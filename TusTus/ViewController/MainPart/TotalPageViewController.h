//
//  TotalPageViewController.h
//  TusTus
//
//  Created by User on 4/24/15.
//  Copyright (c) 2015 Philip. All rights reserved.
//

#import <UIKit/UIKit.h>
#import <PayPalMobile.h>
#import <ASIHTTPRequest.h>

@interface TotalPageViewController : UIViewController<UITableViewDataSource, UITableViewDelegate, PayPalPaymentDelegate, ASIHTTPRequestDelegate>

@end
