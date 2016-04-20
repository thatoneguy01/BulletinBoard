//
//  ConfirmViewController.h
//  BulletinBoard
//
//  Created by Daniel Scott on 2/25/16.
//  Copyright © 2016 Not Quite Human. All rights reserved.
//

#import <UIKit/UIKit.h>
#import <MapKit/MapKit.h>
#import "Message.h"
@class PostViewController;

@interface ConfirmViewController : UIViewController <MKMapViewDelegate>

@property (strong, nonatomic) Message* message;
@property (strong, nonatomic) UITextView* messageBox;
@property (strong, nonatomic) PostViewController* presenter;

@end
