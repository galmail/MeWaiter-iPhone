//
//  Table.m
//  meWaiter-ios
//
//  Created by omar megdadi on 21/10/13.
//  Copyright (c) 2013 [WE ARE] DEVELAPPERS. All rights reserved.
//

#import "Table.h"
#import "CoreService.h"
#import "Floor.h"

@implementation Table

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
    self.tableId=[[dictionary objectForKey:@"id"] intValue];
    self.sid=[dictionary objectForKey:@"sid"];
    self.tableNumber=[[dictionary objectForKey:@"number"] intValue];
    
}

- (NSString *) nameOfTable{
    Floor *floor= [[[CoreService getInstance]db] getFloorWithId:self.floorId];
    return  [NSString stringWithFormat:@"%@ mesa %i",floor.name,self.tableNumber];
}

@end
