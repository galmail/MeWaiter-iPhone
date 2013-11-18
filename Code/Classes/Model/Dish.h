//
//  Dish.h
//  meWaiter-ios
//
//  Created by omar megdadi on 16/10/13.
//  Copyright (c) 2013 [WE ARE] DEVELAPPERS. All rights reserved.
//

#import <Foundation/Foundation.h>

@interface Dish : NSObject
@property (nonatomic,assign) int dishId;
@property (nonatomic,strong) NSString *sid;
@property (nonatomic,strong) NSString *name;
@property (nonatomic,strong) NSString *price;
@property (nonatomic,strong) NSString *sdDishId;
@property (nonatomic,strong) NSString *shortTitle;
@property (nonatomic,strong) NSString *dishDescription;

- (id) initWithDictionary: (NSDictionary *) dictionary;

@end
