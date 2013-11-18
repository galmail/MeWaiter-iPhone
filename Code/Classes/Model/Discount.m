//
//  Discount.m
//  meWaiter-ios
//
//  Created by omar megdadi on 06/11/13.
//  Copyright (c) 2013 [WE ARE] DEVELAPPERS. All rights reserved.
//

#import "Discount.h"

@implementation Discount
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
    self.sid=[dictionary objectForKey:@"sid"];
    self.name=[dictionary objectForKey:@"name"];
    self.dType=[dictionary objectForKey:@"dtype"];
    self.amount=[dictionary objectForKey:@"amount"];
    self.position=[[dictionary objectForKey:@"position"] intValue];
    self.note=[dictionary objectForKey:@"note"];
    self.restaurantId=[[dictionary objectForKey:@"restaurant_id"] intValue];
    self.menuId=[[dictionary objectForKey:@"menu_id"] intValue];
    self.sectionId=[[dictionary objectForKey:@"section_id"] intValue];
    self.dishId=[[dictionary objectForKey:@"dish_id"] intValue];
}
@end
