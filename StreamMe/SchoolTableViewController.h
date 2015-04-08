//
//  SchoolTableViewController.h
//  Proximity
//
//  Created by Chase Midler on 1/15/15.
//  Copyright (c) 2015 midler. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "MainDatabase.h"
#import <Parse/Parse.h>
#import "SchoolTableViewCell.h"
#import "StoreProfessionalProfile.h"
#import "EditDegreesTableViewController.h"
#define MAX_NAME_CHARS 64
#define MAX_YEAR_CHARS  4
@interface SchoolTableViewController : UITableViewController <UITextViewDelegate>

@property (strong, nonatomic) IBOutlet UITableView *schoolTableView;
@property (weak, nonatomic) IBOutlet UIBarButtonItem *saveButton;
- (IBAction)saveAction:(id)sender;
@property (strong, nonatomic) School* school;
@property (strong, nonatomic) NSString* school_id;
@property (strong, nonatomic) NSString* name;
@property (nonatomic, readwrite) int type;
@property (strong, nonatomic) NSString* year;
@property (nonatomic, readwrite) int checkMarkedRow;
@property (strong, nonatomic) SchoolTableViewCell* firstCell;
@end
