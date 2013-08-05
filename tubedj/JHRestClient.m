//
//  JHRestClient.m
//  tubedj
//
//  Created by Jordan Hamill on 04/08/2013.
//  Copyright (c) 2013 Jordan Hamill. All rights reserved.
//

#import "JHRestClient.h"

static NSString * const kAFAPIBaseURLString = @"http://localhost:8081/api/";

@implementation JHRestClient

+ (JHRestClient *)sharedClient
{
    static JHRestClient *_sharedClient = nil;
    static dispatch_once_t JHRestClientToken;
    dispatch_once(&JHRestClientToken, ^{
        _sharedClient = [[JHRestClient alloc] initWithBaseURL:[NSURL URLWithString:kAFAPIBaseURLString]];
    });
	
    return _sharedClient;
}

- (id)initWithBaseURL:(NSURL *)url
{
    self = [super initWithBaseURL:url];
    if (!self) {
        return nil;
    }
	
    [self registerHTTPOperationClass:[AFJSONRequestOperation class]];
    [self setDefaultHeader:@"Accept" value:@"application/json"];

    return self;
}

- (NSData *)getCookies
{
    NSData *cookiesData = [NSKeyedArchiver archivedDataWithRootObject: [[NSHTTPCookieStorage sharedHTTPCookieStorage] cookies]];
    NSUserDefaults *defaults = [NSUserDefaults standardUserDefaults];
    [defaults setObject: cookiesData forKey: @"sessionCookies"];
    [defaults synchronize];
	return cookiesData;
}

- (void)setCookies:(NSArray *)cookies
{
    //NSArray *cookies = [NSKeyedUnarchiver unarchiveObjectWithData: [[NSUserDefaults standardUserDefaults] objectForKey: @"sessionCookies"]];
    NSHTTPCookieStorage *cookieStorage = [NSHTTPCookieStorage sharedHTTPCookieStorage];
	
    for (NSHTTPCookie *cookie in cookies){
        [cookieStorage setCookie: cookie];
    }
}

- (void)createUser:(NSString *)name success:(void (^)(NSString *userId, NSString *name))successBlock error:(void (^)(NSError *error))errorBlock
{
	NSMutableURLRequest *request = [self requestWithMethod:@"POST" path:@"users" parameters:@{@"name": name}];
	
	AFJSONRequestOperation *requestOperation = [AFJSONRequestOperation JSONRequestOperationWithRequest:request
	   success:^(NSURLRequest *request, NSHTTPURLResponse *response, id JSON)
		{
			if(successBlock) successBlock([JSON valueForKey:@"id"], [JSON valueForKey:@"name"]);
		}
	   failure:^(NSURLRequest *request, NSHTTPURLResponse *response, NSError *error, id JSON)
		{
			if(errorBlock) errorBlock(error);
		}
	];
	
	[self enqueueHTTPRequestOperation:requestOperation];

}

- (void)doesUserExist:(NSString *)userId success:(void (^)(BOOL exists, NSString *userId, NSString *name))successBlock error:(void (^)(NSError *error))errorBlock
{
	NSMutableURLRequest *request = [self requestWithMethod:@"GET" path:[NSString stringWithFormat:@"users/%@", userId] parameters:nil];
	
	AFJSONRequestOperation *requestOperation = [AFJSONRequestOperation JSONRequestOperationWithRequest:request
		success:^(NSURLRequest *request, NSHTTPURLResponse *response, id JSON)
		{
			//Grab room id from JSON.id
			BOOL exists = ((BOOL)[JSON valueForKey:@"exists"]);
			if(successBlock) successBlock(exists, [JSON valueForKey:@"id"], [JSON valueForKey:@"name"]);
		}
		failure:^(NSURLRequest *request, NSHTTPURLResponse *response, NSError *error, id JSON)
		{
			if(errorBlock) errorBlock(error);
		}
	];
	
	[self enqueueHTTPRequestOperation:requestOperation];
}

- (void)changeName:(NSString *)newName success:(void (^)(NSString *userId, NSString *name))successBlock error:(void (^)(NSError *error))errorBlock
{
	//TODO Implement on server
}

- (void)createRoomOnSuccess:(void (^)(NSString *roomId))successBlock error:(void (^)(NSError *error))errorBlock
{
	NSMutableURLRequest *request = [self requestWithMethod:@"POST" path:@"rooms" parameters:nil];
	
	AFJSONRequestOperation *requestOperation = [AFJSONRequestOperation JSONRequestOperationWithRequest:request
	   success:^(NSURLRequest *request, NSHTTPURLResponse *response, id JSON)
		{
			//Grab room id from JSON.id
			if(successBlock) successBlock([JSON valueForKey:@"room"]);
		}
	   failure:^(NSURLRequest *request, NSHTTPURLResponse *response, NSError *error, id JSON)
		{
			if(errorBlock) errorBlock(error);
		}
	];
	
	[self enqueueHTTPRequestOperation:requestOperation];
}

- (void)joinRoom:(NSString *)roomId success:(void (^)(NSString *roomId, NSString *ownerId, NSDictionary *users, NSArray *playlist))successBlock error:(void (^)(NSError *error))errorBlock
{
	//Escape roomId!!!!!
	
	NSMutableURLRequest *request = [self requestWithMethod:@"GET" path:[NSString stringWithFormat:@"rooms/%@", roomId] parameters:nil];
	
	AFJSONRequestOperation *requestOperation = [AFJSONRequestOperation JSONRequestOperationWithRequest:request
		success:^(NSURLRequest *request, NSHTTPURLResponse *response, id JSON)
		{
			//Grab room id from JSON.id, users from JSON.users:[] and playlist from JSON.playlist:[]
			if(successBlock) successBlock([JSON valueForKey:@"id"], [JSON valueForKey:@"owner"], [JSON valueForKey:@"playlist"], [JSON valueForKey:@"users"]);
		}
		failure:^(NSURLRequest *request, NSHTTPURLResponse *response, NSError *error, id JSON)
		{
			if(errorBlock) errorBlock(error);
		}
	];
	
	[self enqueueHTTPRequestOperation:requestOperation];
}

- (void)leaveRoom:(NSString *)roomId success:(void (^)())successBlock error:(void (^)(NSError *error))errorBlock
{
	NSMutableURLRequest *request = [self requestWithMethod:@"POST" path:[NSString stringWithFormat:@"rooms/%@/leave", roomId] parameters:nil];
	
	AFJSONRequestOperation *requestOperation = [AFJSONRequestOperation JSONRequestOperationWithRequest:request
		success:^(NSURLRequest *request, NSHTTPURLResponse *response, id JSON)
		{
			if(successBlock) successBlock();
		}
		failure:^(NSURLRequest *request, NSHTTPURLResponse *response, NSError *error, id JSON)
		{
			if(errorBlock) errorBlock(error);
		}
	];
	
	[self enqueueHTTPRequestOperation:requestOperation];
}

- (void)nextSongForRoom:(NSString *)roomId success:(void (^)())successBlock error:(void (^)(NSError *error))errorBlock
{
	NSMutableURLRequest *request = [self requestWithMethod:@"POST" path:[NSString stringWithFormat:@"rooms/%@/next-song", roomId] parameters:nil];
	
	AFJSONRequestOperation *requestOperation = [AFJSONRequestOperation JSONRequestOperationWithRequest:request
		success:^(NSURLRequest *request, NSHTTPURLResponse *response, id JSON)
		{
			if(successBlock) successBlock();
		}
		failure:^(NSURLRequest *request, NSHTTPURLResponse *response, NSError *error, id JSON)
		{
			if(errorBlock) errorBlock(error);
		}
	];
	
	[self enqueueHTTPRequestOperation:requestOperation];
}

- (void)getPlaylistForRoom:(NSString *)roomId success:(void (^)(NSArray *playlist))successBlock error:(void (^)(NSError *error))errorBlock
{
	NSMutableURLRequest *request = [self requestWithMethod:@"GET" path:[NSString stringWithFormat:@"rooms/%@/playlist", roomId] parameters:nil];
	
	AFJSONRequestOperation *requestOperation = [AFJSONRequestOperation JSONRequestOperationWithRequest:request
		success:^(NSURLRequest *request, NSHTTPURLResponse *response, id JSON)
		{
			//Grab JSON.playlist:[] and call delegate
			if(successBlock) successBlock([JSON valueForKey:@"playlist"]);
		}
		failure:^(NSURLRequest *request, NSHTTPURLResponse *response, NSError *error, id JSON)
		{
			if(errorBlock) errorBlock(error);
		}
	];
	
	[self enqueueHTTPRequestOperation:requestOperation];
}

- (void)addYoutubeSongToPlaylist:(NSString *)songId forRoom:(NSString *)roomId success:(void (^)(NSString *songId, NSString *uniqueSongId))successBlock error:(void (^)(NSError *error))errorBlock
{
	NSMutableURLRequest *request = [self requestWithMethod:@"POST" path:[NSString stringWithFormat:@"rooms/%@/playlist", roomId] parameters:@{@"yt":songId}];
	
	AFJSONRequestOperation *requestOperation = [AFJSONRequestOperation JSONRequestOperationWithRequest:request
		success:^(NSURLRequest *request, NSHTTPURLResponse *response, id JSON)
		{
			//JSON.song contains added song info but the websocket should update it correctly
			if(successBlock) successBlock(songId, [JSON valueForKey:@"uid"]);
		}
		failure:^(NSURLRequest *request, NSHTTPURLResponse *response, NSError *error, id JSON)
		{
			if(errorBlock) errorBlock(error);
		}
	];
	
	[self enqueueHTTPRequestOperation:requestOperation];
}

- (void)removeYoutubeSongFromPlaylist:(NSString *)songId forRoom:(NSString *)roomId success:(void (^)(NSString *uniqueSongId))successBlock error:(void (^)(NSError *error))errorBlock
{
	NSMutableURLRequest *request = [self requestWithMethod:@"DEL" path:[NSString stringWithFormat:@"rooms/%@/playlist", roomId] parameters:@{@"songUid":songId}];
	
	AFJSONRequestOperation *requestOperation = [AFJSONRequestOperation JSONRequestOperationWithRequest:request
		success:^(NSURLRequest *request, NSHTTPURLResponse *response, id JSON)
		{
			if(successBlock) successBlock(songId);
		}
		failure:^(NSURLRequest *request, NSHTTPURLResponse *response, NSError *error, id JSON)
		{
			if(errorBlock) errorBlock(error);
		}
	];
	
	[self enqueueHTTPRequestOperation:requestOperation];
}

@end
