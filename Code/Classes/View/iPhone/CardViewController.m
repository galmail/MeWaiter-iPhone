//
//  CardViewController.m
//  meWaiter-ios
//
//  Created by omar megdadi on 15/10/13.
//  Copyright (c) 2013 [WE ARE] DEVELAPPERS. All rights reserved.
//

#import "CardViewController.h"
#import "UIViewController+MMDrawerController.h"
#import "MMDrawerBarButtonItem.h"
#import "Restaurant.h"
#import "Menu.h"
#import "SectionsViewController.h"
#import "HomeViewController.h"
#import "CoreService.h"
#import "CardCell.h"

@interface CardViewController ()

@end

@implementation CardViewController

- (id)initWithNibName:(NSString *)nibNameOrNil bundle:(NSBundle *)nibBundleOrNil
{
    self = [super initWithNibName:nibNameOrNil bundle:nibBundleOrNil];
    if (self) {
        // Custom initialization
    }
    return self;
}

- (void)viewDidLoad
{
    [super viewDidLoad];
    if (self.leftControllSelected) {
        [self setupLeftMenuButton];
    }
    
    UIBarButtonItem *anotherButton = [[UIBarButtonItem alloc] initWithImage:[UIImage imageNamed:@"list"] style:UIBarButtonItemStylePlain target:self action:@selector(goToBoardsAction)];
    self.navigationItem.rightBarButtonItem = anotherButton;
    // Do any additional setup after loading the view from its nib.
}

- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

#pragma mark - setup view

-(void)setupLeftMenuButton{
    MMDrawerBarButtonItem * leftDrawerButton = [[MMDrawerBarButtonItem alloc] initWithTarget:self action:@selector(leftDrawerButtonPress:)];
    [self.navigationItem setLeftBarButtonItem:leftDrawerButton animated:YES];
}

#pragma mark - Button Handlers
-(void)leftDrawerButtonPress:(id)sender{
    [self.mm_drawerController toggleDrawerSide:MMDrawerSideLeft animated:YES completion:nil];
}

#pragma mark - UITableViewDataSource methods

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section
{
    return [[[self restaurant] menus] count];
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath{
    static NSString *CellIdentifier = @"Cell";
    CardCell *cell;
    
    cell = [tableView dequeueReusableCellWithIdentifier:CellIdentifier];
    if (cell == nil) {
        NSArray* topLevelObjects = [[NSBundle mainBundle] loadNibNamed:@"CardCell" owner:self options:nil];
        for (id currentObject in topLevelObjects) {
            if ([currentObject isKindOfClass:[UITableViewCell class]]) {
                cell = (CardCell *)currentObject;
                break;
            }
        }
    }
    Menu *currentMenu=[[self restaurant] menus][indexPath.row];
    cell.cardTitle.text=[currentMenu name];
    return cell;
}

-(void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath
{
    Menu *currentMenu=[[self restaurant] menus][indexPath.row];
    SectionsViewController *sectionViewController=[[SectionsViewController alloc] init];
    sectionViewController.currentMenu=currentMenu;
    [self.navigationController pushViewController:sectionViewController animated:YES];
}

-(CGFloat)tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath{
    return 60;
}

-(void) goToBoardsAction
{
    UINavigationController *nav;
    BootstrapDB *dataBase=[[CoreService getInstance]db];
    
    HomeViewController * homeViewController = [[HomeViewController alloc] init];
    homeViewController.restaurant=[dataBase getRestaurant];
    homeViewController.floorsArray=[dataBase getFloorsArray];
    nav = [[UINavigationController alloc] initWithRootViewController:homeViewController];
    [[nav.navigationBar topItem ]setTitle:@"Pedido"];
    
    [self.mm_drawerController setCenterViewController:nav withCloseAnimation:YES completion:nil];
}

@end
