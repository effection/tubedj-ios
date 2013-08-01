//
//  UIColor+AppColours.m
//  tubedj
//
//  Created by Jordan Hamill on 01/08/2013.
//  Copyright (c) 2013 Jordan Hamill. All rights reserved.
//

#import "UIColor+AppColours.h"
#import "NSString+UIColor.h"

@implementation UIColor (AppColours)

+(UIColor *)colorWithR:(Byte)r G:(Byte)g B:(Byte)b A:(CGFloat)a
{
	return [UIColor colorWithRed:r/255.0 green:g/255.0 blue:b/255.0 alpha:a];
}

+ (UIColor *)app_darkGrey
{
	return [@"#3e4346" toUIColor];
}

+ (UIColor *)app_lightGrey
{
	return [@"#676666" toUIColor];
}

+ (UIColor *)app_blue
{
	return [@"#89a9b4" toUIColor];
}

+ (UIColor *)app_red
{
	return [@"#fb7363" toUIColor];
}

+ (UIColor *)app_green
{
	return [UIColor colorWithR:180 G:208 B:124 A:255];//return [@"#b4d07c" toUIColor];
}

+ (UIColor *)app_offWhite
{
	return [@"#e1e1e1" toUIColor];
}


@end
