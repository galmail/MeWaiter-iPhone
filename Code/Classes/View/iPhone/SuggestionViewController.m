//
//  SuggestionViewController.m
//  meWaiter-ios
//
//  Created by omar megdadi on 15/10/13.
//  Copyright (c) 2013 [WE ARE] DEVELAPPERS. All rights reserved.
//

#import "SuggestionViewController.h"
#import "MMDrawerBarButtonItem.h"
#import "UIViewController+MMDrawerController.h"
#import "CoreService.h"
#import "Constants.h"
#import "MBProgressHUD.h"

@interface SuggestionViewController ()
@property (nonatomic,strong) MBProgressHUD *hud;

@end

@implementation SuggestionViewController

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
    [self setupLeftMenuButton];
    self.suggestionLabel.text=[[NSUserDefaults standardUserDefaults]objectForKey:KsugestionString];
    [self.suggestionLabel sizeToFit];
    [self.scrollview setContentSize:CGSizeMake(320, self.suggestionLabel.frame.origin.y+self.suggestionLabel.frame.size.height+30)];
    self.lastUpdateLabel.text=[NSString stringWithFormat:@"Última actualización:\n %@",[[[CoreService getInstance]db] getConfigWithName:SETTINGS_LAST_SUGGESTION_UPDATE]];
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

- (IBAction)UpdateAction:(id)sender {
    CoreService *coreService=[CoreService getInstance];
    BootstrapDB *dataBase=[coreService db];
    self.hud= [MBProgressHUD showHUDAddedTo:self.view animated:YES];
    self.hud.mode = MBProgressHUDModeIndeterminate;
    self.hud.labelText = @"actualizando...";
    [coreService getSuggestionsWithKey:[[dataBase getUser] mwKey] succes:^(NSMutableDictionary *json) {
        [self hudMessageWithTitle:@"Actualizado" andDelay:1];
        NSString *suggestionString=[json objectForKey:@"suggestions"];
        self.suggestionLabel.text=[[NSUserDefaults standardUserDefaults]objectForKey:KsugestionString];
        [coreService setLastUpdateSuggestion];
        self.lastUpdateLabel.text=[NSString stringWithFormat:@"Última actualización:\n %@",[dataBase getConfigWithName:SETTINGS_LAST_SUGGESTION_UPDATE]];
        [self.suggestionLabel sizeToFit];
        [self.scrollview setContentSize:CGSizeMake(320, self.suggestionLabel.frame.origin.y+self.suggestionLabel.frame.size.height+30)];
        [[NSUserDefaults standardUserDefaults] setObject:suggestionString forKey:KsugestionString];
    } failure:^(NSMutableDictionary *json) {
        [self hudMessageWithTitle:@"Error en las Recomendaciones" andDelay:1];
    }];
}

-(void) hudMessageWithTitle:(NSString *) title andDelay:(NSTimeInterval) delay{
    self.hud.labelText = title;
    self.hud.mode=MBProgressHUDModeCustomView;
    self.hud.customView=nil;
    [self.hud hide:YES afterDelay:delay];
}
@end
