//
//  JHYoutubeClient.m
//  tubedj
//
//  Created by Jordan Hamill on 02/08/2013.
//  Copyright (c) 2013 Jordan Hamill. All rights reserved.
//

#import "JHYoutubeClient.h"
#import "AFNetworking.h"

@implementation JHYoutubeClient {
	NSString *lastSearch;
	int nextSearchItemIndex;
	NSDateFormatter *dateFormat;
	BOOL isSearching;
}

- (id)init
{
	self = [super init];
	
	if(self) {
		self.searchResults = [[NSMutableArray alloc] initWithCapacity:20];
		dateFormat = [[NSDateFormatter alloc] init];
		[dateFormat setDateFormat:@"yyyy-MM-dd'T'HH:mm:ss.SSS'Z'"];//2012-12-24T14:00:13.000Z
	}
	
	return self;
}

- (void)searchFor:(NSString *)search
{
	if(isSearching) return;
	isSearching = YES;
	[self.searchResults removeAllObjects];
	
	if([[self delegate] respondsToSelector:@selector(youtubeClient:searchStartedFor:)]) {
		[[self delegate] youtubeClient:self searchStartedFor:search];
	}
	
	[self searchFor:search start:1 maxResults:20];
}

- (void)nextSearchPage
{
	if(isSearching) return;
	isSearching = YES;
	
	if([[self delegate] respondsToSelector:@selector(youtubeClient:nextPageRequestedFor:)]) {
		[[self delegate] youtubeClient:self nextPageRequestedFor:lastSearch];
	}
	[self searchFor:lastSearch start:nextSearchItemIndex maxResults:20];
}

- (void)searchFor:(NSString *)search start:(int)start maxResults:(int)max
{
	lastSearch = search;
	
	search = [search stringByAddingPercentEscapesUsingEncoding:NSUTF8StringEncoding];
    
	NSString *countryCode = [[NSLocale currentLocale] objectForKey: NSLocaleCountryCode];
#if TARGET_IPHONE_SIMULATOR
	countryCode = @"GB";
#endif
    //make HTTP call
    NSString* searchCall = [NSString stringWithFormat:@"http://gdata.youtube.com/feeds/api/videos?q=%@&start-index=%i&max-results=%i&alt=json&v=2&safeSearch=none&restriction=%@", search, start, max, countryCode];//restriction=EN?
	
	NSURL *url = [NSURL URLWithString:searchCall];
	NSURLRequest *request = [NSURLRequest requestWithURL:url];
	
	__weak JHYoutubeClient *weakself = self;
	AFJSONRequestOperation *operation = [AFJSONRequestOperation JSONRequestOperationWithRequest:request success:^(NSURLRequest *request, NSHTTPURLResponse *response, id JSON) {
		
		NSArray *results = [JSON valueForKeyPath:@"feed.entry"];
		NSMutableArray *formattedResults = [[NSMutableArray alloc] initWithCapacity:results.count];
		
		nextSearchItemIndex = start + results.count;
		
		for(int i = 0; i < results.count; i++)
		{
			JHYoutubeSearchResult *searchResultItem = [[JHYoutubeSearchResult alloc] init];
			searchResultItem.title = [results[i] valueForKeyPath:@"title.$t"];
			
			searchResultItem.author = [results[i] valueForKeyPath:@"author.name.$t"][0];
			NSString *published = [results[i] valueForKeyPath:@"published.$t"];
			searchResultItem.date = [dateFormat dateFromString:published];
			NSString *thumbnailUrl = [results[i] valueForKeyPath:@"media$group.media$thumbnail.url"][0];
			
			BOOL canPlayOnDevice = YES;
			
			NSString *errorState = [results[i] valueForKeyPath:@"app$control.yt$state"];
			searchResultItem.canPlayOnDevice = errorState == nil;
			
			NSURL *href = [[NSURL alloc] initWithString:[results[i] valueForKeyPath:@"link.href"][0]];
			searchResultItem.videoUrl = href;
			
			NSString* videoId = nil;
			NSArray *queryComponents = [href.query componentsSeparatedByString:@"&"];
			for (NSString* pair in queryComponents) {
				NSArray* pairComponents = [pair componentsSeparatedByString:@"="];
				if ([pairComponents[0] isEqualToString:@"v"]) {
					videoId = pairComponents[1];
					break;
				}
			}
			
			searchResultItem.id = videoId;
			searchResultItem.thumbnailUrl = [[NSURL alloc] initWithString:thumbnailUrl];
			[formattedResults addObject:searchResultItem];
		}
		
		[self.searchResults addObjectsFromArray:formattedResults];
		
		if([[self delegate] respondsToSelector:@selector(youtubeClient:searchCompletedFor:startingAt:withResults:)]) {
			[[self delegate] youtubeClient:weakself searchCompletedFor:search startingAt:start withResults:formattedResults];
		}
		
		isSearching = NO;
		
	} failure:^(NSURLRequest *request, NSHTTPURLResponse *response, NSError *error, id JSON) {
		NSLog(@"Youtube search error");
	}];//TODO Failure
	
	[operation start];
}

+ (void)getSongDetails:(NSString *)songId success:(void (^)(JHYoutubeSearchResult *result))successBlock error:(void (^)(NSError *error))errorBlock
{
	NSDateFormatter *dateFormat = [[NSDateFormatter alloc] init];
	[dateFormat setDateFormat:@"yyyy-MM-dd'T'HH:mm:ss.SSS'Z'"];
	
	NSString* searchCall = [NSString stringWithFormat:@"https://gdata.youtube.com/feeds/api/videos/%@?v=2&alt=json", songId];
	
	NSURL *url = [NSURL URLWithString:searchCall];
	NSURLRequest *request = [NSURLRequest requestWithURL:url];
	
	AFJSONRequestOperation *operation = [AFJSONRequestOperation JSONRequestOperationWithRequest:request success:^(NSURLRequest *request, NSHTTPURLResponse *response, id JSON) {
		
		id result = [JSON valueForKeyPath:@"entry"];

		JHYoutubeSearchResult *searchResultItem = [[JHYoutubeSearchResult alloc] init];
		searchResultItem.title = [result valueForKeyPath:@"title.$t"];
		
		searchResultItem.author = [result valueForKeyPath:@"author.name.$t"][0];
		NSString *published = [result valueForKeyPath:@"published.$t"];
		searchResultItem.date = [dateFormat dateFromString:published];
		NSString *thumbnailUrl = [result valueForKeyPath:@"media$group.media$thumbnail.url"][0];
		
		
		NSURL *href = [[NSURL alloc] initWithString:[result valueForKeyPath:@"link.href"][0]];
		searchResultItem.videoUrl = href;
		
		NSString* videoId = nil;
		NSArray *queryComponents = [href.query componentsSeparatedByString:@"&"];
		for (NSString* pair in queryComponents) {
			NSArray* pairComponents = [pair componentsSeparatedByString:@"="];
			if ([pairComponents[0] isEqualToString:@"v"]) {
				videoId = pairComponents[1];
				break;
			}
		}
		
		searchResultItem.id = videoId;
		searchResultItem.thumbnailUrl = [[NSURL alloc] initWithString:thumbnailUrl];
		
		if(successBlock) successBlock(searchResultItem);
	
		
	} failure:nil];
	
	[operation start];
}

@end
