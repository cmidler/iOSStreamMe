//
//  EditWorkTableViewController.h
//  Proximity
//
//  Created by Chase Midler on 1/15/15.
//  Copyright (c) 2015 midler. All rights reserved.
//

#import <UIKit/UIKit.h>
#import <sqlite3.h>
#import <Parse/Parse.h>
#import "StoreProfessionalProfile.h"
#import "EditWorkTableViewCell.h"
#import "WorkTableViewController.h"
#define MAX_WORKS 10
@interface EditWorkTableViewController : UITableViewController
{
    NSArray* works;
}
@property (strong, nonatomic) IBOutlet UITableView *workTableView;
@property (weak, nonatomic) IBOutlet UIBarButtonItem *addButton;
@property (nonatomic, readwrite) int selectedCell;
@end
