//
//  CheckViewController.m
//  meWaiter-ios
//
//  Created by omar megdadi on 15/10/13.
//  Copyright (c) 2013 [WE ARE] DEVELAPPERS. All rights reserved.
//

#import "CheckViewController.h"
#import "MMDrawerBarButtonItem.h"
#import "UIViewController+MMDrawerController.h"
#import "MBProgressHUD.h"
#import "CoreService.h"
#import "Model.h"
#import "Restaurant.h"
#import "Menu.h"
#import "Constants.h"

@interface CheckViewController ()
@property (nonatomic,strong) MBProgressHUD *hud;
@end

@implementation CheckViewController

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
    self.lastUpdateLabel.text=[NSString stringWithFormat:@"Última actualización:\n %@",[[[CoreService getInstance]db] getConfigWithName:SETTINGS_LAST_UPDATE]];
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

#pragma mark - Button Handlers
-(void)leftDrawerButtonPress:(id)sender{
    [self.mm_drawerController toggleDrawerSide:MMDrawerSideLeft animated:YES completion:nil];
}

- (IBAction)refreshAction:(id)sender
{
    CoreService *coreService=[CoreService getInstance];
    BootstrapDB *dataBase=[coreService db];
    self.hud= [MBProgressHUD showHUDAddedTo:self.view animated:YES];
    self.hud.mode = MBProgressHUDModeIndeterminate;
    self.hud.labelText = @"actualizando...";
    [coreService LoginWithKey:self.user.mwKey success:^(NSMutableDictionary *json) {
        if (![[json objectForKey:@"result"] objectForKey:@"error"]) {
            
            self.user.apiKey=[[json objectForKey:@"result"] objectForKey:@"api_key"];
            self.user.locationId=[[json objectForKey:@"result"] objectForKey:@"location_id"];
            self.user.deviceId=[[json objectForKey:@"result"] objectForKey:@"device_id"];
            self.user.userId=[[json objectForKey:@"result"] objectForKey:@"user_id"];
            self.user.employee_id=[[json objectForKey:@"result"] objectForKey:@"employee_id"];
            [[Model getInstance] setLoggedUser:self.user];
            [dataBase deleteAllUsers];
            [dataBase insertWithUser:self.user];
            [coreService setToken:self.user.apiKey];
            self.hud.labelText = @"Información del restaurante";
            [coreService  getRestaurantInfoWithKey:self.user.mwKey succes:^(NSMutableDictionary *json) {
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
                [coreService getTablesWithKey:self.user.mwKey succes:^(NSMutableDictionary *json) {
                    NSMutableArray *floorsArray=[[NSMutableArray alloc]init];
                    for (NSDictionary *floorDictionary in [json objectForKey:@"floors"]) {
                        Floor *floor=[[Floor alloc]initWithDictionary:floorDictionary];
                        [dataBase insertfloor:floor];
                        for (Table *table in [floor tables]) {
                            [dataBase insertTable:table floorId:floor.floorId];
                        }
                        [floorsArray addObject:floor];
                    }
                    self.hud.labelText = @"Cargando recomendaciones";
                    [coreService getSuggestionsWithKey:self.user.mwKey succes:^(NSMutableDictionary *json) {
                        NSString *suggestionString=[json objectForKey:@"suggestions"];
                        [[NSUserDefaults standardUserDefaults] setObject:suggestionString forKey:KsugestionString];
                        self.hud.labelText = @"Cargando información de la app";
                        [coreService getMWAppInfoWithKey:self.user.mwKey succes:^(NSMutableDictionary *json) {
                            InfoApp *info=[[InfoApp alloc]initWithDictionary:[json objectForKey:@"waiter_app"]];
                            [dataBase insertInfo:info];
                            self.hud.labelText = @"Cargando de los modificadores";
                            [coreService getRestaurantModifiersWithKey:self.user.mwKey succes:^(NSMutableDictionary *json) {
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
                                [coreService getDiscountWithKey:self.user.mwKey succes:^(NSMutableDictionary *json) {
                                    [dataBase deleteDiscounts];
                                    for (NSDictionary *discountDictionary in [json objectForKey:@"discounts"]) {
                                        Discount *discount=[[Discount alloc]initWithDictionary:discountDictionary];
                                        [dataBase insertDiscount:discount];
                                    }
                                    [coreService getPaymentOptionsWithKey:self.user.mwKey succes:^(NSMutableDictionary *json) {
                                        [dataBase deletePayments];
                                        for (NSDictionary *paymentDictionary in [json objectForKey:@"payments"]) {
                                            Payment *payment=[[Payment alloc]initWithDictionary:paymentDictionary];
                                            [dataBase insertPayment:payment];
                                        }
                                        [coreService setLastUpdate];
                                        [self hudMessageWithTitle:@"Actualizado" andDelay:1];
                                            self.lastUpdateLabel.text=[NSString stringWithFormat:@"Última actualización:\n %@",[[[CoreService getInstance]db] getConfigWithName:SETTINGS_LAST_SUGGESTION_UPDATE]];
                                    } failure:^(NSMutableDictionary *json) {
                                        [self hudMessageWithTitle:@"Error al cargar Metodos de pagos" andDelay:1];
                                    }];
                                } failure:^(NSMutableDictionary *json) {
                                    [self hudMessageWithTitle:@"Error al cargar Descuentos" andDelay:1];
                                }];
                                
                            } failure:^(NSMutableDictionary *json) {
                                [self hudMessageWithTitle:@"Error al cargar modificadores" andDelay:1];
                            }];
                        } failure:^(NSMutableDictionary *json) {
                            [self hudMessageWithTitle:@"Error en datos de información" andDelay:1];
                        }];
                    } failure:^(NSMutableDictionary *json) {
                        [self hudMessageWithTitle:@"Error en las Recomendaciones" andDelay:1];
                    }];
                } failure:^(NSMutableDictionary *json) {
                    [self hudMessageWithTitle:@"Error en las mesas" andDelay:1];
                }];
            } failure:^(NSMutableDictionary *json) {
                [self hudMessageWithTitle:@"Error en info" andDelay:1];
            }];
        }else{
            [self hudMessageWithTitle:@"Error en password" andDelay:1];
        }
    } failure:^(NSMutableDictionary *json) {
        [self hudMessageWithTitle:@"Error" andDelay:1];
    }];
}

-(void) hudMessageWithTitle:(NSString *) title andDelay:(NSTimeInterval) delay{
    self.hud.labelText = title;
    self.hud.mode=MBProgressHUDModeCustomView;
    self.hud.customView=nil;
    [self.hud hide:YES afterDelay:delay];
}


@end
