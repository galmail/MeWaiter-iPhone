//
//  ModifierList.m
//  meWaiter-ios
//
//  Created by omar megdadi on 28/10/13.
//  Copyright (c) 2013 [WE ARE] DEVELAPPERS. All rights reserved.
//

#import "ModifierList.h"
#import "Modifier.h"

@implementation ModifierList
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
    self.modiferListId=[[dictionary objectForKey:@"id"] intValue];
    self.sid=[dictionary objectForKey:@"sid"];
    self.name=[dictionary objectForKey:@"name"];
    self.isMandatory=[dictionary objectForKey:@"is_mandatory"];
    NSArray *modifierArray=[dictionary objectForKey:@"modifiers"];
    self.modifiers=[[NSMutableArray alloc]init];
    for (NSDictionary *dishDictonary in modifierArray) {
        Modifier *modifier= [[Modifier alloc]initWithDictionary:dishDictonary];
        [self.modifiers addObject:modifier];
    }
}
@end
