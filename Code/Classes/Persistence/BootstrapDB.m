//
//  BootstrapDB.m
//  bootstrap-ios
//
//  Created by Marcos Pinazo on 2/1/13.
//  Copyright (c) 2013 [WE ARE] DEVELAPPERS. All rights reserved.
//

#import "BootstrapDB.h"

#import "CommonUtil.h"

@implementation BootstrapDB

- (NSString *)getDBFullPath
{    
    return [[CommonUtil getDocumentsPath] stringByAppendingPathComponent:@"mewaiter.db"];
}

- (BOOL)createTables
{
    if (![super createTables]) {
        return NO;
    }
    
    return YES;
}

@end
