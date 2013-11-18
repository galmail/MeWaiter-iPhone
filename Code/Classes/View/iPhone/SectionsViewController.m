//
//  SectionsViewController.m
//  meWaiter-ios
//
//  Created by omar megdadi on 16/10/13.
//  Copyright (c) 2013 [WE ARE] DEVELAPPERS. All rights reserved.
//

#import "SectionsViewController.h"
#import "Section.h"
#import "DishesViewController.h"
#import "HomeViewController.h"
#import "CoreService.h"
#import "UIViewController+MMDrawerController.h"
#import "CardCell.h"
#import "PlateDetailViewController.h"
#import "UIView+FrameUtils.h"

@interface SectionsViewController ()

@end

NSMutableArray *DataSourceArray;

@implementation SectionsViewController

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
    self.navigationItem.title = self.currentMenu.name;
    // Do any additional setup after loading the view from its nib.
    
    UIBarButtonItem *anotherButton = [[UIBarButtonItem alloc] initWithImage:[UIImage imageNamed:@"list"] style:UIBarButtonItemStylePlain target:self action:@selector(goToBoardsAction)];
    
    self.navigationItem.rightBarButtonItem = anotherButton;
    if (self.currentMenu.price &&![self.currentMenu.price isEqualToString:@"<null>"]) {
        UIButton *addMenuButton=[UIButton buttonWithType:UIButtonTypeCustom];
        if (IS_IOS_7) {
            addMenuButton.frame=CGRectMake(0,64, 320, 44);
        }else{
            addMenuButton.frame=CGRectMake(0,0, 320, 44);
        }
        [addMenuButton setTitle:[NSString stringWithFormat:@"Agregar %@",self.currentMenu.name] forState:UIControlStateNormal];
        [addMenuButton addTarget:self action:@selector(jumpToDetail:) forControlEvents:UIControlEventTouchUpInside];
        [addMenuButton setBackgroundColor:[UIColor colorWithRed:0.549 green:0.776 blue:0.247 alpha:1.000] ];
        [addMenuButton setTitleColor:[UIColor whiteColor] forState:UIControlStateNormal];
        
        [self.view addSubview:addMenuButton];
        [self.tableView frameMoveByYDelta:44];
        [self.tableView frameResizeByHeightDelta:-44];
                                 
    }
    
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

-(void)viewWillAppear:(BOOL)animated{
    DataSourceArray=[[NSMutableArray alloc]init];
    if (self.currentMenu) {
        DataSourceArray=[self.currentMenu sections];
    }else{
        DataSourceArray=[self subsections];
    }
}

-(void)viewDidAppear:(BOOL)animated{
    [super viewDidAppear:animated];
    NSLog(@"%@",self.navigationItem.backBarButtonItem.title);
}

- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

#pragma mark - UITableViewDataSource methods

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section
{
    return [DataSourceArray count];
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
    Section *currentSection=DataSourceArray[indexPath.row];
    cell.cardTitle.text=[currentSection name];
    return cell;
}

-(CGFloat)tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath{
    return 60;
}

-(void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath
{
    Section *currentSection=DataSourceArray[indexPath.row];
    if ([currentSection.dishes count]!=0) {
        DishesViewController *dishesViewController=[[DishesViewController alloc] init];
        dishesViewController.section=currentSection;
        dishesViewController.menu=self.currentMenu;
        [self.navigationController pushViewController:dishesViewController animated:YES];
    }else if ([currentSection.subsections count]!=0){
        SectionsViewController *subsectionViewController=[[SectionsViewController alloc]init];
        subsectionViewController.subsections=[currentSection subsections];
        [self.navigationController pushViewController:subsectionViewController animated:YES];
    }else{
//        [[[UIAlertView alloc]initWithTitle:@"Noy hay platos" message:@"El servidor no devuelve ni subseciones ni platos para esta sección" delegate:nil cancelButtonTitle:@"Volver" otherButtonTitles: nil] show];
        DishesViewController *dishesViewController=[[DishesViewController alloc] init];
        dishesViewController.section=currentSection;
        dishesViewController.menu=self.currentMenu;
        [self.navigationController pushViewController:dishesViewController animated:YES];
        
    }
    

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

-(void)jumpToDetail:(id) sender
{
    Dish *currentDish=[[Dish alloc]init];
    currentDish.sid=self.currentMenu.sid;
    currentDish.name=self.currentMenu.name;
    currentDish.price=self.currentMenu.price;
    PlateDetailViewController *plateDetailViewController=[[PlateDetailViewController alloc] init];
    plateDetailViewController.dish=currentDish;
    Section *section=[[Section alloc] init];
    section.sid=self.currentMenu.sid;
    plateDetailViewController.section=section;
    [self.navigationController pushViewController:plateDetailViewController animated:YES];
}

@end
