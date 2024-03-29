//
//  JHAppDelegate.m
//  tubedj
//
//  Created by Jordan Hamill on 01/08/2013.
//  Copyright (c) 2013 Jordan Hamill. All rights reserved.
//

#import "JHAppDelegate.h"

#import "JHViewController.h"
#import "JHClientViewController.h"
#import "JHHomeViewController.h"
#import "JHNewUserViewController.h"
#import "UIAlertView+Blocks.h"
#import "JHTubeDjManager.h"

@implementation JHAppDelegate {
	UINavigationController *navController;
}

- (int)OSVersion
{
    static int _deviceSystemMajorVersion = -1;
    static dispatch_once_t onceToken;
    dispatch_once(&onceToken, ^{
        _deviceSystemMajorVersion = [[[[[UIDevice currentDevice] systemVersion] componentsSeparatedByString:@"."] objectAtIndex:0] intValue];
    });
    return _deviceSystemMajorVersion;
}

- (void)customiseUI
{
	//UI Customisation
	[[UINavigationBar appearance] setBackgroundImage:[UIImage imageNamed:@"navbar-background"] forBarMetrics:UIBarMetricsDefault];
	UIImage *shadow = [[UIImage alloc] init];
	[[UINavigationBar appearance] setShadowImage:shadow];
	
	
	//[[UITextField appearanceWhenContainedIn:[UISearchBar class], nil] setTextColor:[UIColor app_green]];
}

- (BOOL)application:(UIApplication *)application didFinishLaunchingWithOptions:(NSDictionary *)launchOptions
{
    self.window = [[UIWindow alloc] initWithFrame:[[UIScreen mainScreen] bounds]];
	navController = [[UINavigationController alloc] init];
	self.window.rootViewController = navController;
    [self.window makeKeyAndVisible];
	[self.window setBackgroundColor:[UIColor app_darkGrey]];
	
	[self customiseUI];
	
	[[NSUserDefaults standardUserDefaults] registerDefaults:@{@"firstRun" : @(YES), @"shouldDisconnectOnBackground" : @(YES), @"WSCoachMarksShown_ClientView" : @(NO), @"WSCoachMarksShown_ServerView" : @(NO)}];
	BOOL isFirstRun = [[NSUserDefaults standardUserDefaults] boolForKey:@"firstRun"];
	
	UIViewController *viewController = nil;
	
    if(isFirstRun)
	{
		viewController = [GeneralUI loadController:[JHNewUserViewController class]];
    }
	else if ([launchOptions objectForKey:UIApplicationLaunchOptionsURLKey])
	{
		NSURL *url = [launchOptions objectForKey:UIApplicationLaunchOptionsURLKey];
		NSString *method = [[url host] stringByReplacingPercentEscapesUsingEncoding:NSUTF8StringEncoding];
		if([method isEqualToString:@"join"])
		{
			NSString *roomId = url.query;
			roomId = [JHTubeDjManager decryptUrlRoomId:roomId];
			
			if(roomId.length < 7 || roomId.length > 12) return NO;
			
			JHHomeViewController *viewController = [GeneralUI loadController:[JHHomeViewController class]];
			navController.viewControllers = @[viewController];
			[viewController queueJoinRoom:roomId];
			return YES;
		}
	}
	else
	{
		viewController = [GeneralUI loadController:[JHHomeViewController class]];
	}
	
	
	navController.viewControllers = @[viewController];
	
	return YES;
}

- (BOOL)application:(UIApplication *)application handleOpenURL:(NSURL *)url {
    NSString *method = [[url host] stringByReplacingPercentEscapesUsingEncoding:NSUTF8StringEncoding];
	
	if([method isEqualToString:@"join"])
	{
		NSString *roomId = url.query;
		roomId = [JHTubeDjManager decryptUrlRoomId:roomId];
		
		if(roomId.length < 7 || roomId.length > 12) return NO;
		
		JHHomeViewController *viewController = [GeneralUI loadController:[JHHomeViewController class]];
		navController.viewControllers = @[viewController];
		[viewController queueJoinRoom:roomId];
		return YES;
	}
	
    return NO;
}

- (void)applicationWillResignActive:(UIApplication *)application
{
	// Sent when the application is about to move from active to inactive state. This can occur for certain types of temporary interruptions (such as an incoming phone call or SMS message) or when the user quits the application and it begins the transition to the background state.
	// Use this method to pause ongoing tasks, disable timers, and throttle down OpenGL ES frame rates. Games should use this method to pause the game.
	[[NSNotificationCenter defaultCenter] postNotificationName:@"tubedj-pause-song"
														object:nil
													  userInfo:nil];
}

- (void)applicationDidEnterBackground:(UIApplication *)application
{
	// Use this method to release shared resources, save user data, invalidate timers, and store enough application state information to restore your application to its current state in case it is terminated later. 
	// If your application supports background execution, this method is called instead of applicationWillTerminate: when the user quits.
	[[NSNotificationCenter defaultCenter] postNotificationName:@"tubedj-going-background"
														object:nil
													  userInfo:nil];
	
	BOOL shouldDisconnect = [[NSUserDefaults standardUserDefaults] boolForKey:@"shouldDisconnectOnBackground"];
	if(shouldDisconnect)
	{
		if([JHTubeDjManager sharedManager].roomId.length > 0) {
			//Save room id to defaults
			
			if(![[JHTubeDjManager sharedManager] isRoomOwner]) {
				[[NSUserDefaults standardUserDefaults] setValue:[JHTubeDjManager sharedManager].roomId forKey:@"restoreRoomId"];
				[[NSUserDefaults standardUserDefaults] synchronize];
			}
			
			//Leave room
			[[JHTubeDjManager sharedManager] socketIODisconnect];
		}
	} 
}

- (void)applicationWillEnterForeground:(UIApplication *)application
{
	// Called as part of the transition from the background to the inactive state; here you can undo many of the changes made on entering the background.
	[[NSNotificationCenter defaultCenter] postNotificationName:@"tubedj-going-foreground"
														object:nil
													  userInfo:nil];
	BOOL shouldTryToReloadRoom = [[NSUserDefaults standardUserDefaults] boolForKey:@"shouldDisconnectOnBackground"];
	if(shouldTryToReloadRoom)
	{
		//Check NSUserDefalts for stored roomId
		NSString *restoreRoomId = [[NSUserDefaults standardUserDefaults] stringForKey:@"restoreRoomId"];
		
		if(restoreRoomId.length > 0)
		{
			//Try to join room again and set stored roomId to nil
			[[NSUserDefaults standardUserDefaults] removeObjectForKey:@"restoreRoomId"];
			[[NSUserDefaults standardUserDefaults] synchronize];
			JHHomeViewController *viewController = [GeneralUI loadController:[JHHomeViewController class]];
			navController.viewControllers = @[viewController];
			[viewController queueJoinRoom:restoreRoomId];
		} else {
			//Tried to reload room but no room id so probably was Sever
			JHHomeViewController *viewController = [GeneralUI loadController:[JHHomeViewController class]];
			navController.viewControllers = @[viewController];
		}
	}
}

- (void)applicationDidBecomeActive:(UIApplication *)application
{
	// Restart any tasks that were paused (or not yet started) while the application was inactive. If the application was previously in the background, optionally refresh the user interface.
	[[NSNotificationCenter defaultCenter] postNotificationName:@"tubedj-going-foreground"
														object:nil
													  userInfo:nil];
	
	
}

- (void)applicationWillTerminate:(UIApplication *)application
{
	// Called when the application is about to terminate. Save data if appropriate. See also applicationDidEnterBackground:.
}

@end
