//
//  Message.h
//  BulletinBoard
//
//  Created by Daniel Scott on 2/25/16.
//  Copyright © 2016 Not Quite Human. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "MessageMarker.h"

@interface Message : NSObject

@property long long mId;
@property NSString* message;
@property NSString* postingUser;
@property int score;
//@property CLLocationCoordinate2D location;
@property NSNumber* lat;
@property NSNumber* lon;
@property long long groupId;
@property NSDate* timePosted;

-(instancetype)initWithMessage:(NSString*)message;
-(instancetype)initWithDict: (NSDictionary*)dic;
-(NSDictionary*)toDict;
-(MessageMarker*)toMarker;

@end
