//
//  GeneralUI.m
//  Why Dont We (ios6)
//
//  Created by Jordan Hamill on 04/07/2013.
//  Copyright (c) 2013 Jordan Hamill. All rights reserved.
//

#import "GeneralUI.h"

@implementation GeneralUI

+ (void)setViewBackground:(UIView*)view
{
	[view setBackgroundColor:[UIColor colorWithPatternImage:[UIImage imageNamed:@"app-background"]]];
}

+ (void)fillView:(UIView *)view insideView:(UIView *)container
{
	[container addSubview:view];
	[container addConstraints:[NSLayoutConstraint constraintsWithVisualFormat:@"H:|[view]|" options:0 metrics:nil views:NSDictionaryOfVariableBindings(view)]];
	[container addConstraints:[NSLayoutConstraint constraintsWithVisualFormat:@"V:|[view]|" options:0 metrics:nil views:NSDictionaryOfVariableBindings(view)]];
}

+ (id)loadViewFromNib:(Class)classType
{
	NSString *className = NSStringFromClass(classType);

	UIView *view = [[classType alloc] init];
	view = [[[NSBundle mainBundle] loadNibNamed:className owner:view options:nil] objectAtIndex:0];

	return view;
}

+ (id)loadController:(Class)classType
{
    NSString *className = NSStringFromClass(classType);
    UIViewController *controller = [[classType alloc] initWithNibName:className bundle:nil];
    return controller;
}

@end
