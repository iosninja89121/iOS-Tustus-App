//
//  DatePickViewController.m
//  TusTus
//
//  Created by User on 4/14/15.
//  Copyright (c) 2015 Philip. All rights reserved.
//

#import "DatePickViewController.h"
#import "SelectCategoryViewController.h"

@interface DatePickViewController ()
@property (weak, nonatomic) IBOutlet UIButton *btnSelect;
@property (weak, nonatomic) IBOutlet UIButton *btnCancel;
@property (weak, nonatomic) IBOutlet UILabel *lblHeaderTitle;
@property (weak, nonatomic) IBOutlet UIDatePicker *datePicker;

@end

@implementation DatePickViewController
- (IBAction)onSelect:(id)sender {
    [self.superViewCtrl setMovingDate:self.datePicker.date];
    [self dismissViewControllerAnimated:YES completion:nil];
}

- (IBAction)onCancel:(id)sender {
    [self dismissViewControllerAnimated:YES completion:nil];
}

- (void)viewDidLoad {
    [super viewDidLoad];
    // Do any additional setup after loading the view.
    [self.btnSelect setTitle:LocalizedString(@"title_select") forState:UIControlStateNormal];
    [self.btnCancel setTitle:LocalizedString(@"title_cancel") forState:UIControlStateNormal];
    [self.lblHeaderTitle setText:LocalizedString(@"header_title_pick_date_time")];
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
