//
//  YourMessagesTableViewCell.h
//  BulletinBoard
//
//  Created by Daniel Scott on 4/16/16.
//  Copyright © 2016 Not Quite Human. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "Message.h"

@interface YourMessagesTableViewCell : UITableViewCell

@property (strong, nonatomic) IBOutlet UILabel* messagePreview;
@property (strong, nonatomic) IBOutlet UILabel* date;
@property (strong, nonatomic) Message* message;

@end
