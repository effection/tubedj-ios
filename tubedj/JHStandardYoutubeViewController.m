//
//  JHStandardYoutubeViewController.m
//  tubedj
//
//  Created by Jordan Hamill on 04/08/2013.
//  Copyright (c) 2013 Jordan Hamill. All rights reserved.
//

#import "JHStandardYoutubeViewController.h"

@interface JHStandardYoutubeViewController ()

@end

@implementation JHStandardYoutubeViewController

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
   
	self.webView.delegate = self;
	self.webView.scrollView.bounces = NO;
	self.webView.allowsInlineMediaPlayback = YES;
	
	//Navigation done button
	self.view.backgroundColor = [UIColor app_darkGrey];
	
	UIButton *doneButton = [[UIButton alloc] initWithFrame:CGRectMake(0, 0, 60, 44)];
	[doneButton setTitle:@"done" forState:UIControlStateNormal];
	[doneButton setTitleColor:[UIColor app_blue] forState:UIControlStateNormal];
	[doneButton addTarget:self action:@selector(doneButtonPressed:) forControlEvents:UIControlEventTouchUpInside];
	
	UIBarButtonItem *doneBarButton = [[UIBarButtonItem alloc] initWithCustomView:doneButton];
	self.navigationController.visibleViewController.navigationItem.rightBarButtonItem = doneBarButton;
	
}

- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
}

- (void)loadYouTubeEmbed:(NSString *)videoId
{
    NSString* searchQuery = [NSString stringWithFormat:@"http://www.youtube.com/embed/%@?showinfo=0&loop=1&modestbranding=1&controls=1&playsinline=1",videoId];
    searchQuery = [searchQuery stringByAddingPercentEscapesUsingEncoding: NSUTF8StringEncoding];
	
    NSURLRequest *request = [NSURLRequest requestWithURL:[NSURL URLWithString:searchQuery]];
    [self.webView loadRequest:request];
}

-(BOOL)webView:(UIWebView *)webView shouldStartLoadWithRequest:(NSURLRequest *)request navigationType:(UIWebViewNavigationType)navigationType {
    if ([[[request URL] absoluteString] isEqualToString:@"<URL String Youtube spits out when video selected>"]) {
        NSLog(@"Blocking YouTube...");
        return NO;
    } else {
        NSLog(@"Link is fine, continue...");
        return YES;
    }
}

- (void)doneButtonPressed:(id)sender
{
	[self.navigationController dismissViewControllerAnimated:YES completion:nil];
}

@end
