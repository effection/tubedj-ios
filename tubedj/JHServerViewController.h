//
//  JHServerViewController.h
//  tubedj
//
//  Created by Jordan Hamill on 07/08/2013.
//  Copyright (c) 2013 Jordan Hamill. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "RESideMenu.h"
#import "JHYouTubeSearchViewController.h"
#import "JHPlaylistViewController.h"

#define IS_WIDESCREEN ( fabs( ( double )[ [ UIScreen mainScreen ] bounds ].size.height - ( double )568 ) < DBL_EPSILON )
@interface JHServerViewController : UIViewController <JHYoutubeSearchViewControllerDelegate, JHPlaylistViewControllerDelegate>
@property (strong, readonly, nonatomic) RESideMenu *sideMenu;

@property (nonatomic, readwrite) BOOL isPlaying;
@property (nonatomic, strong) NSString *currentSongId;

@end
