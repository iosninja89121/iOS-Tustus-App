//
//  DeliveryBookingInfo.m
//  TusTus
//
//  Created by User on 4/25/15.
//  Copyright (c) 2015 Philip. All rights reserved.
//

#import "DeliveryBookingInfo.h"

@implementation DeliveryBookingInfo
+ (instancetype) initWithObject:(PFObject *)pObj{
    DeliveryBookingInfo *bookingInfo = [[DeliveryBookingInfo alloc] init];
    
    bookingInfo.strObjectId             = pObj.objectId;
    bookingInfo.strCustomerName         = validString(pObj[pKeyCustomerName]);
    bookingInfo.strCustomerEmail        = validString(pObj[pKeyCustomerEmail]);
    bookingInfo.strCustomerAddress      = validString(pObj[pKeyCustomerAddress]);
    bookingInfo.strCustomerPhone        = validString(pObj[pKeyCustomerPhone]);
    bookingInfo.strWorkerName           = validString(pObj[pKeyWorkerName]);
    bookingInfo.strWorkerFullName       = validString(pObj[pKeyWorkerFullName]);
    bookingInfo.strWorkerPhone          = validString(pObj[pKeyWorkerPhone]);
    bookingInfo.strCustomerObjId        = validString(pObj[pKeyCustomerObjId]);
    bookingInfo.strWorkerObjId          = validString(pObj[pKeyWorkerObjId]);
    bookingInfo.nStatus                 = [(NSNumber *)pObj[pKeyStatus] integerValue];
    bookingInfo.nCateogry               = [(NSNumber *)pObj[pKeyNCategory] integerValue];
    bookingInfo.strStartAddress         = validString(pObj[pKeyStartAddress]);
    bookingInfo.strStartApartment       = validString(pObj[pKeyStartApartment]);
    bookingInfo.strStartFloor           = validString(pObj[pKeyStartFloor]);
    bookingInfo.strStartPerson          = validString(pObj[pKeyStartPerson]);
    bookingInfo.strStartPhone           = validString(pObj[pKeyStartPhone]);
    bookingInfo.strEndAddress           = validString(pObj[pKeyEndAddress]);
    bookingInfo.strEndApartment         = validString(pObj[pKeyEndApartment]);
    bookingInfo.strEndFloor             = validString(pObj[pKeyEndFloor]);
    bookingInfo.strEndPerson            = validString(pObj[pKeyEndPerson]);
    bookingInfo.strEndPhone             = validString(pObj[pKeyEndPhone]);
    bookingInfo.nPackageType            = [(NSNumber *)pObj[pKeyPackageType] integerValue];
    bookingInfo.nUrgencyType            = [(NSNumber *)pObj[pKeyUrgencyType] integerValue];
    bookingInfo.nDoubleType             = [(NSNumber *)pObj[pKeyDoubleType] integerValue];
    bookingInfo.nAmount                 = [(NSNumber *)pObj[pKeyAmount] integerValue];
    bookingInfo.arrInventoryAmountList  = (pObj[pKeyInventoryAmount] != nil)? pObj[pKeyInventoryAmount] : [[NSMutableArray alloc] init];
    bookingInfo.strComment              = validString(pObj[pKeyComment]);
    bookingInfo.nPrice                  = [(NSNumber *)pObj[pKeyPrice] integerValue];
    bookingInfo.nManagerOwn             = [(NSNumber *)pObj[pKeyManagerOwn] integerValue];
    bookingInfo.nWorkerOwn              = [(NSNumber *)pObj[pKeyWorkerOwn] integerValue];
    bookingInfo.strPublishedDate        = validString(pObj[pKeyPublishedDate]);
    bookingInfo.strAcceptedDate         = validString(pObj[pKeyAcceptedDate]);
    bookingInfo.strPickupedDate         = validString(pObj[pKeyPickupedDate]);
    bookingInfo.strCompletedDate        = validString(pObj[pKeyCompletedDate]);
    bookingInfo.nFreepaymentFlag        = [(NSNumber *)pObj[pKeyFreePaymentFlag] integerValue];
    bookingInfo.strSmsNumber            = validString(pObj[pKeySMSPhoneNumber]);
    
    return bookingInfo;
}
@end
