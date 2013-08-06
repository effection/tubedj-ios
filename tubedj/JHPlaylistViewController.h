//
//  JHPlaylistViewController.h
//  tubedj
//
//  Created by Jordan Hamill on 01/08/2013.
//  Copyright (c) 2013 Jordan Hamill. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "JHYoutubeSongCell.h"

@class JHPlaylistViewController;

@protocol JHPlaylistViewControllerDelegate <NSObject>

@optional

- (void)playlist:(JHPlaylistViewController *)controller requestToRemoveItemFromPlaylist:(NSString *)uid cell:(JHYoutubeSongCell *)cell;

@end

@interface JHPlaylistViewController : UITableViewController <JHYoutubeSongCellDelegate>

@property (nonatomic, assign) id<JHPlaylistViewControllerDelegate> delegate;

@end
