//
//  JHYoutubeSongCell.h
//  tubedj
//
//  Created by Jordan Hamill on 01/08/2013.
//  Copyright (c) 2013 Jordan Hamill. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "RMSwipeTableViewCell.h"

@interface JHYoutubeSongCell : RMSwipeTableViewCell <RMSwipeTableViewCellDelegate>

@property (nonatomic, readwrite) BOOL canDelete;

@end
