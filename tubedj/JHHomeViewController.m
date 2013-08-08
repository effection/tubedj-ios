//
//  JHHomeViewController.m
//  tubedj
//
//  Created by Jordan Hamill on 04/08/2013.
//  Copyright (c) 2013 Jordan Hamill. All rights reserved.
//

#import "JHHomeViewController.h"
#import "JHNewUserViewController.h"
#import "JHClientViewController.h"
#import "JHServerViewController.h"
#import	"JHTubeDjManager.h"
#import "UIAlertView+Blocks.h"

@interface JHHomeViewController ()
@property (weak, nonatomic) IBOutlet UIButton *createRoomButton;
@property (weak, nonatomic) IBOutlet UIButton *joinRoomButton;

@end

@implementation JHHomeViewController

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
	self.view.backgroundColor = [UIColor colorWithPatternImage:[UIImage imageNamed:@"gradient-bg"]];
	[self.createRoomButton setBackgroundImage:[UIImage imageNamed:@"hexagon-button"] forState:UIControlStateNormal];
	[self.createRoomButton setBackgroundImage:[UIImage imageNamed:@"hexagon-button-highlighted"] forState:UIControlStateHighlighted];
	[self.createRoomButton setBackgroundImage:[UIImage imageNamed:@"hexagon-button-highlighted"] forState:UIControlStateSelected];
	[self.createRoomButton setBackgroundImage:[UIImage imageNamed:@"hexagon-button-highlighted"] forState:UIControlStateSelected | UIControlStateHighlighted];
	[self.createRoomButton setTitleColor:[UIColor app_offWhite] forState:UIControlStateNormal];
	[self.createRoomButton setTitleColor:[UIColor app_green] forState:UIControlStateHighlighted];
	[self.createRoomButton setTitleColor:[UIColor app_offWhite] forState:UIControlStateSelected];
	[self.createRoomButton setTitleColor:[UIColor app_offWhite] forState:UIControlStateSelected | UIControlStateHighlighted];
	
	[self.joinRoomButton setBackgroundImage:[UIImage imageNamed:@"hexagon-button"] forState:UIControlStateNormal];
	[self.joinRoomButton setBackgroundImage:[UIImage imageNamed:@"hexagon-button-highlighted"] forState:UIControlStateHighlighted];
	[self.joinRoomButton setBackgroundImage:[UIImage imageNamed:@"hexagon-button-highlighted"] forState:UIControlStateSelected];
	[self.joinRoomButton setBackgroundImage:[UIImage imageNamed:@"hexagon-button-highlighted"] forState:UIControlStateSelected | UIControlStateHighlighted];
	
	[self.joinRoomButton setTitleColor:[UIColor app_offWhite] forState:UIControlStateNormal];
	[self.joinRoomButton setTitleColor:[UIColor app_green] forState:UIControlStateHighlighted];
	[self.joinRoomButton setTitleColor:[UIColor app_offWhite] forState:UIControlStateSelected];
	[self.joinRoomButton setTitleColor:[UIColor app_offWhite] forState:UIControlStateSelected | UIControlStateHighlighted];
	
	//Navigation items
	
	UIButton *button = [[UIButton alloc] initWithFrame:CGRectMake(0, 0, 40, 50)];
	[button setTitle:[JHFontAwesome standardIcon:FontAwesome_Reorder] forState:UIControlStateNormal];
	[button setTitleColor:[UIColor app_blue] forState:UIControlStateNormal];
	button.titleLabel.font = [UIFont fontAwesomeWithSize:28.0];
	[button addTarget:self action:@selector(showMenu) forControlEvents:UIControlEventTouchUpInside];
	
	UIBarButtonItem *customItem = [[UIBarButtonItem alloc] initWithCustomView:button];
	self.navigationController.visibleViewController.navigationItem.leftBarButtonItem = customItem;
	self.navigationItem.hidesBackButton = YES;
	
	
	[[JHTubeDjManager sharedManager] loadAndCheckUserDetailsWithSuccess:^(BOOL found, BOOL valid) {
		if(!found || !valid) {
			
			UIAlertView *alert = [[UIAlertView alloc] initWithTitle:@"Ooops" message:@"Sorry, we couldn't find your details" cancelButtonItem:[UIAlertButtonItem itemWithLabel:@"OK" action:^{
				self.navigationController.viewControllers = [[NSArray alloc] initWithObjects:[GeneralUI loadController:[JHNewUserViewController class]], nil];
			}] otherButtonItems: nil];
			
			[alert show];
		} else {
			NSLog(@"User ok");
		}
		
	} error:^(NSError *error) {
		
		UIAlertView *alert = [[UIAlertView alloc] initWithTitle:@"Ooops" message:@"Sorry, something happened while trying to check your details" cancelButtonItem:[UIAlertButtonItem itemWithLabel:@"OK" action:^{
			self.navigationController.viewControllers = [[NSArray alloc] initWithObjects:[GeneralUI loadController:[JHNewUserViewController class]], nil];
		}] otherButtonItems: nil];
		
		[alert show];

	}];
}

- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

- (IBAction)joinButtonPressed:(UIButton *)sender {
	JHClientViewController *clientViewController = [GeneralUI loadController:[JHClientViewController class]];
	[self.navigationController pushViewController:clientViewController animated:YES];
	//[self showQRCodeReader];
}

- (IBAction)createButtonPressed:(UIButton *)sender
{
	[[JHTubeDjManager sharedManager] createRoomWithSuccess:^(NSString *roomId) {
		NSLog(@"Created room %@", roomId);
		[[JHTubeDjManager sharedManager] joinRoom:roomId success:^(NSString *roomId, NSString *ownerId, NSDictionary *users, NSArray *playlist) {
			
			JHServerViewController *serverViewController = [GeneralUI loadController:[JHServerViewController class]];
			[self.navigationController pushViewController:serverViewController animated:YES];
			
		} error:^(NSError *error) {

			UIAlertView *alert = [[UIAlertView alloc] initWithTitle:@"Ooops" message:@"Sorry, something happened while trying to join your room" cancelButtonItem:[UIAlertButtonItem itemWithLabel:@"OK" action:^{
				//Do nothing
			}] otherButtonItems: nil];
			
			[alert show];

		}];
	} error:^(NSError *error) {

		UIAlertView *alert = [[UIAlertView alloc] initWithTitle:@"Ooops" message:@"Sorry, something happened while trying to create a room" cancelButtonItem:[UIAlertButtonItem itemWithLabel:@"OK" action:^{
			//Do nothing
		}] otherButtonItems: nil];
		
		[alert show];

	}];
}

- (void)showMenu
{
	[self.view endEditing:YES];
	
	RESideMenuItem *nameItem = [[RESideMenuItem alloc] initWithTitle:[JHTubeDjManager sharedManager].myName prefix:[JHFontAwesome standardIcon:FontAwesome_Pencil] ofSize:28.0f ofColour:[UIColor app_offWhite] action:^(RESideMenu *menu, RESideMenuItem *item) {
        [menu hide];
    }];
	
	RESideMenuItem *musicItem = [[RESideMenuItem alloc] initWithTitle:@"music library" prefix:[JHFontAwesome standardIcon:FontAwesome_HDD] ofSize:28.0f ofColour:[UIColor app_offWhite] action:^(RESideMenu *menu, RESideMenuItem *item) {
        //[menu hide];
    }];
	RESideMenuItem *youtubeItem = [[RESideMenuItem alloc] initWithTitle:@"youtube" prefix:[JHFontAwesome standardIcon:FontAwesome_FacetimeVideo] ofSize:23.0f ofColour:[UIColor app_green] action:^(RESideMenu *menu, RESideMenuItem *item) {
        //[menu hide];
    }];
	
    _sideMenu = [[RESideMenu alloc] initWithJHItems:@[@[ nameItem], @[musicItem, youtubeItem]]];
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
    id<NSFastEnumeration> results = [info objectForKey: ZBarReaderControllerResults];

    for(ZBarSymbol *symbol in results) {
		if(symbol.data.length < 7 || symbol.data.length > 12)
			break;
		
		[[JHTubeDjManager sharedManager] joinRoom:symbol.data success:^(NSString *roomId, NSString *ownerId, NSDictionary *users, NSArray *playlist) {
			JHClientViewController *clientViewController = [GeneralUI loadController:[JHClientViewController class]];
			[reader dismissViewControllerAnimated:YES completion:^{
				[self.navigationController pushViewController:clientViewController animated:YES];
			}];
			
		} error:^(NSError *error) {
			UIAlertView *alert = [[UIAlertView alloc] initWithTitle:@"Ooops" message:@"Sorry, something happened while trying to join the room" cancelButtonItem:[UIAlertButtonItem itemWithLabel:@"OK" action:^{
				//Do nothing
			}] otherButtonItems: nil];
			
			[alert show];

		}];
		
		break;
	}
}


- (void)doneButtonPressed:(id)sender
{
	[self.navigationController dismissViewControllerAnimated:YES completion:^ {
		
	}];
}

@end
