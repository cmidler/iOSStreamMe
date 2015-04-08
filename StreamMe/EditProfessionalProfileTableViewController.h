//
//  EditProfessionalProfileTableViewController.h
//  Proximity
//
//  Created by Chase Midler on 1/15/15.
//  Copyright (c) 2015 midler. All rights reserved.
//

#import <UIKit/UIKit.h>
#import <Parse/Parse.h>
#import "MainDatabase.h"
#import "EditProfessionalProfileTableViewCell.h"
#import "StoreProfessionalProfile.h"
#import "StoreUserProfile.h"
#import "SERVICES.h"
@interface EditProfessionalProfileTableViewController : UITableViewController
{
    NSArray* editFields;
}
@property (strong, nonatomic) IBOutlet UITableView *editTableView;
- (IBAction)saveAction:(id)sender;
@property (nonatomic, readwrite) int checkMarkedRow;
@property (weak, nonatomic) IBOutlet UIBarButtonItem *saveButton;
@property (strong, nonatomic) EditProfessionalProfileTableViewCell* firstCell;
@end
