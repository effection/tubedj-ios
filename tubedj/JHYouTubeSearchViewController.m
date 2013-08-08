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
#import "JHStandardYoutubeViewController.h"

@interface JHYouTubeSearchViewController ()

@end

@implementation JHYouTubeSearchViewController {
	JHYoutubeClient *youtubeClient;
	NSMutableArray *addedItems;
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
	searchBar.placeholder = @"search youtube";
	[searchBar setSearchFieldBackgroundImage:[UIImage imageNamed:@"search-background"] forState:UIControlStateNormal];
	[searchBar setImage:[UIImage imageNamed:@"search-icon"] forSearchBarIcon:UISearchBarIconSearch state:UIControlStateNormal];
	[[UITextField appearanceWhenContainedIn:[UISearchBar class], nil] setFont:[UIFont systemFontOfSize:18]];
	[[UITextField appearanceWhenContainedIn:[UISearchBar class], nil] setTextColor:[UIColor app_offWhite]];
	
	self.tableView.tableHeaderView = searchBar;
	self.tableView.contentInset = UIEdgeInsetsMake(0, 0, 80, 0);
	
	youtubeClient = [[JHYoutubeClient alloc] init];
	youtubeClient.delegate = self;
	addedItems = [[NSMutableArray alloc] initWithCapacity:5];
	
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
	//New search
	[addedItems removeAllObjects];
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

#pragma mark - JHYoutubeSongCell delegate

- (void)songCellTriggeredAddAction:(JHYoutubeSongCell *)cell
{
	if(cell.isPerformingAction) return;
	cell.isPerformingAction = YES;
	
	[addedItems addObject:cell.songId];
	if([self.delegate respondsToSelector:@selector(youtubeSearch:requestToAddItemToPlaylist:cell:)])
	{
		[self.delegate youtubeSearch:self requestToAddItemToPlaylist:cell.songId cell:(JHYoutubeSongCell *)cell];
	}
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
	cell.songId = searchItem.id;
	cell.titleLabel.text = searchItem.title;
	cell.ownerLabel.text = searchItem.author;
	cell.ageLabel.text = [[SORelativeDateTransformer registeredTransformer] transformedValue:searchItem.date];
	cell.actionSuccessful = [addedItems containsObject:searchItem.id];
	cell.revealDirection = ([addedItems containsObject:searchItem.id]) ? RMSwipeTableViewCellRevealDirectionNone : RMSwipeTableViewCellRevealDirectionLeft;
	cell.actionDelegate = self;
	[cell.previewImage setImageWithURL:searchItem.thumbnailUrl];
	
	if(!searchItem.canPlayOnDevice) {
		cell.revealDirection = RMSwipeTableViewCellRevealDirectionNone;
		cell.ageLabel.text = @"Can't play on host device";
		cell.ageLabel.textColor = [UIColor app_red];
		cell.ageLabel.alpha = 0.2;
		cell.titleLabel.alpha = 0.2;
		cell.previewImage.alpha = 0.2;
	}
	
	[cell.ageLabel sizeToFit];
	[cell.ownerLabel sizeToFit];
	
	if(indexPath.row >= youtubeClient.searchResults.count -1)
	{
		[youtubeClient nextSearchPage];
	}
	
	return cell;
}


#pragma mark - Table view delegate

- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath
{
    JHYoutubeSongCell *cell = (JHYoutubeSongCell *)[tableView cellForRowAtIndexPath:indexPath];
	NSLog(@"Clicked %@", cell.songId);
	if([self.delegate respondsToSelector:@selector(youtubeSearch:searchItemSelected:cell:)])
	{
		[self.delegate youtubeSearch:self searchItemSelected:cell.songId cell:cell];
	}
}

@end
