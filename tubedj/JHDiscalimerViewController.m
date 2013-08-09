//
//  JHDiscalimerViewController.m
//  tubedj
//
//  Created by Jordan Hamill on 05/08/2013.
//  Copyright (c) 2013 Jordan Hamill. All rights reserved.
//

#import "JHDiscalimerViewController.h"
#import "JHHomeViewController.h"
#import "JHTubeDjManager.h"
#import "UIAlertView+Blocks.h"

@interface JHDiscalimerViewController ()

@end

@implementation JHDiscalimerViewController

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
	self.navigationItem.hidesBackButton = YES;
}

- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}



- (IBAction)doneButtonPressed:(UIButton *)sender {
	NSString *name = [[NSUserDefaults standardUserDefaults] objectForKey:@"username"];
	
	[[JHTubeDjManager sharedManager] createUser:name success:^(NSString *userId, NSString *name) {
		
		if(!userId || !name || name.length < USERNAME_MIN_LENGTH || name.length > USERNAME_MAX_LENGTH) return;
		
		[[JHTubeDjManager sharedManager] saveDetails];
		[[NSUserDefaults standardUserDefaults] setObject:@(NO) forKey:@"firstRun"];
		[[NSUserDefaults standardUserDefaults] setObject:@(YES) forKey:@"termsAgreed"];
		[[NSNotificationCenter defaultCenter] removeObserver:self];
		
		self.navigationController.viewControllers = [[NSArray alloc] initWithObjects:[GeneralUI loadController:[JHHomeViewController class]], nil];
	} error:^(NSError *error) {

		UIAlertView *alert = [[UIAlertView alloc] initWithTitle:@"Ooops" message:@"Sorry, something happened while trying to add your details" cancelButtonItem:[UIAlertButtonItem itemWithLabel:@"OK" action:^{
			[self.navigationController popToRootViewControllerAnimated:YES];
		}] otherButtonItems: nil];
		

		[alert show];
	}];
}

@end
