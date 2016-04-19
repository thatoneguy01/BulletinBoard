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
#import "MessageTableViewCell.h"
#import "Constants.h"

@interface ScanViewController ()

@property (strong, nonatomic) IBOutlet UISegmentedControl* modeSelector;
@property (strong, nonatomic) IBOutlet UIButton* detailsButton;
@property (strong, nonatomic) NSArray* messages;

@end

@implementation ScanViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    // Do any additional setup after loading the view.
    //_listContainer.hidden = YES;
    _mapView.delegate = self;
    _mapView.showsUserLocation = YES;
    CLLocationCoordinate2D coord = _mapView.userLocation.coordinate;
    _tableView.hidden = true;
    _mapView.hidden = false;
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

-(void) addMarkers: (NSArray*)markers {
    for (Message* m in markers) {
        [_mapView addAnnotation:[m toMarker]];
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
    NSArray* selected = _mapView.selectedAnnotations;
    MessageMarker* mm = selected[0];
    
}

-(IBAction)refresh:(id)sender {
    NSString* urlString = [NSString stringWithFormat:@"%@messages/messaesNear?username=%@&latitude=%d&longitude=%d", API_DOMAIN, [[NSUserDefaults standardUserDefaults] stringForKey:@"username"], 0,0];
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
        _messages = [NSArray arrayWithArray:messages];
        [self performSelectorOnMainThread:@selector(addMarkers:) withObject:_messages waitUntilDone:true];

    }];
    [getTask resume];
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
    
}

#pragma mark - MKMapkitDelegate

-(void)mapView:(MKMapView *)mapView didUpdateUserLocation:(MKUserLocation *)userLocation {
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
            _messages = [NSArray arrayWithArray:messages];
            [self performSelectorOnMainThread:@selector(addMarkers:) withObject:_messages waitUntilDone:true];
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
