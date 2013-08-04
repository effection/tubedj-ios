//
//  JHPlaylistViewController.h
//  tubedj
//
//  Created by Jordan Hamill on 01/08/2013.
//  Copyright (c) 2013 Jordan Hamill. All rights reserved.
//

#import <UIKit/UIKit.h>

@class JHPlaylistViewController;

@protocol JHPlaylistViewControllerDelegate <NSObject>

@optional

- (void)playlist:(JHPlaylistViewController *)controller requestToRemoveItemFromPlaylist:(id)item;

@end

@interface JHPlaylistViewController : UITableViewController

@property (nonatomic, assign) id<JHPlaylistViewControllerDelegate> delegate;

@end
