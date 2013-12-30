//
//  HomeViewController.m
//  bootstrap-ios
//
//  Created by Marcos Pinazo on 2/6/13.
//  Copyright (c) 2013 [WE ARE] DEVELAPPERS. All rights reserved.
//

#import "HomeViewController.h"
#import "UIView+FrameUtils.h"
#import "BaseModalView.h"
#import "ModalManager.h"
#import "MMDrawerBarButtonItem.h"
#import "UIViewController+MMDrawerController.h"
#import "Restaurant.h"
#import "Floor.h"
#import "Table.h"
#import "SelectBoardViewController.h"
#import "EditPlateViewController.h"
#import "CoreService.h"
#import "Order.h"
#import "Model.h"
#import "MBProgressHUD.h"
#import "CardViewController.h"
#import "HomeCell.h"

@interface HomeViewController ()
@property (nonatomic,strong) NSMutableArray *OrdersArray;
@end


UIBarButtonItem *anotherButton;

@implementation HomeViewController

- (id)initWithNibName:(NSString *)nibNameOrNil bundle:(NSBundle *)nibBundleOrNil
{
    self = [super initWithNibName:nibNameOrNil bundle:nibBundleOrNil];
    if (self) {
        
    }
    return self;
}

- (void)viewDidLoad
{
    [super viewDidLoad];
    [self setupLeftMenuButton];
    
    anotherButton = [[UIBarButtonItem alloc] initWithImage:[UIImage imageNamed:@"inbox"] style:UIBarButtonItemStylePlain target:self action:@selector(SendAllAction:)];
    self.navigationItem.rightBarButtonItem = anotherButton;
}

- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
}

- (void)viewWillAppear:(BOOL)animated
{
    [super viewWillAppear:animated];
    if ([[[Model getInstance]selectedFloor] sid]&&[[[Model getInstance]selectedTable] sid]) {
        self.currentFloor=[[Model getInstance]selectedFloor];
        self.currentTable=[[Model getInstance]selectedTable];
    }else{
        self.currentTable=nil;
        self.currentFloor=nil;
    }
    if (self.currentTable.sid) {
        self.cardButton.hidden=NO;
        self.ticketButton.hidden=NO;
        self.secondsButton.hidden=NO;
        self.TableLabel.alpha=1.0;
        self.TableLabel.text=[NSString stringWithFormat:@"%@ mesa %i",self.currentFloor.name,self.currentTable.tableNumber];
        [self.selectTableButton setTitle:[NSString stringWithFormat:@"%@ mesa %i",self.currentFloor.name,self.currentTable.tableNumber] forState:UIControlStateNormal];
        self.OrdersArray=[[[CoreService getInstance] db] getOrdersWithTableid:self.currentTable.tableId];
        if ([self.OrdersArray count]>0) {
            self.navigationItem.rightBarButtonItem.enabled=YES;
        }else{
            self.navigationItem.rightBarButtonItem.enabled=NO;
        }
        [self.tableView reloadData];
    }
    else{
        self.cardButton.hidden=YES;
        self.ticketButton.hidden=YES;
        self.secondsButton.hidden=YES;
        self.navigationItem.rightBarButtonItem.enabled=NO;
        [self.selectTableButton setTitle:@"Selecciona una mesa" forState:UIControlStateNormal];
    }
}

- (void)viewDidAppear:(BOOL)animated
{
    [super viewDidAppear:animated];
}

#pragma mark - Setup interface methods

-(void)setupLeftMenuButton{
    MMDrawerBarButtonItem * leftDrawerButton = [[MMDrawerBarButtonItem alloc] initWithTarget:self action:@selector(leftDrawerButtonPress:)];
    [self.navigationItem setLeftBarButtonItem:leftDrawerButton animated:YES];
}

#pragma mark - Button Handlers
-(void)leftDrawerButtonPress:(id)sender
{
    [self.mm_drawerController toggleDrawerSide:MMDrawerSideLeft animated:YES completion:nil];
}

#pragma mark - Actions

- (IBAction)SelectTableAction:(UIButton*)button
{
    SelectBoardViewController * selectBoardViewController=[[SelectBoardViewController alloc]init];
    selectBoardViewController.floorsArray=self.floorsArray;
    if (self.currentTable) {
        for (int i=0;i<[self.floorsArray count]; i++) {
            if ([[self.floorsArray objectAtIndex:i] floorId]==self.currentFloor.floorId) {
                selectBoardViewController.floorNumber=i;
                for (int j=0; j<[[[self.floorsArray objectAtIndex:i] tables] count]; j++) {
                    if ([[[[self.floorsArray objectAtIndex:i] tables] objectAtIndex:j] tableId]==self.currentTable.tableId) {
                        selectBoardViewController.tableNumber=j;
                    }
                }
            }
        }
    }
    [self.navigationController pushViewController:selectBoardViewController animated:YES];
}

- (IBAction)deleteAllAction:(id)sender {
    for (Order *order in self.OrdersArray) {
        [[[CoreService getInstance]db]deleteOrderWithId:order.orderId];
    }
    self.OrdersArray=[[[CoreService getInstance] db] getOrdersWithTableid:self.currentTable.tableId];
    [self.tableView reloadData];
}

- (IBAction)CardAction:(id)sender {
    CardViewController * cardViewController = [[CardViewController alloc] init];
    cardViewController.restaurant=[[[CoreService getInstance] db]getRestaurant];
    cardViewController.leftControllSelected=YES;
    UINavigationController *nav;
    nav = [[UINavigationController alloc] initWithRootViewController:cardViewController];
    [[nav.navigationBar topItem ]setTitle:@"Pedido"];
    
    [self.mm_drawerController setCenterViewController:nav withCloseAnimation:YES completion:nil];
}

- (IBAction)SendAllAction:(id)sender
{
    MBProgressHUD *hud= [MBProgressHUD showHUDAddedTo:self.view animated:YES];
    hud.mode = MBProgressHUDModeIndeterminate;
    hud.labelText = @"Enviando...";
    [[CoreService getInstance] postDishWithOrderArray:self.OrdersArray succes:^(NSMutableDictionary *json) {
        
        if ([[json objectForKey:@"success"] intValue]==1) {
            NSLog(@"Enviado el pedido con existo");
            hud.labelText = @"Enviada comanda con éxito";
            hud.mode=MBProgressHUDModeCustomView;
            hud.customView=nil;
            [hud hide:YES afterDelay:1];
            [self deleteAllAction:nil];
            self.navigationItem.rightBarButtonItem.enabled=NO;
        }else{
            [hud hide:YES];
            [[[UIAlertView alloc]initWithTitle:@"Error al enviar" message:@"Comprueba si la mesa esta abierta e intentalo otra vez" delegate:nil cancelButtonTitle:@"Ok" otherButtonTitles: nil] show];
        }
        
    } failure:^(NSMutableDictionary *json) {
        [hud hide:YES];
        [[[UIAlertView alloc]initWithTitle:@"Error con el POS" message:@"No se ha conseguido comunicar con el POS." delegate:nil cancelButtonTitle:@"Ok" otherButtonTitles: nil] show];
    }];
}

- (IBAction)secondAction:(id)sender
{
    Table *selectedTable=self.currentTable;
    [selectedTable setFloorId:self.currentFloor.floorId];
    [[CoreService getInstance]postSecondDishesWithKey:[[[Model getInstance] loggedUser] mwKey] table:selectedTable succes:^(NSMutableDictionary *json) {
        if ([[json objectForKey:@"success"] intValue]==1) {
            [[[UIAlertView alloc]initWithTitle:@"Segundos Solicitados" message:@"Se han pedido ha cocina los segundos" delegate:nil cancelButtonTitle:@"Ok" otherButtonTitles: nil] show];
        }else{
            [[[UIAlertView alloc]initWithTitle:@"Error de envio" message:@"Comprueba que la mesa esté abierta" delegate:nil cancelButtonTitle:@"Ok" otherButtonTitles: nil] show];
        }
        
    } failure:^(NSMutableDictionary *json) {
        [[[UIAlertView alloc]initWithTitle:@"Error de conexión" message:@"No se ha podido comunicar la app con el POS" delegate:nil cancelButtonTitle:@"Ok" otherButtonTitles: nil] show];
    }];
}

- (IBAction)printTicketAction:(id)sender {
    SelectBoardViewController * selectBoardViewController=[[SelectBoardViewController alloc]init];
    if (self.currentTable) {
        for (int i=0;i<[self.floorsArray count]; i++) {
            if ([[self.floorsArray objectAtIndex:i] floorId]==self.currentFloor.floorId) {
                selectBoardViewController.floorNumber=i;
                for (int j=0; j<[[[self.floorsArray objectAtIndex:i] tables] count]; j++) {
                    if ([[[[self.floorsArray objectAtIndex:i] tables] objectAtIndex:j] tableId]==self.currentTable.tableId) {
                        selectBoardViewController.tableNumber=j;
                    }
                }
            }
        }
    }
    [selectBoardViewController SelectTicketActionWithTable:self.currentTable];
    selectBoardViewController.floorsArray=self.floorsArray;
    [self.navigationController pushViewController:selectBoardViewController animated:YES];
}

#pragma mark - UITableViewDataSource methods

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section
{
    if ([self.OrdersArray count]==0) {
        tableView.hidden=YES;
        self.deleteButton.hidden=YES;
        self.sendButton.hidden=YES;
        self.navigationItem.rightBarButtonItem.enabled=NO;
        return 0;
    }else{
        tableView.hidden=NO;
        self.deleteButton.hidden=NO;
        self.sendButton.hidden=NO;
        self.navigationItem.rightBarButtonItem.enabled=YES;
        return [[self OrdersArray]count];
    }
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath
{
    static NSString *CellIdentifier = @"Cell";
    HomeCell *cell;
    
    cell = [tableView dequeueReusableCellWithIdentifier:CellIdentifier];
    if (cell == nil) {
        NSArray* topLevelObjects = [[NSBundle mainBundle] loadNibNamed:@"HomeCell" owner:self options:nil];
        for (id currentObject in topLevelObjects) {
            if ([currentObject isKindOfClass:[UITableViewCell class]]) {
                cell = (HomeCell *)currentObject;
                break;
            }
        }
    }
    Order *currentOrder=[self.OrdersArray objectAtIndex:indexPath.row];
    NSMutableArray *modifiersOrder=[[[CoreService getInstance]db] getOrdersModsWithOrderId:currentOrder.orderId];
    NSArray *modifiersValuesArray = [modifiersOrder valueForKey:@"value"];
    cell.titleLabel.text=[NSString stringWithFormat:@"%i   %@",[currentOrder quantity],[currentOrder productName]];
    NSString *note=[NSString stringWithFormat:@"%@ %@", [[modifiersValuesArray valueForKey:@"description"] componentsJoinedByString:@"\n "],[[currentOrder note] isEqualToString:@""]?@"":[NSString stringWithFormat:@"\n %@",[currentOrder note]] ];
    if ([modifiersValuesArray count]==0) {
        note=[[currentOrder note] isEqualToString:@""]?@"":[NSString stringWithFormat:@"%@",[currentOrder note]];
    }
    cell.subtitleLabel.text=note;
    cell.subtitleLabel.font=[UIFont systemFontOfSize:12];
    if ([modifiersValuesArray count]==0 && [[currentOrder note] isEqualToString:@""]) {
        [cell.titleLabel frameCenterVerticallyInParent];
    }else{
        [cell.titleLabel frameMoveToY:2];
    }
    [cell setSelectionStyle:UITableViewCellSelectionStyleNone];
    cell.priceLabel.text=[NSString stringWithFormat:@"%.2f",[currentOrder.price floatValue]*[currentOrder quantity] ];
    
    // dynamic size
    CGSize maximumLabelSize = CGSizeMake(200, FLT_MAX);
    
    CGSize expectedLabelSize = [note sizeWithFont:[UIFont systemFontOfSize:12] constrainedToSize:maximumLabelSize lineBreakMode:cell.subtitleLabel.lineBreakMode];
    
    //adjust the label the the new height.
    CGRect newFrame = cell.subtitleLabel.frame;
    newFrame.size.height = expectedLabelSize.height+20;
    cell.subtitleLabel.frame = newFrame;
    //
    return cell;

}

-(CGFloat)tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath
{
    Order *currentOrder=[self.OrdersArray objectAtIndex:indexPath.row];
    NSMutableArray *modifiersOrder=[[[CoreService getInstance]db] getOrdersModsWithOrderId:currentOrder.orderId];
    NSArray *modifiersValuesArray = [modifiersOrder valueForKey:@"value"];
    NSString *note=[NSString stringWithFormat:@"%@ %@", [[modifiersValuesArray valueForKey:@"description"] componentsJoinedByString:@"\n "],[[currentOrder note] isEqualToString:@""]?@"":[NSString stringWithFormat:@"\n %@",[currentOrder note]] ];
    if ([modifiersValuesArray count]==0 && [[currentOrder note] isEqualToString:@""]) {
        return 60;
    }
    
    // dynamic size
    CGSize maximumLabelSize = CGSizeMake(200, FLT_MAX);
    
    CGSize expectedLabelSize = [note sizeWithFont:[UIFont systemFontOfSize:12] constrainedToSize:maximumLabelSize lineBreakMode:NSLineBreakByWordWrapping];
    return expectedLabelSize.height+50;
}

-(void)tableView:(UITableView *)tableView commitEditingStyle:(UITableViewCellEditingStyle)editingStyle forRowAtIndexPath:(NSIndexPath *)indexPath
{
    if (editingStyle == UITableViewCellEditingStyleDelete) {
        
        // Delete the row from the data source
        Order *order=[self.OrdersArray objectAtIndex:[indexPath row]];
        [[[CoreService getInstance] db] deleteOrderWithId:order.orderId];
        [self.OrdersArray removeObjectAtIndex:[indexPath row]];
        // Delete row using the cool literal version of [NSArray arrayWithObject:indexPath]
        
        [tableView deleteRowsAtIndexPaths:@[indexPath] withRowAnimation:UITableViewRowAnimationFade];
    }
}

- (BOOL)tableView:(UITableView *)tableView canEditRowAtIndexPath:(NSIndexPath *)indexPath
{
    // Return YES if you want the specified item to be editable.
    return YES;
}

-(void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath
{
    Order *order=[self.OrdersArray objectAtIndex:[indexPath row]];
    EditPlateViewController *editPlateViewController=[[EditPlateViewController alloc]init];
    editPlateViewController.order=order;
    [self.navigationController pushViewController:editPlateViewController animated:YES];
}

@end
