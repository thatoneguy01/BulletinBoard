//
//  Reply.m
//  BulletinBoard
//
//  Created by Daniel Scott on 4/19/16.
//  Copyright © 2016 Not Quite Human. All rights reserved.
//

#import "Reply.h"

@implementation Reply

-(instancetype)initWithDict:(NSDictionary *)dict {
    self = [super init];
    self.rId = [(NSNumber*)[dict objectForKey:@"id"] longLongValue];
    self.parentId = [(NSNumber*)[dict objectForKey:@"parentId"] longLongValue];
    self.message = (NSString*)[dict objectForKey:@"message"];
    self.postingUser = (NSString*)[dict objectForKey:@"postingUSer"];
    self.timePosted = (NSDate*)[dict objectForKey:@"timePosted"];
    return self;
}

-(NSDictionary*)toDict {
    NSMutableDictionary* dict = [[NSMutableDictionary alloc] init];
    [dict setObject:[NSNumber numberWithLongLong:self.rId] forKey:@"id"];
    [dict setObject:[NSNumber numberWithLongLong:self.parentId] forKey:@"parentId"];
    [dict setObject:self.message forKey:@"message"];
    [dict setObject:self.postingUser forKey:@"postingUSer"];
    //[dict setObject:self.timePosted forKey:@"timePosted"];
    return [NSDictionary dictionaryWithDictionary:dict];
}

@end
