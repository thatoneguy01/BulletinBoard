//
//  LoginViewController.m
//  BulletinBoard
//
//  Created by Daniel Scott on 3/1/16.
//  Copyright © 2016 Not Quite Human. All rights reserved.
//

#import "LoginViewController.h"
#import "Constants.h"
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
    [FBSDKProfile enableUpdatesOnAccessTokenChange:true];
    _loginButton = [[FBSDKLoginButton alloc] init];
    [_loginButton setDelegate:self];
    _loginButton.readPermissions = @[@"public_profile", @"email"];
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
    NSString* urlString = [NSString stringWithFormat:@"%saccounts/accountExists?username=%@", API_DOMAIN, _usernameField.text];
    NSURL* url = [NSURL URLWithString:urlString];
    NSMutableURLRequest* request = [[NSMutableURLRequest alloc] initWithURL:url];
    [request setHTTPMethod:@"GET"];
    [request setValue:@"application/json" forHTTPHeaderField:@"Content-type"];
    NSURLSessionConfiguration* sessionConfig = [NSURLSessionConfiguration defaultSessionConfiguration];
    //sessionConfig.HTTPAdditionalHeaders = {@Authentication", @"AUTH KEY"};
    NSURLSession* conn = [NSURLSession sessionWithConfiguration:sessionConfig];
    NSURLSessionTask* getTask = [conn dataTaskWithRequest:request completionHandler:^(NSData * _Nullable data, NSURLResponse * _Nullable response, NSError * _Nullable error) {
        //process response
        NSError* jsonError;
        NSDictionary* responseContent = [NSJSONSerialization JSONObjectWithData:data options:0 error:&jsonError];
        if ((bool)[responseContent objectForKey:@"exists"]) {
            NSString* urlString = [NSString stringWithFormat:@"%@accounts/checkPassword?username=%@&password=%@", API_DOMAIN, _usernameField.text, _passwordField.text];
            NSURL* url = [NSURL URLWithString:urlString];
            NSMutableURLRequest* request = [[NSMutableURLRequest alloc] initWithURL:url];
            [request setHTTPMethod:@"GET"];
            [request setValue:@"application/json" forHTTPHeaderField:@"Content-type"];
            NSURLSessionConfiguration* sessionConfig = [NSURLSessionConfiguration defaultSessionConfiguration];
            //sessionConfig.HTTPAdditionalHeaders = {@Authentication", @"AUTH KEY"};
            NSURLSession* conn = [NSURLSession sessionWithConfiguration:sessionConfig];
            NSURLSessionTask* getTask = [conn dataTaskWithRequest:request completionHandler:
                                         ^(NSData * _Nullable data, NSURLResponse * _Nullable response, NSError * _Nullable error) {
                                             NSError* jsonError;
                                             NSDictionary* responseContent = [NSJSONSerialization JSONObjectWithData:data options:0 error:&jsonError];
                                             if ((bool)[responseContent objectForKey:@"succeeded"]) {
                                                 NSUserDefaults* defaults = [NSUserDefaults standardUserDefaults];
                                                 NSDictionary* input = [[NSDictionary alloc] initWithObjectsAndKeys:@"loggedIn", true, "username", _usernameField.text, nil];
                                                 [defaults registerDefaults:input];
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
        [getTask resume];
    }];
    [getTask resume];
    
}

-(IBAction)registerAccount:(id)sender {
    
}

-(void)loginButton:(FBSDKLoginButton *)loginButton didCompleteWithResult:(FBSDKLoginManagerLoginResult *)result error:(NSError *)error {
    if (result.token) {
        [[[FBSDKGraphRequest alloc] initWithGraphPath:@"me" parameters:nil]
         startWithCompletionHandler:^(FBSDKGraphRequestConnection *connection, id result, NSError *error) {
         
             if (!error) {
                 NSDictionary* data = result;
                 long userId = (long)[data objectForKey:@"id"];
                 NSString* urlString = [NSString stringWithFormat:@"%saccounts/socialAccoutExist?userId=%ld", API_DOMAIN, userId];
                 NSURL* url = [NSURL URLWithString:urlString];
                 NSMutableURLRequest* request = [[NSMutableURLRequest alloc] initWithURL:url];
                 [request setHTTPMethod:@"GET"];
                 [request setValue:@"application/json" forHTTPHeaderField:@"Content-type"];
                 NSURLSessionConfiguration* sessionConfig = [NSURLSessionConfiguration defaultSessionConfiguration];
                 //sessionConfig.HTTPAdditionalHeaders = {@Authentication", @"AUTH KEY"};
                 NSURLSession* conn = [NSURLSession sessionWithConfiguration:sessionConfig];
                 NSURLSessionTask* getTask = [conn dataTaskWithURL:url completionHandler:^(NSData * _Nullable data, NSURLResponse * _Nullable response, NSError * _Nullable error) {
                     NSError* jsonError;
                     NSDictionary* responseContent = [NSJSONSerialization JSONObjectWithData:data options:0 error:&jsonError];
                     if ((bool)[responseContent objectForKey:@"exists"]) {
                         NSUserDefaults* defaults = [NSUserDefaults standardUserDefaults];
                         NSDictionary* input = [[NSDictionary alloc] initWithObjectsAndKeys:@"loggedIn", true, "username", (NSString*)[responseContent objectForKey:@"username"], nil];
                         [defaults registerDefaults:input];
                         [self presentViewController:[[self storyboard] instantiateViewControllerWithIdentifier:@"tabs"] animated:YES completion:nil];
                     }
                     else {
                         UIAlertController* alert = [UIAlertController alertControllerWithTitle:@"Choose Userna,e" message:@"Please chosse a username for this app." preferredStyle:UIAlertControllerStyleAlert];
                         [alert addTextFieldWithConfigurationHandler:^(UITextField * _Nonnull textField) {
                             textField.placeholder = @"Enter Username";
                         }];
                         UIAlertAction* defaultAction = [UIAlertAction actionWithTitle:@"Choose Username" style:UIAlertActionStyleDefault handler:
                                                         ^(UIAlertAction * action) {
                                                             NSString* username = [alert.textFields objectAtIndex:0].text;
                                                             NSString* urlString = [NSString stringWithFormat:@"%saccounts/accountExists?username=%@", API_DOMAIN, _usernameField.text];
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
                                                                 if (!(bool)[responseContent objectForKey:@"exists"]) {
                                                                     NSString* urlString = [NSString stringWithFormat:@"%saccounts/createSocialAccount?username=%@&userId=%ld", API_DOMAIN, username, userId];
                                                                     NSURL* url = [NSURL URLWithString:urlString];
                                                                     NSMutableURLRequest* request = [[NSMutableURLRequest alloc] initWithURL:url];
                                                                     [request setHTTPMethod:@"GET"];
                                                                     [request setValue:@"application/json" forHTTPHeaderField:@"Content-type"];
                                                                     NSURLSessionConfiguration* sessionConfig = [NSURLSessionConfiguration defaultSessionConfiguration];
                                                                     //sessionConfig.HTTPAdditionalHeaders = {@Authentication", @"AUTH KEY"};
                                                                     NSURLSession* conn = [NSURLSession sessionWithConfiguration:sessionConfig];
                                                                     NSURLSessionTask* getTask = [conn dataTaskWithURL:url completionHandler:^(NSData * _Nullable data, NSURLResponse * _Nullable response, NSError * _Nullable error) {
                                                                         NSError* jsonError;
                                                                         NSDictionary* responseContent = [NSJSONSerialization JSONObjectWithData:data options:0 error:&jsonError];
                                                                         if ((bool)[responseContent objectForKey:@"succeeded"]) {
                                                                             NSUserDefaults* defaults = [NSUserDefaults standardUserDefaults];
                                                                             NSDictionary* input = [[NSDictionary alloc] initWithObjectsAndKeys:@"loggedIn", true, "username", (NSString*)[responseContent objectForKey:@"username"], nil];
                                                                             [defaults registerDefaults:input];
                                                                             [self presentViewController:[[self storyboard] instantiateViewControllerWithIdentifier:@"tabs"] animated:YES completion:nil];
                                                                         }
                                                                         else {
                                                                             UIAlertController* alert = [UIAlertController alertControllerWithTitle:@"Login Failed" message:@"Please Try Again" preferredStyle:UIAlertControllerStyleAlert];
                                                                             UIAlertAction* defaultAction = [UIAlertAction actionWithTitle:@"OK" style:UIAlertActionStyleDefault handler:
                                                                                                             ^(UIAlertAction * action) {}];
                                                                             [alert addAction:defaultAction];
                                                                             [self presentViewController:alert animated:YES completion:nil];
                                                                         }
                                                                     }];
                                                                     [getTask resume];
                                                                 }
                                                                 else {
                                                                     alert.message = @"Username Taken.  Choose a different username.";
                                                                 }
                                                             }];
                                                             [getTask resume];
                                                         }];
                         [alert addAction:defaultAction];
                         [self presentViewController:alert animated:YES completion:nil];
                     }
                 }];
                 [getTask resume];
         }
     }];
    }
}

-(void)loginButtonDidLogOut:(FBSDKLoginButton *)loginButton {
    
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
