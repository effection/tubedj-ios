//
//  JHStandardYoutubeViewController.h
//  tubedj
//
//  Created by Jordan Hamill on 04/08/2013.
//  Copyright (c) 2013 Jordan Hamill. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface JHStandardYoutubeViewController : UIViewController <UIWebViewDelegate>

@property (nonatomic, readonly) NSString *videoId;

@property (weak, nonatomic) IBOutlet UIWebView *webView;

- (void)loadYouTubeEmbed:(NSString *)videoId;

@end
