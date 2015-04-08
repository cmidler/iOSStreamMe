//
//  SettingsViewController.h
//  WhoYu
//
//  Created by Chase Midler on 3/5/15.
//  Copyright (c) 2015 midler. All rights reserved.
//

#import <UIKit/UIKit.h>
#import <MessageUI/MessageUI.h>
#import "SettingsTableViewCell.h"
#import "MainDatabase.h"
#import "AppDelegate.h"

@interface SettingsViewController : UIViewController<MFMailComposeViewControllerDelegate>
{
    NSArray* settings;
}

@property (weak, nonatomic) IBOutlet UIBarButtonItem *sidebarButton;
@property (weak, nonatomic) IBOutlet UITableView *settingsTableView;
@property (strong, nonatomic) UIActivityIndicatorView *spinner;
@end
