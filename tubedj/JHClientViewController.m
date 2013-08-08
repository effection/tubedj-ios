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

@implementation JHClientViewController {
	BOOL isCoaching;
}

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
	
	
	
	BOOL coachMarksShown = [[NSUserDefaults standardUserDefaults] boolForKey:@"WSCoachMarksShown_ClientView"];
    if (coachMarksShown == NO) {
		
		NSArray *coachMarks = @[
@{
@"rect": [NSValue valueWithCGRect:(CGRect){{0,20.0f},{50.0f,44.0f}}],
@"caption": @"Menu shows list of users and disconnect"
},
@{
@"rect": [NSValue valueWithCGRect:(CGRect){{320-50,20.0f},{50.0f,44.0f}}],
@"caption": @"Show QR Code for friends to scan"
},
@{
@"rect": [NSValue valueWithCGRect:(CGRect){{0.0f,64.0f},{320.0f,44.0f}}],
@"caption": @"Search youtube for a video to add"
},
@{
@"rect": [NSValue valueWithCGRect:(CGRect){{0.0f,108.0f},{320.0f,80.0f}}],
@"caption": @"Swipe right to add song"
},
@{
@"rect": [NSValue valueWithCGRect:(CGRect){{0.0f,64.0f},{320.0f,560.0f}}],
@"caption": @"Swipe left to show playlist"
},
@{
@"rect": [NSValue valueWithCGRect:(CGRect){{0.0f,108.0f},{320.0f,80.0f}}],
@"caption": @"Swipe left to remove songs you've added"
},
@{
@"rect": [NSValue valueWithCGRect:(CGRect){{0.0f,64.0f},{320.0f,560.0f}}],
@"caption": @"Swipe right to go back to search"
}
];
		
		WSCoachMarksView *coachMarksView = [[WSCoachMarksView alloc] initWithFrame:self.navigationController.view.bounds coachMarks:coachMarks];
		coachMarksView.delegate = self;
		[self.navigationController.view addSubview:coachMarksView];
		[coachMarksView start];
		isCoaching = YES;
		[[JHTubeDjManager sharedManager] fakeRoomSetup];
	} else {
		//Room joined before entering
		/*
		 [[JHTubeDjManager sharedManager] joinRoom:@"jTgaKskT" success:^(NSString *roomId, NSString *ownerId, NSDictionary *users, NSArray *playlist) {
		 //TODO Remove for release version
		 
		 } error:^(NSError *error) {
		 
		 }];
		 */
	}
}

- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
}

#pragma mark - Coach Marks delegate

- (void)coachMarksView:(WSCoachMarksView*)coachMarksView willNavigateToIndex:(NSInteger)index
{
	switch (index) {
		case 0:
			
			[self.youtubeSearchController searchFor:@"calvin harris feel so close nero remix"];
			
			break;
			
		default:
			break;
	}
}

- (void)coachMarksView:(WSCoachMarksView*)coachMarksView didNavigateToIndex:(NSInteger)index
{
	JHYoutubeSongCell *cell0;
	if(3 == index)
	{
		cell0 = (JHYoutubeSongCell *)[self.youtubeSearchController.tableView cellForRowAtIndexPath:[NSIndexPath indexPathForRow:0 inSection:0]];
		
		//Swipe right to add song - make it bounce
		[[JHTubeDjManager sharedManager] fakeSongAdd:cell0.songId];
		
		[cell0 didStartSwiping];
		[UIView animateWithDuration:0.5
							  delay:0
							options:UIViewAnimationOptionCurveEaseIn
						 animations:^{
							 cell0.contentView.frame = CGRectOffset(cell0.contentView.bounds, 198, 0);
						 }
						 completion:^(BOOL finished) {
							 [UIView animateWithDuration:0.8
												   delay:0.1
												 options:UIViewAnimationOptionCurveEaseOut
											  animations:^{
												  cell0.contentView.frame = CGRectOffset(cell0.contentView.bounds, 0, 0);
											  } completion:nil];
						 }];

	}
	else if(4 == index)
	{
		//Swipe left to show playlist - scroll to playlist
		[self.scrollView setContentOffset:CGPointMake(320, 0) animated:YES];
	}
	else if(5 == index)
	{
		//Swipe left to remove song - make it bounce
		cell0 = (JHYoutubeSongCell *)[self.playlistController.tableView cellForRowAtIndexPath:[NSIndexPath indexPathForRow:0 inSection:1]];
		
		
		[cell0 didStartSwiping];
		[UIView animateWithDuration:0.5
							  delay:0
							options:UIViewAnimationOptionCurveEaseIn
						 animations:^{
							 cell0.contentView.frame = CGRectOffset(cell0.contentView.bounds, -198, 0);
						 }
						 completion:^(BOOL finished) {
							 [[JHTubeDjManager sharedManager] fakeSongRemove];
						 }];
		
	}
	else if(6 == index)
	{
		//Swipe right to show search
		[self.scrollView setContentOffset:CGPointMake(0, 0) animated:YES];
		[self.youtubeSearchController clearSearch];
	}
}

- (void)coachMarksViewWillCleanup:(WSCoachMarksView *)coachMarksView
{
	isCoaching = NO;
	[[NSUserDefaults standardUserDefaults] setBool:YES forKey:@"WSCoachMarksShown_ClientView"];
	[[NSUserDefaults standardUserDefaults] synchronize];
	[self.navigationController popToRootViewControllerAnimated:YES];
}

- (void)tubedjRequestErrorNotification:(NSNotification *) notification
{

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
