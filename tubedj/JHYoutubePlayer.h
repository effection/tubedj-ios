//
//  JHYoutubePlayer.h
//  tubedj
//
//  Created by Jordan Hamill on 07/08/2013.
//  Copyright (c) 2013 Jordan Hamill. All rights reserved.
//

#import <UIKit/UIKit.h>

@class JHYoutubePlayer;

@protocol JHYoutubePlayerDelegate <NSObject>

@optional

- (void)youtubePlayer:(JHYoutubePlayer *)player songEnded:(NSString *)videoId;
- (BOOL)youtubePlayerCanSwipeToNextSong:(JHYoutubePlayer *)player;
- (void)youtubePlayer:(JHYoutubePlayer *)player nextSong:(NSString *)currentVideoId;

@end

@interface JHYoutubePlayer : UIWebView <UIWebViewDelegate, UIGestureRecognizerDelegate>

@property (nonatomic, readonly) NSString *videoId;
@property (nonatomic, assign) id<JHYoutubePlayerDelegate> playerDelegate;

- (void)loadYoutubeVideo:(NSString *)videoId;
- (void)playYoutubeVideo;
- (void)pauseYoutubeVideo;
@end
