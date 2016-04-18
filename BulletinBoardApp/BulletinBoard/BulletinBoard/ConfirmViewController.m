//
//  ConfirmViewController.m
//  BulletinBoard
//
//  Created by Daniel Scott on 2/25/16.
//  Copyright © 2016 Not Quite Human. All rights reserved.
//

#import "ConfirmViewController.h"
#import "Constants.h"
#import "PostViewController.h"
@import CoreLocation;

@interface ConfirmViewController ()

@property (strong, nonatomic) IBOutlet MKMapView* locationMap;
@property (strong, nonatomic) IBOutlet UIButton* confrimButton;
@property (strong, nonatomic) UIActivityIndicatorView* spinner;

@end

@implementation ConfirmViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    _locationMap.delegate = self;
    _locationMap.showsUserLocation = YES;
    double latitude = _locationMap.userLocation.coordinate.latitude;
    float delta = fabs(200 / (111111 * cos(latitude)));
    [self.locationMap setRegion:MKCoordinateRegionMake(_locationMap.userLocation.coordinate, MKCoordinateSpanMake(.0018f, delta)) animated:false];
    _spinner = [[UIActivityIndicatorView alloc] initWithFrame:CGRectMake(135,140,100,100)];
    _spinner.center = self.view.center;
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

-(void)dismiss {
    [_spinner removeFromSuperview];
    self.view.userInteractionEnabled = true;
    _messageBox.text = @"";
    [self dismissViewControllerAnimated:YES completion:nil];
}

-(void)fail {
    [_spinner removeFromSuperview];
    self.view.userInteractionEnabled = true;
    UIAlertController* alert = [UIAlertController alertControllerWithTitle:@"Failed to create message" message:@"Please try again." preferredStyle:UIAlertControllerStyleAlert];
    UIAlertAction* defaultAction = [UIAlertAction actionWithTitle:@"OK" style:UIAlertActionStyleDefault handler:nil];
    [alert addAction:defaultAction];
    [self presentViewController:alert animated:YES completion:nil];
}

-(IBAction)postMessage:(id)sender {
    MKUserLocation* currentLoc = [_locationMap userLocation];
    NSString* lat = [NSString stringWithFormat:@"%f", currentLoc.location.coordinate.latitude];
    NSString* lon = [NSString stringWithFormat:@"%f", currentLoc.location.coordinate.longitude];
    _message.lat = [[NSNumber alloc] initWithDouble:[lat doubleValue]];
    _message.lon = [[NSNumber alloc] initWithDouble:[lon doubleValue]];
    //_message.location = CLLocationCoordinate2DMake([_message.lat floatValue], [_message.lon floatValue]);
    NSString* urlString = [NSString stringWithFormat:@"%@messages/createMessage", API_DOMAIN];
    NSURL* url = [NSURL URLWithString:urlString];
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
        if (error) {
            [self performSelectorOnMainThread:@selector(fail) withObject:nil waitUntilDone:true];
        }
        else {
            [self performSelectorOnMainThread:@selector(dismiss) withObject:nil waitUntilDone:true];
        }
    }];
    [postTask resume];
    [_spinner startAnimating];
    self.view.userInteractionEnabled = false;
    [self.view addSubview:_spinner];
}

#pragma mark - MKMapViewDelegate

-(void)mapView:(MKMapView *)mapView didUpdateUserLocation:(MKUserLocation *)userLocation {
    double latitude = userLocation.coordinate.latitude;
    float delta = fabs(200 / (111111 * cos(latitude)));
    [self.locationMap setRegion:MKCoordinateRegionMake(userLocation.coordinate, MKCoordinateSpanMake(.0018f, delta)) animated:false];
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
