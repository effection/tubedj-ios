//
//  JHTubeDjManager.h
//  tubedj
//
//  Created by Jordan Hamill on 04/08/2013.
//  Copyright (c) 2013 Jordan Hamill. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "JHRestClient.h"

@class JHTubeDjManager;

@protocol JHTubeDjManagerDelegate <NSObject>

@optional

- (void)tubedj:(JHTubeDjManager *)manager error:(NSError *)error;

- (void)tubedjUserDoesntExist:(JHTubeDjManager *)manager;

- (void)tubedjUserValid:(JHTubeDjManager *)manager;

- (void)tubedj:(JHTubeDjManager *)manager createdUserWithId:(NSString *)userId andName:(NSString *)name;

- (void)tubedj:(JHTubeDjManager *)manager user:(NSString *)userid changedNameTo:(NSString *)newName;

- (void)tubedj:(JHTubeDjManager *)manager createdRoomWithId:(NSString *)roomId;

- (void)tubedj:(JHTubeDjManager *)manager joinedRoomWithId:(NSString *)roomId withOwnerId:(NSString *)ownerId withUsers:(NSDictionary *)users andPlaylist:(NSArray *)playlist;

- (void)tubedj:(JHTubeDjManager *)manager leftRoomWithId:(NSString *)roomId;

- (void)tubedjSelectedNextSong:(JHTubeDjManager *)manager;

- (void)tubedj:(JHTubeDjManager *)manager updatedPlaylist:(NSArray *)playlist;

- (void)tubedj:(JHTubeDjManager *)manager addedSongToPlaylist:(id)song;

- (void)tubedj:(JHTubeDjManager *)manager removedSongFromPlaylist:(NSString *)songId;

@end

/**
 *
 * Notifications
 *  tubedj-user-doesnt-exist {}
 *  tubedj-user-is-valid {}
 *  tubedj-user-created {id, name}
 *  tubedj-user-changed-name {id, name}
 *  tubedj-created-room {id}
 *  tubedj-joined-room {roomId, roomOwnerId, users, playlist}
 *  tubedj-left-room {id}
 *  tubedj-next-song {}
 *  tubedj-playlist-refresh {playlist}
 *  tubedj-playlist-added-song {songId, uid}
 *  tubedj-playlist-removed-song {uid}
 */
@interface JHTubeDjManager : NSObject

+ (JHTubeDjManager *)sharedManager;

@property (assign, nonatomic) id<JHTubeDjManagerDelegate> delegate;

@property (strong, nonatomic) NSString *myName;
@property (strong, nonatomic) NSString *myUserId;

@property (copy, nonatomic) NSString *roomId;
@property (nonatomic) BOOL isRoomOwner;
@property (copy, nonatomic) NSString *roomOwnerId;

@property (strong, nonatomic) NSMutableArray *playlist;
@property (strong, nonatomic) NSMutableDictionary *users;

- (void)loadAndCheckUserDetails;
- (void)saveDetails;

- (void)createUser:(NSString *)name;
- (void)changeUserName:(NSString *)newName;

- (void)createRoom;
- (void)joinRoom:(NSString *)roomId;
- (void)leaveRoom;

- (void)nextSong;
- (void)updatePlaylist;
- (void)addYoutubeSongToPlaylist:(NSString *)songId;
- (void)removeSongFromPlaylist:(NSString *)songId;



@end
