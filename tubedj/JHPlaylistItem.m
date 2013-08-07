//
//  JHPlaylistItem.m
//  tubedj
//
//  Created by Jordan Hamill on 06/08/2013.
//  Copyright (c) 2013 Jordan Hamill. All rights reserved.
//

#import "JHPlaylistItem.h"

@implementation JHPlaylistItem

+ (JHPlaylistItem *)fromJSON:(id)JSON
{
	JHPlaylistItem *song = [[JHPlaylistItem alloc] init];
	
	song.isYoutube = (BOOL)[JSON valueForKey:@"isYt"];
	song.songId = [JSON valueForKey:@"id"];
	NSString *temp = [JSON valueForKey:@"uid"];
	song.uid = temp.intValue;
	song.ownerId = [JSON valueForKey:@"owner"];
	if(!song.isYoutube)
	{
		song.title = [JSON valueForKey:@"title"];
		song.artist = [JSON valueForKey:@"artist"];
		song.album = [JSON valueForKey:@"album"];
		song.length = [[JSON valueForKey:@"length"] integerValue];
	}
	
	return song;
}

@end
