//
//  Message.m
//  BulletinBoard
//
//  Created by Daniel Scott on 2/25/16.
//  Copyright © 2016 Not Quite Human. All rights reserved.
//

#import "Message.h"

@implementation Message

//@synthesize message, publicVisable, postingUser, timePosted, score, location;

-(instancetype)initWithMessage: (NSString*) theMessage {
    self = [super init];
    _message = theMessage;
    return self;
}

-(instancetype)initWithDict: (NSDictionary*)dict {
    self = [super init];
    _mId = [(NSNumber*)[dict objectForKey:@"id"] longLongValue];
    _message = [dict objectForKey:@"message"];
    _postingUser = [dict objectForKey:@"postingUser"];
    _lat = [dict objectForKey:@"latitude"];
    _lon = [dict objectForKey:@"longitude"];
    _score = [(NSNumber*)[dict objectForKey:@"score"] intValue];
    _groupId = [(NSNumber*)[dict objectForKey:@"groupId"] longLongValue];
    NSDateFormatter *outputFormatter = [[NSDateFormatter alloc] init];
    [outputFormatter setDateFormat:@"yyyy-MM-dd'T'HH:mm:ssz"];
    _timePosted = [outputFormatter dateFromString:[dict objectForKey:@"timePosted"]];
    return self;
}

-(NSDictionary*)toDict {
    NSDateFormatter *outputFormatter = [[NSDateFormatter alloc] init];
    [outputFormatter setDateFormat:@"yyyy-MM-dd'T'HH:mm:ssz"];
    NSString* time = [outputFormatter stringFromDate:_timePosted];
    NSLog(time);
    NSDictionary* temp = [[NSDictionary alloc] initWithObjectsAndKeys:
                          _message, @"message",
                          _postingUser, @"postingUser",
                          _lat, @"latitude",
                          _lon, @"longitude",
                          _score, @"score",
                          _groupId, @"groupId",
                          time, @"timePosted",
                          _mId, "id", nil];
    return temp;
}

@end
