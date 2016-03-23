//
//  EditContactViewController.h
//  TusTus
//
//  Created by User on 4/24/15.
//  Copyright (c) 2015 Philip. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "AddressInfo.h"

@interface EditContactViewController : UIViewController<UITextFieldDelegate>
@property (nonatomic, strong) AddressInfo *addressInfo;
@end
