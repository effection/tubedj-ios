//
//  JHServerViewController.h
//  tubedj
//
//  Created by Jordan Hamill on 07/08/2013.
//  Copyright (c) 2013 Jordan Hamill. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "JHYouTubeSearchViewController.h"
#import "JHPlaylistViewController.h"
#import "JHYoutubePlayer.h"
#import "WSCoachMarksView.h"
#import "JHSideMenu.h"

#define IS_WIDESCREEN ( fabs( ( double )[ [ UIScreen mainScreen ] bounds ].size.height - ( double )568 ) < DBL_EPSILON )
@interface JHServerViewController : UIViewController <JHYoutubeSearchViewControllerDelegate, JHPlaylistViewControllerDelegate, JHYoutubePlayerDelegate, WSCoachMarksViewDelegate>

@property (strong, readonly, nonatomic) JHSideMenu *sideMenu;

@property (nonatomic, readwrite) BOOL isPlaying;
@property (nonatomic, strong) NSString *currentSongId;

@end
