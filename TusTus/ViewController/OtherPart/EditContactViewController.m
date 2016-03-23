//
//  EditContactViewController.m
//  TusTus
//
//  Created by User on 4/24/15.
//  Copyright (c) 2015 Philip. All rights reserved.
//

#import "EditContactViewController.h"
#import "SearchAddressViewController.h"
#import <SVProgressHUD.h>

@interface EditContactViewController ()
@property (weak, nonatomic) IBOutlet UILabel *lblTitle;
@property (weak, nonatomic) IBOutlet UIButton *btnCancel;
@property (weak, nonatomic) IBOutlet UIButton *btnSave;

@property (weak, nonatomic) IBOutlet UIView *viewForName;
@property (weak, nonatomic) IBOutlet UIView *viewForPhone;
@property (weak, nonatomic) IBOutlet UIView *viewForAddress;
@property (weak, nonatomic) IBOutlet UIView *viewForFloor;
@property (weak, nonatomic) IBOutlet UIView *viewForApartment;

@property (weak, nonatomic) IBOutlet UITextField *tfName;
@property (weak, nonatomic) IBOutlet UITextField *tfPhone;
@property (weak, nonatomic) IBOutlet UITextField *tfAddress;
@property (weak, nonatomic) IBOutlet UITextField *tfFloor;
@property (weak, nonatomic) IBOutlet UITextField *tfApartment;

@property (nonatomic) BOOL isNew;
@end

@implementation EditContactViewController

- (IBAction)onCancel:(id)sender {
    
    [self dismissViewControllerAnimated:YES completion:nil];
}

- (IBAction)onSave:(id)sender {
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
    
    if(self.isNew){
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
                
                [self dismissViewControllerAnimated:YES completion:^{
                    [[NSNotificationCenter defaultCenter] postNotificationName:N_ContactUpdated object:nil];
                }];
                
            }else{
                [SVProgressHUD showErrorWithStatus:[error.userInfo objectForKey:@"error" ]];
            }
        }];
        
    }else{
        PFQuery *contactQuery = [PFQuery queryWithClassName:pClassContact];
        
        [contactQuery whereKey:pKeyMyUsername equalTo:g_myInfo.strPhoneNumber];
        [contactQuery whereKey:pKeyFullName equalTo:self.addressInfo.strFullName];
        [contactQuery whereKey:pKeyUsername equalTo:self.addressInfo.strPhone];
        
        [contactQuery getFirstObjectInBackgroundWithBlock:^(PFObject *object, NSError *error) {
            if(error == nil){
                object[pKeyFullName]   = strFullName;
                object[pKeyUsername]   = strPhone;
                object[pKeyAddress]    = strAddress;
                object[pKeyApartment]  = strApartment;
                object[pKeyFloor]      = strFloor;
                
                [object saveInBackgroundWithBlock:^(BOOL succeeded, NSError *error) {
                    if(succeeded){
                        [SVProgressHUD dismiss];
                        
                        [self.addressInfo initWithObject:object];
                        
                        [self dismissViewControllerAnimated:YES completion:^{
                           [[NSNotificationCenter defaultCenter] postNotificationName:N_ContactUpdated object:nil];
                        }];
                        
                    }else{
                        [SVProgressHUD showErrorWithStatus:[error.userInfo objectForKey:@"error" ]];
                    }
                }];
            }else{
                [SVProgressHUD showErrorWithStatus:[error.userInfo objectForKey:@"error" ]];
            }
        }];

    }
}

- (void)viewDidLoad {
    [super viewDidLoad];
    // Do any additional setup after loading the view.
    [self initUI];
    
    self.tfName.delegate = self;
    self.tfPhone.delegate = self;
    self.tfAddress.delegate = self;
    self.tfApartment.delegate = self;
    self.tfFloor.delegate = self;
    
    self.isNew = (self.addressInfo == nil)? YES : NO;
    
    
    if(!self.isNew)
    {
        self.tfName.text = self.addressInfo.strFullName;
        self.tfPhone.text = self.addressInfo.strPhone;
        self.tfAddress.text = self.addressInfo.strAddress;
        self.tfApartment.text = self.addressInfo.strApartment;
        self.tfFloor.text = self.addressInfo.strFloor;
    }else{
//        [self initForTest];
    }
    
    [[NSNotificationCenter defaultCenter] addObserver:self
                                             selector:@selector(searchAddressSelected:)
                                                 name:N_SearchAddressSelectedForEditContact
                                               object:nil];
}

- (void) initForTest{
    self.tfName.text = @"Name 1";
    self.tfPhone.text = @"Phone 1";
    self.tfAddress.text = @"Address 1";
    self.tfApartment.text = @"apartment 1";
    self.tfFloor.text = @"floor 1";
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
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
    
    self.lblTitle.text = LocalizedString(@"header_title_add_contact");
    [self.btnCancel setTitle:LocalizedString(@"title_cancel") forState:UIControlStateNormal];
    [self.btnSave setTitle:LocalizedString(@"title_save") forState:UIControlStateNormal];
    [self.tfName setPlaceholder:LocalizedString(@"hint_person_name")];
    [self.tfPhone setPlaceholder:LocalizedString(@"hint_person_phone")];
    [self.tfAddress setPlaceholder:LocalizedString(@"hint_address")];
    [self.tfApartment setPlaceholder:LocalizedString(@"hint_apartment")];
    [self.tfFloor setPlaceholder:LocalizedString(@"hint_floor")];
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
        
        searchAddressVC.fromMode = fromEditContact;
        
        [self presentViewController:searchAddressVC animated:YES completion:nil];
        
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
    
    if(textField == self.tfFloor){
        [self.tfApartment becomeFirstResponder];
    }
    
    if(textField == self.tfApartment){
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
