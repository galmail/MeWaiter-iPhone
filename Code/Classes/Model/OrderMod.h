//
//  OrderMod.h
//  meWaiter-ios
//
//  Created by omar megdadi on 06/11/13.
//  Copyright (c) 2013 [WE ARE] DEVELAPPERS. All rights reserved.
//

#import <Foundation/Foundation.h>

@interface OrderMod : NSObject
@property (nonatomic,assign) int orderId;
@property (nonatomic,strong) NSString *mlSetSid;
@property (nonatomic,strong) NSString *mlistSid;
@property (nonatomic,strong) NSString *modifierSid;
@property (nonatomic,strong) NSString *value;
@end
