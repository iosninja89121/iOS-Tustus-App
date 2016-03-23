//
//  AddressInfo.m
//  TusTus
//
//  Created by User on 4/24/15.
//  Copyright (c) 2015 Philip. All rights reserved.
//

#import "AddressInfo.h"

@implementation AddressInfo

- (id)init
{
    self = [super init];
    
    if(self)
    {
        _strPhone       = @"";
        _strFullName    = @"";
        _strAddress     = @"";
        _strApartment   = @"";
        _strFloor       = @"";
    }
    
    return self;
}

+ (instancetype) initWithObject:(PFObject *)pObj{
    AddressInfo *addressInfo = [[AddressInfo alloc] init];
    
    addressInfo.strPhone     = pObj[pKeyUsername];
    addressInfo.strFullName  = pObj[pKeyFullName];
    addressInfo.strAddress   = pObj[pKeyAddress];
    addressInfo.strApartment = pObj[pKeyApartment];
    addressInfo.strFloor     = pObj[pKeyFloor];
    
    return  addressInfo;
}

+ (instancetype) initWithFullName:(NSString *) strFullName
                      phoneNumber:(NSString *) strPhone
                          address:(NSString *) strAddress
                        apartment:(NSString *) strApartment
                            floor:(NSString *) strFloor{
    AddressInfo *addressInfo = [[AddressInfo alloc] init];
    
    addressInfo.strPhone = strPhone;
    addressInfo.strFullName = strFullName;
    addressInfo.strAddress = strAddress;
    addressInfo.strApartment = strApartment;
    addressInfo.strFloor = strFloor;
    
    return addressInfo;
}

- (void) initWithObject:(PFObject *)pObj{
    self.strPhone     = pObj[pKeyUsername];
    self.strFullName  = pObj[pKeyFullName];
    self.strAddress   = pObj[pKeyAddress];
    self.strApartment = pObj[pKeyApartment];
    self.strFloor     = pObj[pKeyFloor];
}

@end
