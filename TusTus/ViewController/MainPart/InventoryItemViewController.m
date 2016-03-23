//
//  InventoryItemViewController.m
//  TusTus
//
//  Created by User on 4/25/15.
//  Copyright (c) 2015 Philip. All rights reserved.
//

#import "InventoryItemViewController.h"
#import <SVProgressHUD.h>

@interface InventoryItemViewController ()
@property (weak, nonatomic) IBOutlet UITableView *tblInventory;
@property (weak, nonatomic) IBOutlet UILabel *lblTitle;
@property (weak, nonatomic) IBOutlet UIButton *btnRewind;
@property (weak, nonatomic) IBOutlet UIButton *btnNext;

@property (nonatomic, strong) NSMutableArray *arrItemData;
@property (nonatomic, strong) NSMutableArray *arrNumber;

@end

@implementation InventoryItemViewController
- (IBAction)onLeftMenu:(id)sender {
    [self.menuContainerViewController toggleLeftSideMenuCompletion:nil];
}

- (IBAction)onRightMenu:(id)sender {
    [self.menuContainerViewController toggleRightSideMenuCompletion:nil];
}

- (IBAction)onRewind:(id)sender {
    [self.navigationController popViewControllerAnimated:YES];
}
- (IBAction)onNext:(id)sender {
    int i = 0;
    
    for(i = 0; i < self.arrItemData.count; i ++){
        NSString *strNumber = [self.arrNumber objectAtIndex:i];
        
        if([strNumber isEqualToString:@"0"] != NSOrderedSame) break;
    }
    
    if(i == self.arrItemData.count){
        [SVProgressHUD showErrorWithStatus:@"Please select the at least one item"];
        return;
    }
    
    [DataStore instance].arrInventoryNumber = [[NSMutableArray alloc] initWithArray:self.arrNumber];
    
    UIViewController *totalVC = [self.storyboard instantiateViewControllerWithIdentifier:VC_TOTAL_PAGE];
    [self.navigationController pushViewController:totalVC animated:YES];
}

- (void) onDec:(id) sender{
    UIView *view = (UIView *)sender;
    
    NSInteger nIdx = [view.accessibilityIdentifier integerValue];
    
    UIView *superView = [view superview];
    
    UITextField *tfNumber = (UITextField *)[superView viewWithTag:2];
    
    NSInteger nNumber = [tfNumber.text integerValue];
    
    if(nNumber == 0) return;
  
    nNumber --;
    
    tfNumber.text = @(nNumber).stringValue;
    
    [self.arrNumber removeObjectAtIndex:nIdx];
    
    [self.arrNumber insertObject:@(nNumber).stringValue atIndex:nIdx];
}

- (void) onInc:(id) sender{
    UIView *view = (UIView *)sender;
    
    NSInteger nIdx = [view.accessibilityIdentifier integerValue];
    
    UIView *superView = [view superview];
    
    UITextField *tfNumber = (UITextField *)[superView viewWithTag:2];
    
    NSInteger nNumber = [tfNumber.text integerValue];
    
    nNumber ++;
    
    tfNumber.text = @(nNumber).stringValue;
    
    [self.arrNumber removeObjectAtIndex:nIdx];
    
    [self.arrNumber insertObject:@(nNumber).stringValue atIndex:nIdx];
}

- (void)viewDidLoad {
    [super viewDidLoad];
    // Do any additional setup after loading the view.
    
    self.arrItemData = [[NSMutableArray alloc] initWithArray:LocalizedSimpleArrayData(arrKeyInventory)];
    
    self.tblInventory.dataSource = self;
    self.tblInventory.delegate = self;
    
    self.arrNumber = [[NSMutableArray alloc] init];
    
    for(int i = 0; i < self.arrItemData.count; i ++)
        [self.arrNumber addObject:@"0"];
    
    [self initUI];
}

- (void) initUI{
    [self.lblTitle setText:LocalizedString(@"header_title_inventory_items")];
    [self.btnRewind setTitle:LocalizedString(@"title_rewind") forState:UIControlStateNormal];
    [self.btnNext setTitle:LocalizedString(@"title_next") forState:UIControlStateNormal];
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

#pragma mark - Table view data source

- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView
{
    return 1;
}

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section {
    
    return self.arrItemData.count;
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath {
    UITableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:CELL_INVENTORY_ITEM forIndexPath:indexPath];
    
    UIButton    *btnDec   = (UIButton *)[cell.contentView viewWithTag:1];
    UITextField *tfNumber = (UITextField *)[cell.contentView viewWithTag:2];
    UIButton    *btnInc   = (UIButton *)[cell.contentView viewWithTag:3];
    UILabel     *lblTitle = (UILabel *)[cell.contentView viewWithTag:4];
    
    NSDictionary *dic = [self.arrItemData objectAtIndex:indexPath.row];
    NSString *strTitle = [dic objectForKey:@"name"];
    
    tfNumber.text = [self.arrNumber objectAtIndex:indexPath.row];
    lblTitle.text = strTitle;
    
    btnDec.accessibilityIdentifier = @(indexPath.row).stringValue;
    btnInc.accessibilityIdentifier = @(indexPath.row).stringValue;
    
    [btnDec addTarget:self action:@selector(onDec:) forControlEvents:UIControlEventTouchUpInside];
    [btnInc addTarget:self action:@selector(onInc:) forControlEvents:UIControlEventTouchUpInside];
    return cell;
    
}

-(CGFloat)tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath{
    
    return 60;
}

- (NSIndexPath *)tableView:(UITableView *)tableView willSelectRowAtIndexPath:(NSIndexPath *)indexPath{
    
    return nil;
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
