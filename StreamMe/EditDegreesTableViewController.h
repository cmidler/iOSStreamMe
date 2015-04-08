//
//  EditDegreesTableViewController.h
//  Proximity
//
//  Created by Chase Midler on 1/15/15.
//  Copyright (c) 2015 midler. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "EditDegreesTableViewCell.h"
#import "DegreeTableViewController.h"
#import "CreateDegreeTableViewController.h"
#import "MainDatabase.h"
#define MAX_DEGREES 3
@interface EditDegreesTableViewController : UITableViewController

@property (strong, nonatomic) NSString* school_id;
@property (strong, nonatomic) School* school;
@property (strong, nonatomic) IBOutlet UITableView *degreeTableView;
- (IBAction)addAction:(id)sender;
@property (weak, nonatomic) IBOutlet UIBarButtonItem *addButton;
@property (nonatomic, readwrite) int selectedCell;
@end
