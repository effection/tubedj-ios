//
//  JHPlaylistHeader.m
//  tubedj
//
//  Created by Jordan Hamill on 08/08/2013.
//  Copyright (c) 2013 Jordan Hamill. All rights reserved.
//

#import "JHPlaylistHeader.h"

@interface JHPlaylistHeader()
@property (weak, nonatomic) IBOutlet UILabel *titleLabel;

@end

@implementation JHPlaylistHeader

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
	[super awakeFromNib];
	self.backgroundColor = [UIColor colorWithPatternImage:[UIImage imageNamed:@"search-background"]];
	self.titleLabel.text = @"Playlist";
	self.titleLabel.font = [UIFont systemFontOfSize:22.0];
	self.titleLabel.textColor = [UIColor app_blue];
}

@end
