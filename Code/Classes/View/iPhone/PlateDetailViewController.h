//
//  PlateDetailViewController.h
//  meWaiter-ios
//
//  Created by omar megdadi on 21/10/13.
//  Copyright (c) 2013 [WE ARE] DEVELAPPERS. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "Section.h"
@class Dish;

@interface PlateDetailViewController : UIViewController<UITextViewDelegate, UITableViewDataSource, UITableViewDelegate>
@property (nonatomic,strong) Dish *dish;
@property (nonatomic,strong) Section *section;
@property (strong, nonatomic) IBOutlet UILabel *mandatoryLabel;
@property (strong, nonatomic) IBOutlet UIButton *addToOrderButton;
@property (strong, nonatomic) IBOutlet UIButton *addToBoardButton;
@property (strong, nonatomic) IBOutlet UILabel *unitsLabel;
@property (strong, nonatomic) IBOutlet UITextView *detailTextView;
@property (nonatomic,strong) IBOutlet UITableView *tableView;
@property (strong, nonatomic) IBOutlet UIButton *okButton;
@property (strong, nonatomic) IBOutlet UIButton *addNoteButton;
@property (strong, nonatomic) IBOutlet UIView *addNoteView;
- (IBAction)okAction:(UIButton *)sender;
- (IBAction)numberOfUnitsChange:(UIStepper *)stepper;
- (IBAction)dismissKeyboard:(id)sender;
- (IBAction)sendToPosAction:(id)sender;
- (IBAction)noteAction:(UIButton *)sender;
@end
