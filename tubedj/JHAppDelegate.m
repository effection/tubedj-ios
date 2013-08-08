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

@implementation JHAppDelegate

- (int)OSVersion
{
    static int _deviceSystemMajorVersion = -1;
    static dispatch_once_t onceToken;
    dispatch_once(&onceToken, ^{
        _deviceSystemMajorVersion = [[[[[UIDevice currentDevice] systemVersion] componentsSeparatedByString:@"."] objectAtIndex:0] intValue];
    });
    return _deviceSystemMajorVersion;
}

- (BOOL)application:(UIApplication *)application didFinishLaunchingWithOptions:(NSDictionary *)launchOptions
{
    self.window = [[UIWindow alloc] initWithFrame:[[UIScreen mainScreen] bounds]];
	
	[[NSUserDefaults standardUserDefaults] registerDefaults:[NSDictionary dictionaryWithObjectsAndKeys:[NSNumber numberWithBool:YES],@"firstRun",nil]];
	BOOL isFirstRun = [[NSUserDefaults standardUserDefaults] boolForKey:@"firstRun"];
	
	UIViewController *viewController = nil;
	
	if(isFirstRun)
		viewController = [GeneralUI loadController:[JHNewUserViewController class]];
	else
		viewController = [GeneralUI loadController:[JHHomeViewController class]];
	
	UINavigationController *navController = [[UINavigationController alloc] initWithRootViewController:viewController];

	self.window.rootViewController = navController;
    [self.window makeKeyAndVisible];
	
	[self.window setBackgroundColor:[UIColor app_darkGrey]];
	
	
	[[UINavigationBar appearance] setBackgroundImage:[UIImage imageNamed:@"navbar-background"] forBarMetrics:UIBarMetricsDefault];
	UIImage *shadow = [[UIImage alloc] init];
	[[UINavigationBar appearance] setShadowImage:shadow];
	 return YES;
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
}

- (void)applicationWillEnterForeground:(UIApplication *)application
{
	// Called as part of the transition from the background to the inactive state; here you can undo many of the changes made on entering the background.
	[[NSNotificationCenter defaultCenter] postNotificationName:@"tubedj-going-foreground"
														object:nil
													  userInfo:nil];
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
