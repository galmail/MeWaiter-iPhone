//
//  Menu.m
//  meWaiter-ios
//
//  Created by omar megdadi on 15/10/13.
//  Copyright (c) 2013 [WE ARE] DEVELAPPERS. All rights reserved.
//

#import "Menu.h"
#import "Section.h"

@implementation Menu
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
    self.menuId=[[dictionary objectForKey:@"id"] intValue];
    self.sid=[dictionary objectForKey:@"sid"];
    self.name=[dictionary objectForKey:@"name"];
    self.menuType=[dictionary objectForKey:@"menu_type"];
    self.price=[dictionary objectForKey:@"price"];
    
    NSArray *sectionArray=[dictionary objectForKey:@"sections"];
    self.sections=[[NSMutableArray alloc]init];
    for (NSDictionary *sectionDictonary in sectionArray) {
        Section *section= [[Section alloc]initWithDictionary:sectionDictonary];
        [self.sections addObject:section];
    }
    
}

@end
