//
//  JHPlaylistItem.h
//  tubedj
//
//  Created by Jordan Hamill on 06/08/2013.
//  Copyright (c) 2013 Jordan Hamill. All rights reserved.
//

#import <Foundation/Foundation.h>

@interface JHPlaylistItem : NSObject

@property (nonatomic) BOOL isYoutube; //song.isYt
@property (copy, nonatomic) NSString *songId;//id
@property (nonatomic) int uid;
@property (copy, nonatomic) NSString *ownerId;
@property (copy, nonatomic) NSString *title;
@property (copy, nonatomic) NSString *artist;
@property (copy, nonatomic) NSString *album;
@property (nonatomic) NSInteger length;

+ (JHPlaylistItem *)fromJSON:(id)JSON;

@end
