//
//  Payment.m
//  meWaiter-ios
//
//  Created by omar megdadi on 07/11/13.
//  Copyright (c) 2013 [WE ARE] DEVELAPPERS. All rights reserved.
//

#import "Payment.h"

@implementation Payment

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
    self.paymentId=[[dictionary objectForKey:@"id"] intValue];
    self.sid=[dictionary objectForKey:@"sid"];
    self.name=[dictionary objectForKey:@"name"];
    self.position=[[dictionary objectForKey:@"position"] intValue];
    self.key=[dictionary objectForKey:@"key"];
}
#pragma mark - NSCopying methods

- (id)copyWithZone:(NSZone *)zone{
    Payment *payment=[[Payment alloc]init];
    payment.name=[self.name copy];
    payment.sid=[self.sid copy];
    payment.paymentId=self.paymentId;
    payment.position=self.position;
    payment.key=[self.key copy];
    return payment;
}
@end
