//
//  YourMessagesTableViewController.h
//  BulletinBoard
//
//  Created by Daniel Scott on 4/16/16.
//  Copyright © 2016 Not Quite Human. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface YourMessagesTableViewController : UITableViewController <UIPopoverControllerDelegate>

@property (strong, nonatomic) NSArray* messages;

-(void)modifyMessage: (NSDictionary*) info;

@end
