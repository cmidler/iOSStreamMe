//
//  MenuTableViewController.h
//  WhoYu
//
//  Created by Chase Midler on 1/25/15.
//  Copyright (c) 2015 midler. All rights reserved.
//

#import <UIKit/UIKit.h>
#import <Parse/Parse.h>
#import "ViewProfileViewController.h"
#import "StoreProfessionalProfile.h"
#import "MenuTableViewCell.h"
#import "StoreUserProfile.h"
@interface MenuTableViewController : UITableViewController
{
    NSArray* menuActions;
}

@property (strong, nonatomic) IBOutlet UITableView *menuTableView;
@property (nonatomic, readwrite) bool indicatorShowing;
@end
