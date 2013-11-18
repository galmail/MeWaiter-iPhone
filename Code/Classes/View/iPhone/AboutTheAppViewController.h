//
//  AboutTheAppViewController.h
//  meWaiter-ios
//
//  Created by omar megdadi on 15/10/13.
//  Copyright (c) 2013 [WE ARE] DEVELAPPERS. All rights reserved.
//

#import <UIKit/UIKit.h>
@class  InfoApp;

@interface AboutTheAppViewController : UIViewController
@property (nonatomic,strong) InfoApp *infoApp;
@property (strong, nonatomic) IBOutlet UILabel *nameLabel;
@property (strong, nonatomic) IBOutlet UILabel *versionLabel;
@property (strong, nonatomic) IBOutlet UILabel *osLabel;
@property (strong, nonatomic) IBOutlet UILabel *whatsNewLabel;
@property (strong, nonatomic) IBOutlet UIScrollView *scrollView;
@end
