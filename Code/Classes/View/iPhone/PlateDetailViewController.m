//
//  PlateDetailViewController.m
//  meWaiter-ios
//
//  Created by omar megdadi on 21/10/13.
//  Copyright (c) 2013 [WE ARE] DEVELAPPERS. All rights reserved.
//

#import "PlateDetailViewController.h"
#import "Dish.h"
#import "CoreService.h"
#import "ModifierListSets.h"
#import "ModifierList.h"
#import "Modifier.h"
#import "Model.h"
#import "MBProgressHUD.h"
#import "UIViewController+MMDrawerController.h"
#import "HomeViewController.h"
#import "UIView+FrameUtils.h"
#import "Constants.h"

@interface PlateDetailViewController ()

@end

ModifierListSets *modifierListSet;
NSMutableSet *selectedModifiers;
NSMutableSet *selectedDiscounts;
NSMutableArray *discountsArray;
NSMutableSet *mandatorySet;
UIBarButtonItem *anotherButton;


@implementation PlateDetailViewController

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
    selectedModifiers=[[NSMutableSet alloc] init];
    selectedDiscounts=[[NSMutableSet alloc]init];
    [self.addNoteView frameResizeByHeightDelta:-KResizeNoteView];
    [self.tableView setContentSize:CGSizeMake(self.tableView.contentSize.width,self.tableView.contentSize.height-KResizeNoteView)];
    self.navigationItem.title = self.dish.name;
    self.detailTextView.delegate=self;
    int mlsId=[[[CoreService getInstance] db]getIdMlsWithid:[self.dish dishId]];
    modifierListSet=nil;
    if (mlsId!=0) {
        modifierListSet=[[[CoreService getInstance] db]getModifierListSetWithid:mlsId];
        mandatorySet = [[NSMutableSet alloc]init];
        int section=0;
        for (ModifierList *modifierList in [modifierListSet modifierLists]) {
            if ([[modifierList isMandatory] isEqualToString:@"1"]) {
                [mandatorySet addObject:[NSNumber numberWithInt:section]];
            }
            section++;
        }
    }else{
        mandatorySet = [[NSMutableSet alloc]init];
    }
    if ([self.dish.sid isEqualToString:self.section.sid]) {
        discountsArray=[[NSMutableArray alloc]init];
    }else{
        discountsArray=[[[CoreService getInstance ]db]getDiscountWithMenuId:[[[CoreService getInstance ]db] getMenuIdOfDishWithId:self.dish.dishId] sectionId:[[[CoreService getInstance ]db] getSectionIdOfDishWithId:self.dish.dishId] dishId:self.dish.dishId];
    }
    
    NSLog(@"%i",mlsId);
    
    anotherButton = [[UIBarButtonItem alloc] initWithImage:[UIImage imageNamed:@"plus"] style:UIBarButtonItemStylePlain target:self action:@selector(addtoOrder:)];
    self.navigationItem.rightBarButtonItem = anotherButton;
    
    UIButton *backButton = [[UIButton alloc] initWithFrame: CGRectMake(0, 0, 70.0f, 30.0f)];
    if (IS_IOS_7) {
        UIImage *backImage = [UIImage imageNamed:@"leftArrow"];
        
        [backButton setImage:backImage  forState:UIControlStateNormal];
        [backButton setTitle:@" Volver" forState:UIControlStateNormal];
        [backButton setTitleColor:[UIColor blueColor] forState:UIControlStateNormal];
        [backButton addTarget:self action:@selector(back:) forControlEvents:UIControlEventTouchUpInside];
    }else{
        UIImage *backImage = [[UIImage imageNamed:@"backButton"] resizableImageWithCapInsets: UIEdgeInsetsMake(0.0, 15.0, 0.0, 5.0)];
        
        [backButton setBackgroundImage:backImage  forState:UIControlStateNormal];
        [backButton setTitle:@"  Volver" forState:UIControlStateNormal];
        [backButton setTitleColor:[UIColor whiteColor] forState:UIControlStateNormal];
        [backButton addTarget:self action:@selector(back:) forControlEvents:UIControlEventTouchUpInside];
    }
    
    UIBarButtonItem *backButtonItem = [[UIBarButtonItem alloc] initWithCustomView:backButton];
    self.navigationItem.leftBarButtonItem = backButtonItem;
    
    for (int i=0; i<[[modifierListSet modifierLists] count]; i++) {
        if ([[[modifierListSet modifierLists]objectAtIndex:i] selectedModiefierSid]) {
            for (int j=0; j<[[[[modifierListSet modifierLists]objectAtIndex:i]modifiers] count]; j++) {
                if ([[[[[[modifierListSet modifierLists]objectAtIndex:i]modifiers] objectAtIndex:j]sid] isEqualToString:[[[modifierListSet modifierLists]objectAtIndex:i] selectedModiefierSid]]) {
                    [selectedModifiers addObject:[NSIndexPath indexPathForRow:j inSection:i]];
                }
            }
        }
    }
}

-(void) back:(id)sender
{
    [self.navigationController popViewControllerAnimated:YES];
}

-(void)viewWillAppear:(BOOL)animated{
    [super viewWillAppear:animated];
    [[NSNotificationCenter defaultCenter] addObserver:self
                                             selector:@selector(keyboardWasShown:)
                                                 name:UIKeyboardWillShowNotification
                                               object:nil];
    
    [[NSNotificationCenter defaultCenter] addObserver:self
                                             selector:@selector(keyboardWillBeHidden:)
                                                 name:UIKeyboardWillHideNotification
                                               object:nil];
    //vamos a ver si todos los obligatorios estan
    NSMutableSet *selectedSectionSet=[[NSMutableSet alloc]init];
    for (NSIndexPath *indexPath in selectedModifiers) {
        [selectedSectionSet addObject:[NSNumber numberWithInt:indexPath.section]];
    }
    BOOL isContained=YES;
    for (NSNumber *number in [mandatorySet allObjects]) {
        isContained= isContained && [selectedSectionSet containsObject:number];
    }
    self.addToBoardButton.hidden=!isContained;
    self.addToOrderButton.hidden=!isContained;
    self.navigationItem.rightBarButtonItem.enabled=isContained;
    self.mandatoryLabel.hidden=isContained;
}

-(void)viewWillDisappear:(BOOL)animated{
    [super viewWillDisappear:animated];
    [[NSNotificationCenter defaultCenter] removeObserver:self
                                                    name:UIKeyboardWillShowNotification
                                                  object:nil];
    
    [[NSNotificationCenter defaultCenter] removeObserver:self
                                                    name:UIKeyboardWillHideNotification
                                                  object:nil];
}

- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

- (IBAction)okAction:(UIButton *)sender
{
    [self.detailTextView resignFirstResponder];
    sender.hidden=YES;
}

- (IBAction)numberOfUnitsChange:(UIStepper *)stepper {
    self.unitsLabel.text=[NSString stringWithFormat:@"%i",(int)[stepper value] ];
}

- (IBAction)dismissKeyboard:(id)sender {
    [self.detailTextView resignFirstResponder];
}

- (IBAction)sendToPosAction:(id)sender {
    if ([[[Model getInstance]selectedTable]sid]) {
        NSMutableArray *modifierArray=[[NSMutableArray alloc]init];
        for (NSIndexPath *index in [selectedModifiers allObjects]) {
            ModifierList *modifierList=[modifierListSet.modifierLists objectAtIndex:index.section];
            Modifier *selectedModifier=[[modifierList modifiers]objectAtIndex:index.row];
            NSDictionary *modifierListDictionary=[NSDictionary dictionaryWithObjectsAndKeys:modifierList.sid,@"sid",modifierList.name,@"name",[NSArray arrayWithObject:[NSDictionary dictionaryWithObjectsAndKeys:selectedModifier.sid,@"sid",selectedModifier.name,@"name", nil]],@"selected_modifiers", nil];
            [modifierArray addObject:modifierListDictionary];
        }
        NSDictionary * modifierListSetDictionary=nil;
        if ([modifierArray count]>0) {
            modifierListSetDictionary=[NSDictionary dictionaryWithObjectsAndKeys:modifierListSet.sid,@"sid",modifierListSet.name,@"name",modifierArray,@"modifier_lists",nil];
        }
        Discount *discount=[[Discount alloc]init];
        if ([[selectedDiscounts allObjects] count]>0) {
            discount=[discountsArray objectAtIndex:[(NSIndexPath*)[[selectedDiscounts allObjects]firstObject]row]];
        }
        [[CoreService getInstance] postDishWithMultiply:self.unitsLabel.text dish:self.dish note:self.detailTextView.text categorySid:self.section.sid modifiers:modifierListSetDictionary discount:discount succes:^(NSMutableDictionary *json) {
            if ([[json objectForKey:@"success"] intValue]==1) {
                [[[UIAlertView alloc]initWithTitle:@"Recibido" message:@"Se Ha transferido el plato con las unidades al POS" delegate:nil cancelButtonTitle:@"Ok" otherButtonTitles: nil] show];
            }else{
                [[[UIAlertView alloc]initWithTitle:@"Error al enviar" message:@"Comprueba si la mesa esta abierta e intentalo otra vez" delegate:nil cancelButtonTitle:@"Ok" otherButtonTitles: nil] show];
            }
        } failure:^(NSMutableDictionary *json) {
            [[[UIAlertView alloc]initWithTitle:@"Error" message:@"Hemos tenido un error de comunicacion con el pos" delegate:nil cancelButtonTitle:@"Ok" otherButtonTitles: nil] show];
        }];
    }else{
        [[[UIAlertView alloc]initWithTitle:@"No has elegido mesa" message:@"debes haber elegido una mesa a la que poder incluir articulos" delegate:nil cancelButtonTitle:@"Ok" otherButtonTitles: nil] show];
    }
}

- (IBAction)noteAction:(UIButton *)sender
{
    sender.hidden=YES;
    self.detailTextView.hidden=NO;
    [self.detailTextView becomeFirstResponder];
    [self.addNoteView frameResizeByHeightDelta:+KResizeNoteView];
    [self.tableView setContentSize:CGSizeMake(self.tableView.contentSize.width,self.tableView.contentSize.height+KResizeNoteView)];
}

-(IBAction)addtoOrder:(id)sender{
    if ([[[Model getInstance]selectedTable]sid]) {
        Order *order=[[Order alloc] init];
        order.tableId=[[[Model getInstance] selectedTable]tableId];
        order.sid=self.dish.sid;
        order.categorySid=self.section.sid;
        order.productName=self.dish.name;
        order.price=self.dish.price;
        order.quantity=[self.unitsLabel.text intValue];
        order.note=self.detailTextView.text;
        [[[CoreService getInstance] db] insertOrder:order];
        order=[[[CoreService getInstance]db]getLastOrder];
        for (NSIndexPath *index in [selectedModifiers allObjects]) {
            [[[CoreService getInstance]db] insertOrderModsWithIndexPath:index modifiersListSet:modifierListSet orderId:order.orderId];
        }
        for (NSIndexPath *indexPath in [selectedDiscounts allObjects]) {
            [[[CoreService getInstance]db] insertOrderDiscountWithDiscount:[discountsArray objectAtIndex:indexPath.row] OrderId:order.orderId];
        }
        
        MBProgressHUD *hud= [MBProgressHUD showHUDAddedTo:self.view animated:YES];
        hud.mode = MBProgressHUDModeIndeterminate;
        hud.labelText = @"añadido a la comanda";
        hud.mode=MBProgressHUDModeCustomView;
        hud.customView=nil;
        [hud hide:YES afterDelay:1];
        [self performSelector:@selector(backAction) withObject:Nil afterDelay:1.3];
        
    }else{
        [[[UIAlertView alloc]initWithTitle:@"No has elegido mesa" message:@"debes haber elegido una mesa a la que poder incluir articulos" delegate:nil cancelButtonTitle:@"Ok" otherButtonTitles: nil] show];
    }
}

-(void)backAction
{
    [self.navigationController popViewControllerAnimated:YES];
}

-(void) goToBoardsAction
{
    UINavigationController *nav;
    BootstrapDB *dataBase=[[CoreService getInstance]db];
    
    HomeViewController * homeViewController = [[HomeViewController alloc] init];
    homeViewController.restaurant=[dataBase getRestaurant];
    homeViewController.floorsArray=[dataBase getFloorsArray];
    nav = [[UINavigationController alloc] initWithRootViewController:homeViewController];
    [[nav.navigationBar topItem ]setTitle:@"Pedido"];
    
    [self.mm_drawerController setCenterViewController:nav withCloseAnimation:YES completion:nil];
}

#pragma mark - UITableViewDataSource methods
-(NSInteger)numberOfSectionsInTableView:(UITableView *)tableView
{
    if ([discountsArray count]==0) {
        return [[modifierListSet modifierLists] count];
    }else{
        return [[modifierListSet modifierLists] count]+1;
    }
    
}

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section
{
    if (section<[[modifierListSet modifierLists] count]) {
        return [[[[modifierListSet modifierLists] objectAtIndex:section] modifiers] count];
    }else{
        return [discountsArray count];
    }
    
}

-(NSString *)tableView:(UITableView *)tableView titleForHeaderInSection:(NSInteger)section{
    if (section<[[modifierListSet modifierLists] count]) {
        if ([mandatorySet containsObject:[NSNumber numberWithInt:section] ]) {
            return [NSString stringWithFormat:@"%@ (Obligatorio)",[[[modifierListSet modifierLists] objectAtIndex:section] name] ];
        }else{
            return [[[modifierListSet modifierLists] objectAtIndex:section] name];
        }
        
    }else{
        return @"Descuentos";
    }
    
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath
{
    static NSString *CellIdentifier = @"Cell";
    UITableViewCell *cell;
    
    cell = [tableView dequeueReusableCellWithIdentifier:CellIdentifier];
    
    if (cell == nil) {
        cell = [[UITableViewCell alloc] initWithStyle:UITableViewCellStyleDefault reuseIdentifier:CellIdentifier];
    }
    [cell setSelectionStyle:UITableViewCellSelectionStyleNone];
    if (indexPath.section<[[modifierListSet modifierLists] count]) {
        Modifier *currentModifier=[[[[modifierListSet modifierLists] objectAtIndex:indexPath.section] modifiers] objectAtIndex:indexPath.row];
        cell.textLabel.text=currentModifier.name;
        
        //TODO poner check al indexpath que esta seleccionado
        if ([selectedModifiers containsObject:indexPath]) {
            cell.accessoryType = UITableViewCellAccessoryCheckmark;
        }else{
            cell.accessoryType = UITableViewCellAccessoryNone;
        }
        return cell;
    }else{
        Discount *discount=[discountsArray objectAtIndex:indexPath.row];
        cell.textLabel.text=discount.name;
        return cell;
    }
    
}

- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath
{
    UITableViewCell *cell = [tableView cellForRowAtIndexPath:indexPath];
    if (indexPath.section<[[modifierListSet modifierLists] count]) {
        if ([[[[modifierListSet modifierLists]objectAtIndex:indexPath.section] isMultioption] isEqualToString:@"1"]) {
            if (cell.accessoryType == UITableViewCellAccessoryCheckmark) {
                cell.accessoryType = UITableViewCellAccessoryNone;
                [selectedModifiers removeObject:indexPath];
            } else {
                cell.accessoryType = UITableViewCellAccessoryCheckmark;
                [selectedModifiers addObject:indexPath];
            }
        }else{
            NSArray *SelectedArray=[selectedModifiers allObjects];
            for (NSIndexPath *index in SelectedArray) {
                if (index.section==indexPath.section) {
                    if (index.row!=indexPath.row) {
                        [[tableView cellForRowAtIndexPath:index] setAccessoryType:UITableViewCellAccessoryNone];
                    }
                    [selectedModifiers removeObject:index];
                }
            };
            if (cell.accessoryType == UITableViewCellAccessoryCheckmark) {
                cell.accessoryType = UITableViewCellAccessoryNone;
            } else {
                cell.accessoryType = UITableViewCellAccessoryCheckmark;
                [selectedModifiers addObject:indexPath];
            }
            //vamos a ver si todos los obligatorios estan
            NSMutableSet *selectedSectionSet=[[NSMutableSet alloc]init];
            for (NSIndexPath *indexPath in selectedModifiers) {
                [selectedSectionSet addObject:[NSNumber numberWithInt:indexPath.section]];
            }
            BOOL isContained=YES;
            for (NSNumber *number in [mandatorySet allObjects]) {
                isContained= isContained && [selectedSectionSet containsObject:number];
            }
            self.addToBoardButton.hidden=!isContained;
            self.addToOrderButton.hidden=!isContained;
            self.navigationItem.rightBarButtonItem.enabled=isContained;
            self.mandatoryLabel.hidden=isContained;
        }
        
    
        
    }else{
        NSArray *SelectedDiscountArray=[selectedDiscounts allObjects];
        for (NSIndexPath *index in SelectedDiscountArray) {
            if (index.section==indexPath.section) {
                if (index.row!=indexPath.row) {
                    [[tableView cellForRowAtIndexPath:index] setAccessoryType:UITableViewCellAccessoryNone];
                }
                [selectedDiscounts removeObject:index];
            }
        };
        if (cell.accessoryType == UITableViewCellAccessoryCheckmark) {
            cell.accessoryType = UITableViewCellAccessoryNone;
        } else {
            cell.accessoryType = UITableViewCellAccessoryCheckmark;
            [selectedDiscounts addObject:indexPath];
        }
    }
    
}

#pragma mark -keyboards methods

- (void)keyboardWasShown:(NSNotification*)aNotification
{
    self.okButton.hidden=NO;
    NSDictionary* info = [aNotification userInfo];
    CGSize kbSize = [[info objectForKey:UIKeyboardFrameBeginUserInfoKey] CGRectValue].size;
    UIEdgeInsets contentInsets =UIEdgeInsetsMake(0.0, 0.0, kbSize.height, 0.0);
    if (IS_IOS_7) {
        contentInsets = UIEdgeInsetsMake(64.0, 0.0, kbSize.height, 0.0);
    }
    self.tableView.contentInset = contentInsets;
    self.tableView.scrollIndicatorInsets = contentInsets;
    
    // If active text field is hidden by keyboard, scroll it so it's visible
    // Your app might not need or want this behavior.
    CGRect aRect = self.view.frame;
    CGRect otherRect=CGRectMake(0, self.tableView.contentSize.height, 1, 1);
    aRect.size.height -= kbSize.height;
    if (!CGRectContainsPoint(aRect,CGPointMake(0, self.tableView.contentSize.height) )) {
        [self.tableView scrollRectToVisible:otherRect animated:YES];
    }
}

// Called when the UIKeyboardWillHideNotification is sent
- (void)keyboardWillBeHidden:(NSNotification*)aNotification
{
    if ([[[self.detailTextView.text componentsSeparatedByCharactersInSet:[NSCharacterSet newlineCharacterSet]] componentsJoinedByString:@""] length]==0) {
        self.addNoteButton.hidden=NO;
        self.detailTextView.hidden=YES;
        self.detailTextView.text=@"";
        [self.addNoteView frameResizeByHeightDelta:-KResizeNoteView];
        [self.tableView setContentSize:CGSizeMake(self.tableView.contentSize.width,self.tableView.contentSize.height-KResizeNoteView)];
    }else{
//        [self.tableView setContentSize:CGSizeMake(self.tableView.contentSize.width,self.tableView.contentSize.height+KResizeNoteView)];
    }
    self.okButton.hidden=YES;
    UIEdgeInsets contentInsets =UIEdgeInsetsZero;
    if (IS_IOS_7) {
        if ([[[self.detailTextView.text componentsSeparatedByCharactersInSet:[NSCharacterSet newlineCharacterSet]] componentsJoinedByString:@""] length]==0) {
            contentInsets = UIEdgeInsetsMake(64.0, 0.0,0.0, 0.0);
        }else{
            contentInsets = UIEdgeInsetsMake(64.0, 0.0,100.0, 0.0);
        }
        
    }
    [UIView animateWithDuration:0.25 animations:^{
        self.tableView.contentInset = contentInsets;
        
    }];
    self.tableView.scrollIndicatorInsets = contentInsets;

}

#pragma mark - UIScrollViewDelegate methods

- (void)scrollViewWillBeginDragging:(UIScrollView *)scrollView
{
    [self.detailTextView resignFirstResponder];
}

@end
