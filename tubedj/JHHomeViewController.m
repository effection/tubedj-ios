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
#import	"JHTubeDjManager.h"

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
	
	[[JHTubeDjManager sharedManager] loadAndCheckUserDetailsWithSuccess:^(BOOL found, BOOL valid) {
		if(!found || !valid) {
			UIAlertView *alert = [[UIAlertView alloc] initWithTitle:@"Something went wrong" message:@"Sorry, we couldn't find your details" delegate:self cancelButtonTitle:@"OK" otherButtonTitles:nil];
			
			[alert show];
		} else {
			NSLog(@"User ok");
		}
		
	} error:^(NSError *error) {
		UIAlertView *alert = [[UIAlertView alloc] initWithTitle:@"Something went wrong" message:@"Sorry, something happened while trying to check your details" delegate:self cancelButtonTitle:@"OK" otherButtonTitles:nil];
		
		[alert show];
	}];
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

- (IBAction)joinButtonPressed:(UIButton *)sender {
	JHClientViewController *clientViewController = [GeneralUI loadController:[JHClientViewController class]];
	[self.navigationController pushViewController:clientViewController animated:YES];

}
@end
