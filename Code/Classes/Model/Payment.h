//
//  Payment.h
//  meWaiter-ios
//
//  Created by omar megdadi on 07/11/13.
//  Copyright (c) 2013 [WE ARE] DEVELAPPERS. All rights reserved.
//

#import <Foundation/Foundation.h>

@interface Payment : NSObject <NSCopying>
/*
 "id": 3,
 "sid": "8fc5532e-4fc9-46ba-92aa-2ded5caef763",
 "name": "Efectivo",
 "position": 1,
 "key": "cash"
*/
@property (nonatomic,assign) int paymentId;
@property (nonatomic,strong) NSString *sid;
@property (nonatomic,strong) NSString *name;
@property (nonatomic,assign) int position;
@property (nonatomic,strong) NSString *key;
@property (nonatomic,strong) NSString *amount;
@property (nonatomic,strong) NSString *note;

- (id) initWithDictionary: (NSDictionary *) dictionary;

@end
