//
//  LocalDB.h
//  bootstrap-ios
//
//  Created by Marcos Pinazo on 2/1/13.
//  Copyright (c) 2013 [WE ARE] DEVELAPPERS. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "sqlite3.h"
#import "Section.h"
#import "Dish.h"
#import "Table.h"
#import "User.h"
#import "ModifierListSets.h"
#import "ModifierList.h"
#import "Modifier.h"
#import "Order.h"
#import "Floor.h"
#import "InfoApp.h"
#import "Discount.h"
#import "Payment.h"
@class Restaurant;
@class Menu;

#define kLocalDBInitializationError @"kLocalDBInitializationError"

@interface LocalDB : NSObject {
    BOOL isOpen;
    sqlite3 *db;
}

- (BOOL)configMultithreading;
- (NSString *)getDBFullPath;
- (BOOL)open;
- (void)close;
- (BOOL)createTables;
- (void)executeBatch:(NSString *)query;

#pragma mark - config methods

- (void)insertConfigWithName:(NSString *)configName andValue:(NSString *)configValue;
- (NSString *)getConfigWithName:(NSString *)configName;
- (void)deleteConfigWithName:(NSString *)configName;

#pragma mark - restaurant methods

- (void)insertRestaurantWithInfo:(Restaurant *)info;
- (NSString *)getRestaurantWithName:(NSString *)infoName;
- (Restaurant *)getRestaurant;
- (void)deleteRestaurantWithName:(NSString *)InfoName;

#pragma mark - Menu methods

- (void)insertMenu:(Menu *)menu ;
- (Menu*)getMenuWithId:(int )menuId;
- (void)deleteMenuWithId:(int )menuId;
- (void)deleteMenus;

#pragma mark - Sections methods

- (void)insertWithSection:(Section *)section menuId:(int)menuId;
- (Section*)getSectionWithId:(int )sectionId;
- (void)deleteSectionWithId:(int )menuId;
- (void)deleteSections;

#pragma mark - Sections methods
- (void)insertSubsection:(Section *)subsection menuId:(int)menuId sectionId:(int)sectionId;
- (void)deleteSubsections;

#pragma mark - Dishes methods

- (void)insertWithDish:(Dish *)dish menuId:(int)menuId sectionId:(int)sectionId;
- (Dish*)getDishWithId:(int )dishId;
- (int)getSectionIdOfDishWithId:(int )dishId;
- (int)getMenuIdOfDishWithId:(int )dishId;
- (Dish*)getDishWithName:(NSString *)dishName;
- (void)deleteDishWithId:(int )dishId;
- (void)deleteDishes;

#pragma mark - Tables methods

- (void)insertTable:(Table *)table floorId:(int)floorId;
- (Table*)getTableWithId:(int )tableId;
- (void)deleteTableWithId:(int )dishId;

#pragma mark - Floors methods

- (void)insertfloor:(Floor*)floor;
- (Floor*)getFloorWithId:(int )floorId;
- (NSMutableArray*)getFloorsArray;
- (void)deleteFloorWithId:(int )floorId;

#pragma mark - User methods

- (void)insertWithUser:(User *)user;
- (User*)getUserWithId:(int )userId;
- (User*)getUserWithApiKey:(NSString *)apiKey ;
- (User*)getUser;
- (void)deleteUserWithId:(int )userId;
-(void) deleteAllUsers;

#pragma mark - Modifier_List_sets methods

- (void)insertModifierListSet:(ModifierListSets *)modifierListSet;
- (ModifierListSets *)getModifierListSetWithid:(int )modifierListSetId;
- (ModifierListSets *)getModifierListSetWithSid:(NSString *)sid;
- (void)deleteModifierListSetWithid:(int)modifierListSetId;
- (void)deleteAllModifierListSet;

#pragma mark - Modifier_List methods

- (void)insertModifierList:(ModifierList*)modifierList withModifierListSetId:(int)modifierListSetId;
- (ModifierList *)getModifierListWithid:(int )modifierListId;
- (ModifierList *)getModifierListWithSid:(NSString *)modifierListSid;
- (NSMutableArray *)getModifierListWithModifierListSetid:(int )modifierListSetId;
- (void)deleteModifierListWithid:(int)modifierListId;

#pragma mark - dish_mod methods

- (void)insertDishMod:(Dish*)DishMod withModifierListSetId:(int)modifierListSetId;
- (Dish *)getDishesModWithid:(int )DishesId;
- (int)getIdMlsWithid:(int )DishesId;
- (NSMutableArray *)getDishesModWithModifierListSetid:(int )modifierListSetId;
- (void)deleteDishModWithid:(int)DishId;

#pragma mark - Modifier methods

- (void)insertModifier:(Modifier*)modifier withModifierListId:(int)modifierListId;
- (Modifier*)getModifierWithid:(int)modifierId;
- (Modifier *)getModifierWithSid:(NSString *)modifierSid;
- (NSMutableArray *)getModifierWithModifierListid:(int )modifierListId;
- (void)deleteModifierWithid:(int)modifierId;

#pragma mark - Order methods

- (void)insertOrder:(Order *)order;
- (Order *)getOrderWithid:(int)orderId;
-(Order*) getLastOrder;
- (NSMutableArray*)getAllOrders;
- (NSMutableSet*)getTableIdOrdersSet;
- (NSMutableArray*)getOrdersWithTableid:(int)tableId;
- (void)deleteOrderWithId:(int)orderId;

#pragma mark - info methods

- (void)insertInfo:(InfoApp *)infoApp;
- (InfoApp *)getInfo;
- (void)deleteInfo;

#pragma mark - OrderMods methods

- (void) insertOrderModsWithIndexPath:(NSIndexPath*)indexpath modifiersListSet:(ModifierListSets*)modifierListSet orderId:(int)orderId;
- (NSMutableArray*)getOrdersModsWithOrderId:(int)orderId;
-(void) deleteOrderModWithOrderId:(int) orderId;

#pragma mark - discount methods

-(void) insertDiscount:(Discount*)discount;
-(Discount*) getDiscountWithSid:(NSString*) sid;
-(NSMutableArray *) getDiscountWithDishId:(int) dishId;
-(NSMutableArray *) getDiscountWithMenuId:(int) menuId;
-(NSMutableArray *) getDiscountWithSectionId:(int) sectionId;
-(NSMutableArray *) getDiscountWithMenuId:(int) menuId sectionId:(int) sectionId dishId:(int) dishId;
-(NSMutableArray *) getDiscountOnlyForRestaurant;
-(void) deleteDiscounts;

#pragma mark -OrderDiscount

-(void)insertOrderDiscountWithDiscount:(Discount *)discount OrderId:(int) orderId;
-(Discount*)getOrderDiscountWithOrderId:(int) orderId;
-(void) deleteOrderDiscountsWithOrderId:(int)orderId;

#pragma mark - Tables methods

- (void)insertPayment:(Payment *)payment;
- (NSMutableArray*)getPaymentsArray;
- (void)deletePayments;

@end
