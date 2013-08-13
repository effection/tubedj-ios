//
//  JHSideMenuToggleCell.m
//  tubedj
//
//  Created by Jordan Hamill on 13/08/2013.
//  Copyright (c) 2013 Jordan Hamill. All rights reserved.
//

#import "JHSideMenuToggleCell.h"

@implementation JHSideMenuToggleCell

- (void)commonInit
{
	[super commonInit];
	_on = NO;
	self.titleLabel.font = [UIFont helveticaNeueRegularWithSize:22.0];
	self.titleLabel.highlightedTextColor = [UIColor app_lightGrey];
	
	UITapGestureRecognizer *tapGesture = [[UITapGestureRecognizer alloc] initWithTarget:self action:@selector(handleTap:)];
	tapGesture.numberOfTapsRequired = 1;
	tapGesture.cancelsTouchesInView = NO;
	[self addGestureRecognizer:tapGesture];
}

- (void)setSelected:(BOOL)selected animated:(BOOL)animated
{
	
}

- (void)handleTap:(UIGestureRecognizer *)sender {
	
    _on = !_on;
	[UIView animateWithDuration:0.2 animations:^{
		self.prefixLabel.transform = CGAffineTransformMakeScale(0.8, 0.8);
	} completion:^(BOOL finished) {
		[UIView animateWithDuration:0.2 animations:^{
			self.prefixLabel.transform = CGAffineTransformIdentity;
			self.prefixLabel.textColor = _on ? self.onColour : self.offColour;
			self.prefixLabel.text = _on ? self.onIcon : self.offIcon;
		}];
	}];
	
}

@end
