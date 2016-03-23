//
//  MainViewController.m
//  TusTus
//
//  Created by User on 4/12/15.
//  Copyright (c) 2015 Philip. All rights reserved.
//

#import "SelectCategoryViewController.h"
#import "DatePickViewController.h"
#import "PickupAddressViewController.h"
#import <SVProgressHUD.h>

@interface SelectCategoryViewController ()
@property (weak, nonatomic) IBOutlet UILabel *lblTitle;
@property (weak, nonatomic) IBOutlet UIButton *btnScooter;
@property (weak, nonatomic) IBOutlet UIButton *btnCar;
@property (weak, nonatomic) IBOutlet UIButton *btnMoving;
@property (weak, nonatomic) IBOutlet UILabel *lblWanaSend;
@property (weak, nonatomic) IBOutlet UITextField *tfWanaSend;
@property (weak, nonatomic) IBOutlet UIPickerView *pickerWanaSend;
@property (weak, nonatomic) IBOutlet UILabel *lblUrgency;
@property (weak, nonatomic) IBOutlet UITextField *tfUrgency;
@property (weak, nonatomic) IBOutlet UIButton *btnCheckbox;
@property (weak, nonatomic) IBOutlet UILabel *lblDouble;
@property (weak, nonatomic) IBOutlet UILabel *lblNumberItems;
@property (weak, nonatomic) IBOutlet UITextField *tfNumberItems;
@property (weak, nonatomic) IBOutlet UIPickerView *pickerUrgency;
@property (weak, nonatomic) IBOutlet UIButton *btnNext;
@property (weak, nonatomic) IBOutlet UIView *viewMoving;
@property (weak, nonatomic) IBOutlet UIView *viewScooterCar;
@property (weak, nonatomic) IBOutlet UIButton *btnChoosingDate;
@property (weak, nonatomic) IBOutlet UILabel *lblDate;

@property (nonatomic) NSMutableArray *arrDataWanaSend;
@property (nonatomic) NSMutableArray *arrDataUrgency;
@property (nonatomic) NSMutableArray *arrTemp;

@property (nonatomic) BOOL hiddenPickerWanaSend;
@property (nonatomic) BOOL hiddenPickerUrgency;
@property (nonatomic) BOOL checked;
@property (nonatomic) NSInteger nWanaSend;
@property (nonatomic) NSInteger nUrgency;
@end

@implementation SelectCategoryViewController
- (IBAction)onChoosingDate:(id)sender {
    DatePickViewController *datePickCtrl = (DatePickViewController *)[self.storyboard instantiateViewControllerWithIdentifier:VC_PICK_DATE];
    
    datePickCtrl.superViewCtrl = self;
    
    [self presentViewController:datePickCtrl animated:YES completion:nil];
}

- (IBAction)onCheckBox:(id)sender {
    self.checked = ! self.checked;
    
    if(self.checked){
        [self.btnCheckbox setImage:[UIImage imageNamed:@"cb_checked.png"] forState:UIControlStateNormal];
    }else{
        [self.btnCheckbox setImage:[UIImage imageNamed:@"cb_unchecked.png"] forState:UIControlStateNormal];
    }
    
}

- (IBAction)onCar:(id)sender {
    [self.viewScooterCar setHidden:NO];
    [self.viewMoving setHidden:YES];
    
    [self.tfNumberItems setText:@"1"];
    
    self.checked = NO;
    [self.btnCheckbox setImage:[UIImage imageNamed:@"cb_unchecked.png"] forState:UIControlStateNormal];
    
    [self initButtons];
    
    [self.btnCar setBackgroundImage:[UIImage imageNamed:@"bg_button_glow.png"] forState:UIControlStateNormal];
    
    [DataStore instance].nCategory = CAR_CAT;
    
    self.arrDataWanaSend = [[NSMutableArray alloc] initWithArray:self.arrTemp];
    [self.pickerWanaSend reloadAllComponents];
}

- (IBAction)onScooter:(id)sender {
    [self.viewScooterCar setHidden:NO];
    [self.viewMoving setHidden:YES];
    
    [self.tfNumberItems setText:@"1"];
    
    self.checked = NO;
    [self.btnCheckbox setImage:[UIImage imageNamed:@"cb_unchecked.png"] forState:UIControlStateNormal];
    
    [self initButtons];
    
    [self.btnScooter setBackgroundImage:[UIImage imageNamed:@"bg_button_glow.png"] forState:UIControlStateNormal];
    
    [DataStore instance].nCategory = SCOOTER_CAT;
    
    self.arrDataWanaSend = [[NSMutableArray alloc] initWithObjects:[self.arrTemp objectAtIndex:0], [self.arrTemp objectAtIndex:1], nil];
    [self.pickerWanaSend reloadAllComponents];
}

- (IBAction)onMoving:(id)sender {
    [self.viewScooterCar setHidden:YES];
    [self.viewMoving setHidden:NO];
    
    [self initButtons];
    
    [self.btnMoving setBackgroundImage:[UIImage imageNamed:@"bg_button_glow.png"] forState:UIControlStateNormal];
    
    [DataStore instance].nCategory = MOVING_CAT;
    
    self.lblDate.text = @"";
}

- (IBAction)onNext:(id)sender {
    if([self isHoliday]){
        [SVProgressHUD showErrorWithStatus:LocalizedString(@"dlg_holiday")];
        return;
    }
    
    if([DataStore instance].nCategory == NONE_CAT) return;
    
    if([DataStore instance].nCategory == MOVING_CAT){
        
    }else{
        [DataStore instance].flgDoubleChecked = self.checked;
        [DataStore instance].nWanaSend = self.nWanaSend;
        [DataStore instance].nUrgency = self.nUrgency;
        [DataStore instance].nNumber = [self.tfNumberItems.text integerValue];
    }
    
    PickupAddressViewController *pickupAddressVC = (PickupAddressViewController *)[self.storyboard instantiateViewControllerWithIdentifier:VC_PICKUP_ADDRESS];
    
    [self.navigationController pushViewController:pickupAddressVC animated:YES];
}

- (IBAction)onIncrease:(id)sender {
    if([DataStore instance].nCategory == NONE_CAT){
        [SVProgressHUD showErrorWithStatus:@"Please select the category first of all"];
        return;
    }
    
    int nVal = [self.tfNumberItems.text intValue] + 1;
    self.tfNumberItems.text = @(nVal).stringValue;
}

- (IBAction)onDecrease:(id)sender {
    if([DataStore instance].nCategory == NONE_CAT){
        [SVProgressHUD showErrorWithStatus:@"Please select the category first of all"];
        return;
    }
    
    int nVal = [self.tfNumberItems.text intValue] - 1;
    
    if(nVal < 0) return;
    
    self.tfNumberItems.text = @(nVal).stringValue;
}

- (IBAction)onLeftMenu:(id)sender {
    [self.menuContainerViewController toggleLeftSideMenuCompletion:nil];
}

- (IBAction)onRightMenu:(id)sender {
    [self.menuContainerViewController toggleRightSideMenuCompletion:nil];
}

- (void) initButtons{
    [self.btnCar setBackgroundImage:[UIImage imageNamed:@"bg_button_red.png"] forState:UIControlStateNormal];
    [self.btnScooter setBackgroundImage:[UIImage imageNamed:@"bg_button_red.png"] forState:UIControlStateNormal];
    [self.btnMoving setBackgroundImage:[UIImage imageNamed:@"bg_button_red.png"] forState:UIControlStateNormal];
}

- (void) getCurrentTime{
    NSURL *url = [NSURL URLWithString:SERVER_DATE_TIME_URL];
    
    NSError * error = nil;
    NSData* data = [NSData dataWithContentsOfURL:url options:NSDataReadingMappedIfSafe error:&error];
    
    NSString *strResponse = [[NSString alloc] initWithData:data encoding:NSNonLossyASCIIStringEncoding];
    
    if(error != nil)
    {
        [SVProgressHUD showErrorWithStatus:@"Cannot access the server"];
        return;
    }
    
    NSArray *arrData = [strResponse componentsSeparatedByString:@":"];
    
    [DataStore instance].nCurYear       = [[arrData objectAtIndex:0] integerValue];
    [DataStore instance].nCurMonth      = [[arrData objectAtIndex:1] integerValue];
    [DataStore instance].nCurDay        = [[arrData objectAtIndex:2] integerValue];
    [DataStore instance].nCurHour       = [[arrData objectAtIndex:3] integerValue];
    [DataStore instance].nCurMinute     = [[arrData objectAtIndex:4] integerValue];
    [DataStore instance].nCurDayofWeek  = [[arrData objectAtIndex:5] integerValue];
}

- (BOOL) isHoliday{
    
    [self getCurrentTime];
    
    if([DataStore instance].nCurDayofWeek < 5) return NO;
    if([DataStore instance].nCurDayofWeek == 5 && [DataStore instance].nCurHour < 16) return NO;
    if([DataStore instance].nCurDayofWeek == 7 && [DataStore instance].nCurHour > 6)  return NO;
    return YES;
}

- (void)viewDidLoad {
    [super viewDidLoad];
    
    // Do any additional setup after loading the view.
    UITapGestureRecognizer *tapGestureRecognizer = [[UITapGestureRecognizer alloc] initWithTarget:self action:@selector(dismissPickerView)];
    
    tapGestureRecognizer.cancelsTouchesInView = NO;
    
    [self.view addGestureRecognizer:tapGestureRecognizer];
    
    [[NSNotificationCenter defaultCenter] addObserver:self
                                             selector:@selector(didUpdateBookingData:)
                                                 name:N_InitSelectCategory
                                               object:nil];
    
    self.arrTemp = [[NSMutableArray alloc] initWithArray:LocalizedSimpleArrayData(arrKeyWanaSend)];
    self.arrDataWanaSend = [[NSMutableArray alloc] initWithObjects:[self.arrTemp objectAtIndex:0], [self.arrTemp objectAtIndex:1], nil];
    self.arrDataUrgency = [[NSMutableArray alloc] initWithArray:LocalizedSimpleArrayData(arrKeyUrgency)];
    
    [self initUI];
}

- (void) initUI{
    self.lblTitle.text = LocalizedString(@"header_title_select_service_category");
    [self.btnCar setTitle:LocalizedString(@"title_car") forState:UIControlStateNormal];
    [self.btnScooter setTitle:LocalizedString(@"title_scooter") forState:UIControlStateNormal];
    [self.btnMoving setTitle:LocalizedString(@"title_moving") forState:UIControlStateNormal];
    [self.btnChoosingDate setTitle:LocalizedString(@"title_choosing_date") forState:UIControlStateNormal];
    
    self.lblWanaSend.text = LocalizedString(@"comment_want_send");
    self.lblUrgency.text = LocalizedString(@"comment_urgency");
    self.lblDouble.text = LocalizedString(@"comment_double");
    self.lblNumberItems.text = LocalizedString(@"comment_number_items");
    [self.btnNext setTitle:LocalizedString(@"title_next") forState:UIControlStateNormal];
    
    self.tfWanaSend.text = [self.arrDataWanaSend objectAtIndex:0];
    self.tfUrgency.text = [self.arrDataUrgency objectAtIndex:0];
    
    self.tfWanaSend.delegate = self;
    self.tfUrgency.delegate = self;
    self.tfNumberItems.delegate = self;
    
    self.pickerWanaSend.delegate = self;
    self.pickerWanaSend.dataSource = self;
    
    self.pickerUrgency.delegate = self;
    self.pickerUrgency.dataSource = self;
    
    [self.pickerWanaSend setHidden:YES];
    [self.pickerUrgency setHidden:YES];
    
    self.hiddenPickerWanaSend = YES;
    self.hiddenPickerUrgency = YES;
    
    [self.viewScooterCar setHidden:NO];
    [self.viewMoving setHidden:YES];
    
    [self.tfNumberItems setText:@"1"];
    
    [DataStore instance].nCategory = NONE_CAT;
    
    self.checked = NO;
    [self.btnCheckbox setImage:[UIImage imageNamed:@"cb_unchecked.png"] forState:UIControlStateNormal];
    
    [DataStore instance].nWanaSend = 0;
    [DataStore instance].nWanaSend = 0;
    [DataStore instance].flgDoubleChecked = NO;
    
    self.nWanaSend = 0;
    self.nUrgency = 0;
}

- (void) didUpdateBookingData:(NSNotification *)notification{
    self.tfWanaSend.text = [self.arrDataWanaSend objectAtIndex:0];
    self.tfUrgency.text = [self.arrDataUrgency objectAtIndex:0];
    
    [self.tfNumberItems setText:@"1"];
    
    [DataStore instance].nCategory = NONE_CAT;
    
    self.checked = NO;
    [self.btnCheckbox setImage:[UIImage imageNamed:@"cb_unchecked.png"] forState:UIControlStateNormal];
    
    [DataStore instance].nWanaSend = 0;
    [DataStore instance].nWanaSend = 0;
    [DataStore instance].flgDoubleChecked = NO;

    self.nWanaSend = 0;
    self.nUrgency = 0;
    
    [self initButtons];
}

- (void) setMovingDate:(NSDate *) dateMoving{
    
    NSDateFormatter *dateFormatter;
    
    dateFormatter = [[NSDateFormatter alloc] init];
    [dateFormatter setDateFormat:@"dd MMM yyyy"];
    
    self.lblDate.text = [dateFormatter stringFromDate:dateMoving];
    [DataStore instance].strMovingDate = [dateFormatter stringFromDate:dateMoving];
}

- (void) dismissPickerView{
    if(!self.hiddenPickerWanaSend){
        self.hiddenPickerWanaSend = YES;
        
        [self.pickerWanaSend  setHidden:YES];
    }
    
    if(!self.hiddenPickerUrgency){
        
        self.hiddenPickerUrgency = YES;
        
        [self.pickerUrgency  setHidden:YES];
    }
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

#pragma mark UITextFieldDelegate
- (BOOL)textFieldShouldBeginEditing:(UITextField *)textField{
    if(textField == self.tfWanaSend && self.hiddenPickerWanaSend){
        
        if(!self.hiddenPickerUrgency){
            
            self.hiddenPickerUrgency = YES;
            [self.pickerUrgency  setHidden:YES];
        }
        
        self.hiddenPickerWanaSend = NO;
        
        [self.pickerWanaSend  setHidden:NO];
    }
    
    if(textField == self.tfUrgency && self.hiddenPickerUrgency){

        if(!self.hiddenPickerWanaSend){
            
            self.hiddenPickerWanaSend = YES;
            [self.pickerWanaSend  setHidden:YES];
        }
        
        self.hiddenPickerUrgency = NO;
        
        [self.pickerUrgency  setHidden:NO];
    }
    
    return NO;
}

#pragma mark - Picker View Data source
-(NSInteger)numberOfComponentsInPickerView:(UIPickerView *)pickerView{
    return 1;
}
-(NSInteger)pickerView:(UIPickerView *)pickerView numberOfRowsInComponent:(NSInteger)component{
    if(pickerView == self.pickerWanaSend) return [self.arrDataWanaSend count];
    return [self.arrDataUrgency count];
}

#pragma mark- Picker View Delegate

-(void)pickerView:(UIPickerView *)pickerView didSelectRow:(NSInteger)row inComponent:(NSInteger)component{
    if(pickerView == self.pickerWanaSend){
        self.nWanaSend = row;
        [self.tfWanaSend setText:[self.arrDataWanaSend objectAtIndex:row]];
    }
    else{
        self.nUrgency = row;
        [self.tfUrgency setText:[self.arrDataUrgency objectAtIndex:row]];
    }
}

- (NSString *)pickerView:(UIPickerView *)pickerView titleForRow:(NSInteger)row forComponent:(NSInteger)component{
    if(pickerView == self.pickerWanaSend) return [self.arrDataWanaSend objectAtIndex:row];
    return [self.arrDataUrgency objectAtIndex:row];
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
