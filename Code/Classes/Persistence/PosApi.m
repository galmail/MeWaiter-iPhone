//
//  PosApi.m
//  meWaiter-ios
//
//  Created by omar megdadi on 22/10/13.
//  Copyright (c) 2013 [WE ARE] DEVELAPPERS. All rights reserved.
//

#import "PosApi.h"

#import "Constants.h"
#import "AFJSONRequestOperation.h"

@implementation PosApi

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
    NSString *fullPath = [NSString stringWithFormat:@"http://%@:8080%@",self.posIdAddres, path];
    
#ifdef LOG_API
    NSLog(@"POS API: request: %@", fullPath);
#endif
    
    [super getPath:fullPath
        parameters:parameters
           success:^(AFHTTPRequestOperation *operation, id responseObject) {
               
#ifdef LOG_API
               NSLog(@"POS API: success: %@", responseObject);
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
               NSLog(@"POS API: error: %@", responseObject);
               NSLog(@"POS API: NSError: %@", errorObject);
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
    NSString *fullPath = [NSString stringWithFormat:@"http://%@:8080%@", self.posIdAddres, path];
    
#ifdef LOG_API
    NSLog(@"POS API: request: %@", fullPath);
    NSLog(@"POS API: parameters: %@", parameters);
#endif
    
    [super postPath:fullPath
         parameters:parameters
            success:^(AFHTTPRequestOperation *operation, id responseObject) {
                
#ifdef LOG_API
                NSLog(@"POS API: success: %@", responseObject);
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
                NSLog(@"POS API: error: %@", responseObject);
#endif
                
                if (failure != nil) {
                    failure(responseObject);
                }
            }
     ];
}
@end
