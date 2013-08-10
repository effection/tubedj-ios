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
#import "JHTubeDjManager.h"
#import "JHYoutubeClient.h"
#import "UIImageView+AFNetworking.h"
#import "JHNoItemsInPlaylistView.h"
#import "JHPlaylistHeader.h"

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

- (void)addNotificationObservers
{
	[[NSNotificationCenter defaultCenter] addObserver:self
											 selector:@selector(tubedjPlaylistRefreshed:)
												 name:@"tubedj-playlist-refresh"
											   object:nil];
	
	[[NSNotificationCenter defaultCenter] addObserver:self
											 selector:@selector(tubedjPlaylistAddedSong:)
												 name:@"tubedj-playlist-added-song"
											   object:nil];
	
	[[NSNotificationCenter defaultCenter] addObserver:self
											 selector:@selector(tubedjPlaylistRemovedSong:)
												 name:@"tubedj-playlist-removed-song"
											   object:nil];
	
	[[NSNotificationCenter defaultCenter] addObserver:self
											 selector:@selector(tubedjPlaylistNextSong:)
												 name:@"tubedj-next-song"
											   object:nil];

}

- (void)removeNotificationObservers
{
	[[NSNotificationCenter defaultCenter] removeObserver:self name:@"tubedj-playlist-refresh" object:nil];
	[[NSNotificationCenter defaultCenter] removeObserver:self name:@"tubedj-playlist-added-song" object:nil];
	[[NSNotificationCenter defaultCenter] removeObserver:self name:@"tubedj-playlist-removed-song" object:nil];
	[[NSNotificationCenter defaultCenter] removeObserver:self name:@"tubedj-next-song" object:nil];
}

- (void)viewDidAppear:(BOOL)animated
{
}

- (void)viewDidDisappear:(BOOL)animated
{
}

- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
}

- (void)tubedjPlaylistNextSong:(NSNotification *) notification
{
	[self.tableView beginUpdates];
	NSIndexPath *indexPath = [NSIndexPath indexPathForRow:0 inSection:1];
	[self.tableView deleteRowsAtIndexPaths:@[indexPath] withRowAnimation:UITableViewRowAnimationAutomatic];
	[self.tableView endUpdates];
	
	JHYoutubeSongCell *cell = (JHYoutubeSongCell *)[self.tableView cellForRowAtIndexPath:[NSIndexPath indexPathForRow:0 inSection:1]];
	cell.isPlaying = YES;
}

- (void)tubedjPlaylistRefreshed:(NSNotification *) notification
{
	[self.tableView reloadData];
}

- (void)tubedjPlaylistAddedSong:(NSNotification *) notification
{
	JHPlaylistItem *song = [notification.userInfo objectForKey:@"song"];
	if(song) {
		[self.tableView beginUpdates];
		NSIndexPath *indexPath = [NSIndexPath indexPathForRow:[[notification.userInfo objectForKey:@"index"] integerValue] inSection:1];
		NSLog(@"adding song at %i playlist.count = %i", indexPath.row, [JHTubeDjManager sharedManager].playlist.count);
		[self.tableView insertRowsAtIndexPaths:@[indexPath] withRowAnimation:UITableViewRowAnimationAutomatic];
		[self.tableView endUpdates];
	}
}

- (void)tubedjPlaylistRemovedSong:(NSNotification *) notification
{
	[self.tableView beginUpdates];
	NSIndexPath *indexPath = [NSIndexPath indexPathForRow:[[notification.userInfo objectForKey:@"index"] integerValue] inSection:1];
	[self.tableView deleteRowsAtIndexPaths:@[indexPath] withRowAnimation:UITableViewRowAnimationAutomatic];

	[self.tableView endUpdates];
}

#pragma mark - JHYoutubeSongCell delegate

- (void)songCellTriggeredDeleteAction:(JHYoutubeSongCell *)cell
{
	if(cell.isPerformingAction) return;
	cell.isPerformingAction = YES;
	
	if([self.delegate respondsToSelector:@selector(playlist:requestToRemoveItemFromPlaylist:cell:)])
	{
		NSIndexPath *indexPath = [(UITableView *)self.tableView indexPathForCell: cell];
		JHPlaylistItem *song = [JHTubeDjManager sharedManager].playlist[indexPath.row];
		[self.delegate playlist:self requestToRemoveItemFromPlaylist:song.uid cell:cell];
	}
}

#pragma mark - Table view data source

- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView
{
    return 2;
}

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section
{
	if(section == 0)
		return 0;
	else if(section == 1)
		return [JHTubeDjManager sharedManager].playlist.count;
	else
		return 0;
}

- (float)tableView:(UITableView *)tableView heightForHeaderInSection:(NSInteger)section
{
	if(section == 0)
		return 44;
	else if(section == 1) 
		return 0;//return ([JHTubeDjManager sharedManager].playlist.count > 0) ? 0 : 40;
	else
		return 0;
}

- (float)tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath
{
	return 80;
}

- (UIView *)tableView:(UITableView *)tableView viewForHeaderInSection:(NSInteger)section
{
	if(section == 0)
	{
		UIView *header = [GeneralUI loadViewFromNib:[JHPlaylistHeader class]];
		return header;
	} /*else if(section == 1 && [JHTubeDjManager sharedManager].playlist.count == 0)
	{
		UIView *header = [GeneralUI loadViewFromNib:[JHNoItemsInPlaylistView class]];
		return header;
	} else if(section == 1 && [JHTubeDjManager sharedManager].playlist.count > 0)
	{
		return nil;
	} */else {
		return nil;
	}
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath
{
    JHYoutubeSongCell *cell = [tableView dequeueReusableCellWithIdentifier:PlaylistCellIdentifier];
	JHPlaylistItem *song = [JHTubeDjManager sharedManager].playlist[indexPath.row];
	
	cell.canDelete = [[JHTubeDjManager sharedManager] isUserMe:song.ownerId] || [[JHTubeDjManager sharedManager] isRoomOwner];
	cell.actionDelegate = self;
	cell.ageLabel.text = ((JHUserItem *)[[JHTubeDjManager sharedManager].users objectForKey:song.ownerId]).name;
	cell.isPlaying = 0 == indexPath.row;
	if(song.isYoutube)
	{
		[JHYoutubeClient getSongDetails:song.songId success:^(JHYoutubeSearchResult *result) {
			cell.songId = result.id;
			cell.titleLabel.text = result.title;
			cell.ownerLabel.text = result.author;
			[cell.previewImage setImageWithURL:result.thumbnailUrl];
		} error:^(NSError *error) {
			cell.titleLabel.text = @"Error loading youtube";
			cell.ownerLabel.text = @"";
		}];
	}
    return cell;
}


//TODO
// * Check all error routines 
// * sanitise all room id's going to manager/in manager so web end doesnt barf.
// * test all initial start up error paths



#pragma mark - Table view delegate

- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath
{
    
}
@end
