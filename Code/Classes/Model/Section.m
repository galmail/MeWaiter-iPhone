//
//  Section.m
//  meWaiter-ios
//
//  Created by omar megdadi on 16/10/13.
//  Copyright (c) 2013 [WE ARE] DEVELAPPERS. All rights reserved.
//

#import "Section.h"
#import "Dish.h"

@implementation Section

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
    self.sectionId=[[dictionary objectForKey:@"id"] intValue];
    self.sid=[dictionary objectForKey:@"sid"];
    self.name=[dictionary objectForKey:@"name"];
    self.mini=[dictionary objectForKey:@"mini"];
    self.thumbnail=[dictionary objectForKey:@"thumbnail"];
    NSArray *dishesArray=[dictionary objectForKey:@"dishes"];
    self.dishes=[[NSMutableArray alloc]init];
    for (NSDictionary *dishDictonary in dishesArray) {
        Dish *dish= [[Dish alloc]initWithDictionary:dishDictonary];
        [self.dishes addObject:dish];
    }
    NSArray *subsectionArray=[dictionary objectForKey:@"subsections"];
    self.subsections=[[NSMutableArray alloc]init];
    for (NSDictionary *subsectionDictonary in subsectionArray) {
        Section *subsection= [[Section alloc]initWithDictionary:subsectionDictonary];
        [self.subsections addObject:subsection];
    }
    
}

@end
