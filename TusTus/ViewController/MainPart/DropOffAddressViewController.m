//
//  DropOffAddressViewController.m
//  TusTus
//
//  Created by User on 4/24/15.
//  Copyright (c) 2015 Philip. All rights reserved.
//

#import "DropOffAddressViewController.h"
#import "ContactListViewController.h"
#import "SearchAddressViewController.h"
#import <MapKit/MapKit.h>
#import <SVProgressHUD.h>
#import <TPKeyboardAvoidingScrollView.h>

@interface DropOffAddressViewController ()
@property (weak, nonatomic) IBOutlet UILabel *lblHeaderTitle;
@property (weak, nonatomic) IBOutlet UIButton *btnCheckBox;
@property (weak, nonatomic) IBOutlet UILabel *lblToMe;
@property (weak, nonatomic) IBOutlet UIButton *btnAddToContact;
@property (weak, nonatomic) IBOutlet UIButton *btnChooseFromContact;

@property (weak, nonatomic) IBOutlet UIView *viewForName;
@property (weak, nonatomic) IBOutlet UIView *viewForPhone;
@property (weak, nonatomic) IBOutlet UIView *viewForAddress;
@property (weak, nonatomic) IBOutlet UIView *viewForFloor;
@property (weak, nonatomic) IBOutlet UIView *viewForApartment;
@property (weak, nonatomic) IBOutlet UIView *viewForComments;
@property (weak, nonatomic) IBOutlet UIView *viewForSMS;


@property (weak, nonatomic) IBOutlet UITextField *tfName;
@property (weak, nonatomic) IBOutlet UITextField *tfPhone;
@property (weak, nonatomic) IBOutlet UITextField *tfAddress;
@property (weak, nonatomic) IBOutlet UITextField *tfFloor;
@property (weak, nonatomic) IBOutlet UITextField *tfApartment;
@property (weak, nonatomic) IBOutlet UITextView *tvComment;
@property (weak, nonatomic) IBOutlet UITextField *tfSMS;

@property (weak, nonatomic) IBOutlet UIButton *btnRewind;
@property (weak, nonatomic) IBOutlet UIButton *btnNext;

@property (weak, nonatomic) IBOutlet UILabel *lblElevator;
@property (weak, nonatomic) IBOutlet UISwitch *switchElevator;
@property (weak, nonatomic) IBOutlet UIPickerView *pickerFloor;

@property (weak, nonatomic) IBOutlet TPKeyboardAvoidingScrollView *scrollViewTP;


@property (nonatomic)       NSInteger   nAutoSMS;
@property (nonatomic, strong) NSArray *arrFloor;

@property (nonatomic)      BOOL       checked;

@property (nonatomic, strong) CLGeocoder *geocoder;

@property (nonatomic) CLLocationCoordinate2D coordinateForPickup;
@property (nonatomic) CLLocationCoordinate2D coordinateForDropOff;

@property (nonatomic, strong) ASIHTTPRequest *requestPickup;
@property (nonatomic, strong) ASIHTTPRequest *requestDropoff;
@property (nonatomic, strong) ASIHTTPRequest *requestDistance;

@property (weak, nonatomic) IBOutlet NSLayoutConstraint *nHeightViewForName;
@property (weak, nonatomic) IBOutlet NSLayoutConstraint *nHeightRewindButton;
@property (weak, nonatomic) IBOutlet NSLayoutConstraint *nHeightSwitch;


@end

@implementation DropOffAddressViewController
- (IBAction)onRightMenu:(id)sender {
    [self.menuContainerViewController toggleRightSideMenuCompletion:nil];
}

- (IBAction)onLeftMenu:(id)sender {
    [self.menuContainerViewController toggleLeftSideMenuCompletion:nil];
}

- (IBAction)onCheckBox:(id)sender {
    self.checked = !self.checked;
    
    if(self.checked){
        [self.btnCheckBox setImage:[UIImage imageNamed:@"cb_checked"] forState:UIControlStateNormal];
        
        self.tfName.text = g_myInfo.strFullName;
        self.tfPhone.text = g_myInfo.strPhoneNumber;
        self.tfAddress.text = g_myInfo.strAddress;
        self.tfFloor.text = g_myInfo.strFloor;
        self.tfApartment.text = g_myInfo.strApartment;
    }else{
        [self.btnCheckBox setImage:[UIImage imageNamed:@"cb_unchecked"] forState:UIControlStateNormal];
        
        self.tfName.text = @"";
        self.tfPhone.text = @"";
        self.tfAddress.text = @"";
        self.tfFloor.text = @"";
        self.tfApartment.text = @"";
    }

}

- (IBAction)onRewind:(id)sender {
    [self.navigationController popViewControllerAnimated:YES];
}

- (IBAction)onNext:(id)sender {
    NSString *strFullName      = self.tfName.text;
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
    
    [DataStore instance].addressInfoForDropOff = [AddressInfo initWithFullName:strFullName phoneNumber:strPhone address:strAddress apartment:strApartment floor:strFloor];
    
    [DataStore instance].strAutoSms = self.tfSMS.text;
    
    if([self.tvComment.text isEqualToString:LocalizedString(@"hint_comment")])
        [DataStore instance].strComment = @"";
    else
        [DataStore instance].strComment = self.tvComment.text;
    
    [DataStore instance].flgElevatorDropoff = self.switchElevator.isOn;
    
    [SVProgressHUD showWithStatus:LocalizedString(@"text_please_wait") maskType:SVProgressHUDMaskTypeGradient];
    
    [self getCoordinateForPickup];
//    [self calcDistance];
    
    
    
}

- (IBAction)onChooseFromContactList:(id)sender {
    if(self.checked) return;
    
    ContactListViewController *contactListVC = (ContactListViewController *)[self.storyboard instantiateViewControllerWithIdentifier:VC_CONTACT_LIST];
    
    contactListVC.fromMode = fromDropOff;
    
    [self presentViewController:contactListVC animated:YES completion:nil];
}

- (IBAction)onAddToContactList:(id)sender {
    if(self.checked) return;
    
    NSString *strFullName      = self.tfName.text;
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

- (void) goNextScreen{
    [SVProgressHUD dismiss];
    
    if([DataStore instance].nCategory == MOVING_CAT){
        UIViewController *inventoryVC = [self.storyboard instantiateViewControllerWithIdentifier:VC_INVENTORY_ITEM];
        [self.navigationController pushViewController:inventoryVC animated:NO];
        
    }else{
        UIViewController *totalVC = [self.storyboard instantiateViewControllerWithIdentifier:VC_TOTAL_PAGE];
        [self.navigationController pushViewController:totalVC animated:NO];
    }
}

- (NSString *)getDirectionsUrl{
    NSString *strPickup  = [NSString stringWithFormat:@"origin=%lf,%lf", self.coordinateForPickup.latitude, self.coordinateForPickup.longitude];
    NSString *strDropoff = [NSString stringWithFormat:@"destination=%lf,%lf", self.coordinateForDropOff.latitude, self.coordinateForDropOff.longitude];
    NSString *strSensor = @"sensor=false";
    
    NSString *strParameters = [NSString stringWithFormat:@"%@&%@&%@", strPickup, strDropoff, strSensor];
    
    NSString *strOutput = @"json";
    
    NSString *strUrl = [NSString stringWithFormat:@"https://maps.googleapis.com/maps/api/directions/%@?%@", strOutput, strParameters];
    
    return strUrl;
}

- (void) processingDataForDistance:(NSData *)objectNotation
{
    NSDictionary *parsedObject = [NSJSONSerialization JSONObjectWithData:objectNotation options:0 error:nil];
    
    NSString *strValue = [[[[[[parsedObject valueForKey:@"routes"] valueForKey:@"legs"] valueForKey:@"distance"] valueForKey:@"value"] firstObject] firstObject];
    
    double dblDistance = [strValue doubleValue];
    
    dblDistance = dblDistance / 1000;
    
    [DataStore instance].dblDistance = dblDistance;
    
    NSLog(@"distance-%lf", [DataStore instance].dblDistance);
    
    [self goNextScreen];
}

- (void) processingDataForPickup:(NSData *)objectNotation
{
    NSDictionary *parsedObject = [NSJSONSerialization JSONObjectWithData:objectNotation options:0 error:nil];
    
    NSString *strValueLat = [[[[[parsedObject valueForKey:@"results"] valueForKey:@"geometry"] valueForKey:@"location"] valueForKey:@"lat"] firstObject];
    NSString *strValueLng = [[[[[parsedObject valueForKey:@"results"] valueForKey:@"geometry"] valueForKey:@"location"] valueForKey:@"lng"] firstObject];
    
    double dblLat = [strValueLat doubleValue];
    double dblLng = [strValueLng doubleValue];
    
    self.coordinateForPickup = CLLocationCoordinate2DMake(dblLat, dblLng);
    
    [self getCoordinateForDropOff];
}

- (void) processingDataForDropoff:(NSData *)objectNotation
{
    NSDictionary *parsedObject = [NSJSONSerialization JSONObjectWithData:objectNotation options:0 error:nil];
    
    NSString *strValueLat = [[[[[parsedObject valueForKey:@"results"] valueForKey:@"geometry"] valueForKey:@"location"] valueForKey:@"lat"] firstObject];
    NSString *strValueLng = [[[[[parsedObject valueForKey:@"results"] valueForKey:@"geometry"] valueForKey:@"location"] valueForKey:@"lng"] firstObject];
    
    double dblLat = [strValueLat doubleValue];
    double dblLng = [strValueLng doubleValue];
    
    self.coordinateForDropOff = CLLocationCoordinate2DMake(dblLat, dblLng);
    
    [self calcDistance];
}


- (void) calcDistance{
    
    NSString *strUrl = [self getDirectionsUrl];
    
    strUrl = [AppDelegate URLEncodeString:strUrl];
    
    NSURL *url = [[NSURL alloc] initWithString:strUrl];
    
    self.requestDistance = [ASIHTTPRequest requestWithURL:url];
    [self.requestDistance setDelegate:self];
    [self.requestDistance startAsynchronous];
}

- (void) getCoordinateForPickup{
    
    NSString *strAddress = [DataStore instance].addressInfoForPickup.strAddress;
    NSString *strUrl = [NSString stringWithFormat:@"http://maps.google.com/maps/api/geocode/json?address=%@&sensor=false", strAddress];
    
    strUrl = [AppDelegate URLEncodeString:strUrl];

    NSURL *url = [[NSURL alloc] initWithString:strUrl];
    
    self.requestPickup = [ASIHTTPRequest requestWithURL:url];
    [self.requestPickup setDelegate:self];
    [self.requestPickup startAsynchronous];
}


- (void) getCoordinateForDropOff{
    NSString *strAddress = [DataStore instance].addressInfoForDropOff.strAddress;
    NSString *strUrl = [NSString stringWithFormat:@"http://maps.google.com/maps/api/geocode/json?address=%@&sensor=false", strAddress];
    
    strUrl = [AppDelegate URLEncodeString:strUrl];
    
    NSURL *url = [[NSURL alloc] initWithString:strUrl];
    
    self.requestDropoff = [ASIHTTPRequest requestWithURL:url];
    [self.requestDropoff setDelegate:self];
    [self.requestDropoff startAsynchronous];
}


- (void)viewDidLoad {
    [super viewDidLoad];
    // Do any additional setup after loading the view.
    [[NSNotificationCenter defaultCenter] addObserver:self
                                             selector:@selector(contactSelected:)
                                                 name:N_ContactSelectedForDropOff
                                               object:nil];
    
    [[NSNotificationCenter defaultCenter] addObserver:self
                                             selector:@selector(searchAddressSelected:)
                                                 name:N_SearchAddressSelectedForDropOff
                                               object:nil];
    
    PFUser *currentUser = [PFUser currentUser];
    
    
    self.nAutoSMS = [(NSNumber *)currentUser[pKeyAutoSMS] integerValue];
    
    [self initUI];
    
//    if([DataStore instance].nCategory == MOVING_CAT) [self initwithData];
    
    self.arrFloor = @[@"-5", @"-4", @"-3", @"-2", @"-1", @"0", @"1", @"2", @"3", @"4", @"5", @"6", @"7", @"8", @"9", @"10", @"11", @"12", @"13", @"14", @"15", @"16", @"17", @"18", @"19", @"20"];
    
    UITapGestureRecognizer *tapGestureRecognizer = [[UITapGestureRecognizer alloc] initWithTarget:self action:@selector(dismissPickerView)];
    
    tapGestureRecognizer.cancelsTouchesInView = NO;
    
    [self.view addGestureRecognizer:tapGestureRecognizer];
}

- (void) initwithData{
    self.tfName.text = @"person 2";
    self.tfPhone.text = @"phone 2";
    self.tfAddress.text = @"Tel Aviv, Israel";
    self.tfApartment.text = @"apartment 2";
    self.tfFloor.text = @"floor 2";
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
    
    self.viewForComments.layer.cornerRadius = 5;
    self.viewForComments.layer.masksToBounds = YES;
    self.viewForComments.layer.borderWidth = 1;
    self.viewForComments.layer.borderColor = [UIColor blackColor].CGColor;
    
    self.viewForSMS.layer.cornerRadius = 5;
    self.viewForSMS.layer.masksToBounds = YES;
    self.viewForSMS.layer.borderWidth = 1;
    self.viewForSMS.layer.borderColor = [UIColor blackColor].CGColor;
    
    [self.lblHeaderTitle setText:LocalizedString(@"header_title_delivery_address")];
    [self.lblToMe setText:LocalizedString(@"comment_to_me")];
    [self.btnAddToContact setTitle:LocalizedString(@"title_add_to_contact_list") forState:UIControlStateNormal];
    [self.btnChooseFromContact setTitle:LocalizedString(@"title_choose_from_contact_list") forState:UIControlStateNormal];
    
    [self.tfName setPlaceholder:LocalizedString(@"hint_person_name")];
    [self.tfPhone setPlaceholder:LocalizedString(@"hint_person_phone")];
    [self.tfAddress setPlaceholder:LocalizedString(@"hint_address")];
    [self.tfFloor setPlaceholder:LocalizedString(@"hint_floor")];
    [self.tfApartment setPlaceholder:LocalizedString(@"hint_apartment")];
    [self.tvComment setText:LocalizedString(@"hint_comment")];
    self.tvComment.textColor = [UIColor lightGrayColor];
    [self.tfSMS setPlaceholder:LocalizedString(@"hint_sms_phone")];
    
    [self.btnRewind setTitle:LocalizedString(@"title_rewind") forState:UIControlStateNormal];
    [self.btnNext setTitle:LocalizedString(@"title_next") forState:UIControlStateNormal];
    
    self.tfName.delegate = self;
    self.tfPhone.delegate = self;
    self.tfAddress.delegate = self;
    self.tfApartment.delegate = self;
    self.tfFloor.delegate = self;
    self.tvComment.delegate = self;
    self.tfSMS.delegate = self;
    
    self.pickerFloor.delegate = self;
    self.pickerFloor.dataSource = self;
    
    if(self.nAutoSMS == 0 || (self.nAutoSMS == 1 && [DataStore instance].nCategory == MOVING_CAT)){
        [self.viewForSMS setHidden:YES];
    }else{
        [self.viewForSMS setHidden:NO];
    }
    
    if([DataStore instance].nCategory == MOVING_CAT){
        self.nHeightViewForName.constant = 8;
        self.nHeightSwitch.constant = 8;
        self.nHeightRewindButton.constant = 50;
        
        [self.lblElevator setHidden:NO];
        [self.switchElevator setHidden:NO];
        self.tfFloor.text = @"0";
        
        [self.lblToMe setHidden:YES];
        [self.btnCheckBox setHidden:YES];
        
        [self.btnChooseFromContact setHidden:YES];
        [self.btnAddToContact setHidden:YES];
        
    }else{
        self.nHeightViewForName.constant = 81;
        self.nHeightRewindButton.constant = 60;
        
        [self.lblElevator setHidden: YES];
        [self.switchElevator setHidden:YES];
        
        [self.lblToMe setHidden:NO];
        [self.btnCheckBox setHidden:NO];
        
        [self.btnChooseFromContact setHidden:NO];
        [self.btnAddToContact setHidden:NO];
        
        self.checked = NO;
        
        [self.btnCheckBox setImage:[UIImage imageNamed:@"cb_unchecked"] forState:UIControlStateNormal];
    }
    
}

- (void) contactSelected:(NSNotification *)notification{
    self.tfName.text      = [DataStore instance].addressInfoForDropOff.strFullName;
    self.tfPhone.text     = [DataStore instance].addressInfoForDropOff.strPhone;
    self.tfAddress.text   = [DataStore instance].addressInfoForDropOff.strAddress;
    self.tfApartment.text = [DataStore instance].addressInfoForDropOff.strApartment;
    self.tfFloor.text     = [DataStore instance].addressInfoForDropOff.strFloor;
}

- (void) searchAddressSelected:(NSNotification *)notification{
    self.tfAddress.text = [DataStore instance].strSearchAddress;
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

- (void) dismissPickerView{
    [self.pickerFloor setHidden:YES];
}

#pragma mark ASIHTTPRequest
- (void)requestFinished:(ASIHTTPRequest *)request{
    NSData *data = [request responseData];
    
    if(request == self.requestPickup){
        [self processingDataForPickup:data];
    }else if(request == self.requestDropoff){
        [self processingDataForDropoff:data];
    }else if(request == self.requestDistance){
        [self processingDataForDistance:data];
    }
}

#pragma mark Keyboard Hidden

- (void)dismissKeyboard {
    [self.view endEditing:YES];
}

#pragma mark UITextFieldDelegate
- (BOOL)textFieldShouldBeginEditing:(UITextField *)textField{
    if(textField == self.tfAddress){
        
        SearchAddressViewController *searchAddressVC = (SearchAddressViewController *)[self.storyboard instantiateViewControllerWithIdentifier:VC_SEARCH_ADDRESS];
        
        searchAddressVC.fromMode = fromDropOff;
        
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
    if(textField == self.tfName){
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
        [self.tvComment becomeFirstResponder];
    }
    
    return YES;
}

#pragma mark -
#pragma mark UITextViewDelegate


- (BOOL) textViewShouldBeginEditing:(UITextView *)textView
{
    NSString* strComment = [textView text];
    NSString *strHint    = LocalizedString(@"hint_comment");
    
    if([strComment compare:strHint] != NSOrderedSame) return YES;
    
    textView.text = @"";
    textView.textColor = [UIColor blackColor];
    
    return YES;
}

-(void) textViewDidChange:(UITextView *)textView
{
    
    if(textView.text.length == 0){
        textView.textColor = [UIColor lightGrayColor];
        
        textView.text = LocalizedString(@"hint_comment");
        
    }
}

- (BOOL)textViewShouldEndEditing:(UITextView *)textView{
    if(textView.text.length > 0) return YES;
    
    textView.textColor = [UIColor lightGrayColor];
    
    textView.text = LocalizedString(@"hint_comment");
    
    return YES;
}

- (void)textViewDidEndEditing:(UITextView *)textView{
    
}


- (void)connection:(NSURLConnection *)connection didFailWithError:(NSError *)error {
    NSString *errorText;
    //Specific error
    if (error)
        errorText = [error localizedDescription];
    //Generic error
    else
        errorText = @"An error occurred when downloading the list of issues. Please check that you are connected to the Internet.";
    
    [SVProgressHUD showErrorWithStatus:errorText];
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
