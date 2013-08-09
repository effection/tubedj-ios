//
//  JHNewUserViewController.m
//  tubedj
//
//  Created by Jordan Hamill on 04/08/2013.
//  Copyright (c) 2013 Jordan Hamill. All rights reserved.
//

#import "JHNewUserViewController.h"
#import "JHIntroGraphicViewController.h"
#import "JHDiscalimerViewController.h"

@interface JHNewUserViewController ()
@property (weak, nonatomic) IBOutlet UITextField *nameTextField;
@property (weak, nonatomic) IBOutlet UIButton *letsGetStartedButton;
@property (weak, nonatomic) IBOutlet NSLayoutConstraint *topHeightConstraint;

@end

@implementation JHNewUserViewController

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
	
	//Keyboard dismissal
	
	UITapGestureRecognizer *gestureRecognizer = [[UITapGestureRecognizer alloc] initWithTarget:self action:@selector(hideKeyboard)];
	// For selecting cell.
	gestureRecognizer.cancelsTouchesInView = NO;
	[self.view addGestureRecognizer:gestureRecognizer];
	
	//Incoming animation
	self.letsGetStartedButton.transform = CGAffineTransformMakeScale(0.5, 0.5);
	self.letsGetStartedButton.alpha = 0.0;
	
	self.topHeightConstraint.constant = 0;
	[self.view updateConstraints];
	[self.view layoutIfNeeded];
}

- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

- (void)viewDidAppear:(BOOL)animated
{
	self.topHeightConstraint.constant = 126;
	[UIView animateWithDuration:0.6 animations:^{
		self.letsGetStartedButton.transform = CGAffineTransformMakeScale(1.0, 1.0);
		self.letsGetStartedButton.alpha = 1.0;
		[self.view updateConstraints];
		[self.view layoutIfNeeded];
	}];
}

- (void) hideKeyboard {
	[self.view endEditing:YES];
}

-(BOOL) textFieldShouldReturn:(UITextField *)textField{
	
    [textField resignFirstResponder];
    return YES;
}
- (IBAction)letsGetStartedTouched:(UIButton *)sender {
	if(self.nameTextField.text.length >= USERNAME_MIN_LENGTH && self.nameTextField.text.length <= USERNAME_MAX_LENGTH)
	{
		[[NSUserDefaults standardUserDefaults] setObject:self.nameTextField.text forKey:@"username"];
		//JHDiscalimerViewController *nextPage = [GeneralUI loadController:[JHDiscalimerViewController class]];
		JHIntroGraphicViewController *nextPage = [GeneralUI loadController:[JHIntroGraphicViewController class]];
		[self.navigationController pushViewController:nextPage animated:YES];
	}
}
@end
