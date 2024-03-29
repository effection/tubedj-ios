//
//  JHYoutubeSongCell.h
//  tubedj
//
//  Created by Jordan Hamill on 01/08/2013.
//  Copyright (c) 2013 Jordan Hamill. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "RMSwipeTableViewCell.h"

@class JHYoutubeSongCell;

@protocol JHYoutubeSongCellDelegate <NSObject>

@optional

- (void)songCellTriggeredAddAction:(JHYoutubeSongCell *)cell;
- (void)songCellTriggeredDeleteAction:(JHYoutubeSongCell *)cell;

@end

@interface JHYoutubeSongCell : RMSwipeTableViewCell <RMSwipeTableViewCellDelegate>

@property (nonatomic, assign) id<JHYoutubeSongCellDelegate>actionDelegate;

@property (nonatomic, readwrite) BOOL isPerformingAction;

@property (nonatomic, readwrite) BOOL canDelete;

@property (nonatomic, readwrite) BOOL actionSuccessful;

@property (nonatomic, readwrite) BOOL isPlaying;

@property (strong, nonatomic) NSString *songId;
@property (weak, nonatomic) IBOutlet UIImageView *previewImage;
@property (weak, nonatomic) IBOutlet UILabel *titleLabel;
@property (weak, nonatomic) IBOutlet UILabel *ownerLabel;
@property (weak, nonatomic) IBOutlet UILabel *ageLabel;

@end
