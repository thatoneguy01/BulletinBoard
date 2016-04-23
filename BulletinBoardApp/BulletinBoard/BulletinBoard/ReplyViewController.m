//
//  ReplyViewController.m
//  BulletinBoard
//
//  Created by Daniel Scott on 3/12/16.
//  Copyright © 2016 Not Quite Human. All rights reserved.
//

#import "ReplyViewController.h"
#import "Reply.h"
#import "Message.h"
#import "ReplyTableViewCell.h"
#import "Constants.h"

@interface ReplyViewController ()

@property (strong, nonatomic) UIActivityIndicatorView* spinner;

@end

@implementation ReplyViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    _usernameLabel.text = _message.postingUser;
    _scoreLabel.text = [NSString stringWithFormat:@"%d", _message.score];
    _messageText.text = _message.message;
    _replyTextArea.delegate = self;
    _spinner = [[UIActivityIndicatorView alloc] initWithFrame:CGRectMake(135,140,100,100)];
    _spinner.center = self.view.center;
    [self.view addGestureRecognizer:[[UITapGestureRecognizer alloc] initWithTarget:self.view action:@selector(endEditing:)]];
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

#pragma mark - IBActions

-(IBAction)voteUp:(id)sender {
    int score = [_scoreLabel.text intValue];
    score = score + 1;
    _scoreLabel.text = [NSString stringWithFormat:@"%d", score];
    NSString* urlString = [NSString stringWithFormat:@"%@messages/score?messageId=%lld&scoreMod=1", API_DOMAIN, _message.mId];
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
        NSDictionary* responseContent = [NSJSONSerialization JSONObjectWithData:data options:NSJSONReadingMutableContainers error:&jsonError];
    }];
    [getTask resume];
}

-(IBAction)voteDown:(id)sender {
    int score = [_scoreLabel.text intValue];
    score = score - 1;
    _scoreLabel.text = [NSString stringWithFormat:@"%d", score];
    NSString* urlString = [NSString stringWithFormat:@"%@messages/score?messageId=%lld&scoreMod=-1", API_DOMAIN, _message.mId];
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
        NSDictionary* responseContent = [NSJSONSerialization JSONObjectWithData:data options:NSJSONReadingMutableContainers error:&jsonError];
    }];
    [getTask resume];
}

-(IBAction)reply:(id)sender {
    self.view.userInteractionEnabled = false;
    Reply* r = [[Reply alloc] init];
    r.postingUser = [[NSUserDefaults standardUserDefaults] stringForKey:@"username"];
    r.message = _replyTextArea.text;
    r.parentId = _message.mId;
    r.timePosted = [[NSDate alloc] init];
    NSString* urlString = [NSString stringWithFormat:@"%@replies/createReply", API_DOMAIN];
    NSURL* url = [NSURL URLWithString:urlString];
    NSMutableURLRequest* request = [[NSMutableURLRequest alloc] initWithURL:url];
    [request setHTTPMethod:@"POST"];
    [request setValue:@"application/json" forHTTPHeaderField:@"Content-type"];
    NSError* error;
    [request setHTTPBody:[NSJSONSerialization dataWithJSONObject:[r toDict] options:0 error:&error]];
    NSURLSessionConfiguration* sessionConfig = [NSURLSessionConfiguration defaultSessionConfiguration];
    //sessionConfig.HTTPAdditionalHeaders = {@Authentication", @"AUTH KEY"};
    NSURLSession* conn = [NSURLSession sessionWithConfiguration:sessionConfig];
    NSURLSessionTask* getTask = [conn dataTaskWithRequest:request completionHandler:^(NSData * _Nullable data, NSURLResponse * _Nullable response, NSError * _Nullable error) {
        //process response
        NSError* jsonError;
        NSDictionary* responseContent = [NSJSONSerialization JSONObjectWithData:data options:NSJSONReadingMutableContainers error:&jsonError];
        NSMutableArray* temp = [NSMutableArray arrayWithArray:_replies];
        [temp addObject:r];
        _replies = [NSArray arrayWithArray:temp];
        [self performSelectorOnMainThread:@selector(done) withObject:nil waitUntilDone:true];
    }];
    [getTask resume];

}

-(void)done {
    [_spinner removeFromSuperview];
    self.view.userInteractionEnabled = true;
    [_tableView reloadData];
    UIAlertController* alert = [UIAlertController alertControllerWithTitle:@"Reply posted!" message:nil preferredStyle:UIAlertControllerStyleAlert];
    [alert addAction:[UIAlertAction actionWithTitle:@"OK" style:UIAlertActionStyleDefault handler:nil]];
    [self presentViewController:alert animated:true completion:nil];
}

-(void)textViewDidBeginEditing:(UITextView *)textView {
    if ([_replyTextArea.text isEqualToString:@"Enter reply here."]) {
        _replyTextArea.text = @"";
        _replyTextArea.textColor = [UIColor blackColor];
    }
}

#pragma mark - UITableViewDelegate

-(NSInteger)numberOfSectionsInTableView:(UITableView *)tableView {
    return 1;
}

-(NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section {
    return _replies.count;
}

-(UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath {
    ReplyTableViewCell* cell = [tableView dequeueReusableCellWithIdentifier:@"rCell"];
    if (cell == nil)
        cell = [[ReplyTableViewCell alloc] init];
    cell.reply = _replies[indexPath.row];
    cell.usernameLabel.text = cell.reply.postingUser;
    cell.replyText.text = cell.reply.message;
    if (indexPath.row % 2 == 0)
        cell.contentView.backgroundColor = [UIColor lightGrayColor];
    NSDateFormatter* formater = [[NSDateFormatter alloc] init];
    [formater setDateFormat:@"MM/dd/yy"];
    cell.postedDate.text = [formater stringFromDate:cell.reply.timePosted];
    return cell;
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
