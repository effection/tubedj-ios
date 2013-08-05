//
//  JHHomeViewController.m
//  tubedj
//
//  Created by Jordan Hamill on 04/08/2013.
//  Copyright (c) 2013 Jordan Hamill. All rights reserved.
//

#import "JHHomeViewController.h"
#import "JHNewUserViewController.h"

@interface JHHomeViewController ()

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
	
	[[JHTubeDjManager sharedManager] loadAndCheckUserDetails];
	
	[[NSNotificationCenter defaultCenter] addObserver:self
											 selector:@selector(tubedjUserValid:)
												 name:@"tubedj-user-is-valid"
											   object:nil];
	[[NSNotificationCenter defaultCenter] addObserver:self
											 selector:@selector(tubedjUserDoesntExist:)
												 name:@"tubedj-user-doesnt-exist"
											   object:nil];
	
	[[NSNotificationCenter defaultCenter] addObserver:self
											 selector:@selector(tubedjError:)
												 name:@"tubedj-request-error"
											   object:nil];
}

- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

- (void)alertView:(UIAlertView *)alertView clickedButtonAtIndex:(NSInteger)buttonIndex
{
	self.navigationController.viewControllers = [[NSArray alloc] initWithObjects:[GeneralUI loadController:[JHNewUserViewController class]], nil];
}

- (void)tubedjUserDoesntExist:(NSNotification *)notifcation
{
	UIAlertView *alert = [[UIAlertView alloc] initWithTitle:@"Something went wrong" message:@"Sorry, we couldn't find your details" delegate:self cancelButtonTitle:@"OK" otherButtonTitles:nil];
	
	[alert show];
}

- (void)tubedjUserValid:(NSNotification *)notifcation
{
	NSLog(@"User ok");
}

- (void)tubedjError:(NSNotification *)notification
{
	UIAlertView *alert = [[UIAlertView alloc] initWithTitle:@"Something went wrong" message:@"Sorry, something happened while trying to check your details" delegate:self cancelButtonTitle:@"OK" otherButtonTitles:nil];
	
	[alert show];
}


@end
