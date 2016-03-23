//
//  AppDelegate.h
//  ProtoDeviceMonitor
//
//  Created by User on 1/16/15.
//  Copyright (c) 2015 Philip. All rights reserved.
//

#import <Foundation/Foundation.h>
#import <Parse/Parse.h>
#import "UserInfo.h"

@interface ParseService : NSObject

+ (id)sharedInstance;

- (void)loginWithUserName:(NSString *)strUserName
                 Password:(NSString *)strPassword
                   Result:(void (^)(NSString *))onResult;

- (void)requestPasswordWithUserName:(NSString *)strUserName
                             Result:(void (^)(NSString *))onResult;

- (void)signUpWithUserInfo:(UserInfo *)userInfo
                    Result:(void (^)(NSString *))onResult;

@end
