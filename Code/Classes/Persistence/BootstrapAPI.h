//
//  BootstrapAPI.h
//  bootstrap-ios
//
//  Created by Marcos Pinazo on 3/8/13.
//  Copyright (c) 2013 [WE ARE] DEVELAPPERS. All rights reserved.
//

#import <Foundation/Foundation.h>

#import "AFHTTPClient.h"

typedef void(^APIResponseHandler)(NSMutableDictionary *json);

@interface BootstrapAPI : AFHTTPClient

- (void)getPath:(NSString *)path
 authenticated:(BOOL)authenticated
     parameters:(NSDictionary *)parameters
        success:(APIResponseHandler)success
        failure:(APIResponseHandler)failure;

- (void)postPath:(NSString *)path
   authenticated:(BOOL)authenticated
      parameters:(NSDictionary *)parameters
         success:(APIResponseHandler)success
         failure:(APIResponseHandler)failure;

@end
