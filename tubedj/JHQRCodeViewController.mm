//
//  JHQRCodeViewController.m
//  tubedj
//
//  Created by Jordan Hamill on 01/08/2013.
//  Copyright (c) 2013 Jordan Hamill. All rights reserved.
//

#import "JHQRCodeViewController.h"
#import "QREncoder.h"
#import "JHTubeDjManager.h"
#import "JBWhatsAppActivity.h"

@interface JHQRCodeViewController ()

@property (weak, nonatomic) IBOutlet UIImageView *qrImageView;
@property (strong, nonatomic) UIButton *shareButton;

@end

@implementation JHQRCodeViewController 

- (id)initWithNibName:(NSString *)nibNameOrNil bundle:(NSBundle *)nibBundleOrNil
{
    self = [super initWithNibName:nibNameOrNil bundle:nibBundleOrNil];
    if (self) {
        // Custom initialization
    }
    return self;
}

- (void)viewDidLoad
{
    [super viewDidLoad];
	self.view.backgroundColor = [UIColor app_darkGrey];
	
	UIButton *doneButton = [[UIButton alloc] initWithFrame:CGRectMake(0, 0, 60, 44)];
	[doneButton setTitle:@"done" forState:UIControlStateNormal];
	[doneButton setTitleColor:[UIColor app_blue] forState:UIControlStateNormal];
	[doneButton addTarget:self action:@selector(doneButtonPressed:) forControlEvents:UIControlEventTouchUpInside];
	
	UIBarButtonItem *doneBarButton = [[UIBarButtonItem alloc] initWithCustomView:doneButton];
	self.navigationController.visibleViewController.navigationItem.rightBarButtonItem = doneBarButton;
	
	self.shareButton = [[UIButton alloc] initWithFrame:CGRectMake(0, 0, 60, 44)];
	self.shareButton.titleLabel.font = [UIFont fontAwesomeWithSize:24.0];
	[self.shareButton setTitle:[JHFontAwesome standardIcon:FontAwesome_Share] forState:UIControlStateNormal];
	[self.shareButton setTitleColor:[UIColor app_blue] forState:UIControlStateNormal];
	[self.shareButton addTarget:self action:@selector(shareButtonPressed:) forControlEvents:UIControlEventTouchUpInside];
	self.showsShareButton = NO;
	
	UIView *buttonView = [[UIView alloc] initWithFrame:CGRectMake(0, 0, 60, 44)];
    buttonView.bounds = CGRectOffset(buttonView.bounds, 0, -3);
    [buttonView addSubview:self.shareButton];
	
	UIBarButtonItem *shareBarButton = [[UIBarButtonItem alloc] initWithCustomView:buttonView];
	self.navigationController.visibleViewController.navigationItem.leftBarButtonItem = shareBarButton;

	
    
}

- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

- (void)setRoomId:(NSString *)roomId
{
	_roomId = roomId;
	DataMatrix *dm = [QREncoder encodeWithECLevel:QR_ECLEVEL_AUTO version:QR_VERSION_AUTO string:self.roomId];
	UIImage *qrCode = [QREncoder renderDataMatrix:dm imageDimension:320];
	self.qrImageView.image = qrCode;
}

- (void)setShowsShareButton:(BOOL)showsShareButton
{
	_showsShareButton = showsShareButton;
	self.shareButton.hidden = !showsShareButton;
}

- (void)shareButtonPressed:(id)sender
{
	WhatsAppMessage *whatsappMsg = [[WhatsAppMessage alloc]initWithMessage: [NSString stringWithFormat:@"Join my tubedj room: tubedj://join?%@", [JHTubeDjManager encryptRoomId:self.roomId]] forABID:nil];
	
	NSArray *items = [NSArray arrayWithObjects:whatsappMsg.text, whatsappMsg, nil];

	UIActivityViewController *activityVC =
	[[UIActivityViewController alloc] initWithActivityItems:items
									  applicationActivities:@[[[JBWhatsAppActivity alloc] init]]];
	
	activityVC.excludedActivityTypes = @[UIActivityTypePostToWeibo, UIActivityTypePostToFacebook, UIActivityTypePostToTwitter, UIActivityTypeAssignToContact, UIActivityTypeSaveToCameraRoll];
	
	activityVC.completionHandler = ^(NSString *activityType, BOOL completed)
	{
        NSLog(@" activityType: %@", activityType);
        NSLog(@" completed: %i", completed);
	};
	
	[self presentViewController:activityVC animated:YES completion:nil];
}

- (void)doneButtonPressed:(id)sender
{
	[self.navigationController dismissViewControllerAnimated:YES completion:nil];
}

@end
