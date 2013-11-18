//
//  Modifier.m
//  meWaiter-ios
//
//  Created by omar megdadi on 28/10/13.
//  Copyright (c) 2013 [WE ARE] DEVELAPPERS. All rights reserved.
//

#import "Modifier.h"

@implementation Modifier
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
    self.modiferId=[[dictionary objectForKey:@"id"] intValue];
    self.sid=[dictionary objectForKey:@"sid"];
    self.name=[dictionary objectForKey:@"name"];
    self.sdModifierid=[dictionary objectForKey:@"sd_modifierid"];
    self.modifierDescription=[dictionary objectForKey:@"description"];
    self.price=[dictionary objectForKey:@"price"];
}
@end
