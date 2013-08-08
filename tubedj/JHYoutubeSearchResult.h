//
//  JHYoutubeSearchResult.h
//  tubedj
//
//  Created by Jordan Hamill on 02/08/2013.
//  Copyright (c) 2013 Jordan Hamill. All rights reserved.
//

#import <Foundation/Foundation.h>

@interface JHYoutubeSearchResult : NSObject

@property (strong, nonatomic) NSString *id;

@property (strong, nonatomic) NSString *title;
@property (strong, nonatomic) NSString *author;
@property (strong, nonatomic) NSDate *date;
@property (nonatomic) int lengthInSeconds;
@property (strong, nonatomic) NSURL *videoUrl;
@property (strong, nonatomic) NSURL *thumbnailUrl;

@property (nonatomic, readwrite) BOOL canPlayOnDevice;

@end
