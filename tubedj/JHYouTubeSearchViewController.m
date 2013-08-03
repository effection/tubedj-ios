//
//  JHYouTubeSearchViewController.m
//  tubedj
//
//  Created by Jordan Hamill on 01/08/2013.
//  Copyright (c) 2013 Jordan Hamill. All rights reserved.
//

#import "JHYouTubeSearchViewController.h"
#import "RMSwipeTableViewCell.h"
#import "JHYoutubeSongCell.h"
#import "UIImageView+AFNetworking.h"
#import "SORelativeDateTransformer.h"

@interface JHYouTubeSearchViewController ()

@end

@implementation JHYouTubeSearchViewController {
	JHYoutubeClient *youtubeClient;
}

NSString * const CellIdentifier = @"JHYoutubeSongCell";

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

    [self.tableView registerNib:[UINib nibWithNibName:@"JHYoutubeSongCell" bundle:[NSBundle mainBundle]] forCellReuseIdentifier:CellIdentifier];

	self.view.backgroundColor = [UIColor clearColor];
	self.tableView.backgroundColor = [UIColor clearColor];
	
	UISearchBar *searchBar = [[UISearchBar alloc] initWithFrame:CGRectMake(0, 0, 320, 44)];
	[searchBar setBackgroundImage:[UIImage new]];
	searchBar.translucent = YES;
	searchBar.delegate = self;
	
	self.tableView.tableHeaderView = searchBar;
	self.tableView.contentInset = UIEdgeInsetsMake(0, 0, 80, 0);
	
	youtubeClient = [[JHYoutubeClient alloc] init];
	youtubeClient.delegate = self;
	
	//Keyboard dismissal

	UITapGestureRecognizer *gestureRecognizer = [[UITapGestureRecognizer alloc] initWithTarget:self action:@selector(hideKeyboard)];
	// For selecting cell.
	gestureRecognizer.cancelsTouchesInView = NO;
	[self.view addGestureRecognizer:gestureRecognizer];

}

- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
}

- (void)searchBarSearchButtonClicked:(UISearchBar *)searchBar
{
	NSString *searchText = searchBar.text;
	[youtubeClient searchFor:searchText];
	[self.view endEditing:YES];
}

- (void) hideKeyboard {
	[self.view endEditing:YES];
}

#pragma mark - JHYoutubeClientDelegate

- (void)youtubeClient:(JHYoutubeClient *)client searchStartedFor:(NSString *)search
{
	[self.tableView reloadData];
}

- (void)youtubeClient:(JHYoutubeClient *)client nextPageRequestedFor:(NSString *)search
{
	NSLog(@"Next page");
}

- (void)youtubeClient:(JHYoutubeClient *)client searchCompletedFor:(NSString *)search startingAt:(int)start withResults:(NSArray *)results
{
	NSMutableArray *indexArray = [[NSMutableArray alloc] initWithCapacity:results.count];
	
	for(int i = 0; i < results.count; i++)
	{
		[indexArray addObject:[NSIndexPath indexPathForRow:start + i - 1 inSection:0]];
	}
	
	[self.tableView beginUpdates];
	[self.tableView insertRowsAtIndexPaths:indexArray withRowAnimation:UITableViewRowAnimationRight];
	[self.tableView endUpdates];
}

#pragma mark - Scroll view delegate

- (void)scrollViewDidScroll:(UIScrollView *)scrollView
{
	
}

#pragma mark - Table view data source

- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView
{
    return 1;
}

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section
{
	return youtubeClient.searchResults.count;
}

- (float)tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath
{
	return 80;
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath
{
	JHYoutubeSongCell *cell = [tableView dequeueReusableCellWithIdentifier:CellIdentifier];
	cell.canDelete = NO;
	
	JHYoutubeSearchResult *searchItem = [youtubeClient.searchResults objectAtIndex:indexPath.row];
	cell.titleLabel.text = searchItem.title;
	cell.ownerLabel.text = searchItem.author;
	cell.ageLabel.text = [[SORelativeDateTransformer registeredTransformer] transformedValue:searchItem.date];
	[cell.previewImage setImageWithURL:searchItem.thumbnailUrl];
	
	if(indexPath.row >= youtubeClient.searchResults.count -1)
	{
		[youtubeClient nextSearchPage];
	}
	
	return cell;
}


#pragma mark - Table view delegate

- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath
{
    
}

@end
