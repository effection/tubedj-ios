//
//  UIViewController+FakeModal.m
//  tubedj
//
//  Created by Jordan Hamill on 08/08/2013.
//  Copyright (c) 2013 Jordan Hamill. All rights reserved.
//

#import "UIViewController+FakeModal.h"

@implementation UIViewController (FakeModal)

- (void)presentViewController:(UIViewController *)viewControllerToPresent animated:(BOOL)flag keepBehind:(BOOL)keepBehind completion:(void (^)(void))completion
{
	if(!keepBehind) {
		[self presentViewController:viewControllerToPresent animated:flag completion:completion];
		return;
	}
	
	UIView *theView = viewControllerToPresent.view;
	CGFloat height = theView.frame.size.height;
	
	//theView.hidden = YES;
	
	[self.view addSubview:theView];
	[self.view addConstraints:[NSLayoutConstraint constraintsWithVisualFormat:@"H:|[theView]|" options:0 metrics:nil views:NSDictionaryOfVariableBindings(theView)]];
	[self.view addConstraints:[NSLayoutConstraint constraintsWithVisualFormat:@"V:[theView]|" options:0 metrics:nil views:NSDictionaryOfVariableBindings(theView)]];
	NSLayoutConstraint *heightConstraint = [NSLayoutConstraint constraintWithItem:theView
																		attribute:NSLayoutAttributeHeight
																		relatedBy:NSLayoutRelationEqual
																		   toItem:nil
																		attribute:NSLayoutAttributeNotAnAttribute
																	   multiplier:1
																		 constant:0];
	[self.view addConstraint:heightConstraint];
	[self.view updateConstraints];
	[self.view layoutIfNeeded];
	
	heightConstraint.constant = height;
	
	[UIView animateWithDuration:0.3 animations:^{
		[self.view updateConstraints];
		[self.view layoutIfNeeded];
	}];
	
}

- (void)dismissHalfViewControllerAnimated:(BOOL)flag completion:(void (^)(void))completion
{
	
}

@end
