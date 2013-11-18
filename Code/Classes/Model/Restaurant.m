//
//  Info.m
//  meWaiter-ios
//
//  Created by omar megdadi on 15/10/13.
//  Copyright (c) 2013 [WE ARE] DEVELAPPERS. All rights reserved.
//

#import "Restaurant.h"
#import "Menu.h"

@implementation Restaurant

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
    self.name=[dictionary objectForKey:@"name"];
    self.posIpAddress=[dictionary objectForKey:@"pos_ip_address"];;
    self.logo=[dictionary objectForKey:@"logo"];
    self.i18nbg=[dictionary objectForKey:@"i18nbg"];
    NSArray *menuArray=[dictionary objectForKey:@"menus"];
    self.menus=[[NSMutableArray alloc]init];
    for (NSDictionary *menuDictonary in menuArray) {
        Menu *menu= [[Menu alloc]initWithDictionary:menuDictonary];
        [self.menus addObject:menu];
    }
    //TODO: Completar con los datos que no estan aun incluidos
}
@end
