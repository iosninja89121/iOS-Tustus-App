//
//  SearchAddressViewController.m
//  TusTus
//
//  Created by User on 4/11/15.
//  Copyright (c) 2015 Philip. All rights reserved.
//

#import "SearchAddressViewController.h"
#import <SVProgressHUD.h>

@interface SearchAddressViewController ()
@property (weak, nonatomic) IBOutlet UILabel *lblHeaderTitle;
@property (weak, nonatomic) IBOutlet UIButton *btnCancel;
@property (weak, nonatomic) IBOutlet UIView *viewForSearch;
@property (weak, nonatomic) IBOutlet UITextField *tfSearch;
@property (weak, nonatomic) IBOutlet UITableView *tblSearchResult;
@property (strong) NSMutableArray *arrData;

@end

@implementation SearchAddressViewController
- (IBAction)onCancel:(id)sender {
    [self dismissViewControllerAnimated:YES completion:nil];
}

- (void)viewDidLoad {
    [super viewDidLoad];
    // Do any additional setup after loading the view.
    self.arrData = [[NSMutableArray alloc] initWithCapacity:0];
    self.tblSearchResult.delegate = self;
    self.tblSearchResult.dataSource = self;
    
    self.viewForSearch.layer.cornerRadius = 5;
    self.viewForSearch.layer.masksToBounds = YES;
    self.viewForSearch.layer.borderWidth = 1;
    self.viewForSearch.layer.borderColor = [UIColor blackColor].CGColor;
    
    [self.lblHeaderTitle setText:LocalizedString(@"header_title_search_address")];
    [self.btnCancel setTitle:LocalizedString(@"title_cancel") forState:UIControlStateNormal];
    [self.tfSearch setPlaceholder:LocalizedString(@"hint_type_address_here")];
    
    UITapGestureRecognizer *tapGestureRecognizer = [[UITapGestureRecognizer alloc] initWithTarget:self action:@selector(dismissKeyboard)];

    tapGestureRecognizer.cancelsTouchesInView = NO;
    [self.view addGestureRecognizer:tapGestureRecognizer];
    
    self.tfSearch.delegate = self;
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

#pragma mark Keyboard

- (BOOL)textField:(UITextField *)textField shouldChangeCharactersInRange:(NSRange)range replacementString:(NSString *)string{
    NSString *strSearch = [NSString stringWithFormat:@"%@%@", textField.text, string];
    
    [self searchAddress:strSearch];
    
    return YES;
}
- (BOOL)textFieldShouldReturn:(UITextField *)textField{
    [self dismissKeyboard];
//    [self searchAddress:textField.text];
    return YES;
}



- (void) searchAddress:(NSString *) strSearch{
    // Obtain browser key from https://code.google.com/apis/console
    NSString *strKey = @"key=AIzaSyBX5mIqDve07low-_YW1895o7aH5kXWNXA";
    NSString *strInput = [NSString stringWithFormat:@"input=%@", strSearch];
    
    // place type to be searched
    NSString *strTypes = @"types=geocode";
    
    // Sensor enabled
    NSString *strSensor = @"sensor=false";
    
    // Output format
    NSString *strOutput = @"json";
    
    // Building the url to the web service
    NSString *strUrl = [NSString stringWithFormat:@"https://maps.googleapis.com/maps/api/place/autocomplete/%@?%@&%@&%@&%@", strOutput, strInput, strTypes, strSensor, strKey];
    
    strUrl = [AppDelegate URLEncodeString:strUrl];
    
    // The url to make the request to
    NSURL *urlAddress = [NSURL URLWithString:strUrl];
    
    //The actual request
    ASIHTTPRequest *request = [ASIHTTPRequest requestWithURL:urlAddress];
    
    // Becoming the request delegate
    //To get callbacks like requestFinished: or requestFailed:
    [request setDelegate:self];
    
    // Fire off the request
    [request startAsynchronous];
}

#pragma mark ASIHTTPRequest
- (void)requestFinished:(ASIHTTPRequest *)request{
    NSString *theJSON = [request responseString];
    
    NSData *jsonData = [theJSON dataUsingEncoding:NSUTF8StringEncoding];
    NSError *e;
    NSDictionary *jsonDictionary = [NSJSONSerialization JSONObjectWithData:jsonData options:0 error:&e];
    
    NSMutableArray *arrAddress = [jsonDictionary valueForKey:@"predictions"];

    [self.arrData removeAllObjects];
    
    for(int i = 0; i < arrAddress.count; i ++){
        NSDictionary *itemDic = [arrAddress objectAtIndex:i];
        
        NSString *title  = [itemDic valueForKey:@"description"];
        [self.arrData addObject:title];
    }
    
    [self.tblSearchResult reloadData];
}

#pragma mark Keyboard

- (void)dismissKeyboard {
    [self.view endEditing:YES];
}

#pragma mark - Table view data source

- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView {
    // Return the number of sections.
    return 1;
}

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section {
    // Return the number of rows in the section.
    
    return self.arrData.count;
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath {
    UITableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:CELL_SEARCH_RESULT forIndexPath:indexPath];
    
    cell.textLabel.text = [self.arrData objectAtIndex:indexPath.row];
    
    return cell;
}

- (NSIndexPath *)tableView:(UITableView *)tableView willSelectRowAtIndexPath:(NSIndexPath *)indexPath{
    NSString *strAddress = [self.arrData objectAtIndex:indexPath.row];
    
    if (self.fromMode == fromPickup && ![[DataStore instance].arrCity containsObject:strAddress] && [DataStore instance].nCategory != MOVING_CAT) {
        
        [SVProgressHUD showErrorWithStatus:@"This area is not currently supported"];
        return nil;
    }
    
    [DataStore instance].strSearchAddress = [self.arrData objectAtIndex:indexPath.row];
    
    [self dismissViewControllerAnimated:YES completion:^{
     
        NSString *strNotification = @"";
        
        if(self.fromMode == fromRegister)    strNotification = N_SearchAddressSelectedForRegister;
        if(self.fromMode == fromPickup)      strNotification = N_SearchAddressSelectedForPickup;
        if(self.fromMode == fromDropOff)     strNotification = N_SearchAddressSelectedForDropOff;
        if(self.fromMode == fromEditContact) strNotification = N_SearchAddressSelectedForEditContact;
            
        [[NSNotificationCenter defaultCenter] postNotificationName:strNotification object:nil];
    }];
    
    return indexPath;
}

-(CGFloat)tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath{
    return 40.0;
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
