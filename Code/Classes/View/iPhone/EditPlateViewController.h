//
//  EditPlateViewController.h
//  meWaiter-ios
//
//  Created by omar megdadi on 30/10/13.
//  Copyright (c) 2013 [WE ARE] DEVELAPPERS. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "Dish.h"
#import "Section.h"
#import "Order.h"

@interface EditPlateViewController : UIViewController<UITextViewDelegate,UITableViewDelegate,UITableViewDataSource,UIScrollViewDelegate>
@property (nonatomic,strong) Dish *dish;
@property (nonatomic,strong) Section *section;
@property (nonatomic,strong) Order *order;
@property (strong, nonatomic) IBOutlet UIButton *changeButton;
@property (nonatomic,strong) IBOutlet UIStepper *stepper;
@property (strong, nonatomic) IBOutlet UILabel *unitsLabel;
@property (strong, nonatomic) IBOutlet UITextView *detailTextView;
@property (nonatomic,strong) IBOutlet UITableView *tableView;

@property (strong, nonatomic) IBOutlet UIButton *okButton;
@property (strong, nonatomic) IBOutlet UIButton *addNoteButton;
@property (strong, nonatomic) IBOutlet UIView *addNoteView;

- (IBAction)okAction:(UIButton *)sender;
- (IBAction)numberOfUnitsChange:(UIStepper *)stepper;
- (IBAction)dismissKeyboard:(id)sender;
- (IBAction)noteAction:(UIButton *)sender;
- (IBAction)editPlateAction:(id)sender;
@end
