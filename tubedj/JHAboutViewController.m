//
//  JHAboutViewController.m
//  tubedj
//
//  Created by Jordan Hamill on 10/08/2013.
//  Copyright (c) 2013 Jordan Hamill. All rights reserved.
//

#import "JHAboutViewController.h"
#import "JHTubeDjManager.h"
#import "JHNewUserViewController.h"
#import "UIAlertView+Blocks.h"

@interface JHAboutViewController ()
@property (weak, nonatomic) IBOutlet UILabel *text1;
@property (weak, nonatomic) IBOutlet UIButton *resetButton;
@property (weak, nonatomic) IBOutlet UIProgressView *resetProgressView;

@end

@implementation JHAboutViewController {
	NSTimer *resetTimer;
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
	self.text1.textColor = [UIColor app_offWhite];
	[self.resetButton setImage:[UIImage imageNamed:@"reset-icon"] forState:UIControlStateNormal];
	[self.resetButton setImage:[UIImage imageNamed:@"reset-icon-pressed"] forState:UIControlStateHighlighted];
	[self.resetButton setImage:[UIImage imageNamed:@"reset-icon-pressed"] forState:UIControlStateSelected];
	[self.resetButton setTitleColor:[UIColor app_red] forState:UIControlStateNormal];
	[self.resetButton setTitleColor:[UIColor app_offWhite] forState:UIControlStateHighlighted];
	[self.resetButton setTitleColor:[UIColor app_offWhite] forState:UIControlStateSelected];
	
	[self.resetButton addTarget:self action:@selector(resetButtonDown:) forControlEvents:UIControlEventTouchDown];
	[self.resetButton addTarget:self action:@selector(resetButtonUp:) forControlEvents:UIControlEventTouchUpOutside];
	[self.resetButton addTarget:self action:@selector(resetButtonUp:) forControlEvents:UIControlEventTouchUpInside];
	
	self.resetProgressView.progress = 0;
	self.resetProgressView.progressTintColor = [UIColor app_red];
	self.resetProgressView.trackTintColor = [UIColor app_offWhite];
	self.resetProgressView.alpha = 0;
	
	//Nav
	
	UIButton *backbutton = [[UIButton alloc] initWithFrame:CGRectMake(0, 0, 60, 44)];
	[backbutton setTitle:@"back" forState:UIControlStateNormal];
	[backbutton setTitleColor:[UIColor app_blue] forState:UIControlStateNormal];
	[backbutton addTarget:self action:@selector(backButtonPressed:) forControlEvents:UIControlEventTouchUpInside];
	
	UIBarButtonItem *backBarButton = [[UIBarButtonItem alloc] initWithCustomView:backbutton];
	self.navigationController.visibleViewController.navigationItem.leftBarButtonItem = backBarButton;
}

- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

- (void)backButtonPressed:(id)sender
{
	[self.navigationController popViewControllerAnimated:YES];
}

- (void) updateProgress
{
	float progress = self.resetProgressView.progress + 1 / (3 / 0.05);
	[self.resetProgressView setProgress:progress animated:YES];

	if(self.resetProgressView.progress >= 1.0)
	{
		[resetTimer invalidate];
		resetTimer = nil;
		
		[[JHTubeDjManager sharedManager] resetUserWithSuccess:^(BOOL shouldGoToCreateUserScreen, NSString *userId, NSString *name) {
			if(shouldGoToCreateUserScreen) {
				UIViewController *viewController = [GeneralUI loadController:[JHNewUserViewController class]];
				self.navigationController.viewControllers = @[viewController];
			} else {

				[self.navigationController popViewControllerAnimated:YES];
			}
			
		} error:^(NSError *error) {
			UIAlertView *alert = [[UIAlertView alloc] initWithTitle:@"Ooops" message:@"We couldn't reset your account. Try again and if the problem persists the server is likely down." cancelButtonItem:[UIAlertButtonItem itemWithLabel:@"OK" action:^{
				//Do nothing
			}] otherButtonItems: nil];
			
			[alert show];
		}];
		
		[UIView animateWithDuration:0.5 animations:^{
			self.resetProgressView.alpha = 0;
		}];
	}
}

- (void)resetButtonDown:(id)sender
{
	[UIView animateWithDuration:0.5 animations:^{
		self.resetProgressView.alpha = 1;
	}];
	
	resetTimer = [NSTimer scheduledTimerWithTimeInterval:0.05
												  target:self
												selector:@selector(updateProgress)
												userInfo:nil
												 repeats:YES];
}

- (void)resetButtonUp:(id)sender
{
	[resetTimer invalidate];
	resetTimer = nil;
	if(self.resetProgressView.progress < 1.0)
	{
		self.resetProgressView.progress = 0;
		[UIView animateWithDuration:0.5 animations:^{
			self.resetProgressView.alpha = 0;
		}];
	}
}

@end
