//
//  LoginViewController.m
//  BulletinBoard
//
//  Created by Daniel Scott on 3/1/16.
//  Copyright © 2016 Not Quite Human. All rights reserved.
//

#import "LoginViewController.h"
#import <FBSDKCoreKit/FBSDKCoreKit.h>
#import <FBSDKLoginKit/FBSDKLoginKit.h>


@interface LoginViewController ()

@property (strong, nonatomic) IBOutlet UITextField* usernameField;
@property (strong, nonatomic) IBOutlet UITextField* passwordField;
@property (strong, nonatomic) NSString* salt;
@property (strong, nonatomic) IBOutlet UIView* loginButtonContainer;
@property (strong, nonatomic) IBOutlet FBSDKLoginButton* loginButton;


@end

@implementation LoginViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    // Do any additional setup after loading the view.
    _loginButton = [[FBSDKLoginButton alloc] init];
    _loginButton.readPermissions = @[@"email"];
    _loginButton.frame = CGRectMake(0, 0, _loginButtonContainer.frame.size.width, _loginButtonContainer.frame.size.height);
    [_loginButtonContainer addSubview:_loginButton];
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

-(IBAction)login:(id)sender {
    if ([_usernameField.text isEqualToString:@""] || [_passwordField.text isEqualToString:@""]) {
        UIAlertController* alert = [UIAlertController alertControllerWithTitle:@"Invalid username or password" message:@"Please enter a valid username and password." preferredStyle:UIAlertControllerStyleAlert];
        UIAlertAction* defaultAction = [UIAlertAction actionWithTitle:@"OK" style:UIAlertActionStyleDefault handler:
                                        ^(UIAlertAction * action) {
                                            if ([_usernameField.text isEqualToString:@""]) {
                                                [_usernameField becomeFirstResponder];
                                            }
                                            else{
                                                [_passwordField becomeFirstResponder];
                                            }}];
        [alert addAction:defaultAction];
        [self presentViewController:alert animated:YES completion:nil];
        return;
    }
    NSString* urlString = [NSString stringWithFormat:@"CHECK USERNAME URL?username=%@", _usernameField.text];
    NSURL* url = [NSURL URLWithString:urlString];
    NSMutableURLRequest* request = [[NSMutableURLRequest alloc] initWithURL:url];
    [request setHTTPMethod:@"GET"];
    [request setValue:@"application/json" forHTTPHeaderField:@"Content-type"];
    NSURLSessionConfiguration* sessionConfig = [NSURLSessionConfiguration defaultSessionConfiguration];
    //sessionConfig.HTTPAdditionalHeaders = {@Authentication", @"AUTH KEY"};
    NSURLSession* conn = [NSURLSession sessionWithConfiguration:sessionConfig];
    NSURLSessionTask* getTask = [conn dataTaskWithRequest:request completionHandler:^(NSData * _Nullable data, NSURLResponse * _Nullable response, NSError * _Nullable error) {
        //process responce
        NSError* jsonError;
        NSDictionary* responceContent = [NSJSONSerialization JSONObjectWithData:data options:0 error:&jsonError];
        if (response) {
            //on sucess
            
            //NEED TO ADD hash function
            
            NSString* urlString = [NSString stringWithFormat:@"CHECK LOGIN URL?username=%@&hashpass=%@", _usernameField.text, [NSString stringWithFormat:@"%@%@", _passwordField.text, _salt]];
            NSURL* url = [NSURL URLWithString:urlString];
            NSMutableURLRequest* request = [[NSMutableURLRequest alloc] initWithURL:url];
            [request setHTTPMethod:@"GET"];
            [request setValue:@"application/json" forHTTPHeaderField:@"Content-type"];
            NSURLSessionConfiguration* sessionConfig = [NSURLSessionConfiguration defaultSessionConfiguration];
            //sessionConfig.HTTPAdditionalHeaders = {@Authentication", @"AUTH KEY"};
            NSURLSession* conn = [NSURLSession sessionWithConfiguration:sessionConfig];
            NSURLSessionTask* getTask = [conn dataTaskWithRequest:request completionHandler:
                                         ^(NSData * _Nullable data, NSURLResponse * _Nullable response, NSError * _Nullable error) {
                                             if (response) {
                                                 //on success
                                                 //store logged in in user defaults
                                                 //store username in user defaults
                                                 [self presentViewController:[[self storyboard] instantiateViewControllerWithIdentifier:@"tabs"] animated:YES completion:nil];
                                             }
                                             else {
                                                 UIAlertController* alert = [UIAlertController alertControllerWithTitle:@"Login Failed" message:@"Incorrect username or password." preferredStyle:UIAlertControllerStyleAlert];
                                                 UIAlertAction* defaultAction = [UIAlertAction actionWithTitle:@"OK" style:UIAlertActionStyleDefault handler:
                                                                                 ^(UIAlertAction * action) {
                                                                                     [_passwordField setText:@""];
                                                                                     [_usernameField becomeFirstResponder];
                                                                                 }];
                                                 [alert addAction:defaultAction];
                                                 [self presentViewController:alert animated:YES completion:nil];
                                             }}];
        }
        else {
            UIAlertController* alert = [UIAlertController alertControllerWithTitle:@"Login Failed" message:@"Incorrect username or password." preferredStyle:UIAlertControllerStyleAlert];
            UIAlertAction* defaultAction = [UIAlertAction actionWithTitle:@"OK" style:UIAlertActionStyleDefault handler:
                                            ^(UIAlertAction * action) {
                                                [_passwordField setText:@""];
                                                [_usernameField becomeFirstResponder];
                                            }];
            [alert addAction:defaultAction];
            [self presentViewController:alert animated:YES completion:nil];
        }
    }];
    [getTask resume];
    
}

-(IBAction)registerAccount:(id)sender {
    
}

/*
#pragma mark - Navigation

// In a storyboard-based application, you will often want to do a little preparation before navigation
- (void)prepareForSegue:(UIStoryboardSegue *)segue sender:(id)sender {
    // Get the new view controller using [segue destinationViewController].
    // Pass the selected object to the new view controller.
}
*/

@end
