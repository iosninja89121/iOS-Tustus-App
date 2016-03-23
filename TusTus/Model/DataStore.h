//
//  DataStore.h
//  TusTus
//
//  Created by User on 4/24/15.
//  Copyright (c) 2015 Philip. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "AddressInfo.h"

@interface DataStore : NSObject
@property (nonatomic, strong) NSMutableArray *arrContacts;
@property (nonatomic, strong) NSMutableArray *arrCompletedBooking;
@property (nonatomic, strong) NSMutableArray *arrCurrentBooking;
@property (nonatomic, strong) NSMutableArray *arrCity;

@property (nonatomic, strong) AddressInfo    *addressInfoForPickup;
@property (nonatomic, strong) AddressInfo    *addressInfoForDropOff;

@property (nonatomic, strong) NSString       *strMovingDate;
@property (nonatomic)         CategoryMode   nCategory;
@property (nonatomic)        BOOL            flgDoubleChecked;
@property (nonatomic)        NSInteger       nWanaSend;
@property (nonatomic)        NSInteger       nUrgency;
@property (nonatomic)        NSInteger       nNumber;

@property (nonatomic)        BOOL            flgElevatorPickup;
@property (nonatomic)        BOOL            flgElevatorDropoff;

@property (nonatomic, strong) NSString       *strComment;
@property (nonatomic, strong) NSString       *strAutoSms;

@property (nonatomic, strong) NSMutableArray *arrInventoryNumber;

@property (nonatomic)        double         dblDistance;
@property (nonatomic)        NSInteger      nPrice;

@property (nonatomic)        NSInteger      nCurYear;
@property (nonatomic)        NSInteger      nCurMonth;
@property (nonatomic)        NSInteger      nCurDay;
@property (nonatomic)        NSInteger      nCurHour;
@property (nonatomic)        NSInteger      nCurMinute;
@property (nonatomic)        NSInteger      nCurDayofWeek;

@property (nonatomic, strong) NSString       *strSearchAddress;

+ (DataStore *) instance;
- (void) reset;

@end
