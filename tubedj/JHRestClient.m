//
//  JHRestClient.m
//  tubedj
//
//  Created by Jordan Hamill on 04/08/2013.
//  Copyright (c) 2013 Jordan Hamill. All rights reserved.
//

#import "JHRestClient.h"
#import <CommonCrypto/CommonHMAC.h>
#import "NSData+Base64.h"

#if TARGET_IPHONE_SIMULATOR
static NSString * const kAFAPIBaseURLString = @"http://localhost:8081/api/";
#else
static NSString * const kAFAPIBaseURLString = @"http://ihateyouloveme.no-ip.org:8081/api/";
#endif


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

- (NSString *)hmacForMethod:(NSString*)method url:(NSString *)url body:(NSString*)body
{
	
	NSString * parameters = [NSString stringWithFormat:@"%@%@%@", method, url, body];
	NSString *salt = [@"JordanSaltsalt234" stringByAppendingString:self.userSecret==nil? @"" : self.userSecret];
	NSData *saltData = [salt dataUsingEncoding:NSUTF8StringEncoding];
	NSData *paramData = [parameters dataUsingEncoding:NSUTF8StringEncoding];
	NSMutableData* hash = [NSMutableData dataWithLength:CC_SHA256_DIGEST_LENGTH ];
	CCHmac(kCCHmacAlgSHA256, saltData.bytes, saltData.length, paramData.bytes, paramData.length, hash.mutableBytes);
	NSString *base64Hash = [hash base64EncodedString];

	base64Hash = (NSString *)CFBridgingRelease(CFURLCreateStringByAddingPercentEscapes(NULL, (CFStringRef)base64Hash, NULL, (CFStringRef)@"!*'();:@&=+$,/?%#[]", kCFStringEncodingUTF8));
	
	return base64Hash;
}

- (NSMutableURLRequest *)addHMACToRequest:(NSMutableURLRequest*)request
{
	NSString *method = request.HTTPMethod;
	NSString *path = [request.URL absoluteString];
	
	if ([method isEqualToString:@"GET"] || [method isEqualToString:@"HEAD"] || [method isEqualToString:@"DELETE"])
	{
		//HMAC the full url
		NSString *hmac = [self hmacForMethod:method url:path body:@""];
		//Append to the url
		NSURL *url = [NSURL URLWithString:
					  [
					   [request.URL absoluteString]
					   stringByAppendingFormat:([path rangeOfString:@"?"].location == NSNotFound ? @"?%@" : @"&%@"), [NSString stringWithFormat:@"signed=%@", hmac]]];
		
		[request setURL:url];
	} else
	{
		//TODO HMAC the body
		NSString *hmac = [self hmacForMethod:method url:path body:@""];
		//request.HTTPBody
		NSURL *url = [NSURL URLWithString:
					  [
					   [request.URL absoluteString]
					   stringByAppendingFormat:([path rangeOfString:@"?"].location == NSNotFound ? @"?%@" : @"&%@"), [NSString stringWithFormat:@"signed=%@", hmac]]];
		
		[request setURL:url];
	}
	return request;
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

- (void)deleteMeWithSuccess:(void (^)())successBlock error:(void (^)(NSError *))errorBlock
{
	NSMutableURLRequest *request = [self requestWithMethod:@"DELETE" path:@"users/me" parameters:nil];
	request = [self addHMACToRequest:request];
	
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

- (void)createUser:(NSString *)name success:(void (^)(NSString *userId, NSString *name))successBlock error:(void (^)(NSError *error))errorBlock
{
	[self createUser:name shouldRetry:YES success:^(NSURLRequest *request, NSHTTPURLResponse *response, id JSON) {
		if(successBlock) successBlock([JSON valueForKey:@"id"], [JSON valueForKey:@"name"]);
	} error:^(NSError *error) {
		if(errorBlock) errorBlock(error);
	}];

}

- (void)createUser:(NSString *)name shouldRetry:(BOOL)shouldRetry success:(void (^)(NSURLRequest *request, NSHTTPURLResponse *response, id JSON))successBlock error:(void (^)(NSError *))errorBlock
{
	NSMutableURLRequest *request = [self requestWithMethod:@"POST" path:@"users" parameters:@{@"name": name}];
	request = [self addHMACToRequest:request];
	
	AFJSONRequestOperation *requestOperation = [AFJSONRequestOperation JSONRequestOperationWithRequest:request
		success:^(NSURLRequest *request, NSHTTPURLResponse *response, id JSON)
		{
			if(successBlock) successBlock(request, response, JSON);
		}
		failure:^(NSURLRequest *request, NSHTTPURLResponse *response, NSError *error, id JSON)
		{
			if(response.statusCode == 300 && shouldRetry) {
				[self createUser:name shouldRetry:NO success:successBlock error:errorBlock];
				return;
		}
			if(errorBlock) errorBlock(error); //if response is 300 msg: Please retry...retry it!
		}
	];

	[self enqueueHTTPRequestOperation:requestOperation];
}

- (void)doesUserExist:(NSString *)userId success:(void (^)(BOOL exists, NSString *userId, NSString *name))successBlock error:(void (^)(NSError *error))errorBlock
{
	NSMutableURLRequest *request = [self requestWithMethod:@"GET" path:[NSString stringWithFormat:@"users/%@", userId] parameters:nil];
	request = [self addHMACToRequest:request];
	AFJSONRequestOperation *requestOperation = [AFJSONRequestOperation JSONRequestOperationWithRequest:request
		success:^(NSURLRequest *request, NSHTTPURLResponse *response, id JSON)
		{
			//Grab room id from JSON.id
			BOOL exists = [[JSON valueForKey:@"exists"] boolValue];
			//BOOL exists = (BOOL)v;
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
	NSMutableURLRequest *request = [self requestWithMethod:@"POST" path:@"users/me" parameters:@{@"newName" : newName}];
	request = [self addHMACToRequest:request];
	
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

- (void)createRoomOnSuccess:(void (^)(NSString *roomId))successBlock error:(void (^)(NSError *error))errorBlock
{
	NSMutableURLRequest *request = [self requestWithMethod:@"POST" path:@"rooms" parameters:nil];
	request = [self addHMACToRequest:request];
	
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

- (void)joinRoom:(NSString *)roomId success:(void (^)(NSString *roomId, NSString *ownerId, NSArray *users, NSArray *playlist))successBlock error:(void (^)(NSError *error))errorBlock
{
	//Escape roomId!!!!!
	
	NSMutableURLRequest *request = [self requestWithMethod:@"GET" path:[NSString stringWithFormat:@"rooms/%@", roomId] parameters:nil];
	request = [self addHMACToRequest:request];
	
	AFJSONRequestOperation *requestOperation = [AFJSONRequestOperation JSONRequestOperationWithRequest:request
		success:^(NSURLRequest *request, NSHTTPURLResponse *response, id JSON)
		{
			//Grab room id from JSON.id, users from JSON.users:[] and playlist from JSON.playlist:[]
			if(successBlock) successBlock([JSON valueForKey:@"id"], [JSON valueForKey:@"owner"], [JSON valueForKey:@"users"], [JSON valueForKey:@"playlist"]);
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
	request = [self addHMACToRequest:request];
	
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
	request = [self addHMACToRequest:request];
	
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
	request = [self addHMACToRequest:request];
	
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

- (void)addYoutubeSongToPlaylist:(NSString *)songId forRoom:(NSString *)roomId success:(void (^)(NSString *songId, int uniqueSongId, NSString *ownerId))successBlock error:(void (^)(NSError *error))errorBlock
{
	NSDictionary *parameters = @{@"song" : @{@"yt" : songId}};
	NSMutableURLRequest *request = [self requestWithMethod:@"POST" path:[NSString stringWithFormat:@"rooms/%@/playlist", roomId] parameters:parameters];
	request = [self addHMACToRequest:request];
	
	AFJSONRequestOperation *requestOperation = [AFJSONRequestOperation JSONRequestOperationWithRequest:request
		success:^(NSURLRequest *request, NSHTTPURLResponse *response, id JSON)
		{
			//JSON.song contains added song info but the websocket should update it correctly
			if(successBlock) successBlock([JSON valueForKeyPath:@"song.id"], [[JSON valueForKeyPath:@"song.uid"] integerValue], [JSON valueForKeyPath:@"song.owner"]);
		}
		failure:^(NSURLRequest *request, NSHTTPURLResponse *response, NSError *error, id JSON)
		{
			if(errorBlock) errorBlock(error);
		}
	];
	
	[self enqueueHTTPRequestOperation:requestOperation];
}

- (void)removeYoutubeSongFromPlaylist:(int)songId forRoom:(NSString *)roomId success:(void (^)(int uniqueSongId))successBlock error:(void (^)(NSError *error))errorBlock
{
	NSMutableURLRequest *request = [self requestWithMethod:@"DELETE" path:[NSString stringWithFormat:@"rooms/%@/playlist/%i", roomId,songId] parameters:nil];
	request = [self addHMACToRequest:request];
	
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
