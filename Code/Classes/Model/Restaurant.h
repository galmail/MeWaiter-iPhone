//
//  Info.h
//  meWaiter-ios
//
//  Created by omar megdadi on 15/10/13.
//  Copyright (c) 2013 [WE ARE] DEVELAPPERS. All rights reserved.
//

#import <Foundation/Foundation.h>

@interface Restaurant : NSObject
@property (nonatomic,strong) NSString *name;
@property (nonatomic,strong) NSString *posIpAddress;
@property (nonatomic,strong) NSString *logo;
@property (nonatomic,strong) NSString *i18nbg;
@property (nonatomic,strong) NSMutableArray *menus;

- (id) initWithDictionary: (NSDictionary *) dictionary;
@end
