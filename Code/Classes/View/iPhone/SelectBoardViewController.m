//
//  SelectBoardViewController.m
//  meWaiter-ios
//
//  Created by omar megdadi on 23/10/13.
//  Copyright (c) 2013 [WE ARE] DEVELAPPERS. All rights reserved.
//

#import "SelectBoardViewController.h"
#import "HomeViewController.h"
#import "CoreService.h"
#import "Model.h"
#import "Floor.h"
#import "Table.h"
#import "UIView+FrameUtils.h"
#import "MBProgressHUD.h"

@interface SelectBoardViewController ()

@property (nonatomic,strong) MBProgressHUD *hud;
@end

NSMutableArray *payArray;
NSMutableSet *selectedPaymentSet;
Payment *selectedPayment;
NSMutableArray *discountArray;
NSMutableSet *selectedDiscount;
float totalpayment;

@implementation SelectBoardViewController

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
    [self setupPickers];
    [self setupTablesDataSourcesArray];
    [self setTitle:@"Mesas"];
    [self setupSwitches];
    //self.floorNumber=0;
    //self.TableNumber=0;
    self.paxTextField.delegate=self;
    
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
    [self.numberPickerView selectRow:self.tableNumber inComponent:0 animated:NO];
    [self.sitePickerView selectRow:self.floorNumber inComponent:0 animated:NO];
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

#pragma mark - Setup interface methods

-(void) setupPickers
{
    [self setupSitePicker];
    [self setupNumberPicker];
}

-(void) setupSitePicker
{
    [self.sitePickerView setDataSource: self];
    [self.sitePickerView  setDelegate: self];
    if (IS_IOS_7) {
        [self.sitePickerView frameMoveByYDelta:50];
    }
}

-(void) setupNumberPicker
{
    [self.numberPickerView setDataSource: self];
    [self.numberPickerView  setDelegate: self];
    if (IS_IOS_7) {
        [self.numberPickerView frameMoveByYDelta:50];
    }
}

-(void) setupTablesDataSourcesArray
{
    BootstrapDB *dataBase=[[CoreService getInstance]db];
    payArray=[dataBase getPaymentsArray];
    discountArray=[dataBase getDiscountOnlyForRestaurant];
    selectedDiscount=[[NSMutableSet alloc]init];
    selectedPaymentSet=[[NSMutableSet alloc]init];
}
-(void)setupSwitches
{
    [[UISwitch appearance] setOnImage:[UIImage imageNamed:@"SiSwitch"]];
    [[UISwitch appearance] setOffImage:[UIImage imageNamed:@"NoSwitch"]];
}
#pragma mark - UIPickerViewDataSource methods

- (NSInteger)numberOfComponentsInPickerView:(UIPickerView *)pickerView
{
    return 1;
}

// returns the # of rows in each component..
- (NSInteger)pickerView:(UIPickerView *)pickerView numberOfRowsInComponent:(NSInteger)component
{
    if (self.sitePickerView==pickerView) {
        return [self.floorsArray count];
    }else if (self.numberPickerView==pickerView){
        return [[[self.floorsArray objectAtIndex:self.floorNumber] tables] count];
    }else{
        return 0;
    }
}

-(NSString *)pickerView:(UIPickerView *)pickerView titleForRow:(NSInteger)row forComponent:(NSInteger)component
{
    if (self.sitePickerView==pickerView) {
        return [self.floorsArray[row] name];
    }else if (self.numberPickerView==pickerView){
        return [NSString stringWithFormat:@"%i",[[self.floorsArray[self.floorNumber] tables][row] tableNumber]];
    }else{
        return 0;
    }
}

-(void)pickerView:(UIPickerView *)pickerView didSelectRow:(NSInteger)row inComponent:(NSInteger)component
{
    if (self.sitePickerView==pickerView) {
        self.floorNumber=row;
        self.TableNumber=0;
        [self.sitePickerView reloadAllComponents];
        [self.numberPickerView selectRow:0 inComponent:0 animated:NO];
        [self.numberPickerView reloadAllComponents];
    }else if (self.numberPickerView==pickerView){
        self.TableNumber=row;
    }
    Table *selectedTable=(Table *)[self.floorsArray[self.floorNumber] tables][self.tableNumber];
    [selectedTable setFloorId:[self.floorsArray[self.floorNumber]floorId]];
    self.tableLabel.text=[selectedTable nameOfTable];
}

- (IBAction)TableSelectedAction:(UIButton *)button
{
    if ([button tag]==0) {

    }else{

    }
}

- (IBAction)SelectBoard:(UIButton *)button
{
    [[CoreService getInstance]getIsOpenedWithSid:[[self.floorsArray[self.floorNumber] tables][self.tableNumber]sid] Succes:^(NSMutableDictionary *json) {
        if ([[json objectForKey:@"opened"] boolValue]) {
            HomeViewController *homeViewController=(HomeViewController *)[[[self navigationController] viewControllers] firstObject];
            [[Model getInstance] setSelectedTable:[self.floorsArray[self.floorNumber] tables][self.tableNumber]];
            [[Model getInstance] setSelectedFloor:self.floorsArray[self.floorNumber]] ;
            [self.navigationController popToViewController:homeViewController animated:YES];
        }else{
            [self.modalView setFrame:[[UIScreen mainScreen] bounds]];
            //[self.littleViewModal frameCenterInParent];
            [self.view addSubview:self.modalView];
        }
        
    } failure:^(NSMutableDictionary *json) {
        [[[UIAlertView alloc]initWithTitle:@"Error de comunicación" message:@"POS no responde" delegate:nil cancelButtonTitle:@"Ok" otherButtonTitles: nil] show];
    }];
}


- (IBAction)openBoardAction:(id)sender {
    self.hud= [MBProgressHUD showHUDAddedTo:self.view animated:YES];
    self.hud.mode = MBProgressHUDModeIndeterminate;
    self.hud.labelText = @"Solicitando mesa...";
    [[CoreService getInstance] postOpenTableWithKey:[[[Model getInstance] loggedUser] mwKey] tableSid:[[self.floorsArray[self.floorNumber] tables][self.tableNumber]sid] method:@"open" pax:self.paxTextField.text reservation:[self.reservationSwitch isOn]?@"true":@"false" firstTimeVisit:[self.firstTimeSwitch isOn]?@"true":@"false" succes:^(NSMutableDictionary *json) {
        [[self hud] hide:YES];
        if ([[json objectForKey:@"success"] intValue]==1) {
            [self SelectBoard:nil];
        }else{
            [[[UIAlertView alloc]initWithTitle:@"Error al abrir mesa" message:@"algun dato es incorrecto o la mesa ya esta abierta" delegate:nil cancelButtonTitle:@"Ok" otherButtonTitles: nil] show];
        }
    } failure:^(NSMutableDictionary *json) {
        [[self hud] hide:YES];
        [[[UIAlertView alloc]initWithTitle:@"Error de comunicación" message:@"POS no responde" delegate:nil cancelButtonTitle:@"Ok" otherButtonTitles: nil] show];
    }];
}
-(IBAction)printBoardTicketAction:(id)sender {
    
    NSString *tableName=[NSString stringWithFormat:@"%@ mesa %@",[self.floorsArray[self.floorNumber] name],[NSString stringWithFormat:@"%i",[[self.floorsArray[self.floorNumber] tables][self.tableNumber] tableNumber]]];
    
    [[CoreService getInstance] postPrintTicketTableWithKey:[[[Model getInstance] loggedUser] mwKey] tableSid:[[self.floorsArray[self.floorNumber] tables][self.tableNumber]sid] tableName:tableName discountSet:selectedDiscount succes:^(NSMutableDictionary *json) {
        //[self.payView removeFromSuperview];
        if ([[json objectForKey:@"success"] intValue]==1) {
            [[[UIAlertView alloc]initWithTitle:@"Imprimiendo" message:[NSString stringWithFormat:@"Se está sacando un resumen en la impresora, por un valor de %.2f",[[json objectForKey:@"total"] floatValue]] delegate:nil cancelButtonTitle:@"Ok" otherButtonTitles: nil] show];
                self.totalLabel.text=[NSString stringWithFormat:@"Total a pagar : %.2f",[[json objectForKey:@"total"] floatValue]];
        }else{
            [[[UIAlertView alloc]initWithTitle:@"Error al imprimir" message:@"No se ha conseguido enviar el ticket" delegate:nil cancelButtonTitle:@"Ok" otherButtonTitles: nil] show];
        }
    } failure:^(NSMutableDictionary *json) {
        //[self.payView removeFromSuperview];
        [[[UIAlertView alloc]initWithTitle:@"Error en la comunicacion" message:@"No se ha conseguido comunicar con el POS para enviar la petición" delegate:nil cancelButtonTitle:@"Ok" otherButtonTitles: nil] show];
    }];
}

- (IBAction)BackModalAction:(id)sender {
    [self.modalView removeFromSuperview];
}

- (IBAction)BackPayViewAction:(id)sender {
    [self.payView removeFromSuperview];
}

- (IBAction)secondAction:(id)sender
{
    Table *selectedTable=(Table *)[self.floorsArray[self.floorNumber] tables][self.tableNumber];
    [selectedTable setFloorId:[self.floorsArray[self.floorNumber]floorId]];
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


#pragma mark -UITextFieldDelegate methods

- (BOOL)textFieldShouldReturn:(UITextField *)textField{
    [self.paxTextField resignFirstResponder];
    [self.payNoteTextField resignFirstResponder];
    return YES;
}

-(IBAction)dismissKeyboard:(id)sender{
    [self.paxTextField resignFirstResponder];
    [self.payNoteTextField resignFirstResponder];
    [self.payTextField resignFirstResponder];
}

- (IBAction)SelectTicketAction:(id)sender {
    [[CoreService getInstance]getIsOpenedWithSid:[[self.floorsArray[self.floorNumber] tables][self.tableNumber]sid] Succes:^(NSMutableDictionary *json) {
        if ([[json objectForKey:@"opened"] boolValue]) {
            [self.payView setFrame:[[UIScreen mainScreen] bounds]];
            [self.view addSubview:self.payView];
        }else{
            [[[UIAlertView alloc]initWithTitle:@"Mesa Cerrada" message:@"Selecciona una mesa que esté abierta" delegate:nil cancelButtonTitle:@"Ok" otherButtonTitles: nil] show];
        }
        
    } failure:^(NSMutableDictionary *json) {
        [[[UIAlertView alloc]initWithTitle:@"Error de comunicación" message:@"POS no responde" delegate:nil cancelButtonTitle:@"Ok" otherButtonTitles: nil] show];
    }];
    
}

- (void)SelectTicketActionWithTable:(Table *)table {
    [[CoreService getInstance]getIsOpenedWithSid:table.sid Succes:^(NSMutableDictionary *json) {
        if ([[json objectForKey:@"opened"] boolValue]) {
            self.tableLabel.text=[table nameOfTable];
            [self.payView setFrame:[[UIScreen mainScreen] bounds]];
            [self.view addSubview:self.payView];
        }else{
            [[[UIAlertView alloc]initWithTitle:@"Mesa Cerrada" message:@"Selecciona una mesa que esté abierta" delegate:nil cancelButtonTitle:@"Ok" otherButtonTitles: nil] show];
        }
        
    } failure:^(NSMutableDictionary *json) {
        [[[UIAlertView alloc]initWithTitle:@"Error de comunicación" message:@"POS no responde" delegate:nil cancelButtonTitle:@"Ok" otherButtonTitles: nil] show];
    }];
    
}

- (IBAction)amountAceptAction:(id)sender
{
    if (([self.payTextField.text length]>0)&&([self.payTextField.text floatValue]>0)&&([[self.payTextField.text componentsSeparatedByString:@","] count]<=2)) {
        selectedPayment.amount=[self.payTextField.text stringByReplacingOccurrencesOfString:@"," withString:@"."];
        selectedPayment.note=self.payNoteTextField.text;
        [selectedPaymentSet addObject:selectedPayment];
        [self.amountView removeFromSuperview];
        [self.payNoteTextField setText:@""];
        [self.payTable reloadData];
    }else{
        [[[UIAlertView alloc]initWithTitle:@"Cantidad Erronea" message:@"Debes introducir una cantidad de dinero" delegate:nil cancelButtonTitle:@"Ok" otherButtonTitles: nil] show];
    }
}

- (IBAction)amountCancelAction:(id)sender
{
    [self.amountView removeFromSuperview];
}


- (IBAction)payTicketAction:(id)sender {
    if ([[selectedPaymentSet allObjects] count]!=0) {
        NSString *tableName=[NSString stringWithFormat:@"%@ mesa %@",[self.floorsArray[self.floorNumber] name],[NSString stringWithFormat:@"%i",[[self.floorsArray[self.floorNumber] tables][self.tableNumber] tableNumber]]];
        
        [[CoreService getInstance] postPrintTicketAndCloseTableWithKey:[[[Model getInstance] loggedUser] mwKey] tableSid:[[self.floorsArray[self.floorNumber] tables][self.tableNumber]sid] tableName:tableName discountSet:selectedDiscount paymentSet:selectedPaymentSet succes:^(NSMutableDictionary *json) {
            //[self.payView removeFromSuperview];
            [self.navigationController popViewControllerAnimated:YES];
            if ([[json objectForKey:@"success"] intValue]==1) {
                [[[UIAlertView alloc]initWithTitle:@"Imprimiendo" message:@"Se ha impreso el ticket correctamente" delegate:nil cancelButtonTitle:@"Ok" otherButtonTitles: nil] show];
                [[Model getInstance] setSelectedFloor:nil];
                [[Model getInstance] setSelectedTable:nil];
            }else{
                [[[UIAlertView alloc]initWithTitle:@"Error al imprimir" message:@"No se ha conseguido enviar el ticket" delegate:nil cancelButtonTitle:@"Ok" otherButtonTitles: nil] show];
            }
        } failure:^(NSMutableDictionary *json) {
            //[self.payView removeFromSuperview];
            [[[UIAlertView alloc]initWithTitle:@"Error en la comunicacion" message:@"No se ha conseguido comunicar con el POS para enviar la petición" delegate:nil cancelButtonTitle:@"Ok" otherButtonTitles: nil] show];
        }];
    }else{
        [[[UIAlertView alloc]initWithTitle:@"Metodos de pago" message:@"Debes haber seleccionado al menos un modo de pago" delegate:nil cancelButtonTitle:@"Ok" otherButtonTitles: nil] show];
    }
    
}

#pragma mark -UITableViewDataSource methods

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section{
    if (tableView==self.payTable) {
        totalpayment=0;
        for (Payment *payment in selectedPaymentSet) {
            totalpayment+= [payment.amount floatValue];
        }
        
        return [payArray count];
    }else if (tableView==self.discountTable){
        return [discountArray count];
    }else{
        return 0;
    }
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath
{
    static NSString *CellIdentifier = @"Cell";
    UITableViewCell *cell;
    
    cell = [tableView dequeueReusableCellWithIdentifier:CellIdentifier];
    
    if (cell == nil) {
        cell = [[UITableViewCell alloc] initWithStyle:UITableViewCellStyleSubtitle reuseIdentifier:CellIdentifier];
    }
    [cell setSelectionStyle:UITableViewCellSelectionStyleNone];
    [[cell textLabel] setBackgroundColor:[UIColor clearColor]];
    [[cell detailTextLabel] setBackgroundColor:[UIColor clearColor]];
    if (tableView==self.payTable) {
        
        Payment *payment=[payArray objectAtIndex:indexPath.row];
        cell.textLabel.text=payment.name;
        
        if ([selectedPaymentSet containsObject:payment]) {
            cell.backgroundColor=[UIColor colorWithRed:0.549 green:0.776 blue:0.247 alpha:1.000];
            cell.contentView.backgroundColor=[UIColor colorWithRed:0.549 green:0.776 blue:0.247 alpha:1.000];
        }else{
            cell.backgroundColor=[UIColor whiteColor];
            cell.contentView.backgroundColor=[UIColor whiteColor];
            cell.textLabel.backgroundColor=[UIColor whiteColor];
        }
    }else{
        Discount *discount=[discountArray objectAtIndex:indexPath.row];
        cell.textLabel.text=discount.name;
        if ([selectedDiscount containsObject:discount]) {
            cell.backgroundColor=[UIColor colorWithRed:0.549 green:0.776 blue:0.247 alpha:1.000];
            cell.contentView.backgroundColor=[UIColor colorWithRed:0.549 green:0.776 blue:0.247 alpha:1.000];
        }else{
            cell.backgroundColor=[UIColor whiteColor];
            cell.contentView.backgroundColor=[UIColor whiteColor];
        }
    }
    return cell;
}

-(NSString *)tableView:(UITableView *)tableView titleForHeaderInSection:(NSInteger)section
{
    if (tableView==self.payTable) {
       return @"Pagos";
    }else {
       return @"Descuentos";
    }
}

-(void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath
{
    if (tableView==self.discountTable) {
        Discount *discount=[discountArray objectAtIndex:indexPath.row];
        if ([selectedDiscount containsObject:discount]) {
            [selectedDiscount removeObject:discount];
        }else{
            [selectedDiscount addObject:discount];
        }
        [self.discountTable reloadData];
    }else{
        selectedPayment=[payArray objectAtIndex:indexPath.row];
        if ([selectedPaymentSet containsObject:selectedPayment]) {
            [selectedPaymentSet removeObject:selectedPayment];
            [self.payTable reloadData];
        }else{
            [self openAmountView];
        }
        
    }

}

-(void) openAmountView{
    [self.view addSubview:self.amountView];
    if ([selectedPayment.key isEqualToString:@"cash"]) {
        self.payNoteTextField.hidden=YES;
    }else{
        self.payNoteTextField.hidden=NO;
    }
    [self.payTextField setText:@""];
}

#pragma mark -keyboards methods

- (void)keyboardWasShown:(NSNotification*)aNotification
{
    NSDictionary* info = [aNotification userInfo];
    CGSize kbSize = [[info objectForKey:UIKeyboardFrameBeginUserInfoKey] CGRectValue].size;
    [UIView animateWithDuration:0.25 animations:^{
        [self.littleAmountView frameMoveByYDelta:-kbSize.height/2];
    }];
}

// Called when the UIKeyboardWillHideNotification is sent
- (void)keyboardWillBeHidden:(NSNotification*)aNotification
{
    NSDictionary* info = [aNotification userInfo];
    CGSize kbSize = [[info objectForKey:UIKeyboardFrameBeginUserInfoKey] CGRectValue].size;
    [UIView animateWithDuration:0.25 animations:^{
        [self.littleAmountView frameMoveByYDelta:kbSize.height/2];
    }];
}
@end
