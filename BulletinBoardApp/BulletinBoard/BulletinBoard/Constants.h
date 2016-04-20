//
//  Constants.h
//  BulletinBoard
//
//  Created by Daniel Scott on 2/25/16.
//  Copyright © 2016 Not Quite Human. All rights reserved.
//

#import <Foundation/Foundation.h>

#define API_DOMAIN @"https://bulletinboard-1230.appspot.com/_ah/api/bulletinBoard/v5/"

@interface Constants : NSObject <NSCoding>

@property (strong, nonatomic) NSString* clietntId;
@property (strong, nonatomic) NSString* apiKey;
@property (strong, nonatomic) NSString* username;
@property (strong, nonatomic) NSString* salt;

//-(bool)newGroup;

@end
