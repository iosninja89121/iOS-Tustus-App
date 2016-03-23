//
//  MyProfileViewController.m
//  TusTus
//
//  Created by User on 4/25/15.
//  Copyright (c) 2015 Philip. All rights reserved.
//

#import "MyProfileViewController.h"
#import "SearchAddressViewController.h"
#import <SVProgressHUD.h>

@interface MyProfileViewController ()
@property (weak, nonatomic) IBOutlet UILabel *lblTitle;
@property (weak, nonatomic) IBOutlet UIButton *btnEdit;
@property (weak, nonatomic) IBOutlet UIView *viewForPhone;
@property (weak, nonatomic) IBOutlet UIView *viewForEmail;
@property (weak, nonatomic) IBOutlet UIView *viewForName;
@property (weak, nonatomic) IBOutlet UIView *viewForAddress;
@property (weak, nonatomic) IBOutlet UIView *viewForFloor;
@property (weak, nonatomic) IBOutlet UIView *viewForPassword;
@property (weak, nonatomic) IBOutlet UIView *viewForConfirm;
@property (weak, nonatomic) IBOutlet UIView *viewForApartment;
@property (weak, nonatomic) IBOutlet UITextField *tfPhone;
@property (weak, nonatomic) IBOutlet UITextField *tfEmail;
@property (weak, nonatomic) IBOutlet UITextField *tfName;
@property (weak, nonatomic) IBOutlet UITextField *tfAddress;
@property (weak, nonatomic) IBOutlet UITextField *tfFloor;
@property (weak, nonatomic) IBOutlet UITextField *tfPassword;
@property (weak, nonatomic) IBOutlet UITextField *tfConfirm;
@property (weak, nonatomic) IBOutlet UITextField *tfApartment;
@property (weak, nonatomic) IBOutlet UIScrollView *myScrollView;

@property (nonatomic) BOOL  isEdit;
@end

@implementation MyProfileViewController
- (IBAction)onLeftMenu:(id)sender {
    [self.menuContainerViewController toggleLeftSideMenuCompletion:nil];
}

- (IBAction)onRightMenu:(id)sender {
    [self.menuContainerViewController toggleRightSideMenuCompletion:nil];
}

- (IBAction)onEdit:(id)sender {
    
    if(!self.isEdit){
        self.isEdit = YES;
        [self.btnEdit setTitle:LocalizedString(@"title_done") forState:UIControlStateNormal];
        
        return;
    }
    
    NSString *strEmail     = self.tfEmail.text;
    NSString *strName      = self.tfName.text;
    NSString *strAddress   = self.tfAddress.text;
    NSString *strApartment = self.tfApartment.text;
    NSString *strFloor     = self.tfFloor.text;
    NSString *strPassword  = self.tfPassword.text;
    NSString *strConfirm   = self.tfConfirm.text;
    
    if(strEmail.length == 0){
        [SVProgressHUD showErrorWithStatus:@"Please enter a email address"];
        return;
    }
    
    if(strName.length == 0){
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
    
    PFUser *currentUser = [PFUser currentUser];
    
    currentUser[pKeyEmail]     = strEmail;
    currentUser[pKeyFullName]  = strName;
    currentUser[pKeyAddress]   = strAddress;
    currentUser[pKeyApartment] = strApartment;
    currentUser[pKeyFloor]     = strFloor;
    currentUser[pKeyPSW]       = strPassword;
    
    [SVProgressHUD showWithStatus:LocalizedString(@"text_please_wait") maskType:SVProgressHUDMaskTypeGradient];
    
    [currentUser saveEventually:^(BOOL succeeded, NSError *error) {
        [SVProgressHUD dismiss];
        
        [g_myInfo addInfoWithPFUser:currentUser];
        
        self.isEdit = NO;
        [self.btnEdit setTitle:LocalizedString(@"title_edit") forState:UIControlStateNormal];
    }];
    
}

- (void)viewDidLoad {
    [super viewDidLoad];
    // Do any additional setup after loading the view.
    [self initUI];
}

- (void) initUI{
    self.viewForPhone.layer.cornerRadius = 5;
    self.viewForPhone.layer.masksToBounds = YES;
    self.viewForPhone.layer.borderWidth = 1;
    self.viewForPhone.layer.borderColor = [UIColor blackColor].CGColor;
    
    self.viewForEmail.layer.cornerRadius = 5;
    self.viewForEmail.layer.masksToBounds = YES;
    self.viewForEmail.layer.borderWidth = 1;
    self.viewForEmail.layer.borderColor = [UIColor blackColor].CGColor;
    
    self.viewForName.layer.cornerRadius = 5;
    self.viewForName.layer.masksToBounds = YES;
    self.viewForName.layer.borderWidth = 1;
    self.viewForName.layer.borderColor = [UIColor blackColor].CGColor;
    
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
    
    self.viewForPassword.layer.cornerRadius = 5;
    self.viewForPassword.layer.masksToBounds = YES;
    self.viewForPassword.layer.borderWidth = 1;
    self.viewForPassword.layer.borderColor = [UIColor blackColor].CGColor;
    
    self.viewForConfirm.layer.cornerRadius = 5;
    self.viewForConfirm.layer.masksToBounds = YES;
    self.viewForConfirm.layer.borderWidth = 1;
    self.viewForConfirm.layer.borderColor = [UIColor blackColor].CGColor;
    
    self.tfPhone.delegate = self;
    self.tfEmail.delegate = self;
    self.tfName.delegate = self;
    self.tfAddress.delegate = self;
    self.tfFloor.delegate = self;
    self.tfApartment.delegate = self;
    self.tfPassword.delegate = self;
    self.tfConfirm.delegate = self;
    
    self.isEdit = NO;
    
    [self.btnEdit setTitle:LocalizedString(@"title_edit") forState:UIControlStateNormal];
    
    self.tfPhone.text = g_myInfo.strPhoneNumber;
    self.tfEmail.text = g_myInfo.strEmail;
    self.tfName.text  = g_myInfo.strFullName;
    self.tfAddress.text = g_myInfo.strAddress;
    self.tfApartment.text = g_myInfo.strApartment;
    self.tfFloor.text = g_myInfo.strFloor;
    self.tfPassword.text = g_myInfo.strPassword;
    self.tfConfirm.text = g_myInfo.strPassword;
    
    self.myScrollView.contentSize = CGSizeMake(320, 700);
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

#pragma mark Keyboard Hidden

- (void)dismissKeyboard {
    [self.view endEditing:YES];
}

#pragma mark UITextFieldDelegate
- (BOOL)textFieldShouldBeginEditing:(UITextField *)textField{
    if(!self.isEdit) return NO;
    
    if(textField == self.tfAddress){
        
        SearchAddressViewController *searchAddressVC = (SearchAddressViewController *)[self.storyboard instantiateViewControllerWithIdentifier:VC_SEARCH_ADDRESS];
        
        searchAddressVC.fromMode = fromMyProfile;
        
        [self presentViewController:searchAddressVC animated:YES completion:nil];
        return NO;
    }
    
    if(textField == self.tfPhone) return NO;
    
    return YES;
}

- (BOOL)textFieldShouldReturn:(UITextField *)textField {
    if(textField == self.tfEmail){
        [self.tfName becomeFirstResponder];
    }
    
    if(textField == self.tfName){
        [self.tfApartment becomeFirstResponder];
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
        [self.tfConfirm resignFirstResponder];
        [self dismissKeyboard];
    }
    
    return YES;
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
