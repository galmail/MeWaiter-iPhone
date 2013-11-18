//
//  CheckViewController.h
//  meWaiter-ios
//
//  Created by omar megdadi on 15/10/13.
//  Copyright (c) 2013 [WE ARE] DEVELAPPERS. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "User.h"

@interface CheckViewController : UIViewController
@property (nonatomic,strong) User *user;
@property (strong, nonatomic) IBOutlet UILabel *lastUpdateLabel;
- (IBAction)refreshAction:(id)sender;
@end
