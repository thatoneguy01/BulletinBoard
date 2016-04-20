//
//  Group.m
//  BulletinBoard
//
//  Created by Daniel Scott on 4/11/16.
//  Copyright © 2016 Not Quite Human. All rights reserved.
//

#import "Group.h"

@implementation Group
@synthesize groupId, name, time;

-(instancetype)initWithDict: (NSDictionary*)dict {
    self = [super init];
    groupId = [(NSNumber*)[dict objectForKey:@"id"] longLongValue];
    name = (NSString*)[dict objectForKey:@"name"];
    time = (NSDate*)[dict objectForKey:@"time"];
    return self;
}

@end
