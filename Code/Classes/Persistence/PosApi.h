//
//  PosApi.h
//  meWaiter-ios
//
//  Created by omar megdadi on 22/10/13.
//  Copyright (c) 2013 [WE ARE] DEVELAPPERS. All rights reserved.
//
#import <Foundation/Foundation.h>
#import "AFHTTPClient.h"
#import "BootstrapAPI.h"

@interface PosApi : AFHTTPClient
@property (nonatomic,strong) NSString *posIdAddres;

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
