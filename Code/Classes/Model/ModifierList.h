//
//  ModifierList.h
//  meWaiter-ios
//
//  Created by omar megdadi on 28/10/13.
//  Copyright (c) 2013 [WE ARE] DEVELAPPERS. All rights reserved.
//

#import <Foundation/Foundation.h>

@interface ModifierList : NSObject
@property (nonatomic,assign) int modiferListId;
@property (nonatomic,strong) NSString *sid;
@property (nonatomic,strong) NSString *name;
@property (nonatomic,strong) NSString *isMandatory;
@property (nonatomic,strong) NSString *isMultioption;
@property (nonatomic,strong) NSString *selectedModiefierSid;
@property (nonatomic,strong) NSMutableArray *modifiers;

- (id) initWithDictionary: (NSDictionary *) dictionary;
@end
