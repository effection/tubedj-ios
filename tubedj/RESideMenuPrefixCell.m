//
//  RESideMenuPrefixCell.m
//  tubedj
//
//  Created by Jordan Hamill on 01/08/2013.
//  Copyright (c) 2013 Jordan Hamill. All rights reserved.
//

#import "RESideMenuPrefixCell.h"

@interface RESideMenuPrefixCell()

- (void)commonInit;

@end

@implementation RESideMenuPrefixCell

- (id)initWithStyle:(UITableViewCellStyle)style reuseIdentifier:(NSString *)reuseIdentifier
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
}

- (void)layoutSubviews
{
    [super layoutSubviews];
    if (self.imageView.image) {
        self.imageView.frame = CGRectMake(self.horizontalOffset, self.imageView.frame.origin.y, self.imageView.frame.size.width, self.imageView.frame.size.height);
        self.textLabel.frame = CGRectMake(CGRectGetMaxX(self.imageView.frame) + 20.0, self.textLabel.frame.origin.y, self.textLabel.frame.size.width, self.textLabel.frame.size.height);
    } else {
        self.textLabel.frame = CGRectMake(self.horizontalOffset, self.textLabel.frame.origin.y, self.textLabel.frame.size.width, self.textLabel.frame.size.height);
    }
}

@end
