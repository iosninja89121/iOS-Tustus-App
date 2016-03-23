//
//  TotalPageViewController.m
//  TusTus
//
//  Created by User on 4/24/15.
//  Copyright (c) 2015 Philip. All rights reserved.
//

#import "TotalPageViewController.h"
#import <SVProgressHUD.h>

// Set the environment:
// - For live charges, use PayPalEnvironmentProduction (default).
// - To use the PayPal sandbox, use PayPalEnvironmentSandbox.
// - For testing, use PayPalEnvironmentNoNetwork.
#define kPayPalEnvironment PayPalEnvironmentProduction


@interface TotalPageViewController ()
@property (weak, nonatomic) IBOutlet UITableView *tblTotal;

@property (nonatomic, strong) NSMutableArray *arrDataWanaSend;
@property (nonatomic, strong) NSMutableArray *arrDataUrgency;
@property (nonatomic, strong) NSMutableArray *arrInventoryItem;
@property (nonatomic, strong) NSMutableArray *arrCurrentInventoryList;

@property (nonatomic)  NSInteger price_mode;
@property (nonatomic)  NSInteger flat_price;
@property (nonatomic)  NSInteger minPrice;
@property (nonatomic)  NSInteger minDistance;
@property (nonatomic)  NSInteger perKmPrice;
@property (nonatomic)  NSInteger nRateDay;
@property (nonatomic)  NSInteger nRateEvening;
@property (nonatomic)  NSInteger nRateNight;
@property (nonatomic)  NSInteger nHourDayStart;
@property (nonatomic)  NSInteger nHourDayEnd;
@property (nonatomic)  NSInteger nHourEveningStart;
@property (nonatomic)  NSInteger nHourEveningEnd;
@property (nonatomic)  NSInteger nHourNightStart;
@property (nonatomic)  NSInteger nHourNightEnd;

@property(nonatomic, strong, readwrite) PayPalConfiguration *payPalConfig;


@end

@implementation TotalPageViewController
- (IBAction)onLeftMenu:(id)sender {
    [self.menuContainerViewController toggleLeftSideMenuCompletion:nil];
}

- (IBAction)onRightMenu:(id)sender {
    [self.menuContainerViewController toggleRightSideMenuCompletion:nil];
}

- (void)viewWillAppear:(BOOL)animated {
    [super viewWillAppear:YES];
    // Preconnect to PayPal early
    [PayPalMobile preconnectWithEnvironment:kPayPalEnvironment];
}

- (void)viewDidLoad {
    [super viewDidLoad];
    // Do any additional setup after loading the view.
    
    // Set up payPalConfig
    _payPalConfig = [[PayPalConfiguration alloc] init];
    _payPalConfig.acceptCreditCards = YES;
    _payPalConfig.merchantName = @"Awesome Shirts, Inc.";
    _payPalConfig.merchantPrivacyPolicyURL = [NSURL URLWithString:@"https://www.paypal.com/webapps/mpp/ua/privacy-full"];
    _payPalConfig.merchantUserAgreementURL = [NSURL URLWithString:@"https://www.paypal.com/webapps/mpp/ua/useragreement-full"];
    
    self.tblTotal.dataSource = self;
    self.tblTotal.delegate = self;
    
    self.arrDataWanaSend = [[NSMutableArray alloc] initWithArray:LocalizedSimpleArrayData(arrKeyWanaSend)];
    self.arrDataUrgency = [[NSMutableArray alloc] initWithArray:LocalizedSimpleArrayData(arrKeyUrgency)];
    self.arrInventoryItem = [[NSMutableArray alloc] initWithArray:LocalizedSimpleArrayData(arrKeyInventory)];
    
    if([DataStore instance].nCategory == MOVING_CAT) [self loadData];
    
    [self initPriceParameter];
    
    
    
    [DataStore instance].nPrice = [self calculatePriceWitDistance:[DataStore instance].dblDistance];
    
    NSLog(@"price-%ld", (long)[DataStore instance].nPrice);
}

- (NSInteger) calculatePriceWitDistance:(double) nDistance{
    if(self.price_mode == 1){
        return self.flat_price;
    }
    
    double basicPrice = self.minPrice;
    double distance = nDistance - self.minDistance;
    
    if(distance < 0) distance = 0;
    
    basicPrice += distance * self.perKmPrice;
    
    int totalPercent = 0;
    
    NSInteger nCurrentTime = [DataStore instance].nCurHour * 60 + [DataStore instance].nCurMinute;
    
    if((self.nHourDayStart < self.nHourDayEnd) && (self.nHourDayStart <= nCurrentTime) && (nCurrentTime < self.nHourDayEnd)){
        totalPercent += self.nRateDay;
    }else if((self.nHourDayStart > self.nHourDayEnd) && ((self.nHourDayStart <= nCurrentTime) || (nCurrentTime < self.nHourDayEnd))){
        totalPercent += self.nRateDay;
    }else if((self.nHourEveningStart < self.nHourEveningEnd) && (self.nHourEveningStart <= nCurrentTime) && (nCurrentTime < self.nHourEveningEnd)){
        totalPercent += self.nRateEvening;
    }else if((self.nHourEveningStart > self.nHourEveningEnd) && ((self.nHourEveningStart <= nCurrentTime) || (nCurrentTime < self.nHourEveningEnd))){
        totalPercent += self.nRateEvening;
    }else if((self.nHourNightStart < self.nHourNightEnd) && (self.nHourNightStart <= nCurrentTime) && (nCurrentTime < self.nHourNightEnd)){
        totalPercent += self.nRateNight;
    }else if((self.nHourNightStart > self.nHourNightEnd) && ((self.nHourNightStart <= nCurrentTime) || (nCurrentTime < self.nHourNightEnd))){
        totalPercent += self.nRateNight;
    }
    
    if([DataStore instance].nCurHour >= 16 && [DataStore instance].nCurHour < 20) totalPercent += nEveningRate;
    if([DataStore instance].nCurHour >= 20 && [DataStore instance].nCurHour < 7) totalPercent += nNightRate;
    if([DataStore instance].nUrgency == 1) totalPercent += nUrgencyRate;
    if([DataStore instance].flgDoubleChecked) totalPercent += nDoubleRate;
    
    basicPrice += basicPrice * totalPercent / 100.f;
    
    if([DataStore instance].nCategory != MOVING_CAT){
        if([DataStore instance].nWanaSend == 1) basicPrice += [DataStore instance].nNumber * nPriceForA4;
        if([DataStore instance].nWanaSend == 2) basicPrice += [DataStore instance].nNumber * nPriceForBOX50;
        if([DataStore instance].nWanaSend == 3) basicPrice += [DataStore instance].nNumber * nPriceForBOX150;
    }else{
        double nSum = 0;
        int nTotalCategory = 0;
        
        for(int i = 0; i < self.arrCurrentInventoryList.count; i ++){
            NSMutableDictionary *dicItem = [self.arrCurrentInventoryList objectAtIndex:i];
            
            NSString *strNumber = [dicItem objectForKey:@"number"];
            NSString *strPrice  = [dicItem objectForKey:@"price"];
            
            NSInteger nNumber = [strNumber integerValue];
            NSInteger nPrice  = [strPrice integerValue];
            
            if(nNumber == 0) continue;
            
            nTotalCategory ++;
            
            double itemTotalPrice = nPrice * nNumber;
            
            if(nNumber > 100) nNumber = 100;
            
            if(nNumber > 1) itemTotalPrice = itemTotalPrice * (100 - nNumber * 0.5) / 100.f;
            
            nSum  += itemTotalPrice;
        }
        
        if(nTotalCategory > 50) nTotalCategory = 50;
        if(nTotalCategory > 1) nSum = nSum * (100 - nTotalCategory) / 100.f;
        
        NSString *strFloor = [[DataStore instance].addressInfoForPickup.strFloor stringByReplacingOccurrencesOfString:@"[^\\d.]" withString:@""];
        NSInteger nPickupFloor = [strFloor integerValue];
        
        strFloor = [[DataStore instance].addressInfoForDropOff.strFloor stringByReplacingOccurrencesOfString:@"[^\\d.]" withString:@""];
        
        NSInteger nDropOffFloor = [strFloor integerValue];
        NSInteger nTotalPercent = 0;
        
        if([DataStore instance].flgElevatorPickup)  nTotalPercent += nPickupFloor * nElevatorYesRate;  else nTotalPercent += nPickupFloor * nElevatorNoRate;
        if([DataStore instance].flgElevatorDropoff) nTotalPercent += nDropOffFloor * nElevatorYesRate; else nTotalPercent += nDropOffFloor * nElevatorNoRate;
        
        nSum += nSum * nTotalPercent / 100.f;
        
        basicPrice += nSum;
    }
    
    basicPrice = basicPrice * (100 + nTax) / 100;
    basicPrice = ceil(basicPrice);
    
    return (NSInteger)basicPrice;
}

- (void) loadData{
    self.arrCurrentInventoryList = [[NSMutableArray alloc] init];
    
    for(int i = 0; i < [DataStore instance].arrInventoryNumber.count; i ++){
        NSString *strNumber = [[DataStore instance].arrInventoryNumber objectAtIndex:i];
        
        if([strNumber isEqualToString:@"0"]) continue;
        
        NSDictionary *dicItem = [self.arrInventoryItem objectAtIndex:i];
        
        NSString *strTitle = [dicItem objectForKey:@"name"];
        NSNumber *nsPrice   = [dicItem objectForKey:@"price"];
        NSString *strPrice  = [nsPrice stringValue];
        
        NSMutableDictionary *dicNewItem = [[NSMutableDictionary alloc] init];
        
        [dicNewItem setObject:strTitle  forKey:@"name"];
        [dicNewItem setObject:strNumber forKey:@"number"];
        [dicNewItem setObject:strPrice forKey:@"price"];
        
        [self.arrCurrentInventoryList addObject:dicNewItem];
    }
    
    [self.tblTotal reloadData];
}

- (NSInteger)convertToMinutes:(double) dblVal{
    int nVal = (int)dblVal;
    NSString *strVal = [NSString stringWithFormat:@"%04d", nVal];
    NSString *strHour = [strVal substringWithRange:NSMakeRange(0, 2)];
    NSString *strMinute = [strVal substringWithRange:NSMakeRange(2, 2)];
    NSInteger nHour = [strHour integerValue];
    NSInteger nMinute = [strMinute integerValue];
    
    nHour = nHour % 24;
    nMinute = nMinute % 60;
    
    return nHour * 60 + nMinute;
}

- (void) initPriceParameter{
    double dblPerKmPriceForScooter  = nPerKmPriceForScooter;
    double dblPerKmPriceForCar      = nPerKmPriceForCar;
    double dblPerKmPriceForTruck    = nPerKmPriceForTruck;
    double dblMinPriceForScooter    = nMinPriceForScooter;
    double dblMinPriceForCar        = nMinPriceForCar;
    double dblMinPriceForTruck      = nMinPriceForTruck;
    double dblMinDistanceForScooter = nMinDistanceForScooter;
    double dblMinDistanceForCar     = nMinDistanceForCar;
    double dblMinDistanceForTruck   = nMinDistanceForTruck;
    
    PFUser *currentUser = [PFUser currentUser];
    
    dblPerKmPriceForScooter  = [(NSNumber *)currentUser[pKeyPriceForScooter] doubleValue];
    dblPerKmPriceForCar      = [(NSNumber *)currentUser[pKeyPriceForCar] doubleValue];
    dblPerKmPriceForTruck    = [(NSNumber *)currentUser[pKeyPriceForTruck] doubleValue];
    dblMinPriceForScooter    = [(NSNumber *)currentUser[pKeyMinPriceForScooter] doubleValue];
    dblMinPriceForCar        = [(NSNumber *)currentUser[pKeyMinPriceForCar] doubleValue];
    dblMinPriceForTruck      = [(NSNumber *)currentUser[pKeyMinPriceForTruck] doubleValue];
    dblMinDistanceForScooter = [(NSNumber *)currentUser[pKeyMinDistanceForScooter] doubleValue];
    dblMinDistanceForCar     = [(NSNumber *)currentUser[pKeyMinDistanceForCar] doubleValue];
    dblMinDistanceForTruck   = [(NSNumber *)currentUser[pKeyMinDistanceForTruck] doubleValue];
    self.price_mode          = [(NSNumber *)currentUser[pKeyModePrice] integerValue];
    self.flat_price          = [(NSNumber *)currentUser[pKeyFlatPrice] integerValue];
    
    if([DataStore instance].nCategory == SCOOTER_CAT){
        self.minPrice    = dblMinPriceForScooter;
        self.minDistance = dblMinDistanceForScooter;
        self.perKmPrice  = dblPerKmPriceForScooter;
    }else if([DataStore instance].nCategory == CAR_CAT){
        self.minPrice    = dblMinPriceForCar;
        self.minDistance = dblMinDistanceForCar;
        self.perKmPrice  = dblPerKmPriceForCar;
    }else{
        self.minPrice    = dblMinPriceForTruck;
        self.minDistance = dblMinDistanceForTruck;
        self.perKmPrice  = dblPerKmPriceForTruck;
        
        [DataStore instance].flgDoubleChecked = NO;
        [DataStore instance].nUrgency = 0;
    }
    
    self.nRateDay     = [(NSNumber *)currentUser[pKeyRateDay] integerValue];
    self.nRateEvening = [(NSNumber *)currentUser[pKeyRateEvening] integerValue];
    self.nRateNight   = [(NSNumber *)currentUser[pKeyRateNight] integerValue];
    
    self.nHourDayStart     = [self convertToMinutes:[(NSNumber *)currentUser[pKeyHourDayStart] doubleValue]];
    self.nHourDayEnd       = [self convertToMinutes:[(NSNumber *)currentUser[pKeyHourDayEnd] doubleValue]];
    self.nHourEveningStart = [self convertToMinutes:[(NSNumber *)currentUser[pKeyHourEveningStart] doubleValue]];
    self.nHourEveningEnd   = [self convertToMinutes:[(NSNumber *)currentUser[pKeyHourEveningEnd] doubleValue]];
    self.nHourNightStart   = [self convertToMinutes:[(NSNumber *)currentUser[pKeyHourNightStart] doubleValue]];
    self.nHourNightEnd     = [self convertToMinutes:[(NSNumber *)currentUser[pKeyHourNightEnd] doubleValue]];
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

- (void) onOrder{
    PFUser *currentUser = [PFUser currentUser];
    
    NSInteger nFreePayment_flag = [(NSNumber *)currentUser[pKeyFreePaymentFlag] integerValue];
    
    if(nFreePayment_flag == 0 || (nFreePayment_flag == 1 && [DataStore instance].nCategory == MOVING_CAT)){
        [self doPay];
    }else{
        [self makeDeliveryOrder];
    }
}

- (void) onRewind{
    [self.navigationController popViewControllerAnimated:YES];
}

- (void) onCancel{
    [[NSNotificationCenter defaultCenter] postNotificationName:N_InitSelectCategory object:nil];
    [self.navigationController popToRootViewControllerAnimated:YES];
}

- (void) doPay{
    
    PayPalPayment *payment = [[PayPalPayment alloc] init];
    payment.amount = [[NSDecimalNumber alloc] initWithUnsignedInteger:[DataStore instance].nPrice];
    payment.currencyCode = @"ILS";
    payment.shortDescription = @"Delivery";
    payment.items = nil;  // if not including multiple items, then leave payment.items as nil
    payment.paymentDetails = nil; // if not including payment details, then leave payment.paymentDetails as nil
    
    if (!payment.processable) {
        // This particular payment will always be processable. If, for
        // example, the amount was negative or the shortDescription was
        // empty, this payment wouldn't be processable, and you'd want
        // to handle that here.
    }
    
    // Update payPalConfig re accepting credit cards.
    
    PayPalPaymentViewController *paymentViewController = [[PayPalPaymentViewController alloc] initWithPayment:payment
                                                                                                configuration:self.payPalConfig
                                                                                                     delegate:self];
    [self presentViewController:paymentViewController animated:YES completion:nil];
}

- (void) sendOrderDocWithInfo:(DeliveryBookingInfo *) bookingInfo{
    NSString *strEmail    = bookingInfo.strCustomerEmail;
    
    NSString *strAmount = @"";
    NSString *strPackageType = @"";
    
    for(int i = 0; i < bookingInfo.arrInventoryAmountList.count; i ++){
        
        NSString *strItem = [bookingInfo.arrInventoryAmountList objectAtIndex:i];
        
        NSArray *arrData = [strItem componentsSeparatedByString:@":"];
        
        NSString *str0 = [[[arrData objectAtIndex:0] componentsSeparatedByCharactersInSet:[[NSCharacterSet decimalDigitCharacterSet] invertedSet]] componentsJoinedByString:@""];
        
        NSInteger idx = [str0 integerValue];
        
        NSString *strTitle = [[self.arrInventoryItem objectAtIndex:idx] objectForKey:@"name"];
        
        NSString *str1 = [[[arrData objectAtIndex:1] componentsSeparatedByCharactersInSet:[[NSCharacterSet decimalDigitCharacterSet] invertedSet]] componentsJoinedByString:@""];
        
        if(i > 0){
            strAmount       = [strAmount stringByAppendingString:@":"];
            strPackageType  = [strPackageType stringByAppendingString:@":"];
        }
        
        strAmount       = [strAmount stringByAppendingString:str1];
        strPackageType  = [strPackageType stringByAppendingString:strTitle];
    }
    
    /*
    
    NSURLComponents *components     = [NSURLComponents componentsWithString:SERVER_URL];
    
    NSURLQueryItem *itemMode            = [NSURLQueryItem queryItemWithName:@"mode"             value:@"email"];
    NSURLQueryItem *itemEmail           = [NSURLQueryItem queryItemWithName:@"email"            value:strEmail];
    NSURLQueryItem *itemKind            = [NSURLQueryItem queryItemWithName:@"kind"             value:@"order_file"];
    NSURLQueryItem *itemCustomerName    = [NSURLQueryItem queryItemWithName:pKeyCustomerName    value:bookingInfo.strCustomerName];
    NSURLQueryItem *itemCustomerAddress = [NSURLQueryItem queryItemWithName:pKeyCustomerAddress value:bookingInfo.strCustomerAddress];
    NSURLQueryItem *itemCustomerPhone   = [NSURLQueryItem queryItemWithName:pKeyCustomerPhone   value:bookingInfo.strCustomerPhone];
    NSURLQueryItem *itemStartAddress    = [NSURLQueryItem queryItemWithName:pKeyStartAddress    value:bookingInfo.strStartAddress];
    NSURLQueryItem *itemEndAddress      = [NSURLQueryItem queryItemWithName:pKeyEndAddress      value:bookingInfo.strEndAddress];
    NSURLQueryItem *itemMovingDate      = [NSURLQueryItem queryItemWithName:pKeyMovingDate      value:[DataStore instance].strMovingDate];
    NSURLQueryItem *itemAmount          = [NSURLQueryItem queryItemWithName:pKeyAmount          value:strAmount];
    NSURLQueryItem *itemPackageType     = [NSURLQueryItem queryItemWithName:pKeyPackageType     value:strPackageType];
    NSURLQueryItem *itemPrice           = [NSURLQueryItem queryItemWithName:pKeyPrice           value:@(bookingInfo.nPrice).stringValue];
    NSURLQueryItem *itemObjectID        = [NSURLQueryItem queryItemWithName:pKeyObjectID        value:bookingInfo.strObjectId];
    
    components.queryItems = @[ itemMode, itemEmail, itemKind, itemCustomerName, itemCustomerAddress, itemCustomerPhone, itemStartAddress, itemEndAddress, itemMovingDate, itemAmount, itemPackageType, itemPrice, itemObjectID];
    
    NSURL *url = components.URL;
    
    NSURLRequest *request = [NSURLRequest requestWithURL:url];
    
    // Create url connection and fire request
    NSURLConnection *conn = [[NSURLConnection alloc] initWithRequest:request delegate:self];
     */
    
    NSString *strUrl = [NSString stringWithFormat:@"%@?%@=%@&%@=%@&%@=%@&%@=%@&%@=%@&%@=%@&%@=%@&%@=%@&%@=%@&%@=%@&%@=%@&%@=%@&%@=%@", SERVER_URL, @"mode", @"email", @"email", strEmail, @"kind", @"order_file",  pKeyCustomerName, bookingInfo.strCustomerName, pKeyCustomerAddress, bookingInfo.strCustomerAddress, pKeyCustomerPhone, bookingInfo.strCustomerPhone, pKeyStartAddress, bookingInfo.strStartAddress, pKeyEndAddress, bookingInfo.strEndAddress, pKeyMovingDate, [DataStore instance].strMovingDate, pKeyAmount, strAmount, pKeyPackageType, strPackageType, pKeyPrice, @(bookingInfo.nPrice).stringValue, pKeyObjectID, bookingInfo.strObjectId];
    
    strUrl = [AppDelegate URLEncodeStringForWindows1255:strUrl];
    
    NSURLRequest *urlRequest = [NSURLRequest requestWithURL:[NSURL URLWithString:strUrl]];
    
    NSURLResponse *response = nil;
    NSError *error = nil;
    NSData *data = [NSURLConnection sendSynchronousRequest:urlRequest returningResponse:&response error:&error];
}

- (void) sendStatusEmailWithInfo:(DeliveryBookingInfo *) bookingInfo{
    
    NSString *strEmail    = bookingInfo.strCustomerEmail;
    
    NSString *strCategory = @"general";
    
    if(bookingInfo.nCateogry == MOVING_CAT) strCategory = @"truck";
    
    /*
    
    NSURLComponents *components     = [NSURLComponents componentsWithString:SERVER_URL];
    
    NSURLQueryItem *itemMode            = [NSURLQueryItem queryItemWithName:@"mode"             value:@"email"];
    NSURLQueryItem *itemEmail           = [NSURLQueryItem queryItemWithName:@"email"            value:strEmail];
    NSURLQueryItem *itemKind            = [NSURLQueryItem queryItemWithName:@"kind"             value:@"status"];
    NSURLQueryItem *itemCategory        = [NSURLQueryItem queryItemWithName:pKeyNCategory       value:strCategory];
    NSURLQueryItem *itemStatus          = [NSURLQueryItem queryItemWithName:pKeyStatus          value:@"0"];
    NSURLQueryItem *itemObjectID        = [NSURLQueryItem queryItemWithName:pKeyObjectID        value:bookingInfo.strObjectId];
    NSURLQueryItem *itemCustomerName    = [NSURLQueryItem queryItemWithName:pKeyCustomerName    value:bookingInfo.strCustomerName];
    NSURLQueryItem *itemStartPerson     = [NSURLQueryItem queryItemWithName:pKeyStartPerson     value:bookingInfo.strStartPerson];
    NSURLQueryItem *itemStartAddress    = [NSURLQueryItem queryItemWithName:pKeyStartAddress    value:bookingInfo.strStartAddress];
    NSURLQueryItem *itemEndPerson       = [NSURLQueryItem queryItemWithName:pKeyEndPerson       value:bookingInfo.strEndPerson];
    NSURLQueryItem *itemEndAddress      = [NSURLQueryItem queryItemWithName:pKeyEndAddress      value:bookingInfo.strEndAddress];
    
    components.queryItems = @[itemMode, itemEmail, itemKind, itemCategory, itemStatus, itemObjectID, itemCustomerName, itemStartPerson, itemStartAddress, itemEndPerson, itemEndAddress];
    
    NSURL *url = components.URL;
    
    NSURLRequest *request = [NSURLRequest requestWithURL:url];
    
    // Create url connection and fire request
    NSURLConnection *conn = [[NSURLConnection alloc] initWithRequest:request delegate:self];
     */
    
    
    NSString *strUrl = [NSString stringWithFormat:@"%@?%@=%@&%@=%@&%@=%@&%@=%@&%@=%@&%@=%@&%@=%@&%@=%@&%@=%@&%@=%@&%@=%@", SERVER_URL, @"mode", @"email", @"email", strEmail, @"kind", @"status", pKeyNCategory, strCategory, pKeyStatus, @"0", pKeyObjectID, bookingInfo.strObjectId, pKeyCustomerName, bookingInfo.strCustomerName, pKeyStartPerson, bookingInfo.strStartPerson, pKeyStartAddress, bookingInfo.strStartAddress, pKeyEndPerson, bookingInfo.strEndPerson, pKeyEndAddress, bookingInfo.strEndAddress];
    
    strUrl = [AppDelegate URLEncodeStringForWindows1255:strUrl];
//    strUrl = [AppDelegate RemoveSpaceString:strUrl];
    
    NSURLRequest *urlRequest = [NSURLRequest requestWithURL:[NSURL URLWithString:strUrl]];
    
    NSURLResponse *response = nil;
    NSError *error = nil;
    NSData *data = [NSURLConnection sendSynchronousRequest:urlRequest returningResponse:&response error:&error];
}

- (void) makeDeliveryOrder{
    
    PFUser *currentUser = [PFUser currentUser];
    
    NSString *strCustomerName      = g_myInfo.strFullName;
    NSString *strCustomerEmail     = g_myInfo.strEmail;
    NSString *strCustomerAddress   = g_myInfo.strAddress;
    NSString *strCustomerPhone     = g_myInfo.strPhoneNumber;
    NSString *strWorkerName        = @"";
    NSString *strWorkerFullName    = @"";
    NSString *strWorkerPhoneNumber = @"";
    NSString *strCustomerObjId     = g_myInfo.strUserObjID;
    NSString *strWorkerObjId       = @"";
    NSInteger nStatus              = 0;
    NSString *strstartAddress      = [DataStore instance].addressInfoForPickup.strAddress;
    NSString *strStartApartment    = [DataStore instance].addressInfoForPickup.strApartment;
    NSString *strStartFloor        = [DataStore instance].addressInfoForPickup.strFloor;
    NSString *strStartPerson       = [DataStore instance].addressInfoForPickup.strFullName;
    NSString *strStartPhone        = [DataStore instance].addressInfoForPickup.strPhone;
    NSString *strEndAddress        = [DataStore instance].addressInfoForDropOff.strAddress;
    NSString *strEndApartment      = [DataStore instance].addressInfoForDropOff.strApartment;
    NSString *strEndFloor          = [DataStore instance].addressInfoForDropOff.strFloor;
    NSString *strEndPerson         = [DataStore instance].addressInfoForDropOff.strFullName;
    NSString *strEndPhone          = [DataStore instance].addressInfoForDropOff.strPhone;
    NSInteger nPackageType         = [DataStore instance].nWanaSend;
    NSInteger nUrgencyType         = [DataStore instance].nUrgency;
    NSInteger nDoubleType          = [[NSNumber numberWithBool:[DataStore instance].flgDoubleChecked] integerValue];
    NSInteger nAmount              = [DataStore instance].nNumber;
    NSInteger nFreepaymentFlag     = [(NSNumber *)currentUser[pKeyFreePaymentFlag] integerValue];
    
    if([DataStore instance].nCategory == MOVING_CAT) nFreepaymentFlag = 0;
    
    NSMutableArray *arrInventoryAmount = [[NSMutableArray alloc] init];
    
    for(int i = 0; i < [DataStore instance].arrInventoryNumber.count; i ++){
        NSString *strNumber = [[DataStore instance].arrInventoryNumber objectAtIndex:i];
        
        if([strNumber isEqualToString:@"0"]) continue;
        
        NSString *strItem = [NSString stringWithFormat:@"%d:%@", i, strNumber];
        
        [arrInventoryAmount addObject:strItem];
    }
    
    NSInteger  nManagerOnw = 0;
    NSInteger  nWorkerOwn  = 0;
    NSString *strComment   = [DataStore instance].strComment;

    NSDateFormatter *dateFormatter = [[NSDateFormatter alloc] init];
    
    [dateFormatter setDateFormat:@"d LLL yyyy, HH:mm"];
    
    NSString *strPublishedDate = [dateFormatter stringFromDate:[NSDate date]];
    NSString *strAcceptedDate  = @"";
    NSString *strPickedDate    = @"";
    NSString *strCompletedDate = @"";
    NSString *strPurchasedDate = @"";
    NSInteger nWorkerFlag      = [(NSNumber *)currentUser[pKeyWorkerFlag] integerValue];
    strWorkerName    = currentUser[pKeyWorker];
        
    PFObject *bookingObj = [PFObject objectWithClassName:pClassDelivery];
    
    bookingObj[pKeyCustomerName]    = strCustomerName;
    bookingObj[pKeyCustomerEmail]   = strCustomerEmail;
    bookingObj[pKeyCustomerAddress] = strCustomerAddress;
    bookingObj[pKeyCustomerPhone]   = strCustomerPhone;
    bookingObj[pKeyWorkerName]      = strWorkerName;
    bookingObj[pKeyWorkerFullName]  = strWorkerFullName;
    bookingObj[pKeyWorkerPhone]     = strWorkerPhoneNumber;
    bookingObj[pKeyCustomerObjId]   = strCustomerObjId;
    bookingObj[pKeyWorkerObjId]     = strWorkerObjId;
    bookingObj[pKeyStatus]          = [NSNumber numberWithInteger:nStatus];
    bookingObj[pKeyNCategory]       = [NSNumber numberWithInteger:[DataStore instance].nCategory];
    bookingObj[pKeyStartAddress]    = strstartAddress;
    bookingObj[pKeyStartApartment]  = strStartApartment;
    bookingObj[pKeyStartFloor]      = strStartFloor;
    bookingObj[pKeyStartPerson]     = strStartPerson;
    bookingObj[pKeyStartPhone]      = strStartPhone;
    bookingObj[pKeyEndAddress]      = strEndAddress;
    bookingObj[pKeyEndApartment]    = strEndApartment;
    bookingObj[pKeyEndFloor]        = strEndFloor;
    bookingObj[pKeyEndPerson]       = strEndPerson;
    bookingObj[pKeyEndPhone]        = strEndPhone;
    bookingObj[pKeyPackageType]     = [NSNumber numberWithInteger:nPackageType];
    bookingObj[pKeyUrgencyType]     = [NSNumber numberWithInteger:nUrgencyType];
    bookingObj[pKeyDoubleType]      = [NSNumber numberWithInteger:nDoubleType];
    bookingObj[pKeyAmount]          = [NSNumber numberWithInteger:nAmount];
    bookingObj[pKeyInventoryAmount] = arrInventoryAmount;
    bookingObj[pKeyPrice]           = [NSNumber numberWithInteger:[DataStore instance].nPrice];
    bookingObj[pKeyManagerOwn]      = [NSNumber numberWithInteger:nManagerOnw];
    bookingObj[pKeyWorkerOwn]       = [NSNumber numberWithInteger:nWorkerOwn];
    bookingObj[pKeyComment]         = strComment;
    bookingObj[pKeyPublishedDate]   = strPublishedDate;
    bookingObj[pKeyAcceptedDate]    = strAcceptedDate;
    bookingObj[pKeyPickupedDate]    = strPickedDate;
    bookingObj[pKeyCompletedDate]   = strCompletedDate;
    bookingObj[pKeyPurchasedDate]   = strPurchasedDate;
    bookingObj[pKeyPublicMode]      = [NSNumber numberWithInteger:nWorkerFlag];
    bookingObj[pKeyFreePaymentFlag] = [NSNumber numberWithInteger:nFreepaymentFlag];
    bookingObj[pKeySMSPhoneNumber]  = [DataStore instance].strAutoSms;
    
    NSLog(@"auto sms number is %@", [DataStore instance].strAutoSms);
    
    [SVProgressHUD showWithStatus:LocalizedString(@"text_please_wait") maskType:SVProgressHUDMaskTypeGradient];
    
    [bookingObj saveInBackgroundWithBlock:^(BOOL succeeded, NSError *error) {
        if(succeeded){
            DeliveryBookingInfo *bookingInfo = [DeliveryBookingInfo initWithObject:bookingObj];
            
            if([DataStore instance].nCategory == MOVING_CAT) [self sendOrderDocWithInfo:bookingInfo];
            
            [[DataStore instance].arrCurrentBooking insertObject:bookingInfo atIndex:0];
            
            NSMutableArray *arrData = [[[NSUserDefaults standardUserDefaults] objectForKey:pref_booked_array] mutableCopy];
            
            NSString *strNewItem = [NSString stringWithFormat:@"%@:@", bookingInfo.strObjectId];
            
            [arrData addObject:strNewItem];
            
            [[NSUserDefaults standardUserDefaults] setObject:arrData forKey:pref_booked_array];
            
            NSMutableArray *arrWorkerID = [[NSMutableArray alloc] init];
            
            if(nWorkerFlag == 0){
                if([DataStore instance].nCategory == SCOOTER_CAT){

                    PFQuery *scooterQuery = [PFQuery queryWithClassName:pClassWorkerScooter];
                    
                    NSArray *arrWorkerScooter = [scooterQuery findObjects];
                    
                    for(PFObject *pfObj in arrWorkerScooter){
                        [arrWorkerID addObject:pfObj.objectId];
                    }
                    
                    PFQuery *carQuery  = [PFQuery queryWithClassName:pClassWorkerCar];
                    
                    NSArray *arrWorkerCar = [carQuery findObjects];
                    
                    for(PFObject *pfObj in arrWorkerCar){
                        [arrWorkerID addObject:pfObj.objectId];
                    }
                    
                }else if([DataStore instance].nCategory == CAR_CAT){
                    
                    PFQuery *carQuery  = [PFQuery queryWithClassName:pClassWorkerCar];
                    
                    NSArray *arrWorkerCar = [carQuery findObjects];
                    
                    for(PFObject *pfObj in arrWorkerCar){
                        [arrWorkerID addObject:pfObj.objectId];
                    }
                    
                }else{
                    
                    PFQuery *truckQuery  = [PFQuery queryWithClassName:pClassWorkerTruck];
                    
                    NSArray *arrWorkerTruck = [truckQuery findObjects];
                    
                    for(PFObject *pfObj in arrWorkerTruck){
                        [arrWorkerID addObject:pfObj.objectId];
                    }
                    
                }
            }else{
                
                NSString *strWorkerUsername = currentUser[pKeyWorker];
                
                if(strWorkerUsername == nil) strWorkerUsername = @"";
                
                PFQuery *queryTotal = [PFQuery queryWithClassName:pClassWorkerScooter];
                
                [queryTotal whereKey:pKeyUsername equalTo:strWorkerUsername];
                
                NSArray *arrTotal = [queryTotal findObjects];
                
                if(arrTotal.count == 0){
                    
                    queryTotal = [PFQuery queryWithClassName:pClassWorkerCar];
                    
                    [queryTotal whereKey:pKeyUsername equalTo:strWorkerUsername];
                    
                    arrTotal = [queryTotal findObjects];
                    
                    if(arrTotal.count == 0){
                        
                        queryTotal = [PFQuery queryWithClassName:pClassWorkerTruck];
                        
                        [queryTotal whereKey:pKeyUsername equalTo:strWorkerUsername];
                        
                        arrTotal = [queryTotal findObjects];
                    }
                }
                
                for(PFObject *pfObj in arrTotal){
                    [arrWorkerID addObject:pfObj.objectId];
                }
                
            }
            
            // Build the actual push notification target query
            PFQuery *query = [PFInstallation query];
            
            [query whereKey:pKeyUserID containedIn:arrWorkerID];
            
            NSString *strFormat = LocalizedString(@"push_new%@%@%@%@");
            
            if(bookingInfo.nCateogry == MOVING_CAT) strFormat = LocalizedString(@"push_new_truck%@%@%@%@");
            
            NSString *strAlert =[NSString stringWithFormat:strFormat, bookingInfo.strStartPerson, bookingInfo.strStartAddress, bookingInfo.strEndPerson, bookingInfo.strEndAddress];
            
            NSDictionary *data = [NSDictionary dictionaryWithObjectsAndKeys:
                                  bookingInfo.strObjectId,  pnBookingID,
                                  PN_NEW,                   pnMode,
                                  g_myInfo.strUserObjID,    pnFromID,
                                  strAlert,                 pnAlert,
                                  nil];
            
            
            // Send the notification.
            PFPush *push = [[PFPush alloc] init];
        
            [push setQuery:query];
            [push setData:data];
        
            [push sendPushInBackground];
            
            [self sendStatusEmailWithInfo:bookingInfo];
            
            [[NSNotificationCenter defaultCenter] postNotificationName:N_NewBookingPublished object:nil];
            [[NSNotificationCenter defaultCenter] postNotificationName:N_InitSelectCategory object:nil];
            
            [self.menuContainerViewController toggleLeftSideMenuCompletion:^{
                [NSThread sleepForTimeInterval:1];
                
                [self.menuContainerViewController setMenuState:MFSideMenuStateClosed];
            }];
            
            [SVProgressHUD dismiss];
            
            [self.navigationController popToRootViewControllerAnimated:NO];
            
        }else{
            [SVProgressHUD showErrorWithStatus:[error.userInfo objectForKey:@"error"]];
        }
    }];
}

#pragma mark PayPalPaymentDelegate methods

- (void)payPalPaymentViewController:(PayPalPaymentViewController *)paymentViewController didCompletePayment:(PayPalPayment *)completedPayment {
    NSLog(@"PayPal Payment Success!");
    
    [self dismissViewControllerAnimated:YES completion:nil];
    [self makeDeliveryOrder];
}

- (void)payPalPaymentDidCancel:(PayPalPaymentViewController *)paymentViewController {
    NSLog(@"PayPal Payment Canceled");
    
    [self dismissViewControllerAnimated:YES completion:nil];
}


#pragma mark - Table view data source

- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView
{
    return 1;
}

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section {
    if([DataStore instance].nCategory == MOVING_CAT){
        return 10 + self.arrCurrentInventoryList.count;
    }
    
    return 11;
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath {
    UITableViewCell *cell = nil;
    
    if(indexPath.row < 6){
        switch (indexPath.row) {
            case 0:{
                cell = [tableView dequeueReusableCellWithIdentifier:CELL_TITLE forIndexPath:indexPath];
                
                UILabel *lblLabel = (UILabel *)[cell.contentView viewWithTag:1];
                
                lblLabel.text = LocalizedString(@"header_title_total_page");
                
                break;
            }
                
            case 1:{
                cell = [tableView dequeueReusableCellWithIdentifier:CELL_GENERAL forIndexPath:indexPath];
                
                NSString *strCommentDeliveryType = LocalizedString(@"comment_delivery_type");
                NSString *strDeliveryCategory    = ([DataStore instance].nCategory == SCOOTER_CAT)? LocalizedString(@"title_scooter") : LocalizedString(@"title_car");
                
                UILabel *lblContent = (UILabel *)[cell.contentView viewWithTag:1];
                
                lblContent.text = [NSString stringWithFormat:@"%@%@", strDeliveryCategory, strCommentDeliveryType];
                
                break;
            }
                
            case 2:{
                cell = [tableView dequeueReusableCellWithIdentifier:CELL_GENERAL forIndexPath:indexPath];
                
                UILabel *lblContent = (UILabel *)[cell.contentView viewWithTag:1];
                
                lblContent.text = LocalizedString(@"comment_pickup_location");
                
                break;
            }
                
            case 3:{
                cell = [tableView dequeueReusableCellWithIdentifier:CELL_ADDRESS_INFO forIndexPath:indexPath];
                
                UILabel *lblContent = (UILabel *)[cell.contentView viewWithTag:1];
                
                lblContent.text = [NSString stringWithFormat:@"(%@), (%@)%@-(%@), %@-(%@), %@-(%@)", [DataStore instance].addressInfoForPickup.strFullName, [DataStore instance].addressInfoForPickup.strAddress, LocalizedString(@"hint_floor"), [DataStore instance].addressInfoForPickup.strFloor, LocalizedString(@"hint_apartment"), [DataStore instance].addressInfoForPickup.strApartment, LocalizedString(@"hint_phone_number"), [DataStore instance].addressInfoForPickup.strPhone];
                
                break;
            }
                
            case 4:{
                cell = [tableView dequeueReusableCellWithIdentifier:CELL_GENERAL forIndexPath:indexPath];
                
                UILabel *lblContent = (UILabel *)[cell.contentView viewWithTag:1];
                
                lblContent.text = LocalizedString(@"comment_delivery_location");
                
                break;
            }
            case 5:{
                cell = [tableView dequeueReusableCellWithIdentifier:CELL_ADDRESS_INFO forIndexPath:indexPath];
                
                UILabel *lblContent = (UILabel *)[cell.contentView viewWithTag:1];
                
                lblContent.text = [NSString stringWithFormat:@"(%@), (%@)%@-(%@), %@-(%@), %@-(%@)", [DataStore instance].addressInfoForDropOff.strFullName, [DataStore instance].addressInfoForDropOff.strAddress, LocalizedString(@"hint_floor"), [DataStore instance].addressInfoForDropOff.strFloor, LocalizedString(@"hint_apartment"), [DataStore instance].addressInfoForDropOff.strApartment, LocalizedString(@"hint_phone_number"), [DataStore instance].addressInfoForDropOff.strPhone];
                
                break;
            }
            
            default:
                break;
        }
    }else{
        if([DataStore instance].nCategory == MOVING_CAT){
            
            NSInteger p = [self.arrCurrentInventoryList count];
            
            if(indexPath.row == 6){
                cell = [tableView dequeueReusableCellWithIdentifier:CELL_GENERAL forIndexPath:indexPath];
                
                UILabel *lblContent = (UILabel *)[cell.contentView viewWithTag:1];
                
                lblContent.font = [UIFont boldSystemFontOfSize:15];
                lblContent.text = LocalizedString(@"comment_amount_item");
            }else if(indexPath.row > 6 && indexPath.row < 7 + p){
                cell = [tableView dequeueReusableCellWithIdentifier:CELL_ITEM forIndexPath:indexPath];
                
                NSInteger nIdx = indexPath.row - 7;
                
                NSMutableDictionary *dicItem = [self.arrCurrentInventoryList objectAtIndex:nIdx];
                
                UILabel *lblTitle  = (UILabel *)[cell.contentView viewWithTag:1];
                UILabel *lblNumber = (UILabel *)[cell.contentView viewWithTag:2];
                
                lblTitle.text  = [dicItem objectForKey:@"name"];
                lblNumber.text = [dicItem objectForKey:@"number"];
                
            }else if(indexPath.row == 7 + p){
                
                cell = [tableView dequeueReusableCellWithIdentifier:CELL_PRICE forIndexPath:indexPath];
                
                UILabel *lblComment = (UILabel *)[cell.contentView viewWithTag:1];
                UILabel *lblPrice   = (UILabel *)[cell.contentView viewWithTag:2];
                
                lblComment.text = LocalizedString(@"comment_price");
                lblPrice.text = @([DataStore instance].nPrice).stringValue;
                
            }else if(indexPath.row == 8 + p){
                
                cell = [tableView dequeueReusableCellWithIdentifier:CELL_BUTTON_ORDER forIndexPath:indexPath];
                PFUser *currentUser = [PFUser currentUser];
                
                UIButton *btnOrder = (UIButton *)[cell.contentView viewWithTag:1];
                
                NSInteger nFreePayment_flag = [(NSNumber *)currentUser[pKeyFreePaymentFlag] integerValue];
                
                if(nFreePayment_flag == 0 || (nFreePayment_flag == 1 && [DataStore instance].nCategory == MOVING_CAT)){
                    [btnOrder setTitle:LocalizedString(@"title_order") forState:UIControlStateNormal];
                }else{
                    [btnOrder setTitle:LocalizedString(@"title_order_freepayment") forState:UIControlStateNormal];
                }
                
                
                [btnOrder addTarget:self action:@selector(onOrder) forControlEvents:UIControlEventTouchUpInside];

            }else if(indexPath.row == 9 + p){
                
                cell = [tableView dequeueReusableCellWithIdentifier:CELL_REWIND_CANCEL forIndexPath:indexPath];
                
                UIButton *btnCancel = (UIButton *)[cell.contentView viewWithTag:1];
                UIButton *btnRewind = (UIButton *)[cell.contentView viewWithTag:2];
                
                [btnCancel setTitle:LocalizedString(@"title_cancel") forState:UIControlStateNormal];
                [btnRewind setTitle:LocalizedString(@"title_rewind") forState:UIControlStateNormal];
                
                [btnCancel addTarget:self action:@selector(onCancel) forControlEvents:UIControlEventTouchUpInside];
                [btnRewind addTarget:self action:@selector(onRewind) forControlEvents:UIControlEventTouchUpInside];

            }
            
            
        }else{
            switch (indexPath.row) {
                case 6:{
                    cell = [tableView dequeueReusableCellWithIdentifier:CELL_GENERAL forIndexPath:indexPath];
                    
                    NSString *strContent = @"";
                    
                    if([DataStore instance].flgDoubleChecked) strContent = [NSString stringWithFormat:@"(%@)", LocalizedString(@"comment_double")];
                    if([DataStore instance].nUrgency == 1) strContent = [NSString stringWithFormat:@"%@(%@) :%@", strContent, [self.arrDataUrgency objectAtIndex:[DataStore instance].nUrgency], LocalizedString(@"comment_urgency")];
                    
                    strContent = [NSString stringWithFormat:@"%@(%@)%@", strContent, [self.arrDataWanaSend objectAtIndex:[DataStore instance].nWanaSend], LocalizedString(@"comment_option")];
                    
                    UILabel *lblContent = (UILabel *)[cell.contentView viewWithTag:1];
                    
                    lblContent.text = strContent;
                    
                    break;
                }
                case 7:{
                    cell = [tableView dequeueReusableCellWithIdentifier:CELL_GENERAL forIndexPath:indexPath];
                    
                    UILabel *lblContent = (UILabel *)[cell.contentView viewWithTag:1];
                    
                    lblContent.text = [NSString stringWithFormat:@"%@ %@", @([DataStore instance].nNumber).stringValue , LocalizedString(@"comment_amount_items")];
                    break;
                }
                case 8:{
                    cell = [tableView dequeueReusableCellWithIdentifier:CELL_PRICE forIndexPath:indexPath];
                    
                    UILabel *lblComment = (UILabel *)[cell.contentView viewWithTag:1];
                    UILabel *lblPrice   = (UILabel *)[cell.contentView viewWithTag:2];
                    
                    lblComment.text = LocalizedString(@"comment_price");
                    lblPrice.text = @([DataStore instance].nPrice).stringValue;
                    
                    break;
                }
                case 9:{
                    cell = [tableView dequeueReusableCellWithIdentifier:CELL_BUTTON_ORDER forIndexPath:indexPath];
                    PFUser *currentUser = [PFUser currentUser];
                    
                    UIButton *btnOrder = (UIButton *)[cell.contentView viewWithTag:1];
                    
                    NSInteger nFreePayment_flag = [(NSNumber *)currentUser[pKeyFreePaymentFlag] integerValue];
                    
                    if(nFreePayment_flag == 0 || (nFreePayment_flag == 1 && [DataStore instance].nCategory == MOVING_CAT)){
                        [btnOrder setTitle:LocalizedString(@"title_order") forState:UIControlStateNormal];
                    }else{
                        [btnOrder setTitle:LocalizedString(@"title_order_freepayment") forState:UIControlStateNormal];
                    }
                    
                    [btnOrder addTarget:self action:@selector(onOrder) forControlEvents:UIControlEventTouchUpInside];
                    break;
                }
                case 10:{
                    cell = [tableView dequeueReusableCellWithIdentifier:CELL_REWIND_CANCEL forIndexPath:indexPath];
                    
                    UIButton *btnCancel = (UIButton *)[cell.contentView viewWithTag:1];
                    UIButton *btnRewind = (UIButton *)[cell.contentView viewWithTag:2];
                    
                    [btnCancel setTitle:LocalizedString(@"title_cancel") forState:UIControlStateNormal];
                    [btnRewind setTitle:LocalizedString(@"title_rewind") forState:UIControlStateNormal];
                    
                    [btnCancel addTarget:self action:@selector(onCancel) forControlEvents:UIControlEventTouchUpInside];
                    [btnRewind addTarget:self action:@selector(onRewind) forControlEvents:UIControlEventTouchUpInside];
                    
                    break;
                }
                default:
                    break;
            }
        }
    }
    
    return cell;
    
}

-(CGFloat)tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath{
    CGFloat height = 60;
    NSArray *arrHeightForCar = @[@"60", @"30", @"30", @"80", @"30", @"80", @"30", @"30", @"40", @"50", @"50"];
    
    if([DataStore instance].nCategory == MOVING_CAT){
        NSInteger p = self.arrCurrentInventoryList.count;
        
        if(indexPath.row < 7){
            height = [[arrHeightForCar objectAtIndex:indexPath.row] floatValue];
        }else if(indexPath.row > 6 && indexPath.row < 7 + p){
            height = 30;
        }else{
            height = [[arrHeightForCar objectAtIndex:indexPath.row - p + 1] floatValue];
        }
    }else{
        height = [[arrHeightForCar objectAtIndex:indexPath.row] floatValue];
    }
    
    
    return height;
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
