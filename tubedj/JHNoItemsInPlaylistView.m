//
//  JHNoItemsInPlaylistView.m
//  tubedj
//
//  Created by Jordan Hamill on 08/08/2013.
//  Copyright (c) 2013 Jordan Hamill. All rights reserved.
//

#import "JHNoItemsInPlaylistView.h"

@interface JHNoItemsInPlaylistView()
@property (weak, nonatomic) IBOutlet UILabel *textLabel;

@end

@implementation JHNoItemsInPlaylistView

- (id)initWithFrame:(CGRect)frame
{
    self = [super initWithFrame:frame];
    if (self) {
        // Initialization code
    }
    return self;
}

- (void)awakeFromNib
{
	self.backgroundColor = [UIColor clearColor];
	self.textLabel.textColor = [UIColor app_green];
	self.textLabel.alpha = 0.4;
}

/*
// Only override drawRect: if you perform custom drawing.
// An empty implementation adversely affects performance during animation.
- (void)drawRect:(CGRect)rect
{
    // Drawing code
}
*/

@end
