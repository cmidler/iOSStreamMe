//
//  EditSchoolsTableViewController.h
//  Proximity
//
//  Created by Chase Midler on 1/15/15.
//  Copyright (c) 2015 midler. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "EditSchoolsTableViewCell.h"
#import "StoreProfessionalProfile.h"
#import "SchoolTableViewController.h"
#define MAX_SCHOOLS 10
@interface EditSchoolsTableViewController : UITableViewController
{
    NSArray* schools;
}
@property (strong, nonatomic) IBOutlet UITableView *schoolTableView;
@property (nonatomic, readwrite) int selectedCell;
@property (weak, nonatomic) IBOutlet UIBarButtonItem *addButton;

@end
