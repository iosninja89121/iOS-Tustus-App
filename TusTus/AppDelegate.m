//
//  AppDelegate.m
//  TusTus
//
//  Created by User on 4/7/15.
//  Copyright (c) 2015 Philip. All rights reserved.
//

#import "AppDelegate.h"
#import "MainNavigationController.h"
#import <PayPalMobile.h>
#import <AudioToolbox/AudioToolbox.h>
#import "TestFairy.h"
#import <SVProgressHUD.h>

UserInfo                                     *g_myInfo;
MFSideMenuContainerViewController            *g_sideMenuController;
AppDelegate                                  *g_appDelegate;
MainNavigationController                     *g_mainNav;

@interface AppDelegate ()
@property (nonatomic, strong) NSString *strBookingID;
@property (nonatomic, strong) NSString *strFromID;
@property (nonatomic, strong) NSString *strMode;
@property (nonatomic, strong) NSString *strAlert;
@property (nonatomic)         NSInteger nInvoiceNumber;
@end

@implementation AppDelegate


- (BOOL)application:(UIApplication *)application didFinishLaunchingWithOptions:(NSDictionary *)launchOptions {
    // Override point for customization after application launch.
    //Initialize Parse.com
    [Parse setApplicationId:PARSE_APPLICATION_ID      clientKey:PARSE_CLIENT_KEY];
    
    if ([[[UIDevice currentDevice] systemVersion] floatValue] >= 8.0)
    {
        UIUserNotificationType userNotificationTypes = (UIUserNotificationTypeAlert | UIUserNotificationTypeBadge |     UIUserNotificationTypeSound);
        UIUserNotificationSettings *settings = [UIUserNotificationSettings settingsForTypes:userNotificationTypes categories:nil];
        
        
        [application registerUserNotificationSettings:settings];
        [application registerForRemoteNotifications];
    }else{
        [application registerForRemoteNotificationTypes:
         (UIUserNotificationTypeBadge | UIUserNotificationTypeSound | UIUserNotificationTypeAlert)];
    }
    
    [PayPalMobile initializeWithClientIdsForEnvironments:@{PayPalEnvironmentProduction : @"AQyDsvwVd_i-U1fcqjt6I6OOMs3bUlAx5aF4rp-17lKJlAuO-72e5ikqnlCfjlcDZOXrdWRudJx6-XiR",
                                                           PayPalEnvironmentSandbox : @"ARc5I6HPlNfRiXJ_Ve12qs7_wg51vS3FlJcp7MpVOt69j2Zbqs_leU-YBTBjGTYfA-xzd-YMLlCv4SH4"}];
    
    //Initialize TestFairy
    [TestFairy begin:@"1c27fb5ccdee208ed4e6ce270a61075cc22bb386"];

    LocalizationSetLanguage(@"he");
//    LocalizationSetLanguage(@"Base");
    
    g_myInfo = nil;
    [self buildSideMenu];
    g_appDelegate = self;
    
    return YES;
}

- (void)application:(UIApplication*)application didReceiveRemoteNotification:(NSDictionary*)userInfo fetchCompletionHandler:(void (^)(UIBackgroundFetchResult))completionHandler
{
    [UIApplication sharedApplication].applicationIconBadgeNumber = 0;
    
    self.strBookingID = [userInfo objectForKey:pnBookingID];
    self.strFromID    = [userInfo objectForKey:pnFromID];
    self.strMode      = [userInfo objectForKey:pnMode];
    self.strAlert     = [[userInfo objectForKey:pnAps] objectForKey:pnAlert];
    
    BOOL isAlertDisabled = [[NSUserDefaults standardUserDefaults] boolForKey:DEFAULT_ALERT_DISABLED];
    
    if(![self.strMode isEqualToString:PN_ACCEPT_REQUEST]){
        if(!isAlertDisabled) [self getNotificationWithString:self.strAlert];
    }
    
    self.nInvoiceNumber = 1;
    
    if([self.strMode isEqualToString:PN_ACCEPT_REQUEST]) [self funcAcceptRequest];
    if([self.strMode isEqualToString:PN_ACCEPT])         [self funcAccept];
    if([self.strMode isEqualToString:PN_PICKUP])         [self funcPickup];
    if([self.strMode isEqualToString:PN_DELIVERY]){
        self.nInvoiceNumber = [(NSNumber *)[userInfo objectForKey:pnInvoiceNumber] integerValue];
        [self funcDelivery];
    }
    
    if([application applicationState] == UIApplicationStateActive){
        if(![self.strMode isEqualToString:PN_ACCEPT_REQUEST]){
            if(!isAlertDisabled) [SVProgressHUD showInfoWithStatus:self.strAlert];
        }
    }
    
    completionHandler(UIBackgroundFetchResultNewData);
}

- (void) getNotificationWithString:(NSString *) strAlert{
    NSDate *pickerDate = [NSDate dateWithTimeIntervalSinceNow:0];
    
    // Schedule the notification
    UILocalNotification* localNotification = [[UILocalNotification alloc] init];
    localNotification.fireDate = pickerDate;
    localNotification.alertBody = strAlert;
    localNotification.alertAction = @"Show me the item";

    
    [[UIApplication sharedApplication] scheduleLocalNotification:localNotification];
}

- (void) funcAcceptRequest{
    NSMutableArray *arrBooking = [[[NSUserDefaults standardUserDefaults] objectForKey:pref_booked_array] mutableCopy];
    
    BOOL flag = NO;
   
    NSString *strAns1 = [NSString stringWithFormat:@"%@:%@", self.strBookingID, self.strFromID];
    NSString *strAns2 = [NSString stringWithFormat:@"%@:@", self.strBookingID];
    
    for(int i = 0; i < arrBooking.count; i ++){
        NSString *strItem = [arrBooking objectAtIndex:i];
        
        if([strItem isEqualToString:strAns1] || [strItem isEqualToString:strAns2]){
            [arrBooking removeObjectAtIndex:i];
            [arrBooking insertObject:strAns1 atIndex:i];
            flag = YES;
            break;
        }
    }
    
    NSString *strModePN = PN_ACCPET_FORBIDDEN;
    
    if(flag){
        [[NSUserDefaults standardUserDefaults] setObject:arrBooking forKey:pref_booked_array];
        strModePN = PN_ACCEPT_APPROVE;
    }
    
    NSDictionary *data = [NSDictionary dictionaryWithObjectsAndKeys:
                          self.strBookingID,        pnBookingID,
                          strModePN,                pnMode,
                          g_myInfo.strUserObjID,    pnFromID,
                          @"",                      pnAlert,
                          nil];

    PFQuery *query = [PFInstallation query];
    
    [query whereKey:pKeyUserID equalTo:self.strFromID];
    
    // Send the notification.
    PFPush *push = [[PFPush alloc] init];
    
    [push setQuery:query];
    [push setData:data];
    
    [push sendPushInBackground];
}

- (void) funcAccept{
    
    if(g_myInfo == nil) return;

    NSInteger i;
    NSMutableArray *arrBooking = [[[NSUserDefaults standardUserDefaults] objectForKey:pref_booked_array] mutableCopy];

    NSString *strAns = [NSString stringWithFormat:@"%@:%@", self.strBookingID, self.strFromID];
    
    for(i = 0; i < arrBooking.count; i ++){
        NSString *strItem =[arrBooking objectAtIndex:i];
        
        if([strItem isEqualToString:strAns]){
            [arrBooking removeObjectAtIndex:i];
            break;
        }
    }

    [[NSUserDefaults standardUserDefaults] setObject:arrBooking forKey:pref_booked_array];
    
    for(i = 0; i < [DataStore instance].arrCurrentBooking.count; i ++){
        DeliveryBookingInfo *bookingInfo = [[DataStore instance].arrCurrentBooking objectAtIndex:i];
        
        if([bookingInfo.strObjectId isEqualToString:self.strBookingID]) break;
    }
    
    if(i == [DataStore instance].arrCurrentBooking.count) return;
    
    PFQuery *query = [PFQuery queryWithClassName:pClassDelivery];
    
    [query whereKey:pKeyObjectID equalTo:self.strBookingID];
    
    [query findObjectsInBackgroundWithBlock:^(NSArray *objects, NSError *error) {
        if(error != nil) return;
        if(objects.count == 0) return;

        PFObject *pfObj = [objects objectAtIndex:0];
        
        DeliveryBookingInfo *bookingInfo = [[DataStore instance].arrCurrentBooking objectAtIndex:i];
        
        [[DataStore instance].arrCurrentBooking removeObjectAtIndex:i];
        
        bookingInfo.nStatus = 1;
        bookingInfo.strWorkerName   = pfObj[pKeyWorkerName];
        bookingInfo.strWorkerObjId  = pfObj[pKeyWorkerObjId];
        bookingInfo.strAcceptedDate = pfObj[pKeyAcceptedDate];
        
        [[DataStore instance].arrCurrentBooking insertObject:bookingInfo atIndex:i];
        
       [[NSNotificationCenter defaultCenter] postNotificationName:N_NewBookingPublished object:nil]; // This means updated too.
        
    }];
}

- (void) funcPickup{
    if(g_myInfo == nil) return;
    
    NSInteger i;
    
    for(i = 0; i < [DataStore instance].arrCurrentBooking.count; i ++){
        DeliveryBookingInfo *bookingItem = [[DataStore instance].arrCurrentBooking objectAtIndex:i];
        
        if([bookingItem.strObjectId isEqualToString:self.strBookingID]) break;
    }
    
    if(i == [DataStore instance].arrCurrentBooking.count) return;
    
    PFQuery *query = [PFQuery queryWithClassName:pClassDelivery];
    
    [query whereKey:pKeyObjectID equalTo:self.strBookingID];
    
    [query findObjectsInBackgroundWithBlock:^(NSArray *objects, NSError *error) {
        if(error != nil) return;
        if(objects.count == 0) return;
        
        PFObject *pfObj = [objects objectAtIndex:0];
        
        DeliveryBookingInfo *bookingInfo = [[DataStore instance].arrCurrentBooking objectAtIndex:i];
        
        [[DataStore instance].arrCurrentBooking removeObjectAtIndex:i];
        
        bookingInfo.nStatus = 2;
        bookingInfo.strPickupedDate = pfObj[pKeyPickupedDate];
        
        [[DataStore instance].arrCurrentBooking insertObject:bookingInfo atIndex:i];
        
        [[NSNotificationCenter defaultCenter] postNotificationName:N_NewBookingPublished object:nil]; // This means updated too.
    }];
}

- (void) funcDelivery{
    
    NSString *strInvoiceNumber = [NSString stringWithFormat:@"%04ld", (long)self.nInvoiceNumber];
   
    if(g_myInfo == nil){
        PFQuery *query = [PFQuery queryWithClassName:pClassDelivery];
        
        [query whereKey:pKeyObjectID equalTo:self.strBookingID];
        
        [query findObjectsInBackgroundWithBlock:^(NSArray *objects, NSError *error) {
            if(error != nil) return;
            if(objects.count == 0) return;
            
            PFObject *pfObj = [objects objectAtIndex:0];
            
            DeliveryBookingInfo *bookingInfo = [DeliveryBookingInfo initWithObject:pfObj];
            
            PFObject *completedItemObj = [PFObject objectWithClassName:pClassCompletedDelivery];
            
            completedItemObj[pKeyCustomerName]   = bookingInfo.strCustomerName;
            completedItemObj[pKeyCustomerEmail]  = bookingInfo.strCustomerEmail;
            completedItemObj[pKeyWorkerName]     = bookingInfo.strWorkerName;
            completedItemObj[pKeyWorkerFullName] = bookingInfo.strWorkerFullName;
            completedItemObj[pKeyWorkerPhone]    = bookingInfo.strWorkerPhone;
            completedItemObj[pKeyCustomerObjId]  = bookingInfo.strCustomerObjId;
            completedItemObj[pKeyWorkerObjId]    = bookingInfo.strWorkerObjId;
            completedItemObj[pKeyStatus]         = [NSNumber numberWithInteger:bookingInfo.nStatus];
            completedItemObj[pKeyNCategory]      = [NSNumber numberWithInteger:bookingInfo.nCateogry];
            completedItemObj[pKeyStartAddress]   = bookingInfo.strStartAddress;
            completedItemObj[pKeyStartApartment] = bookingInfo.strStartApartment;
            completedItemObj[pKeyStartFloor]     = bookingInfo.strStartFloor;
            completedItemObj[pKeyStartPerson]    = bookingInfo.strStartPerson;
            completedItemObj[pKeyStartPhone]     = bookingInfo.strStartPhone;
            completedItemObj[pKeyEndAddress]     = bookingInfo.strEndAddress;
            completedItemObj[pKeyEndApartment]   = bookingInfo.strEndApartment;
            completedItemObj[pKeyEndFloor]       = bookingInfo.strEndFloor;
            completedItemObj[pKeyEndPerson]      = bookingInfo.strEndPerson;
            completedItemObj[pKeyEndPhone]       = bookingInfo.strEndPhone;
            completedItemObj[pKeyPackageType]    = [NSNumber numberWithInteger:bookingInfo.nPackageType];
            completedItemObj[pKeyUrgencyType]    = [NSNumber numberWithInteger:bookingInfo.nUrgencyType];
            completedItemObj[pKeyDoubleType]     = [NSNumber numberWithInteger:bookingInfo.nDoubleType];
            completedItemObj[pKeyAmount]         = [NSNumber numberWithInteger:bookingInfo.nAmount];
            completedItemObj[pKeyPrice]          = [NSNumber numberWithInteger:bookingInfo.nPrice];
            completedItemObj[pKeyManagerOwn]     = [NSNumber numberWithInteger:bookingInfo.nManagerOwn];
            completedItemObj[pKeyWorkerOwn]      = [NSNumber numberWithInteger:bookingInfo.nWorkerOwn];
            completedItemObj[pKeyComment]        = bookingInfo.strComment;
            completedItemObj[pKeyPublishedDate]  = bookingInfo.strPublishedDate;
            completedItemObj[pKeyAcceptedDate]   = bookingInfo.strAcceptedDate;
            completedItemObj[pKeyPickupedDate]   = bookingInfo.strPickupedDate;
            completedItemObj[pKeyCompletedDate]  = bookingInfo.strCompletedDate;
            completedItemObj[pKeyPurchasedDate]  = @"";
            completedItemObj[pKeyInvoiceNumber]  = strInvoiceNumber;
            completedItemObj[pKeyInventoryAmount]= bookingInfo.arrInventoryAmountList;
            completedItemObj[pKeyFreePaymentFlag]= [NSNumber numberWithInteger:bookingInfo.nFreepaymentFlag];
            
            [completedItemObj saveInBackground];
            
            [pfObj deleteInBackground];
            
        }];
        
        return;
    }
    
    int i;
    
    for(i = 0; i < [DataStore instance].arrCurrentBooking.count; i ++){
        DeliveryBookingInfo *bookingInfo = [[DataStore instance].arrCurrentBooking objectAtIndex:i];
        
        if([bookingInfo.strObjectId isEqualToString:self.strBookingID]) break;
    }
    
    if(i == [DataStore instance].arrCurrentBooking.count) return;
   
    PFQuery *query = [PFQuery queryWithClassName:pClassDelivery];
    [query whereKey:pKeyObjectID equalTo:self.strBookingID];
    
    [query findObjectsInBackgroundWithBlock:^(NSArray *objects, NSError *error) {
        if(error != nil) return;
        if(objects.count == 0) return;
        
        PFObject *pfObj = [objects objectAtIndex:0];
        
        DeliveryBookingInfo *bookingInfo = [[DataStore instance].arrCurrentBooking objectAtIndex:i];
        
        [[DataStore instance].arrCurrentBooking removeObjectAtIndex:i];
        
        bookingInfo.nStatus = 3;
        bookingInfo.strCompletedDate = pfObj[pKeyCompletedDate];
        bookingInfo.nManagerOwn      = [(NSNumber *)pfObj[pKeyManagerOwn] integerValue];
        bookingInfo.nWorkerOwn       = [(NSNumber *)pfObj[pKeyWorkerOwn] integerValue];
        
        [[DataStore instance].arrCompletedBooking addObject:bookingInfo];
        
        PFObject *completedItemObj = [PFObject objectWithClassName:pClassCompletedDelivery];
        
        completedItemObj[pKeyCustomerName]   = bookingInfo.strCustomerName;
        completedItemObj[pKeyCustomerEmail]  = bookingInfo.strCustomerEmail;
        completedItemObj[pKeyWorkerName]     = bookingInfo.strWorkerName;
        completedItemObj[pKeyWorkerFullName] = bookingInfo.strWorkerFullName;
        completedItemObj[pKeyWorkerPhone]    = bookingInfo.strWorkerPhone;
        completedItemObj[pKeyCustomerObjId]  = bookingInfo.strCustomerObjId;
        completedItemObj[pKeyWorkerObjId]    = bookingInfo.strWorkerObjId;
        completedItemObj[pKeyStatus]         = [NSNumber numberWithInteger:bookingInfo.nStatus];
        completedItemObj[pKeyNCategory]      = [NSNumber numberWithInteger:bookingInfo.nCateogry];
        completedItemObj[pKeyStartAddress]   = bookingInfo.strStartAddress;
        completedItemObj[pKeyStartApartment] = bookingInfo.strStartApartment;
        completedItemObj[pKeyStartFloor]     = bookingInfo.strStartFloor;
        completedItemObj[pKeyStartPerson]    = bookingInfo.strStartPerson;
        completedItemObj[pKeyStartPhone]     = bookingInfo.strStartPhone;
        completedItemObj[pKeyEndAddress]     = bookingInfo.strEndAddress;
        completedItemObj[pKeyEndApartment]   = bookingInfo.strEndApartment;
        completedItemObj[pKeyEndFloor]       = bookingInfo.strEndFloor;
        completedItemObj[pKeyEndPerson]      = bookingInfo.strEndPerson;
        completedItemObj[pKeyEndPhone]       = bookingInfo.strEndPhone;
        completedItemObj[pKeyPackageType]    = [NSNumber numberWithInteger:bookingInfo.nPackageType];
        completedItemObj[pKeyUrgencyType]    = [NSNumber numberWithInteger:bookingInfo.nUrgencyType];
        completedItemObj[pKeyDoubleType]     = [NSNumber numberWithInteger:bookingInfo.nDoubleType];
        completedItemObj[pKeyAmount]         = [NSNumber numberWithInteger:bookingInfo.nAmount];
        completedItemObj[pKeyPrice]          = [NSNumber numberWithInteger:bookingInfo.nPrice];
        completedItemObj[pKeyManagerOwn]     = [NSNumber numberWithInteger:bookingInfo.nManagerOwn];
        completedItemObj[pKeyWorkerOwn]      = [NSNumber numberWithInteger:bookingInfo.nWorkerOwn];
        completedItemObj[pKeyComment]        = bookingInfo.strComment;
        completedItemObj[pKeyPublishedDate]  = bookingInfo.strPublishedDate;
        completedItemObj[pKeyAcceptedDate]   = bookingInfo.strAcceptedDate;
        completedItemObj[pKeyPickupedDate]   = bookingInfo.strPickupedDate;
        completedItemObj[pKeyCompletedDate]  = bookingInfo.strCompletedDate;
        completedItemObj[pKeyPurchasedDate]  = @"";
        completedItemObj[pKeyInvoiceNumber]  = strInvoiceNumber;
        completedItemObj[pKeyInventoryAmount]= bookingInfo.arrInventoryAmountList;
        completedItemObj[pKeyFreePaymentFlag]= [NSNumber numberWithInteger:bookingInfo.nFreepaymentFlag];
        
        [completedItemObj saveInBackground];
        
        [pfObj deleteInBackground];
        
        [[NSNotificationCenter defaultCenter] postNotificationName:N_NewBookingPublished object:nil]; // This means updated too.
        
    }];
}


- (void)buildSideMenu
{
    UIStoryboard *storyboard = [UIStoryboard storyboardWithName:main_storyboard bundle:nil];
    
    UIViewController *leftVC  = [storyboard instantiateViewControllerWithIdentifier:VC_LEFT_MENU];
    UIViewController *rightVC = [storyboard instantiateViewControllerWithIdentifier:VC_RIGHT_MENU];
    UIViewController *selectCategoryVC  = [storyboard instantiateViewControllerWithIdentifier:VC_SELECT_CATEGORY_I];
    
    g_mainNav = [storyboard instantiateViewControllerWithIdentifier:NAV_MAIN];
    
    [g_mainNav setViewControllers:@[selectCategoryVC]];
    
    g_sideMenuController = [MFSideMenuContainerViewController containerWithCenterViewController:g_mainNav
                                                                         leftMenuViewController:leftVC
                                                                        rightMenuViewController:rightVC];
    [g_sideMenuController.shadow setEnabled:YES];
    [g_sideMenuController.shadow setRadius:10.f];
    [g_sideMenuController.shadow setColor:[UIColor whiteColor]];
    [g_sideMenuController.shadow setOpacity:0.7f];
}

- (void)application:(UIApplication*)application didRegisterForRemoteNotificationsWithDeviceToken:(NSData*)deviceToken
{
    // Store the deviceToken in the current installation and save it to Parse.
    PFInstallation *currentInstallation = [PFInstallation currentInstallation];
    [currentInstallation setDeviceTokenFromData:deviceToken];
    
    [currentInstallation saveInBackground];
    
}

- (void)applicationWillResignActive:(UIApplication *)application {
    // Sent when the application is about to move from active to inactive state. This can occur for certain types of temporary interruptions (such as an incoming phone call or SMS message) or when the user quits the application and it begins the transition to the background state.
    // Use this method to pause ongoing tasks, disable timers, and throttle down OpenGL ES frame rates. Games should use this method to pause the game.
}

- (void)applicationDidEnterBackground:(UIApplication *)application {
    // Use this method to release shared resources, save user data, invalidate timers, and store enough application state information to restore your application to its current state in case it is terminated later.
    // If your application supports background execution, this method is called instead of applicationWillTerminate: when the user quits.
}

- (void)applicationWillEnterForeground:(UIApplication *)application {
    // Called as part of the transition from the background to the inactive state; here you can undo many of the changes made on entering the background.
}

- (void)applicationDidBecomeActive:(UIApplication *)application {
    // Restart any tasks that were paused (or not yet started) while the application was inactive. If the application was previously in the background, optionally refresh the user interface.
}

- (void)applicationWillTerminate:(UIApplication *)application {
    // Called when the application is about to terminate. Save data if appropriate. See also applicationDidEnterBackground:.
}

+(NSString *) URLEncodeString:(NSString *) str
{
    
    NSMutableString *tempStr = [NSMutableString stringWithString:str];
    [tempStr replaceOccurrencesOfString:@" " withString:@"+" options:NSCaseInsensitiveSearch range:NSMakeRange(0, [tempStr length])];
    
    
    return [[NSString stringWithFormat:@"%@",tempStr] stringByAddingPercentEscapesUsingEncoding:NSUTF8StringEncoding];
}



+(NSString *) URLEncodeStringForWindows1255:(NSString *) str{
    NSMutableString *tempStr = [NSMutableString stringWithString:str];
    [tempStr replaceOccurrencesOfString:@" " withString:@"+" options:NSCaseInsensitiveSearch range:NSMakeRange(0, [tempStr length])];
    
    NSString* encoding = @"windows-1255";
    
    CFStringEncoding cfEncoding = CFStringConvertIANACharSetNameToEncoding((__bridge CFStringRef)encoding);
    NSStringEncoding nsEncoding = CFStringConvertEncodingToNSStringEncoding(cfEncoding);
    
    return [[NSString stringWithFormat:@"%@",tempStr] stringByAddingPercentEscapesUsingEncoding:nsEncoding];
}

+ (float) getRealWidthFrom:(float)height content:(NSString *)content fontname:(NSString *)fontname fontsize:(float)fontsize
{
    UIFont *textFont = [UIFont fontWithName:fontname size:fontsize];
    
    
    return [AppDelegate getRealWidthFrom:height content:content font:textFont];
}



+ (float) getRealWidthFrom:(float)height content:(NSString *)content font:(UIFont *)font
{
    CGSize size = CGSizeMake(320, height);
    CGSize textSize = [content sizeWithFont:font constrainedToSize:size lineBreakMode:NSLineBreakByWordWrapping];
    
    return textSize.width;
}


+ (float) getRealHeightFrom:(float)width content:(NSString *)content fontname:(NSString *)fontname fontsize:(float)fontsize
{
    UIFont *textFont = [UIFont fontWithName:fontname size:fontsize];
    
    return [AppDelegate getRealHeightFrom:width content:content font:textFont];
}


+ (float) getRealHeightFrom:(float)width content:(NSString *)content font:(UIFont *)font
{
    CGSize size = CGSizeMake(width, 1000);
    CGSize textSize = [content sizeWithFont:font constrainedToSize:size lineBreakMode:NSLineBreakByWordWrapping];
    
    return textSize.height;
}

@end
