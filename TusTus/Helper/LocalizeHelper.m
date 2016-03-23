//
//  LocalizeHelper.m
//  TusTus
//
//  Created by User on 4/8/15.
//  Copyright (c) 2015 Philip. All rights reserved.
//

// LocalizeHelper.m
#import "LocalizeHelper.h"

// Singleton
static LocalizeHelper* SingleLocalSystem = nil;

// my Bundle (not the main bundle!)
static NSBundle* myBundle = nil;


@implementation LocalizeHelper


//-------------------------------------------------------------
// allways return the same singleton
//-------------------------------------------------------------
+ (LocalizeHelper*) sharedLocalSystem {
    // lazy instantiation
    if (SingleLocalSystem == nil) {
        SingleLocalSystem = [[LocalizeHelper alloc] init];
    }
    return SingleLocalSystem;
}


//-------------------------------------------------------------
// initiating
//-------------------------------------------------------------
- (id) init {
    self = [super init];
    if (self) {
        // use systems main bundle as default bundle
        myBundle = [NSBundle mainBundle];
    }
    return self;
}

- (NSArray *) getSimpleArrayData:(NSString *) key{
    NSDictionary* dataDict = [NSDictionary dictionaryWithContentsOfFile:[myBundle pathForResource:@"ArrayData" ofType:@"plist"]];
    NSArray *dataArray = [dataDict objectForKey:key];
    
    return dataArray;
}

- (NSArray *) getInventoryTitleArrayData{
    NSDictionary* dataDict = [NSDictionary dictionaryWithContentsOfFile:[myBundle pathForResource:@"ArrayData" ofType:@"plist"]];
    NSArray *dataArray = [dataDict objectForKey:arrKeyInventory];
    
    NSMutableArray *ansArray = [[NSMutableArray alloc] initWithCapacity:0];
    
    for(int i = 0; i < dataArray.count; i ++){
        NSDictionary *itemDic = [dataArray objectAtIndex:i];
        
        NSString *strTitle = [itemDic valueForKey:@"name"];
        
        [ansArray addObject:strTitle];
    }
    
    return (NSArray *)ansArray;
}

- (NSArray *) getInventoryPriceArrayData{
    NSDictionary* dataDict = [NSDictionary dictionaryWithContentsOfFile:[myBundle pathForResource:@"ArrayData" ofType:@"plist"]];
    NSArray *dataArray = [dataDict objectForKey:arrKeyInventory];
    
    NSMutableArray *ansArray = [[NSMutableArray alloc] initWithCapacity:0];
    
    for(int i = 0; i < dataArray.count; i ++){
        NSDictionary *itemDic = [dataArray objectAtIndex:i];
        
        int nPrice = [[itemDic valueForKey:@"price"] intValue];
        
        [ansArray addObject:@(nPrice)];
    }
    
    return (NSArray *)ansArray;
}


//-------------------------------------------------------------
// translate a string
//-------------------------------------------------------------
// you can use this macro:
// LocalizedString(@"Text");
- (NSString*) localizedStringForKey:(NSString*) key {
    // this is almost exactly what is done when calling the macro NSLocalizedString(@"Text",@"comment")
    // the difference is: here we do not use the systems main bundle, but a bundle
    // we selected manually before (see "setLanguage")
    return [myBundle localizedStringForKey:key value:@"" table:nil];
}


//-------------------------------------------------------------
// set a new language
//-------------------------------------------------------------
// you can use this macro:
// LocalizationSetLanguage(@"German") or LocalizationSetLanguage(@"de");
- (void) setLanguage:(NSString*) lang {
    
    // path to this languages bundle
    NSString *path = [[NSBundle mainBundle] pathForResource:lang ofType:@"lproj" ];
    if (path == nil) {
        // there is no bundle for that language
        // use main bundle instead
        myBundle = [NSBundle mainBundle];
    } else {
        
        // use this bundle as my bundle from now on:
        myBundle = [NSBundle bundleWithPath:path];
        
        // to be absolutely shure (this is probably unnecessary):
        if (myBundle == nil) {
            myBundle = [NSBundle mainBundle];
        }
    }
}


@end