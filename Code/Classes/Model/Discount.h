//
//  Discount.h
//  meWaiter-ios
//
//  Created by omar megdadi on 06/11/13.
//  Copyright (c) 2013 [WE ARE] DEVELAPPERS. All rights reserved.
//

#import <Foundation/Foundation.h>
/*
 "sid": "67594c57-2c71-48f1-899a-0f1513e0d9ee",
 "name": "Promo 2x1 en Pastas",
 "dtype": "percentage",
 "amount": "50.0",
 "position": 1,
 "note": "Cupon Oportunista",
 "restaurant_id": 20
 "menu_id": 18
 "section_id": 76
 "dish_id": 329
 */
@interface Discount : NSObject
@property (nonatomic,strong) NSString *sid;
@property (nonatomic,strong) NSString *name;
@property (nonatomic,strong) NSString *dType;
@property (nonatomic,strong) NSString *amount;
@property (nonatomic,assign) int position;
@property (nonatomic,strong) NSString *note;
@property (nonatomic,assign) int restaurantId;
@property (nonatomic,assign) int menuId;
@property (nonatomic,assign) int sectionId;
@property (nonatomic,assign) int dishId;

- (id) initWithDictionary: (NSDictionary *) dictionary;
@end
