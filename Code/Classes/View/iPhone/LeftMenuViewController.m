//
//  LeftMenuViewController.m
//  meWaiter-ios
//
//  Created by omar megdadi on 09/10/13.
//  Copyright (c) 2013 [WE ARE] DEVELAPPERS. All rights reserved.
//

#import "LeftMenuViewController.h"
#import "HomeViewController.h"
#import "CardViewController.h"
#import "CheckViewController.h"
#import "SuggestionViewController.h"
#import "OrderToSendViewController.h"
#import "AboutTheAppViewController.h"
#import "Restaurant.h"
#import "InfoApp.h"
#import "Model.h"
#import "CoreService.h"
#import "BootstrapDB.h"
#import "Constants.h"

@interface LeftMenuViewController ()
@property (nonatomic,strong) NSArray *menuItemsArray;
@end

@implementation LeftMenuViewController

- (id)initWithNibName:(NSString *)nibNameOrNil bundle:(NSBundle *)nibBundleOrNil
{
    self = [super initWithNibName:nibNameOrNil bundle:nibBundleOrNil];
    if (self) {
        // Custom initialization
        self.menuItemsArray=@[@"Pedido",@"Carta",@"Mi Cuenta",@"Sugerencias",@"Pedidos por Enviar",@"Acerca de la App",@"Salir"];
    }
    return self;
}

- (void)viewDidLoad
{
    [super viewDidLoad];
    [self setupInterface];
    // Do any additional setup after loading the view from its nib.
}

- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

-(void) setupInterface
{
    self.tableView.backgroundColor=[UIColor colorWithRed:0.925 green:0.914 blue:0.894 alpha:1.000];
}

#pragma mark - UITableViewDataSource methods

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section
{
    NSLog(@"%i",[self.menuItemsArray count]);
    return [self.menuItemsArray count];
}

// Row display. Implementers should *always* try to reuse cells by setting each cell's reuseIdentifier and querying for available reusable cells with dequeueReusableCellWithIdentifier:
// Cell gets various attributes set automatically based on table (separators) and data source (accessory views, editing controls)

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath
{
    UITableViewCell * cell = [[UITableViewCell alloc]initWithStyle:UITableViewCellStyleDefault reuseIdentifier:@"Cell"];
    cell.textLabel.text=self.menuItemsArray[indexPath.row];
    cell.textLabel.font=[UIFont boldSystemFontOfSize:16];
    cell.textLabel.textColor=[UIColor blackColor];
    cell.backgroundColor=[UIColor colorWithRed:0.925 green:0.914 blue:0.894 alpha:1.000];
    return cell;
}

- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath {
	UINavigationController *nav;
    BootstrapDB *dataBase=[[CoreService getInstance]db];
    switch (indexPath.row) {
        case 0:{
            HomeViewController * homeViewController = [[HomeViewController alloc] init];
            homeViewController.restaurant=[dataBase getRestaurant];
            homeViewController.floorsArray=[dataBase getFloorsArray];
            nav = [[UINavigationController alloc] initWithRootViewController:homeViewController];
            [[nav.navigationBar topItem ]setTitle:@"Pedido"];
            if (![[[(UINavigationController *) [self.mm_drawerController centerViewController] viewControllers] objectAtIndex:0] isKindOfClass:[HomeViewController class]] || ![[[nav viewControllers] objectAtIndex:0] isKindOfClass:[HomeViewController class]]) {
                 [self.mm_drawerController setCenterViewController:nav withCloseAnimation:YES completion:nil];
            }
            break;
        }
            
        case 1: {
            CardViewController * cardViewController = [[CardViewController alloc] init];
            cardViewController.restaurant=[dataBase getRestaurant];
            cardViewController.leftControllSelected=YES;
            nav = [[UINavigationController alloc] initWithRootViewController:cardViewController];
            [[nav.navigationBar topItem ]setTitle:nav.title=@"Carta"];
            if (![[[(UINavigationController *) [self.mm_drawerController centerViewController] viewControllers] objectAtIndex:0] isKindOfClass:[CardViewController class]] || ![[[nav viewControllers] objectAtIndex:0] isKindOfClass:[CardViewController class]]) {
                [self.mm_drawerController setCenterViewController:nav withCloseAnimation:YES completion:nil];
            }
//            if ([[[Model getInstance]selectedTable]sid]) {
//                if (![[[(UINavigationController *) [self.mm_drawerController centerViewController] viewControllers] objectAtIndex:0] isKindOfClass:[CardViewController class]] || ![[[nav viewControllers] objectAtIndex:0] isKindOfClass:[CardViewController class]]) {
//                    [self.mm_drawerController setCenterViewController:nav withCloseAnimation:YES completion:nil];
//                }
//            }else{
//                [[[UIAlertView alloc]initWithTitle:@"No has elegido mesa" message:@"debes haber elegido una mesa a la que poder incluir articulos" delegate:nil cancelButtonTitle:@"Ok" otherButtonTitles: nil] show];
//            }
            break;
        }
            
        case 2: {
            CheckViewController * checkViewController = [[CheckViewController alloc] init];
            checkViewController.user=[dataBase getUser];
            nav = [[UINavigationController alloc] initWithRootViewController:checkViewController];
            [[nav.navigationBar topItem ]setTitle:@"Mi cuenta"];
            if (![[[(UINavigationController *) [self.mm_drawerController centerViewController] viewControllers] objectAtIndex:0] isKindOfClass:[CheckViewController class]] || ![[[nav viewControllers] objectAtIndex:0] isKindOfClass:[CheckViewController class]]) {
                [self.mm_drawerController setCenterViewController:nav withCloseAnimation:YES completion:nil];
            }
            break;
        }
        case 3: {
            SuggestionViewController * suggestionViewController = [[SuggestionViewController alloc] init];
            suggestionViewController.suggestionString=[[NSUserDefaults standardUserDefaults]objectForKey:KsugestionString];
            nav = [[UINavigationController alloc] initWithRootViewController:suggestionViewController];
            [[nav.navigationBar topItem ]setTitle:@"Sugerencias"];
            if (![[[(UINavigationController *) [self.mm_drawerController centerViewController] viewControllers] objectAtIndex:0] isKindOfClass:[SuggestionViewController class]] || ![[[nav viewControllers] objectAtIndex:0] isKindOfClass:[SuggestionViewController class]]) {
                [self.mm_drawerController setCenterViewController:nav withCloseAnimation:YES completion:nil];
            }
            break;
        }
            
        case 4: {
            OrderToSendViewController * orderToSendViewController = [[OrderToSendViewController alloc] init];
            nav = [[UINavigationController alloc] initWithRootViewController:orderToSendViewController];
            [[nav.navigationBar topItem ]setTitle:@"Pedido por enviar"];
            if (![[[(UINavigationController *) [self.mm_drawerController centerViewController] viewControllers] objectAtIndex:0] isKindOfClass:[OrderToSendViewController class]] || ![[[nav viewControllers] objectAtIndex:0] isKindOfClass:[OrderToSendViewController class]]) {
                [self.mm_drawerController setCenterViewController:nav withCloseAnimation:YES completion:nil];
            }
            break;
        }
        case 5: {
            AboutTheAppViewController * aboutViewController = [[AboutTheAppViewController alloc] init];
            aboutViewController.infoApp=[dataBase getInfo];
            nav = [[UINavigationController alloc] initWithRootViewController:aboutViewController];
            [[nav.navigationBar topItem ]setTitle:@"Acerca de la app"];
            if (![[[(UINavigationController *) [self.mm_drawerController centerViewController] viewControllers] objectAtIndex:0] isKindOfClass:[AboutTheAppViewController class]] || ![[[nav viewControllers] objectAtIndex:0] isKindOfClass:[AboutTheAppViewController class]]) {
                [self.mm_drawerController setCenterViewController:nav withCloseAnimation:YES completion:nil];
            }
            break;
        }
        case 6: {
            [self.mm_drawerController closeDrawerAnimated:YES completion:^(BOOL finished) {
                [[CoreService getInstance] logout];
            }];
            break;
        }
            
        default:
            break;
    }
    
    
    //////
	[self.mm_drawerController closeDrawerAnimated:YES completion:nil];// setCenterViewController:nav withCloseAnimation:YES completion:nil];
	
    [tableView selectRowAtIndexPath:indexPath animated:NO scrollPosition:UITableViewScrollPositionNone];
    [tableView deselectRowAtIndexPath:indexPath animated:YES];
}
@end
