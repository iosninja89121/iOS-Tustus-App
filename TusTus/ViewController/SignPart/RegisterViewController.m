//
//  RegisterViewController.m
//  TusTus
//
//  Created by User on 4/10/15.
//  Copyright (c) 2015 Philip. All rights reserved.
//

#import "RegisterViewController.h"
#import "SearchAddressViewController.h"
#import <SVProgressHUD.h>

@interface RegisterViewController ()
@property (weak, nonatomic) IBOutlet UILabel *lblHeaderTitle;
@property (weak, nonatomic) IBOutlet UIButton *btnHome;
@property (weak, nonatomic) IBOutlet UIButton *btnCreateAccount;

@property (weak, nonatomic) IBOutlet UIView *viewForPhoneNumber;
@property (weak, nonatomic) IBOutlet UIView *viewForEmail;
@property (weak, nonatomic) IBOutlet UIView *viewForFullName;
@property (weak, nonatomic) IBOutlet UIView *viewForAddress;
@property (weak, nonatomic) IBOutlet UIView *viewForApartment;
@property (weak, nonatomic) IBOutlet UIView *viewForFloor;
@property (weak, nonatomic) IBOutlet UIView *viewForPassword;
@property (weak, nonatomic) IBOutlet UIView *viewForConfirm;

@property (weak, nonatomic) IBOutlet UITextField *tfPhoneNumber;
@property (weak, nonatomic) IBOutlet UITextField *tfEmail;
@property (weak, nonatomic) IBOutlet UITextField *tfFullName;
@property (weak, nonatomic) IBOutlet UITextField *tfAddress;
@property (weak, nonatomic) IBOutlet UITextField *tfApartment;
@property (weak, nonatomic) IBOutlet UITextField *tfFloor;
@property (weak, nonatomic) IBOutlet UITextField *tfPassword;
@property (weak, nonatomic) IBOutlet UITextField *tfConfirm;

@property (weak, nonatomic) IBOutlet UIScrollView *myScrollView;

@property (weak, nonatomic) IBOutlet UIButton *btnCheckbox;

@property (weak, nonatomic) IBOutlet NIAttributedLabel *lblPrivacy;

@property (nonatomic) BOOL checkedPrivacy;
@end

@implementation RegisterViewController

- (IBAction)onCheckPrivacy:(id)sender {
    self.checkedPrivacy = !self.checkedPrivacy;
    
    if(self.checkedPrivacy){
        [self.btnCheckbox setImage:[UIImage imageNamed:@"cb_checked.png"] forState:UIControlStateNormal];
    }else{
        [self.btnCheckbox setImage:[UIImage imageNamed:@"cb_unchecked.png"] forState:UIControlStateNormal];
    }
}

- (IBAction)onCreateAccount:(id)sender {
    if(!self.checkedPrivacy){
        [SVProgressHUD showErrorWithStatus:@"Please check the privacy terms"];
        return;
    }
    
    [self processFieldEntries];
}

- (void)viewDidLoad {
    [super viewDidLoad];
    // Do any additional setup after loading the view.
    [self initUI];
    
    [[NSNotificationCenter defaultCenter] addObserver:self
                                             selector:@selector(searchAddressSelected:)
                                                 name:N_SearchAddressSelectedForRegister
                                               object:nil];

}

- (void) searchAddressSelected:(NSNotification *)notification{
    self.tfAddress.text = [DataStore instance].strSearchAddress;
}

- (void) sendWelcomeEmail{
    PFUser *currentUser = [PFUser currentUser];
    
    NSString *strFullName = currentUser[pKeyFullName];
    NSString *strUserName = currentUser.username;
    NSString *strPassword = currentUser[pKeyPSW];
    NSString *strEmail    = currentUser.email;
    
    NSString *strUrl = [NSString stringWithFormat:@"%@?mode=email&kind=welcome&email=%@&name=%@&password=%@&user=%@", SERVER_URL, strEmail, strFullName, strPassword, strUserName];
    
    strUrl = [AppDelegate URLEncodeStringForWindows1255:strUrl];
    
    NSURLRequest *urlRequest = [NSURLRequest requestWithURL:[NSURL URLWithString:strUrl]];
    
    NSOperationQueue *queue = [[NSOperationQueue alloc] init];
    
    [NSURLConnection sendAsynchronousRequest:urlRequest queue:queue completionHandler:nil];
}

- (void) initUI{
    self.viewForPhoneNumber.layer.cornerRadius = 5;
    self.viewForPhoneNumber.layer.masksToBounds = YES;
    self.viewForPhoneNumber.layer.borderWidth = 1;
    self.viewForPhoneNumber.layer.borderColor = [UIColor blackColor].CGColor;
    
    self.viewForEmail.layer.cornerRadius = 5;
    self.viewForEmail.layer.masksToBounds = YES;
    self.viewForEmail.layer.borderWidth = 1;
    self.viewForEmail.layer.borderColor = [UIColor blackColor].CGColor;
    
    self.viewForFullName.layer.cornerRadius = 5;
    self.viewForFullName.layer.masksToBounds = YES;
    self.viewForFullName.layer.borderWidth = 1;
    self.viewForFullName.layer.borderColor = [UIColor blackColor].CGColor;
    
    self.viewForAddress.layer.cornerRadius = 5;
    self.viewForAddress.layer.masksToBounds = YES;
    self.viewForAddress.layer.borderWidth = 1;
    self.viewForAddress.layer.borderColor = [UIColor blackColor].CGColor;
    
    self.viewForApartment.layer.cornerRadius = 5;
    self.viewForApartment.layer.masksToBounds = YES;
    self.viewForApartment.layer.borderWidth = 1;
    self.viewForApartment.layer.borderColor = [UIColor blackColor].CGColor;
    
    self.viewForFloor.layer.cornerRadius = 5;
    self.viewForFloor.layer.masksToBounds = YES;
    self.viewForFloor.layer.borderWidth = 1;
    self.viewForFloor.layer.borderColor = [UIColor blackColor].CGColor;
    
    self.viewForPassword.layer.cornerRadius = 5;
    self.viewForPassword.layer.masksToBounds = YES;
    self.viewForPassword.layer.borderWidth = 1;
    self.viewForPassword.layer.borderColor = [UIColor blackColor].CGColor;
    
    self.viewForConfirm.layer.cornerRadius = 5;
    self.viewForConfirm.layer.masksToBounds = YES;
    self.viewForConfirm.layer.borderWidth = 1;
    self.viewForConfirm.layer.borderColor = [UIColor blackColor].CGColor;
    
//    self.myScrollView.contentSize = CGSizeMake(300, 420);
    
    [self.lblHeaderTitle setText:LocalizedString(@"title_signup")];
    [self.btnHome setTitle:LocalizedString(@"title_home") forState:UIControlStateNormal];
    
    [self.tfPhoneNumber setText:self.strPhoneNumber];
    [self.tfEmail setPlaceholder:LocalizedString(@"hint_email")];
    [self.tfFullName setPlaceholder:LocalizedString(@"hint_full_name")];
    [self.tfAddress setPlaceholder:LocalizedString(@"hint_address")];
    [self.tfApartment setPlaceholder:LocalizedString(@"hint_apartment")];
    [self.tfFloor setPlaceholder:LocalizedString(@"hint_floor")];
    [self.tfPassword setPlaceholder:LocalizedString(@"hint_password")];
    [self.tfConfirm setPlaceholder:LocalizedString(@"hint_cfm_password")];
    
    [self.btnCheckbox setImage:[UIImage imageNamed:@"cb_unchecked.png"] forState:UIControlStateNormal];
    [self.btnCreateAccount setTitle:LocalizedString(@"title_create_account") forState:UIControlStateNormal];
    
    self.checkedPrivacy = NO;
    
    self.tfEmail.delegate = self;
    self.tfFullName.delegate = self;
    self.tfAddress.delegate = self;
    self.tfApartment.delegate = self;
    self.tfFloor.delegate = self;
    self.tfPassword.delegate = self;
    self.tfConfirm.delegate = self;
    
    [self.lblPrivacy setText:LocalizedString(@"comment_privacy")];
    [self.lblPrivacy setLinkColor:[UIColor blueColor]];
    [self.lblPrivacy setNumberOfLines:0];
    [self.lblPrivacy addLink: [NSURL URLWithString:@"http://www.tustus.co/privacy.php"] range:NSMakeRange(12, 30)];
    self.lblPrivacy.delegate = self;
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

- (void)processFieldEntries {
    NSString *strPhone     = self.tfPhoneNumber.text;
    NSString *strEmail     = self.tfEmail.text;
    NSString *strFullName  = self.tfFullName.text;
    NSString *strAddress   = self.tfAddress.text;
    NSString *strApartment = self.tfApartment.text;
    NSString *strFloor     = self.tfFloor.text;
    NSString *strPassword  = self.tfPassword.text;
    NSString *strConfirm   = self.tfConfirm.text;
    
    if(strEmail.length == 0){
        [SVProgressHUD showErrorWithStatus:@"Please enter a email address"];
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
        [SVProgressHUD showErrorWithStatus:@"Please enter a apart info"];
        return;
    }
    
    if(strFloor.length == 0){
        [SVProgressHUD showErrorWithStatus:@"Please enter a floor info"];
        return;
    }
    
    if(strPassword.length == 0){
        [SVProgressHUD showErrorWithStatus:@"Please enter a password"];
        return;
    }
    
    if(strConfirm.length == 0){
        [SVProgressHUD showErrorWithStatus:@"Please enter a cofirm"];
        return;
    }
    
    if([strPassword compare:strConfirm] != NSOrderedSame){
        self.tfPassword.text = @"";
        self.tfConfirm.text = @"";
        
        [SVProgressHUD showErrorWithStatus:@"password doen't match, please enter again"];
        
        return;
    }
    
    UserInfo *userInfo = [UserInfo initWithPhoneNumber:strPhone password:strPassword fullName:strFullName email:strEmail address:strAddress apartment:strApartment floor:strFloor];
    
    [SVProgressHUD showWithStatus:@"Signing Up..." maskType:SVProgressHUDMaskTypeGradient];
    [[ParseService sharedInstance] signUpWithUserInfo:userInfo
                                               Result:^(NSString *strError) {
                                                   if(strError == nil)
                                                   {
                                                       [SVProgressHUD dismiss];
                                                       
                                                       [self sendWelcomeEmail];
                                                       
                                                       [self processAppTransition];
                                                   }
                                                   else
                                                       [SVProgressHUD showErrorWithStatus:strError];
                                               }];
    
}

- (void)processAppTransition
{
    
    [UIView transitionWithView:[g_appDelegate window]
                      duration:0.5
                       options:UIViewAnimationOptionTransitionFlipFromLeft
                    animations:^(void){
                        BOOL oldState = [UIView areAnimationsEnabled];
                        [UIView setAnimationsEnabled:NO];
                        [[g_appDelegate window] setRootViewController:g_sideMenuController];
                        [UIView setAnimationsEnabled:oldState];
                    }
                    completion:nil];
    
}

#pragma mark Keyboard

- (void)dismissKeyboard {
    [self.view endEditing:YES];
}

#pragma mark UITextFieldDelegate
- (BOOL)textFieldShouldBeginEditing:(UITextField *)textField{
    if(textField == self.tfAddress){
        
        SearchAddressViewController *searchAddressVC = (SearchAddressViewController *)[self.storyboard instantiateViewControllerWithIdentifier:VC_SEARCH_ADDRESS];
        
        searchAddressVC.fromMode = fromRegister;
        
        [self presentViewController:searchAddressVC animated:YES completion:nil];
        return NO;
    }
    
    return YES;
}

- (BOOL)textFieldShouldReturn:(UITextField *)textField {
    if(textField == self.tfEmail){
        [self.tfFullName becomeFirstResponder];
    }
    
    if(textField == self.tfFullName){
        [self.tfAddress becomeFirstResponder];
    }
    
    if(textField == self.tfApartment){
        [self.tfFloor becomeFirstResponder];
    }
    
    if(textField == self.tfFloor){
        [self.tfPassword becomeFirstResponder];
    }
    
    if(textField == self.tfPassword){
        [self.tfConfirm becomeFirstResponder];
    }
    
    if(textField == self.tfConfirm){
        [self dismissKeyboard];
    }
        
    return YES;
}

#pragma mark NIAttributedLabelDelegate

- (void)attributedLabel:(NIAttributedLabel *)attributedLabel didSelectTextCheckingResult:(NSTextCheckingResult *)result atPoint:(CGPoint)point
{
    [[UIApplication sharedApplication] openURL:result.URL];
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
