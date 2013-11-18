//
//  Dish.m
//  meWaiter-ios
//
//  Created by omar megdadi on 16/10/13.
//  Copyright (c) 2013 [WE ARE] DEVELAPPERS. All rights reserved.
//

#import "Dish.h"

@implementation Dish
- (id) initWithDictionary: (NSDictionary *) dictionary
{
    self = [super init];
    if (self) {
        
        [self hydrateWithDictionary: dictionary];
    }
    return self;
}

- (void) hydrateWithDictionary: (NSDictionary *) dictionary
{
    self.dishId=[[dictionary objectForKey:@"id"] intValue];
    self.sid=[dictionary objectForKey:@"sid"];
    self.name=[dictionary objectForKey:@"name"];
    self.price=[dictionary objectForKey:@"price"];
    self.sdDishId=[dictionary objectForKey:@"sd_dish_id"];
    self.shortTitle=[dictionary objectForKey:@"short_title"];
    self.dishDescription=[dictionary objectForKey:@"description"];
}


@end
