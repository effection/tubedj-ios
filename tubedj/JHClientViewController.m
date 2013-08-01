//
//  JHClientViewController.m
//  tubedj
//
//  Created by Jordan Hamill on 01/08/2013.
//  Copyright (c) 2013 Jordan Hamill. All rights reserved.
//

#import "JHClientViewController.h"
#import "JHYoutubeSongCell.h"
#import "JHYouTubeSearchViewController.h"
#import "JHPlaylistViewController.h"

@interface JHClientViewController ()
@property (strong, nonatomic) JHYouTubeSearchViewController *youtubeSearchController;
@property (strong, nonatomic) JHPlaylistViewController *playlistController;

@end

@implementation JHClientViewController

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
	self.scrollView.backgroundColor = [UIColor clearColor];
	
	self.youtubeSearchController = [GeneralUI loadController:[JHYouTubeSearchViewController class]];
	self.playlistController = [GeneralUI loadController:[JHPlaylistViewController class]];
	UIView *searchView = self.youtubeSearchController.view;
	UIView *playlistView = self.playlistController.view;
	//searchView.backgroundColor = [UIColor redColor];
	//playlistView.backgroundColor = [UIColor greenColor];
	
	searchView.translatesAutoresizingMaskIntoConstraints = NO;
	playlistView.translatesAutoresizingMaskIntoConstraints = NO;
	[self.scrollView addSubview:searchView];
	[self.scrollView addSubview:playlistView];
	
	
	
	[self.view addConstraints:[NSLayoutConstraint constraintsWithVisualFormat:@"H:|[searchView(320)][playlistView(320)]|" options:0 metrics:nil views:NSDictionaryOfVariableBindings(searchView,playlistView)]];
	[self.view addConstraints:[NSLayoutConstraint constraintsWithVisualFormat:@"V:|[searchView(460)]|" options:0 metrics:nil views:NSDictionaryOfVariableBindings(searchView)]];
	[self.view addConstraints:[NSLayoutConstraint constraintsWithVisualFormat:@"V:|[playlistView(460)]|" options:0 metrics:nil views:NSDictionaryOfVariableBindings(playlistView)]];
	[self.view updateConstraints];
	[self.view layoutIfNeeded];
	
}

- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
   
	
}

@end
