//
//  PhoneNumberViewController.m
//  TusTus
//
//  Created by User on 4/10/15.
//  Copyright (c) 2015 Philip. All rights reserved.
//

#import "PhoneNumberViewController.h"
#import "RegisterViewController.h"
#import <SVProgressHUD.h>

@interface PhoneNumberViewController ()
@property (weak, nonatomic) IBOutlet UILabel *lblHeaderTitle;
@property (weak, nonatomic) IBOutlet UILabel *lblCommentPleaseEnter;
@property (weak, nonatomic) IBOutlet UIView *viewForPhoneNumber;
@property (weak, nonatomic) IBOutlet UITextField *tfPhoneNumber;
@property (weak, nonatomic) IBOutlet UIButton *btnDone;
@property (weak, nonatomic) IBOutlet UIButton *btnBack;

@end

@implementation PhoneNumberViewController
- (IBAction)onDone:(id)sender {
    [self processFieldEntries];
}

- (void)viewDidLoad {
    [super viewDidLoad];
    // Do any additional setup after loading the view.
    
    UITapGestureRecognizer *tapGestureRecognizer = [[UITapGestureRecognizer alloc] initWithTarget:self action:@selector(dismissKeyboard)];
    
    tapGestureRecognizer.cancelsTouchesInView = NO;
    
    [self.view addGestureRecognizer:tapGestureRecognizer];
    
    self.viewForPhoneNumber.layer.cornerRadius = 5;
    self.viewForPhoneNumber.layer.masksToBounds = YES;
    self.viewForPhoneNumber.layer.borderWidth = 1;
    self.viewForPhoneNumber.layer.borderColor = [UIColor blackColor].CGColor;
    
    self.tfPhoneNumber.delegate = self;
    
    [self.lblHeaderTitle setText:LocalizedString(@"header_title_phone_number")];
    [self.lblCommentPleaseEnter setText:LocalizedString(@"comment_phone_number")];
    [self.tfPhoneNumber setPlaceholder:LocalizedString(@"hint_phone_number")];
    [self.btnDone setTitle:LocalizedString(@"title_done") forState:UIControlStateNormal];
    [self.btnBack setTitle:LocalizedString(@"title_back") forState:UIControlStateNormal];
}

- (void)processFieldEntries {
    NSString *strPhoneNumber = self.tfPhoneNumber.text;
    
    if(strPhoneNumber.length > 8 && strPhoneNumber.length < 11) {
        if(self.fromMode == fromSignup){
            [self performSegueWithIdentifier:SEGUE_REGISTER_FROM_NUMBER sender:self];
        }else{
            [self sendPasswordWithUsername:strPhoneNumber];
        }
    }else{
        [SVProgressHUD showErrorWithStatus:@"Please input your valid phone number!"];
    }
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

- (void) sendPasswordWithUsername:(NSString *)strUsername{
    [SVProgressHUD showWithStatus:@"Processing..." maskType:SVProgressHUDMaskTypeGradient];
    
    PFQuery *queryUser = [PFUser query];
    
    [queryUser whereKey:pKeyUsername equalTo:strUsername];
    
    [queryUser findObjectsInBackgroundWithBlock:^(NSArray *objects, NSError *error) {
        if(error != nil){
            [SVProgressHUD showErrorWithStatus:@"Your phone number is not registerd, please try again"];
        }else{
            PFUser *pfUser = [objects firstObject];
            
            NSString *strFullName = pfUser[pKeyFullName];
            NSString *strPSW      = pfUser[pKeyPSW];
            
            NSString *strUrl = [NSString stringWithFormat:@"%@?mode=email&kind=password&email=%@&name=%@&password=%@", SERVER_URL, pfUser.email, strFullName, strPSW];
            
            strUrl = [AppDelegate URLEncodeString:strUrl];
            
            NSURLRequest *urlRequest = [NSURLRequest requestWithURL:[NSURL URLWithString:strUrl]];
            
            NSOperationQueue *queue = [[NSOperationQueue alloc] init];
            
            [NSURLConnection sendAsynchronousRequest:urlRequest queue:queue completionHandler:^(NSURLResponse *response, NSData *data, NSError *error){
                
             }];
            
            [SVProgressHUD showSuccessWithStatus:@"Your password has been sent to your email address. please check it."];

        }
    }];
}

#pragma mark Keyboard

- (void)dismissKeyboard {
    [self.view endEditing:YES];
}

#pragma mark UITextFieldDelegate

- (BOOL)textFieldShouldReturn:(UITextField *)textField {
    [self dismissKeyboard];
    [self processFieldEntries];
    return YES;
}

#pragma mark - Navigation

// In a storyboard-based application, you will often want to do a little preparation before navigation
- (void)prepareForSegue:(UIStoryboardSegue *)segue sender:(id)sender {
    // Get the new view controller using [segue destinationViewController].
    // Pass the selected object to the new view controller.
    if([segue.identifier isEqualToString:SEGUE_REGISTER_FROM_NUMBER]){
        RegisterViewController *controller = (RegisterViewController *)segue.destinationViewController;
        controller.strPhoneNumber = self.tfPhoneNumber.text;
    }
}


@end
