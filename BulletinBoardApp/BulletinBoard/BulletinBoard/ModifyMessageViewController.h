//
//  ModifyMessageViewController.h
//  BulletinBoard
//
//  Created by Daniel Scott on 4/16/16.
//  Copyright © 2016 Not Quite Human. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "Message.h"
#import "YourMessagesTableViewController.h"

@interface ModifyMessageViewController : UIViewController

@property (strong, nonatomic) Message* message;
@property (strong, nonatomic) YourMessagesTableViewController* presenter;
@property NSNumber* row;

@end
