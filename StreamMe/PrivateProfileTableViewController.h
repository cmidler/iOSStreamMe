//
//  PrivateProfileTableViewController.h
//  WhoYu
//
//  Created by Chase Midler on 1/26/15.
//  Copyright (c) 2015 midler. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "PrivateProfileTableViewCell.h"
#import "StorePrivateProfile.h"

@interface PrivateProfileTableViewController : UITableViewController

@property (weak, nonatomic) IBOutlet UIBarButtonItem *editButton;
- (IBAction)editAction:(id)sender;

@property (strong, nonatomic) IBOutlet UITableView *privateTableView;

@end
