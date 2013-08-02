//
//  RESideMenuPrefixCell.h
//  tubedj
//
//  Created by Jordan Hamill on 01/08/2013.
//  Copyright (c) 2013 Jordan Hamill. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface RESideMenuPrefixCell : UITableViewCell

@property (assign, readwrite, nonatomic) CGFloat horizontalOffset;

@property (weak, nonatomic) IBOutlet UILabel *prefixLabel;
@property (weak, nonatomic) IBOutlet UILabel *textLabel;

@end
