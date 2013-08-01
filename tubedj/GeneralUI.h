//
//  GeneralUI.h
//  Why Dont We (ios6)
//
//  Created by Jordan Hamill on 04/07/2013.
//  Copyright (c) 2013 Jordan Hamill. All rights reserved.
//

#import <Foundation/Foundation.h>
#import	"UIFont+AppFonts.h"
#import	"UIColor+AppColours.h"
#import	"JHFontAwesome.h"

@interface GeneralUI : NSObject

//Loading
+ (id)loadViewFromNib:(Class)classType;
+ (id)loadController:(Class)classType;

//Backgrounds
+ (void)setViewBackground:(UIView*)view;
+ (void)fillView:(UIView *)view insideView:(UIView *)container;




@end
