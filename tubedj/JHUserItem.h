//
//  JHUserItem.h
//  tubedj
//
//  Created by Jordan Hamill on 06/08/2013.
//  Copyright (c) 2013 Jordan Hamill. All rights reserved.
//

#import <Foundation/Foundation.h>

@interface JHUserItem : NSObject

@property (copy, nonatomic) NSString *userId;
@property (copy, nonatomic) NSString *name;

+ (JHUserItem *)fromJSON:(id)JSON;

@end
