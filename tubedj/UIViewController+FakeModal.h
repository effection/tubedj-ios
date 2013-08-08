//
//  UIViewController+FakeModal.h
//  tubedj
//
//  Created by Jordan Hamill on 08/08/2013.
//  Copyright (c) 2013 Jordan Hamill. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface UIViewController (FakeModal)

- (void)presentViewController:(UIViewController *)viewControllerToPresent animated:(BOOL)flag keepBehind:(BOOL)keepBehind completion:(void (^)(void))completion;

@end
