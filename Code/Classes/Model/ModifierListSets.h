//
//  ModifierListSets.h
//  meWaiter-ios
//
//  Created by omar megdadi on 28/10/13.
//  Copyright (c) 2013 [WE ARE] DEVELAPPERS. All rights reserved.
//

#import <Foundation/Foundation.h>

@interface ModifierListSets : NSObject <NSCopying>

@property (nonatomic,assign) int modiferListSetsId;
@property (nonatomic,strong) NSString *sid;
@property (nonatomic,strong) NSString *name;
@property (nonatomic,strong) NSMutableArray *dishes;
@property (nonatomic,strong) NSMutableArray *modifierLists;

- (id) initWithDictionary: (NSDictionary *) dictionary;

@end
