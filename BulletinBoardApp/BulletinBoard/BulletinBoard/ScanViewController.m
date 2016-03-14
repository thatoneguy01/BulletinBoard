//
//  ScanViewController.m
//  BulletinBoard
//
//  Created by Daniel Scott on 2/26/16.
//  Copyright © 2016 Not Quite Human. All rights reserved.
//

#import "ScanViewController.h"
#import "Message.h"
#import "MessageListTableViewController.h"
#import "MessageMapViewController.h"

@interface ScanViewController ()

@property (strong, nonatomic) IBOutlet UISegmentedControl* modeSelector;
@property (strong, nonatomic) IBOutlet UIView* mapContainer;
@property (strong, nonatomic) IBOutlet UIView* listContainer;
@property (strong, nonatomic) NSMutableArray* messages;

@end

@implementation ScanViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    // Do any additional setup after loading the view.
    _listContainer.hidden = YES;
    NSURL* url = [NSURL URLWithString:@"MESSAGE LIST URL"];
    NSMutableURLRequest* request = [[NSMutableURLRequest alloc] initWithURL:url];
    [request setHTTPMethod:@"GET"];
    [request setValue:@"application/json" forHTTPHeaderField:@"Content-type"];
    NSURLSessionConfiguration* sessionConfig = [NSURLSessionConfiguration defaultSessionConfiguration];
    //sessionConfig.HTTPAdditionalHeaders = {@Authentication", @"AUTH KEY"};
    NSURLSession* conn = [NSURLSession sessionWithConfiguration:sessionConfig];
    NSURLSessionTask* getTask = [conn dataTaskWithRequest:request completionHandler:^(NSData * _Nullable data, NSURLResponse * _Nullable response, NSError * _Nullable error) {
        //process responce
        NSError* jsonError;
        NSDictionary* messages = [NSJSONSerialization JSONObjectWithData:data options:NSJSONReadingMutableContainers error:&jsonError];
        _messages = [messages objectForKey:@"objects"];
    }];
    [getTask resume];
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

-(IBAction)swapView:(id)sender {
    if (_listContainer.hidden == YES) {
        _listContainer.hidden = NO;
        _mapContainer.hidden = YES;
    }
    else {
        _listContainer.hidden = YES;
        _listContainer.hidden = NO;
    }
}

#pragma mark - Navigation

// In a storyboard-based application, you will often want to do a little preparation before navigation
- (void)prepareForSegue:(UIStoryboardSegue *)segue sender:(id)sender {
    // Get the new view controller using [segue destinationViewController].
    // Pass the selected object to the new view controller.
    NSString* identifier = segue.identifier;
    if ([identifier isEqualToString:@"mList"]) {
        MessageListTableViewController* listView = segue.destinationViewController;
        listView.messages = _messages;
    }
    else if ([identifier isEqualToString:@"mMap"]) {
        MessageMapViewController* mapView = segue.destinationViewController;
        mapView.messages = _messages;
    }
}

@end
