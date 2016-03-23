//
//  MainViewController.h
//  TusTus
//
//  Created by User on 4/12/15.
//  Copyright (c) 2015 Philip. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface SelectCategoryViewController : UIViewController<UITextFieldDelegate, UIPickerViewDataSource,UIPickerViewDelegate>
- (void) setMovingDate:(NSDate *) movingDate;
@end
