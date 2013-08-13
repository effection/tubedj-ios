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
#import "JHAboutViewController.h"
#import	"JHTubeDjManager.h"
#import "UIAlertView+Blocks.h"

@interface JHHomeViewController ()
@property (weak, nonatomic) IBOutlet UIButton *createRoomButton;
@property (weak, nonatomic) IBOutlet UIButton *joinRoomButton;

@end

@implementation JHHomeViewController {
	NSString *queuedRoomId;
	BOOL loaded;
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
	
	loaded = NO;
	[[JHTubeDjManager sharedManager] loadAndCheckUserDetailsWithSuccess:^(BOOL found, BOOL valid) {
		if(!found || !valid) {
			
			UIAlertView *alert = [[UIAlertView alloc] initWithTitle:@"Ooops" message:@"Sorry, we couldn't find your details" cancelButtonItem:[UIAlertButtonItem itemWithLabel:@"OK" action:^{
				self.navigationController.viewControllers = [[NSArray alloc] initWithObjects:[GeneralUI loadController:[JHNewUserViewController class]], nil];
			}] otherButtonItems: nil];
			
			[alert show];
		} else {
			NSLog(@"User ok");
			[JHRestClient sharedClient].userSecret = [JHTubeDjManager sharedManager].myUserId;
			loaded = YES;
			
			if(queuedRoomId.length > 0) {
				//Join room
				
				[[JHTubeDjManager sharedManager] joinRoom:queuedRoomId success:^(NSString *roomId, NSString *ownerId, NSDictionary *users, NSArray *playlist) {
					JHClientViewController *clientViewController = [GeneralUI loadController:[JHClientViewController class]];
					[self.navigationController pushViewController:clientViewController animated:YES];
					queuedRoomId = nil;
				} error:^(NSError *error) {
					UIAlertView *alert = [[UIAlertView alloc] initWithTitle:@"Ooops" message:@"Sorry, we couldn't join that room" cancelButtonItem:[UIAlertButtonItem itemWithLabel:@"OK" action:^{
						
					}] otherButtonItems: nil];
					
					queuedRoomId = nil;
					[alert show];
				}];
			}
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

- (void)viewWillAppear:(BOOL)animated
{
	CGAffineTransform transform = CGAffineTransformRotate(CGAffineTransformIdentity, -10.0/180*M_PI);
	transform = CGAffineTransformScale(transform, 0.8, 0.8);
	self.createRoomButton.transform = transform;
	self.joinRoomButton.transform = transform;
	self.createRoomButton.alpha = 0;
	self.joinRoomButton.alpha = 0;
}

- (void)viewDidAppear:(BOOL)animated
{
	[UIView animateWithDuration:0.3 animations:^{
		self.createRoomButton.alpha = 0.4;
		self.joinRoomButton.alpha = 0.4;
		self.joinRoomButton.transform = CGAffineTransformScale(CGAffineTransformIdentity, 1, 1);
		self.createRoomButton.transform = CGAffineTransformScale(CGAffineTransformIdentity, 1, 1);
	}];
}

- (void)queueJoinRoom:(NSString *)roomId
{
	if(loaded) {
		//Join room
		
		[[JHTubeDjManager sharedManager] joinRoom:queuedRoomId success:^(NSString *roomId, NSString *ownerId, NSDictionary *users, NSArray *playlist) {
			JHClientViewController *clientViewController = [GeneralUI loadController:[JHClientViewController class]];
			[self.navigationController pushViewController:clientViewController animated:YES];
		} error:^(NSError *error) {
			UIAlertView *alert = [[UIAlertView alloc] initWithTitle:@"Ooops" message:@"Sorry, we couldn't join that room" cancelButtonItem:[UIAlertButtonItem itemWithLabel:@"OK" action:^{
				
			}] otherButtonItems: nil];
			
			[alert show];
		}];
	} else {
		queuedRoomId = roomId;
	}
}

- (void)openJoinScreenOverrideCoachMarks:(BOOL)overrideShowingCoachMarks showQRCodeReader:(BOOL)showQRCodeReader
{
#ifdef YES
	[[JHTubeDjManager sharedManager] joinRoom:@"8TXEdskT" success:^(NSString *roomId, NSString *ownerId, NSDictionary *users, NSArray *playlist) {
	 JHClientViewController *clientViewController = [GeneralUI loadController:[JHClientViewController class]];
	 [self.navigationController pushViewController:clientViewController animated:YES];
	 } error:^(NSError *error) {
	 
	 }];
	 return;
#endif
	clientJoiningRoom = NO;
	BOOL coachMarksShown = [[NSUserDefaults standardUserDefaults] boolForKey:@"WSCoachMarksShown_ClientView"];
    if (coachMarksShown == NO && !overrideShowingCoachMarks)
	{
		JHClientViewController *clientViewController = [GeneralUI loadController:[JHClientViewController class]];
		[self.navigationController pushViewController:clientViewController animated:YES];
	}
	else
	{
		if(showQRCodeReader)
		{
			[self showQRCodeReader];
		}
		else
		{
			JHClientViewController *clientViewController = [GeneralUI loadController:[JHClientViewController class]];
			[self.navigationController pushViewController:clientViewController animated:YES];
		}
	}

}

- (IBAction)joinButtonPressed:(UIButton *)sender
{
	[self openJoinScreenOverrideCoachMarks:NO showQRCodeReader:YES];
}

- (IBAction)createButtonPressed:(UIButton *)sender
{

	BOOL coachMarksShown = [[NSUserDefaults standardUserDefaults] boolForKey:@"WSCoachMarksShown_ServerView"];
    if (coachMarksShown == NO) {
		JHServerViewController *serverViewController = [GeneralUI loadController:[JHServerViewController class]];
		[self.navigationController pushViewController:serverViewController animated:YES];

		return;
	}
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
	NSString *currentName = [NSString stringWithString:[JHTubeDjManager sharedManager].myName];
	
	JHSideMenuEditCell *nameItem = [GeneralUI loadViewFromNib:[JHSideMenuEditCell class]];
	nameItem.prefixLabel.font = [UIFont fontAwesomeWithSize:28.0f];
	nameItem.prefixLabel.text = [JHFontAwesome standardIcon:FontAwesome_Pencil];
	nameItem.editField.text = [JHTubeDjManager sharedManager].myName;
	nameItem.action = ^(JHSideMenu *menu, JHSideMenuCell* item) {
		
		JHSideMenuEditCell *editCell = (JHSideMenuEditCell *)item;
		NSString *newName = editCell.editField.text;
		if(newName.length < USERNAME_MIN_LENGTH || newName.length > USERNAME_MAX_LENGTH) return;
		
		[[JHTubeDjManager sharedManager] changeUserName:newName success:^(NSString *userId, NSString *name) {
			//[menu hide];
		} error:^(NSError *error) {
			UIAlertView *alert = [[UIAlertView alloc] initWithTitle:@"Ooops" message:@"Sorry, something happened while trying to change your name" cancelButtonItem:[UIAlertButtonItem itemWithLabel:@"OK" action:^{
				//Do nothing
				editCell.editField.text = currentName;
			}] otherButtonItems: nil];
			
			[alert show];
		}];
		
	};
	
	
	JHSideMenuToggleCell *alwaysLeaveItem = [GeneralUI loadViewFromNib:[JHSideMenuToggleCell class]];
	alwaysLeaveItem.prefixLabel.font = [UIFont fontAwesomeWithSize:25.0f];
	alwaysLeaveItem.offColour = [UIColor app_offWhite];
	alwaysLeaveItem.onColour = [UIColor app_green];
	alwaysLeaveItem.offIcon = [JHFontAwesome standardIcon:FontAwesome_CheckEmpty];
	alwaysLeaveItem.onIcon = [JHFontAwesome standardIcon:FontAwesome_Check];
	alwaysLeaveItem.titleLabel.text = @"always leave";
	alwaysLeaveItem.action = ^(JHSideMenu *menu, JHSideMenuCell *cell) {
		JHSideMenuToggleCell *toggleCell = (JHSideMenuToggleCell *)cell;
		[[NSUserDefaults standardUserDefaults] setBool:toggleCell.on forKey:@"shouldDisconnectOnBackground"];
	};
	
	JHSideMenuButtonCell *aboutItem = [GeneralUI loadViewFromNib:[JHSideMenuButtonCell class]];
	aboutItem.titleLabel.text = @"about";
	aboutItem.prefixLabel.font = [UIFont fontAwesomeWithSize:28.0f];
	aboutItem.prefixLabel.text = [JHFontAwesome standardIcon:FontAwesome_Info];
	aboutItem.action = ^(JHSideMenu *menu, JHSideMenuCell *cell) {
		[menu hide];
		[self.navigationController pushViewController:[GeneralUI loadController:[JHAboutViewController class]] animated:YES];
	};

	
	_jhSideMenu = [[JHSideMenu alloc] initWithItems:@[@[nameItem, alwaysLeaveItem], @[aboutItem]]];
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


- (void)showMenu1
{
	[self.view endEditing:YES];
	NSString *currentName = [NSString stringWithString:[JHTubeDjManager sharedManager].myName];
	
	RESideMenuItem *nameItem = [[RESideMenuItem alloc] initWithTitle:[JHTubeDjManager sharedManager].myName isEditable:YES prefix:[JHFontAwesome standardIcon:FontAwesome_Pencil] ofSize:28.0f ofColour:[UIColor app_offWhite] action:nil editAction:^(RESideMenu *menu, RESideMenuItem *item, UITextField *textField) {
		
		NSString *newName = textField.text;
		if(newName.length < USERNAME_MIN_LENGTH || newName.length > USERNAME_MAX_LENGTH) return;
		
		[[JHTubeDjManager sharedManager] changeUserName:newName success:^(NSString *userId, NSString *name) {
			//[menu hide];
		} error:^(NSError *error) {
			UIAlertView *alert = [[UIAlertView alloc] initWithTitle:@"Ooops" message:@"Sorry, something happened while trying to change your name" cancelButtonItem:[UIAlertButtonItem itemWithLabel:@"OK" action:^{
				//Do nothing
				textField.text = currentName;
			}] otherButtonItems: nil];
			
			[alert show];
		}];
		
	}];
	
	NSString *icon = [[NSUserDefaults standardUserDefaults] boolForKey:@"shouldDisconnectOnBackground"] ? [JHFontAwesome standardIcon:FontAwesome_Check] : [JHFontAwesome standardIcon:FontAwesome_CheckEmpty];
	
	RESideMenuItem *alwasyLeaveItem = [[RESideMenuItem alloc] initWithTitle:@"always leave" prefix:icon ofSize:25.0f ofColour:[UIColor app_offWhite] action:^(RESideMenu *menu, RESideMenuItem *item) {
        BOOL value = ![[NSUserDefaults standardUserDefaults] boolForKey:@"shouldDisconnectOnBackground"];
		//TODO Add toggling of icon live here
		[[NSUserDefaults standardUserDefaults] setObject:@(value) forKey:@"shouldDisconnectOnBackground"];
		
    }];
	/*
	RESideMenuItem *musicItem = [[RESideMenuItem alloc] initWithTitle:@"music library" prefix:[JHFontAwesome standardIcon:FontAwesome_HDD] ofSize:28.0f ofColour:[UIColor app_offWhite] action:^(RESideMenu *menu, RESideMenuItem *item) {
        //[menu hide];
    }];
	RESideMenuItem *youtubeItem = [[RESideMenuItem alloc] initWithTitle:@"youtube" prefix:[JHFontAwesome standardIcon:FontAwesome_FacetimeVideo] ofSize:23.0f ofColour:[UIColor app_green] action:^(RESideMenu *menu, RESideMenuItem *item) {
        //[menu hide];
    }];*/
	
	RESideMenuItem *aboutItem = [[RESideMenuItem alloc] initWithTitle:@"about" prefix:[JHFontAwesome standardIcon:FontAwesome_Info] ofSize:28.0f ofColour:[UIColor app_offWhite] action:^(RESideMenu *menu, RESideMenuItem *item) {
        [menu hide];
		[self.navigationController pushViewController:[GeneralUI loadController:[JHAboutViewController class]] animated:YES];
    }];
	
    _sideMenu = [[RESideMenu alloc] initWithJHItems:@[@[nameItem, alwasyLeaveItem], @[aboutItem]]];
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

BOOL clientJoiningRoom = NO;

- (void) imagePickerController: (UIImagePickerController*) reader
 didFinishPickingMediaWithInfo: (NSDictionary*) info
{
    // ADD: get the decode results
    id<NSFastEnumeration> results = [info objectForKey: ZBarReaderControllerResults];
	
    for(ZBarSymbol *symbol in results) {
		if(symbol.data.length < 7 || symbol.data.length > 12 || clientJoiningRoom)
			break;
		clientJoiningRoom = YES;
		[[JHTubeDjManager sharedManager] joinRoom:symbol.data success:^(NSString *roomId, NSString *ownerId, NSDictionary *users, NSArray *playlist) {
			
			JHClientViewController *clientViewController = [GeneralUI loadController:[JHClientViewController class]];
			[reader dismissViewControllerAnimated:YES completion:^{
				[self.navigationController pushViewController:clientViewController animated:YES];
				clientJoiningRoom = NO;
			}];
			
		} error:^(NSError *error) {
			UIAlertView *alert = [[UIAlertView alloc] initWithTitle:@"Ooops" message:@"Sorry, something happened while trying to join the room" cancelButtonItem:[UIAlertButtonItem itemWithLabel:@"OK" action:^{
				//Do nothing
			}] otherButtonItems: nil];
			
			[alert show];
			clientJoiningRoom = NO;

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
