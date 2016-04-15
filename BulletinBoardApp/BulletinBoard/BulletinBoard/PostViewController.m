//
//  PostViewController.m
//  BulletinBoard
//
//  Created by Daniel Scott on 2/25/16.
//  Copyright © 2016 Not Quite Human. All rights reserved.
//

#import "PostViewController.h"
#import "ConfirmViewController.h"
#import "Group.h"
#import "Constants.h"

@interface PostViewController ()

@property (strong, nonatomic) IBOutlet UITextView* messageBox;
@property (strong, nonatomic) IBOutlet UISegmentedControl* privateSwitch;
@property (strong, nonatomic) IBOutlet UITextField* privateGroup;
@property (strong, nonatomic) IBOutlet UIButton* nextButton;
@property (strong, nonatomic) NSArray* userGroups;
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

-(IBAction)dismissKeyboard:(id)sender {
    [_messageBox resignFirstResponder];
}

-(IBAction)togglePrivate:(id)sender {
    if (_privateSwitch.selectedSegmentIndex == 1) {
        NSString* username = [[NSUserDefaults standardUserDefaults] objectForKey:@"username"];
        NSString* urlString = [NSString stringWithFormat:@"%@groups/listGroups?username=%@", API_DOMAIN, username];
        NSURL* url = [NSURL URLWithString:urlString];
        NSMutableURLRequest* request = [[NSMutableURLRequest alloc] initWithURL:url];
        [request setHTTPMethod:@"GET"];
        [request setValue:@"application/json" forHTTPHeaderField:@"Content-type"];
        NSURLSessionConfiguration* sessionConfig = [NSURLSessionConfiguration defaultSessionConfiguration];
        //sessionConfig.HTTPAdditionalHeaders = {@Authentication", @"AUTH KEY"};
        NSURLSession* conn = [NSURLSession sessionWithConfiguration:sessionConfig];
        NSURLSessionTask* getTask = [conn dataTaskWithRequest:request completionHandler:^(NSData * _Nullable data, NSURLResponse * _Nullable response, NSError * _Nullable error) {
            NSError* jsonError;
            NSDictionary* responseContent = [NSJSONSerialization JSONObjectWithData:data options:0 error:&jsonError];
            NSArray* groups = [responseContent objectForKey:@"items"];
            NSMutableArray* groupList = [[NSMutableArray alloc] init];
            for (NSDictionary* dict in groups) {
                Group* g = [[Group alloc] initWithDict:dict];
                [groupList addObject:g];
            }
            _userGroups = [[NSArray alloc] initWithArray:groupList];
        }
                                     ];
        [getTask resume];
    }
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
