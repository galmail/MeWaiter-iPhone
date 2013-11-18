//
//  SelectBoardViewController.h
//  meWaiter-ios
//
//  Created by omar megdadi on 23/10/13.
//  Copyright (c) 2013 [WE ARE] DEVELAPPERS. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface SelectBoardViewController : UIViewController<UIPickerViewDataSource,UIPickerViewDelegate,UITextFieldDelegate, UITableViewDataSource,UITableViewDelegate>


@property (strong, nonatomic) IBOutlet UIPickerView *sitePickerView;
@property (strong, nonatomic) IBOutlet UIPickerView *numberPickerView;

@property (strong, nonatomic) IBOutlet UITextField *paxTextField;

@property (strong, nonatomic) IBOutlet UISwitch *reservationSwitch;
@property (strong, nonatomic) IBOutlet UISwitch *firstTimeSwitch;

@property (strong, nonatomic) IBOutlet UIView *modalView;
@property (strong, nonatomic) IBOutlet UIView *littleViewModal;

@property (strong, nonatomic) IBOutlet UIControl *payView;
@property (strong, nonatomic) IBOutlet UIControl *littlePayView;

@property (strong, nonatomic) IBOutlet UITableView *payTable;
@property (strong, nonatomic) IBOutlet UITableView *discountTable;

@property (nonatomic,strong) NSMutableArray *floorsArray;
@property (strong, nonatomic) IBOutlet UILabel *totalLabel;
@property (strong, nonatomic) IBOutlet UILabel *tableLabel;


//// amountView
@property (strong, nonatomic) IBOutlet UIControl *amountView;
@property (strong, nonatomic) IBOutlet UIView *littleAmountView;
@property (strong, nonatomic) IBOutlet UITextField *payTextField;
@property (nonatomic,strong) IBOutlet  UITextField *payNoteTextField;

- (IBAction)SelectBoard:(UIButton *)button;
- (IBAction)openBoardAction:(id)sender;
- (IBAction)printBoardTicketAction:(id)sender;
- (IBAction)payTicketAction:(id)sender;
- (IBAction)BackModalAction:(id)sender;
- (IBAction)BackPayViewAction:(id)sender;
- (IBAction)dismissKeyboard:(id)sender;
- (IBAction)SelectTicketAction:(id)sender;
- (IBAction)amountAceptAction:(id)sender;
- (IBAction)amountCancelAction:(id)sender;


@end
