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

- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
}

- (void)tubedjPlaylistNextSong:(NSNotification *) notification
{
	[self.tableView beginUpdates];
	NSIndexPath *indexPath = [NSIndexPath indexPathForRow:0 inSection:0];
	[self.tableView deleteRowsAtIndexPaths:@[indexPath] withRowAnimation:UITableViewRowAnimationAutomatic];
	[self.tableView endUpdates];
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
		NSIndexPath *indexPath = [NSIndexPath indexPathForRow:[[notification.userInfo objectForKey:@"index"] integerValue] inSection:0];
		[self.tableView insertRowsAtIndexPaths:@[indexPath] withRowAnimation:UITableViewRowAnimationAutomatic];
		[self.tableView endUpdates];
	}
}

- (void)tubedjPlaylistRemovedSong:(NSNotification *) notification
{
	[self.tableView beginUpdates];
	NSIndexPath *indexPath = [NSIndexPath indexPathForRow:[[notification.userInfo objectForKey:@"index"] integerValue] inSection:0];
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
    return 1;
}

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section
{
    return [JHTubeDjManager sharedManager].playlist.count;
}

- (float)tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath
{
	return 80;
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath
{
    JHYoutubeSongCell *cell = [tableView dequeueReusableCellWithIdentifier:PlaylistCellIdentifier];
	JHPlaylistItem *song = [JHTubeDjManager sharedManager].playlist[indexPath.row];
	
	cell.canDelete = [[JHTubeDjManager sharedManager] isUserMe:song.ownerId];
	cell.actionDelegate = self;
	cell.ageLabel.text = ((JHUserItem *)[[JHTubeDjManager sharedManager].users objectForKey:song.ownerId]).name;

	if(song.isYoutube)
	{
		[JHYoutubeClient getSongDetails:song.songId success:^(JHYoutubeSearchResult *result) {
			cell.songId = result.id;
			cell.titleLabel.text = result.title;
			cell.ownerLabel.text = result.author;
			[cell.previewImage setImageWithURL:result.thumbnailUrl];
		} error:^(NSError *error) {
			//TODO Error
		}];
	}
    return cell;
}


//TODO
// * Check all error routines 

// * register in JHPlaylistViewController for playlist updates and update the table as needed

// * Deal with song owners so only song owners and room owner can swipe to delete songs


// * change all JHTubeDjManager notifications except request errors to be generic updates on the whole state such as websocket updates of playlist!!
// * register for next-song notifcation and update table view in JHPlalistViewController to show next song playing and remove items from playlist previous
// * sanitise all room id's going to manager/in manager so web end doesnt barf.
// * test all initial start up error paths



#pragma mark - Table view delegate

- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath
{
    
}
@end
