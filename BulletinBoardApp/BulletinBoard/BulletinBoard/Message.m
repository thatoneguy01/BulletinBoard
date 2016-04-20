//
//  Message.m
//  BulletinBoard
//
//  Created by Daniel Scott on 2/25/16.
//  Copyright © 2016 Not Quite Human. All rights reserved.
//

#import "Message.h"
#import "MessageMarker.h"
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
    //_location = CLLocationCoordinate2DMake([(NSNumber*)[dict objectForKey:@"latitude"] floatValue], [(NSNumber*)[dict objectForKey:@"longitude"] floatValue]);
    _lat = [dict objectForKey:@"latitude"];
    _lon = [dict objectForKey:@"longitude"];
    _score = [(NSNumber*)[dict objectForKey:@"score"] intValue];
    _groupId = (long long)[dict objectForKey:@"groupId"];
    NSDateFormatter *outputFormatter = [[NSDateFormatter alloc] init];
    [outputFormatter setDateFormat:@"yyyy-MM-dd'T'HH:mm:ssz"];
    _timePosted = [outputFormatter dateFromString:[dict objectForKey:@"timePosted"]];
    return self;
}

-(NSDictionary*)toDict {
    NSDateFormatter *outputFormatter = [[NSDateFormatter alloc] init];
    [outputFormatter setDateFormat:@"yyyy-MM-dd'T'HH:mm:ssz"];
    NSString* time = [outputFormatter stringFromDate:_timePosted];
    //NSNumber* gId = [NSNumber numberWithLongLong:_groupId];
    NSMutableDictionary* temp = [[NSMutableDictionary alloc] init];
    [temp setObject:_message forKey:@"message"];
    [temp setObject:_lat forKey:@"latitude"];
    [temp setObject:_lon forKey:@"longitude"];
    [temp setObject:_postingUser forKey:@"postingUser"];
    [temp setObject:@(_score) forKey:@"score"];
    [temp setObject:@(_groupId) forKey:@"groupId"];
    //[temp setObject:time forKey:@"timePosted"];
    [temp setObject:@(_mId) forKey:@"id"];
    
    return [NSDictionary dictionaryWithDictionary:temp];
}

-(MessageMarker*)toMarker {
    MessageMarker* m = [[MessageMarker alloc] init];
    m.title = self.message;
    m.subtitle = self.postingUser;
    m.coordinate = CLLocationCoordinate2DMake([self.lat doubleValue], [self.lon doubleValue]);
    m.message = self;
    return m;
}

@end
