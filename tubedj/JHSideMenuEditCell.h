//
//  JHSideMenuEditCell.h
//  tubedj
//
//  Created by Jordan Hamill on 13/08/2013.
//  Copyright (c) 2013 Jordan Hamill. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "JHSideMenuCell.h"

@interface JHSideMenuEditCell : JHSideMenuCell <UITextFieldDelegate>

@property (weak, nonatomic) IBOutlet UILabel *prefixLabel;
@property (weak, nonatomic) IBOutlet UITextField *editField;

@end
