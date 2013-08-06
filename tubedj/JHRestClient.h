//
//  JHRestClient.h
//  tubedj
//
//  Created by Jordan Hamill on 04/08/2013.
//  Copyright (c) 2013 Jordan Hamill. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "AFNetworking.h"


@interface JHRestClient : AFHTTPClient

+ (JHRestClient *)sharedClient;

- (NSData *)getCookies;
- (void)setCookies:(NSArray *)cookies;

- (void)createUser:(NSString *)name success:(void (^)(NSString *userId, NSString *name))successBlock error:(void (^)(NSError *error))errorBlock;

- (void)doesUserExist:(NSString *)userId success:(void (^)(BOOL exists, NSString *userId, NSString *name))successBlock error:(void (^)(NSError *error))errorBlock;

- (void)changeName:(NSString *)newName success:(void (^)(NSString *userId, NSString *name))successBlock error:(void (^)(NSError *error))errorBlock;

- (void)createRoomOnSuccess:(void (^)(NSString *roomId))successBlock error:(void (^)(NSError *error))errorBlock;

- (void)joinRoom:(NSString *)roomId success:(void (^)(NSString *roomId, NSString *ownerId, NSArray *users, NSArray *playlist))successBlock error:(void (^)(NSError *error))errorBlock;

- (void)leaveRoom:(NSString *)roomId success:(void (^)())successBlock error:(void (^)(NSError *error))errorBlock;

- (void)nextSongForRoom:(NSString *)roomId success:(void (^)())successBlock error:(void (^)(NSError *error))errorBlock;

- (void)getPlaylistForRoom:(NSString *)roomId success:(void (^)(NSArray *playlist))successBlock error:(void (^)(NSError *error))errorBlock;

- (void)addYoutubeSongToPlaylist:(NSString *)songId forRoom:(NSString *)roomId success:(void (^)(NSString *songId, NSString *uniqueSongId, NSString *ownerId))successBlock error:(void (^)(NSError *error))errorBlock;

- (void)removeYoutubeSongFromPlaylist:(NSString *)songId forRoom:(NSString *)roomId success:(void (^)(NSString *uniqueSongId))successBlock error:(void (^)(NSError *error))errorBlock;

@end