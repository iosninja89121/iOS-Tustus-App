//
//  DeliveryBookingInfo.h
//  TusTus
//
//  Created by User on 4/25/15.
//  Copyright (c) 2015 Philip. All rights reserved.
//

#import <Foundation/Foundation.h>

@interface DeliveryBookingInfo : NSObject
@property (nonatomic, strong) NSString *strObjectId;
@property (nonatomic, strong) NSString *strCustomerName;
@property (nonatomic, strong) NSString *strCustomerEmail;
@property (nonatomic, strong) NSString *strCustomerAddress;
@property (nonatomic, strong) NSString *strCustomerPhone;
@property (nonatomic, strong) NSString *strWorkerName;
@property (nonatomic, strong) NSString *strWorkerFullName;
@property (nonatomic, strong) NSString *strWorkerPhone;
@property (nonatomic, strong) NSString *strCustomerObjId;
@property (nonatomic, strong) NSString *strWorkerObjId;
@property (nonatomic)         NSInteger nStatus;
@property (nonatomic)         NSInteger nCateogry;
@property (nonatomic, strong) NSString *strStartAddress;
@property (nonatomic, strong) NSString *strStartApartment;
@property (nonatomic, strong) NSString *strStartFloor;
@property (nonatomic, strong) NSString *strStartPerson;
@property (nonatomic, strong) NSString *strStartPhone;
@property (nonatomic, strong) NSString *strEndAddress;
@property (nonatomic, strong) NSString *strEndApartment;
@property (nonatomic, strong) NSString *strEndFloor;
@property (nonatomic, strong) NSString *strEndPerson;
@property (nonatomic, strong) NSString *strEndPhone;
@property (nonatomic)         NSInteger nPackageType;
@property (nonatomic)         NSInteger nUrgencyType;
@property (nonatomic)         NSInteger nDoubleType;
@property (nonatomic)         NSInteger nAmount;
@property (nonatomic, strong) NSMutableArray  *arrInventoryAmountList;
@property (nonatomic, strong) NSString *strComment;
@property (nonatomic)         NSInteger nPrice;
@property (nonatomic)         NSInteger nManagerOwn;
@property (nonatomic)         NSInteger nWorkerOwn;
@property (nonatomic, strong) NSString *strPublishedDate;
@property (nonatomic, strong) NSString *strAcceptedDate;
@property (nonatomic, strong) NSString *strPickupedDate;
@property (nonatomic, strong) NSString *strCompletedDate;
@property (nonatomic)         NSInteger nFreepaymentFlag;
@property (nonatomic, strong) NSString *strSmsNumber;

+ (instancetype) initWithObject:(PFObject *)pObj;
@end
