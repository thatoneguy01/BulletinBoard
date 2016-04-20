//
//  ScanViewController.m
//  BulletinBoard
//
//  Created by Daniel Scott on 2/26/16.
//  Copyright © 2016 Not Quite Human. All rights reserved.
//

#import "ScanViewController.h"
#import "Message.h"
#import "Reply.h"
#import "MessageListTableViewController.h"
#import "MessageMapViewController.h"
#import "MessageTableViewCell.h"
#import "Constants.h"
#import "MessageMarker.h"
#import "ReplyViewController.h"

@interface ScanViewController ()

@property (strong, nonatomic) IBOutlet UISegmentedControl* modeSelector;
@property (strong, nonatomic) IBOutlet UIButton* detailsButton;
@property (strong, nonatomic) NSArray* messages;
@property (nonatomic) CLLocationCoordinate2D location;
@property (strong, nonatomic) UIActivityIndicatorView* spinner;


@end

@implementation ScanViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    // Do any additional setup after loading the view.
    //_listContainer.hidden = YES;
    _mapView.delegate = self;
    _mapView.showsUserLocation = YES;
    _tableView.hidden = true;
    _mapView.hidden = false;
    _spinner = [[UIActivityIndicatorView alloc] initWithFrame:CGRectMake(135,140,100,100)];
    _spinner.center = self.view.center;
    self.view.userInteractionEnabled = false;
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

-(void) addMarkers: (NSArray*)markers {
    [_spinner removeFromSuperview];
    self.view.userInteractionEnabled = true;
    _messages = markers;
    [_tableView reloadData];
    for (Message* m in markers) {
        MessageMarker* mm = [m toMarker];
        [_mapView addAnnotation:mm];
    }
}

-(IBAction)swapView:(id)sender {
    if (_modeSelector.selectedSegmentIndex == 1) {
        _tableView.hidden = false;
        _mapView.hidden = true;
    }
    else {
        _tableView.hidden = true;
        _mapView.hidden = false;
    }
}

-(IBAction)viewDetails:(id)sender {
    if (_mapView.selectedAnnotations == nil | _mapView.selectedAnnotations.count == 0) {}
    else {
        self.view.userInteractionEnabled = false;
        NSArray* selected = _mapView.selectedAnnotations;
        MessageMarker* mm = selected[0];
        Message* m = mm.message;
        ReplyViewController* reply = [[UIStoryboard storyboardWithName:@"Main" bundle:nil] instantiateViewControllerWithIdentifier:@"reply"];
        reply.message = m;
        NSString* urlString = [NSString stringWithFormat:@"%@replies/replies?messageId=%lld", API_DOMAIN, m.mId];
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
            NSArray* replyDicts = [responseContent objectForKey:@"items"];
            NSMutableArray* replies = [[NSMutableArray alloc] init];
            for (NSDictionary* dict in replyDicts) {
                [replies addObject:[[Reply alloc] initWithDict:dict]];
            }
            reply.replies = replies;
            [self performSelectorOnMainThread:@selector(presentReplyView:) withObject:reply waitUntilDone:true];
                    }];
        [getTask resume];
        [_spinner startAnimating];
        self.view.userInteractionEnabled = false;
        [self.view addSubview:_spinner];
    }
}

-(void)presentReplyView: (ReplyViewController*) vc {
    [_spinner removeFromSuperview];
    self.view.userInteractionEnabled = true;
    [self.navigationController pushViewController:vc animated:true];
}

-(IBAction)refresh:(id)sender {
    NSString* urlString = [NSString stringWithFormat:@"%@messages/messagesNear?username=%@&latitude=%f&longitude=%f", API_DOMAIN, [[NSUserDefaults standardUserDefaults] stringForKey:@"username"], _mapView.userLocation.coordinate.latitude, _mapView.userLocation.coordinate.longitude];
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
        NSDictionary* responceContent = [NSJSONSerialization JSONObjectWithData:data options:NSJSONReadingMutableContainers error:&jsonError];
        NSArray* messageDicts = [responceContent objectForKey:@"items"];
        NSMutableArray* messages = [[NSMutableArray alloc] init];
        for (NSDictionary* dict in messageDicts) {
            [messages addObject:[[Message alloc] initWithDict:dict]];
        }
        //_messages = [NSArray arrayWithArray:messages];
        [self performSelectorOnMainThread:@selector(addMarkers:) withObject:messages waitUntilDone:true];
    }];
    [getTask resume];
    [_spinner startAnimating];
    self.view.userInteractionEnabled = false;
    [self.view addSubview:_spinner];
}

#pragma marl - UITableViewDelegate

-(NSInteger)numberOfSectionsInTableView:(UITableView *)tableView {
    return 1;
}

-(UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath {
    MessageTableViewCell* cell = [tableView dequeueReusableCellWithIdentifier:@"mListCell"];
    if (cell == nil) {
        cell = [[MessageTableViewCell alloc] init];
    }
    cell.message = _messages[indexPath.row];
    cell.usernameLabel.text = cell.message.postingUser;
    cell.messageText.text = cell.message.message;
    return cell;
}

-(NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section {
    return self.messages.count;
}

-(void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath {
    self.view.userInteractionEnabled = false;
    Message* m = ((MessageTableViewCell*)[self tableView:tableView cellForRowAtIndexPath:indexPath]).message;
    ReplyViewController* reply = [[UIStoryboard storyboardWithName:@"Main" bundle:nil] instantiateViewControllerWithIdentifier:@"reply"];
    reply.message = m;
    NSString* urlString = [NSString stringWithFormat:@"%@replies/replies?messageId=%lld", API_DOMAIN, m.mId];
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
        NSArray* replyDicts = [responseContent objectForKey:@"items"];
        NSMutableArray* replies = [[NSMutableArray alloc] init];
        for (NSDictionary* dict in replyDicts) {
            [replies addObject:[[Reply alloc] initWithDict:dict]];
        }
        reply.replies = replies;
        [self performSelectorOnMainThread:@selector(presentReplyView:) withObject:reply waitUntilDone:true];
    }];
    [getTask resume];
    [_spinner startAnimating];
    [self.view addSubview:_spinner];
}

#pragma mark - MKMapkitDelegate

-(void)mapView:(MKMapView *)mapView didUpdateUserLocation:(MKUserLocation *)userLocation {
    self.view.userInteractionEnabled = true;
    if (_messages == nil) {
        NSString* urlString = [NSString stringWithFormat:@"%@messages/messagesNear?username=%@&latitude=%f&longitude=%f", API_DOMAIN, [[NSUserDefaults standardUserDefaults] stringForKey:@"username"], userLocation.coordinate.latitude,userLocation.coordinate.longitude];
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
            NSDictionary* responceContent = [NSJSONSerialization JSONObjectWithData:data options:NSJSONReadingMutableContainers error:&jsonError];
            NSArray* messageDicts = [responceContent objectForKey:@"items"];
            NSMutableArray* messages = [[NSMutableArray alloc] init];
            for (NSDictionary* dict in messageDicts) {
                [messages addObject:[[Message alloc] initWithDict:dict]];
            }
            //_messages = [NSArray arrayWithArray:messages];
            //[_tableView reloadData];
            [self performSelectorOnMainThread:@selector(addMarkers:) withObject:messages waitUntilDone:true];
        }];
        [getTask resume];
    }
    double latitude = userLocation.coordinate.latitude;
    float delta = fabs(200 / (111111 * cos(latitude)));
    [self.mapView setRegion:MKCoordinateRegionMake(userLocation.coordinate, MKCoordinateSpanMake(.0018f, delta)) animated:false];
}


#pragma mark - Navigation

// In a storyboard-based application, you will often want to do a little preparation before navigation
- (void)prepareForSegue:(UIStoryboardSegue *)segue sender:(id)sender {
    // Get the new view controller using [segue destinationViewController].
    // Pass the selected object to the new view controller.

}

@end
