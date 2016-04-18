//
//  YourGroupsTableViewController.m
//  BulletinBoard
//
//  Created by Daniel Scott on 4/16/16.
//  Copyright © 2016 Not Quite Human. All rights reserved.
//

#import "YourGroupsTableViewController.h"
#import "YourGroupsTableViewCell.h"
#import "Constants.h"

@interface YourGroupsTableViewController ()

@end

@implementation YourGroupsTableViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    
    // Uncomment the following line to preserve selection between presentations.
    // self.clearsSelectionOnViewWillAppear = NO;
    
    // Uncomment the following line to display an Edit button in the navigation bar for this view controller.
    // self.navigationItem.rightBarButtonItem = self.editButtonItem;
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

#pragma mark - Table view data source

- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView {
    return 1;
}

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section {
    return _groups.count;
}


- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath {
    YourGroupsTableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:@"ygCell"];
    if (cell == nil) {
        cell = [[YourGroupsTableViewCell alloc] init];
    }
    cell.group = [_groups objectAtIndex:indexPath.row];
    cell.row = [NSNumber numberWithInteger:indexPath.row];
    cell.groupName.text = cell.group.name;
    
    // Configure the cell...
    
    return cell;
}



// Override to support conditional editing of the table view.
- (BOOL)tableView:(UITableView *)tableView canEditRowAtIndexPath:(NSIndexPath *)indexPath {
    // Return NO if you do not want the specified item to be editable.
    return YES;
}



// Override to support editing the table view.
- (void)tableView:(UITableView *)tableView commitEditingStyle:(UITableViewCellEditingStyle)editingStyle forRowAtIndexPath:(NSIndexPath *)indexPath {
    if (editingStyle == UITableViewCellEditingStyleDelete) {
        // Delete the row from the data source
        Group* g = [_groups objectAtIndex:indexPath.row];
        NSMutableArray* temp = [[NSMutableArray alloc] initWithArray:_groups];
        [temp removeObject:g];
        _groups = [NSArray arrayWithArray:temp];
        NSString* urlString = [NSString stringWithFormat:@"%@groups/leaveGroup?username=%@&groupId=%lld", API_DOMAIN, [[NSUserDefaults standardUserDefaults] stringForKey:@"username"], g.groupId];
        NSURL* url = [NSURL URLWithString:urlString];
        NSMutableURLRequest* request = [[NSMutableURLRequest alloc] initWithURL:url];
        [request setHTTPMethod:@"GET"];
        [request setValue:@"application/json" forHTTPHeaderField:@"Content-type"];
        NSURLSessionConfiguration* sessionConfig = [NSURLSessionConfiguration defaultSessionConfiguration];
        //sessionConfig.HTTPAdditionalHeaders = {@Authentication", @"AUTH KEY"};
        NSURLSession* conn = [NSURLSession sessionWithConfiguration:sessionConfig];
        NSURLSessionTask* getTask = [conn dataTaskWithRequest:request completionHandler:^(NSData * _Nullable data, NSURLResponse * _Nullable response, NSError * _Nullable error) {
        }];
        [getTask resume];
        [tableView deleteRowsAtIndexPaths:@[indexPath] withRowAnimation:UITableViewRowAnimationFade];
    } else if (editingStyle == UITableViewCellEditingStyleInsert) {
        // Create a new instance of the appropriate class, insert it into the array, and add a new row to the table view
    }   
}

-(NSString*) tableView:(UITableView *)tableView titleForDeleteConfirmationButtonForRowAtIndexPath:(NSIndexPath *)indexPath {
    return @"Leave Group";
}

/*
// Override to support rearranging the table view.
- (void)tableView:(UITableView *)tableView moveRowAtIndexPath:(NSIndexPath *)fromIndexPath toIndexPath:(NSIndexPath *)toIndexPath {
}
*/

/*
// Override to support conditional rearranging of the table view.
- (BOOL)tableView:(UITableView *)tableView canMoveRowAtIndexPath:(NSIndexPath *)indexPath {
    // Return NO if you do not want the item to be re-orderable.
    return YES;
}
*/

/*
#pragma mark - Navigation

// In a storyboard-based application, you will often want to do a little preparation before navigation
- (void)prepareForSegue:(UIStoryboardSegue *)segue sender:(id)sender {
    // Get the new view controller using [segue destinationViewController].
    // Pass the selected object to the new view controller.
}
*/

@end
