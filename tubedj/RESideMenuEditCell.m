//
//  RESideMenuEditCell.m
//  tubedj
//
//  Created by Jordan Hamill on 08/08/2013.
//  Copyright (c) 2013 Jordan Hamill. All rights reserved.
//

#import "RESideMenuEditCell.h"

@interface RESideMenuEditCell()

- (void)commonInit;

@end

@implementation RESideMenuEditCell

-  (id)initWithStyle:(UITableViewCellStyle)style reuseIdentifier:(NSString *)reuseIdentifier
{
    self = [super initWithStyle:style reuseIdentifier:reuseIdentifier];
    if (self) {
		[self commonInit];
    }
    return self;
}

- (void)awakeFromNib
{
	[super awakeFromNib];
	[self commonInit];
}

- (void)commonInit
{
	self.prefixLabel.font = [UIFont fontAwesomeWithSize:48];
	self.editField.font = [UIFont systemFontOfSize:17.0];
	self.editField.textColor = [UIColor app_offWhite];
}

- (void)layoutSubviews
{
    //[super layoutSubviews];
	
	//self.textLabel.frame = CGRectMake(self.horizontalOffset, self.textLabel.frame.origin.y, self.textLabel.frame.size.width, self.textLabel.frame.size.height);
}

- (void) setHighlighted:(BOOL)highlighted
{
	
}

- (void)setSelected:(BOOL)selected animated:(BOOL)animated
{
    [super setSelected:selected animated:animated];
}


@end
