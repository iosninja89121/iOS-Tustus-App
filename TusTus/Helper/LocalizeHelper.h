//
//  LocalizeHelper.h
//  TusTus
//
//  Created by User on 4/8/15.
//  Copyright (c) 2015 Philip. All rights reserved.
//

//LocalizeHelper.h

#import <Foundation/Foundation.h>

// some macros (optional, but makes life easy)

// Use "LocalizedString(key)" the same way you would use "NSLocalizedString(key,comment)"
#define LocalizedString(key) [[LocalizeHelper sharedLocalSystem] localizedStringForKey:(key)]
#define LocalizedSimpleArrayData(key) [[LocalizeHelper sharedLocalSystem] getSimpleArrayData:(key)]
#define LocalizedInventoryTitleArrayData [[LocalizeHelper sharedLocalSystem] getInventoryTitleArrayData]
#define LocalizedInventoryPriceArrayData [[LocalizeHelper sharedLocalSystem] getInventoryPriceArrayData]

// "language" can be (for american english): "en", "en-US", "english". Analogous for other languages.
#define LocalizationSetLanguage(language) [[LocalizeHelper sharedLocalSystem] setLanguage:(language)]

@interface LocalizeHelper : NSObject

// a singleton:
+ (LocalizeHelper*) sharedLocalSystem;

// this gets the string localized:
- (NSString*) localizedStringForKey:(NSString*) key;

// this gets the simple array data localized:
- (NSArray *) getSimpleArrayData:(NSString *) key;

- (NSArray *) getInventoryTitleArrayData;
- (NSArray *) getInventoryPriceArrayData;

//set a new language:
- (void) setLanguage:(NSString*) lang;

@end