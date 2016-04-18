//
//  YourGroupsTableViewCell.h
//  BulletinBoard
//
//  Created by Daniel Scott on 4/17/16.
//  Copyright © 2016 Not Quite Human. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "Group.h"

@interface YourGroupsTableViewCell : UITableViewCell

@property (strong, nonatomic) IBOutlet UILabel* groupName;
@property (strong, nonatomic) Group* group;
@property (strong, nonatomic) NSNumber* row;

@end
