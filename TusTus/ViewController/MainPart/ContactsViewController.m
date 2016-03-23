//
//  ContactsViewController.m
//  TusTus
//
//  Created by User on 4/25/15.
//  Copyright (c) 2015 Philip. All rights reserved.
//

#import "ContactsViewController.h"
#import "EditContactViewController.h"
#import <SVProgressHUD.h>
#import "AddressInfo.h"

@interface ContactsViewController ()
@property (weak, nonatomic) IBOutlet UILabel *lblTitle;
@property (weak, nonatomic) IBOutlet UIButton *btnAdd;
@property (weak, nonatomic) IBOutlet UISearchBar *searchBarContacts;
@property (weak, nonatomic) IBOutlet UITableView *tblContacts;

@property (strong, nonatomic) NSMutableArray *arrFilteredContacts;
@property (nonatomic, strong) AddressInfo *selAddressInfo;
@end

@implementation ContactsViewController
- (IBAction)onLeftMenu:(id)sender {
    [self.menuContainerViewController toggleLeftSideMenuCompletion:nil];
}
- (IBAction)onRightMenu:(id)sender {
    [self.menuContainerViewController toggleRightSideMenuCompletion:nil];
}

- (IBAction)onAdd:(id)sender {
    EditContactViewController *editContactVC = (EditContactViewController *)[self.storyboard instantiateViewControllerWithIdentifier:VC_EDIT_CONTACT];
    
    editContactVC.addressInfo = nil;
    
    [self presentViewController:editContactVC animated:YES completion:nil];
}

- (void)viewDidLoad {
    [super viewDidLoad];
    // Do any additional setup after loading the view.
    self.tblContacts.delegate = self;
    self.tblContacts.dataSource = self;
    
    self.arrFilteredContacts = [NSMutableArray arrayWithCapacity:[[DataStore instance].arrContacts count]];
    
    [[NSNotificationCenter defaultCenter] addObserver:self
                                             selector:@selector(contactUpdated:)
                                                 name:N_ContactUpdated
                                               object:nil];

    [self initUI];
}

- (void) initUI{
    self.lblTitle.text = LocalizedString(@"header_title_contacts");
    [self.btnAdd setTitle:LocalizedString(@"title_add") forState:UIControlStateNormal];
    [self.searchBarContacts setPlaceholder:LocalizedString(@"hint_search")];
}

- (void) contactUpdated:(NSNotification *)notification{
    [self.tblContacts reloadData];
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

- (void) performEdit{
    EditContactViewController *editContactVC = (EditContactViewController *)[self.storyboard instantiateViewControllerWithIdentifier:VC_EDIT_CONTACT];
    
    editContactVC.addressInfo = self.selAddressInfo;
    
    [self presentViewController:editContactVC animated:YES completion:nil];
}

- (void) performRemove{
    PFQuery *contactQuery = [PFQuery queryWithClassName:pClassContact];
    
    [contactQuery whereKey:pKeyMyUsername equalTo:g_myInfo.strPhoneNumber];
    [contactQuery whereKey:pKeyFullName equalTo:self.selAddressInfo.strFullName];
    [contactQuery whereKey:pKeyUsername equalTo:self.selAddressInfo.strPhone];
    
    [SVProgressHUD showWithStatus:@"Wait..." maskType:SVProgressHUDMaskTypeGradient];
    
    [contactQuery getFirstObjectInBackgroundWithBlock:^(PFObject *object, NSError *error) {
        if(error == nil){
            [object deleteInBackgroundWithBlock:^(BOOL succeeded, NSError *error) {
                if(succeeded){
                    [SVProgressHUD dismiss];
                    [[DataStore instance].arrContacts removeObject:self.selAddressInfo];
                    [self.tblContacts reloadData];
                }else{
                    [SVProgressHUD showErrorWithStatus:[error.userInfo objectForKey:@"error" ]];

                }
            }];
            
        }else{
            [SVProgressHUD showErrorWithStatus:[error.userInfo objectForKey:@"error" ]];
        }
    }];
}

#pragma mark Content Filtering
-(void)filterContentForSearchText:(NSString*)searchText scope:(NSString*)scope {
    [self.arrFilteredContacts removeAllObjects];
    
    NSPredicate *predicate = [NSPredicate predicateWithFormat:@"SELF.strFullName contains[c] %@",searchText];
    self.arrFilteredContacts = [NSMutableArray arrayWithArray:[[DataStore instance].arrContacts filteredArrayUsingPredicate:predicate]];
}

#pragma mark - UISearchDisplayController Delegate Methods
-(BOOL)searchDisplayController:(UISearchDisplayController *)controller shouldReloadTableForSearchString:(NSString *)searchString {
    // Tells the table data source to reload when text changes
    [self filterContentForSearchText:searchString scope:
     [[self.searchDisplayController.searchBar scopeButtonTitles] objectAtIndex:[self.searchDisplayController.searchBar selectedScopeButtonIndex]]];
    // Return YES to cause the search result table view to be reloaded.
    return YES;
}

-(BOOL)searchDisplayController:(UISearchDisplayController *)controller shouldReloadTableForSearchScope:(NSInteger)searchOption {
    // Tells the table data source to reload when scope bar selection changes
    [self filterContentForSearchText:self.searchDisplayController.searchBar.text scope:
     [[self.searchDisplayController.searchBar scopeButtonTitles] objectAtIndex:searchOption]];
    // Return YES to cause the search result table view to be reloaded.
    return YES;
}

#pragma mark - Action sheet

- (void)actionSheet:(UIActionSheet *)actionSheet clickedButtonAtIndex:(NSInteger)buttonIndex {
    
    if(buttonIndex == 0) [self performEdit];
    if(buttonIndex == 1) [self performRemove];
}

#pragma mark - Table view data source

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section
{
    // Check to see whether the normal table or search results table is being displayed and return the count from the appropriate array
    if (tableView == self.searchDisplayController.searchResultsTableView)
    {
        return [self.arrFilteredContacts count];
    }
    else
    {
        return [[DataStore instance].arrContacts count];
    }
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath
{
    //    static NSString *CellIdentifier = @"Cell";
    UITableViewCell *cell = [self.tblContacts dequeueReusableCellWithIdentifier:CELL_CONTACT];
    
    
    //    UITableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:CELL_CONTACT];
    
    UILabel *lblMainInfo = (UILabel *)[cell.contentView viewWithTag:1];
    UILabel *lblDetailInfo = (UILabel *)[cell.contentView viewWithTag:2];
    
    // Create a new Candy Object
    AddressInfo *addressInfo = nil;
    
    // Check to see whether the normal table or search results table is being displayed and set the Candy object from the appropriate array
    if (tableView == self.searchDisplayController.searchResultsTableView)
    {
        addressInfo = [self.arrFilteredContacts objectAtIndex:[indexPath row]];
    }
    else
    {
        addressInfo = [[DataStore instance].arrContacts objectAtIndex:[indexPath row]];
    }
    
    // Configure the cell
    NSString *strLabelFullName  = LocalizedString(@"hint_full_name");
    NSString *strLabelAddress   = LocalizedString(@"hint_address");
    NSString *strLabelFloor     = LocalizedString(@"hint_floor");
    NSString *strLabelApartment = LocalizedString(@"hint_apartment");
    NSString *strlabelPhone     = LocalizedString(@"hint_phone_number");
    
    lblMainInfo.text   = [NSString stringWithFormat:@"%@-%@, %@-%@", strLabelFullName, addressInfo.strFullName, strLabelAddress, addressInfo.strAddress];
    lblDetailInfo.text = [NSString stringWithFormat:@"%@-%@, %@-%@, %@-%@", strLabelFloor, addressInfo.strFloor, strLabelApartment, addressInfo.strApartment, strlabelPhone, addressInfo.strPhone];
    
    return cell;
}

-(CGFloat)tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath{
    
    UITableViewCell *cell = [self.tblContacts dequeueReusableCellWithIdentifier:CELL_CONTACT];
    
    UILabel *lblMainInfo = (UILabel *)[cell.contentView viewWithTag:1];
    UILabel *lblDetailInfo = (UILabel *)[cell.contentView viewWithTag:2];
    
    // Create a new Candy Object
    AddressInfo *addressInfo = nil;
    
    // Check to see whether the normal table or search results table is being displayed and set the Candy object from the appropriate array
    if (tableView == self.searchDisplayController.searchResultsTableView)
    {
        addressInfo = [self.arrFilteredContacts objectAtIndex:[indexPath row]];
    }
    else
    {
        addressInfo = [[DataStore instance].arrContacts objectAtIndex:[indexPath row]];
    }
    
    // Configure the cell
    NSString *strLabelFullName  = LocalizedString(@"hint_full_name");
    NSString *strLabelAddress   = LocalizedString(@"hint_address");
    NSString *strLabelFloor     = LocalizedString(@"hint_floor");
    NSString *strLabelApartment = LocalizedString(@"hint_apartment");
    NSString *strlabelPhone     = LocalizedString(@"hint_phone_number");
    
    NSString *strMainInfo   = [NSString stringWithFormat:@"%@-%@, %@-%@", strLabelFullName, addressInfo.strFullName, strLabelAddress, addressInfo.strAddress];
    NSString *strDetailInfo = [NSString stringWithFormat:@"%@-%@, %@-%@, %@-%@", strLabelFloor, addressInfo.strFloor, strLabelApartment, addressInfo.strApartment, strlabelPhone, addressInfo.strPhone];
    
    CGFloat heightMain   = [AppDelegate getRealHeightFrom:lblMainInfo.frame.size.width content:strMainInfo fontname:lblMainInfo.font.fontName fontsize:lblMainInfo.font.pointSize];
    
    CGFloat heightDetail = [AppDelegate getRealHeightFrom:lblDetailInfo.frame.size.width content:strDetailInfo fontname:lblDetailInfo.font.fontName fontsize:lblDetailInfo.font.pointSize];
    
    return heightMain + heightDetail + 30;
}

#pragma mark - TableView Delegate

- (NSIndexPath *)tableView:(UITableView *)tableView willSelectRowAtIndexPath:(NSIndexPath *)indexPath{
    
    if (tableView == self.searchDisplayController.searchResultsTableView)
    {
        self.selAddressInfo = [self.arrFilteredContacts objectAtIndex:[indexPath row]];
    }
    else
    {
        self.selAddressInfo = [[DataStore instance].arrContacts objectAtIndex:[indexPath row]];
    }
    
    NSMutableArray *shareList =[[NSMutableArray alloc] initWithObjects:LocalizedString(@"pop_menu_edit"), LocalizedString(@"pop_menu_remove"), nil];
    
    UIActionSheet *actionSheet = [[UIActionSheet alloc] initWithTitle:nil
                                                             delegate:self
                                                    cancelButtonTitle:nil
                                               destructiveButtonTitle:nil
                                                    otherButtonTitles:nil];
    
    for (NSString *item in shareList) {
        [actionSheet addButtonWithTitle:item];
    }
    
    actionSheet.cancelButtonIndex = [actionSheet addButtonWithTitle:LocalizedString(@"pop_menu_cancel")];
    
    [actionSheet showInView:self.view];

    return nil;
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
