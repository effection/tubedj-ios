//
//  JHSideMenu.h
//  tubedj
//
//  Created by Jordan Hamill on 13/08/2013.
//  Copyright (c) 2013 Jordan Hamill. All rights reserved.
//

#import <Foundation/Foundation.h>
#import <UIKit/UIKit.h>
#import <QuartzCore/QuartzCore.h>
#import "UIWindow+RESideMenuExtensions.h"
#import "REBackgroundView.h"
#import "JHSideMenuCell.h"
#import "JHSideMenuButtonCell.h"
#import "JHSideMenuEditCell.h"
#import "JHSideMenuToggleCell.h"

@interface JHSideMenu : NSObject <UITableViewDataSource, UITableViewDelegate, UITextFieldDelegate>

@property (strong, readonly, nonatomic) NSArray *items;
@property (assign, readwrite, nonatomic) CGFloat verticalOffset;
@property (assign, readwrite, nonatomic) CGFloat horizontalOffset;
@property (assign, readwrite, nonatomic) CGFloat itemHeight;
@property (strong, readwrite, nonatomic) UIFont *font;
@property (strong, readwrite, nonatomic) UIColor *textColor;
@property (strong, readwrite, nonatomic) UIColor *highlightedTextColor;
@property (strong, readwrite, nonatomic) UIImage *backgroundImage;
@property (assign, readwrite, nonatomic) BOOL hideStatusBarArea;

- (id)initWithItems:(NSArray *)items;
- (void)show;
- (void)hide;
- (void)setRootViewController:(UIViewController *)viewController;

- (void) hideKeyboard;

@end
