//
//  SearchAddressViewController.h
//  TusTus
//
//  Created by User on 4/11/15.
//  Copyright (c) 2015 Philip. All rights reserved.
//

#import <UIKit/UIKit.h>
#import <ASIHTTPRequest.h>

@interface SearchAddressViewController : UIViewController<UITableViewDataSource, UITableViewDelegate, UITextFieldDelegate, ASIHTTPRequestDelegate>
@property (nonatomic) FromMode fromMode;
@end
