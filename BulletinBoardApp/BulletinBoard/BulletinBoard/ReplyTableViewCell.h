//
//  ReplyTableViewCell.h
//  BulletinBoard
//
//  Created by Daniel Scott on 3/12/16.
//  Copyright © 2016 Not Quite Human. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface ReplyTableViewCell : UITableViewCell

@property (strong, nonatomic) IBOutlet UILabel* usernameLabel;
@property (strong, nonatomic) IBOutlet UITextView* replyText;

@end
