//
//  JHNewUserViewController.m
//  tubedj
//
//  Created by Jordan Hamill on 04/08/2013.
//  Copyright (c) 2013 Jordan Hamill. All rights reserved.
//

#import "JHNewUserViewController.h"
#import "JHDiscalimerViewController.h"

@interface JHNewUserViewController ()
@property (weak, nonatomic) IBOutlet UITextField *nameTextField;

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
}

- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

- (void) hideKeyboard {
	[self.view endEditing:YES];
}

-(BOOL) textFieldShouldReturn:(UITextField *)textField{
	
    [textField resignFirstResponder];
    return YES;
}
- (IBAction)letsGetStartedTouched:(UIButton *)sender {
	if(self.nameTextField.text.length > 3)
	{
		[[NSUserDefaults standardUserDefaults] setObject:self.nameTextField.text forKey:@"username"];
		JHDiscalimerViewController *nextPage = [GeneralUI loadController:[JHDiscalimerViewController class]];
		[self.navigationController pushViewController:nextPage animated:YES];
	}
}
@end
