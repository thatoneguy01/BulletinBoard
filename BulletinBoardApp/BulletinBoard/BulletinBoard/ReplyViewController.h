//
//  ReplyViewController.h
//  BulletinBoard
//
//  Created by Daniel Scott on 3/12/16.
//  Copyright © 2016 Not Quite Human. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface ReplyViewController : UIViewController

@property (strong, nonatomic) IBOutlet UIImage* imageView;
@property (strong, nonatomic) IBOutlet UILabel* usernameLabel;
@property (strong, nonatomic) IBOutlet UIButton* upVoteButton;
@property (strong, nonatomic) IBOutlet UIButton* downVoteButton;
@property (strong, nonatomic) IBOutlet UITextView* messageText;
@property (strong, nonatomic) IBOutlet UITextView* replyTextArea;
@property (strong, nonatomic) IBOutlet UIButton* replyButton;

@end
