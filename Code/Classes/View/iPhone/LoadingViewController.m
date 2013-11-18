//
//  LoadingViewController.m
//  bootstrap-ios
//
//  Created by Marcos Pinazo on 2/6/13.
//  Copyright (c) 2013 [WE ARE] DEVELAPPERS. All rights reserved.
//

#import "LoadingViewController.h"

#import "CoreService.h"
#import "NSTimer+Blocks.h"

@interface LoadingViewController ()

@end

@implementation LoadingViewController

- (id)initWithNibName:(NSString *)nibNameOrNil bundle:(NSBundle *)nibBundleOrNil
{
    self = [super initWithNibName:nibNameOrNil bundle:nibBundleOrNil];
    if (self) {
        
    }
    return self;
}

- (void)viewDidLoad
{
    [super viewDidLoad];
}

- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
}

- (void)viewWillAppear:(BOOL)animated
{
    [super viewWillAppear:animated];

    [self.navigationController setNavigationBarHidden:YES];
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(onInitializationSuccess:) name:kServiceInitializationSuccess object:nil];
}

- (void)viewWillDisappear:(BOOL)animated
{
    [super viewWillDisappear:animated];
    
    [[NSNotificationCenter defaultCenter] removeObserver:self];
}

- (void)onInitializationSuccess:(NSNotification *)event
{
    [[NSNotificationCenter defaultCenter] postNotificationName:kServiceReadyToShowHome object:nil userInfo:event.userInfo];
}

@end
