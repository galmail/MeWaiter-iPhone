//
//  AppDelegate.h
//  bootstrap-ios
//
//  Created by Marcos Pinazo on 4/6/13.
//  Copyright (c) 2013 [WE ARE] DEVELAPPERS. All rights reserved.
//

#import <UIKit/UIKit.h>

#import "LoadingViewController.h"
#import "LoginViewController.h"
#import "HomeViewController.h"
#import "MMDrawerController.h"

@interface AppDelegate : UIResponder <UIApplicationDelegate>

@property (strong, nonatomic) UIWindow *window;
@property (strong, nonatomic) UINavigationController *mainNavigationController;
@property (strong, nonatomic) LoadingViewController *loadingViewController;
@property (strong, nonatomic) LoginViewController *loginViewController;
@property (strong, nonatomic) HomeViewController *homeViewController;
@property (nonatomic,strong) MMDrawerController *drawerController;

@end
