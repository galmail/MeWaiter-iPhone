//
//  AppDelegate.m
//  bootstrap-ios
//
//  Created by Marcos Pinazo on 4/6/13.
//  Copyright (c) 2013 [WE ARE] DEVELAPPERS. All rights reserved.
//

#import "AppDelegate.h"

#import "Constants.h"
#import "TestFlight.h"
#import "CoreService.h"
#import "ModalManager.h"
#import "Restaurant.h"
#import "Floor.h"
#import "InfoApp.h"
#import "LeftMenuViewController.h"
#import "MMExampleDrawerVisualStateManager.h"


@implementation AppDelegate

- (BOOL)application:(UIApplication *)application didFinishLaunchingWithOptions:(NSDictionary *)launchOptions
{
    #ifndef PRODUCTION
    [TestFlight takeOff:@"18a3ed15-2f56-4ffb-bccd-efc2c34e6c52"];
    [TestFlight passCheckpoint:[NSString stringWithFormat:@"Loading %@", APP_NAME]];
    #endif
    
    self.window = [[UIWindow alloc] initWithFrame:[[UIScreen mainScreen] bounds]];
    self.window.backgroundColor = [UIColor whiteColor];
    
    self.loadingViewController = [[LoadingViewController alloc] initWithNibName:@"LoadingViewController" bundle:nil];
    self.loginViewController = [[LoginViewController alloc] initWithNibName:@"LoginViewController" bundle:nil];
    
    self.mainNavigationController = [[UINavigationController alloc] initWithRootViewController:self.loadingViewController];
    self.window.rootViewController = self.mainNavigationController;
    [self.window makeKeyAndVisible];
    
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(onReadyToShowHome:) name:kServiceReadyToShowHome object:nil];
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(onInitializationError:) name:kServiceInitializationError object:nil];
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(onLogout:) name:kServiceLogout object:nil];
    
    [[CoreService getInstance] initApplication];
    
    return YES;
}

- (void)onReadyToShowHome:(NSNotification *)event
{
    BOOL userLogged = [[event.userInfo objectForKey:@"userLogged"] boolValue];
    if (userLogged) {
        [self prepareDrawerController];
        [self.mainNavigationController pushViewController:self.drawerController animated:NO];
    } else {
        [self.mainNavigationController pushViewController:self.loginViewController animated:NO];
    }
}

- (void)onLogout:(NSNotification *)event
{
    [self.mainNavigationController popToRootViewControllerAnimated:NO];
    self.loadingViewController = [[LoadingViewController alloc] initWithNibName:@"LoadingViewController" bundle:nil];
    self.loginViewController = [[LoginViewController alloc] initWithNibName:@"LoginViewController" bundle:nil];
    self.homeViewController = [[HomeViewController alloc] initWithNibName:@"HomeViewController" bundle:nil];
    
    [[NSNotificationCenter defaultCenter] postNotificationName:kServiceReadyToShowHome object:nil userInfo:[NSDictionary dictionaryWithObject:[NSNumber numberWithBool:NO] forKey:@"userLogged"]];
}

- (void)onInitializationError:(NSNotification *)event
{
    [[NSNotificationCenter defaultCenter] removeObserver:self name:kServiceInitializationError object:nil];
    
    /*
    BaseModalView *modal = [[BaseModalView alloc] initWithParent:self.loadingViewController
                                                 backgroundColor:[UIColor whiteColor]
                                                       textColor:[CommonUtil darkerColorForColor:COLOR_BASE delta:COLOR_DELTA]
                                                           title:[L18N get:@"modal.loadingerror.title"]
                                                         message:[L18N get:@"modal.loadingerror.message"]
                                                    actionButton:[L18N get:@"modal.loadingerror.close"]
                                             actionButtonHandler:^{
                                                 [self tryAgain];
                                             }
                                                     closeButton:nil];
    [[ModalManager getInstance] pushAndShow:modal];
    */
}

- (void)tryAgain
{
    [[ModalManager getInstance] hideTopWithCompletionHandler:^{
        [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(onInitializationError:) name:kServiceInitializationError object:nil];
        [[CoreService getInstance] initApplication];
    }];
}

- (void)applicationWillResignActive:(UIApplication *)application
{
    // Nothing to do.
}

- (void)applicationDidEnterBackground:(UIApplication *)application
{
    // Nothing to do.
}

- (void)applicationWillEnterForeground:(UIApplication *)application
{
    // Nothing to do.
}

- (void)applicationDidBecomeActive:(UIApplication *)application
{
    // Nothing to do.
}

- (void)applicationWillTerminate:(UIApplication *)application
{
    // Nothing to do.
}

- (void)prepareDrawerController{
    CoreService *coreService=[CoreService getInstance];
    
    LeftMenuViewController * leftSideDrawerViewController = [[LeftMenuViewController alloc] initWithNibName:@"LeftMenuViewController" bundle:nil];
    leftSideDrawerViewController.restaurant=[[coreService db] getRestaurant];
    [[coreService posApi] setPosIdAddres:leftSideDrawerViewController.restaurant.posIpAddress];
    leftSideDrawerViewController.floorsArray=[[coreService db]getFloorsArray];
    leftSideDrawerViewController.suggestionString=[[NSUserDefaults standardUserDefaults] objectForKey:KsugestionString];
    leftSideDrawerViewController.info=[[coreService db]getInfo];
    
    HomeViewController * centerViewController = [[HomeViewController alloc] initWithNibName:@"HomeViewController" bundle:nil];
    centerViewController.restaurant=[[coreService db] getRestaurant];
    centerViewController.floorsArray=[[coreService db]getFloorsArray];
    
    UINavigationController * navigationController = [[UINavigationController alloc] initWithRootViewController:centerViewController];
    [navigationController setRestorationIdentifier:@"MMExampleCenterNavigationControllerRestorationKey"];
    [[navigationController.navigationBar topItem ]setTitle:@"Pedido"];
    if(OSVersionIsAtLeastiOS7()){
        UINavigationController * leftSideNavController = [[UINavigationController alloc] initWithRootViewController:leftSideDrawerViewController];
        [leftSideNavController.navigationBar setTranslucent:YES];
        [leftSideNavController.navigationBar setBarTintColor:[UIColor darkGrayColor]];
        [[leftSideNavController.navigationBar topItem ]setTitle:@"Opciones"];
		[leftSideNavController setRestorationIdentifier:@"MMExampleLeftNavigationControllerRestorationKey"];
        self.drawerController = [[MMDrawerController alloc]
                                 initWithCenterViewController:navigationController
                                 leftDrawerViewController:leftSideNavController
                                 rightDrawerViewController:nil];
        [self.drawerController setShowsShadow:NO];
    }
    else{
        self.drawerController = [[MMDrawerController alloc]
                                 initWithCenterViewController:navigationController
                                 leftDrawerViewController:leftSideDrawerViewController
                                 rightDrawerViewController:nil];
    }
    [self.drawerController setRestorationIdentifier:@"MMDrawer"];
    [self.drawerController setMaximumLeftDrawerWidth:200.0];
    [self.drawerController setOpenDrawerGestureModeMask:MMOpenDrawerGestureModeAll];
    [self.drawerController setCloseDrawerGestureModeMask:MMCloseDrawerGestureModeAll];
    
    [self.drawerController
     setDrawerVisualStateBlock:^(MMDrawerController *drawerController, MMDrawerSide drawerSide, CGFloat percentVisible) {
         MMDrawerControllerDrawerVisualStateBlock block;
         block = [[MMExampleDrawerVisualStateManager sharedManager]
                  drawerVisualStateBlockForDrawerSide:drawerSide];
         if(block){
             block(drawerController, drawerSide, percentVisible);
         }
     }];
}

@end
