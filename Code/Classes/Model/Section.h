//
//  Section.h
//  meWaiter-ios
//
//  Created by omar megdadi on 16/10/13.
//  Copyright (c) 2013 [WE ARE] DEVELAPPERS. All rights reserved.
//

#import <Foundation/Foundation.h>

@interface Section : NSObject

@property (nonatomic,assign) int sectionId;
@property (nonatomic,strong) NSString *sid;
@property (nonatomic,strong) NSString *name;
@property (nonatomic,strong) NSString *mini;
@property (nonatomic,strong) NSString *thumbnail;
@property (nonatomic,strong) NSMutableArray *dishes;
@property (nonatomic,strong) NSMutableArray *subsections;

- (id) initWithDictionary: (NSDictionary *) dictionary;

@end
