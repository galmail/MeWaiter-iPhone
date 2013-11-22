//
//  HomeViewController.h
//  bootstrap-ios
//
//  Created by Marcos Pinazo on 2/6/13.
//  Copyright (c) 2013 [WE ARE] DEVELAPPERS. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "Floor.h"
#import "Table.h"
@class Restaurant;

@interface HomeViewController : UIViewController<UITableViewDataSource,UITableViewDelegate>

@property (nonatomic,strong) IBOutlet UITableView *tableView;

@property (strong, nonatomic) IBOutlet UITextField *dinersTextField;

@property (strong, nonatomic) IBOutlet UIButton *selectTableButton;
@property (strong, nonatomic) IBOutlet UIButton *deleteButton;
@property (strong, nonatomic) IBOutlet UIButton *sendButton;
@property (strong, nonatomic) IBOutlet UIButton *cardButton;
@property (strong, nonatomic) IBOutlet UIButton *ticketButton;
@property (strong, nonatomic) IBOutlet UIButton *secondsButton;



@property (strong, nonatomic) IBOutlet UILabel *TableLabel;

@property (nonatomic,strong) Restaurant *restaurant;
@property (nonatomic,strong) NSMutableArray *floorsArray;

//@property (nonatomic,assign) int floorNumber;
//@property (nonatomic,assign) int TableNumber;
@property (nonatomic,strong) Floor *currentFloor;
@property (nonatomic,strong) Table *currentTable;

- (IBAction)SelectTableAction:(UIButton*)button;
- (IBAction)deleteAllAction:(id)sender;
- (IBAction)secondAction:(id)sender;
- (IBAction)printTicketAction:(id)sender;


@end
