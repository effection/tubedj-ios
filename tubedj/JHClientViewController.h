//
//  JHClientViewController.h
//  tubedj
//
//  Created by Jordan Hamill on 01/08/2013.
//  Copyright (c) 2013 Jordan Hamill. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "JHYouTubeSearchViewController.h"
#import "JHPlaylistViewController.h"
#import "ZBarSDK.h"
#import "WSCoachMarksView.h"
#import "JHSideMenu.h"

#define IS_WIDESCREEN ( fabs( ( double )[ [ UIScreen mainScreen ] bounds ].size.height - ( double )568 ) < DBL_EPSILON )
@interface JHClientViewController : UIViewController <JHYoutubeSearchViewControllerDelegate, JHPlaylistViewControllerDelegate, WSCoachMarksViewDelegate>

@property (weak, nonatomic) IBOutlet UIScrollView *scrollView;

@property (strong, readonly, nonatomic) JHSideMenu *sideMenu;

@end
