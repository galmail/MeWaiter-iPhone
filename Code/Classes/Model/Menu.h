//
//  Menu.h
//  meWaiter-ios
//
//  Created by omar megdadi on 15/10/13.
//  Copyright (c) 2013 [WE ARE] DEVELAPPERS. All rights reserved.
//

#import <Foundation/Foundation.h>

@interface Menu : NSObject
//sid,id,name,menu_type,price
@property (nonatomic,assign) int menuId;
@property (nonatomic,strong) NSString *sid;
@property (nonatomic,strong) NSString *name;
@property (nonatomic,strong) NSString *menuType;
@property (nonatomic,strong) NSString *price;
@property (nonatomic,strong) NSMutableArray *sections;

- (id) initWithDictionary: (NSDictionary *) dictionary;

@end
