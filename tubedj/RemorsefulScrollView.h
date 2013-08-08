//
//  RemorsefulScrollView.h
//  tubedj
//
//  Created by Jordan Hamill on 08/08/2013.
//  Copyright (c) 2013 Jordan Hamill. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface RemorsefulScrollView : UIScrollView {
	CGPoint _originalPoint;
	BOOL _isHorizontalScroll, _isMultitouch;
	UIView *_currentChild;
}
@end
