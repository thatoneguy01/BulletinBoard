//
//  YourMessagesTableViewController.m
//  BulletinBoard
//
//  Created by Daniel Scott on 4/16/16.
//  Copyright © 2016 Not Quite Human. All rights reserved.
//

#import "YourMessagesTableViewController.h"
#import "YourMessagesTableViewCell.h"
#import "ModifyMessageViewController.h"
#import "Constants.h"

@interface YourMessagesTableViewController ()

@end

@implementation YourMessagesTableViewController

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
    return _messages.count;
}


- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath {
    UITableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:@"ymCell"];
    if (cell == nil) {
        cell = [[YourMessagesTableViewCell alloc] init];
    }
    YourMessagesTableViewCell* mCell = (YourMessagesTableViewCell*)cell;
    mCell.message = [_messages objectAtIndex:indexPath.row];
    mCell.messagePreview.text = mCell.message.message;
    NSDateFormatter *outputFormatter = [[NSDateFormatter alloc] init];
    [outputFormatter setDateFormat:@"yyyy/MM/dd"];
    mCell.date.text = [outputFormatter stringFromDate:mCell.message.timePosted];
    return cell;
}

- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath {
    ModifyMessageViewController* modify = [[UIStoryboard storyboardWithName:@"Main" bundle:nil] instantiateViewControllerWithIdentifier:@"modify"];
    modify.message = [_messages objectAtIndex:indexPath.row];
    modify.presenter = self;
    modify.row = [NSNumber numberWithInteger:indexPath.row];
    UIPopoverPresentationController* popper = [modify popoverPresentationController];
    modify.modalPresentationStyle = UIModalPresentationPopover;
    popper.sourceView = self.view;
    popper.sourceRect = CGRectMake(30, 50, 200, 400);
    [self presentViewController:modify animated:true completion:nil];
}

-(void)modifyMessage: (NSDictionary*) info{
    NSLog(@"modifyMessage Called");
    Message* m = [_messages objectAtIndex:[[info objectForKey:@"row"] integerValue]];
    m.message = [info objectForKey:@"message"];
    //[NSIndexPath indexPathForRow:[info objectForKey:@"row"] integerValue] inSection:1]
    YourMessagesTableViewCell* mCell = (YourMessagesTableViewCell*)[self tableView:self.tableView cellForRowAtIndexPath:[NSIndexPath indexPathForRow:[[info objectForKey:@"row"] integerValue] inSection:1]];
    mCell.messagePreview.text = [info objectForKey:@"message"];
    [self.tableView reloadData];
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
        Message* m = [_messages objectAtIndex:indexPath.row];
        NSMutableArray* temp = [[NSMutableArray alloc] initWithArray:_messages];
        [temp removeObject:m];
        _messages = [NSArray arrayWithArray:temp];
        NSString* urlString = [NSString stringWithFormat:@"%@messages/deleteMessage?messageId=%lld", API_DOMAIN, [m mId]];
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
