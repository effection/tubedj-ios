//
//  JHYouTubeSearchViewController.h
//  tubedj
//
//  Created by Jordan Hamill on 01/08/2013.
//  Copyright (c) 2013 Jordan Hamill. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "JHYoutubeClient.h"
#import "JHYoutubeSongCell.h"

@class JHYouTubeSearchViewController;

@protocol JHYoutubeSearchViewControllerDelegate <NSObject>

@optional

- (void)youtubeSearch:(JHYouTubeSearchViewController *)controller searchItemSelected:(NSString *)songId cell:(JHYoutubeSongCell *)cell;
- (void)youtubeSearch:(JHYouTubeSearchViewController *)controller requestToAddItemToPlaylist:(NSString *)songId cell:(JHYoutubeSongCell *)cell;

@end

@interface JHYouTubeSearchViewController : UITableViewController <UISearchBarDelegate, JHYoutubeClientDelegate, JHYoutubeSongCellDelegate>

@property (nonatomic, assign) id<JHYoutubeSearchViewControllerDelegate> delegate;

- (void)searchFor:(NSString *)searchText;
- (void)clearSearch;

@end
