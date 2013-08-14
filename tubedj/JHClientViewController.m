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
	BOOL _notificationObserversAdded;
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
	}
	[self addNotificationObservers];
}

- (void)viewWillAppear:(BOOL)animated
{
	[self addNotificationObservers];
}

- (void)viewWillDisappear:(BOOL)animated {
	NSArray *viewControllers = self.navigationController.viewControllers;
	if (viewControllers.count > 1 && [viewControllers objectAtIndex:viewControllers.count-2] == self) {
		//NSLog(@"New view controller was pushed");
	} else if ([viewControllers indexOfObject:self] == NSNotFound) {
		[self removeNotificationObservers];
	}
}

- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
}


- (void)addNotificationObservers
{
	if(_notificationObserversAdded) return;
	_notificationObserversAdded = YES;
	
	[[NSNotificationCenter defaultCenter] addObserver:self
											 selector:@selector(tubedjRequestErrorNotification:)
												 name:@"tubedj-request-error"
											   object:nil];
	
	[[NSNotificationCenter defaultCenter] addObserver:self
											 selector:@selector(tubedjRoomClosed:)
												 name:@"tubedj-room-closed"
											   object:nil];
	
	[self.playlistController addNotificationObservers];
}

- (void)removeNotificationObservers
{
	if(!_notificationObserversAdded) return;
	_notificationObserversAdded = NO;
	
	[[NSNotificationCenter defaultCenter] removeObserver:self name:@"tubedj-request-error" object:nil];
	
	[self.playlistController removeNotificationObservers];
	
}

#pragma mark - Coach Marks delegate

- (void)coachMarksView:(WSCoachMarksView*)coachMarksView willNavigateToIndex:(NSInteger)index
{
	switch (index) {
		case 0:
			
			[self.youtubeSearchController searchFor:@"London Grammar - Strong"];
			
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

- (void)tubedjRoomClosed:(NSNotification *) notification
{
	/**
	 should have already left as the sever closes the websocket
	 
	[[JHTubeDjManager sharedManager] leaveRoomWithSuccess:^(NSString *roomId) {
		[self.navigationController popToRootViewControllerAnimated:YES];
	} error:^(NSError *error) {
		//Let user stay in until they close app... will have to reset acount
	}];
	*/
	UIAlertView *alert = [[UIAlertView alloc] initWithTitle:@"Bye" message:@"The host has now closed this room" cancelButtonItem:[UIAlertButtonItem itemWithLabel:@"OK" action:^{
		[self.navigationController popToRootViewControllerAnimated:YES];
	}] otherButtonItems: nil];
	
	[alert show];
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
	qrViewController.roomId = [JHTubeDjManager sharedManager].roomId;
}

- (void)showMenu
{
	[self.view endEditing:YES];
	
	JHSideMenuButtonCell *stopitem = [GeneralUI loadViewFromNib:[JHSideMenuButtonCell class]];
	stopitem.textLabel.text = @"disconnect";
	stopitem.prefixLabel.font = [UIFont fontAwesomeWithSize:28.0f];
	stopitem.prefixLabel.textColor = [UIColor app_red];
	stopitem.prefixLabel.text = [JHFontAwesome standardIcon:FontAwesome_Off];
	stopitem.action = ^(JHSideMenu *menu, JHSideMenuCell *cell) {
		[menu hide];
		[[JHTubeDjManager sharedManager] leaveRoomWithSuccess:^(NSString *roomId) {
			[self.navigationController popToRootViewControllerAnimated:YES];
		} error:^(NSError *error) {
			//Let user stay in until they close app
		}];
	};
	
	
	NSMutableArray *userItems = [[NSMutableArray alloc] initWithCapacity:[JHTubeDjManager sharedManager].users.count];
	
	for (NSString* key in [JHTubeDjManager sharedManager].users) {
		JHUserItem *user = [[JHTubeDjManager sharedManager].users objectForKey:key];
		
		JHSideMenuButtonCell *useritem = [GeneralUI loadViewFromNib:[JHSideMenuButtonCell class]];
		useritem.titleLabel.text = user.name;
		useritem.prefixLabel.font = [UIFont fontAwesomeWithSize:23.0f];
		useritem.prefixLabel.text = [JHFontAwesome standardIcon:FontAwesome_EllipsisVertical];
		useritem.action = ^(JHSideMenu *menu, JHSideMenuCell *cell) {
			[menu hide];
		};
		
		[userItems addObject:useritem];
	}
	
	_jhSideMenu = [[JHSideMenu alloc] initWithItems:@[@[stopitem], userItems]];
	UIImage *img = [UIImage imageNamed:@"menu-bg"];
	_jhSideMenu.backgroundImage = img;
    _jhSideMenu.verticalOffset = IS_WIDESCREEN ? 160 : 126;
	_jhSideMenu.itemHeight = 40.0;
	_jhSideMenu.font = [UIFont helveticaNeueRegularWithSize:22.0];
	_jhSideMenu.textColor = [UIColor app_offWhite];
	_jhSideMenu.hideStatusBarArea = NO;
    //_sideMenu.hideStatusBarArea = [[[UIApplication sharedApplication] delegate] OSVersion] < 7;
    [_jhSideMenu show];
	
}

@end
