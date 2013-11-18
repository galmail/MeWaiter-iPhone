//
//  User.h
//  bootstrap-ios
//
//  Created by Marcos Pinazo on 2/1/13.
//  Copyright (c) 2013 [WE ARE] DEVELAPPERS. All rights reserved.
//

// TODO: Definir si esta aplicación tiene usuarios, si no borrar.

#import <Foundation/Foundation.h>

@interface User : NSObject
//mwkey,api_key,location_id,device_id,user_id,employee_id
@property (strong, nonatomic) NSString *mwKey;
@property (strong, nonatomic) NSString *apiKey;
@property (strong, nonatomic) NSString *locationId;
@property (strong, nonatomic) NSString *deviceId;
@property (strong, nonatomic) NSString *userId;
@property (strong, nonatomic) NSString *employee_id;

@end
