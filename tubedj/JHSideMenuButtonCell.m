//
//  JHSideMenuButtonCell.m
//  tubedj
//
//  Created by Jordan Hamill on 13/08/2013.
//  Copyright (c) 2013 Jordan Hamill. All rights reserved.
//

#import "JHSideMenuButtonCell.h"

@implementation JHSideMenuButtonCell

- (void)commonInit
{
	[super commonInit];
	self.prefixLabel.textColor = [UIColor app_offWhite];
	self.titleLabel.textColor = [UIColor app_offWhite];
	self.titleLabel.font = [UIFont helveticaNeueRegularWithSize:22.0];
}

@end
