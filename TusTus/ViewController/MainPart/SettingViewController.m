//
//  SettingViewController.m
//  TusTus
//
//  Created by User on 4/25/15.
//  Copyright (c) 2015 Philip. All rights reserved.
//

#import "SettingViewController.h"

@interface SettingViewController ()
@property (weak, nonatomic) IBOutlet UILabel *lblTItle;
@property (weak, nonatomic) IBOutlet UILabel *lblComment;
@property (weak, nonatomic) IBOutlet UIButton *btnCheckBox;

@property (nonatomic)       BOOL  isAlertDisabled;
@end

@implementation SettingViewController
- (IBAction)onLeftMenu:(id)sender {
    [self.menuContainerViewController toggleLeftSideMenuCompletion:nil];
}
- (IBAction)onRightMenu:(id)sender {
    [self.menuContainerViewController toggleRightSideMenuCompletion:nil];
}
- (IBAction)onCheckBox:(id)sender {
    self.isAlertDisabled = !self.isAlertDisabled;
    
    [[NSUserDefaults standardUserDefaults] setBool:self.isAlertDisabled forKey:DEFAULT_ALERT_DISABLED];
    [[NSUserDefaults standardUserDefaults] synchronize];
    
    if(self.isAlertDisabled){
        [self.btnCheckBox setImage:[UIImage imageNamed:@"cb_checked.png"] forState:UIControlStateNormal];
    }else{
        [self.btnCheckBox setImage:[UIImage imageNamed:@"cb_unchecked.png"] forState:UIControlStateNormal];
    }
}

- (void)viewDidLoad {
    [super viewDidLoad];
    // Do any additional setup after loading the view.
    
    self.isAlertDisabled = [[NSUserDefaults standardUserDefaults] boolForKey:DEFAULT_ALERT_DISABLED];
    
    [self initUI];
}

- (void) initUI{
    if(self.isAlertDisabled){
        [self.btnCheckBox setImage:[UIImage imageNamed:@"cb_checked.png"] forState:UIControlStateNormal];
    }else{
        [self.btnCheckBox setImage:[UIImage imageNamed:@"cb_unchecked.png"] forState:UIControlStateNormal];
    }
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
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
