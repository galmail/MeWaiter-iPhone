//
//  LoginViewController.m
//  bootstrap-ios
//
//  Created by Marcos Pinazo on 2/15/13.
//  Copyright (c) 2013 [WE ARE] DEVELAPPERS. All rights reserved.
//

#import "LoginViewController.h"
#import "Constants.h"
#import "CoreService.h"
#import "ModalManager.h"
#import "HomeViewController.h"
#import "MMDrawerController.h"
#import "MMExampleDrawerVisualStateManager.h"
#import "LeftMenuViewController.h"
#import "MBProgressHUD.h"
#import "Restaurant.h"
#import "Floor.h"
#import "InfoApp.h"
#import "BootstrapDB.h"
#import "Menu.h"
#import "User.h"
#import "Model.h"
#import "ModifierListSets.h"
#import "Modifier.h"
#import "Discount.h"
#import "Payment.h"


@interface LoginViewController ()
@property (nonatomic,strong) MMDrawerController * drawerController;
@property (nonatomic,strong) MBProgressHUD * hud;
@end

@implementation LoginViewController

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
}

- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
}

- (void)viewDidAppear:(BOOL)animated
{
    [super viewDidAppear:animated];
}

- (void)viewWillDisappear:(BOOL)animated
{
    [super viewWillDisappear:animated];
}

#pragma mark - sliding constructor

- (void)prepareDrawerControllerWithRestaurant:(Restaurant *)restaurant floors:(NSMutableArray*) floors suggestion:(NSString*)suggestionString info:(InfoApp *)info
{
    CoreService *coreService=[CoreService getInstance];
    BootstrapDB *dataBase=[coreService db];
    LeftMenuViewController * leftSideDrawerViewController = [[LeftMenuViewController alloc] initWithNibName:@"LeftMenuViewController" bundle:nil];
    leftSideDrawerViewController.restaurant=[dataBase getRestaurant];
    leftSideDrawerViewController.floorsArray=[dataBase getFloorsArray];
    leftSideDrawerViewController.suggestionString=[[NSUserDefaults standardUserDefaults]objectForKey:KsugestionString];
    leftSideDrawerViewController.info=[dataBase getInfo];
    
    HomeViewController * centerViewController = [[HomeViewController alloc] initWithNibName:@"HomeViewController" bundle:nil];
    centerViewController.restaurant=[dataBase getRestaurant];
    centerViewController.floorsArray=[dataBase getFloorsArray];
    
    UINavigationController * navigationController = [[UINavigationController alloc] initWithRootViewController:centerViewController];
    [navigationController setRestorationIdentifier:@"MMExampleCenterNavigationControllerRestorationKey"];
    [[navigationController.navigationBar topItem ]setTitle:@"Pedido"];
    if(OSVersionIsAtLeastiOS7()){
        UINavigationController * leftSideNavController = [[UINavigationController alloc] initWithRootViewController:leftSideDrawerViewController];
        [leftSideNavController.navigationBar setTranslucent:YES];
        [leftSideNavController.navigationBar setBarTintColor:[UIColor darkGrayColor]];
        [[leftSideNavController.navigationBar topItem ]setTitle:@"Opciones"];
		[leftSideNavController setRestorationIdentifier:@"MMExampleLeftNavigationControllerRestorationKey"];
        self.drawerController = [[MMDrawerController alloc]
                                 initWithCenterViewController:navigationController
                                 leftDrawerViewController:leftSideNavController
                                 rightDrawerViewController:nil];
        [self.drawerController setShowsShadow:NO];
    }
    else{
        self.drawerController = [[MMDrawerController alloc]
                                 initWithCenterViewController:navigationController
                                 leftDrawerViewController:leftSideDrawerViewController
                                 rightDrawerViewController:nil];
    }
    [self.drawerController setRestorationIdentifier:@"MMDrawer"];
    [self.drawerController setMaximumLeftDrawerWidth:200.0];
    [self.drawerController setOpenDrawerGestureModeMask:MMOpenDrawerGestureModeAll];
    [self.drawerController setCloseDrawerGestureModeMask:MMCloseDrawerGestureModeAll];
    
    [self.drawerController
     setDrawerVisualStateBlock:^(MMDrawerController *drawerController, MMDrawerSide drawerSide, CGFloat percentVisible) {
         MMDrawerControllerDrawerVisualStateBlock block;
         block = [[MMExampleDrawerVisualStateManager sharedManager]
                  drawerVisualStateBlockForDrawerSide:drawerSide];
         if(block){
             block(drawerController, drawerSide, percentVisible);
         }
     }];
}

#pragma mark - actions methods

-(IBAction)startButtonAction:(id)sender
{
    UIAlertView *message = [[UIAlertView alloc] initWithTitle:@"Introduce la clave de acceso"
                                                      message:nil
                                                     delegate:self
                                            cancelButtonTitle:@"Volver"
                                            otherButtonTitles:@"Entrar", nil];
    [message setAlertViewStyle:UIAlertViewStyleSecureTextInput];
    [message show];
}

#pragma mark - UIAlertViewDelegate

- (void)alertView:(UIAlertView *)alertView clickedButtonAtIndex:(NSInteger)buttonIndex
{
    if (buttonIndex==1){
        NSString *inputText = [[alertView textFieldAtIndex:0] text];
        if( [inputText length] == 0 )
        {
            [[[UIAlertView alloc] initWithTitle:@"Error" message:@"no se ha escrito la clave de camarero" delegate:self cancelButtonTitle:@"Volver" otherButtonTitles: nil] show];
        }
        else
        {
            self.hud= [MBProgressHUD showHUDAddedTo:self.view animated:YES];
            self.hud.mode = MBProgressHUDModeIndeterminate;
            self.hud.labelText = @"comprobando...";
            [self LoginAndSaveDatasWithAccessString:inputText];
        }
        
    }else{
        
    }
    
}

- (void)LoginAndSaveDatasWithAccessString:(NSString *)inputText
{
    CoreService *coreService=[CoreService getInstance];
    BootstrapDB *dataBase=[coreService db];
    [coreService LoginWithKey:inputText success:^(NSMutableDictionary *json) {
        if (![[json objectForKey:@"result"] objectForKey:@"error"]) {
            User *user = [[User alloc] init];
            user.mwKey = inputText;
            user.apiKey=[[json objectForKey:@"result"] objectForKey:@"api_key"];
            user.locationId=[[json objectForKey:@"result"] objectForKey:@"location_id"];
            user.deviceId=[[json objectForKey:@"result"] objectForKey:@"device_id"];
            user.userId=[[json objectForKey:@"result"] objectForKey:@"user_id"];
            user.employee_id=[[json objectForKey:@"result"] objectForKey:@"employee_id"];
            [[Model getInstance] setLoggedUser:user];
            [dataBase deleteAllUsers];
            [dataBase insertWithUser:user];
            [coreService setToken:user.apiKey];
            self.hud.labelText = @"Información del restaurante";
            [coreService  getRestaurantInfoWithKey:user.mwKey succes:^(NSMutableDictionary *json) {
                Restaurant *restaurant=[[Restaurant alloc] initWithDictionary:json];
                [[coreService posApi] setPosIdAddres:restaurant.posIpAddress];
                [dataBase insertRestaurantWithInfo:restaurant];
                [dataBase deleteMenus];
                [dataBase deleteSections];
                [dataBase deleteDishes];
                [dataBase deleteSubsections];
                for (Menu *menu in [restaurant menus]) {
                    [dataBase insertMenu:menu];
                    for (Section *section in [menu sections]) {
                        [dataBase insertWithSection:section menuId:menu.menuId];
                        for (Dish *dish in [section dishes]) {
                            [dataBase insertWithDish:dish menuId:menu.menuId sectionId:section.sectionId];
                        }
                        for (Section *subsection in [section subsections]) {
                            [dataBase insertSubsection:subsection menuId:menu.menuId sectionId:section.sectionId];
                            for (Dish *dish in [subsection dishes]) {
                                [dataBase insertWithDish:dish menuId:menu.menuId sectionId:subsection.sectionId];
                            }
                        }
                    }
                }
                NSLog(@"%@", [(Restaurant*)[dataBase getRestaurantWithName:restaurant.name]logo]);
                self.hud.labelText = @"Información de las mesas";
                [coreService getTablesWithKey:user.mwKey succes:^(NSMutableDictionary *json) {
                    NSMutableArray *floorsArray=[[NSMutableArray alloc]init];
                    [dataBase deleteFloors];
                    [dataBase deleteTables];
                    for (NSDictionary *floorDictionary in [json objectForKey:@"floors"]) {
                        Floor *floor=[[Floor alloc]initWithDictionary:floorDictionary];
                        [dataBase insertfloor:floor];
                        for (Table *table in [floor tables]) {
                            [dataBase insertTable:table floorId:floor.floorId];
                        }
                        [floorsArray addObject:floor];
                    }
                    self.hud.labelText = @"Cargando recomendaciones";
                    [coreService getSuggestionsWithKey:user.mwKey succes:^(NSMutableDictionary *json) {
                        NSString *suggestionString=[json objectForKey:@"suggestions"];
                        [[NSUserDefaults standardUserDefaults] setObject:suggestionString forKey:KsugestionString];
                        self.hud.labelText = @"Cargando información de la app";
                        [coreService getMWAppInfoWithKey:user.mwKey succes:^(NSMutableDictionary *json) {
                            InfoApp *info=[[InfoApp alloc]initWithDictionary:[json objectForKey:@"waiter_app"]];
                            [dataBase insertInfo:info];
                            self.hud.labelText = @"Cargando de los modificadores";
                            [coreService getRestaurantModifiersWithKey:user.mwKey succes:^(NSMutableDictionary *json) {
                                NSLog(@"%@",json);
                                NSMutableArray *ModifierListArray=[[NSMutableArray alloc]init];
                                for (NSDictionary *modifierListSet in [json objectForKey:@"modifier_list_sets"]) {
                                    ModifierListSets *modifierListSets=[[ModifierListSets alloc] initWithDictionary:modifierListSet];
                                    [ModifierListArray addObject:modifierListSets];
                                }
                                for (ModifierListSets *modifierListSet in ModifierListArray) {
                                    [dataBase insertModifierListSet:modifierListSet];
                                    for (ModifierList *modifierList in [modifierListSet modifierLists]) {
                                        [dataBase insertModifierList:modifierList withModifierListSetId:[modifierListSet modiferListSetsId]];
                                        for (Modifier *modifier in [modifierList modifiers]) {
                                            [dataBase insertModifier:modifier withModifierListId:[modifierList modiferListId]];
                                        }
                                    }
                                    for (Dish *dishMod in [modifierListSet dishes]) {
                                        [dataBase insertDishMod:dishMod withModifierListSetId:[modifierListSet modiferListSetsId]];
                                    }
                                }
                                self.hud.labelText = @"Cargando descuentos";
                                [coreService getDiscountWithKey:user.mwKey succes:^(NSMutableDictionary *json) {
                                    [dataBase deleteDiscounts];
                                    for (NSDictionary *discountDictionary in [json objectForKey:@"discounts"]) {
                                        Discount *discount=[[Discount alloc]initWithDictionary:discountDictionary];
                                        [dataBase insertDiscount:discount];
                                    }
                                    [coreService getPaymentOptionsWithKey:user.mwKey succes:^(NSMutableDictionary *json) {
                                        [dataBase deletePayments];
                                        for (NSDictionary *paymentDictionary in [json objectForKey:@"payments"]) {
                                            Payment *payment=[[Payment alloc]initWithDictionary:paymentDictionary];
                                            [dataBase insertPayment:payment];
                                        }
                                        [coreService setLastUpdate];
                                        [self.hud hide:YES];
                                        [self prepareDrawerControllerWithRestaurant:restaurant floors:floorsArray suggestion:suggestionString info:info];
                                        [self.navigationController pushViewController:self.drawerController animated:YES];
                                    } failure:^(NSMutableDictionary *json) {
                                        [self errorHudWithTitle:@"Error al cargar Metodos de pagos" andDelay:1];
                                    }];
                                } failure:^(NSMutableDictionary *json) {
                                    [self errorHudWithTitle:@"Error al cargar Descuentos" andDelay:1];
                                }];
                                
                            } failure:^(NSMutableDictionary *json) {
                                [self errorHudWithTitle:@"Error al cargar modificadores" andDelay:1];
                            }];
                        } failure:^(NSMutableDictionary *json) {
                            [self errorHudWithTitle:@"Error en datos de información" andDelay:1];
                        }];
                    } failure:^(NSMutableDictionary *json) {
                        [self errorHudWithTitle:@"Error en las Recomendaciones" andDelay:1];
                    }];
                } failure:^(NSMutableDictionary *json) {
                    [self errorHudWithTitle:@"Error en las mesas" andDelay:1];
                }];
            } failure:^(NSMutableDictionary *json) {
                [self errorHudWithTitle:@"Error en info" andDelay:1];
            }];
        }else{
            [self errorHudWithTitle:@"Error en password" andDelay:1];
        }
    } failure:^(NSMutableDictionary *json) {
        [self errorHudWithTitle:@"Error" andDelay:1];
    }];
}

-(void) errorHudWithTitle:(NSString *) title andDelay:(NSTimeInterval) delay{
    self.hud.labelText = title;
    self.hud.mode=MBProgressHUDModeCustomView;
    self.hud.customView=nil;
    [self.hud hide:YES afterDelay:delay];
}

@end
