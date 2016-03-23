//
//  LeftMenuTableViewController.m
//  TusTus
//
//  Created by User on 4/12/15.
//  Copyright (c) 2015 Philip. All rights reserved.
//

#import "LeftMenuTableViewController.h"

@interface LeftMenuTableViewController ()
@property (nonatomic, strong) NSMutableArray *arrStausTitle;
@property (nonatomic, strong) NSArray *arrStatusImageTitle;
@end

@implementation LeftMenuTableViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    
    // Uncomment the following line to preserve selection between presentations.
    // self.clearsSelectionOnViewWillAppear = NO;
    
    // Uncomment the following line to display an Edit button in the navigation bar for this view controller.
    // self.navigationItem.rightBarButtonItem = self.editButtonItem;
    
    self.arrStausTitle = [[NSMutableArray alloc] initWithArray:LocalizedSimpleArrayData(arrKeyStatusCategory)];
    self.arrStatusImageTitle = @[@"status_published", @"status_accepted", @"status_pickuped", @"status_completed", @"status_cancelled"];
    
    [[NSNotificationCenter defaultCenter] addObserver:self
                                             selector:@selector(newBookingPublished:)
                                                 name:N_NewBookingPublished
                                               object:nil];
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

- (void) onCancel:(id) sender{
    UIView *view = (UIView *)sender;
    
    NSInteger nIdx = [view.accessibilityIdentifier integerValue];
    
    UIAlertView* alert = [[UIAlertView alloc] initWithTitle:@"" message:@"Are you sure you really want to cancel this delivery booking?" delegate:self cancelButtonTitle:@"Yes" otherButtonTitles:@"No",nil];
    
    alert.tag = nIdx;
    
    [alert show];
}

- (void) newBookingPublished:(NSNotification *)notification{
    [self.tableView reloadData];
}

#pragma - mark AlertView Delegate Methods
- (void)alertView:(UIAlertView *)alertView clickedButtonAtIndex:(NSInteger)buttonIndex
{
    if(buttonIndex == 0){
        NSInteger nIdx = alertView.tag;
        
        DeliveryBookingInfo *bookingInfo = [[DataStore instance].arrCurrentBooking objectAtIndex:nIdx];
        
        [[DataStore instance].arrCurrentBooking removeObjectAtIndex:nIdx];
        
        [[NSNotificationCenter defaultCenter] postNotificationName:N_NewBookingPublished object:nil];
        
        PFQuery *query = [PFQuery queryWithClassName:pClassDelivery];
        
        [query whereKey:pKeyObjectID equalTo:bookingInfo.strObjectId];
        
        [query findObjectsInBackgroundWithBlock:^(NSArray *objects, NSError *error) {
            if(error != nil) return;
            if(objects.count == 0) return;
            
            [PFObject deleteAllInBackground:objects];
            
            NSString *strFormat = LocalizedString(@"push_cancel%@%@");
            
            NSString *strAlert = [NSString stringWithFormat:strFormat, bookingInfo.strStartPerson, bookingInfo.strEndPerson];
            
            
            NSDictionary *data = [NSDictionary dictionaryWithObjectsAndKeys:
                                  bookingInfo.strObjectId,      pnBookingID,
                                  PN_CANCEL_NEW,                pnMode,
                                  bookingInfo.strCustomerObjId, pnFromID,
                                  strAlert,                     pnAlert,
                                  nil];
            
            if (bookingInfo.nStatus == 0) {
                
                PFQuery *queryWorker = [PFQuery queryWithClassName:pClassWorkerScooter];
                
                if(bookingInfo.nCateogry == CAR_CAT)    queryWorker = [PFQuery queryWithClassName:pClassWorkerCar];
                if(bookingInfo.nCateogry == MOVING_CAT) queryWorker = [PFQuery queryWithClassName:pClassWorkerTruck];
                
                NSArray *arrWorker = [queryWorker findObjects];
                
                NSMutableArray *arrWorkerID = [[NSMutableArray alloc] init];
                
                for(PFObject *pfObj in arrWorker){
                    [arrWorkerID addObject:pfObj.objectId];
                }
                
                // Build the actual push notification target query
                PFQuery *queryInstallation = [PFInstallation query];
                
                [queryInstallation whereKey:pKeyUserID containedIn:arrWorkerID];
                
                // Send the notification.
                PFPush *push = [[PFPush alloc] init];
                
                [push setQuery:queryInstallation];
                [push setData:data];
                
                [push sendPushInBackground];
                
            }else{
                
                NSDateFormatter *dateFormatter = [[NSDateFormatter alloc] init];
                
                [dateFormatter setDateFormat:@"d LLL yyyy, HH:mm"];
                
                NSString *strCancelledDate = [dateFormatter stringFromDate:[NSDate date]];

                
                PFQuery *queryInstallation = [PFInstallation query];
                
                [queryInstallation whereKey:pKeyUserID equalTo:bookingInfo.strWorkerObjId];
                
                // Send the notification.
                PFPush *push = [[PFPush alloc] init];
                
                [push setQuery:queryInstallation];
                [push setData:data];
                
                [push sendPushInBackground];

                PFObject *cancelledObj = [PFObject objectWithClassName:pClassCanceledDelivery];
               
                cancelledObj[pKeyCustomerName]   = bookingInfo.strCustomerName;
                cancelledObj[pKeyWorkerName]     = bookingInfo.strWorkerName;
                cancelledObj[pKeyWorkerFullName] = bookingInfo.strWorkerFullName;
                cancelledObj[pKeyWorkerPhone]    = bookingInfo.strWorkerPhone;
                cancelledObj[pKeyCustomerObjId]  = bookingInfo.strCustomerObjId;
                cancelledObj[pKeyWorkerObjId]    = bookingInfo.strWorkerObjId;
                cancelledObj[pKeyStatus]         = [NSNumber numberWithInteger:bookingInfo.nStatus];
                cancelledObj[pKeyNCategory]      = [NSNumber numberWithInteger:bookingInfo.nCateogry];
                cancelledObj[pKeyStartAddress]   = bookingInfo.strStartAddress;
                cancelledObj[pKeyStartApartment] = bookingInfo.strStartApartment;
                cancelledObj[pKeyStartFloor]     = bookingInfo.strStartFloor;
                cancelledObj[pKeyStartPerson]    = bookingInfo.strStartPerson;
                cancelledObj[pKeyStartPhone]     = bookingInfo.strStartPhone;
                cancelledObj[pKeyEndAddress]     = bookingInfo.strEndAddress;
                cancelledObj[pKeyEndApartment]   = bookingInfo.strEndApartment;
                cancelledObj[pKeyEndFloor]       = bookingInfo.strEndFloor;
                cancelledObj[pKeyEndPerson]      = bookingInfo.strEndPerson;
                cancelledObj[pKeyEndPhone]       = bookingInfo.strEndPhone;
                cancelledObj[pKeyPackageType]    = [NSNumber numberWithInteger:bookingInfo.nPackageType];
                cancelledObj[pKeyUrgencyType]    = [NSNumber numberWithInteger:bookingInfo.nUrgencyType];
                cancelledObj[pKeyDoubleType]     = [NSNumber numberWithInteger:bookingInfo.nDoubleType];
                cancelledObj[pKeyAmount]         = [NSNumber numberWithInteger:bookingInfo.nAmount];
                cancelledObj[pKeyPrice]          = [NSNumber numberWithInteger:bookingInfo.nPrice];
                cancelledObj[pKeyManagerOwn]     = [NSNumber numberWithInteger:bookingInfo.nManagerOwn];
                cancelledObj[pKeyWorkerOwn]      = [NSNumber numberWithInteger:bookingInfo.nWorkerOwn];
                cancelledObj[pKeyComment]        = bookingInfo.strComment;
                cancelledObj[pKeyPublishedDate]  = bookingInfo.strPublishedDate;
                cancelledObj[pKeyAcceptedDate]   = bookingInfo.strAcceptedDate;
                cancelledObj[pKeyPickupedDate]   = bookingInfo.strPickupedDate;
                cancelledObj[pKeyCanceledDate]   = strCancelledDate;
                cancelledObj[pKeyPurchasedDate]  = @"";

                [cancelledObj saveInBackground];
            }
            
            [self.tableView reloadData];
            
        }];
    }
}


#pragma mark - Table view data source
- (CGFloat)tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath{
    CGFloat height = 0;
    
    if(indexPath.row == 0){
        height = 45;
    }else{
        DeliveryBookingInfo *bookingInfo = [[DataStore instance].arrCurrentBooking objectAtIndex:indexPath.row - 1];
        
        if([bookingInfo.strStartPhone isEqualToString:g_myInfo.strPhoneNumber]){
            if(bookingInfo.nStatus == 0 || bookingInfo.nStatus == 1){
                height = 230; // cell_left_from_me_cancel
            }else{
                height = 190; // cell_left_from_me
            }
        }else if([bookingInfo.strEndPhone isEqualToString:g_myInfo.strPhoneNumber]){
            if(bookingInfo.nStatus == 0 || bookingInfo.nStatus == 1){
                height = 220; // cell_left_to_me_cancel
            }else{
                height = 190; // cell_left_to_me
            }
        }else{
            if(bookingInfo.nStatus == 0 || bookingInfo.nStatus == 1){
                height = 320; // cell_left_general_cancel
            }else{
                height = 280; // cell_left_general
            }
        }
    }
    
    return  height;
}

- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView {
    // Return the number of sections.
    return 1;
}

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section {
    // Return the number of rows in the section.
    return [DataStore instance].arrCurrentBooking.count + 1;
}


- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath {
    UITableViewCell *cell = [[UITableViewCell alloc] init];
    
    if(indexPath.row == 0){
        cell = [tableView dequeueReusableCellWithIdentifier:CELL_NUMBER_DELIVERY forIndexPath:indexPath];
        
        UILabel *lblTitle = (UILabel *)[cell.contentView viewWithTag:1];
        UILabel *lblNumber = (UILabel *)[cell.contentView viewWithTag:2];
        
        lblNumber.text = @([DataStore instance].arrCurrentBooking.count).stringValue;
        
    }else{
        DeliveryBookingInfo *bookingInfo = [[DataStore instance].arrCurrentBooking objectAtIndex:indexPath.row - 1];
        
        NSInteger nStatus = bookingInfo.nStatus;
        
        if(nStatus == -2) nStatus = 4;
        
        if(nStatus < 0 || nStatus > 4) return cell;
        
        if([bookingInfo.strStartPhone isEqualToString:g_myInfo.strPhoneNumber]){
            if(bookingInfo.nStatus == 0 || bookingInfo.nStatus == 1){
                cell = [tableView dequeueReusableCellWithIdentifier:CELL_LEFT_FROM_ME_CANCEL forIndexPath:indexPath];
                
                UIButton *btnCancel   = (UIButton *)[cell.contentView viewWithTag:7];
                
                btnCancel.accessibilityIdentifier = @(indexPath.row -1).stringValue;
                
                [btnCancel   addTarget:self action:@selector(onCancel:) forControlEvents:UIControlEventTouchUpInside];
                
            }else{
                cell = [tableView dequeueReusableCellWithIdentifier:CELL_LEFT_FROM_ME forIndexPath:indexPath];
            }
            
            UILabel *lblFromMe    = (UILabel *)[cell.contentView viewWithTag:1];
            UILabel *lblToPerson  = (UILabel *)[cell.contentView viewWithTag:2];
            UILabel *lblToAddress = (UILabel *)[cell.contentView viewWithTag:3];
            UILabel *lblToOther     = (UILabel *)[cell.contentView viewWithTag:4];
            UIImageView *imgvStatus = (UIImageView *)[cell.contentView viewWithTag:5];
            UILabel *lblStatus    = (UILabel *)[cell.contentView viewWithTag:6];
            
            lblToPerson.text  = [NSString stringWithFormat:@"Delivery: %@", bookingInfo.strEndPerson];
            lblToAddress.text = [NSString stringWithFormat:@"%@-%@", LocalizedString(@"hint_address"), bookingInfo.strEndAddress];
            lblToOther.text   = [NSString stringWithFormat:@"%@-%@, %@-%@", LocalizedString(@"hint_floor"), bookingInfo.strEndFloor, LocalizedString(@"hint_apartment"), bookingInfo.strEndApartment];
            imgvStatus.image  = [UIImage imageNamed:[self.arrStatusImageTitle objectAtIndex:nStatus]];
            lblStatus.text    = [self.arrStausTitle objectAtIndex:nStatus];
            
        }else if([bookingInfo.strEndPhone isEqualToString:g_myInfo.strPhoneNumber]){
            if(bookingInfo.nStatus == 0 || bookingInfo.nStatus == 1){
                cell = [tableView dequeueReusableCellWithIdentifier:CELL_LEFT_TO_ME_CANCEL forIndexPath:indexPath];
                
                UIButton *btnCancel     = (UIButton *)[cell.contentView viewWithTag:7];
                
                btnCancel.accessibilityIdentifier = @(indexPath.row -1).stringValue;
                
                [btnCancel   addTarget:self action:@selector(onCancel:) forControlEvents:UIControlEventTouchUpInside];
                
            }else{
                cell = [tableView dequeueReusableCellWithIdentifier:CELL_LEFT_TO_ME forIndexPath:indexPath];
            }
            
            UILabel *lblFromPerson  = (UILabel *)[cell.contentView viewWithTag:1];
            UILabel *lblFromAddress = (UILabel *)[cell.contentView viewWithTag:2];
            UILabel *lblFromOther   = (UILabel *)[cell.contentView viewWithTag:3];
            UILabel *lblToMe        = (UILabel *)[cell.contentView viewWithTag:4];
            UIImageView *imgvStatus = (UIImageView *)[cell.contentView viewWithTag:5];
            UILabel *lblStatus      = (UILabel *)[cell.contentView viewWithTag:6];
            
            lblFromPerson.text  = [NSString stringWithFormat:@"Pick up: %@", bookingInfo.strStartPerson];
            lblFromAddress.text = [NSString stringWithFormat:@"%@-%@", LocalizedString(@"hint_address"), bookingInfo.strStartAddress];
            lblFromOther.text   = [NSString stringWithFormat:@"%@-%@, %@-%@", LocalizedString(@"hint_floor"), bookingInfo.strStartFloor, LocalizedString(@"hint_apartment"), bookingInfo.strStartApartment];
            imgvStatus.image  = [UIImage imageNamed:[self.arrStatusImageTitle objectAtIndex:nStatus]];
            lblStatus.text    = [self.arrStausTitle objectAtIndex:nStatus];
            
        }else{
            if(bookingInfo.nStatus == 0 || bookingInfo.nStatus == 1){
                cell = [tableView dequeueReusableCellWithIdentifier:CELL_LEFT_GENERAL_CANCEL forIndexPath:indexPath];
                
                UIButton *btnCancel     = (UIButton *)[cell.contentView viewWithTag:9];
                
                btnCancel.accessibilityIdentifier = @(indexPath.row -1).stringValue;
                
                [btnCancel   addTarget:self action:@selector(onCancel:) forControlEvents:UIControlEventTouchUpInside];
                
            }else{
                cell = [tableView dequeueReusableCellWithIdentifier:CELL_LEFT_GENERAL forIndexPath:indexPath];
            }
            
            UILabel *lblFromPerson  = (UILabel *)[cell.contentView viewWithTag:1];
            UILabel *lblFromAddress = (UILabel *)[cell.contentView viewWithTag:2];
            UILabel *lblFromOther   = (UILabel *)[cell.contentView viewWithTag:3];
            UILabel *lblToPerson    = (UILabel *)[cell.contentView viewWithTag:4];
            UILabel *lblToAddress   = (UILabel *)[cell.contentView viewWithTag:5];
            UILabel *lblToOther     = (UILabel *)[cell.contentView viewWithTag:6];
            UIImageView *imgvStatus = (UIImageView *)[cell.contentView viewWithTag:7];
            UILabel *lblStatus      = (UILabel *)[cell.contentView viewWithTag:8];
            
            lblFromPerson.text  = [NSString stringWithFormat:@"Pick up: %@", bookingInfo.strStartPerson];
            lblFromAddress.text = [NSString stringWithFormat:@"%@-%@", LocalizedString(@"hint_address"), bookingInfo.strStartAddress];
            lblFromOther.text   = [NSString stringWithFormat:@"%@-%@, %@-%@", LocalizedString(@"hint_floor"), bookingInfo.strStartFloor, LocalizedString(@"hint_apartment"), bookingInfo.strStartApartment];
            lblToPerson.text  = [NSString stringWithFormat:@"Delivery: %@", bookingInfo.strEndPerson];
            lblToAddress.text = [NSString stringWithFormat:@"%@-%@", LocalizedString(@"hint_address"), bookingInfo.strEndAddress];
            lblToOther.text   = [NSString stringWithFormat:@"%@-%@, %@-%@", LocalizedString(@"hint_floor"), bookingInfo.strEndFloor, LocalizedString(@"hint_apartment"), bookingInfo.strEndApartment];
            imgvStatus.image  = [UIImage imageNamed:[self.arrStatusImageTitle objectAtIndex:nStatus]];
            lblStatus.text    = [self.arrStausTitle objectAtIndex:nStatus];

        }
    }
    
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
