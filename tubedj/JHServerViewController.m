//
//  JHServerViewController.m
//  tubedj
//
//  Created by Jordan Hamill on 07/08/2013.
//  Copyright (c) 2013 Jordan Hamill. All rights reserved.
//

#import "JHServerViewController.h"
#import "JHAppDelegate.h"
#import "JHYoutubeSongCell.h"
#import "JHPlaylistViewController.h"
#import "JHQRCodeViewController.h"
#import "JHStandardYoutubeViewController.h"
#import "JHTubeDjManager.h"
#import "UIAlertView+Blocks.h"
#import <Reachability.h>

@interface JHServerViewController ()
@property (weak, nonatomic) IBOutlet NSLayoutConstraint *youtubePlayerHeightConstraint;
@property (weak, nonatomic) IBOutlet JHYoutubePlayer *youtubePlayer;
@property (weak, nonatomic) IBOutlet UIScrollView *scrollView;
@property (strong, nonatomic) JHYouTubeSearchViewController *youtubeSearchController;
@property (strong, nonatomic) JHPlaylistViewController *playlistController;
@end

@implementation JHServerViewController {
	CGRect oldFrame;
	CGFloat originalYoutubePlayerHeightConstant;
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
	self.youtubePlayer.playerDelegate = self;
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
		remainingHeight = [NSNumber numberWithFloat:548-self.youtubePlayer.bounds.size.height - 44];
	} else {
		remainingHeight = [NSNumber numberWithFloat:460-self.youtubePlayer.bounds.size.height - 44];
	}
	originalYoutubePlayerHeightConstant = self.youtubePlayerHeightConstraint.constant;
	
	
	[self.view addConstraints:[NSLayoutConstraint constraintsWithVisualFormat:@"H:|[searchView(320)][playlistView(320)]|" options:0 metrics:nil views:NSDictionaryOfVariableBindings(searchView,playlistView)]];
	[self.view addConstraints:[NSLayoutConstraint constraintsWithVisualFormat:@"V:|[searchView(remainingHeight)]|" options:0 metrics:NSDictionaryOfVariableBindings(remainingHeight) views:NSDictionaryOfVariableBindings(searchView)]];
	[self.view addConstraints:[NSLayoutConstraint constraintsWithVisualFormat:@"V:|[playlistView(remainingHeight)]|" options:0 metrics:NSDictionaryOfVariableBindings(remainingHeight) views:NSDictionaryOfVariableBindings(playlistView)]];
	[self.view updateConstraints];
	[self.view layoutIfNeeded];
	
	BOOL coachMarksShown = [[NSUserDefaults standardUserDefaults] boolForKey:@"WSCoachMarksShown_ServerView"];
    if (coachMarksShown == NO) {
		
		NSArray *coachMarks = @[
			@{
				@"rect": [NSValue valueWithCGRect:(CGRect){{0,20.0f},{50.0f,44.0f}}],
				@"caption": @"Menu shows list of users"
			},
			@{
				@"rect": [NSValue valueWithCGRect:(CGRect){{320-50,20.0f},{50.0f,44.0f}}],
				@"caption": @"Show QR Code for friends to scan"
			},
			@{
				@"rect": [NSValue valueWithCGRect:(CGRect){{0.0f,64.0f},{320.0f,200.0f}}],
				@"caption": @"Current playing song"
			},
			@{
				@"rect": [NSValue valueWithCGRect:(CGRect){{0.0f,264.0f},{320.0f,44.0f}}],
				@"caption": @"Search youtube for a video to add"
			},
			@{
				@"rect": [NSValue valueWithCGRect:(CGRect){{0.0f,308.0f},{320.0f,80.0f}}],
				@"caption": @"Swipe right to add song"
			},
			@{
				@"rect": [NSValue valueWithCGRect:(CGRect){{0.0f,264.0f},{320.0f,260.0f}}],
				@"caption": @"Swipe left to show playlist"
			},
			@{
				@"rect": [NSValue valueWithCGRect:(CGRect){{0.0f,308.0f},{320.0f,80.0f}}],
				@"caption": @"Swipe left to remove"
			},
			@{
			   @"rect": [NSValue valueWithCGRect:(CGRect){{0.0f,264.0f},{320.0f,260.0f}}],
				@"caption": @"Swipe right to go back to search"
			}
		];
		
		WSCoachMarksView *coachMarksView = [[WSCoachMarksView alloc] initWithFrame:self.navigationController.view.bounds coachMarks:coachMarks];
		coachMarksView.delegate = self;
		[self.navigationController.view addSubview:coachMarksView];
		[coachMarksView start];
		isCoaching = YES;
		[[JHTubeDjManager sharedManager] fakeRoomSetup];
	}
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

- (void)addNotificationObservers
{
	if(_notificationObserversAdded) return;
	_notificationObserversAdded = YES;
	
	[[NSNotificationCenter defaultCenter] addObserver:self
											 selector:@selector(keyboardWillShow:)
												 name:UIKeyboardWillShowNotification
											   object:nil];
	[[NSNotificationCenter defaultCenter] addObserver:self
											 selector:@selector(keyboardWillHide)
												 name:UIKeyboardWillHideNotification
											   object:nil];
	
	
	[[NSNotificationCenter defaultCenter] addObserver:self
											 selector:@selector(tubedjRequestErrorNotification:)
												 name:@"tubedj-request-error"
											   object:nil];
	
	[[NSNotificationCenter defaultCenter] addObserver:self
											 selector:@selector(tubedjPlaylistRefreshed:)
												 name:@"tubedj-playlist-refresh"
											   object:nil];
	
	[[NSNotificationCenter defaultCenter] addObserver:self
											 selector:@selector(tubedjPlaylistAddedSong:)
												 name:@"tubedj-playlist-added-song"
											   object:nil];
	
	[[NSNotificationCenter defaultCenter] addObserver:self
											 selector:@selector(tubedjPlaylistRemovedSong:)
												 name:@"tubedj-playlist-removed-song"
											   object:nil];
	
	
	[[NSNotificationCenter defaultCenter] addObserver:self
											 selector:@selector(appGoingBackground:)
												 name:@"tubedj-going-background"
											   object:nil];
	[[NSNotificationCenter defaultCenter] addObserver:self
											 selector:@selector(appGoingForeground:)
												 name:@"tubedj-going-foreground"
											   object:nil];
	[[NSNotificationCenter defaultCenter] addObserver:self
											 selector:@selector(appPauseSong:)
												 name:@"tubedj-pause-song"
											   object:nil];
	
	[self.playlistController addNotificationObservers];
	
	if(isCoaching) return;
	
	[[NSNotificationCenter defaultCenter] addObserver:self
											 selector:@selector(handleNetworkChange:)
												 name:kReachabilityChangedNotification object:nil];
	
	
	Reachability *reachability = [Reachability reachabilityForInternetConnection];
	[reachability startNotifier];
	NetworkStatus status = [reachability currentReachabilityStatus];
	
	switch (status)
	{
		case NotReachable:
		{
			NSLog(@"The internet is down.");
			break;
			
		}
		case ReachableViaWiFi:
		{
			NSLog(@"The internet is working via WIFI.");
			break;
			
		}
		case ReachableViaWWAN:
		{
			NSLog(@"The internet is working via WWAN.");
			UIAlertView *alert = [[UIAlertView alloc] initWithTitle:@"Warning" message:@"You are currently not on WiFi. Playing youtube videos will use up your data!" cancelButtonItem:[UIAlertButtonItem itemWithLabel:@"OK" action:^{
				//Do nothing
			}] otherButtonItems: nil];
			
			[alert show];
			break;
			
		}
	}
}

- (void)removeNotificationObservers
{
	if(!_notificationObserversAdded) return;
	_notificationObserversAdded = NO;
	
	[self.playlistController removeNotificationObservers];
	
	[[NSNotificationCenter defaultCenter] removeObserver:self name:UIKeyboardWillShowNotification
												  object:nil];
	[[NSNotificationCenter defaultCenter] removeObserver:self name:UIKeyboardWillHideNotification
												  object:nil];
	
	
	[[NSNotificationCenter defaultCenter] removeObserver:self name:@"tubedj-request-error"
												  object:nil];
	
	[[NSNotificationCenter defaultCenter] removeObserver:self name:@"tubedj-playlist-refresh"
												  object:nil];
	
	[[NSNotificationCenter defaultCenter] removeObserver:self name:@"tubedj-playlist-added-song"
												  object:nil];
	
	[[NSNotificationCenter defaultCenter] removeObserver:self name:@"tubedj-playlist-removed-song"
												  object:nil];
	
	
	[[NSNotificationCenter defaultCenter] removeObserver:self name:@"tubedj-going-background"
												  object:nil];
	[[NSNotificationCenter defaultCenter] removeObserver:self name:@"tubedj-going-foreground"
												  object:nil];
	[[NSNotificationCenter defaultCenter] removeObserver:self name:@"tubedj-pause-song"
												  object:nil];

	if(isCoaching) return;
	
	[[NSNotificationCenter defaultCenter] removeObserver:self name:kReachabilityChangedNotification object:nil];
}

- (void)viewDidAppear:(BOOL)animated
{
	
}

- (void)viewDidDisappear:(BOOL)animated
{
	
}

- (void)handleNetworkChange:(NSNotification *)notice{
	Reachability* curReach = [notice object];
	NetworkStatus status = [curReach currentReachabilityStatus];
	switch (status)
    {
        case NotReachable:
        {
            NSLog(@"The internet is down.");
            break;
			
        }
        case ReachableViaWiFi:
        {
            NSLog(@"The internet is working via WIFI.");
            break;
			
        }
        case ReachableViaWWAN:
        {
            NSLog(@"The internet is working via WWAN.");
			UIAlertView *alert = [[UIAlertView alloc] initWithTitle:@"Warning" message:@"You are currently not on WiFi. Playing youtube videos will use up your data!" cancelButtonItem:[UIAlertButtonItem itemWithLabel:@"OK" action:^{
				//Do nothing
			}] otherButtonItems: nil];
			
			[alert show];
            break;
			
        }
    }
	
}

- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}



#pragma mark -Keyboard

-(void)keyboardWillShow:(NSNotification*)notification {
    //NSDictionary* keyboardInfo = [notification userInfo];
    //NSValue* keyboardFrameBegin = [keyboardInfo valueForKey:UIKeyboardFrameBeginUserInfoKey];
    //CGRect keyboardFrameBeginRect = [keyboardFrameBegin CGRectValue];

	self.youtubePlayerHeightConstraint.constant = 0;
	[UIView animateWithDuration:0.3f animations:^ {
		[self.view updateConstraints];
		[self.view layoutIfNeeded];
    }];
}

-(void)keyboardWillHide {
    // Animate the current view back to its original position
	self.youtubePlayerHeightConstraint.constant = originalYoutubePlayerHeightConstant;
    [UIView animateWithDuration:0.3f animations:^ {
		[self.view updateConstraints];
		[self.view layoutIfNeeded];
    }];
}

- (void)showQRCode
{
	JHQRCodeViewController *qrViewController = [GeneralUI loadController:[JHQRCodeViewController class]];
	
	UINavigationController *extraNavController = [[UINavigationController alloc] initWithRootViewController:qrViewController];
	[self.navigationController presentViewController:extraNavController animated:YES completion:nil];
	qrViewController.roomId = [JHTubeDjManager sharedManager].roomId;
	qrViewController.showsShareButton = YES;
}


#pragma mark -TubeDj

- (void)appGoingBackground:(NSNotification *) notification
{
	[self stopCurrentSong];
}

- (void)appGoingForeground:(NSNotification *) notification
{
	[self unpauseSong];
}

- (void)appPauseSong:(NSNotification *) notification
{
	[self stopCurrentSong];
}

- (void)tubedjRequestErrorNotification:(NSNotification *) notification
{
	
}

- (void)tubedjPlaylistRefreshed:(NSNotification *) notification
{
	if(self.isPlaying)
	{
		if([JHTubeDjManager sharedManager].playlist.count > 0)
		{
			JHPlaylistItem *song = (JHPlaylistItem *)[[JHTubeDjManager sharedManager].playlist objectAtIndex:0];
			if([song.songId isEqualToString:self.currentSongId])
			{
				//Do nothing
			} else {
				//Stop current song and play new song
				[self stopCurrentSong];
				[self playSong:song];
			}
		} else {
			//Stop current song
			[self stopCurrentSong];
		}
		
	} else {
		//Do nothing
	}
}

- (void)tubedjPlaylistAddedSong:(NSNotification *) notification
{
	if(isCoaching) return;
	
	JHPlaylistItem *song = [notification.userInfo objectForKey:@"song"];
	int index = [[notification.userInfo objectForKey:@"index"] integerValue];
	if(index == 0) {
		if(!self.isPlaying)
		{
			//play first song added to playlist
			[self playSong:song];
		} else {
			//What??? lol
			// play first song added to playlist
			[self stopCurrentSong];
			[self playSong:song];
		}
	} 

}

- (void)tubedjPlaylistRemovedSong:(NSNotification *) notification
{
	int index = [[notification.userInfo objectForKey:@"index"] integerValue];
	if(index == 0) {

			//First song removed
			if([JHTubeDjManager sharedManager].playlist.count > 0)
			{
				//Send next song and play
				[self playNextSong];
			} else {
				//Stop current song
				[self stopCurrentSong];
			}
	}
	
}

- (void)unpauseSong
{
	[self.youtubePlayer playYoutubeVideo];
}

- (void)playSong: (JHPlaylistItem *)song
{
	[self.youtubePlayer loadYoutubeVideo:song.songId];
}

- (void)playNextSong
{
	[[JHTubeDjManager sharedManager] nextSongWithSuccess:^{
		if([JHTubeDjManager sharedManager].playlist.count == 0) {
			return;//Shouldn't ever happen
		}
		//Alerts everyone to next song
		JHPlaylistItem *song = [[JHTubeDjManager sharedManager].playlist objectAtIndex:0];
		if(!song ||!song.isYoutube)
		{
			//Silently fail - shouldn't happen and nothing we can do about it
			return;
		}
		[self.youtubePlayer loadYoutubeVideo:song.songId];
		
	} error:^(NSError *error) {
		UIAlertView *alert = [[UIAlertView alloc] initWithTitle:@"Ooops" message:@"Sorry, we could't find the next song to play" cancelButtonItem:[UIAlertButtonItem itemWithLabel:@"OK" action:^{
			//Do nothing
		}] otherButtonItems: nil];
		
		[alert show];
	}];
}

- (void)stopCurrentSong
{
	[self.youtubePlayer pauseYoutubeVideo];
}

#pragma mark - JHYoutubePlayerDelegate

- (void)youtubePlayer:(JHYoutubePlayer *)player songEnded:(NSString *)videoId
{
	if([JHTubeDjManager sharedManager].playlist.count > 1)
	{
		[self playNextSong];
	}
	else
	{
		 NSLog(@"No more songs in playlist");
		 if([JHTubeDjManager sharedManager].playlist.count == 1)
		 {
			 JHPlaylistItem *song = [JHTubeDjManager sharedManager].playlist[0];
			 [[JHTubeDjManager sharedManager] removeSongFromPlaylist:song.uid success:^(int uid) {
				 
			 } error:^(NSError *error) {
				 //Silently fail
			 }];
		 }
	}
}

- (BOOL)youtubePlayerCanSwipeToNextSong:(JHYoutubePlayer *)player
{
	return [JHTubeDjManager sharedManager].playlist.count > 1;
}

- (void)youtubePlayer:(JHYoutubePlayer *)player nextSong:(NSString *)currentVideoId
{
	if([JHTubeDjManager sharedManager].playlist.count > 1)
	{
		[self playNextSong];
	}
}

#pragma mark - JHYoutubeSearchViewControllerDelegate

- (void)youtubeSearch:(JHYouTubeSearchViewController *)controller searchItemSelected:(NSString *)songId cell:(JHYoutubeSongCell *)cell
{
	/*JHStandardYoutubeViewController *youtubeViewController = [GeneralUI loadController:[JHStandardYoutubeViewController class]];
	UINavigationController *extraNavController = [[UINavigationController alloc] initWithRootViewController:youtubeViewController];
	[self.navigationController presentViewController:extraNavController animated:YES completion:nil];
	[youtubeViewController loadYouTubeEmbed:cell.songId];*/
	//TODO PLAY THIS SONG INSTEAD
}

- (void)youtubeSearch:(JHYouTubeSearchViewController *)controller requestToAddItemToPlaylist:(NSString *)songId cell:(JHYoutubeSongCell *)cell
{
	[[JHTubeDjManager sharedManager] addYoutubeSongToPlaylist:songId success:^(JHPlaylistItem *song) {
		//Song request successful. WebSocket should make table update
		
	} error:^(NSError *error) {
		cell.actionSuccessful = NO;
		cell.isPerformingAction = NO;
		
		UIAlertView *alert = [[UIAlertView alloc] initWithTitle:@"Ooops" message:@"Sorry, we could't add the song to the playlist" cancelButtonItem:[UIAlertButtonItem itemWithLabel:@"OK" action:^{
			//Do nothing
		}] otherButtonItems: nil];
		[alert show];
	}];
}

- (void)playlist:(JHPlaylistViewController *)controller requestToRemoveItemFromPlaylist:(int)uid cell:(JHYoutubeSongCell *)cell
{
	NSIndexPath *indexPath = [self.playlistController.tableView indexPathForCell:cell];
	if(indexPath.row == 0) {
		//First item being removed. Instead of remove call next-song
		[self playNextSong];
	} else {
		[[JHTubeDjManager sharedManager] removeSongFromPlaylist:uid success:^(int uid) {
			
		} error:^(NSError *error) {
			cell.actionSuccessful = NO;
			cell.isPerformingAction = NO;
			
			UIAlertView *alert = [[UIAlertView alloc] initWithTitle:@"Ooops" message:@"Sorry, we could't remove the song from the playlist" cancelButtonItem:[UIAlertButtonItem itemWithLabel:@"OK" action:^{
				//Do nothing
			}] otherButtonItems: nil];
			[alert show];
		}];
	}
}

- (void)showMenu
{
	[self.view endEditing:YES];
	
	JHSideMenuButtonCell *stopitem = [GeneralUI loadViewFromNib:[JHSideMenuButtonCell class]];
	stopitem.textLabel.text = @"stop server";
	stopitem.prefixLabel.font = [UIFont fontAwesomeWithSize:23.0f];
	stopitem.prefixLabel.textColor = [UIColor app_red];
	stopitem.prefixLabel.text = [JHFontAwesome standardIcon:FontAwesome_Cloud];
	stopitem.action = ^(JHSideMenu *menu, JHSideMenuCell *cell) {
		[menu hide];
		[self stopCurrentSong];
		self.youtubePlayer = nil;
		
		[[JHTubeDjManager sharedManager] leaveRoomWithSuccess:^(NSString *roomId) {
			[self.navigationController popToRootViewControllerAnimated:YES];
		} error:^(NSError *error) {
			//Silently fail
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
	
	_sideMenu = [[JHSideMenu alloc] initWithItems:@[@[stopitem], userItems]];
	UIImage *img = [UIImage imageNamed:@"menu-bg"];
	_sideMenu.backgroundImage = img;
    _sideMenu.verticalOffset = IS_WIDESCREEN ? 160 : 126;
	_sideMenu.itemHeight = 40.0;
	_sideMenu.font = [UIFont helveticaNeueRegularWithSize:22.0];
	_sideMenu.textColor = [UIColor app_offWhite];
	_sideMenu.hideStatusBarArea = NO;
    //_sideMenu.hideStatusBarArea = [[[UIApplication sharedApplication] delegate] OSVersion] < 7;
    [_sideMenu show];

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
	if(4 == index)
	{
		//Swipe right to add song - make it bounce
		cell0 = (JHYoutubeSongCell *)[self.youtubeSearchController.tableView cellForRowAtIndexPath:[NSIndexPath indexPathForRow:0 inSection:0]];
		
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
	else if(5 == index)
	{
		//Swipe left to show playlist - scroll to playlist
		[self.scrollView setContentOffset:CGPointMake(320, 0) animated:YES];
	}
	else if(6 == index)
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
	else if(7 == index)
	{
		//Swipe right to show search
		[self.scrollView setContentOffset:CGPointMake(0, 0) animated:YES];
		[self.youtubeSearchController clearSearch];
	}
}

- (void)coachMarksViewWillCleanup:(WSCoachMarksView *)coachMarksView
{
	isCoaching = NO;
	[[NSUserDefaults standardUserDefaults] setBool:YES forKey:@"WSCoachMarksShown_ServerView"];
	[[NSUserDefaults standardUserDefaults] synchronize];
	[self.navigationController popToRootViewControllerAnimated:YES];
}

@end
