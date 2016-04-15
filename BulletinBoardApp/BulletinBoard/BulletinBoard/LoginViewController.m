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
    NSNotificationCenter* center = [NSNotificationCenter defaultCenter];
    //center pr
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

-(void)resign {
    [_passwordField setText:@""];
    [_usernameField becomeFirstResponder];
}

-(void)success {
    NSUserDefaults* defaults = [NSUserDefaults standardUserDefaults];
    NSMutableDictionary* build = [[NSMutableDictionary alloc] init];
    [build setObject:[NSNumber numberWithBool:true] forKey:@"loggedIn"];
    [build setObject:_usernameField.text forKey:@"username"];
    NSDictionary* input = [[NSDictionary alloc] initWithDictionary:build];
    [defaults registerDefaults:input];
    [self presentViewController:[[self storyboard] instantiateViewControllerWithIdentifier:@"entry"] animated:YES completion:nil];
}

-(void)socialSuccess:(NSString*)username {
    NSUserDefaults* defaults = [NSUserDefaults standardUserDefaults];
    NSMutableDictionary* build = [[NSMutableDictionary alloc] init];
    [build setObject:[NSNumber numberWithBool:true] forKey:@"loggedIn"];
    [build setObject:username forKey:@"username"];
    NSDictionary* input = [[NSDictionary alloc] initWithDictionary:build];
    [defaults registerDefaults:input];
    [self presentViewController:[[self storyboard] instantiateViewControllerWithIdentifier:@"entry"] animated:YES completion:nil];
}

-(void)invalidLoginAlert {
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
}

-(void)usernameTaken: (NSNumber*) userId {
    UIAlertController* alert = [UIAlertController alertControllerWithTitle:@"Username taken" message:@"Pkease ender a differnt username." preferredStyle:UIAlertControllerStyleAlert];
    [alert addTextFieldWithConfigurationHandler:^(UITextField * _Nonnull textField) {
        textField.placeholder = @"Enter Username";
    }];
    UIAlertAction* defaultAction = [UIAlertAction actionWithTitle:@"OK" style:UIAlertActionStyleDefault handler:^(UIAlertAction * _Nonnull action) {
        [self chooseUsernameAction:userId alert:alert];
    }];
    [alert addAction:defaultAction];
    [self presentViewController:alert animated:YES completion:nil];
}

-(void)chooseUsernameAction: (NSNumber*)userId alert: (UIAlertController*)alert {
    NSString* username = [alert.textFields objectAtIndex:0].text;
    NSString* urlString = [NSString stringWithFormat:@"%@accounts/accountExists?username=%@", API_DOMAIN, _usernameField.text];
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
        NSNumber* ack = (NSNumber*)[responseContent objectForKey:@"exists"];
        if (![ack boolValue]) {
            NSString* urlString = [NSString stringWithFormat:@"%@accounts/createSocialAccount?username=%@&token=%ld", API_DOMAIN, username, [userId longValue]];
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
                NSNumber* ack = [responseContent objectForKey:@"succeeded"];
                if ([ack boolValue]) {
                    [self performSelectorOnMainThread:@selector(socialSuccess:) withObject:username waitUntilDone:true];
                }
                else {
                    [self performSelectorOnMainThread:@selector(usernameTaken:) withObject:userId waitUntilDone:true];
                }
            }];
            [getTask resume];
        }
        else {
            [self performSelectorOnMainThread:@selector(usernameTaken:) withObject:userId waitUntilDone:true];
            //alert.message = @"Username Taken.  Choose a different username.";
        }
    }];
    [getTask resume];
}

-(void)chooseUsername:(NSNumber*)userId {
    UIAlertController* alert = [UIAlertController alertControllerWithTitle:@"Choose Username" message:@"Please chosse a username for this app." preferredStyle:UIAlertControllerStyleAlert];
    [alert addTextFieldWithConfigurationHandler:^(UITextField * _Nonnull textField) {
        textField.placeholder = @"Enter Username";
    }];
    UIAlertAction* defaultAction = [UIAlertAction actionWithTitle:@"Choose Username" style:UIAlertActionStyleDefault handler:
                                    ^(UIAlertAction * action) {
                                        [self chooseUsernameAction:userId alert:alert];
                                    }];
    [alert addAction:defaultAction];
    [self presentViewController:alert animated:YES completion:nil];
}

-(void)socialLoginFail {
    UIAlertController* alert = [UIAlertController alertControllerWithTitle:@"Login Failed" message:@"Please Try Again" preferredStyle:UIAlertControllerStyleAlert];
    UIAlertAction* defaultAction = [UIAlertAction actionWithTitle:@"OK" style:UIAlertActionStyleDefault handler:
                                    ^(UIAlertAction * action) {}];
    [alert addAction:defaultAction];
    [self presentViewController:alert animated:YES completion:nil];
}

-(IBAction)login:(id)sender {
    if ([_usernameField.text isEqualToString:@""] || [_passwordField.text isEqualToString:@""]) {
        [self invalidLoginAlert];
        return;
    }
    NSString* urlString = [NSString stringWithFormat:@"%@accounts/accountExists?username=%@", API_DOMAIN, _usernameField.text];
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
        NSNumber* ack = [responseContent objectForKey:@"exists"];
        if ([ack boolValue]) {
            NSString* urlString = [NSString stringWithFormat:@"%@accounts/createAccount?username=%@&password=%@", API_DOMAIN, _usernameField.text, _passwordField.text];
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
                                             NSNumber* accepted = [responseContent objectForKey:@"accepted"];
                                             if ([accepted boolValue]) {
                                                 [self performSelectorOnMainThread:@selector(success) withObject:nil waitUntilDone:true];
                                                 return;
                                             }
                                             else {
                                                 [self performSelectorOnMainThread:@selector(invalidLoginAlert) withObject:nil waitUntilDone:true];
                                                 //[self invalidLoginAlert];
                                                 return;
                                             }}];
            [getTask resume];
        }
        else {
            [self performSelectorOnMainThread:@selector(invalidLoginAlert) withObject:nil waitUntilDone:true];
            //[self invalidLoginAlert];
            return;
        }
        [getTask resume];
    }];
    [getTask resume];
    
}

-(IBAction)registerAccount:(id)sender {
    if ([_usernameField.text isEqualToString:@""] || [_passwordField.text isEqualToString:@""]) {
        [self invalidLoginAlert];
        return;
    }
    NSString* urlString = [NSString stringWithFormat:@"%@accounts/accountExists?username=%@", API_DOMAIN, _usernameField.text];
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
                                             NSNumber* accepted = [responseContent objectForKey:@"accepted"];
                                             if ([accepted boolValue]) {
                                                 [self performSelectorOnMainThread:@selector(success) withObject:nil waitUntilDone:true];
                                                 return;
                                             }
                                             else {
                                                 [self performSelectorOnMainThread:@selector(invalidLoginAlert) withObject:nil waitUntilDone:true];
                                                 //[self invalidLoginAlert];
                                                 return;
                                             }}];
            [getTask resume];
        }
        else {
            [self performSelectorOnMainThread:@selector(invalidLoginAlert) withObject:nil waitUntilDone:true];
            //[self invalidLoginAlert];
            return;
        }
        [getTask resume];
    }];
    [getTask resume];
    

}

-(void)loginButton:(FBSDKLoginButton *)loginButton didCompleteWithResult:(FBSDKLoginManagerLoginResult *)result error:(NSError *)error {
    if (result.token) {
        [[[FBSDKGraphRequest alloc] initWithGraphPath:@"me" parameters:nil]
         startWithCompletionHandler:^(FBSDKGraphRequestConnection *connection, id result, NSError *error) {
         
             if (!error) {
                 NSDictionary* data = result;
                 long long userId = (long long)[data objectForKey:@"id"];
#warning fix api parameter name
                 NSString* urlString = [NSString stringWithFormat:@"%@accounts/socialAccountExists?username=%ld", API_DOMAIN, userId];
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
                     NSNumber* ack = (NSNumber*)[responseContent objectForKey:@"exists"];
                     if ([ack boolValue]) {
                         [self performSelectorOnMainThread:@selector(success) withObject:nil waitUntilDone:true];
                     }
                     else {
                         [self performSelectorOnMainThread:@selector(chooseUsername:) withObject:[NSNumber numberWithLong:userId] waitUntilDone:true];
                     }
                 }];
                 [getTask resume];
         }
     }];
    }
}

-(void)loginButtonDidLogOut:(FBSDKLoginButton *)loginButton {
    
}

-(void)facebookLoginFinished {
    
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
