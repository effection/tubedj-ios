//
//  JHUserItem.m
//  tubedj
//
//  Created by Jordan Hamill on 06/08/2013.
//  Copyright (c) 2013 Jordan Hamill. All rights reserved.
//

#import "JHUserItem.h"

@implementation JHUserItem

+ (JHUserItem *)fromJSON:(id)JSON
{
	JHUserItem *user = [[JHUserItem alloc] init];
	
	user.userId = [JSON valueForKey:@"id"];
	user.name = [JSON valueForKey:@"name"];
	
	return user;
}

@end
