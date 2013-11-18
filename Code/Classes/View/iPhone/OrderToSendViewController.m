//
//  OrderToSendViewController.m
//  meWaiter-ios
//
//  Created by omar megdadi on 15/10/13.
//  Copyright (c) 2013 [WE ARE] DEVELAPPERS. All rights reserved.
//

#import "OrderToSendViewController.h"
#import "MMDrawerBarButtonItem.h"
#import "UIViewController+MMDrawerController.h"
#import "CoreService.h"
#import "MBProgressHUD.h"

NSMutableArray *tablesArray;
NSMutableArray *OrdersTableArray;
BootstrapDB *dataBase;

@interface OrderToSendViewController ()

@end

@implementation OrderToSendViewController

- (id)initWithNibName:(NSString *)nibNameOrNil bundle:(NSBundle *)nibBundleOrNil
{
    self = [super initWithNibName:nibNameOrNil bundle:nibBundleOrNil];
    if (self) {
        // Custom initialization
    }
    return self;
}

- (void)viewDidLoad
{
    [super viewDidLoad];
    [self setupLeftMenuButton];
    [self setupDataSourceElements];
    // Do any additional setup after loading the view from its nib.
}

- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

#pragma mark - setup view

-(void)setupLeftMenuButton{
    MMDrawerBarButtonItem * leftDrawerButton = [[MMDrawerBarButtonItem alloc] initWithTarget:self action:@selector(leftDrawerButtonPress:)];
    [self.navigationItem setLeftBarButtonItem:leftDrawerButton animated:YES];
}

-(void)setupDataSourceElements
{
    dataBase=[[CoreService getInstance]db];
    tablesArray=[[NSMutableArray alloc]init];
    OrdersTableArray=[[NSMutableArray alloc]init];
    tablesArray=[[[dataBase getTableIdOrdersSet]allObjects] mutableCopy];
}

#pragma mark - Button Handlers
-(void)leftDrawerButtonPress:(id)sender{
    [self.mm_drawerController toggleDrawerSide:MMDrawerSideLeft animated:YES completion:nil];
}

- (IBAction)SendAllOrdersToPosAction:(id)sender
{
    for (NSNumber *tableid in tablesArray) {
        Table* table=[dataBase getTableWithId:[tableid intValue]];
        OrdersTableArray=[dataBase getOrdersWithTableid:table.tableId];
        MBProgressHUD *hud= [MBProgressHUD showHUDAddedTo:self.view animated:YES];
        hud.mode = MBProgressHUDModeIndeterminate;
        hud.labelText = @"Enviando...";
        [[CoreService getInstance] postDishWithOrderArray:OrdersTableArray table:table succes:^(NSMutableDictionary *json) {
            
            if ([[json objectForKey:@"success"] intValue]==1) {
                NSLog(@"Enviado el pedido con existo");
                hud.labelText = @"Enviada comanda con éxito";
                hud.mode=MBProgressHUDModeCustomView;
                hud.customView=nil;
                [hud hide:YES afterDelay:1];
                for (Order *order in OrdersTableArray) {
                    [dataBase deleteOrderWithId:order.orderId];
                }
                
                [tablesArray removeObject:tableid];
                [self.tableView reloadData];
            }else{
                [hud hide:YES];
                [[[UIAlertView alloc]initWithTitle:@"Error al enviar" message:[NSString stringWithFormat: @"Comprueba si  %@ esta abierta e intentalo otra vez",[table nameOfTable]] delegate:nil cancelButtonTitle:@"Ok" otherButtonTitles: nil] show];
            }
            
        } failure:^(NSMutableDictionary *json) {
            [hud hide:YES];
            [[[UIAlertView alloc]initWithTitle:@"Error con el POS" message:@"No se ha conseguido comunicar con el POS." delegate:nil cancelButtonTitle:@"Ok" otherButtonTitles: nil] show];
        }];
    }
    

}

#pragma mark -UITableDataSource

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section
{
    return [[dataBase getOrdersWithTableid:[[tablesArray objectAtIndex:section] intValue]] count];
}

-(NSInteger)numberOfSectionsInTableView:(UITableView *)tableView
{
    return [tablesArray count];
}

-(NSString *)tableView:(UITableView *)tableView titleForHeaderInSection:(NSInteger)section{
    Table *table=[dataBase getTableWithId:[[tablesArray objectAtIndex:section] intValue]];
    return [table nameOfTable];
}


- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath
{
    Table *table=[dataBase getTableWithId:[[tablesArray objectAtIndex:indexPath.section] intValue]];
    OrdersTableArray=[dataBase getOrdersWithTableid:table.tableId];
    Order *currentOrder=[OrdersTableArray objectAtIndex:indexPath.row];
    UITableViewCell * cell = [[UITableViewCell alloc]initWithStyle:UITableViewCellStyleDefault reuseIdentifier:@"Cell"];
    cell.selectionStyle=UITableViewCellSelectionStyleNone;
    cell.textLabel.text=[NSString stringWithFormat:@"%i  %@",currentOrder.quantity,currentOrder.productName];
    cell.textLabel.font=[UIFont boldSystemFontOfSize:16];
    cell.textLabel.textColor=[UIColor blackColor];
    return cell;
}
@end
