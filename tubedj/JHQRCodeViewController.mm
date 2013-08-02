//
//  JHQRCodeViewController.m
//  tubedj
//
//  Created by Jordan Hamill on 01/08/2013.
//  Copyright (c) 2013 Jordan Hamill. All rights reserved.
//

#import "JHQRCodeViewController.h"
#import "QREncoder.h"


@interface JHQRCodeViewController ()
@property (weak, nonatomic) IBOutlet UIImageView *qrImageView;

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
	
    DataMatrix *dm = [QREncoder encodeWithECLevel:QR_ECLEVEL_AUTO version:QR_VERSION_AUTO string:@"Test"];
	UIImage *qrCode = [QREncoder renderDataMatrix:dm imageDimension:320];
	self.qrImageView.image = qrCode;
}

- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

@end
