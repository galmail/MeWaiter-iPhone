//
//  Table.h
//  meWaiter-ios
//
//  Created by omar megdadi on 21/10/13.
//  Copyright (c) 2013 [WE ARE] DEVELAPPERS. All rights reserved.
//

#import <Foundation/Foundation.h>

@interface Table : NSObject
@property (nonatomic,assign) int tableId;
@property (nonatomic,strong) NSString *sid;
@property (nonatomic,assign) int tableNumber;
@property (nonatomic,assign) int floorId;

- (id) initWithDictionary: (NSDictionary *) dictionary;
- (NSString *) nameOfTable;
@end
