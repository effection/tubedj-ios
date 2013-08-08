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
	self.delegate = self;
	self.backgroundColor = [UIColor app_darkGrey];
	self.scrollView.bounces = NO;
	self.mediaPlaybackRequiresUserAction = NO;
	self.allowsInlineMediaPlayback = YES;
	
	[self loadRequest:[NSURLRequest requestWithURL:[NSURL fileURLWithPath:[[NSBundle mainBundle] pathForResource:@"YT_Player" ofType:@"html"] isDirectory:NO]]];
}

- (void)loadYoutubeVideo:(NSString *)videoId
{
	_videoId = videoId;
	NSLog(@"%@",[self stringByEvaluatingJavaScriptFromString:[NSString stringWithFormat:@"APP_loadVideoById('%@');", videoId]]);
}

- (void)playYoutubeVideo
{
	[self stringByEvaluatingJavaScriptFromString:@"APP_playVideo();"];
}

- (void)pauseYoutubeVideo
{
	[self stringByEvaluatingJavaScriptFromString:@"APP_pauseVideo();"];
}



- (BOOL)webView:(UIWebView *)webView shouldStartLoadWithRequest:(NSURLRequest *)request navigationType:(UIWebViewNavigationType)navigationType
{
	NSString *url = [[request URL] absoluteString];
    if ([url hasPrefix:@"tubedjapp:"]) {
		NSString *event = [url substringFromIndex:10];
		if([event isEqualToString:@"song-ended"])
		{
			if([self.playerDelegate respondsToSelector:@selector(youtubePlayer:songEnded:)])
			   [self.playerDelegate youtubePlayer:self songEnded:self.videoId];
		}
		
        return NO;
    }
    return YES;
	
}

@end
