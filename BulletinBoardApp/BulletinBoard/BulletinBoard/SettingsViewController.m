//
//  SettingsViewController.m
//  BulletinBoard
//
//  Created by Daniel Scott on 4/15/16.
//  Copyright © 2016 Not Quite Human. All rights reserved.
//

#import "SettingsViewController.h"
#import "YourGroupsTableViewController.h"
#import "YourMessagesTableViewController.h"
#import "Message.h"
#import "Group.h"
#import "Constants.h"

@interface SettingsViewController ()

@property (strong, nonatomic) IBOutlet UILabel* username;
@property (strong, nonatomic) IBOutlet UIButton* logoutButton;
@property (strong, nonatomic) IBOutlet UIView* logoutBox;
@property (strong, nonatomic) FBSDKLoginButton* fBlogoutButton;
@property (strong, nonatomic) UIActivityIndicatorView* spinner;

@end

@implementation SettingsViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    _username.text = [[NSUserDefaults standardUserDefaults] stringForKey:@"username"];
    _spinner = [[UIActivityIndicatorView alloc] initWithFrame:CGRectMake(135,140,50,50)];
    _spinner.center = self.view.center;
    if ([FBSDKAccessToken currentAccessToken]) {
        [FBSDKProfile enableUpdatesOnAccessTokenChange:true];
        _fBlogoutButton = [[FBSDKLoginButton alloc] init];
        [_fBlogoutButton setDelegate:self];
        _fBlogoutButton.readPermissions = @[@"public_profile", @"email"];
        _fBlogoutButton.frame = CGRectMake(0, 0, _logoutBox.frame.size.width, _logoutBox.frame.size.height);
        [_logoutBox addSubview:_fBlogoutButton];
        _logoutButton.hidden = true;
    }
    else
        _logoutBox.hidden = true;
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

-(void)displayMessages: (NSArray*) messages {
    YourMessagesTableViewController* dest = [[UIStoryboard storyboardWithName:@"Main" bundle:nil] instantiateViewControllerWithIdentifier:@"yourMessages"];
    dest.messages = messages;
    [self.navigationController pushViewController:dest animated:true];
    [_spinner removeFromSuperview];
    self.view.userInteractionEnabled = true;
}

-(void)displayGroups: (NSArray*) groups {
    YourGroupsTableViewController* dest = [[UIStoryboard storyboardWithName:@"Main" bundle:nil] instantiateViewControllerWithIdentifier:@"yourGroups"];
    dest.groups = groups;
    [self.navigationController pushViewController:dest animated:true];
    [_spinner removeFromSuperview];
    self.view.userInteractionEnabled = true;
}

-(IBAction)getUserMessages:(id)sender {
    NSString* urlString = [NSString stringWithFormat:@"%@messages/messagesForUser?username=%@", API_DOMAIN, [[NSUserDefaults standardUserDefaults] stringForKey:@"username"]];
    NSURL* url = [NSURL URLWithString:urlString];
    NSMutableURLRequest* request = [[NSMutableURLRequest alloc] initWithURL:url];
    [request setHTTPMethod:@"GET"];
    [request setValue:@"application/json" forHTTPHeaderField:@"Content-type"];
    NSURLSessionConfiguration* sessionConfig = [NSURLSessionConfiguration defaultSessionConfiguration];
    //sessionConfig.HTTPAdditionalHeaders = {@Authentication", @"AUTH KEY"};
    NSURLSession* conn = [NSURLSession sessionWithConfiguration:sessionConfig];
    NSURLSessionTask* getTask = [conn dataTaskWithRequest:request completionHandler:^(NSData * _Nullable data, NSURLResponse * _Nullable response, NSError * _Nullable error) {
        NSLog(@"RESPONCE RECIEVED");
        NSError* jsonError;
        NSDictionary* responseContent = [NSJSONSerialization JSONObjectWithData:data options:0 error:&jsonError];
        NSArray* messageDicts = [responseContent objectForKey:@"items"];
        NSMutableArray* messages = [[NSMutableArray alloc] init];
        for (NSDictionary* dict in messageDicts) {
            [messages addObject:[[Message alloc] initWithDict:dict]];
        }
        [self performSelectorOnMainThread:@selector(displayMessages:) withObject:messages waitUntilDone:true];
        
}];
    [getTask resume];
    [_spinner startAnimating];
    self.view.userInteractionEnabled = false;
    [self.view addSubview:_spinner];
}

-(IBAction)getUserGroups:(id)sender {
    NSString* urlString = [NSString stringWithFormat:@"%@accounts/groupsForUser?username=%@", API_DOMAIN, [[NSUserDefaults standardUserDefaults] stringForKey:@"username"]];
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
        NSArray* groupDicts = [responseContent objectForKey:@"items"];
        NSMutableArray* groups = [[NSMutableArray alloc] init];
        for (NSDictionary* dict in groupDicts) {
            [groups addObject:[[Group alloc] initWithDict:dict]];
        }
        [self performSelectorOnMainThread:@selector(displayGroups:) withObject:groups waitUntilDone:true];
    }];
    [getTask resume];
    [_spinner startAnimating];
    self.view.userInteractionEnabled = false;
    [self.view addSubview:_spinner];
}

-(IBAction)logout:(id)sender {
    NSUserDefaults* defaults = [NSUserDefaults standardUserDefaults];
    [defaults setObject:nil forKey:@"username"];
    [defaults setObject:[NSNumber numberWithBool:false] forKey:@"loggedIn"];
    [defaults synchronize];
    [self presentViewController:[[UIStoryboard storyboardWithName:@"Main" bundle:nil] instantiateViewControllerWithIdentifier:@"login"] animated:true completion:nil];
}

-(void) loginButtonDidLogOut:(FBSDKLoginButton *)loginButton {
    NSUserDefaults* defaults = [NSUserDefaults standardUserDefaults];
    [defaults setObject:nil forKey:@"username"];
    [defaults setObject:[NSNumber numberWithBool:false] forKey:@"loggedIn"];
    [defaults synchronize];
    [self presentViewController:[[UIStoryboard storyboardWithName:@"Main" bundle:nil] instantiateViewControllerWithIdentifier:@"login"] animated:true completion:nil];
}

-(void) loginButton:(FBSDKLoginButton *)loginButton didCompleteWithResult:(FBSDKLoginManagerLoginResult *)result error:(NSError *)error {
    
}

#pragma mark - Navigation

// In a storyboard-based application, you will often want to do a little preparation before navigation
- (void)prepareForSegue:(UIStoryboardSegue *)segue sender:(id)sender {
    // Get the new view controller using [segue destinationViewController].
    // Pass the selected object to the new view controller.
}


@end
