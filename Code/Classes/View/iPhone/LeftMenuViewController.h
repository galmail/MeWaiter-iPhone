//
//  LeftMenuViewController.h
//  meWaiter-ios
//
//  Created by omar megdadi on 09/10/13.
//  Copyright (c) 2013 [WE ARE] DEVELAPPERS. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "UIViewController+MMDrawerController.h"
@class Restaurant;
@class InfoApp;

@interface LeftMenuViewController : UIViewController<UITableViewDataSource,UITableViewDelegate>
@property (strong, nonatomic) IBOutlet UITableView *tableView;
@property (nonatomic,strong) Restaurant *restaurant;
@property (nonatomic,strong) NSMutableArray *floorsArray;
@property (nonatomic,strong) NSString *suggestionString;
@property (nonatomic,strong) InfoApp *info;

@end
