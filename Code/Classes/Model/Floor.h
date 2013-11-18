//
//  Floor.h
//  meWaiter-ios
//
//  Created by omar megdadi on 21/10/13.
//  Copyright (c) 2013 [WE ARE] DEVELAPPERS. All rights reserved.
//

#import <Foundation/Foundation.h>

@interface Floor : NSObject
@property (nonatomic,assign) int floorId;
@property (nonatomic,strong) NSString *sid;
@property (nonatomic,strong) NSString *name;
@property (nonatomic,strong) NSMutableArray *tables;

- (id) initWithDictionary: (NSDictionary *) dictionary;

@end
