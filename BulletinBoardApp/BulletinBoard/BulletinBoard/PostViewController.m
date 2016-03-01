//
//  PostViewController.m
//  BulletinBoard
//
//  Created by Daniel Scott on 2/25/16.
//  Copyright © 2016 Not Quite Human. All rights reserved.
//

#import "PostViewController.h"
#import "ConfirmViewController.h"

@interface PostViewController ()

@property (strong, nonatomic) IBOutlet UITextView* messageBox;
@property (strong, nonatomic) IBOutlet UISegmentedControl* privateSwitch;
@property (strong, nonatomic) IBOutlet UITextField* privateGroup;
@property (strong, nonatomic) IBOutlet UIButton* nextButton;
//@property (strong, nonatomic) Modal* popController;

@end

@implementation PostViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    // Do any additional setup after loading the view.
    [self.view addGestureRecognizer:[[UITapGestureRecognizer alloc] initWithTarget:self.view action:@selector(endEditing:)]];
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

-(IBAction)dismissKeyboard:(id)sender{
    [_messageBox resignFirstResponder];
}

#pragma mark - Navigation

// In a storyboard-based application, you will often want to do a little preparation before navigation
- (void)prepareForSegue:(UIStoryboardSegue *)segue sender:(id)sender {
    ConfirmViewController* destination = [segue destinationViewController];
    destination.message = [[Message alloc] initWithMessage:_messageBox.text];
    destination.message.postingUser = @"test";
    destination.message.score = 0;
    NSDate * now = [NSDate date];
    NSDateFormatter *outputFormatter = [[NSDateFormatter alloc] init];
    [outputFormatter setDateFormat:@"HH:mm:ss"];
    destination.message.timePosted = [outputFormatter stringFromDate:now];
    if (_privateSwitch.selectedSegmentIndex == 0)
        destination.message.publicVisable = YES;
    else
        destination.message.publicVisable = NO;
}

@end
