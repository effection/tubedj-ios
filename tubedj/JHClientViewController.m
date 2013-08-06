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
	
	
	[self.view addConstraints:[NSLayoutConstraint constraintsWithVisualFormat:@"H:|[searchView(320)][playlistView(320)]|" options:0 metrics:nil views:NSDictionaryOfVariableBindings(searchView,playlistView)]];
	[self.view addConstraints:[NSLayoutConstraint constraintsWithVisualFormat:@"V:|[searchView(460)]|" options:0 metrics:nil views:NSDictionaryOfVariableBindings(searchView)]];
	[self.view addConstraints:[NSLayoutConstraint constraintsWithVisualFormat:@"V:|[playlistView(460)]|" options:0 metrics:nil views:NSDictionaryOfVariableBindings(playlistView)]];
	[self.view updateConstraints];
	[self.view layoutIfNeeded];
	
	
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
			
			//TODO Error
			UIAlertView *alert = [[UIAlertView alloc] initWithTitle:@"Ooops" message:@"Sorry, we couldn't find that room" delegate:self cancelButtonTitle:@"OK" otherButtonTitles:nil];
			
			[alert show];

			
		}];
		return YES;
	}
	
	return NO;
}

- (void)alertView:(UIAlertView *)alertView clickedButtonAtIndex:(NSInteger)buttonIndex
{
	[self.navigationController popToRootViewControllerAnimated:YES];//TODO Not always leave room
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
		cell.isSwipeable = YES;
		cell.isPerformingAction = NO;
	}];
}

- (void)playlist:(JHPlaylistViewController *)controller requestToRemoveItemFromPlaylist:(NSString *)uid cell:(JHYoutubeSongCell *)cell
{
	[[JHTubeDjManager sharedManager] removeSongFromPlaylist:uid success:^(NSString *uid) {
		
	} error:^(NSError *error) {
		cell.isSwipeable = YES;
		cell.isPerformingAction = NO;
	}];
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
		[self.navigationController popToRootViewControllerAnimated:YES];
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
	
    _sideMenu = [[RESideMenu alloc] initWithJHItems:@[@[homeItem, nameItem], @[]]];
	UIImage *img = [UIImage imageNamed:@"menu-bg"];
	_sideMenu.backgroundImage = img;
    _sideMenu.verticalOffset = IS_WIDESCREEN ? 160 : 126;
	_sideMenu.itemHeight = 40.0;
	_sideMenu.font = [UIFont helveticaNeueRegularWithSize:22.0];
	_sideMenu.textColor = [UIColor app_offWhite];
    //_sideMenu.hideStatusBarArea = [[[UIApplication sharedApplication] delegate] OSVersion] < 7;
    [_sideMenu show];
}

- (void)showQRCodeReader
{
	ZBarReaderViewController *reader = [ZBarReaderViewController new];
    reader.readerDelegate = self;
    reader.supportedOrientationsMask = ZBarOrientationMaskAll;
	reader.showsZBarControls = NO;
	reader.wantsFullScreenLayout = NO;
    ZBarImageScanner *scanner = reader.scanner;
    // TODO: (optional) additional reader configuration here
	
    // EXAMPLE: disable rarely used I2/5 to improve performance
    [scanner setSymbology: ZBAR_I25
				   config: ZBAR_CFG_ENABLE
					   to: 0];
	UINavigationController *extraNavController = [[UINavigationController alloc] initWithRootViewController:reader];
	
	UIButton *doneButton = [[UIButton alloc] initWithFrame:CGRectMake(0, 0, 60, 44)];
	[doneButton setTitle:@"cancel" forState:UIControlStateNormal];
	[doneButton setTitleColor:[UIColor app_blue] forState:UIControlStateNormal];
	[doneButton addTarget:self action:@selector(doneButtonPressed:) forControlEvents:UIControlEventTouchUpInside];
	
	UIBarButtonItem *doneBarButton = [[UIBarButtonItem alloc] initWithCustomView:doneButton];
	reader.navigationItem.rightBarButtonItem = doneBarButton;
	
    [self.navigationController presentViewController:extraNavController animated:YES completion:nil];
}

#pragma mark - ZBar QR Code delegate

- (void) imagePickerController: (UIImagePickerController*) reader
 didFinishPickingMediaWithInfo: (NSDictionary*) info
{
    // ADD: get the decode results
    id<NSFastEnumeration> results =
	[info objectForKey: ZBarReaderControllerResults];
    ZBarSymbol *symbol = nil;
    for(symbol in results) {		
		if([self loadRoom:symbol.data])
		{
			[reader dismissViewControllerAnimated:YES completion:nil];
			break;
		}
	}
	
}

- (void)doneButtonPressed:(id)sender
{
	[self.navigationController dismissViewControllerAnimated:YES completion:^ {
		[self.navigationController popToRootViewControllerAnimated:YES];
	}];
}

@end
