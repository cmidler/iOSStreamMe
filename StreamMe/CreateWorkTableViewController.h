//
//  CreateWorkTableViewController.h
//  Proximity
//
//  Created by Chase Midler on 1/16/15.
//  Copyright (c) 2015 midler. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "MainDatabase.h"
#import <Parse/Parse.h>
#import "CreateWorkTableViewCell.h"
#import "StoreProfessionalProfile.h"
#define MAX_NAME_CHARS 64
#define MAX_YEAR_CHARS 4
@interface CreateWorkTableViewController : UITableViewController

@property (weak, nonatomic) IBOutlet UIBarButtonItem *saveButton;
- (IBAction)saveAction:(id)sender;
@property (strong, nonatomic) IBOutlet UITableView *workTableView;

@property (strong, nonatomic) NSString* name;
@property (strong, nonatomic) NSString* position;
@property (strong, nonatomic) NSString* end_date;
@property (nonatomic, readwrite) bool isPresent;
@property (nonatomic, readwrite) int checkMarkedRow;
@property (strong, nonatomic) CreateWorkTableViewCell* firstCell;
@end
