//
//  JHSideMenuCell.h
//  tubedj
//
//  Created by Jordan Hamill on 13/08/2013.
//  Copyright (c) 2013 Jordan Hamill. All rights reserved.
//

#import <UIKit/UIKit.h>

@class JHSideMenu;

@interface JHSideMenuCell : UITableViewCell

@property (assign, readwrite, nonatomic) CGFloat horizontalOffset;

@property (copy, readwrite, nonatomic) void (^action)(JHSideMenu *menu, JHSideMenuCell *item);

- (void)commonInit;

@end
