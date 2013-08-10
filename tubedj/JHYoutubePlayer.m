//
//  JHYoutubePlayer.m
//  tubedj
//
//  Created by Jordan Hamill on 07/08/2013.
//  Copyright (c) 2013 Jordan Hamill. All rights reserved.
//

#import "JHYoutubePlayer.h"
#import <QuartzCore/QuartzCore.h>

@interface JHYoutubePlayer()

@property (strong, nonatomic) UIImageView *screenshot;

- (void)commonInit;

@end

@implementation JHYoutubePlayer {
	dispatch_once_t nextSongTriggerToken;
}

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
	self.backgroundColor = [UIColor clearColor];
	self.opaque=NO;
	self.scrollView.bounces = NO;
	self.mediaPlaybackRequiresUserAction = NO;
	self.allowsInlineMediaPlayback = YES;
	
	[self loadRequest:[NSURLRequest requestWithURL:[NSURL fileURLWithPath:[[NSBundle mainBundle] pathForResource:@"YT_Player" ofType:@"html"] isDirectory:NO]]];
	
	
	UIPanGestureRecognizer *panGesture = [[UIPanGestureRecognizer alloc] initWithTarget:self action:@selector(webviewSwiped:)];
	panGesture.delegate = self;
	[self addGestureRecognizer:panGesture];
	
	self.screenshot = [[UIImageView alloc] initWithFrame:CGRectOffset(self.bounds, self.bounds.size.width, 0)];
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

- (UIImage *)captureWebview
{
	UIGraphicsBeginImageContext(self.bounds.size);
	CGContextRef context = UIGraphicsGetCurrentContext();
	[self.layer renderInContext:context];
	UIImage *screenShot = UIGraphicsGetImageFromCurrentImageContext();
	UIGraphicsEndImageContext();
	return screenShot;
}

#pragma mark - Gesture recognizer delegate

-(BOOL)gestureRecognizerShouldBegin:(UIPanGestureRecognizer *)panGestureRecognizer
{
	nextSongTriggerToken = NO;
	
	self.screenshot.alpha = 1.0;
    self.screenshot.image = [self captureWebview];
	self.screenshot.frame = CGRectOffset(self.bounds, self.bounds.size.width, 0);
	
	[self addSubview:self.screenshot];
	
	return YES;
}

- (void)webviewSwiped:(UIPanGestureRecognizer *)panGestureRecognizer
{
	CGPoint translation = [panGestureRecognizer translationInView:panGestureRecognizer.view];
    CGPoint velocity = [panGestureRecognizer velocityInView:panGestureRecognizer.view];
    CGFloat panOffset = translation.x;

	if (ABS(translation.x) > 0)
	{
		CGFloat width = CGRectGetWidth(self.frame);
		CGFloat offset = abs(translation.x);
		
		panOffset = (offset * 1.0f * width) / (offset * 0.5f + width);
		panOffset *= translation.x < 0 ? -1.0f : 1.0f;
	}
	
	if (ABS(translation.x) > self.bounds.size.width * 0.6)
	{
		//Cancel it
		panGestureRecognizer.enabled = NO;
		panGestureRecognizer.enabled = YES;
		dispatch_once(&nextSongTriggerToken, ^{
			if([self.playerDelegate respondsToSelector:@selector(youtubePlayer:nextSong:)])
				[self.playerDelegate youtubePlayer:self nextSong:nil];
		});
	}
	
    CGPoint actualTranslation = CGPointMake(panOffset, translation.y);
    if (panGestureRecognizer.state == UIGestureRecognizerStateBegan && [panGestureRecognizer numberOfTouches] > 0) {
        [self animateContentViewForPoint:actualTranslation velocity:velocity];
    } else if (panGestureRecognizer.state == UIGestureRecognizerStateChanged && [panGestureRecognizer numberOfTouches] > 0) {
        [self animateContentViewForPoint:actualTranslation velocity:velocity];
	} else if (panGestureRecognizer.state == UIGestureRecognizerStateEnded || panGestureRecognizer.state == UIGestureRecognizerStateCancelled) {
		[self resetCellFromPoint:actualTranslation  velocity:velocity];
	}

}

-(void)animateContentViewForPoint:(CGPoint)point velocity:(CGPoint)velocity {
	UIView *viewToMove = self.screenshot;
    if (point.x < 0) {
        viewToMove.frame = CGRectOffset(CGRectOffset(viewToMove.bounds, self.bounds.size.width, 0), point.x, 0);
		self.frame = CGRectOffset(self.bounds, point.x, 0);
    } else if (point.x > 0) {
        viewToMove.frame = CGRectOffset(viewToMove.bounds, self.bounds.size.width, 0);
		self.frame = CGRectOffset(self.bounds, 0, 0);
    }
}

-(void)resetCellFromPoint:(CGPoint)point velocity:(CGPoint)velocity {
    if (point.x > 0) {
        return;
    }
	
	UIView *viewToMove = self.screenshot;
    if (YES) {
        [UIView animateWithDuration:0.4
                              delay:0
                            options:UIViewAnimationOptionCurveEaseIn
                         animations:^{
                             viewToMove.frame = CGRectOffset(viewToMove.bounds, 0, 0);
							 viewToMove.alpha = 0.0;
							 self.frame = CGRectOffset(self.bounds, 0, 0);
                         }
                         completion:^(BOOL finished) {
							 //[self.screenshot removeFromSuperview];
                         }
         ];
    }
}

- (BOOL)gestureRecognizer:(UIGestureRecognizer *)gestureRecognizer shouldRecognizeSimultaneouslyWithGestureRecognizer:(UIGestureRecognizer *)otherGestureRecognizer
{
    return YES;
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
