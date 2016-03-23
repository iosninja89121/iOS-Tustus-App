//
//  HistoryViewController.m
//  TusTus
//
//  Created by User on 4/25/15.
//  Copyright (c) 2015 Philip. All rights reserved.
//

#import "HistoryViewController.h"

@interface HistoryViewController ()
@property (weak, nonatomic) IBOutlet UITableView *tblHistory;

@end

@implementation HistoryViewController
- (IBAction)onLeftMenu:(id)sender {
    [self.menuContainerViewController toggleLeftSideMenuCompletion:nil];
}
- (IBAction)onRightMenu:(id)sender {
    [self.menuContainerViewController toggleRightSideMenuCompletion:nil];
}

- (void)viewDidLoad {
    [super viewDidLoad];
    // Do any additional setup after loading the view.
    self.tblHistory.delegate = self;
    self.tblHistory.dataSource = self;
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

#pragma mark - Table view data source

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section
{
    // Check to see whether the normal table or search results table is being displayed and return the count from the appropriate array
    return [DataStore instance].arrCompletedBooking.count;
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath
{
    UITableViewCell *cell = [self.tblHistory dequeueReusableCellWithIdentifier:CELL_HISTORY];
    DeliveryBookingInfo *bookingInfo = [[DataStore instance].arrCompletedBooking objectAtIndex:indexPath.row];
    
    //    UITableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:CELL_CONTACT];
    UILabel *lblPickupAddress   = (UILabel *)[cell.contentView viewWithTag:1];
    UILabel *lblDeliveryAddress = (UILabel *)[cell.contentView viewWithTag:2];
    UILabel *lblCreatedDate     = (UILabel *)[cell.contentView viewWithTag:3];
    UILabel *lblCompletedDate   = (UILabel *)[cell.contentView viewWithTag:4];
    
    lblPickupAddress.text   = [NSString stringWithFormat:@"pickup Address: %@", bookingInfo.strStartAddress];
    lblDeliveryAddress.text = [NSString stringWithFormat:@"delivery Address: %@", bookingInfo.strEndAddress];
    lblCreatedDate.text     = [NSString stringWithFormat:@"Created date: %@", bookingInfo.strPublishedDate];
    lblCompletedDate.text   = [NSString stringWithFormat:@"Completed date: %@", bookingInfo.strCompletedDate];
    
    return cell;
}

-(CGFloat)tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath{
    
    return 110;
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
