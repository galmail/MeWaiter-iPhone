//
//  CardViewController.h
//  meWaiter-ios
//
//  Created by omar megdadi on 15/10/13.
//  Copyright (c) 2013 [WE ARE] DEVELAPPERS. All rights reserved.
//

#import <UIKit/UIKit.h>
@class  Restaurant;
@interface CardViewController : UIViewController <UITableViewDataSource,UITableViewDelegate>
@property (nonatomic,assign) BOOL leftControllSelected;
@property (nonatomic,strong) Restaurant *restaurant;
@property (nonatomic,strong) IBOutlet UITableView *tableView;
@end
