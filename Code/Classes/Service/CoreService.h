//
//  CoreService.h
//  bootstrap-ios
//
//  Created by Marcos Pinazo on 2/15/13.
//  Copyright (c) 2013 [WE ARE] DEVELAPPERS. All rights reserved.
//

#import <Foundation/Foundation.h>

#import "Reachability.h"
#import "BootstrapDB.h"
#import "BootstrapAPI.h"
#import "PosApi.h"

#define kServiceInitializationSuccess @"kServiceInitializationSuccess"
#define kServiceInitializationError @"kServiceInitializationError"
#define kServiceReadyToShowHome @"kServiceReadyToShowHome"
#define kServiceLogout @"kServiceLogout"
#define kServiceShowHome @"kServiceShowHome"

@interface CoreService : NSObject

@property (strong, nonatomic) Reachability *reachability;
@property (strong, nonatomic) BootstrapDB *db;
@property (strong, nonatomic) BootstrapAPI *api;
@property (strong, nonatomic) PosApi *posApi;

+ (id)getInstance;

- (void)initApplication;

- (void)settingsWithSuccess:(APIResponseHandler)success failure:(APIResponseHandler)failure;

// TODO: Definir si esta aplicación tiene usuarios, si no borrar.
#pragma mark - Login and logout methods

-(void)LoginWithSuccess:(APIResponseHandler)success failure:(APIResponseHandler)failure;
-(void)LoginWithKey:(NSString*)mwkey success:(APIResponseHandler)success failure:(APIResponseHandler)failure;
- (void)logout;
- (void)setToken:(NSString *)token;
- (void)setLastUpdate;
- (void)setLastUpdateSuggestion;

#pragma mark - Restaurant Info methods

-(void)getRestaurantInfoWithSucces:(APIResponseHandler)success failure:(APIResponseHandler)failure;
-(void)getRestaurantInfoWithKey:(NSString*)mwkey succes:(APIResponseHandler)success failure:(APIResponseHandler)failure;

#pragma mark - Get Restaurant Modifiers methods

-(void)getRestaurantModifiersWithSucces:(APIResponseHandler)success failure:(APIResponseHandler)failure;
-(void)getRestaurantModifiersWithKey:(NSString*)mwkey succes:(APIResponseHandler)success failure:(APIResponseHandler)failure;

#pragma mark - Get Tables methods

-(void)getTablesWithSucces:(APIResponseHandler)success failure:(APIResponseHandler)failure;
-(void)getTablesWithKey:(NSString*)mwkey succes:(APIResponseHandler)success failure:(APIResponseHandler)failure;


#pragma mark - Get Suggestions methods

-(void)getSuggestionsWithSucces:(APIResponseHandler)success failure:(APIResponseHandler)failure;
-(void)getSuggestionsWithKey:(NSString*)mwkey succes:(APIResponseHandler)success failure:(APIResponseHandler)failure;


#pragma mark - Get User Info methods

-(void)getUserInfoWithSucces:(APIResponseHandler)success failure:(APIResponseHandler)failure;
-(void)getUserInfoWithKey:(NSString*)mwkey succes:(APIResponseHandler)success failure:(APIResponseHandler)failure;

#pragma mark - Get MW App Info methods

-(void)getMWAppInfoWithSucces:(APIResponseHandler)success failure:(APIResponseHandler)failure;
-(void)getMWAppInfoWithKey:(NSString*)mwkey succes:(APIResponseHandler)success failure:(APIResponseHandler)failure;

#pragma mark - Get Payment Options methods

-(void)getPaymentOptionsWithSucces:(APIResponseHandler)success failure:(APIResponseHandler)failure;
-(void)getPaymentOptionsWithKey:(NSString*)mwkey succes:(APIResponseHandler)success failure:(APIResponseHandler)failure;

#pragma mark - Get Discount methods

-(void)getDiscountWithSucces:(APIResponseHandler)success failure:(APIResponseHandler)failure;
-(void)getDiscountWithKey:(NSString*)mwkey succes:(APIResponseHandler)success failure:(APIResponseHandler)failure;

#pragma mark - Get payments methods

-(void)getPaymentsWithSucces:(APIResponseHandler)success failure:(APIResponseHandler)failure;
-(void)getPaymentsWithKey:(NSString*)mwkey succes:(APIResponseHandler)success failure:(APIResponseHandler)failure;

#pragma mark - POS methods

-(void)postOpenTableWithKey:(NSString*)mwkey tableSid:(NSString*)sid method:(NSString*)method pax:(NSString*)pax reservation:(NSString*)reservation firstTimeVisit:(NSString*)firstTimeVisit succes:(APIResponseHandler)success failure:(APIResponseHandler)failure;
-(void)postPrintTicketTableWithKey:(NSString*)mwkey tableSid:(NSString*)sid tableName:(NSString*)tableName discountSet:(NSMutableSet *)discountSet succes:(APIResponseHandler)success failure:(APIResponseHandler)failure;
-(void)postPrintTicketAndCloseTableWithKey:(NSString*)mwkey tableSid:(NSString*)sid tableName:(NSString*)tableName discountSet:(NSMutableSet *)discountSet paymentSet:(NSMutableSet *)paymentSet succes:(APIResponseHandler)success failure:(APIResponseHandler)failure;

-(void)postDishWithsucces:(APIResponseHandler)success failure:(APIResponseHandler)failure;
-(void)postDishWithMultiply:(NSString*)multiply dish:(Dish*)dish note:(NSString*)note categorySid:(NSString *)categorySid modifiers:(NSDictionary*) modifierList discount:(Discount*)discount succes:(APIResponseHandler)success failure:(APIResponseHandler)failure;
-(void)postDishWithOrderArray:(NSMutableArray *)orderArray succes:(APIResponseHandler)success failure:(APIResponseHandler)failure;
-(void)postDishWithOrderArray:(NSMutableArray *)orderArray table:(Table*)currentTable succes:(APIResponseHandler)success failure:(APIResponseHandler)failure;
-(void)postSecondDishesWithKey:(NSString*)mwkey table:(Table *)table succes:(APIResponseHandler)success failure:(APIResponseHandler)failure;
-(void)getIsOpenedWithSid:(NSString *)sid Succes:(APIResponseHandler)success failure:(APIResponseHandler)failure;
@end
