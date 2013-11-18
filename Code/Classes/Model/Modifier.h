//
//  Modifier.h
//  meWaiter-ios
//
//  Created by omar megdadi on 28/10/13.
//  Copyright (c) 2013 [WE ARE] DEVELAPPERS. All rights reserved.
//

#import <Foundation/Foundation.h>

@interface Modifier : NSObject
@property (nonatomic,assign) int modiferId;
@property (nonatomic,strong) NSString *sid;
@property (nonatomic,strong) NSString *name;
@property (nonatomic,strong) NSString *sdModifierid;
@property (nonatomic,strong) NSString *modifierDescription;
@property (nonatomic,strong) NSString *price;

- (id) initWithDictionary: (NSDictionary *) dictionary;
@end
