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
#import "JHPlaylistViewController.h"
#import "RESideMenu.h"
#import "JHQRCodeViewController.h"
#import "JHStandardYoutubeViewController.h"
#import "ZBarSDK.h"
#import "JHTubeDjManager.h"
#import "UIAlertView+Blocks.h"

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
	self.navigationItem.hidesBackButton = YES;
	
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
	self.youtubeSearchController.delegate = self;
	self.playlistController = [GeneralUI loadController:[JHPlaylistViewController class]];
	self.playlistController.delegate = self;
	UIView *searchView = self.youtubeSearchController.view;
	UIView *playlistView = self.playlistController.view;

	searchView.translatesAutoresizingMaskIntoConstraints = NO;
	playlistView.translatesAutoresizingMaskIntoConstraints = NO;
	[self.scrollView addSubview:searchView];
	[self.scrollView addSubview:playlistView];
	
	
	NSNumber *remainingHeight;
	
	if(IS_IPHONE5) {
		remainingHeight = [NSNumber numberWithFloat:548 - 44];
	} else {
		remainingHeight = [NSNumber numberWithFloat:460 - 44];
	}
	
	
	[self.view addConstraints:[NSLayoutConstraint constraintsWithVisualFormat:@"H:|[searchView(320)][playlistView(320)]|" options:0 metrics:nil views:NSDictionaryOfVariableBindings(searchView,playlistView)]];
	[self.view addConstraints:[NSLayoutConstraint constraintsWithVisualFormat:@"V:|[searchView(remainingHeight)]|" options:0 metrics:NSDictionaryOfVariableBindings(remainingHeight) views:NSDictionaryOfVariableBindings(searchView)]];
	[self.view addConstraints:[NSLayoutConstraint constraintsWithVisualFormat:@"V:|[playlistView(remainingHeight)]|" options:0 metrics:NSDictionaryOfVariableBindings(remainingHeight) views:NSDictionaryOfVariableBindings(playlistView)]];
	[self.view updateConstraints];
	[self.view layoutIfNeeded];
	
	[self.scrollView setContentOffset:CGPointMake(320, 0)];
	
	[[NSNotificationCenter defaultCenter] addObserver:self 
											  selector:@selector(tubedjRequestErrorNotification:)
												 name:@"tubedj-request-error"
											   object:nil];
	//[self showQRCodeReader];
	[self loadRoom:@"jTgaKskT"];
}

- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
}

- (void)tubedjRequestErrorNotification:(NSNotification *) notification
{

}


- (BOOL)loadRoom:(NSString *)roomid
{
	//Sanatise
	
	if(roomid.length > 7 && roomid.length < 15) {
		[[JHTubeDjManager sharedManager] joinRoom:roomid success:^(NSString *roomId, NSString *ownerId, NSDictionary *users, NSArray *playlist) {
			
			//Populate playlist controller
			//self.playlistController
			
			//Populate users menu
			
			
		} error:^(NSError *error) {
			UIAlertView *alert = [[UIAlertView alloc] initWithTitle:@"Ooops" message:@"Sorry, we could't find that room" cancelButtonItem:[UIAlertButtonItem itemWithLabel:@"OK" action:^{
					[self.navigationController popToRootViewControllerAnimated:YES];
			}] otherButtonItems: nil];
				
			[alert show];

			
		}];
		return YES;
	}
	
	return NO;
}

- (void)alertView:(UIAlertView *)alertView clickedButtonAtIndex:(NSInteger)buttonIndex
{
	//TODO Not always leave room
}

#pragma mark - JHYoutubeSearchViewControllerDelegate

- (void)youtubeSearch:(JHYouTubeSearchViewController *)controller searchItemSelected:(NSString *)songId cell:(JHYoutubeSongCell *)cell
{
	JHStandardYoutubeViewController *youtubeViewController = [GeneralUI loadController:[JHStandardYoutubeViewController class]];
	UINavigationController *extraNavController = [[UINavigationController alloc] initWithRootViewController:youtubeViewController];
	[self.navigationController presentViewController:extraNavController animated:YES completion:nil];
	[youtubeViewController loadYouTubeEmbed:cell.songId];
}

- (void)youtubeSearch:(JHYouTubeSearchViewController *)controller requestToAddItemToPlaylist:(NSString *)songId cell:(JHYoutubeSongCell *)cell
{
	[[JHTubeDjManager sharedManager] addYoutubeSongToPlaylist:songId success:^(JHPlaylistItem *song) {
		//Song request successful. WebSocket should make table update
		
	} error:^(NSError *error) {
		cell.actionSuccessful = NO;
		cell.isPerformingAction = NO;
	}];
}

- (void)playlist:(JHPlaylistViewController *)controller requestToRemoveItemFromPlaylist:(int)uid cell:(JHYoutubeSongCell *)cell
{
	NSIndexPath *indexPath = [self.playlistController.tableView indexPathForCell:cell];
	if(indexPath.row == 0) {
		//Can't remove currently playing song
		cell.actionSuccessful = NO;
		cell.isPerformingAction = NO;
	} else {
		[[JHTubeDjManager sharedManager] removeSongFromPlaylist:uid success:^(int uid) {
			
		} error:^(NSError *error) {
			cell.actionSuccessful = NO;
			cell.isPerformingAction = NO;
		}];
	}
}

- (void)showQRCode
{
	JHQRCodeViewController *qrViewController = [GeneralUI loadController:[JHQRCodeViewController class]];
	//JHGoogleQRCodeViewController *qrViewController = [GeneralUI loadController:[JHGoogleQRCodeViewController class]];
	UINavigationController *extraNavController = [[UINavigationController alloc] initWithRootViewController:qrViewController];
	[self.navigationController presentViewController:extraNavController animated:YES completion:nil];
	[qrViewController setCode:[JHTubeDjManager sharedManager].roomId];
}

- (void)showMenu
{
	[self.view endEditing:YES];
	
    RESideMenuItem *homeItem = [[RESideMenuItem alloc] initWithTitle:@"disconnect" prefix:[JHFontAwesome standardIcon:FontAwesome_Off] ofSize:28.0f ofColour:[UIColor app_red] action:^(RESideMenu *menu, RESideMenuItem *item) {
        [menu hide];
		[[JHTubeDjManager sharedManager] leaveRoomWithSuccess:^(NSString *roomId) {
			[self.navigationController popToRootViewControllerAnimated:YES];
		} error:^(NSError *error) {
			//Let user stay in until they close app
		}];
		
        /*
        SecondViewController *secondViewController = [[SecondViewController alloc] init];
        secondViewController.title = item.title;
        UINavigationController *navigationController = [[UINavigationController alloc] initWithRootViewController:secondViewController];
        [menu setRootViewController:navigationController];*/
    }];
	
	RESideMenuItem *nameItem = [[RESideMenuItem alloc] initWithTitle:[JHTubeDjManager sharedManager].myName prefix:[JHFontAwesome standardIcon:FontAwesome_Pencil] ofSize:28.0f ofColour:[UIColor app_offWhite] action:^(RESideMenu *menu, RESideMenuItem *item) {
        [menu hide];
    }];
	
	NSMutableArray *userItems = [[NSMutableArray alloc] initWithCapacity:[JHTubeDjManager sharedManager].users.count];
	
	for (NSString* key in [JHTubeDjManager sharedManager].users) {
		JHUserItem *user = [[JHTubeDjManager sharedManager].users objectForKey:key];
		RESideMenuItem *userMenuItem = [[RESideMenuItem alloc] initWithTitle:user.name prefix:[JHFontAwesome standardIcon:FontAwesome_EllipsisVertical] ofSize:23.0f ofColour:[UIColor app_offWhite] action:^(RESideMenu *menu, RESideMenuItem *item) {
			[menu hide];
		}];
		[userItems addObject:userMenuItem];
	}
	
	
	
	
	RESideMenuItem *startServerItem = [[RESideMenuItem alloc] initWithTitle:@"start server" prefix:[JHFontAwesome standardIcon:FontAwesome_Cloud] ofSize:23.0f ofColour:[UIColor app_offWhite] action:^(RESideMenu *menu, RESideMenuItem *item) {
        [menu hide];
    }];
	RESideMenuItem *musicItem = [[RESideMenuItem alloc] initWithTitle:@"music library" prefix:[JHFontAwesome standardIcon:FontAwesome_HDD] ofSize:28.0f ofColour:[UIColor app_offWhite] action:^(RESideMenu *menu, RESideMenuItem *item) {
        [menu hide];
    }];
	RESideMenuItem *youtubeItem = [[RESideMenuItem alloc] initWithTitle:@"youtube" prefix:[JHFontAwesome standardIcon:FontAwesome_FacetimeVideo] ofSize:23.0f ofColour:[UIColor app_green] action:^(RESideMenu *menu, RESideMenuItem *item) {
        [menu hide];
    }];
	
    _sideMenu = [[RESideMenu alloc] initWithJHItems:@[@[homeItem, nameItem], userItems]];
	UIImage *img = [UIImage imageNamed:@"menu-bg"];
	_sideMenu.backgroundImage = img;
    _sideMenu.verticalOffset = IS_WIDESCREEN ? 160 : 126;
	_sideMenu.itemHeight = 40.0;
	_sideMenu.font = [UIFont helveticaNeueRegularWithSize:22.0];
	_sideMenu.textColor = [UIColor app_offWhite];
    //_sideMenu.hideStatusBarArea = [[[UIApplication sharedApplication] delegate] OSVersion] < 7;
    [_sideMenu show];
}

@end
