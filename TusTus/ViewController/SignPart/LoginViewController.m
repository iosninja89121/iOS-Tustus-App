//
//  LoginViewController.m
//  TusTus
//
//  Created by User on 4/7/15.
//  Copyright (c) 2015 Philip. All rights reserved.
//

#import "LoginViewController.h"
#import "PhoneNumberViewController.h"
#import "AddressInfo.h"
#import "DeliveryBookingInfo.h"
#import "UserInfo.h"
#import <SVProgressHUD.h>

@interface LoginViewController ()
@property (weak, nonatomic) IBOutlet UIView *viewForID;
@property (weak, nonatomic) IBOutlet UIView *viewForPassword;
@property (weak, nonatomic) IBOutlet UITextField *tfUsername;
@property (weak, nonatomic) IBOutlet UITextField *tfPassword;
@property (weak, nonatomic) IBOutlet UIButton *btnRemember;
@property (nonatomic) BOOL boolRemember;

@property (weak, nonatomic) IBOutlet UILabel *lblRememberMe;
@property (weak, nonatomic) IBOutlet UIButton *btnLogin;
@property (weak, nonatomic) IBOutlet UIButton *btnSignup;
@property (weak, nonatomic) IBOutlet UIButton *btnForgotPassword;

@end

@implementation LoginViewController
- (IBAction)unwindWelcome:(UIStoryboardSegue *)segue{
    
}

- (IBAction)onLogin:(id)sender {
    [self processFieldEntries];
}

- (IBAction)onRemember:(id)sender {
    self.boolRemember = !self.boolRemember;
    
    if(self.boolRemember){
        [self.btnRemember setImage:[UIImage imageNamed:@"cb_checked.png"] forState:UIControlStateNormal];
    }else{
        [self.btnRemember setImage:[UIImage imageNamed:@"cb_unchecked.png"] forState:UIControlStateNormal];
    }
    
}

- (void)viewDidLoad {
    [super viewDidLoad];
    // Do any additional setup after loading the view.
    
    UITapGestureRecognizer *tapGestureRecognizer = [[UITapGestureRecognizer alloc] initWithTarget:self action:@selector(dismissKeyboard)];
    
    tapGestureRecognizer.cancelsTouchesInView = NO;
    
    [self.view addGestureRecognizer:tapGestureRecognizer];
    
    [self initUI];

}

- (void) initUI{
    self.viewForID.layer.cornerRadius = 5;
    self.viewForID.layer.masksToBounds = YES;
    self.viewForID.layer.borderWidth = 1;
    self.viewForID.layer.borderColor = [UIColor blackColor].CGColor;
    
    self.viewForPassword.layer.cornerRadius = 5;
    self.viewForPassword.layer.masksToBounds = YES;
    self.viewForPassword.layer.borderWidth = 1;
    self.viewForPassword.layer.borderColor = [UIColor blackColor].CGColor;
    
    self.tfUsername.delegate = self;
    self.tfPassword.delegate = self;
    
    self.boolRemember = [[NSUserDefaults standardUserDefaults] boolForKey:DEFAULT_REMEMBER_ME];
    
    if(self.boolRemember){
        NSString* strPhone = [[NSUserDefaults standardUserDefaults] stringForKey:DEFAULT_USER_PHONE];
        NSString* strPswd = [[NSUserDefaults standardUserDefaults] stringForKey:DEFAULT_USER_PSWD];
        
        self.tfUsername.text = strPhone;
        self.tfPassword.text = strPswd;
        
        [self.btnRemember setImage:[UIImage imageNamed:@"cb_checked.png"] forState:UIControlStateNormal];
    }else{
        [self.btnRemember setImage:[UIImage imageNamed:@"cb_unchecked.png"] forState:UIControlStateNormal];
    }
    
    self.lblRememberMe.text = LocalizedString(@"comment_remember_me");
    [self.btnLogin setTitle:LocalizedString(@"title_login") forState:UIControlStateNormal];
    [self.btnSignup setTitle:LocalizedString(@"title_signup") forState:UIControlStateNormal];
    [self.btnForgotPassword setTitle:LocalizedString(@"comment_forgot_password") forState:UIControlStateNormal];
    [self.tfUsername setPlaceholder:LocalizedString(@"hint_phone_number")];
    [self.tfPassword setPlaceholder:LocalizedString(@"hint_password")];
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

- (void)processFieldEntries {
    // Get the username text, store it in the app delegate for now
    
    if (self.tfUsername.text.length < 1 || self.tfPassword.text.length < 1) {
        [SVProgressHUD showErrorWithStatus:@"Please complete the sign in form!"];
        return;
    }
    
    [SVProgressHUD showWithStatus:@"Logging In..." maskType:SVProgressHUDMaskTypeGradient];
    [[ParseService sharedInstance] loginWithUserName:self.tfUsername.text
                                            Password:self.tfPassword.text
                                              Result:^(NSString *strError) {
                                                  if(strError == nil)
                                                  {
                                                      [self getData];
                                                  }
                                                  else
                                                  {
                                                      [SVProgressHUD showErrorWithStatus:strError];
                                                  }
                                              }];
}

- (void) getData{
    [[DataStore instance] reset];
    
    PFUser *currentUser = [PFUser currentUser];
    
    PFQuery *contactQuery = [PFQuery queryWithClassName:pClassContact];
    
    [contactQuery whereKey:pKeyMyUsername equalTo:currentUser.username];
    
    NSArray * arrContact = [contactQuery findObjects];
    
    for(int i = 0; i < arrContact.count; i ++){
        PFObject *pfObj = [arrContact objectAtIndex:i];
        
        AddressInfo *addressInfo = [AddressInfo initWithObject:pfObj];
        
        [[DataStore instance].arrContacts addObject:addressInfo];
    }
    
    NSString *strFullName = currentUser[pKeyFullName];
    PFQuery *completedQuery = [PFQuery queryWithClassName:pClassCompletedDelivery];
    
    [completedQuery orderByDescending:@"createdAt"];
    [completedQuery whereKey:pKeyCustomerName equalTo:strFullName];
    
    NSArray *arrCompleted = [completedQuery findObjects];
    
    for(int i = 0; i < arrCompleted.count; i ++){
        PFObject *pfObj = [arrCompleted objectAtIndex:i];
        
        DeliveryBookingInfo *bookingInfo = [DeliveryBookingInfo initWithObject:pfObj];
        
        [[DataStore instance].arrCompletedBooking addObject:bookingInfo];
    }
    
    PFQuery *deliveryQuery = [PFQuery queryWithClassName:pClassDelivery];
    
    [deliveryQuery orderByDescending:@"createdAt"];
    [deliveryQuery whereKey:pKeyCustomerName equalTo:strFullName];
    [deliveryQuery whereKey:pKeyStatus notEqualTo:[NSNumber numberWithInt:-1]];
    
    NSArray *arrDelivery = [deliveryQuery findObjects];

    for(int i = 0; i < arrDelivery.count; i ++){
        PFObject *pfObj = [arrDelivery objectAtIndex:i];
        
        DeliveryBookingInfo *bookingInfo = [DeliveryBookingInfo initWithObject:pfObj];
        
        [[DataStore instance].arrCurrentBooking addObject:bookingInfo];
    }
    
    PFQuery *cityQuery = [PFQuery queryWithClassName:pClassCity_Hebrew];
    
    NSArray *arrCity = [cityQuery findObjects];
    
    for(PFObject *pfObj in arrCity){
        NSString *strCity = pfObj[pKeyCityName];
        
        [[DataStore instance].arrCity addObject:strCity];
    }
    
    NSMutableArray *arrNewBookedID = [[NSMutableArray alloc] init];
    
    for (DeliveryBookingInfo *bookingInfo in [DataStore instance].arrCurrentBooking) {
        if(bookingInfo.nStatus == 0){
            NSString *strIDCouple = [NSString stringWithFormat:@"%@:@", bookingInfo.strObjectId];
            
            [arrNewBookedID addObject:strIDCouple];
        }
    }
    
    [[NSUserDefaults standardUserDefaults] setObject:arrNewBookedID forKey:pref_booked_array];
    
    [self didGetData];
}

- (void) didGetData{
    [SVProgressHUD dismiss];
    [[NSUserDefaults standardUserDefaults] setBool:self.boolRemember forKey:DEFAULT_REMEMBER_ME];
    
    if(self.boolRemember){
        [[NSUserDefaults standardUserDefaults] setValue:self.tfUsername.text forKey:DEFAULT_USER_PHONE];
        [[NSUserDefaults standardUserDefaults] setValue:self.tfPassword.text  forKey:DEFAULT_USER_PSWD];
    }
    
    [[NSUserDefaults standardUserDefaults] synchronize];
   
    PFInstallation *currentInstallation = [PFInstallation currentInstallation];
    
    currentInstallation[pKeyUserID] = g_myInfo.strUserObjID;
    
    [currentInstallation saveInBackground];
    
    [self processAppTransition];
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

- (BOOL)textFieldShouldReturn:(UITextField *)textField {
    if (textField == self.tfUsername) {
        [self.tfPassword becomeFirstResponder];
    }
    
    if (textField == self.tfPassword) {
        [self dismissKeyboard];
        [self processFieldEntries];
    }
    
    return YES;
}


#pragma mark - Navigation

// In a storyboard-based application, you will often want to do a little preparation before navigation
- (void)prepareForSegue:(UIStoryboardSegue *)segue sender:(id)sender {
    // Get the new view controller using [segue destinationViewController].
    // Pass the selected object to the new view controller.
    if([segue.identifier isEqualToString:SEGUE_NUMBER_FROM_SIGNUP]){
        PhoneNumberViewController *controller = (PhoneNumberViewController *)segue.destinationViewController;
        controller.fromMode = fromSignup;
    }
    
    if([segue.identifier isEqualToString:SEGUE_NUMBER_FROM_FORGOT]){
        PhoneNumberViewController *controller = (PhoneNumberViewController *)segue.destinationViewController;
        controller.fromMode = fromForgot;
    }
}


@end
