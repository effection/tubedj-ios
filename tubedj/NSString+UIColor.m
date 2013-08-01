//
//  NSString+UIColor.m
//  tubedj
//
//  Created by Jordan Hamill on 01/08/2013.
//  Copyright (c) 2013 Jordan Hamill. All rights reserved.
//

#import "NSString+UIColor.h"

@implementation NSString (UIColor)

- (UIColor *)toUIColor {
	unsigned rgbValue = 0;
    NSScanner *scanner = [NSScanner scannerWithString:self];
    [scanner setScanLocation:1]; // bypass '#' character
    [scanner scanHexInt:&rgbValue];
	float alpha = 1.0;
	if(self.length == 9) {
		alpha = ((rgbValue & 0xFF000000) >> 24) / 255.0;
	}
	
    return [UIColor colorWithRed:((rgbValue & 0xFF0000) >> 16)/255.0 green:((rgbValue & 0xFF00) >> 8)/255.0 blue:(rgbValue & 0xFF)/255.0 alpha:alpha];
}

@end
