//
//  Constants.m
//  BulletinBoard
//
//  Created by Daniel Scott on 2/25/16.
//  Copyright © 2016 Not Quite Human. All rights reserved.
//

#import "Constants.h"

@implementation Constants

#pragma mark NSCoding

-(instancetype)initWithCoder:(NSCoder *)aDecoder {
    self = [super init];
    NSString* clientId = [aDecoder decodeObjectForKey:@"clientId"];
    NSString* apiKey = [aDecoder decodeObjectForKey:@"apiKey"];
    NSString* username = [aDecoder decodeObjectForKey:@"username"];
    if (clientId) {
        _clietntId = clientId;
    }
    if (apiKey) {
        _apiKey = apiKey;
    }
    if (username) {
        _username = username;
    }
    return self;
}

-(void)encodeWithCoder:(NSCoder *)aCoder {
    [aCoder encodeObject:_clietntId forKey:@"clientId"];
    [aCoder encodeObject:_apiKey forKey:@"apiKey"];
    [aCoder encodeObject:_username forKey:@"username"];
}


@end
