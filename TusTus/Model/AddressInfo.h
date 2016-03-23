//
//  AddressInfo.h
//  TusTus
//
//  Created by User on 4/24/15.
//  Copyright (c) 2015 Philip. All rights reserved.
//

#import <Foundation/Foundation.h>

@interface AddressInfo : NSObject
@property (nonatomic, strong) NSString *strPhone;
@property (nonatomic, strong) NSString *strFullName;
@property (nonatomic, strong) NSString *strAddress;
@property (nonatomic, strong) NSString *strApartment;
@property (nonatomic, strong) NSString *strFloor;

+ (instancetype) initWithObject:(PFObject *)pObj;

+ (instancetype) initWithFullName:(NSString *) strFullName
                      phoneNumber:(NSString *) strPhone
                          address:(NSString *) strAddress
                        apartment:(NSString *) strApartment
                            floor:(NSString *) strFloor;

- (void) initWithObject:(PFObject *)pObj;

@end
