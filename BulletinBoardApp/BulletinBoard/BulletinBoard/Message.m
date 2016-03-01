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

-(NSDictionary*)toDict {
    NSDictionary* temp = [[NSDictionary alloc] initWithObjectsAndKeys:
                          _message, @"message",
                          _postingUser, @"postingUser",
                          _location, @"location",
                          _score, @"score",
                          _publicVisable, @"publicVisable",
                          _timePosted, @"timePosted", nil];
    return temp;
}

@end
