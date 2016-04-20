//
//  PostViewController.h
//  BulletinBoard
//
//  Created by Daniel Scott on 2/25/16.
//  Copyright © 2016 Not Quite Human. All rights reserved.
//

#import <UIKit/UIKit.h>
@import CoreLocation;

@interface PostViewController : UIViewController <CLLocationManagerDelegate, UITextFieldDelegate, UIPickerViewDelegate>

@property (strong, nonatomic) IBOutlet UITextView* messageBox;
@property (strong, nonatomic) IBOutlet UISegmentedControl* privateSwitch;
@property (strong, nonatomic) IBOutlet UITextField* privateGroup;
@property (strong, nonatomic) IBOutlet UIView* grayView;
@property (strong, nonatomic) IBOutlet UIView* groupSelectorContainer;


-(void)clearForm;

@end
