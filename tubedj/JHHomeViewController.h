//
//  JHHomeViewController.h
//  tubedj
//
//  Created by Jordan Hamill on 04/08/2013.
//  Copyright (c) 2013 Jordan Hamill. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "ZBarSDK.h"
#import "RESideMenu.h"

@interface JHHomeViewController : UIViewController <ZBarReaderDelegate>

@property (strong, readonly, nonatomic) RESideMenu *sideMenu;

- (void)queueJoinRoom:(NSString *)roomId;

- (void)openJoinScreenOverrideCoachMarks:(BOOL)overrideShowingCoachMarks showQRCodeReader:(BOOL)showQRCodeReader;

- (IBAction)createButtonPressed:(UIButton *)sender;
- (IBAction)joinButtonPressed:(UIButton *)sender;

@end
