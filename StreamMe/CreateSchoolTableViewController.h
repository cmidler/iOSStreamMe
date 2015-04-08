//
//  CreateSchoolTableViewController.h
//  Proximity
//
//  Created by Chase Midler on 1/16/15.
//  Copyright (c) 2015 midler. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "MainDatabase.h"
#import <Parse/Parse.h>
#import "CreateSchoolTableViewCell.h"
#import "StoreProfessionalProfile.h"

#define MAX_NAME_CHARS 64
#define MAX_YEAR_CHARS 4
@interface CreateSchoolTableViewController : UITableViewController
@property (weak, nonatomic) IBOutlet UIBarButtonItem *saveButton;
- (IBAction)saveAction:(id)sender;

@property (strong, nonatomic) IBOutlet UITableView *schoolTableView;
@property (strong, nonatomic) NSString* name;
@property (strong, nonatomic) NSString* year;
@property (nonatomic, readwrite) int type;
@property (nonatomic, readwrite) int checkMarkedRow;
@property (strong, nonatomic) CreateSchoolTableViewCell* firstCell;
@end
