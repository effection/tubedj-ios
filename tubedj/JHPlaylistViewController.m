//
//  JHPlaylistViewController.m
//  tubedj
//
//  Created by Jordan Hamill on 01/08/2013.
//  Copyright (c) 2013 Jordan Hamill. All rights reserved.
//

#import "JHPlaylistViewController.h"
#import "RMSwipeTableViewCell.h"
#import "JHYoutubeSongCell.h"

@interface JHPlaylistViewController ()

@end

@implementation JHPlaylistViewController {
	
}

NSString * const PlaylistCellIdentifier = @"JHYoutubeSongCell";

- (id)initWithStyle:(UITableViewStyle)style
{
    self = [super initWithStyle:style];
    if (self) {
        // Custom initialization
    }
    return self;
}

- (void)viewDidLoad
{
    [super viewDidLoad];
	
    [self.tableView registerNib:[UINib nibWithNibName:@"JHYoutubeSongCell" bundle:[NSBundle mainBundle]] forCellReuseIdentifier:PlaylistCellIdentifier];
	
	self.view.backgroundColor = [UIColor clearColor];
	self.tableView.backgroundColor = [UIColor clearColor];
}

- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
}

#pragma mark - Table view data source

- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView
{
    return 1;
}

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section
{
    return 40;
}

- (float)tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath
{
	return 80;
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath
{
    JHYoutubeSongCell *cell = [tableView dequeueReusableCellWithIdentifier:PlaylistCellIdentifier];
	cell.canDelete = YES;
    return cell;
}


#pragma mark - Table view delegate

- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath
{
    
}
@end
