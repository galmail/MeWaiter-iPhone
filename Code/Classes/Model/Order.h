//
//  Order.h
//  meWaiter-ios
//
//  Created by omar megdadi on 29/10/13.
//  Copyright (c) 2013 [WE ARE] DEVELAPPERS. All rights reserved.
//

#import <Foundation/Foundation.h>

@interface Order : NSObject
//(sid TEXT, product_name TEXT, category_sid TEXT, status INTEGER, note TEXT, price TEXT, quantity INTEGER, id INTEGER PRIMARY KEY, id_table INTEGER)
@property (nonatomic,strong) NSString *sid;
@property (nonatomic,strong) NSString *productName;
@property (nonatomic,strong) NSString *categorySid;
@property (nonatomic,assign) int status;
@property (nonatomic,strong) NSString *note;
@property (nonatomic,strong) NSString *price;
@property (nonatomic,assign) int quantity;
@property (nonatomic,assign) int orderId;
@property (nonatomic,assign) int tableId;

@end
