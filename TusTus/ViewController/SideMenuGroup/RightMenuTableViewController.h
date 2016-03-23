//
//  RightMenuTableViewController.h
//  TusTus
//
//  Created by User on 4/12/15.
//  Copyright (c) 2015 Philip. All rights reserved.
//

#import <UIKit/UIKit.h>
#import <MessageUI/MessageUI.h>
#import <MessageUI/MFMessageComposeViewController.h>
#import <MessageUI/MFMailComposeViewController.h>

@interface RightMenuTableViewController : UITableViewController<UIActionSheetDelegate, MFMailComposeViewControllerDelegate, MFMessageComposeViewControllerDelegate>

@end
