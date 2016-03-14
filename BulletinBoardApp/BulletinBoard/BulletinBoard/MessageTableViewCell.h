//
//  MessageTableViewCell.h
//  BulletinBoard
//
//  Created by Daniel Scott on 3/12/16.
//  Copyright © 2016 Not Quite Human. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface MessageTableViewCell : UITableViewCell

@property (strong, nonatomic) IBOutlet UIImageView* userImageView;
@property (strong, nonatomic) IBOutlet UILabel* usernameLabel;
@property (strong, nonatomic) IBOutlet UITextView* messageText;

@end
