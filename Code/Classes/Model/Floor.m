//
//  Floor.m
//  meWaiter-ios
//
//  Created by omar megdadi on 21/10/13.
//  Copyright (c) 2013 [WE ARE] DEVELAPPERS. All rights reserved.
//

#import "Floor.h"
#import "Table.h"


@implementation Floor
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
    self.floorId=[[dictionary objectForKey:@"id"] intValue];
    self.sid=[dictionary objectForKey:@"sid"];
    self.name=[dictionary objectForKey:@"name"];
    
    NSArray *tablesArray=[dictionary objectForKey:@"tables"];
    self.tables=[[NSMutableArray alloc]init];
    for (NSDictionary *sectionDictonary in tablesArray) {
        Table *table= [[Table alloc]initWithDictionary:sectionDictonary];
        [self.tables addObject:table];
    }
}
@end
