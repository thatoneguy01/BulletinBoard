//
//  NewGroupViewController.m
//  BulletinBoard
//
//  Created by Daniel Scott on 4/16/16.
//  Copyright © 2016 Not Quite Human. All rights reserved.
//

#import "NewGroupViewController.h"
#import "Constants.h"

@interface NewGroupViewController ()

@property (strong, nonatomic) IBOutlet UITextField* groupName;
@property (strong, nonatomic) IBOutlet UITextView* members;

@end

@implementation NewGroupViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    // Do any additional setup after loading the view.
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

-(void)failedSubmit {
    UIAlertController* alert = [UIAlertController alertControllerWithTitle:@"Failed to create group" message:@"Please try again." preferredStyle:UIAlertControllerStyleAlert];
    UIAlertAction* defaultAction = [UIAlertAction actionWithTitle:@"OK" style:UIAlertActionStyleDefault handler:nil];
    [alert addAction:defaultAction];
    [self presentViewController:alert animated:YES completion:nil];
}

-(IBAction)create:(id)sender {
    NSString* groupName = _groupName.text;
    NSString* memberString = _members.text;
    NSArray *members = [memberString componentsSeparatedByCharactersInSet:[NSCharacterSet whitespaceCharacterSet]];
    members = [members filteredArrayUsingPredicate:[NSPredicate predicateWithFormat:@"SELF != ''"]];
    NSString* urlString = [NSString stringWithFormat:@"%@groups/createGroup?name=%@", API_DOMAIN, groupName];
    NSURL* url = [NSURL URLWithString:urlString];
    NSMutableURLRequest* request = [[NSMutableURLRequest alloc] initWithURL:url];
    [request setHTTPMethod:@"POST"];
    [request setValue:@"application/json" forHTTPHeaderField:@"Content-type"];
    NSMutableDictionary* temp = [[NSMutableDictionary alloc] init];
    [temp setObject:members forKey:@"memberNames"];
    NSError* error;
    NSData* body = [NSJSONSerialization dataWithJSONObject:[NSDictionary dictionaryWithDictionary:temp] options:0 error:&error];
    [request setHTTPBody:body];
    NSURLSessionConfiguration* sessionConfig = [NSURLSessionConfiguration defaultSessionConfiguration];
    //sessionConfig.HTTPAdditionalHeaders = {@Authentication", @"AUTH KEY"};
    NSURLSession* conn = [NSURLSession sessionWithConfiguration:sessionConfig];
    NSURLSessionTask* getTask = [conn dataTaskWithRequest:request completionHandler:^(NSData * _Nullable data, NSURLResponse * _Nullable response, NSError * _Nullable error) {
        NSError* jsonError;
        NSDictionary* responseContent = [NSJSONSerialization JSONObjectWithData:data options:0 error:&jsonError];
        NSNumber* ack = [responseContent objectForKey:@"succeeded"];
        if ([ack boolValue]) {
            [self.navigationController popViewControllerAnimated:true];
        }
        else {
            [self performSelectorOnMainThread:@selector(failedSubmit) withObject:nil waitUntilDone:true];
        }
    }];
    [getTask resume];

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
