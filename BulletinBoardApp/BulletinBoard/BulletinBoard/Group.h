//
//  Group.h
//  BulletinBoard
//
//  Created by Daniel Scott on 4/11/16.
//  Copyright © 2016 Not Quite Human. All rights reserved.
//

#import <Foundation/Foundation.h>

@interface Group : NSObject

@property long long groupId;
@property NSString* name;
@property NSDate* time;

-(instancetype)initWithDict: (NSDictionary*)dict;

@end
