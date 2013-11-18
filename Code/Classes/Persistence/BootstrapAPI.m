//
//  BootstrapAPI.m
//  bootstrap-ios
//
//  Created by Marcos Pinazo on 3/8/13.
//  Copyright (c) 2013 [WE ARE] DEVELAPPERS. All rights reserved.
//

#import "BootstrapAPI.h"

#import "Constants.h"
#import "AFJSONRequestOperation.h"

@implementation BootstrapAPI

- (NSMutableDictionary *)createCommunicationErrorObject
{
    return [NSMutableDictionary dictionaryWithObject:[NSMutableDictionary dictionaryWithObjectsAndKeys:[NSNumber numberWithInt:-1], @"code", @"Communication error", @"message", nil] forKey:@"error"];
}

- (void)getPath:(NSString *)path
  authenticated:(BOOL)authenticated
     parameters:(NSDictionary *)parameters
        success:(APIResponseHandler)success
        failure:(APIResponseHandler)failure
{
    NSString *fullPath = [NSString stringWithFormat:@"%@%@%@", API_BASE_URL, API_VERSION, path];
    
    #ifdef LOG_API
    NSLog(@"Bootstrap API: request: %@", fullPath);
    #endif
    
    [super getPath:fullPath
        parameters:parameters
           success:^(AFHTTPRequestOperation *operation, id responseObject) {
               
               #ifdef LOG_API
               NSLog(@"Bootstrap API: success: %@", responseObject);
               #endif
               
               if (success != nil) {
                   success((NSMutableDictionary *)responseObject);
               }
           }
           failure:^(AFHTTPRequestOperation *operation, NSError *errorObject) {
               id responseObject = ((AFJSONRequestOperation *)operation).responseJSON;
               if (responseObject == nil) {
                   responseObject = [self createCommunicationErrorObject];
               }
               
               #ifdef LOG_API
               NSLog(@"Bootstrap API: error: %@", responseObject);
               NSLog(@"Bootstrap API: NSError: %@", errorObject);
               #endif
               
               if (failure != nil) {
                   failure(responseObject);
               }
           }
    ];
}

- (void)postPath:(NSString *)path
  authenticated:(BOOL)authenticated
     parameters:(NSDictionary *)parameters
        success:(APIResponseHandler)success
        failure:(APIResponseHandler)failure
{
    NSString *fullPath = [NSString stringWithFormat:@"%@%@%@", API_BASE_URL, API_VERSION, path];
    
    #ifdef LOG_API
    NSLog(@"Bootstrap API: request: %@", fullPath);
    NSLog(@"Bootstrap API: parameters: %@", parameters);
    #endif
    
    [super postPath:fullPath
         parameters:parameters
            success:^(AFHTTPRequestOperation *operation, id responseObject) {
                
                #ifdef LOG_API
                NSLog(@"Bootstrap API: success: %@", responseObject);
                #endif
                
                if (success != nil) {
                    success(responseObject);
                }
               
            }
            failure:^(AFHTTPRequestOperation *operation, NSError *errorObject) {
                id responseObject = ((AFJSONRequestOperation *)operation).responseJSON;
                if (responseObject == nil) {
                    responseObject = [self createCommunicationErrorObject];
                }
                
                #ifdef LOG_API
                NSLog(@"Bootstrap API: error: %@", responseObject);
                #endif
                
                if (failure != nil) {
                    failure(responseObject);
                }
            }
    ];
}

@end
