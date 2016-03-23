//
//  RegisterViewController.h
//  TusTus
//
//  Created by User on 4/10/15.
//  Copyright (c) 2015 Philip. All rights reserved.
//

#import <UIKit/UIKit.h>
#import <Nimbus/NIAttributedLabel.h>

@interface RegisterViewController : UIViewController<UITextFieldDelegate, NIAttributedLabelDelegate>
@property (nonatomic) NSString *strPhoneNumber;

@end
