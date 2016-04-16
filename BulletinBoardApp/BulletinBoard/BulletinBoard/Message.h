//
//  Message.h
//  BulletinBoard
//
//  Created by Daniel Scott on 2/25/16.
//  Copyright © 2016 Not Quite Human. All rights reserved.
//

#import <Foundation/Foundation.h>

@interface Message : NSObject

@property NSString* message;
@property NSString* postingUser;
@property int score;
@property NSString* location;
@property NSNumber* lat;
@property NSNumber* lon;
@property long long groupId;
@property NSDate* timePosted;

-(instancetype)initWithMessage:(NSString*)message;
-(instancetype)initWithDict: (NSDictionary*)dic;
-(NSDictionary*)toDict;

@end
