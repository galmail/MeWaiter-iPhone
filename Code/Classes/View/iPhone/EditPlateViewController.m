//
//  EditPlateViewController.m
//  meWaiter-ios
//
//  Created by omar megdadi on 30/10/13.
//  Copyright (c) 2013 [WE ARE] DEVELAPPERS. All rights reserved.
//

#import "EditPlateViewController.h"
#import "Dish.h"
#import "CoreService.h"
#import "ModifierListSets.h"
#import "ModifierList.h"
#import "Modifier.h"
#import "Model.h"
#import "MBProgressHUD.h"
#import "OrderMod.h"
#import "Discount.h"
#import "Constants.h"
#import "UIView+FrameUtils.h"



@interface EditPlateViewController ()

@end

ModifierListSets *modifierListSet;
NSMutableSet *selectedModifiers;
NSMutableSet *selectedDiscounts;
NSMutableArray *discountsArray;
NSMutableSet *mandatorySet;

@implementation EditPlateViewController

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
    self.dish=[[[CoreService getInstance] db] getDishWithName:self.order.productName];
    [self.addNoteView frameResizeByHeightDelta:-KResizeNoteView];
    self.navigationItem.title = self.dish.name;
    self.detailTextView.delegate=self;
    self.detailTextView.text=self.order.note;
    self.stepper.value=self.order.quantity;
    self.unitsLabel.text=[NSString stringWithFormat:@"%i",self.order.quantity ];
    int mlsId=[[[CoreService getInstance] db]getIdMlsWithid:[self.dish dishId]];
    modifierListSet=nil;
    if (mlsId!=0) {
        selectedModifiers=[[NSMutableSet alloc] init];
        modifierListSet=[[[CoreService getInstance] db]getModifierListSetWithid:mlsId];
        [self configureModifierSet];
        mandatorySet = [[NSMutableSet alloc]init];
        int section=0;
        for (ModifierList *modifierList in [modifierListSet modifierLists]) {
            if ([[modifierList isMandatory] isEqualToString:@"1"]) {
                [mandatorySet addObject:[NSNumber numberWithInt:section]];
            }
            section++;
        }
    }else{
        
    }
    if (![self.order.note isEqualToString:@""]) {
        self.detailTextView.hidden=NO;
        self.addNoteButton.hidden=YES;
        [self.addNoteView frameResizeByHeightDelta:KResizeNoteView];
        [self.tableView setContentSize:CGSizeMake(self.tableView.contentSize.width,self.tableView.contentSize.height+KResizeNoteView)];
    }
    [self configureDiscountSet];
    NSLog(@"%i",mlsId);
    
    // Do any additional setup after loading the view from its nib.
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
    
    self.navigationItem.leftBarButtonItem=backButtonItem;
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

-(void)configureModifierSet
{
    NSMutableArray *orderModsSaved=[[[CoreService getInstance]db]getOrdersModsWithOrderId:self.order.orderId];
    for (OrderMod *orderMod in orderModsSaved) {
        int modifierListSection=0;
        for (ModifierList *modifierList in [modifierListSet modifierLists] ) {
            if ([orderMod.mlistSid isEqualToString:modifierList.sid ]) {
                int modifierRow=0;
                for (Modifier *modifier in [modifierList modifiers]) {
                    if ([modifier.sid isEqualToString: orderMod.modifierSid]) {
                        [selectedModifiers addObject:[NSIndexPath indexPathForRow:modifierRow inSection:modifierListSection]];
                    }
                    modifierRow++;
                }
            }
            modifierListSection++;
        }
    }
}

-(void) configureDiscountSet
{
    discountsArray=[[[CoreService getInstance ]db]getDiscountWithMenuId:[[[CoreService getInstance ]db] getMenuIdOfDishWithId:self.dish.dishId] sectionId:[[[CoreService getInstance ]db] getSectionIdOfDishWithId:self.dish.dishId] dishId:self.dish.dishId];
    Discount *discountSaved=[[[CoreService getInstance]db] getOrderDiscountWithOrderId:self.order.orderId];
    selectedDiscounts=[[NSMutableSet alloc]init];
    int discountPosition=0;
    for (Discount *discount in discountsArray) {
        if ([discountSaved.sid isEqualToString:discount.sid]) {
            if ([[modifierListSet modifierLists]count]>0) {
                [selectedDiscounts addObject:[NSIndexPath indexPathForRow:discountPosition inSection:[[modifierListSet modifierLists]count]]];
            }else{
                [selectedDiscounts addObject:[NSIndexPath indexPathForRow:discountPosition inSection:0]];
            }
        }
        discountPosition++;
    }
}

- (IBAction)numberOfUnitsChange:(UIStepper *)stepper {
    self.unitsLabel.text=[NSString stringWithFormat:@"%i",(int)[stepper value] ];
}

- (IBAction)dismissKeyboard:(id)sender {
    [self.detailTextView resignFirstResponder];
}

-(IBAction)editPlateAction:(id)sender{
    BootstrapDB* dataBase=[[CoreService getInstance] db];
    self.order.quantity=[self.unitsLabel.text intValue];
    self.order.note=self.detailTextView.text;
    
    [dataBase insertOrder:self.order];
    self.order=[dataBase getLastOrder];
    [dataBase deleteOrderModWithOrderId:self.order.orderId];
    for (NSIndexPath *index in [selectedModifiers allObjects]) {
        [dataBase insertOrderModsWithIndexPath:index modifiersListSet:modifierListSet orderId:self.order.orderId];
    }
    [dataBase deleteOrderDiscountsWithOrderId:self.order.orderId];
    for (NSIndexPath *index in [selectedDiscounts allObjects]) {
        [dataBase insertOrderDiscountWithDiscount:[discountsArray objectAtIndex:index.row] OrderId:self.order.orderId];
    }
    MBProgressHUD *hud= [MBProgressHUD showHUDAddedTo:self.view animated:YES];
    hud.mode = MBProgressHUDModeIndeterminate;
    hud.labelText = @"modificado en la comanda";
    hud.mode=MBProgressHUDModeCustomView;
    hud.customView=nil;
    [hud hide:YES afterDelay:1];
    [self performSelector:@selector(backAction) withObject:Nil afterDelay:1.3];
}

-(void)backAction
{
    [self.navigationController popViewControllerAnimated:YES];
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
        if ([selectedDiscounts containsObject:indexPath]) {
            cell.accessoryType = UITableViewCellAccessoryCheckmark;
        }else{
            cell.accessoryType = UITableViewCellAccessoryNone;
        }
        return cell;
    }
}

- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath
{
    UITableViewCell *cell = [tableView cellForRowAtIndexPath:indexPath];
    if (indexPath.section<[[modifierListSet modifierLists] count]) {
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
        self.changeButton.enabled=isContained;
        if (isContained) {
            [self.changeButton setTitle:@"Realizar cambios" forState:UIControlStateNormal];
            [self.changeButton setBackgroundColor:[UIColor colorWithRed:0.549 green:0.776 blue:0.247 alpha:1.000]];
        }else{
            [self.changeButton setTitle:@"Seleccionar campos obligatorios" forState:UIControlStateNormal];
            [self.changeButton setBackgroundColor:[UIColor colorWithRed:0.890 green:0.145 blue:0.180 alpha:1.000]];
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
    if (!IS_IPHONE_5) {
        otherRect=CGRectMake(0, self.tableView.contentSize.height-KResizeNoteView, 1, 1);
    }
    aRect.size.height -= kbSize.height;
    [self.tableView scrollRectToVisible:otherRect animated:YES];
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
        [self.tableView setContentSize:CGSizeMake(self.tableView.contentSize.width,self.tableView.contentSize.height+KResizeNoteView)];
    }
    self.okButton.hidden=YES;
    
    UIEdgeInsets contentInsets =UIEdgeInsetsZero;
    if (IS_IOS_7) {
        if ([[[self.detailTextView.text componentsSeparatedByCharactersInSet:[NSCharacterSet newlineCharacterSet]] componentsJoinedByString:@""] length]==0) {
            contentInsets = UIEdgeInsetsMake(64.0, 0.0,0.0, 0.0);
        }else{
            if (!IS_IPHONE_5) {
                contentInsets = UIEdgeInsetsMake(64.0, 0.0,0.0, 0.0);
            }else{
                contentInsets = UIEdgeInsetsMake(64.0, 0.0,100.0, 0.0);
            }
        }
        
    }
    [UIView animateWithDuration:0.3 animations:^{
        self.tableView.contentInset = contentInsets;
    }];
    self.tableView.scrollIndicatorInsets = contentInsets;
}

#pragma mark - UIScrollViewDelegate methods

- (void)scrollViewWillBeginDragging:(UIScrollView *)scrollView
{
    [self.detailTextView resignFirstResponder];
}

- (IBAction)okAction:(UIButton *)sender
{
    [self.detailTextView resignFirstResponder];
    sender.hidden=YES;
}

- (IBAction)noteAction:(UIButton *)sender
{
    sender.hidden=YES;
    self.detailTextView.hidden=NO;
    [self.detailTextView becomeFirstResponder];
    [self.addNoteView frameResizeByHeightDelta:+KResizeNoteView];
    [self.tableView setContentSize:CGSizeMake(self.tableView.contentSize.width,self.tableView.contentSize.height+KResizeNoteView)];
}

@end
