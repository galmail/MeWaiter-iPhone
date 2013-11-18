//
//  SuggestionViewController.h
//  meWaiter-ios
//
//  Created by omar megdadi on 15/10/13.
//  Copyright (c) 2013 [WE ARE] DEVELAPPERS. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface SuggestionViewController : UIViewController
@property (nonatomic,strong) NSString *suggestionString;
@property (strong, nonatomic) IBOutlet UILabel *suggestionLabel;
@property (strong, nonatomic) IBOutlet UILabel *lastUpdateLabel;
@property (strong, nonatomic) IBOutlet UIScrollView *scrollview;
- (IBAction)UpdateAction:(id)sender;

@end
