//
//  AppDelegate.h
//  TusTus
//
//  Created by User on 4/7/15.
//  Copyright (c) 2015 Philip. All rights reserved.
//

#import <UIKit/UIKit.h>
#import <MFSideMenu.h>



@class MainNavigationController;

extern UserInfo                                     *g_myInfo;
extern MFSideMenuContainerViewController            *g_sideMenuController;
extern MainNavigationController                     *g_mainNav;

static CFStringRef charsToEscape = CFSTR("&=");
static CFStringRef charsUnchanged = CFSTR("%");

@interface AppDelegate : UIResponder <UIApplicationDelegate>

@property (strong, nonatomic) UIWindow *window;

+(NSString *) URLEncodeString:(NSString *) str;
+(NSString *) URLEncodeStringForWindows1255:(NSString *) str;

+ (float) getRealWidthFrom:(float)height content:(NSString *)content font:(UIFont *)font;
+ (float) getRealWidthFrom:(float)height content:(NSString *)content fontname:(NSString *)fontname fontsize:(float)fontsize;

+ (float) getRealHeightFrom:(float)width content:(NSString *)content font:(UIFont *)font;
+ (float) getRealHeightFrom:(float)width content:(NSString *)content fontname:(NSString *)fontname fontsize:(float)fontsize;

@end

