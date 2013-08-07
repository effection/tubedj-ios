//
//  JHYoutubePlayer.h
//  tubedj
//
//  Created by Jordan Hamill on 07/08/2013.
//  Copyright (c) 2013 Jordan Hamill. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface JHYoutubePlayer : UIWebView

- (void)loadYoutubeVideo:(NSString *)videoId;
- (void)pauseYoutubeVideo;
@end
