//
//  JHYoutubePlayer.m
//  tubedj
//
//  Created by Jordan Hamill on 07/08/2013.
//  Copyright (c) 2013 Jordan Hamill. All rights reserved.
//

#import "JHYoutubePlayer.h"

@interface JHYoutubePlayer()

- (void)commonInit;

@end

@implementation JHYoutubePlayer

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
	self.scrollView.bounces = NO;
	self.mediaPlaybackRequiresUserAction = NO;
	self.allowsInlineMediaPlayback = YES;
}

- (void)loadYoutubeVideo:(NSString *)videoId
{
	[self loadRequest:[NSURLRequest requestWithURL:[NSURL fileURLWithPath:[[NSBundle mainBundle] pathForResource:@"YT_Player" ofType:@"html"] isDirectory:NO]]];
}

- (void)pauseYoutubeVideo
{
	
}

@end
