//
//  DishesViewController.m
//  meWaiter-ios
//
//  Created by omar megdadi on 21/10/13.
//  Copyright (c) 2013 [WE ARE] DEVELAPPERS. All rights reserved.
//

#import "DishesViewController.h"
#import "Dish.h"
#import "PlateDetailViewController.h"
#import "UIViewController+MMDrawerController.h"
#import "HomeViewController.h"
#import "CoreService.h"
#import "CardCell.h"
#import "UIView+FrameUtils.h"

@interface DishesViewController ()

@end

NSMutableArray *datasourceArray;

@implementation DishesViewController

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
    self.navigationItem.title = self.section.name;
    self.dishesSearchbar = [[UISearchBar alloc] init];
    if (IS_IOS_7) {
        self.dishesSearchbar.frame=CGRectMake(0,64, 320, 44);
    }else{
        self.dishesSearchbar.frame=CGRectMake(0,0, 320, 44);
    }
    
    if ([self.menu.menuType isEqualToString:@"wines"]||[self.menu.menuType isEqualToString:@"beverages"]) {
        [[self tableView] frameMoveToY:44];
        [[self tableView]frameResizeByHeightDelta:-44];
        [[self view] addSubview:self.dishesSearchbar];
        self.dishesSearchbar.delegate=self;
        [self.dishesSearchbar setShowsCancelButton:YES];
    }
    datasourceArray=[[self section]dishes];
    //[[self tableView] setTableHeaderView:dishesSearchbar];
    UIBarButtonItem *anotherButton = [[UIBarButtonItem alloc] initWithImage:[UIImage imageNamed:@"list"] style:UIBarButtonItemStylePlain target:self action:@selector(goToBoardsAction)];
    self.navigationItem.rightBarButtonItem = anotherButton;
    UIButton *backButton = [[UIButton alloc] initWithFrame: CGRectMake(0, 0, 70.0f, 30.0f)];
    if (IS_IOS_7) {
        UIImage *backImage = [UIImage imageNamed:@"leftArrow"];
        
        [backButton setImage:backImage  forState:UIControlStateNormal];
        [backButton setTitle:@" Volver" forState:UIControlStateNormal];
        [backButton setTitleColor:[UIColor blueColor] forState:UIControlStateNormal];
        [backButton addTarget:self action:@selector(back:) forControlEvents:UIControlEventTouchUpInside];
    }else{
        UIImage *backImage = [[UIImage imageNamed:@"backButton"] resizableImageWithCapInsets: UIEdgeInsetsMake(0.0, 15.0, 0.0, 5.0)];
        
        [backButton setBackgroundImage:backImage  forState:UIControlStateNormal];
        [backButton setTitle:@"  Volver" forState:UIControlStateNormal];
        [backButton setTitleColor:[UIColor whiteColor] forState:UIControlStateNormal];
        [backButton addTarget:self action:@selector(back:) forControlEvents:UIControlEventTouchUpInside];
    }
    
    UIBarButtonItem *backButtonItem = [[UIBarButtonItem alloc] initWithCustomView:backButton];
    
    self.navigationItem.leftBarButtonItem=backButtonItem;
}

-(void) back:(id)sender
{
    [self.navigationController popViewControllerAnimated:YES];
}

- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

#pragma mark -UITableViewDataSource methods

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section
{
    return [datasourceArray count];
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath
{
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
    
    Dish *currentDish=datasourceArray[indexPath.row];
    cell.cardTitle.text=[currentDish name];
    return cell;
}

-(CGFloat)tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath{
    return 60;
}

-(void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath
{
    Dish *currentDish=datasourceArray[indexPath.row];
    PlateDetailViewController *plateDetailViewController=[[PlateDetailViewController alloc] init];
    plateDetailViewController.dish=currentDish;
    plateDetailViewController.section= self.section;
    [self.navigationController pushViewController:plateDetailViewController animated:YES];
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

#pragma mark - Search methods
-(void)searchBarCancelButtonClicked:(UISearchBar *)searchBar
{
    datasourceArray=[[self section]dishes];
    self.dishesSearchbar.text=@"";
    [self.tableView reloadData];
    [self.dishesSearchbar resignFirstResponder];
}

-(void)searchDisplayControllerDidEndSearch:(UISearchDisplayController *)controller{
    [self.dishesSearchbar resignFirstResponder];
}

-(void) searchBar:(UISearchBar *)searchBar textDidChange:(NSString *)searchText {
    if ([searchText length] <= 1) {
        datasourceArray=[[self section]dishes];
    } else {
        NSPredicate *predicate = [NSPredicate predicateWithFormat:@"SELF.name contains[c] %@",searchText];
        datasourceArray = [NSMutableArray arrayWithArray:[[[self section]dishes] filteredArrayUsingPredicate:predicate]];
    }
    [[self tableView] reloadData];
}

- (void)searchBarSearchButtonClicked:(UISearchBar *)searchBar
{
    [searchBar resignFirstResponder];
    // Do the search...
}

#pragma mark - UIScrollViewDelegate

- (void)scrollViewWillBeginDragging:(UIScrollView *)scrollView{
    [self.dishesSearchbar resignFirstResponder];
}

@end
