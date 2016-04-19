//
//  MessageMarker.h
//  BulletinBoard
//
//  Created by Daniel Scott on 4/18/16.
//  Copyright © 2016 Not Quite Human. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "Message.h"
@class Message;
#import <MapKit/MapKit.h>

@interface MessageMarker : NSObject <MKAnnotation>

@property (nonatomic, assign) CLLocationCoordinate2D coordinate;
@property (nonatomic, copy) NSString* title;
@property (nonatomic, copy) NSString* subtitle;
@property (nonatomic) Message* message;

@end
