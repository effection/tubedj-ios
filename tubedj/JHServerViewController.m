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
#import "RESideMenu.h"
#import "JHQRCodeViewController.h"
#import "JHStandardYoutubeViewController.h"
#import "JHTubeDjManager.h"


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
	
	NSNumber *remainingHeight = [NSNumber numberWithFloat:self.view.bounds.size.height-self.youtubePlayer.bounds.size.height];
	originalYoutubePlayerHeightConstant = self.youtubePlayerHeightConstraint.constant;
	
	
	[self.view addConstraints:[NSLayoutConstraint constraintsWithVisualFormat:@"H:|[searchView(320)][playlistView(320)]|" options:0 metrics:nil views:NSDictionaryOfVariableBindings(searchView,playlistView)]];
	[self.view addConstraints:[NSLayoutConstraint constraintsWithVisualFormat:@"V:|[searchView(remainingHeight)]|" options:0 metrics:NSDictionaryOfVariableBindings(remainingHeight) views:NSDictionaryOfVariableBindings(searchView)]];
	[self.view addConstraints:[NSLayoutConstraint constraintsWithVisualFormat:@"V:|[playlistView(remainingHeight)]|" options:0 metrics:NSDictionaryOfVariableBindings(remainingHeight) views:NSDictionaryOfVariableBindings(playlistView)]];
	[self.view updateConstraints];
	[self.view layoutIfNeeded];
	
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
				//TODO Stop current song and play new song
			}
		} else {
			//TODO Stop current song
		}
		
	} else {
		//Do nothing
	}
	//[self.tableView reloadData];
}

- (void)tubedjPlaylistAddedSong:(NSNotification *) notification
{
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
			//TODO error
			return;
		}
		[self.youtubePlayer loadYoutubeVideo:song.songId];
		
	} error:^(NSError *error) {
		//TODO error
	}];
}

- (void)stopCurrentSong
{
	[self.youtubePlayer pauseYoutubeVideo];
}

- (void)alertView:(UIAlertView *)alertView clickedButtonAtIndex:(NSInteger)buttonIndex
{
	[self.navigationController popToRootViewControllerAnimated:YES];//TODO Not always leave room
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
				 
			 }];
		 }
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
		}];
	}
}

- (void)showMenu
{
	[self.view endEditing:YES];
	
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
	
	
	RESideMenuItem *stopServerItem = [[RESideMenuItem alloc] initWithTitle:@"stop server" prefix:[JHFontAwesome standardIcon:FontAwesome_Cloud] ofSize:23.0f ofColour:[UIColor app_red] action:^(RESideMenu *menu, RESideMenuItem *item) {
        [menu hide];
		
		[[JHTubeDjManager sharedManager] leaveRoomWithSuccess:^(NSString *roomId) {
			[self.navigationController popToRootViewControllerAnimated:YES];
		} error:^(NSError *error) {
			//TODO
		}];

    }];
	
	RESideMenuItem *musicItem = [[RESideMenuItem alloc] initWithTitle:@"music library" prefix:[JHFontAwesome standardIcon:FontAwesome_HDD] ofSize:28.0f ofColour:[UIColor app_offWhite] action:^(RESideMenu *menu, RESideMenuItem *item) {
        [menu hide];
    }];
	RESideMenuItem *youtubeItem = [[RESideMenuItem alloc] initWithTitle:@"youtube" prefix:[JHFontAwesome standardIcon:FontAwesome_FacetimeVideo] ofSize:23.0f ofColour:[UIColor app_green] action:^(RESideMenu *menu, RESideMenuItem *item) {
        [menu hide];
    }];
	
    _sideMenu = [[RESideMenu alloc] initWithJHItems:@[@[stopServerItem, nameItem, musicItem, youtubeItem], userItems]];
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
