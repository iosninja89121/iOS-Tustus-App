//
//  PickupAddressViewController.m
//  TusTus
//
//  Created by User on 4/19/15.
//  Copyright (c) 2015 Philip. All rights reserved.
//

#import "PickupAddressViewController.h"
#import "DropOffAddressViewController.h"
#import "ContactListViewController.h"
#import "SearchAddressViewController.h"
#import <TPKeyboardAvoidingScrollView.h>
#import <SVProgressHUD.h>

@interface PickupAddressViewController ()
@property (weak, nonatomic) IBOutlet UILabel *lblTitle;
@property (weak, nonatomic) IBOutlet UIButton *btnCheckBox;
@property (weak, nonatomic) IBOutlet UIButton *btnAddToContact;
@property (weak, nonatomic) IBOutlet UIButton *btnChooseFromContact;
@property (weak, nonatomic) IBOutlet UIView *viewForName;
@property (weak, nonatomic) IBOutlet UIView *viewForPhone;
@property (weak, nonatomic) IBOutlet UIView *viewForAddress;
@property (weak, nonatomic) IBOutlet UIView *viewForFloor;
@property (weak, nonatomic) IBOutlet UIView *viewForApartment;
@property (weak, nonatomic) IBOutlet UIButton *btnRewind;
@property (weak, nonatomic) IBOutlet UIButton *btnNext;
@property (weak, nonatomic) IBOutlet UITextField *tfPerson;
@property (weak, nonatomic) IBOutlet UITextField *tfPhone;
@property (weak, nonatomic) IBOutlet UITextField *tfAddress;
@property (weak, nonatomic) IBOutlet UITextField *tfFloor;
@property (weak, nonatomic) IBOutlet UITextField *tfApartment;
@property (weak, nonatomic) IBOutlet UILabel *lblFromMe;
@property (weak, nonatomic) IBOutlet UISwitch *switchElevator;
@property (weak, nonatomic) IBOutlet UILabel *lblElevator;
@property (weak, nonatomic) IBOutlet UIPickerView *pickerFloor;

@property (nonatomic, strong) NSArray *arrFloor;
@property (nonatomic) BOOL checked;
@property (weak, nonatomic) IBOutlet TPKeyboardAvoidingScrollView *scrollViewTP;

@property (weak, nonatomic) IBOutlet NSLayoutConstraint *nHeightViewForName;
@property (weak, nonatomic) IBOutlet NSLayoutConstraint *nHeightViewForBottomButton;

@end

@implementation PickupAddressViewController
- (IBAction)onLeftMenu:(id)sender {
    [self.menuContainerViewController toggleLeftSideMenuCompletion:nil];
}

- (IBAction)onRightMenu:(id)sender {
    [self.menuContainerViewController toggleRightSideMenuCompletion:nil];
}

- (IBAction)onCheckBox:(id)sender {
    self.checked = !self.checked;
    
    if(self.checked){
        [self.btnCheckBox setImage:[UIImage imageNamed:@"cb_checked"] forState:UIControlStateNormal];
        
        self.tfPerson.text = g_myInfo.strFullName;
        self.tfPhone.text = g_myInfo.strPhoneNumber;
        self.tfAddress.text = g_myInfo.strAddress;
        self.tfFloor.text = g_myInfo.strFloor;
        self.tfApartment.text = g_myInfo.strApartment;
    }else{
        [self.btnCheckBox setImage:[UIImage imageNamed:@"cb_unchecked"] forState:UIControlStateNormal];
        
        self.tfPerson.text = @"";
        self.tfPhone.text = @"";
        self.tfAddress.text = @"";
        self.tfFloor.text = @"";
        self.tfApartment.text = @"";
    }
}

- (IBAction)onAddToContact:(id)sender {
    if(self.checked) return;
    
    NSString *strFullName      = self.tfPerson.text;
    NSString *strPhone     = self.tfPhone.text;
    NSString *strAddress   = self.tfAddress.text;
    NSString *strApartment = self.tfApartment.text;
    NSString *strFloor     = self.tfFloor.text;
    
    if(strPhone.length == 0){
        [SVProgressHUD showErrorWithStatus:@"Please enter a phone"];
        return;
    }
    
    if(strFullName.length == 0){
        [SVProgressHUD showErrorWithStatus:@"Please enter a full name"];
        return;
    }
    
    if(strAddress.length == 0){
        [SVProgressHUD showErrorWithStatus:@"Please enter a address"];
        return;
    }
    
    if(strApartment.length == 0){
        [SVProgressHUD showErrorWithStatus:@"Please enter a apartment info"];
        return;
    }
    
    if(strFloor.length == 0){
        [SVProgressHUD showErrorWithStatus:@"Please enter a floor info"];
        return;
    }
    
    [SVProgressHUD showWithStatus:@"Wait..." maskType:SVProgressHUDMaskTypeGradient];
    
    PFObject *contactObj = [PFObject objectWithClassName:pClassContact];
    
    contactObj[pKeyMyUsername] = g_myInfo.strPhoneNumber;
    contactObj[pKeyFullName]   = strFullName;
    contactObj[pKeyUsername]   = strPhone;
    contactObj[pKeyAddress]    = strAddress;
    contactObj[pKeyApartment]  = strApartment;
    contactObj[pKeyFloor]      = strFloor;
    
    [contactObj saveInBackgroundWithBlock:^(BOOL succeeded, NSError *error) {
        if(succeeded){
            [SVProgressHUD dismiss];
            
            AddressInfo *addressInfo = [AddressInfo initWithObject:contactObj];
            
            [[DataStore instance].arrContacts addObject:addressInfo];
            
        }else{
            [SVProgressHUD showErrorWithStatus:[error.userInfo objectForKey:@"error" ]];
        }
    }];

}

- (IBAction)onChooseFromContact:(id)sender {
    if(self.checked) return;
    
    ContactListViewController *contactListVC = (ContactListViewController *)[self.storyboard instantiateViewControllerWithIdentifier:VC_CONTACT_LIST];
    
    contactListVC.fromMode = fromPickup;
    
    [self presentViewController:contactListVC animated:YES completion:nil];
}

- (IBAction)onRewind:(id)sender {
    [self.navigationController popViewControllerAnimated:YES];
}

- (IBAction)onNext:(id)sender {
    NSString *strFullName      = self.tfPerson.text;
    NSString *strPhone     = self.tfPhone.text;
    NSString *strAddress   = self.tfAddress.text;
    NSString *strApartment = self.tfApartment.text;
    NSString *strFloor     = self.tfFloor.text;
    
    if(strPhone.length == 0){
        [SVProgressHUD showErrorWithStatus:@"Please enter a phone"];
        return;
    }
    
    if(strFullName.length == 0){
        [SVProgressHUD showErrorWithStatus:@"Please enter a full name"];
        return;
    }
    
    if(strAddress.length == 0){
        [SVProgressHUD showErrorWithStatus:@"Please enter a address"];
        return;
    }
    
    if(strApartment.length == 0){
        [SVProgressHUD showErrorWithStatus:@"Please enter a apartment info"];
        return;
    }
    
    if(strFloor.length == 0){
        [SVProgressHUD showErrorWithStatus:@"Please enter a floor info"];
        return;
    }
    
    [DataStore instance].flgElevatorPickup = self.switchElevator.isOn;

    [DataStore instance].addressInfoForPickup = [AddressInfo initWithFullName:strFullName phoneNumber:strPhone address:strAddress apartment:strApartment floor:strFloor];
    
    DropOffAddressViewController *dropOffAddressVC = (DropOffAddressViewController *)[self.storyboard instantiateViewControllerWithIdentifier:VC_DROP_OFF_ADDRESS];
    
    [self.navigationController pushViewController:dropOffAddressVC animated:YES];
}

- (void)viewDidLoad {
    [super viewDidLoad];
    // Do any additional setup after loading the view.
    
    [[NSNotificationCenter defaultCenter] addObserver:self
                                             selector:@selector(contactSelected:)
                                                 name:N_ContactSelectedForPickup
                                               object:nil];
    
    [[NSNotificationCenter defaultCenter] addObserver:self
                                             selector:@selector(searchAddressSelected:)
                                                 name:N_SearchAddressSelectedForPickup
                                               object:nil];
    
    [self initUI];
//    if([DataStore instance].nCategory == MOVING_CAT) [self initwithData];

    self.arrFloor = @[@"-5", @"-4", @"-3", @"-2", @"-1", @"0", @"1", @"2", @"3", @"4", @"5", @"6", @"7", @"8", @"9", @"10", @"11", @"12", @"13", @"14", @"15", @"16", @"17", @"18", @"19", @"20"];
    
    UITapGestureRecognizer *tapGestureRecognizer = [[UITapGestureRecognizer alloc] initWithTarget:self action:@selector(dismissPickerView)];
    
    tapGestureRecognizer.cancelsTouchesInView = NO;
    
    [self.view addGestureRecognizer:tapGestureRecognizer];
}

- (void) initwithData{
    self.tfPerson.text = @"person 1";
    self.tfPhone.text = @"phone 1";
    self.tfAddress.text = @"Ramat Gan, Israel";
    self.tfApartment.text = @"apartment 1";
    self.tfFloor.text = @"floor 1";
}

- (void) dismissPickerView{
    [self.pickerFloor setHidden:YES];
}

- (void) initUI{
    self.viewForName.layer.cornerRadius = 5;
    self.viewForName.layer.masksToBounds = YES;
    self.viewForName.layer.borderWidth = 1;
    self.viewForName.layer.borderColor = [UIColor blackColor].CGColor;
    
    self.viewForPhone.layer.cornerRadius = 5;
    self.viewForPhone.layer.masksToBounds = YES;
    self.viewForPhone.layer.borderWidth = 1;
    self.viewForPhone.layer.borderColor = [UIColor blackColor].CGColor;
    
    self.viewForAddress.layer.cornerRadius = 5;
    self.viewForAddress.layer.masksToBounds = YES;
    self.viewForAddress.layer.borderWidth = 1;
    self.viewForAddress.layer.borderColor = [UIColor blackColor].CGColor;
    
    self.viewForFloor.layer.cornerRadius = 5;
    self.viewForFloor.layer.masksToBounds = YES;
    self.viewForFloor.layer.borderWidth = 1;
    self.viewForFloor.layer.borderColor = [UIColor blackColor].CGColor;
    
    self.viewForApartment.layer.cornerRadius = 5;
    self.viewForApartment.layer.masksToBounds = YES;
    self.viewForApartment.layer.borderWidth = 1;
    self.viewForApartment.layer.borderColor = [UIColor blackColor].CGColor;
    
    [self.lblTitle setText:LocalizedString(@"header_title_pickup_address")];
    [self.lblFromMe setText:LocalizedString(@"comment_from_me")];
    [self.lblElevator setText:LocalizedString(@"comment_elevator")];
    [self.btnAddToContact setTitle:LocalizedString(@"title_add_to_contact_list") forState:UIControlStateNormal];
    [self.btnChooseFromContact setTitle:LocalizedString(@"title_choose_from_contact_list") forState:UIControlStateNormal];
    [self.btnRewind setTitle:LocalizedString(@"title_rewind") forState:UIControlStateNormal];
    [self.btnNext setTitle:LocalizedString(@"title_next") forState:UIControlStateNormal];
    [self.tfPerson setPlaceholder:LocalizedString(@"hint_person_name")];
    [self.tfPhone setPlaceholder:LocalizedString(@"hint_person_phone")];
    [self.tfAddress setPlaceholder:LocalizedString(@"hint_address")];
    [self.tfFloor setPlaceholder:LocalizedString(@"hint_floor")];
    [self.tfApartment setPlaceholder:LocalizedString(@"hint_apartment")];
    
    self.tfPerson.delegate = self;
    self.tfPhone.delegate = self;
    self.tfAddress.delegate = self;
    self.tfApartment.delegate = self;
    self.tfFloor.delegate = self;
    self.pickerFloor.delegate = self;
    self.pickerFloor.dataSource = self;
    
    if([DataStore instance].nCategory == MOVING_CAT){
        self.nHeightViewForName.constant = 10;
        self.nHeightViewForBottomButton.constant = 51;
        
        [self.lblElevator setHidden:NO];
        [self.switchElevator setHidden:NO];
        self.tfFloor.text = @"0";
        
        [self.lblFromMe setHidden:YES];
        [self.btnCheckBox setHidden:YES];
        
        [self.btnChooseFromContact setHidden:YES];
        [self.btnAddToContact setHidden:YES];
    }else{
        self.nHeightViewForName.constant = 86;
        self.nHeightViewForBottomButton.constant = 8;
        
        [self.lblElevator setHidden: YES];
        [self.switchElevator setHidden:YES];
        
        [self.lblFromMe setHidden:NO];
        [self.btnCheckBox setHidden:NO];
        
        [self.btnChooseFromContact setHidden:NO];
        [self.btnAddToContact setHidden:NO];
        
        self.checked = NO;
        
        [self.btnCheckBox setImage:[UIImage imageNamed:@"cb_unchecked"] forState:UIControlStateNormal];
    }
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

- (void) contactSelected:(NSNotification *)notification{
    self.tfPerson.text    = [DataStore instance].addressInfoForPickup.strFullName;
    self.tfPhone.text     = [DataStore instance].addressInfoForPickup.strPhone;
    self.tfAddress.text   = [DataStore instance].addressInfoForPickup.strAddress;
    self.tfApartment.text = [DataStore instance].addressInfoForPickup.strApartment;
    self.tfFloor.text     = [DataStore instance].addressInfoForPickup.strFloor;
}

- (void) searchAddressSelected:(NSNotification *)notification{
    self.tfAddress.text = [DataStore instance].strSearchAddress;
}

#pragma mark Keyboard Hidden

- (void)dismissKeyboard {
    [self.view endEditing:YES];
}


#pragma mark UITextFieldDelegate
- (BOOL)textFieldShouldBeginEditing:(UITextField *)textField{
    if(textField == self.tfAddress){
        
        SearchAddressViewController *searchAddressVC = (SearchAddressViewController *)[self.storyboard instantiateViewControllerWithIdentifier:VC_SEARCH_ADDRESS];
        
        searchAddressVC.fromMode = fromPickup;
        
        [self presentViewController:searchAddressVC animated:YES completion:nil];
        return NO;
    }
    
    if(textField == self.tfFloor && [DataStore instance].nCategory == MOVING_CAT){
        [self.pickerFloor setHidden:NO];
        
        return NO;
    }
    
    return YES;
}

- (BOOL)textFieldShouldReturn:(UITextField *)textField {
    if(textField == self.tfPerson){
        [self.tfPhone becomeFirstResponder];
    }
    
    if(textField == self.tfPhone){
        [self.tfApartment becomeFirstResponder];
    }
    
    if(textField == self.tfApartment){
        if([DataStore instance].nCategory == MOVING_CAT){
            [self.tfFloor resignFirstResponder];
            [self.tfFloor becomeFirstResponder];
        }else{
            [self dismissKeyboard];
        }
    }
    
    if(textField == self.tfFloor){
        [self dismissKeyboard];
    }
    
    return YES;
}

#pragma mark - Picker View Data source
-(NSInteger)numberOfComponentsInPickerView:(UIPickerView *)pickerView{
    return 1;
}
-(NSInteger)pickerView:(UIPickerView *)pickerView numberOfRowsInComponent:(NSInteger)component{
    return self.arrFloor.count;
}

#pragma mark- Picker View Delegate

-(void)pickerView:(UIPickerView *)pickerView didSelectRow:(NSInteger)row inComponent:(NSInteger)component{
    [self.tfFloor setText:[self.arrFloor objectAtIndex:row]];
}

- (NSString *)pickerView:(UIPickerView *)pickerView titleForRow:(NSInteger)row forComponent:(NSInteger)component{
    return [self.arrFloor objectAtIndex:row];
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
