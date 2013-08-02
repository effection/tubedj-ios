//
//  JHClientViewController.m
//  tubedj
//
//  Created by Jordan Hamill on 01/08/2013.
//  Copyright (c) 2013 Jordan Hamill. All rights reserved.
//

#import "JHAppDelegate.h"
#import "JHClientViewController.h"
#import "JHYoutubeSongCell.h"
#import "JHYouTubeSearchViewController.h"
#import "JHPlaylistViewController.h"
#import "RESideMenu.h"
#import "JHQRCodeViewController.h"

@interface JHClientViewController ()
@property (strong, nonatomic) JHYouTubeSearchViewController *youtubeSearchController;
@property (strong, nonatomic) JHPlaylistViewController *playlistController;

@end

@implementation JHClientViewController

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
	
	//Navigation items
	
	UIButton *button = [[UIButton alloc] initWithFrame:CGRectMake(0, 0, 40, 50)];
	[button setTitle:[JHFontAwesome standardIcon:FontAwesome_Reorder] forState:UIControlStateNormal];
	[button setTitleColor:[UIColor app_blue] forState:UIControlStateNormal];
	button.titleLabel.font = [UIFont fontAwesomeWithSize:28.0];
	[button addTarget:self action:@selector(showMenu) forControlEvents:UIControlEventTouchUpInside];
	
	UIBarButtonItem *customItem = [[UIBarButtonItem alloc] initWithCustomView:button];
	self.navigationController.visibleViewController.navigationItem.leftBarButtonItem = customItem;
	
	//QR Code button
	
	UIButton *qrbutton = [[UIButton alloc] initWithFrame:CGRectMake(0, 0, 40, 50)];
	[qrbutton setTitle:[JHFontAwesome standardIcon:FontAwesome_QR] forState:UIControlStateNormal];
	[qrbutton setTitleColor:[UIColor app_blue] forState:UIControlStateNormal];
	qrbutton.titleLabel.font = [UIFont fontAwesomeWithSize:28.0];
	[qrbutton addTarget:self action:@selector(showQRCode) forControlEvents:UIControlEventTouchUpInside];
	
	UIBarButtonItem *qrBarButton = [[UIBarButtonItem alloc] initWithCustomView:qrbutton];
	self.navigationController.visibleViewController.navigationItem.rightBarButtonItem = qrBarButton;
	
	
	//
	
	self.view.backgroundColor = [UIColor app_darkGrey];
	self.scrollView.backgroundColor = [UIColor clearColor];
	
	self.youtubeSearchController = [GeneralUI loadController:[JHYouTubeSearchViewController class]];
	self.playlistController = [GeneralUI loadController:[JHPlaylistViewController class]];
	UIView *searchView = self.youtubeSearchController.view;
	UIView *playlistView = self.playlistController.view;

	searchView.translatesAutoresizingMaskIntoConstraints = NO;
	playlistView.translatesAutoresizingMaskIntoConstraints = NO;
	[self.scrollView addSubview:searchView];
	[self.scrollView addSubview:playlistView];
	
	
	[self.view addConstraints:[NSLayoutConstraint constraintsWithVisualFormat:@"H:|[searchView(320)][playlistView(320)]|" options:0 metrics:nil views:NSDictionaryOfVariableBindings(searchView,playlistView)]];
	[self.view addConstraints:[NSLayoutConstraint constraintsWithVisualFormat:@"V:|[searchView(460)]|" options:0 metrics:nil views:NSDictionaryOfVariableBindings(searchView)]];
	[self.view addConstraints:[NSLayoutConstraint constraintsWithVisualFormat:@"V:|[playlistView(460)]|" options:0 metrics:nil views:NSDictionaryOfVariableBindings(playlistView)]];
	[self.view updateConstraints];
	[self.view layoutIfNeeded];
	
}

- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
}
- (void)showQRCode
{
	JHQRCodeViewController *qrViewController = [GeneralUI loadController:[JHQRCodeViewController class]];
	[self.navigationController pushViewController:qrViewController animated:YES];
}

- (void)showMenu
{
    RESideMenuItem *homeItem = [[RESideMenuItem alloc] initWithTitle:@"disconnect" prefix:[JHFontAwesome standardIcon:FontAwesome_Off] ofSize:28.0f ofColour:[UIColor app_red] action:^(RESideMenu *menu, RESideMenuItem *item) {
        [menu hide];
        /*
        SecondViewController *secondViewController = [[SecondViewController alloc] init];
        secondViewController.title = item.title;
        UINavigationController *navigationController = [[UINavigationController alloc] initWithRootViewController:secondViewController];
        [menu setRootViewController:navigationController];*/
    }];
	RESideMenuItem *nameItem = [[RESideMenuItem alloc] initWithTitle:@"jordan" prefix:[JHFontAwesome standardIcon:FontAwesome_Pencil] ofSize:28.0f ofColour:[UIColor app_offWhite] action:^(RESideMenu *menu, RESideMenuItem *item) {
        [menu hide];
    }];
	RESideMenuItem *startServerItem = [[RESideMenuItem alloc] initWithTitle:@"start server" prefix:[JHFontAwesome standardIcon:FontAwesome_Cloud] ofSize:23.0f ofColour:[UIColor app_offWhite] action:^(RESideMenu *menu, RESideMenuItem *item) {
        [menu hide];
    }];
	RESideMenuItem *musicItem = [[RESideMenuItem alloc] initWithTitle:@"music library" prefix:[JHFontAwesome standardIcon:FontAwesome_HDD] ofSize:28.0f ofColour:[UIColor app_offWhite] action:^(RESideMenu *menu, RESideMenuItem *item) {
        [menu hide];
    }];
	RESideMenuItem *youtubeItem = [[RESideMenuItem alloc] initWithTitle:@"youtube" prefix:[JHFontAwesome standardIcon:FontAwesome_FacetimeVideo] ofSize:23.0f ofColour:[UIColor app_green] action:^(RESideMenu *menu, RESideMenuItem *item) {
        [menu hide];
    }];
	
    _sideMenu = [[RESideMenu alloc] initWithJHItems:@[@[homeItem, nameItem, startServerItem], @[musicItem, youtubeItem]]];
	UIImage *img = [UIImage imageNamed:@"menu-bg"];
	_sideMenu.backgroundImage = img;
    _sideMenu.verticalOffset = IS_WIDESCREEN ? 160 : 126;
	_sideMenu.itemHeight = 40.0;
    //_sideMenu.hideStatusBarArea = [[[UIApplication sharedApplication] delegate] OSVersion] < 7;
    [_sideMenu show];
}


@end
