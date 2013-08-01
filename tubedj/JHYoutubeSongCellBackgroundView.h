//
//  JHYoutubeSongCellBackgroundView.h
//  tubedj
//
//  Created by Jordan Hamill on 01/08/2013.
//  Copyright (c) 2013 Jordan Hamill. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface JHYoutubeSongCellBackgroundView : UIView
@property (weak, nonatomic) IBOutlet UIButton *addButton;
@property (weak, nonatomic) IBOutlet UILabel *dot1;
@property (weak, nonatomic) IBOutlet UILabel *dot2;
@property (weak, nonatomic) IBOutlet UILabel *dot3;
@property (weak, nonatomic) IBOutlet UILabel *dot4;

@property (nonatomic, readwrite) BOOL canDelete;

@end
