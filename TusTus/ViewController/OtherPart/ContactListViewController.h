//
//  ContactListViewController.h
//  TusTus
//
//  Created by User on 4/24/15.
//  Copyright (c) 2015 Philip. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface ContactListViewController : UIViewController<UISearchBarDelegate, UISearchDisplayDelegate, UITableViewDataSource, UITableViewDelegate, UIActionSheetDelegate>

@property (nonatomic) FromMode fromMode;

@end
