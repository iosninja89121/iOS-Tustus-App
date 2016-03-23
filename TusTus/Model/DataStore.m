//
//  DataStore.m
//  TusTus
//
//  Created by User on 4/24/15.
//  Copyright (c) 2015 Philip. All rights reserved.
//

#import "DataStore.h"

@implementation DataStore

static DataStore *instance = nil;
+ (DataStore *) instance
{
    @synchronized (self) {
        if (instance == nil) {
            instance = [[DataStore alloc] init];
        }
    }
    return instance;
}

- (id) init
{
    self = [super init];
    if (self) {
        _arrContacts = [[NSMutableArray alloc] init];
        _arrCompletedBooking = [[NSMutableArray alloc] init];
        _arrCurrentBooking = [[NSMutableArray alloc] init];
        _arrCity = [[NSMutableArray alloc] init];
        _addressInfoForPickup  = [[AddressInfo alloc] init];
        _addressInfoForDropOff = [[AddressInfo alloc] init];
        _arrInventoryNumber = [[NSMutableArray alloc] init];
    }
    return self;
}

- (void) reset
{
    [_arrContacts removeAllObjects];
    [_arrCompletedBooking removeAllObjects];
    [_arrCurrentBooking removeAllObjects];
    [_arrCity removeAllObjects];
    [_arrInventoryNumber removeAllObjects];
}

@end
