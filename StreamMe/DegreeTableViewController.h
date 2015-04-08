//
//  DegreeTableViewController.h
//  Proximity
//
//  Created by Chase Midler on 1/16/15.
//  Copyright (c) 2015 midler. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "MainDatabase.h"
#import <Parse/Parse.h>
#import "StoreProfessionalProfile.h"
#import "DegreeTableViewCell.h"
#define MAX_DEGREE_CHARS 64
@interface DegreeTableViewController : UITableViewController<UIAlertViewDelegate>

@property (strong, nonatomic) IBOutlet UITableView *degreeTableView;
@property (weak, nonatomic) IBOutlet UIBarButtonItem *saveButton;
- (IBAction)saveAction:(id)sender;
@property (strong, nonatomic) School* school;
@property (strong, nonatomic) NSArray* degree;
@property (nonatomic, readwrite) int checkMarkedRow;
@property (strong, nonatomic) NSString* lastEditedString;
@property (strong, nonatomic) DegreeTableViewCell* firstCell;
@end
