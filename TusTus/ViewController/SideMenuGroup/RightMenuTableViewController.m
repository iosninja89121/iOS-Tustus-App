//
//  RightMenuTableViewController.m
//  TusTus
//
//  Created by User on 4/12/15.
//  Copyright (c) 2015 Philip. All rights reserved.
//

#import "RightMenuTableViewController.h"
#import "MainNavigationController.h"
#import <SVProgressHUD.h>

@interface RightMenuTableViewController ()
@property (nonatomic) NSArray *arrMenuTitle;
@end

@implementation RightMenuTableViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    
    // Uncomment the following line to preserve selection between presentations.
    // self.clearsSelectionOnViewWillAppear = NO;
    
    // Uncomment the following line to display an Edit button in the navigation bar for this view controller.
    // self.navigationItem.rightBarButtonItem = self.editButtonItem;
    
    NSString *strBooking = LocalizedString(@"menu_booking");
    NSString *strHistory = LocalizedString(@"menu_history");
    NSString *strProfile = LocalizedString(@"menu_my_profile");
    NSString *strContact = LocalizedString(@"menu_contacts");
    NSString *strShare   = LocalizedString(@"menu_share");
    NSString *strCallUs  = LocalizedString(@"menu_call_us");
    NSString *strSetting = LocalizedString(@"menu_setting");
    NSString *strLogout  = LocalizedString(@"menu_Logout");
    
    self.arrMenuTitle = @[@"", strBooking, strHistory, strProfile, strContact, strShare, strCallUs, strSetting, strLogout];
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

#pragma mark - Table view data source
- (CGFloat)tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath{
    if(indexPath.row == 0) return 65.f;
    return 55.f;
}

- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView {
    // Return the number of sections.
    return 1;
}

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section {
    // Return the number of rows in the section.
    return 9;
}


- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath {
    if(indexPath.row == 0){
        UITableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:CELL_PROFILE forIndexPath:indexPath];
        PFUser *user = [PFUser currentUser];
        
        // Configure the cell...
        UILabel     *lblFullName = (UILabel *)[cell.contentView viewWithTag:1];
        UILabel     *lblPhone    = (UILabel *)[cell.contentView viewWithTag:2];
        
        lblFullName.text = user[pKeyFullName];
        lblPhone.text    = user.username;
        
        return cell;
    }
    
    UITableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:CELL_RIGHT_MENU forIndexPath:indexPath];
    
    NSString *strImageName = [NSString stringWithFormat:@"ic_right%ld.png", (long)indexPath.row];
    
    UIImageView *imgViewMenu  = (UIImageView *)[cell.contentView viewWithTag:1];
    UILabel     *lblMenuTitle = (UILabel *)[cell.contentView viewWithTag:2];
    
    [imgViewMenu setImage:[UIImage imageNamed:strImageName]];
    lblMenuTitle.text = [self.arrMenuTitle objectAtIndex:indexPath.row];
    
    // Configure the cell...
    
    return cell;
}

- (NSIndexPath *)tableView:(UITableView *)tableView willSelectRowAtIndexPath:(NSIndexPath *)indexPath{
 
    switch(indexPath.row){
            
        case 0:
            [tableView deselectRowAtIndexPath:indexPath animated:NO];
            break;
            
        case 1:
            [self goBooking];
            break;
            
        case 2:
            [self goHistory];
            break;
            
        case 3:
            [self goMyProfile];
            break;
            
        case 4:
            [self goContacts];
            break;
            
        case 5:
            [self goShare];
            break;
            
        case 6:
            [self goCallUs];
            break;
            
        case 7:
            [self goSetting];
            break;
            
        default:
            [self goLogout];
            
    }
    
    return nil;
}

- (void) goBooking{
    
    [[NSNotificationCenter defaultCenter] postNotificationName:N_InitSelectCategory object:nil];
    
    [g_mainNav popToRootViewControllerAnimated:YES];
    
    [self.menuContainerViewController setMenuState:MFSideMenuStateClosed];
}

- (void) goHistory{
    
    UIViewController *historyVC  = [self.storyboard instantiateViewControllerWithIdentifier:VC_HISTORY];
    
    [g_mainNav popToRootViewControllerAnimated:NO];
    [g_mainNav pushViewController:historyVC animated:NO];
    
    [self.menuContainerViewController setMenuState:MFSideMenuStateClosed];
}

- (void) goMyProfile{
    UIViewController *myProfileVC  = [self.storyboard instantiateViewControllerWithIdentifier:VC_MY_PROFILE];
    
    [g_mainNav popToRootViewControllerAnimated:NO];
    [g_mainNav pushViewController:myProfileVC animated:NO];
    
    [self.menuContainerViewController setMenuState:MFSideMenuStateClosed];
}

- (void) goContacts{
    UIViewController *contactsVC  = [self.storyboard instantiateViewControllerWithIdentifier:VC_CONTACTS];
    
    [g_mainNav popToRootViewControllerAnimated:NO];
    [g_mainNav pushViewController:contactsVC animated:NO];
    
    [self.menuContainerViewController setMenuState:MFSideMenuStateClosed];
}

- (void) goShare{
    
    NSMutableArray *shareList =[[NSMutableArray alloc] initWithObjects:@"Email", @"Message", nil];
    
    UIActionSheet *actionSheet = [[UIActionSheet alloc] initWithTitle:@"Tell a Friend"
                                                             delegate:self
                                                    cancelButtonTitle:nil
                                               destructiveButtonTitle:nil
                                                    otherButtonTitles:nil];
    
    for (NSString *item in shareList) {
        [actionSheet addButtonWithTitle:item];
    }
    
    actionSheet.cancelButtonIndex = [actionSheet addButtonWithTitle:@"Cancel"];
    
    [actionSheet showInView:self.view];
    
    [self.menuContainerViewController setMenuState:MFSideMenuStateClosed];
}

- (void) goCallUs{
    
    NSString *phoneNumber = @"telprompt://037365365";
    [[UIApplication sharedApplication] openURL:[NSURL URLWithString:phoneNumber]];
    
    [self.menuContainerViewController setMenuState:MFSideMenuStateClosed];
}

- (void) goSetting{
    UIViewController *settingVC  = [self.storyboard instantiateViewControllerWithIdentifier:VC_SETTING];
    
    [g_mainNav popToRootViewControllerAnimated:NO];
    [g_mainNav pushViewController:settingVC animated:NO];
    
    [self.menuContainerViewController setMenuState:MFSideMenuStateClosed];
}

- (void) goLogout{
    [PFUser logOut];
    g_myInfo = nil;
    [[DataStore instance] reset];
    
    [g_mainNav popToRootViewControllerAnimated:NO];
    [self.menuContainerViewController setMenuState:MFSideMenuStateClosed];

    UIViewController *loginVC        = [self.storyboard instantiateViewControllerWithIdentifier:VC_LOGIN];

    UINavigationController *navCtrl  = [[UINavigationController alloc] initWithRootViewController:loginVC];
    
    navCtrl.navigationBarHidden = YES;
    
    [UIView transitionWithView:[g_appDelegate window]
                      duration:0.5
                       options:UIViewAnimationOptionTransitionFlipFromLeft
                    animations:^(void){
                        BOOL oldState = [UIView areAnimationsEnabled];
                        [UIView setAnimationsEnabled:NO];
                        [[g_appDelegate window] setRootViewController:navCtrl];
                        [UIView setAnimationsEnabled:oldState];
                    }
                    completion:nil];

}

- (void) shareWithEmail{
    if ([MFMailComposeViewController canSendMail])
    {
        MFMailComposeViewController *mailer = [[MFMailComposeViewController alloc] init];
        
        mailer.mailComposeDelegate = self;
        
        [mailer setSubject:@"Please Check out"];
        
//        NSArray *toRecipients = [NSArray arrayWithObjects:self.selItem.strValue, nil];
//        [mailer setToRecipients:toRecipients];
        
        NSString *emailBody = LocalizedString(@"text_share_message");
        [mailer setMessageBody:emailBody isHTML:NO];
        
        [self presentViewController:mailer animated:YES completion:nil];
    }
    else
    {
        UIAlertView *alert = [[UIAlertView alloc] initWithTitle:@"Failure"
                                                        message:@"Your device doesn't support the composer sheet"
                                                       delegate:nil
                                              cancelButtonTitle:@"OK"
                                              otherButtonTitles: nil];
        [alert show];
    }

    
}

- (void) shareWithSMS{
    MFMessageComposeViewController *messageController = [[MFMessageComposeViewController alloc] init];
    messageController.messageComposeDelegate = self;
    
    if([MFMessageComposeViewController canSendText]){
        messageController.body = LocalizedString(@"text_share_message");
//        messageController.recipients = [NSArray arrayWithObjects:self.selItem.strValue, nil];
        [self presentViewController:messageController animated:YES completion:nil];
    }

    
}

#pragma mark - Mail Composer

-(void)mailComposeController:(MFMailComposeViewController*)controller didFinishWithResult: (MFMailComposeResult)result error:  (NSError*)error {
    
    [self dismissViewControllerAnimated:YES completion:nil];
    
}

#pragma mark - Message Composer

- (void)messageComposeViewController:(MFMessageComposeViewController *)controller
                 didFinishWithResult:(MessageComposeResult)result{
    switch (result) {
        case MessageComposeResultSent: NSLog(@"SENT"); [self dismissViewControllerAnimated:YES completion:nil]; break;
        case MessageComposeResultFailed: NSLog(@"FAILED"); [self dismissViewControllerAnimated:YES completion:nil]; break;
        case MessageComposeResultCancelled: NSLog(@"CANCELLED"); [self dismissViewControllerAnimated:YES completion:nil]; break;
    }
    
}

#pragma mark - Action sheet

- (void)actionSheet:(UIActionSheet *)actionSheet clickedButtonAtIndex:(NSInteger)buttonIndex {
    
    if(buttonIndex == 0) [self shareWithEmail];
    if(buttonIndex == 1) [self shareWithSMS];
}
/*
// Override to support conditional editing of the table view.
- (BOOL)tableView:(UITableView *)tableView canEditRowAtIndexPath:(NSIndexPath *)indexPath {
    // Return NO if you do not want the specified item to be editable.
    return YES;
}
*/

/*
// Override to support editing the table view.
- (void)tableView:(UITableView *)tableView commitEditingStyle:(UITableViewCellEditingStyle)editingStyle forRowAtIndexPath:(NSIndexPath *)indexPath {
    if (editingStyle == UITableViewCellEditingStyleDelete) {
        // Delete the row from the data source
        [tableView deleteRowsAtIndexPaths:@[indexPath] withRowAnimation:UITableViewRowAnimationFade];
    } else if (editingStyle == UITableViewCellEditingStyleInsert) {
        // Create a new instance of the appropriate class, insert it into the array, and add a new row to the table view
    }   
}
*/

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
