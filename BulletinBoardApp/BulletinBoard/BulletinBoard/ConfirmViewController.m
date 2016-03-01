//
//  ConfirmViewController.m
//  BulletinBoard
//
//  Created by Daniel Scott on 2/25/16.
//  Copyright © 2016 Not Quite Human. All rights reserved.
//

#import "ConfirmViewController.h"

@interface ConfirmViewController ()

@property (strong, nonatomic) IBOutlet MKMapView* locationMap;
@property (strong, nonatomic) IBOutlet UIButton* confrimButton;

@end

@implementation ConfirmViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    _locationMap.showsUserLocation = YES;
    MKUserLocation *userLocation = _locationMap.userLocation;
    MKCoordinateRegion region =
    MKCoordinateRegionMakeWithDistance (
                                        userLocation.location.coordinate, 2000, 2000);
    [_locationMap setRegion:region animated:NO];
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

-(IBAction)postMessage:(id)sender {
    MKUserLocation* currentLoc = [_locationMap userLocation];
    NSString* lat = [NSString stringWithFormat:@"%f", currentLoc.location.coordinate.latitude];
    NSString* lon = [NSString stringWithFormat:@"%f", currentLoc.location.coordinate.longitude];
    _message.location = [NSString stringWithFormat:@"%@, %@", lat, lon];
    NSURL* url = [NSURL URLWithString:@"POST MESSAGE API PATH GOES HERE"];
    NSMutableURLRequest* request = [[NSMutableURLRequest alloc] initWithURL:url];
    [request setHTTPMethod:@"POST"];
    [request setValue:@"application/json" forHTTPHeaderField:@"Content-type"];
    NSError* error;
    NSData* body = [NSJSONSerialization dataWithJSONObject:[_message toDict] options:0 error:&error];
    [request setHTTPBody:body];
    NSURLSessionConfiguration* sessionConfig = [NSURLSessionConfiguration defaultSessionConfiguration];
    //sessionConfig.HTTPAdditionalHeaders = {@Authentication", @"AUTH KEY"};
    NSURLSession* conn = [NSURLSession sessionWithConfiguration:sessionConfig];
    NSURLSessionTask* postTask = [conn dataTaskWithRequest:request completionHandler:^(NSData * _Nullable data, NSURLResponse * _Nullable response, NSError * _Nullable error) {
        //NO-OP
    }];
    [postTask resume];
    [self dismissViewControllerAnimated:YES completion:nil];
}

#pragma mark - Navigation

// In a storyboard-based application, you will often want to do a little preparation before navigation
- (void)prepareForSegue:(UIStoryboardSegue *)segue sender:(id)sender {
    // Get the new view controller using [segue destinationViewController].
    // Pass the selected object to the new view controller.
}

-(IBAction)cancel:(id)sender {
    [self dismissViewControllerAnimated:YES completion:nil];
}

@end
