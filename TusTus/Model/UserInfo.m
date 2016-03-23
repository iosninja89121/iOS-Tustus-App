//
//  UserInfo.m
//  ProtoDeviceMonitor
//
//  Created by User on 1/16/15.
//  Copyright (c) 2015 Philip. All rights reserved.
//

#import "UserInfo.h"

@implementation UserInfo

@synthesize             strPhoneNumber;
@synthesize             strPassword;
@synthesize             strFullName;
@synthesize             strEmail;
@synthesize             strAddress;
@synthesize             strApartment;
@synthesize             strFloor;
@synthesize             strUserObjID;

- (id)init
{
    self = [super init];
    if(self)
    {
        strPhoneNumber = @"";
        strPassword    = @"";
        strFullName    = @"";
        strEmail       = @"";
        strAddress     = @"";
        strApartment   = @"";
        strFloor       = @"";
        strUserObjID   = @"";
    }
    
    return self;
}

- (void)addInfoWithPFUser:(PFUser *)user
{
    strPhoneNumber   = user.username;
    strPassword      = user[pKeyPSW] == nil ? @"" : user[pKeyPSW];
    strFullName      = user[pKeyFullName] == nil ? @"" : user[pKeyFullName];
    strEmail         = user.email == nil ? @"" : user.email;
    strAddress       = user[pKeyAddress] == nil ? @"" : user[pKeyAddress];
    strApartment     = user[pKeyApartment] == nil ? @"" : user[pKeyApartment];
    strFloor         = user[pKeyFloor] == nil ? @"" : user[pKeyFloor];
    strUserObjID     = user.objectId;
}

+ (instancetype)initWithPhoneNumber:(NSString *)phoneNumber
                           password:(NSString *)password
                           fullName:(NSString *)fullName
                              email:(NSString *)email
                            address:(NSString *)address
                          apartment:(NSString *)apartment
                              floor:(NSString *)floor
{
    UserInfo *userInfo = [[UserInfo alloc] init];
    
    userInfo.strPhoneNumber  = phoneNumber;
    userInfo.strPassword     = password;
    userInfo.strFullName     = fullName;
    userInfo.strEmail        = email;
    userInfo.strAddress      = address;
    userInfo.strApartment    = apartment;
    userInfo.strFloor        = floor;
    userInfo.strUserObjID     = @"";
    
    return userInfo;
}

@end
