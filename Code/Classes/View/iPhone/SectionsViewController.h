//
//  SectionsViewController.h
//  meWaiter-ios
//
//  Created by omar megdadi on 16/10/13.
//  Copyright (c) 2013 [WE ARE] DEVELAPPERS. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "Menu.h"

@interface SectionsViewController : UIViewController<UITableViewDataSource,UITableViewDelegate>
@property (nonatomic,strong) Menu *currentMenu;
@property (nonatomic,strong) NSMutableArray *subsections;
@property (nonatomic,strong) IBOutlet UITableView *tableView;

@end
