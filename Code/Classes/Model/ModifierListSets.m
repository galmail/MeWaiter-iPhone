//
//  ModifierListSets.m
//  meWaiter-ios
//
//  Created by omar megdadi on 28/10/13.
//  Copyright (c) 2013 [WE ARE] DEVELAPPERS. All rights reserved.
//

#import "ModifierListSets.h"
#import "Dish.h"
#import "ModifierList.h"

@implementation ModifierListSets

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
    self.modiferListSetsId=[[dictionary objectForKey:@"id"] intValue];
    self.sid=[dictionary objectForKey:@"sid"];
    self.name=[dictionary objectForKey:@"name"];
    NSArray *dishesArray=[dictionary objectForKey:@"dishes"];
    self.dishes=[[NSMutableArray alloc]init];
    for (NSDictionary *dishDictonary in dishesArray) {
        Dish *dish= [[Dish alloc]initWithDictionary:dishDictonary];
        [self.dishes addObject:dish];
    }
    NSArray *modifierListArray=[dictionary objectForKey:@"modifier_lists"];
    self.modifierLists=[[NSMutableArray alloc]init];
    for (NSDictionary *dishDictonary in modifierListArray) {
        ModifierList *modifierList= [[ModifierList alloc]initWithDictionary:dishDictonary];
        [self.modifierLists addObject:modifierList];
    }
}

#pragma mark - NSCopy methods

- (id)copyWithZone:(NSZone *)zone{
    ModifierListSets *newModifierListSets=[[ModifierListSets alloc]init];
    newModifierListSets.name=[self.name copy];
    newModifierListSets.sid=[self.sid copy];
    newModifierListSets.modiferListSetsId=self.modiferListSetsId;
    return newModifierListSets;
}
@end
