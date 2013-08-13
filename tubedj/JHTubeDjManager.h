//
//  JHTubeDjManager.h
//  tubedj
//
//  Created by Jordan Hamill on 04/08/2013.
//  Copyright (c) 2013 Jordan Hamill. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "JHRestClient.h"
#import "JHPlaylistItem.h"
#import "JHUserItem.h"
#import "SocketIO.h"

/**
 *
 * Notifications
 *  tubedj-request-error {operation, error}
 *  tubedj-user-doesnt-exist {}
 *  tubedj-user-is-valid {}
 *  tubedj-user-created {id, name}
 *  tubedj-user-changed-name {id, name}
 *  tubedj-created-room {id}
 *  tubedj-joined-room {roomId, roomOwnerId, users, playlist}
 *  tubedj-left-room {id}
 *  tubedj-next-song {}
 *  tubedj-playlist-refresh {playlist}
 *  tubedj-playlist-added-song {song, index}
 *  tubedj-playlist-removed-song {uid, index}
 *  tubedj-room-closed {}
 */
@interface JHTubeDjManager : NSObject <SocketIODelegate>

+ (JHTubeDjManager *)sharedManager;

+ (NSString *)encryptRoomId:(NSString*)roomId;
+ (NSString *)decryptUrlRoomId:(NSString*)urlId;

@property (strong, nonatomic) NSString *myName;
@property (strong, nonatomic) NSString *myUserId;

@property (copy, nonatomic) NSString *roomId;
@property (nonatomic) BOOL isRoomOwner;
@property (copy, nonatomic) NSString *roomOwnerId;

@property (strong, nonatomic) NSMutableArray *playlist;
@property (strong, nonatomic) NSMutableDictionary *users;

- (void)fakeRoomSetup;
- (void)fakeSongAdd:(NSString *)youtubeSongId;
- (void)fakeSongRemove;

- (BOOL)isRoomOwner;
- (BOOL)isUserMe:(NSString *)userId;

- (void)loadAndCheckUserDetailsWithSuccess:(void (^)(BOOL found, BOOL valid))successBlock error:(void (^)(NSError *error))errorBlock;
- (void)saveDetails;

- (void)resetUserWithSuccess:(void (^)(BOOL shouldGoToCreateUserScreen, NSString *userId, NSString *name))successBlock error:(void (^)(NSError *error))errorBlock;

- (void)createUser:(NSString *)name success:(void (^)(NSString *userId, NSString *name))successBlock error:(void (^)(NSError *error))errorBlock;
- (void)changeUserName:(NSString *)newName success:(void (^)(NSString *userId, NSString *name))successBlock error:(void (^)(NSError *error))errorBlock;

- (void)createRoomWithSuccess:(void (^)(NSString *roomId))successBlock error:(void (^)(NSError *error))errorBlock;
- (BOOL)joinRoom:(NSString *)roomId success:(void (^)(NSString *roomId, NSString *ownerId, NSDictionary *users, NSArray *playlist))successBlock error:(void (^)(NSError *error))errorBlock;
- (void)leaveRoomWithSuccess:(void (^)(NSString *roomId))successBlock error:(void (^)(NSError *error))errorBlock;

- (void)nextSongWithSuccess:(void (^)())successBlock error:(void (^)(NSError *error))errorBlock;
- (void)updatePlaylistWithSuccess:(void (^)(NSArray *playlist))successBlock error:(void (^)(NSError *error))errorBlock;
- (void)addYoutubeSongToPlaylist:(NSString *)songId success:(void (^)(JHPlaylistItem *song))successBlock error:(void (^)(NSError *error))errorBlock;
- (void)removeSongFromPlaylist:(int)songId success:(void (^)(int uid))successBlock error:(void (^)(NSError *error))errorBlock;

- (void)socketIODisconnect;


@end
