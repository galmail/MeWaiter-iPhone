//
//  CoreService.m
//  bootstrap-ios
//
//  Created by Marcos Pinazo on 2/15/13.
//  Copyright (c) 2013 [WE ARE] DEVELAPPERS. All rights reserved.
//

#import "CoreService.h"

#import "GAI.h"
#import "AFJSONRequestOperation.h"
#import "NSTimer+Blocks.h"
#import "Constants.h"
#import "Model.h"
#import "OrderMod.h"
#import "Discount.h"

@implementation CoreService

+ (id)getInstance
{
	static CoreService *instance = nil;
	@synchronized(self) {
		if (instance == nil) {
			instance = [[CoreService alloc] init];
		}
		return instance;
	}
}

- (id)init
{
	if (self = [super init]) {
        self.db = [[BootstrapDB alloc] init];
        
        self.api = [BootstrapAPI clientWithBaseURL:[NSURL URLWithString:API_BASE_URL]];
        [self.api registerHTTPOperationClass:[AFJSONRequestOperation class]];
        [self.api setDefaultHeader:@"Accept" value:@"application/json"];
        [self.api setParameterEncoding:AFFormURLParameterEncoding];
        
        self.posApi = [PosApi clientWithBaseURL:[NSURL URLWithString:API_BASE_URL]];
        [self.posApi registerHTTPOperationClass:[AFJSONRequestOperation class]];
        [self.posApi setDefaultHeader:@"Accept" value:@"application/json"];
        [self.posApi setParameterEncoding:AFJSONParameterEncoding];
        
	}
	return self;
}

- (void)initApplication
{
    if (
        [self initDB]
        &&
        [self initReachability]
        &&
        [self initGoogleAnalytics]
        &&
        [self initSettings]
    ) {
        [[NSNotificationCenter defaultCenter] removeObserver:self name:kLocalDBInitializationError object:self.db];
    }
}

- (void)onDBInitializationError:(NSNotification *)event
{
    [[NSNotificationCenter defaultCenter] postNotificationName:kServiceInitializationError object:self];
}

- (BOOL)initDB
{
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(onDBInitializationError:) name:kLocalDBInitializationError object:self.db];
    return [self.db createTables];
}

- (BOOL)initReachability
{
    self.reachability = [Reachability reachabilityWithHostname:@"www.google.com"];
    [[NSNotificationCenter defaultCenter] addObserver:self
                                             selector:@selector(onReachabilityChanged:)
                                                 name:kReachabilityChangedNotification
                                               object:nil];
    
    [self.reachability startNotifier];
    return YES;
}

- (BOOL)initGoogleAnalytics
{
    #ifdef DEBUG
    [GAI sharedInstance].debug = YES;
    #endif
    
    [GAI sharedInstance].dispatchInterval = 20;
    [[GAI sharedInstance] trackerWithTrackingId:GAID];
    [[[GAI sharedInstance] defaultTracker] sendView:@"Loaded"];
    
    return YES;
}

- (void)onReachabilityChanged:(NSNotification *)event
{
    #ifdef LOG_VERBOSE
    NSLog(@"reachabilityChanged: %@", [self.reachability currentReachabilityString]);
    #endif
}

- (BOOL)initSettings
{
    APIResponseHandler success = ^(NSMutableDictionary *json) {
        // TODO: Definir si esta aplicación tiene usuarios, si no borrar.
        [self initUser:kServiceInitializationSuccess];
    };
    APIResponseHandler failure = ^(NSMutableDictionary *json) {
        [[NSNotificationCenter defaultCenter] postNotificationName:kServiceInitializationError object:self];
    };
    [self settingsWithSuccess:success failure:failure];
    return YES;
}

- (void)settingsWithSuccess:(APIResponseHandler)success failure:(APIResponseHandler)failure
{
    // TODO: Invocar al servicio real:
    /*
    [self.api getPath:@"/global/settings"
        authenticated:NO
           parameters:[NSDictionary dictionary]
              success:success
              failure:failure
     ];
    */
    // Fake:
    [NSTimer scheduledTimerWithTimeInterval:2
                                      block:^{
                                          if (success) {
                                              success(nil);
                                          }
                                      }
                                    repeats:NO];
}




// TODO: Definir si esta aplicación tiene usuarios, si no borrar.
- (void)initUser:(NSString *)notificationName
{
    NSString *token = [self.db getConfigWithName:SETTINGS_TOKEN];
    // Comentar / descomentar para alternar entre home y login.
    // Ojo porque una vez hemos puesto el token a != nil se guardará en BD y a partir de entonces siempre se da por logado.
    // token = @"123token321";
    
    if (token != nil) {
        // TODO: El usuario se leería o de BD o del servidor.
        User *user = [self.db getUserWithApiKey:token];
        [[Model getInstance] setLoggedUser:user];
        // Fin Fake.
        
        [self setToken:token];
        [[NSNotificationCenter defaultCenter] postNotificationName:notificationName object:self userInfo:[NSDictionary dictionaryWithObject:[NSNumber numberWithBool:YES] forKey:@"userLogged"]];
    } else {
        [[NSNotificationCenter defaultCenter] postNotificationName:notificationName object:self userInfo:[NSDictionary dictionaryWithObject:[NSNumber numberWithBool:NO] forKey:@"userLogged"]];
    }
}

// TODO: Definir si esta aplicación tiene usuarios, si no borrar.
- (void)setToken:(NSString *)token
{
    [[Model getInstance] setToken:token];
    [self.db insertConfigWithName:SETTINGS_TOKEN andValue:token];
}

- (void)setLastUpdate
{
    [[Model getInstance]setLastUpdateDate:[NSDate date]];
    NSDateFormatter *dateFormatter= [[NSDateFormatter alloc] init];
    [dateFormatter setDateFormat:@"dd-MM-yyyy hh:mm"];
    [self.db insertConfigWithName:SETTINGS_LAST_UPDATE andValue:[dateFormatter stringFromDate:[NSDate date]]];
    [self.db insertConfigWithName:SETTINGS_LAST_SUGGESTION_UPDATE andValue:[dateFormatter stringFromDate:[NSDate date]]];
}

- (void)setLastUpdateSuggestion
{
    [[Model getInstance]setLastUpdateDate:[NSDate date]];
    NSDateFormatter *dateFormatter= [[NSDateFormatter alloc] init];
    [dateFormatter setDateFormat:@"dd-MM-yyyy hh:mm"];
    [self.db insertConfigWithName:SETTINGS_LAST_SUGGESTION_UPDATE andValue:[dateFormatter stringFromDate:[NSDate date]]];
}


#pragma mark - Login and logout methods

-(void)LoginWithSuccess:(APIResponseHandler)success failure:(APIResponseHandler)failure{
    //TODO: averiguar como se hace el login
    //deviceId no puede o no deberia ser el UDID apple lo elimino.
    [self.api getPath:[NSString stringWithFormat:@"/cli/mw/login.json?mwkey=%@&device_id=%@",API_CLIENT_SECRET,API_CLIENT_ID]
        authenticated:NO
           parameters:nil
              success:success
              failure:failure
     ];
}

-(void)LoginWithKey:(NSString*)mwkey success:(APIResponseHandler)success failure:(APIResponseHandler)failure{
    //TODO: averiguar como se hace el login
    //deviceId no puede o no deberia ser el UDID apple lo elimino.
    [self.api getPath:[NSString stringWithFormat:@"/cli/mw/login.json?mwkey=%@&device_id=%@",mwkey,API_CLIENT_ID]
        authenticated:NO
           parameters:nil
              success:success
              failure:failure
     ];
}
// TODO: Definir si esta aplicación tiene usuarios, si no borrar.
- (void)logout
{
    [self removeToken];
}

// TODO: Definir si esta aplicación tiene usuarios, si no borrar.
- (void)removeToken
{
    [[Model getInstance] setToken:nil];
    [self.db deleteConfigWithName:SETTINGS_TOKEN];
    [self initUser:kServiceLogout];
}

#pragma mark - Restaurant Info methods

-(void)getRestaurantInfoWithSucces:(APIResponseHandler)success failure:(APIResponseHandler)failure
{
    [self.api getPath:[NSString stringWithFormat:@"/cli/c/get_restaurant_info.json?mwkey=%@",API_CLIENT_SECRET]
        authenticated:NO
           parameters:nil
              success:success
              failure:failure
     ];
}

-(void)getRestaurantInfoWithKey:(NSString*)mwkey succes:(APIResponseHandler)success failure:(APIResponseHandler)failure
{
    [self.api getPath:[NSString stringWithFormat:@"/cli/c/get_restaurant_info.json?mwkey=%@",mwkey]
        authenticated:NO
           parameters:nil
              success:success
              failure:failure
     ];
}

#pragma mark - Get Restaurant Modifiers methods

-(void)getRestaurantModifiersWithSucces:(APIResponseHandler)success failure:(APIResponseHandler)failure
{
    [self.api getPath:[NSString stringWithFormat:@"/cli/mw/modifiers.json?mwkey=%@",API_CLIENT_SECRET]
        authenticated:NO
           parameters:nil
              success:success
              failure:failure
     ];
}

-(void)getRestaurantModifiersWithKey:(NSString*)mwkey succes:(APIResponseHandler)success failure:(APIResponseHandler)failure
{
    [self.api getPath:[NSString stringWithFormat:@"/cli/mw/modifiers.json?mwkey=%@",mwkey]
        authenticated:NO
           parameters:nil
              success:success
              failure:failure
     ];
}

#pragma mark - Get Tables methods

-(void)getTablesWithSucces:(APIResponseHandler)success failure:(APIResponseHandler)failure
{
    [self.api getPath:[NSString stringWithFormat:@"/cli/mw/tables.json?mwkey=%@",API_CLIENT_SECRET]
        authenticated:NO
           parameters:nil
              success:success
              failure:failure
     ];
}

-(void)getTablesWithKey:(NSString*)mwkey succes:(APIResponseHandler)success failure:(APIResponseHandler)failure
{
    [self.api getPath:[NSString stringWithFormat:@"/cli/mw/tables.json?mwkey=%@",mwkey]
        authenticated:NO
           parameters:nil
              success:success
              failure:failure
     ];
}

#pragma mark - Get Suggestions methods

-(void)getSuggestionsWithSucces:(APIResponseHandler)success failure:(APIResponseHandler)failure
{
    [self.api getPath:[NSString stringWithFormat:@"/cli/mw/suggestions.json?mwkey=%@",API_CLIENT_SECRET]
        authenticated:NO
           parameters:nil
              success:success
              failure:failure
     ];
}

-(void)getSuggestionsWithKey:(NSString*)mwkey succes:(APIResponseHandler)success failure:(APIResponseHandler)failure
{
    [self.api getPath:[NSString stringWithFormat:@"/cli/mw/suggestions.json?mwkey=%@",mwkey]
        authenticated:NO
           parameters:nil
              success:success
              failure:failure
     ];
}

#pragma mark - Get User Info methods

-(void)getUserInfoWithSucces:(APIResponseHandler)success failure:(APIResponseHandler)failure
{
    [self.api getPath:[NSString stringWithFormat:@"/cli/mw/user_info.json?mwkey=%@",API_CLIENT_SECRET]
        authenticated:NO
           parameters:nil
              success:success
              failure:failure
     ];
}

-(void)getUserInfoWithKey:(NSString*)mwkey succes:(APIResponseHandler)success failure:(APIResponseHandler)failure
{
    [self.api getPath:[NSString stringWithFormat:@"/cli/mw/user_info.json?mwkey=%@",mwkey]
        authenticated:NO
           parameters:nil
              success:success
              failure:failure
     ];
}

#pragma mark - Get MW App Info methods

-(void)getMWAppInfoWithSucces:(APIResponseHandler)success failure:(APIResponseHandler)failure
{
    [self.api getPath:[NSString stringWithFormat:@"/cli/mw/app_info.json?mwkey=%@",API_CLIENT_SECRET]
        authenticated:NO
           parameters:nil
              success:success
              failure:failure
     ];
}

-(void)getMWAppInfoWithKey:(NSString*)mwkey succes:(APIResponseHandler)success failure:(APIResponseHandler)failure
{
    [self.api getPath:[NSString stringWithFormat:@"/cli/mw/app_info.json?mwkey=%@",mwkey]
        authenticated:NO
           parameters:nil
              success:success
              failure:failure
     ];
}

#pragma mark - Get Payment Options methods

-(void)getPaymentOptionsWithSucces:(APIResponseHandler)success failure:(APIResponseHandler)failure
{
    [self.api getPath:[NSString stringWithFormat:@"/cli/mw/payments.json?mwkey=%@",API_CLIENT_SECRET]
        authenticated:NO
           parameters:nil
              success:success
              failure:failure
     ];
}

-(void)getPaymentOptionsWithKey:(NSString*)mwkey succes:(APIResponseHandler)success failure:(APIResponseHandler)failure
{
    [self.api getPath:[NSString stringWithFormat:@"/cli/mw/payments.json?mwkey=%@",mwkey]
        authenticated:NO
           parameters:nil
              success:success
              failure:failure
     ];
}

#pragma mark - Get Discount methods

-(void)getDiscountWithSucces:(APIResponseHandler)success failure:(APIResponseHandler)failure
{
    [self.api getPath:[NSString stringWithFormat:@"/cli/mw/discounts.json?mwkey=%@",API_CLIENT_SECRET]
        authenticated:NO
           parameters:nil
              success:success
              failure:failure
     ];
}

-(void)getDiscountWithKey:(NSString*)mwkey succes:(APIResponseHandler)success failure:(APIResponseHandler)failure
{
    [self.api getPath:[NSString stringWithFormat:@"/cli/mw/discounts.json?mwkey=%@",mwkey]
        authenticated:NO
           parameters:nil
              success:success
              failure:failure
     ];
}

#pragma mark - Get payments methods

-(void)getPaymentsWithSucces:(APIResponseHandler)success failure:(APIResponseHandler)failure
{
    [self.api getPath:[NSString stringWithFormat:@"/cli/mw/payments.json?mwkey=%@",API_CLIENT_SECRET]
        authenticated:NO
           parameters:nil
              success:success
              failure:failure
     ];
}

-(void)getPaymentsWithKey:(NSString*)mwkey succes:(APIResponseHandler)success failure:(APIResponseHandler)failure
{
    [self.api getPath:[NSString stringWithFormat:@"/cli/mw/payments.json?mwkey=%@",mwkey]
        authenticated:NO
           parameters:nil
              success:success
              failure:failure
     ];
}

#pragma mark - POS methods

-(void)postOpenTableWithKey:(NSString*)mwkey tableSid:(NSString*)sid method:(NSString*)method pax:(NSString*)pax reservation:(NSString*)reservation firstTimeVisit:(NSString*)firstTimeVisit succes:(APIResponseHandler)success failure:(APIResponseHandler)failure
{
    if ([[self.posApi posIdAddres] length]==0) {
        [[[UIAlertView alloc]initWithTitle:@"Impresora sin configurar" message:@"No tiene la conficuracion de la impresora especificada" delegate:nil cancelButtonTitle:@"Ok" otherButtonTitles: nil] show];
    }else{
        [self.posApi postPath:[NSString stringWithFormat:@"/table?mwkey=%@&table=%@&method=%@&pax=%@&reservation=%@&first_time_visit=%@",mwkey,sid,method,pax,reservation,firstTimeVisit]
                authenticated:NO
                   parameters:nil
                      success:success
                      failure:failure
         ];
    }
    
}

-(void)postPrintTicketTableWithKey:(NSString*)mwkey tableSid:(NSString*)sid tableName:(NSString*)tableName discountSet:(NSMutableSet *)discountSet succes:(APIResponseHandler)success failure:(APIResponseHandler)failure
{
    if ([[self.posApi posIdAddres] length]==0) {
        [[[UIAlertView alloc]initWithTitle:@"Impresora sin configurar" message:@"No tiene la conficuracion de la impresora especificada" delegate:nil cancelButtonTitle:@"Ok" otherButtonTitles: nil] show];
    }else{
        NSMutableArray *paymentArray= [NSMutableArray arrayWithObject:[NSDictionary dictionaryWithObjectsAndKeys:@"",@"name",@"",@"sid",@"",@"amount", nil]];
        NSMutableArray *discountArray=[[NSMutableArray alloc]init];
        for (Discount *discount in discountSet) {
            [discountArray addObject:[NSDictionary dictionaryWithObjectsAndKeys:discount.sid,@"sid",discount.name,@"name",discount.note,@"note",discount.dType,@"dtype",discount.amount,@"amount", nil]];
        }
        NSDictionary *parameters=[NSDictionary dictionaryWithObjectsAndKeys:sid,@"table_sid",tableName,@"table_name",paymentArray,@"payment_lines",discountArray,@"discounts", nil];
        [self.posApi postPath:[NSString stringWithFormat:@"/ticket?mwkey=%@&close_table=false",mwkey]
                authenticated:NO
                   parameters:parameters
                      success:success
                      failure:failure
         ];
    }
    
}

-(void)postPrintTicketAndCloseTableWithKey:(NSString*)mwkey tableSid:(NSString*)sid tableName:(NSString*)tableName discountSet:(NSMutableSet *)discountSet paymentSet:(NSMutableSet *)paymentSet succes:(APIResponseHandler)success failure:(APIResponseHandler)failure
{
    if ([[self.posApi posIdAddres] length]==0) {
        [[[UIAlertView alloc]initWithTitle:@"Impresora sin configurar" message:@"No tiene la conficuracion de la impresora especificada" delegate:nil cancelButtonTitle:@"Ok" otherButtonTitles: nil] show];
    }else{
        NSMutableArray *paymentArray=[[NSMutableArray alloc]init];
        for (Payment *payment in paymentSet) {
            if ([payment.key isEqualToString:@"cash"]) {
                [paymentArray addObject:[NSDictionary dictionaryWithObjectsAndKeys:payment.key,@"name",payment.sid,@"sid",payment.amount,@"amount", nil]];
            }else{
                [paymentArray addObject:[NSDictionary dictionaryWithObjectsAndKeys:payment.key,@"name",payment.sid,@"sid",payment.amount,@"amount",payment.note,@"note", nil]];
            }
            
        }
        NSMutableArray *discountArray=[[NSMutableArray alloc]init];
        for (Discount *discount in discountSet) {
            [discountArray addObject:[NSDictionary dictionaryWithObjectsAndKeys:discount.sid,@"sid",discount.name,@"name",discount.note,@"note",discount.dType,@"dtype",discount.amount,@"amount", nil]];
        }
        
        
        NSDictionary *parameters=[NSDictionary dictionaryWithObjectsAndKeys:sid,@"table_sid",tableName,@"table_name",paymentArray,@"payment_lines",discountArray,@"discounts", nil];
        [self.posApi postPath:[NSString stringWithFormat:@"/ticket?mwkey=%@&close_table=true",mwkey]
                authenticated:NO
                   parameters:parameters
                      success:success
                      failure:failure
         ];
    }
    
}

-(void)postDishWithsucces:(APIResponseHandler)success failure:(APIResponseHandler)failure
{
    Table *currentTable=[[Model getInstance] selectedTable];
    Floor *currentFloor=[[Model getInstance]selectedFloor];
    NSMutableArray *ticketLineArray= [NSMutableArray arrayWithObject:[NSDictionary dictionaryWithObjectsAndKeys:@"5d004328-aa99-4666-8241-73e9a4f2e8ea",@"product_sid", @"22ce7475-6cf1-4afa-b8a9-fef05c60f958",@"category_sid",@"Lady Burguer P",@"product_name",@"2",@"multiply",@"9.9",@"price",@"cambiar patatas por ensalada ",@"note", nil]];
    NSString *tableName=[NSString stringWithFormat:@"%@ mesa %@",[currentFloor name],[NSString stringWithFormat:@"%i",[currentTable tableNumber]]];
    NSDictionary *parameters=[NSDictionary dictionaryWithObjectsAndKeys:currentTable.sid,@"table_sid",tableName,@"table_name",ticketLineArray,@"ticket_lines", nil];
    [self.posApi postPath:@"/order"
            authenticated:NO
               parameters:parameters
                  success:success
                  failure:failure
     ];
}

-(void)postDishWithMultiply:(NSString*)multiply dish:(Dish*)dish note:(NSString*)note categorySid:(NSString *)categorySid modifiers:(NSDictionary*) modifierList discount:(Discount*)discount succes:(APIResponseHandler)success failure:(APIResponseHandler)failure
{
    if ([[self.posApi posIdAddres] length]==0) {
        [[[UIAlertView alloc]initWithTitle:@"Impresora sin configurar" message:@"No tiene la conficuracion de la impresora especificada" delegate:nil cancelButtonTitle:@"Ok" otherButtonTitles: nil] show];
    }else{
        Table *currentTable=[[Model getInstance] selectedTable];
        Floor *currentFloor=[[Model getInstance]selectedFloor];
        NSDictionary *discountDictionary=[NSDictionary dictionaryWithObjectsAndKeys:@"",@"sid",@"",@"name",@"",@"note",@"",@"dtype",@"",@"amount", nil];
        if (discount.sid) {
            discountDictionary=[NSDictionary dictionaryWithObjectsAndKeys:discount.sid,@"sid",discount.name,@"name",discount.note,@"note",discount.dType,@"dtype",discount.amount,@"amount", nil];
        }
        NSMutableArray *ticketLineArray=nil;
        if (modifierList) {
            ticketLineArray= [NSMutableArray arrayWithObject:[NSDictionary dictionaryWithObjectsAndKeys:dish.sid,@"product_sid", categorySid,@"category_sid",dish.name,@"product_name",multiply,@"multiply",dish.price,@"price",modifierList,@"modifier_list_set",note,@"note",discountDictionary,@"discount", nil]];
        }else{
            ticketLineArray= [NSMutableArray arrayWithObject:[NSDictionary dictionaryWithObjectsAndKeys:dish.sid,@"product_sid", categorySid,@"category_sid",dish.name,@"product_name",multiply,@"multiply",dish.price,@"price",note,@"note",discountDictionary,@"discount", nil]];
        }
        NSString *tableName=[NSString stringWithFormat:@"%@ mesa %@",[currentFloor name],[NSString stringWithFormat:@"%i",[currentTable tableNumber]]];
        NSDictionary *parameters=[NSDictionary dictionaryWithObjectsAndKeys:currentTable.sid,@"table_sid",tableName,@"table_name",ticketLineArray,@"ticket_lines", nil];
        [self.posApi postPath:@"/order"
                authenticated:NO
                   parameters:parameters
                      success:success
                      failure:failure
         ];
    }

}

-(void)postDishWithOrderArray:(NSMutableArray *)orderArray succes:(APIResponseHandler)success failure:(APIResponseHandler)failure
{
    if ([[self.posApi posIdAddres] length]==0) {
        [[[UIAlertView alloc]initWithTitle:@"Impresora sin configurar" message:@"No tiene la conficuracion de la impresora especificada" delegate:nil cancelButtonTitle:@"Ok" otherButtonTitles: nil] show];
    }else{
        Table *currentTable=[[Model getInstance] selectedTable];
        Floor *currentFloor=[[Model getInstance]selectedFloor];
        NSMutableArray *ticketLineArray= [[NSMutableArray alloc]init];
        for (Order *order in orderArray) {
            Discount *discount=[[self db]getOrderDiscountWithOrderId:order.orderId];
            NSDictionary *discountDictionary=[NSDictionary dictionaryWithObjectsAndKeys:@"",@"sid",@"",@"name",@"",@"note",@"",@"dtype",@"",@"amount", nil];
            if (discount.sid) {
                discountDictionary=[NSDictionary dictionaryWithObjectsAndKeys:discount.sid,@"sid",discount.name,@"name",discount.note,@"note",discount.dType,@"dtype",discount.amount,@"amount", nil];
            }
            NSMutableArray *modifierArray=[[NSMutableArray alloc]init];
            NSString *modifierListSetSid=nil;
            for (OrderMod *orderMod in [[self db]getOrdersModsWithOrderId:order.orderId]) {
                ModifierList *modifierList=[[self db]getModifierListWithSid:orderMod.mlistSid];
                Modifier *selectedModifier=[[self db]getModifierWithSid:orderMod.modifierSid];
                NSDictionary *modifierListDictionary=[NSDictionary dictionaryWithObjectsAndKeys:modifierList.sid,@"sid",modifierList.name,@"name",[NSArray arrayWithObject:[NSDictionary dictionaryWithObjectsAndKeys:selectedModifier.sid,@"sid",selectedModifier.name,@"name", nil]],@"selected_modifiers", nil];
                [modifierArray addObject:modifierListDictionary];
                modifierListSetSid=orderMod.mlSetSid;
            }
            NSDictionary * modifierListSetDictionary=nil;
            if ([modifierArray count]>0) {
                ModifierListSets *modifierListSet=[[self db] getModifierListSetWithSid:modifierListSetSid];
                modifierListSetDictionary=[NSDictionary dictionaryWithObjectsAndKeys:modifierListSet.sid,@"sid",modifierListSet.name,@"name",modifierArray,@"modifier_lists",nil];
            }
            if (modifierListSetDictionary) {
                NSDictionary *orderDictionary=[NSDictionary dictionaryWithObjectsAndKeys:order.sid,@"product_sid", order.categorySid,@"category_sid",order.productName,@"product_name",[NSString stringWithFormat:@"%i", order.quantity],@"multiply",order.price,@"price",modifierListSetDictionary,@"modifier_list_set",order.note,@"note",discountDictionary,@"discount", nil];
                [ticketLineArray addObject:orderDictionary];
            }else{
                NSDictionary *orderDictionary=[NSDictionary dictionaryWithObjectsAndKeys:order.sid,@"product_sid", order.categorySid,@"category_sid",order.productName,@"product_name",[NSString stringWithFormat:@"%i", order.quantity],@"multiply",order.price,@"price",order.note,@"note",discountDictionary,@"discount", nil];
                [ticketLineArray addObject:orderDictionary];
            }
        }
        NSString *tableName=[NSString stringWithFormat:@"%@ mesa %@",[currentFloor name],[NSString stringWithFormat:@"%i",[currentTable tableNumber]]];
        NSDictionary *parameters=[NSDictionary dictionaryWithObjectsAndKeys:currentTable.sid,@"table_sid",tableName,@"table_name",ticketLineArray,@"ticket_lines", nil];
        [self.posApi postPath:@"/order"
                authenticated:NO
                   parameters:parameters
                      success:success
                      failure:failure
         ];
    }
}


-(void)postDishWithOrderArray:(NSMutableArray *)orderArray table:(Table*)currentTable succes:(APIResponseHandler)success failure:(APIResponseHandler)failure
{
    if ([[self.posApi posIdAddres] length]==0) {
        [[[UIAlertView alloc]initWithTitle:@"Impresora sin configurar" message:@"No tiene la conficuracion de la impresora especificada" delegate:nil cancelButtonTitle:@"Ok" otherButtonTitles: nil] show];
    }else{
        NSMutableArray *ticketLineArray= [[NSMutableArray alloc]init];
        for (Order *order in orderArray) {
            Discount *discount=[[self db]getOrderDiscountWithOrderId:order.orderId];
            NSDictionary *discountDictionary=[NSDictionary dictionaryWithObjectsAndKeys:@"",@"sid",@"",@"name",@"",@"note",@"",@"dtype",@"",@"amount", nil];
            if (discount.sid) {
                discountDictionary=[NSDictionary dictionaryWithObjectsAndKeys:discount.sid,@"sid",discount.name,@"name",discount.note,@"note",discount.dType,@"dtype",discount.amount,@"amount", nil];
            }
            NSMutableArray *modifierArray=[[NSMutableArray alloc]init];
            NSString *modifierListSetSid=nil;
            for (OrderMod *orderMod in [[self db]getOrdersModsWithOrderId:order.orderId]) {
                ModifierList *modifierList=[[self db]getModifierListWithSid:orderMod.mlistSid];
                Modifier *selectedModifier=[[self db]getModifierWithSid:orderMod.modifierSid];
                NSDictionary *modifierListDictionary=[NSDictionary dictionaryWithObjectsAndKeys:modifierList.sid,@"sid",modifierList.name,@"name",[NSArray arrayWithObject:[NSDictionary dictionaryWithObjectsAndKeys:selectedModifier.sid,@"sid",selectedModifier.name,@"name", nil]],@"selected_modifiers", nil];
                [modifierArray addObject:modifierListDictionary];
                modifierListSetSid=orderMod.mlSetSid;
            }
            NSDictionary * modifierListSetDictionary=nil;
            if ([modifierArray count]>0) {
                ModifierListSets *modifierListSet=[[self db] getModifierListSetWithSid:modifierListSetSid];
                modifierListSetDictionary=[NSDictionary dictionaryWithObjectsAndKeys:modifierListSet.sid,@"sid",modifierListSet.name,@"name",modifierArray,@"modifier_lists",nil];
            }
            if (modifierListSetDictionary) {
                NSDictionary *orderDictionary=[NSDictionary dictionaryWithObjectsAndKeys:order.sid,@"product_sid", order.categorySid,@"category_sid",order.productName,@"product_name",[NSString stringWithFormat:@"%i", order.quantity],@"multiply",order.price,@"price",modifierListSetDictionary,@"modifier_list_set",order.note,@"note",discountDictionary,@"discount", nil];
                [ticketLineArray addObject:orderDictionary];
            }else{
                NSDictionary *orderDictionary=[NSDictionary dictionaryWithObjectsAndKeys:order.sid,@"product_sid", order.categorySid,@"category_sid",order.productName,@"product_name",[NSString stringWithFormat:@"%i", order.quantity],@"multiply",order.price,@"price",order.note,@"note",discountDictionary,@"discount", nil];
                [ticketLineArray addObject:orderDictionary];
            }
        }
        NSDictionary *parameters=[NSDictionary dictionaryWithObjectsAndKeys:currentTable.sid,@"table_sid",[currentTable nameOfTable],@"table_name",ticketLineArray,@"ticket_lines", nil];
        [self.posApi postPath:@"/order"
                authenticated:NO
                   parameters:parameters
                      success:success
                      failure:failure
         ];
    }
    
}

-(void)getIsOpenedWithSid:(NSString *)sid Succes:(APIResponseHandler)success failure:(APIResponseHandler)failure
{
    if ([[self.posApi posIdAddres] length]==0) {
        [[[UIAlertView alloc]initWithTitle:@"Impresora sin configurar" message:@"No tiene la conficuracion de la impresora especificada" delegate:nil cancelButtonTitle:@"Ok" otherButtonTitles: nil] show];
    }else{
        [self.posApi getPath:[NSString stringWithFormat:@"/table?mwkey=%@&table=%@",API_CLIENT_SECRET,sid]
               authenticated:NO
                  parameters:nil
                     success:success
                     failure:failure
         ];
    }
    
}

-(void)postSecondDishesWithKey:(NSString*)mwkey table:(Table *)table succes:(APIResponseHandler)success failure:(APIResponseHandler)failure
{
    if ([[self.posApi posIdAddres] length]==0) {
        [[[UIAlertView alloc]initWithTitle:@"Impresora sin configurar" message:@"No tiene la conficuracion de la impresora especificada" delegate:nil cancelButtonTitle:@"Ok" otherButtonTitles: nil] show];
    }else{
        [self getIsOpenedWithSid:table.sid Succes:^(NSMutableDictionary *json) {
            [self.posApi postPath:[NSString stringWithFormat:@"/actions/bring_second_courses?mwkey=%@&table_sid=%@&table_name=%@",mwkey,table.sid,[[table nameOfTable] stringByReplacingOccurrencesOfString:@" " withString:@"%20"]]
                    authenticated:NO
                       parameters:nil
                          success:success
                          failure:failure
             ];
        } failure:^(NSMutableDictionary *json) {
            [[[UIAlertView alloc]initWithTitle:@"Mesa no abierta" message:@"La mesa seleccionada para mandar los segundos platos no esta abierta" delegate:nil cancelButtonTitle:@"Ok" otherButtonTitles: nil] show];
        }];
        
    }
    
}

@end
