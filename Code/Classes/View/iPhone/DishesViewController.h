//
//  DishesViewController.h
//  meWaiter-ios
//
//  Created by omar megdadi on 21/10/13.
//  Copyright (c) 2013 [WE ARE] DEVELAPPERS. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "Section.h"
#import "Menu.h"

@interface DishesViewController : UIViewController <UITableViewDataSource, UITableViewDelegate,UISearchBarDelegate,UIScrollViewDelegate>
@property (nonatomic,strong) Section *section;
@property (nonatomic,strong) Menu *menu;
@property (nonatomic,strong) IBOutlet UITableView *tableView;
@property (nonatomic,strong) UISearchBar *dishesSearchbar ;

@end
