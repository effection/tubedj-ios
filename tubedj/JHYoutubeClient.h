//
//  JHYoutubeClient.h
//  tubedj
//
//  Created by Jordan Hamill on 02/08/2013.
//  Copyright (c) 2013 Jordan Hamill. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "JHYoutubeSearchResult.h"

@class JHYoutubeClient;

@protocol JHYoutubeClientDelegate <NSObject>

@optional

- (void)youtubeClient:(JHYoutubeClient *)client searchStartedFor:(NSString *)search;
- (void)youtubeClient:(JHYoutubeClient *)client nextPageRequestedFor:(NSString *)search;
- (void)youtubeClient:(JHYoutubeClient *)client searchCompletedFor:(NSString *)search startingAt:(int)start withResults:(NSArray *)results;

@end

@interface JHYoutubeClient : NSObject

@property (strong, nonatomic) id<JHYoutubeClientDelegate> delegate;
@property (strong, nonatomic) NSMutableArray *searchResults;

- (void)searchFor:(NSString *)search;
- (void)searchFor:(NSString *)search start:(int)start maxResults:(int)max;
- (void)nextSearchPage;

+ (void)getSongDetails:(NSString *)songId success:(void (^)(JHYoutubeSearchResult *result))successBlock error:(void (^)(NSError *error))errorBlock;

@end
