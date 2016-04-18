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
@import CoreLocation;

@interface PostViewController ()

//@property (strong, nonatomic) IBOutlet UITextView* messageBox;
@property (strong, nonatomic) IBOutlet UISegmentedControl* privateSwitch;
@property (strong, nonatomic) IBOutlet UITextField* privateGroup;
@property (strong, nonatomic) IBOutlet UIButton* nextButton;
@property (strong, nonatomic) NSArray* userGroups;
@property (strong, nonatomic) IBOutlet UIView* grayView;
@property (strong, nonatomic) IBOutlet UIView* groupSelectorContainer;
@property NSInteger index;
@property (strong) CLLocationManager* locationManager;
@property (strong, nonatomic) UIPickerView* picker;


//@property (strong, nonatomic) Modal* popController;

@end

@implementation PostViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    // Do any additional setup after loading the view.
    _grayView = [[UIView alloc] initWithFrame:[_groupSelectorContainer bounds]];
    _grayView.backgroundColor = [UIColor colorWithWhite:0.5 alpha:0.5];
    [_groupSelectorContainer addSubview:_grayView];
    _privateGroup.delegate = self;
    NSString* username = [[NSUserDefaults standardUserDefaults] objectForKey:@"username"];
    NSString* urlString = [NSString stringWithFormat:@"%@groups/groupsForUser?username=%@", API_DOMAIN, username];
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
        _userGroups = [groupList sortedArrayUsingComparator:^NSComparisonResult(id  _Nonnull obj1, id  _Nonnull obj2) {
            Group* g1 = (Group*)obj1;
            Group* g2 = (Group*)obj2;
            return [g1.name compare:g2.name];
        }];
    }
                                 ];
    [getTask resume];
    [self.view addGestureRecognizer:[[UITapGestureRecognizer alloc] initWithTarget:self.view action:@selector(endEditing:)]];
    _picker = [[UIPickerView alloc] init];
    _picker.delegate = self;
    //_picker.hidden = true;
    _privateGroup.delegate = self;
    _privateGroup.inputView = _picker;
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

-(IBAction)dismissKeyboard:(id)sender {
    [_messageBox resignFirstResponder];
}

-(void)clearForm {
    _messageBox.text = @"";
    if (_privateSwitch.selectedSegmentIndex == 1) {
        _privateSwitch.selectedSegmentIndex = 0;
        _grayView.hidden = false;
    }
}

-(IBAction)togglePrivate:(id)sender {
    if (_privateSwitch.selectedSegmentIndex == 1) {
        _grayView.hidden = true;
        NSString* username = [[NSUserDefaults standardUserDefaults] objectForKey:@"username"];
        NSString* urlString = [NSString stringWithFormat:@"%@groups/groupsForUser?username=%@", API_DOMAIN, username];
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
            _userGroups = [groupList sortedArrayUsingComparator:^NSComparisonResult(id  _Nonnull obj1, id  _Nonnull obj2) {
                Group* g1 = (Group*)obj1;
                Group* g2 = (Group*)obj2;
                return [g1.name compare:g2.name];
            }];        }
                                     ];
        [getTask resume];
    }
    else {
        _grayView.hidden = false;
    }
}

-(void)pickerView:(UIPickerView *)pickerView didSelectRow:(NSInteger)row inComponent:(NSInteger)component {
    _privateGroup.text = [(Group*)_userGroups[row] name];
    _index = row;
    //_picker.hidden = true;
    [self dismissKeyboard:_privateGroup];
}

-(NSString *)pickerView:(UIPickerView *)pickerView titleForRow:(NSInteger)row forComponent:(NSInteger)component {
    return [(Group*)_userGroups[row] name];
}

- (NSInteger)pickerView:(UIPickerView *)pickerView numberOfRowsInComponent:(NSInteger)component {
    return _userGroups.count;
}

- (NSInteger)numberOfComponentsInPickerView:(UIPickerView *)pickerView {
    return 1;
}

-(void)textFieldDidBeginEditing:(UITextField *)textField {
    //_picker.hidden = false;
    
}

-(BOOL) textField:(UITextField *)textField shouldChangeCharactersInRange:(NSRange)range replacementString:(NSString *)string {
    return false;
}

#pragma mark - Navigation

// In a storyboard-based application, you will often want to do a little preparation before navigation
- (void)prepareForSegue:(UIStoryboardSegue *)segue sender:(id)sender {
    ConfirmViewController* destination = [segue destinationViewController];
    destination.message = [[Message alloc] initWithMessage:_messageBox.text];
    destination.message.postingUser = [[NSUserDefaults standardUserDefaults] stringForKey:@"username"];
    destination.message.score = 0;
    destination.messageBox = _messageBox;
    NSDate * now = [NSDate date];
    destination.message.timePosted = now;
    if (_privateSwitch.selectedSegmentIndex == 0)
        destination.message.groupId = -1;
    else {
        destination.message.groupId = ((Group*)[_userGroups objectAtIndex:_index]).groupId;
        }
}

-(BOOL) shouldPerformSegueWithIdentifier:(NSString *)identifier sender:(id)sender {
    if (_privateSwitch.selectedSegmentIndex == 1 && [_privateGroup.text isEqualToString:@""]) {
        UIAlertController* alert = [UIAlertController alertControllerWithTitle:@"Error" message:@"Please Select a group" preferredStyle:UIAlertControllerStyleAlert];
        UIAlertAction* defaultAction = [UIAlertAction actionWithTitle:@"OK" style:UIAlertActionStyleDefault handler:nil];
        [alert addAction:defaultAction];
        [self presentViewController:alert animated:YES completion:nil];
        return false;
    }
    else
        return true;
}

@end
