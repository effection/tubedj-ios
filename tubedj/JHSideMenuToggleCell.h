//
//  JHSideMenuToggleCell.h
//  tubedj
//
//  Created by Jordan Hamill on 13/08/2013.
//  Copyright (c) 2013 Jordan Hamill. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "JHSideMenuButtonCell.h"

@interface JHSideMenuToggleCell : JHSideMenuButtonCell

@property (nonatomic, readwrite) BOOL on;

@property (weak, nonatomic) IBOutlet UILabel *prefixLabel;
@property (weak, nonatomic) IBOutlet UILabel *titleLabel;

@property (nonatomic, copy) NSString *offIcon;
@property (nonatomic, copy) NSString *onIcon;

@property (nonatomic, copy) UIColor *offColour;
@property (nonatomic, copy) UIColor *onColour;

@end
