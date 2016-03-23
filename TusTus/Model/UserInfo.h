//
//  UserInfo.h
//  ProtoDeviceMonitor
//
//  Created by User on 1/16/15.
//  Copyright (c) 2015 Philip. All rights reserved.
//

#import <Foundation/Foundation.h>

@interface UserInfo : NSObject

@property (nonatomic, retain) NSString          *strPhoneNumber;
@property (nonatomic, retain) NSString          *strPassword;
@property (nonatomic, retain) NSString          *strFullName;
@property (nonatomic, retain) NSString          *strEmail;
@property (nonatomic, retain) NSString          *strAddress;
@property (nonatomic, retain) NSString          *strApartment;
@property (nonatomic, retain) NSString          *strFloor;
@property (nonatomic, retain) NSString          *strUserObjID;

- (void)addInfoWithPFUser:(PFUser *)user;

+ (instancetype)initWithPhoneNumber:(NSString *)phoneNumber
                           password:(NSString *)password
                           fullName:(NSString *)fullName
                              email:(NSString *)email
                            address:(NSString *)address
                          apartment:(NSString *)apartment
                              floor:(NSString *)floor;

@end
