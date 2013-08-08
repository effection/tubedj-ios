//
//  RESideMenuEditCell.h
//  tubedj
//
//  Created by Jordan Hamill on 08/08/2013.
//  Copyright (c) 2013 Jordan Hamill. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface RESideMenuEditCell : UITableViewCell

@property (assign, readwrite, nonatomic) CGFloat horizontalOffset;

@property (weak, nonatomic) IBOutlet UILabel *prefixLabel;
@property (weak, nonatomic) IBOutlet UILabel *textLabel;
@property (weak, nonatomic) IBOutlet UITextField *editField;

@end
