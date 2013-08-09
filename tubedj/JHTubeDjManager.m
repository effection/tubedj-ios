//
//  JHTubeDjManager.m
//  tubedj
//
//  Created by Jordan Hamill on 04/08/2013.
//  Copyright (c) 2013 Jordan Hamill. All rights reserved.
//

#import "JHTubeDjManager.h"
#import "SocketIOPacket.h"

@implementation JHTubeDjManager {
	SocketIO *socketIO;
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
	
	socketIO = [[SocketIO alloc] initWithDelegate:self];
	
	[[NSNotificationCenter defaultCenter] addObserver:self
											 selector:@selector(appGoingBackground:)
												 name:@"tubedj-going-background"
											   object:nil];
	[[NSNotificationCenter defaultCenter] addObserver:self
											 selector:@selector(appGoingForeground:)
												 name:@"tubedj-going-foreground"
											   object:nil];
	
	return self;
}

- (void)appGoingBackground:(NSNotification *) notification
{
	//[socketIO disconnect];
}

- (void)appGoingForeground:(NSNotification *) notification
{
	
}

- (BOOL)isUserMe:(NSString *)userId
{
	return [self.myUserId isEqualToString:userId];
}

- (void)fakeRoomSetup
{
	self.roomId = @"BLAH";
	self.roomOwnerId = self.myUserId;
	self.users = [[NSMutableDictionary alloc] initWithCapacity:1];
	self.playlist = [[NSMutableArray alloc] initWithCapacity:1];
	JHUserItem *me = [[JHUserItem alloc] init];
	me.userId = self.myUserId;
	me.name = self.myName;
	[self.users setObject:me forKey:me.userId];

}

- (void)fakeSongAdd:(NSString *)youtubeSongId
{
	JHPlaylistItem *song = [[JHPlaylistItem alloc] init];
	song.songId = youtubeSongId;
	song.uid = 9999;
	song.isYoutube = YES;
	song.ownerId = self.myUserId;
	[self.playlist insertObject:song atIndex:0];
	
	[[NSNotificationCenter defaultCenter] postNotificationName:@"tubedj-playlist-added-song"
														object:nil
													  userInfo:@{@"song" :song, @"index" : @(0)}];
}

- (void)fakeSongRemove
{
	NSInteger uid = 9999;
	
	for (int i = 0; i < self.playlist.count; i++) {
		JHPlaylistItem *song = self.playlist[i];
		if(song.uid == uid)
		{
			[self.playlist removeObjectAtIndex:i];
			[[NSNotificationCenter defaultCenter] postNotificationName:@"tubedj-playlist-removed-song"
																object:nil
															  userInfo:@{@"uid" :@(uid), @"index" : @(i)}];
			break;
		}
	}

}

- (void)loadAndCheckUserDetailsWithSuccess:(void (^)(BOOL found, BOOL valid))successBlock error:(void (^)(NSError *error))errorBlock
{
	//Grab my name and take id out of plain cookie
	self.myName = [[NSUserDefaults standardUserDefaults] objectForKey:@"username"];
	if(!self.myName || self.myName.length == 0)
	{
//		[[NSNotificationCenter defaultCenter] postNotificationName:@"tubedj-user-doesnt-exist"
//															object:nil
//														  userInfo:nil];
		if(successBlock) successBlock(NO, NO);
		
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
//		[[NSNotificationCenter defaultCenter] postNotificationName:@"tubedj-user-doesnt-exist"
//															object:nil
//														  userInfo:nil];
		
		if(successBlock) successBlock(NO, NO);
		return;
	}
	//If they aren't valid call user doesn't exist delegate
	[[JHRestClient sharedClient] doesUserExist:self.myUserId success:^(BOOL exists, NSString *userId, NSString *name) {
		if(!exists)
		{
//			[[NSNotificationCenter defaultCenter] postNotificationName:@"tubedj-user-doesnt-exist"
//																object:nil
//															  userInfo:nil];
			
			if(successBlock) successBlock(NO, NO);
		} else
		{
//			[[NSNotificationCenter defaultCenter] postNotificationName:@"tubedj-user-is-valid"
//																object:nil
//															  userInfo:nil];
			
			if(successBlock) successBlock(YES, YES);
		}
	} error:^(NSError *error) {
		if(errorBlock) errorBlock(error);
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

- (void)createUser:(NSString *)name success:(void (^)(NSString *userId, NSString *name))successBlock error:(void (^)(NSError *error))errorBlock
{
	//successBlock(self.myUserId, self.myName);
	//return;
	
	if(name.length < USERNAME_MIN_LENGTH || name.length > USERNAME_MAX_LENGTH)
	{
		if(errorBlock) errorBlock([[NSError alloc] init]);
		return;
	}
	
	NSMutableCharacterSet* testCharSet = [[NSMutableCharacterSet alloc] init];
	[testCharSet formUnionWithCharacterSet:[NSCharacterSet alphanumericCharacterSet]];
	[testCharSet formUnionWithCharacterSet:[NSCharacterSet nonBaseCharacterSet]];
	[testCharSet formUnionWithCharacterSet:[NSCharacterSet whitespaceCharacterSet]];
	
	NSCharacterSet *charactersToRemove = [testCharSet invertedSet];
	
	name = [[ name componentsSeparatedByCharactersInSet:charactersToRemove ] componentsJoinedByString:@"" ];
	
	[[JHRestClient sharedClient] createUser:name success:^(NSString *userId, NSString *returnedName) {
		self.myName = returnedName;
		self.myUserId = userId;
		
//		[[NSNotificationCenter defaultCenter] postNotificationName:@"tubedj-user-created"
//															object:nil
//														  userInfo:@{@"id" : userId, @"name" : returnedName}];
		
		if(successBlock) successBlock(userId, returnedName);
		
	} error:^(NSError *error) {

		[[NSNotificationCenter defaultCenter] postNotificationName:@"tubedj-request-error"
															object:nil
														  userInfo:@{@"operation" : @"create-user", @"error" : error}];
		
		if(errorBlock) errorBlock(error);
	}];
}

- (void)changeUserName:(NSString *)newName success:(void (^)(NSString *userId, NSString *name))successBlock error:(void (^)(NSError *error))errorBlock
{
	if(newName.length < USERNAME_MIN_LENGTH || newName.length > USERNAME_MAX_LENGTH)
	{
		if(errorBlock) errorBlock([[NSError alloc] init]);
		return;
	}
	NSMutableCharacterSet* testCharSet = [[NSMutableCharacterSet alloc] init];
	[testCharSet formUnionWithCharacterSet:[NSCharacterSet alphanumericCharacterSet]];
	[testCharSet formUnionWithCharacterSet:[NSCharacterSet nonBaseCharacterSet]];
	[testCharSet formUnionWithCharacterSet:[NSCharacterSet whitespaceCharacterSet]];
	
	NSCharacterSet *charactersToRemove = [testCharSet invertedSet];
	
	newName = [[ newName componentsSeparatedByCharactersInSet:charactersToRemove ] componentsJoinedByString:@"" ];
	
	[[JHRestClient sharedClient] changeName:newName success:^(NSString *userId, NSString *name) {
		self.myName = name;
		
//		[[NSNotificationCenter defaultCenter] postNotificationName:@"tubedj-user-changed-name"
//															object:nil
//														  userInfo:@{@"id" : userId, @"name" : name}];
		
		if(successBlock) successBlock(userId, name);
		
	} error:^(NSError *error) {

		[[NSNotificationCenter defaultCenter] postNotificationName:@"tubedj-request-error"
															object:nil
														  userInfo:@{@"operation" : @"change-name", @"error" : error}];
		
		if(errorBlock) errorBlock(error);
	}];
}

- (void)createRoomWithSuccess:(void (^)(NSString *roomId))successBlock error:(void (^)(NSError *error))errorBlock
{
	[[JHRestClient sharedClient] createRoomOnSuccess:^(NSString *roomId) {
		
//		[[NSNotificationCenter defaultCenter] postNotificationName:@"tubedj-created-room"
//															object:nil
//														  userInfo:@{@"id" : roomId}];
		
		if(successBlock) successBlock(roomId);
		
	} error:^(NSError *error) {
		
		[[NSNotificationCenter defaultCenter] postNotificationName:@"tubedj-request-error"
															object:nil
														  userInfo:@{@"operation" : @"create-room", @"error" : error}];
		
		if(errorBlock) errorBlock(error);
	}];
}

- (void)joinRoom:(NSString *)roomId success:(void (^)(NSString *roomId, NSString *ownerId, NSDictionary *users, NSArray *playlist))successBlock error:(void (^)(NSError *error))errorBlock
{
	NSMutableCharacterSet* testCharSet = [[NSMutableCharacterSet alloc] init];
	[testCharSet formUnionWithCharacterSet:[NSCharacterSet alphanumericCharacterSet]];
	
	NSCharacterSet *charactersToRemove = [testCharSet invertedSet];
	roomId = [[ roomId componentsSeparatedByCharactersInSet:charactersToRemove ] componentsJoinedByString:@"" ];
	
	[[JHRestClient sharedClient] joinRoom:roomId success:^(NSString *roomId, NSString *ownerId, NSArray *users, NSArray *playlist) {
		
		self.roomId = roomId;
		self.roomOwnerId = ownerId;
		self.users = [[NSMutableDictionary alloc] initWithCapacity:users.count];
		self.playlist = [[NSMutableArray alloc] initWithCapacity:playlist.count];
		
		for(int i = 0; i < playlist.count; i++)
		{
			JHPlaylistItem *item = [JHPlaylistItem fromJSON:playlist[i]];
			[self.playlist addObject:item];
		}
		
		JHUserItem *me = [[JHUserItem alloc] init];
		me.userId = self.myUserId;
		me.name = self.myName;
		[self.users setObject:me forKey:me.userId];
		
		for(int i = 0; i < users.count; i++)
		{
			JHUserItem *user = [JHUserItem fromJSON:users[i]];
			[self.users setObject:user forKey:user.userId];
		}
		
		[[NSNotificationCenter defaultCenter] postNotificationName:@"tubedj-playlist-refresh"
															object:nil
														  userInfo:@{@"playlist" : self.playlist}];
		
//		[[NSNotificationCenter defaultCenter] postNotificationName:@"tubedj-joined-room"
//															object:nil
//														  userInfo:@{@"roomId" : roomId, @"roomOwnerId" : ownerId, @"users" : self.users, @"playlist" : self.playlist}];
		if(socketIO.isConnected || socketIO.isConnecting)
			[socketIO disconnect];
		[socketIO connectToHost:@"192.168.0.6" onPort:8081];
		
		
		if(successBlock) successBlock(self.roomId, self.roomOwnerId, self.users, self.playlist);
		
	} error:^(NSError *error) {

		[[NSNotificationCenter defaultCenter] postNotificationName:@"tubedj-request-error"
															object:nil
														  userInfo:@{@"operation" : @"join-room", @"error" : error}];
		
		if(errorBlock) errorBlock(error);
	}];
}

- (void)leaveRoomWithSuccess:(void (^)(NSString *roomId))successBlock error:(void (^)(NSError *error))errorBlock
{
	[[JHRestClient sharedClient] leaveRoom:self.roomId success:^{
		
//		[[NSNotificationCenter defaultCenter] postNotificationName:@"tubedj-left-room"
//															object:nil
//														  userInfo:@{@"id" : self.roomId}];
		
		if(successBlock) successBlock(self.roomId);
		[socketIO disconnect];
		self.roomId = nil;
		self.roomOwnerId = nil;
		self.users = nil;
		self.playlist = nil;
	} error:^(NSError *error) {

		[[NSNotificationCenter defaultCenter] postNotificationName:@"tubedj-request-error"
															object:nil
														  userInfo:@{@"operation" : @"leave-room", @"error" : error}];
		
		if(errorBlock) errorBlock(error);
	}];
}

- (void)nextSongWithSuccess:(void (^)())successBlock error:(void (^)(NSError *error))errorBlock
{
	if(![self.roomOwnerId isEqualToString:self.myUserId]) return;
	
	[[JHRestClient sharedClient] nextSongForRoom:self.roomId success:^{
		
		if(successBlock) successBlock();
		
	} error:^(NSError *error) {
		
		[[NSNotificationCenter defaultCenter] postNotificationName:@"tubedj-request-error"
															object:nil
														  userInfo:@{@"operation" : @"next-song", @"error" : error}];
		
		if(errorBlock) errorBlock(error);
	}];
}

- (void)updatePlaylistWithSuccess:(void (^)(NSArray *playlist))successBlock error:(void (^)(NSError *error))errorBlock
{
	[[JHRestClient sharedClient] getPlaylistForRoom:self.roomId success:^(NSArray *playlist) {
		[self.playlist removeAllObjects];

		for(int i = 0; i < playlist.count; i++)
		{
			JHPlaylistItem *item = [JHPlaylistItem fromJSON:playlist[i]];
			[self.playlist addObject:item];
		}

		
		[[NSNotificationCenter defaultCenter] postNotificationName:@"tubedj-playlist-refresh"
															object:nil
														  userInfo:@{@"playlist" : self.playlist}];
		
		
		if(successBlock) successBlock(self.playlist);
		
	} error:^(NSError *error) {
		
		[[NSNotificationCenter defaultCenter] postNotificationName:@"tubedj-request-error"
															object:nil
														  userInfo:@{@"operation" : @"update-playlist", @"error" : error}];
		
		if(errorBlock) errorBlock(error);
	}];
}

- (void)addYoutubeSongToPlaylist:(NSString *)songId success:(void (^)(JHPlaylistItem *song))successBlock error:(void (^)(NSError *error))errorBlock
{
	[[JHRestClient sharedClient] addYoutubeSongToPlaylist:songId forRoom:self.roomId success:^(NSString *songId, int uniqueSongId, NSString *ownerId) {
		
		JHPlaylistItem *song = [[JHPlaylistItem alloc] init];
		song.songId = songId;
		song.uid = uniqueSongId;
		song.isYoutube = YES;
		song.ownerId = ownerId;
		
//		[[NSNotificationCenter defaultCenter] postNotificationName:@"tubedj-playlist-added-song"
//															object:nil
//														  userInfo:@{@"songId" : songId, @"uid" : uniqueSongId}];
		
		if(successBlock) successBlock(song);
		
	} error:^(NSError *error) {
		
		[[NSNotificationCenter defaultCenter] postNotificationName:@"tubedj-request-error"
															object:nil
														  userInfo:@{@"operation" : @"add-youtube-song-to-playlist", @"error" : error}];
		
		if(errorBlock) errorBlock(error);
	}];
}

- (void)removeSongFromPlaylist:(int)songId success:(void (^)(int uid))successBlock error:(void (^)(NSError *error))errorBlock
{
	[[JHRestClient sharedClient] removeYoutubeSongFromPlaylist:songId forRoom:self.roomId success:^(int uniqueSongId) {
		
//		[[NSNotificationCenter defaultCenter] postNotificationName:@"tubedj-playlist-removed-song"
//															object:nil
//														  userInfo:@{@"uid" : uniqueSongId}];
		
		if(successBlock) successBlock(uniqueSongId);
		
	} error:^(NSError *error) {
		
		[[NSNotificationCenter defaultCenter] postNotificationName:@"tubedj-request-error"
															object:nil
														  userInfo:@{@"operation" : @"remove-song-from-playlist", @"error" : error}];
		
		if(errorBlock) errorBlock(error);
		
	}];
}

#pragma mark- Socket IO Delegate

- (void) socketIODidConnect:(SocketIO *)socket
{
	NSLog(@"SocketIO: Connected");
}

- (void) socketIODidDisconnect:(SocketIO *)socket disconnectedWithError:(NSError *)error
{
	NSLog(@"SocketIO: Disconnected");
}

- (void) socketIO:(SocketIO *)socket didReceiveMessage:(SocketIOPacket *)packet
{
	NSLog(@"SocketIO: Received Message");
}

- (void) socketIO:(SocketIO *)socket didReceiveJSON:(SocketIOPacket *)packet
{
	NSLog(@"SocketIO: Received JSON");
}

- (void) socketIO:(SocketIO *)socket didReceiveEvent:(SocketIOPacket *)packet
{
	NSLog(@"SocketIO: Received Event");

	if ([packet.name isEqualToString:@"playlist:song-added"])
	{
		JHPlaylistItem *song = [JHPlaylistItem fromJSON:[packet.args[0] valueForKeyPath:@"song"]];
		
		[self.playlist addObject:song];
		int index = self.playlist.count - 1;
		
		[[NSNotificationCenter defaultCenter] postNotificationName:@"tubedj-playlist-added-song"
															object:nil
														  userInfo:@{@"song" :song, @"index" : @(index)}];

		
	} else if ([packet.name isEqualToString:@"playlist:song-removed"])
	{
		NSInteger uid = [[packet.args valueForKey:@"songUid"][0] integerValue];
		
		for (int i = 0; i < self.playlist.count; i++) {
			JHPlaylistItem *song = self.playlist[i];
			if(song.uid == uid)
			{
				[self.playlist removeObjectAtIndex:i];
				[[NSNotificationCenter defaultCenter] postNotificationName:@"tubedj-playlist-removed-song"
																	object:nil
																  userInfo:@{@"uid" :@(uid), @"index" : @(i)}];
				break;
			}
		}
		
		
	} else if ([packet.name isEqualToString:@"playlist:next-song"])
	{
		[self.playlist removeObjectAtIndex:0];
		
		[[NSNotificationCenter defaultCenter] postNotificationName:@"tubedj-next-song"
															object:nil
														  userInfo:nil];

	} else if ([packet.name isEqualToString:@"user:disconnected"])
	{
		NSString *userId = [packet.args valueForKey:@"user"];
		[self.users removeObjectForKey:userId];
		
		[[NSNotificationCenter defaultCenter] postNotificationName:@"tubedj-user-disconnected"
															object:nil
														  userInfo:@{@"id" : userId}];
		
	} else if ([packet.name isEqualToString:@"user:joined"])
	{
		NSString *userId = [packet.args valueForKeyPath:@"user.id"][0];
		JHUserItem *user = [[JHUserItem alloc] init];
		user.userId = userId;
		user.name = [packet.args valueForKeyPath:@"user.name"][0];
		[self.users setObject:user forKey:userId];
		
		[[NSNotificationCenter defaultCenter] postNotificationName:@"tubedj-user-joined"
															object:nil
														  userInfo:@{@"id" : userId}];
	}
}

- (void) socketIO:(SocketIO *)socket didSendMessage:(SocketIOPacket *)packet
{
	NSLog(@"SocketIO: Sent Message");
}

- (void) socketIO:(SocketIO *)socket onError:(NSError *)error
{
	NSLog(@"SocketIO: Error");
}

@end
