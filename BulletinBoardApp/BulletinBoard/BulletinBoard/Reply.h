//
//  Reply.h
//  BulletinBoard
//
//  Created by Daniel Scott on 4/19/16.
//  Copyright © 2016 Not Quite Human. All rights reserved.
//

#import <Foundation/Foundation.h>

@interface Reply : NSObject

@property long long rId;
@property NSString* message;
@property long long parentId;
@property NSDate* timePosted;
@property NSString* postingUser;

-(instancetype)initWithDict: (NSDictionary*)dict;
-(NSDictionary*)toDict;

@end
