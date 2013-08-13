//
//  JHSideMenuEditCell.m
//  tubedj
//
//  Created by Jordan Hamill on 13/08/2013.
//  Copyright (c) 2013 Jordan Hamill. All rights reserved.
//

#import "JHSideMenuEditCell.h"

@implementation JHSideMenuEditCell

- (void)commonInit
{
	[super commonInit];
	self.editField.delegate = self;
	self.prefixLabel.textColor = [UIColor app_offWhite];
	self.editField.textColor = [UIColor app_offWhite];
	self.editField.font = [UIFont helveticaNeueRegularWithSize:22.0];
}

- (void)textFieldDidEndEditing:(UITextField *)textField
{
	if(self.action != nil)
		self.action(nil, self);
}

- (BOOL)textFieldShouldReturn:(UITextField *)textField
{
	if(self.action != nil)
		self.action(nil, self);
	return YES;
	
}

- (BOOL)textField:(UITextField *) textField shouldChangeCharactersInRange:(NSRange)range replacementString:(NSString *)string {
	
    NSUInteger oldLength = [textField.text length];
    NSUInteger replacementLength = [string length];
    NSUInteger rangeLength = range.length;
	
    NSUInteger newLength = oldLength - rangeLength + replacementLength;
	
    BOOL returnKey = [string rangeOfString: @"\n"].location != NSNotFound;
	
    return newLength <= USERNAME_MAX_LENGTH || returnKey;
}

@end
