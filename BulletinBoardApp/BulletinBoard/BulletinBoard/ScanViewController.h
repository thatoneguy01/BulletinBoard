//
//  ScanViewController.h
//  BulletinBoard
//
//  Created by Daniel Scott on 2/26/16.
//  Copyright © 2016 Not Quite Human. All rights reserved.
//

#import <UIKit/UIKit.h>
#import <MapKit/MapKit.h>

@interface ScanViewController : UIViewController <MKMapViewDelegate, UITableViewDelegate, UITableViewDataSource>

@property (strong, nonatomic) IBOutlet MKMapView* mapView;
@property (strong, nonatomic) IBOutlet UITableView* tableView;

@end
