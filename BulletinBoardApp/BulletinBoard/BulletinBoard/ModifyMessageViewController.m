//
//  ModifyMessageViewController.m
//  BulletinBoard
//
//  Created by Daniel Scott on 4/16/16.
//  Copyright © 2016 Not Quite Human. All rights reserved.
//

#import "ModifyMessageViewController.h"
#import "YourMessagesTableViewController.h"
#import "Message.h"
#import "Constants.h"

@interface ModifyMessageViewController ()

@property (strong, nonatomic) IBOutlet UITextView* oldMessage;
@property (strong, nonatomic) IBOutlet UITextView* modMessage;


@end

@implementation ModifyMessageViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    // Do any additional setup after loading the view.
    _oldMessage.text = _message.message;
    [self.view addGestureRecognizer:[[UITapGestureRecognizer alloc] initWithTarget:self.view action:@selector(endEditing:)]];
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

-(IBAction)confirm:(id)sender {
    //NSString* modMessage = [_modMessage.text stringByAddingPercentEscapesUsingEncoding:NSUTF8StringEncoding];
    NSString* modMessage = [_modMessage.text stringByReplacingOccurrencesOfString:@" " withString:@"+"];
    NSString* urlString = [NSString stringWithFormat:@"%@messages/modifyMessage?messageId=%lld&modifiedMessage=%@", API_DOMAIN, _message.mId, modMessage];
    NSURL* url = [NSURL URLWithString:urlString];
    NSMutableURLRequest* request = [[NSMutableURLRequest alloc] initWithURL:url];
    [request setHTTPMethod:@"POST"];
    [request setValue:@"application/json" forHTTPHeaderField:@"Content-type"];
    //NSError* error;
    //NSDictionary* dict = [[NSDictionary alloc] initWithObjects:@[_modMessage.text] forKeys:@[@"modifiedMessage"]];
    //NSData* body = [NSJSONSerialization dataWithJSONObject:_modMessage.text options:0 error:&error];
    //[request setHTTPBody:body];
    NSURLSessionConfiguration* sessionConfig = [NSURLSessionConfiguration defaultSessionConfiguration];
    //sessionConfig.HTTPAdditionalHeaders = {@Authentication", @"AUTH KEY"};
    NSURLSession* conn = [NSURLSession sessionWithConfiguration:sessionConfig];
    NSURLSessionTask* postTask = [conn dataTaskWithRequest:request completionHandler:^(NSData * _Nullable data, NSURLResponse * _Nullable response, NSError * _Nullable error) {
        if ([_presenter respondsToSelector:@selector(modifyMessage:)]) {
            [_presenter performSelector:@selector(modifyMessage:) withObject:[[NSDictionary alloc] initWithObjects:@[_modMessage.text, _row] forKeys:@[@"message", @"row"]]];
        }
        [self performSelectorOnMainThread:@selector(cancel:) withObject:nil waitUntilDone:true];
    }];
    [postTask resume];
}

-(IBAction)cancel:(id)sender {
    [self dismissViewControllerAnimated:true completion:nil];
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
