//
//  JHYoutubeSongCellBackgroundView.m
//  tubedj
//
//  Created by Jordan Hamill on 01/08/2013.
//  Copyright (c) 2013 Jordan Hamill. All rights reserved.
//

#import "JHYoutubeSongCellBackgroundView.h"

@interface JHYoutubeSongCellBackgroundView()

- (void)commonInit;

@end

@implementation JHYoutubeSongCellBackgroundView

- (id)initWithFrame:(CGRect)frame
{
    self = [super initWithFrame:frame];
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
	self.backgroundColor = [UIColor app_darkGrey];
	self.addButton.titleLabel.font = [UIFont fontAwesomeWithSize:48.0f];
	self.dot1.font = [UIFont fontAwesomeWithSize:26.0f];
	self.dot2.font = [UIFont fontAwesomeWithSize:26.0f];
	self.dot3.font = [UIFont fontAwesomeWithSize:26.0f];
	self.dot4.font = [UIFont fontAwesomeWithSize:26.0f];

	self.dot1.text = [JHFontAwesome standardIcon:FontAwesome_Circle]; [self.dot1 sizeToFit];
	self.dot2.text = [JHFontAwesome standardIcon:FontAwesome_Circle]; [self.dot2 sizeToFit];
	self.dot3.text = [JHFontAwesome standardIcon:FontAwesome_Circle]; [self.dot3 sizeToFit];
	self.dot4.text = [JHFontAwesome standardIcon:FontAwesome_Circle]; [self.dot4 sizeToFit];
	
	[self.addButton setTitle:[JHFontAwesome standardIcon:FontAwesome_Ok] forState:UIControlStateNormal];
}

- (void)setCanDelete:(BOOL)canDelete
{
	if(_canDelete == canDelete) return;
	
	_canDelete = canDelete;
	if(canDelete)
	{
		[self.addButton setTitle:[JHFontAwesome standardIcon:FontAwesome_Trash] forState:UIControlStateNormal];
		[self.addButton setTitleColor:[UIColor app_red] forState:UIControlStateNormal];
		
		self.addButton.center = CGPointMake(self.addButton.center.x - 30, self.addButton.center.y);
		
		self.dot1.center = CGPointMake(320 - self.dot1.center.x, self.dot1.center.y);
		self.dot2.center = CGPointMake(320 - self.dot2.center.x, self.dot2.center.y);
		self.dot3.center = CGPointMake(320 - self.dot3.center.x, self.dot3.center.y);
		self.dot4.center = CGPointMake(320 - self.dot4.center.x, self.dot4.center.y);
		
		self.dot1.textColor = [UIColor app_red];
		self.dot2.textColor = [UIColor app_red];
		self.dot3.textColor = [UIColor app_red];
		self.dot4.textColor = [UIColor app_red];

	} else
	{
		[self.addButton setTitle:[JHFontAwesome standardIcon:FontAwesome_Ok] forState:UIControlStateNormal];
		[self.addButton setTitleColor:[UIColor app_green] forState:UIControlStateNormal];
		
		self.dot1.textColor = [UIColor app_green];
		self.dot2.textColor = [UIColor app_green];
		self.dot3.textColor = [UIColor app_green];
		self.dot4.textColor = [UIColor app_green];

	}
}

@end
