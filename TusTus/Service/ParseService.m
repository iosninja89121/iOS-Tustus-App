//
//  AppDelegate.h
//  ProtoDeviceMonitor
//
//  Created by User on 1/16/15.
//  Copyright (c) 2015 Philip. All rights reserved.
//

#import "ParseService.h"

@implementation ParseService

ParseService *sharedParseObj = nil;

+ (id)sharedInstance{
    
    if(!sharedParseObj)
    {
        static dispatch_once_t oncePredicate;
        dispatch_once(&oncePredicate, ^{
            sharedParseObj = [[self alloc] init];
        });
    }
    
    return sharedParseObj;
}

- (void)loginWithUserName:(NSString *)strUserName
                 Password:(NSString *)strPassword
                   Result:(void (^)(NSString *))onResult
{
    [PFUser logInWithUsernameInBackground:strUserName
                                 password:strPassword
                                    block:^(PFUser *user, NSError *error) {
                                        if(error == nil)
                                        {
                                            g_myInfo = [[UserInfo alloc] init];
                                            [g_myInfo addInfoWithPFUser:user];

                                            onResult(nil);
                                        }
                                        else
                                            onResult([error.userInfo objectForKey:@"error"]);
                                    }];
}

- (void)requestPasswordWithUserName:(NSString *)strUserName
                             Result:(void (^)(NSString *))onResult
{
    [PFUser requestPasswordResetForEmailInBackground:strUserName
                                               block:^(BOOL succeeded, NSError *error) {
                                                   if(error == nil)
                                                       onResult(nil);
                                                   else
                                                       onResult([error.userInfo objectForKey:@"error"]);
                                               }];
}

- (void)signUpWithUserInfo:(UserInfo *)userInfo
                    Result:(void (^)(NSString *))onResult
{
    PFUser *user = [PFUser new];
    
    user.username       = userInfo.strPhoneNumber;
    user.password       = userInfo.strPassword;
    user.email          = userInfo.strEmail;
    user[pKeyFullName]  = userInfo.strFullName;
    user[pKeyAddress]   = userInfo.strAddress;
    user[pKeyApartment] = userInfo.strApartment;
    user[pKeyFloor]     = userInfo.strFloor;
    user[pKeyPSW]       = userInfo.strPassword;
    user[pKeyPriceForScooter] = @(nPerKmPriceForScooter);
    user[pKeyPriceForCar] = @(nPerKmPriceForCar);
    user[pKeyPriceForTruck] = @(nPerKmPriceForTruck);
    user[pKeyMinPriceForScooter] = @(nMinPriceForScooter);
    user[pKeyMinPriceForCar] = @(nMinPriceForCar);
    user[pKeyMinPriceForTruck] = @(nMinPriceForTruck);
    user[pKeyMinDistanceForScooter] = @(nMinDistanceForScooter);
    user[pKeyMinDistanceForCar] = @(nMinDistanceForCar);
    user[pKeyMinDistanceForTruck] = @(nMinDistanceForTruck);
    user[pKeyModePrice] = @(0);
    user[pKeyFlatPrice] = @(0);
    user[pKeyWorkerFlag] = @(0);
    user[pKeyWorker] = @"";
    user[pKeyRateDay] = @(nDayRate);
    user[pKeyRateEvening] = @(nEveningRate);
    user[pKeyRateNight] = @(nNightRate);
    user[pKeyHourDayStart] = @(nDayStart);
    user[pKeyHourDayEnd] = @(nDayEnd);
    user[pKeyHourEveningStart] = @(nEveningStart);
    user[pKeyHourEveningEnd] = @(nEveningEnd);
    user[pKeyHourNightStart] = @(nNightStart);
    user[pKeyHourNightEnd] = @(nNightEnd);
    
    
    [user signUpInBackgroundWithBlock:^(BOOL succeeded, NSError *error) {
        if(error == nil)
        {
            g_myInfo = [[UserInfo alloc] init];
            [g_myInfo addInfoWithPFUser:user];
            onResult(nil);
        }
        else
            onResult([error.userInfo objectForKey:@"error"]);
    }];
}


@end
