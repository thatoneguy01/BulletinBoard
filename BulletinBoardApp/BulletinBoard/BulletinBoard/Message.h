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
@property BOOL publicVisable;
@property NSString* timePosted;

-(instancetype)initWithMessage:(NSString*)message;
-(NSDictionary*)toDict;

@end
