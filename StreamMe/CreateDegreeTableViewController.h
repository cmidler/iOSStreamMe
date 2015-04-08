//
//  CreateDegreeTableViewController.h
//  Proximity
//
//  Created by Chase Midler on 1/16/15.
//  Copyright (c) 2015 midler. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "MainDatabase.h"
#import <Parse/Parse.h>
#import "CreateDegreeTableViewCell.h"
#import "StoreProfessionalProfile.h"

#define MAX_DEGREE_CHARS 64
@interface CreateDegreeTableViewController : UITableViewController

@property (strong, nonatomic)School* school;
- (IBAction)saveAction:(id)sender;

@property (weak, nonatomic) IBOutlet UIBarButtonItem *saveButton;
@property (strong, nonatomic) IBOutlet UITableView *degreeTableView;
@property (nonatomic, readwrite) int checkMarkedRow;
@property (strong, nonatomic) NSString* lastEditedString;
@property (strong, nonatomic) CreateDegreeTableViewCell* firstCell;
@end
