//
//  JHTubeDjManager.m
//  tubedj
//
//  Created by Jordan Hamill on 04/08/2013.
//  Copyright (c) 2013 Jordan Hamill. All rights reserved.
//

#import "JHTubeDjManager.h"

@implementation JHTubeDjManager {
	
}

+ (JHTubeDjManager *)sharedManager
{
    static JHTubeDjManager *_sharedManager = nil;
    static dispatch_once_t JHTubeDjManagerToken;
    dispatch_once(&JHTubeDjManagerToken, ^{
        _sharedManager = [[JHTubeDjManager alloc] init];
    });
	
    return _sharedManager;
}

- (id)init
{
	self = [super init];
	if(!self) return self;

	return self;
}

- (void)loadAndCheckUserDetails
{
	//Grab my name and take id out of plain cookie
	self.myName = [[NSUserDefaults standardUserDefaults] objectForKey:@"username"];
	if(!self.myName || self.myName.length == 0)
	{
		if([self.delegate respondsToSelector:@selector(tubedjUserDoesntExist:)])
			[self.delegate tubedjUserDoesntExist:self];
		
		[[NSNotificationCenter defaultCenter] postNotificationName:@"tubedj-user-doesnt-exist"
															object:nil
														  userInfo:nil];
		return;
	}
	
	self.myUserId = @"";
	
	//Load details from storage.
	NSArray *cookies = [NSKeyedUnarchiver unarchiveObjectWithData: [[NSUserDefaults standardUserDefaults] objectForKey: @"sessionCookies"]];
	if(cookies)
	{
		[[JHRestClient sharedClient] setCookies:cookies];
		for (NSHTTPCookie *cookie in cookies) {
			if([cookie.name isEqualToString:@"tubedj-id"]) {
				self.myUserId = cookie.value;
				break;
			}
		}
	} else
	{
		if([self.delegate respondsToSelector:@selector(tubedjUserDoesntExist:)])
			[self.delegate tubedjUserDoesntExist:self];
		
		[[NSNotificationCenter defaultCenter] postNotificationName:@"tubedj-user-doesnt-exist"
															object:nil
														  userInfo:nil];
		return;
	}
	//If they aren't valid call user doesn't exist delegate
	[[JHRestClient sharedClient] doesUserExist:self.myUserId success:^(BOOL exists, NSString *userId, NSString *name) {
		if(!exists)
		{
			if([self.delegate respondsToSelector:@selector(tubedjUserDoesntExist:)])
				[self.delegate tubedjUserDoesntExist:self];
			
			[[NSNotificationCenter defaultCenter] postNotificationName:@"tubedj-user-doesnt-exist"
																object:nil
															  userInfo:nil];
		} else
		{
			if([self.delegate respondsToSelector:@selector(tubedjUserValid:)])
				[self.delegate tubedjUserValid:self];

			[[NSNotificationCenter defaultCenter] postNotificationName:@"tubedj-user-is-valid"
																object:nil
															  userInfo:nil];
		}
	} error:^(NSError *error) {
		if([self.delegate respondsToSelector:@selector(tubedj:error:)])
			[self.delegate tubedj:self error:error];
	}];
}

- (void)saveDetails
{
	NSUserDefaults *defaults = [NSUserDefaults standardUserDefaults];
	NSData *cookiesData = [[JHRestClient sharedClient] getCookies];
	
	[defaults setObject:self.myName forKey:@"username"];
    [defaults setObject: cookiesData forKey: @"sessionCookies"];
    [defaults synchronize];
}

- (void)createUser:(NSString *)name
{
	//TODO Sanatise name
	
	[[JHRestClient sharedClient] createUser:name success:^(NSString *userId, NSString *returnedName) {
		self.myName = returnedName;
		self.myUserId = userId;
		
		if([self.delegate respondsToSelector:@selector(tubedj:createdUserWithId:andName:)])
			[self.delegate tubedj:self createdUserWithId:userId andName:name];
		
		[[NSNotificationCenter defaultCenter] postNotificationName:@"tubedj-user-created"
															object:nil
														  userInfo:@{@"id" : userId, @"name" : returnedName}];
	} error:^(NSError *error) {
		if([self.delegate respondsToSelector:@selector(tubedj:error:)])
			[self.delegate tubedj:self error:error];
		
		[[NSNotificationCenter defaultCenter] postNotificationName:@"tubedj-request-error"
															object:nil
														  userInfo:@{@"operation" : @"create-user", @"error" : error}];
	}];
}

- (void)changeUserName:(NSString *)newName
{
	//TODO Sanatise name
	[[JHRestClient sharedClient] changeName:newName success:^(NSString *userId, NSString *name) {
		self.myName = name;
		
		if([self.delegate respondsToSelector:@selector(tubedj:user:changedNameTo:)])
			[self.delegate tubedj:self user:userId changedNameTo:name];
		
		[[NSNotificationCenter defaultCenter] postNotificationName:@"tubedj-user-changed-name"
															object:nil
														  userInfo:@{@"id" : userId, @"name" : name}];
	} error:^(NSError *error) {
		if([self.delegate respondsToSelector:@selector(tubedj:error:)])
			[self.delegate tubedj:self error:error];
		
		[[NSNotificationCenter defaultCenter] postNotificationName:@"tubedj-request-error"
															object:nil
														  userInfo:@{@"operation" : @"change-name", @"error" : error}];
	}];
}

- (void)createRoom
{
	[[JHRestClient sharedClient] createRoomOnSuccess:^(NSString *roomId) {
		if([self.delegate respondsToSelector:@selector(tubedj:createdRoomWithId:)])
			[self.delegate tubedj:self createdRoomWithId:roomId];
		
		[[NSNotificationCenter defaultCenter] postNotificationName:@"tubedj-created-room"
															object:nil
														  userInfo:@{@"id" : roomId}];
	} error:^(NSError *error) {
		if([self.delegate respondsToSelector:@selector(tubedj:error:)])
			[self.delegate tubedj:self error:error];
		
		[[NSNotificationCenter defaultCenter] postNotificationName:@"tubedj-request-error"
															object:nil
														  userInfo:@{@"operation" : @"create-room", @"error" : error}];
	}];
}

- (void)joinRoom:(NSString *)roomId
{
	//TODO Sanatise roomId
	
	[[JHRestClient sharedClient] joinRoom:roomId success:^(NSString *roomId, NSString *ownerId, NSDictionary *users, NSArray *playlist) {
		self.roomId = roomId;
		self.roomOwnerId = ownerId;
		self.users = [[NSMutableDictionary alloc] initWithDictionary:users copyItems:YES];
		self.playlist = [[NSMutableArray alloc] initWithArray:playlist copyItems:YES];
		
		if([self.delegate respondsToSelector:@selector(tubedj:joinedRoomWithId:withOwnerId:withUsers:andPlaylist:)])
			[self.delegate tubedj:self joinedRoomWithId:roomId withOwnerId:ownerId withUsers:users andPlaylist:playlist];
		
		[[NSNotificationCenter defaultCenter] postNotificationName:@"tubedj-joined-room"
															object:nil
														  userInfo:@{@"roomId" : roomId, @"roomOwnerId" : ownerId, @"users" : self.users, @"playlist" : self.playlist}];
	} error:^(NSError *error) {
		if([self.delegate respondsToSelector:@selector(tubedj:error:)])
			[self.delegate tubedj:self error:error];
		
		[[NSNotificationCenter defaultCenter] postNotificationName:@"tubedj-request-error"
															object:nil
														  userInfo:@{@"operation" : @"join-room", @"error" : error}];
	}];
}

- (void)leaveRoom
{
	[[JHRestClient sharedClient] leaveRoom:self.roomId success:^{
		
		if([self.delegate respondsToSelector:@selector(tubedj:leftRoomWithId:)])
			[self.delegate tubedj:self leftRoomWithId:self.roomId];
		
		[[NSNotificationCenter defaultCenter] postNotificationName:@"tubedj-left-room"
															object:nil
														  userInfo:@{@"id" : self.roomId}];
		
		self.roomId = nil;
		self.roomOwnerId = nil;
		self.users = nil;
		self.playlist = nil;
	} error:^(NSError *error) {
		if([self.delegate respondsToSelector:@selector(tubedj:error:)])
			[self.delegate tubedj:self error:error];
		
		[[NSNotificationCenter defaultCenter] postNotificationName:@"tubedj-request-error"
															object:nil
														  userInfo:@{@"operation" : @"leave-room", @"error" : error}];
	}];
}

- (void)nextSong
{
	if(![self.roomOwnerId isEqualToString:self.myUserId]) return;
	
	[[JHRestClient sharedClient] nextSongForRoom:self.roomId success:^{
		if([self.delegate respondsToSelector:@selector(tubedjSelectedNextSong:)])
			[self.delegate tubedjSelectedNextSong:self];
		
		[[NSNotificationCenter defaultCenter] postNotificationName:@"tubedj-next-song"
															object:nil
														  userInfo:nil];
		
	} error:^(NSError *error) {
		if([self.delegate respondsToSelector:@selector(tubedj:error:)])
			[self.delegate tubedj:self error:error];
		
		[[NSNotificationCenter defaultCenter] postNotificationName:@"tubedj-request-error"
															object:nil
														  userInfo:@{@"operation" : @"next-song", @"error" : error}];
	}];
}

- (void)updatePlaylist
{
	[[JHRestClient sharedClient] getPlaylistForRoom:self.roomId success:^(NSArray *playlist) {
		self.playlist = [[NSMutableArray alloc] initWithArray:playlist copyItems:YES];
		
		if([self.delegate respondsToSelector:@selector(tubedj:updatedPlaylist:)])
			[self.delegate tubedj:self updatedPlaylist:playlist];
		
		[[NSNotificationCenter defaultCenter] postNotificationName:@"tubedj-playlist-refresh"
															object:nil
														  userInfo:@{@"playlist" : self.playlist}];
		
	} error:^(NSError *error) {
		if([self.delegate respondsToSelector:@selector(tubedj:error:)])
			[self.delegate tubedj:self error:error];
		
		[[NSNotificationCenter defaultCenter] postNotificationName:@"tubedj-request-error"
															object:nil
														  userInfo:@{@"operation" : @"update-playlist", @"error" : error}];
	}];
}

- (void)addYoutubeSongToPlaylist:(NSString *)songId
{
	[[JHRestClient sharedClient] addYoutubeSongToPlaylist:songId forRoom:self.roomId success:^(NSString *songId, NSString *uniqueSongId) {
		if([self.delegate respondsToSelector:@selector(tubedj:addedSongToPlaylist:)])
			[self.delegate tubedj:self addedSongToPlaylist:songId];
		
		[[NSNotificationCenter defaultCenter] postNotificationName:@"tubedj-playlist-added-song"
															object:nil
														  userInfo:@{@"songId" : songId, @"uid" : uniqueSongId}];
		
	} error:^(NSError *error) {
		if([self.delegate respondsToSelector:@selector(tubedj:error:)])
			[self.delegate tubedj:self error:error];
		
		[[NSNotificationCenter defaultCenter] postNotificationName:@"tubedj-request-error"
															object:nil
														  userInfo:@{@"operation" : @"add-youtube-song-to-playlist", @"error" : error}];
	}];
}

- (void)removeSongFromPlaylist:(NSString *)songId
{
	[[JHRestClient sharedClient] removeYoutubeSongFromPlaylist:songId forRoom:self.roomId success:^(NSString *uniqueSongId) {
		if([self.delegate respondsToSelector:@selector(tubedj:removedSongFromPlaylist:)])
			[self.delegate tubedj:self removedSongFromPlaylist:uniqueSongId];
		
		[[NSNotificationCenter defaultCenter] postNotificationName:@"tubedj-playlist-removed-song"
															object:nil
														  userInfo:@{@"uid" : uniqueSongId}];
		
	} error:^(NSError *error) {
		if([self.delegate respondsToSelector:@selector(tubedj:error:)])
			[self.delegate tubedj:self error:error];
		
		[[NSNotificationCenter defaultCenter] postNotificationName:@"tubedj-request-error"
															object:nil
														  userInfo:@{@"operation" : @"remove-song-from-playlist", @"error" : error}];
	}];
}


@end
