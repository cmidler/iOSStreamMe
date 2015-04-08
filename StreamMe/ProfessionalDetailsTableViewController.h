//
//  ProfessionalDetailsTableViewController.h
//  Proximity
//
//  Created by Chase Midler on 1/5/15.
//  Copyright (c) 2015 midler. All rights reserved.
//

#import <UIKit/UIKit.h>
#import <Parse/Parse.h>
#import "ProfessionalDetailsTableViewCell.h"
#import "ProfessionalProfile.h"
#import "SchoolTableViewController.h"
#import "WorkTableViewController.h"
@interface ProfessionalDetailsTableViewController : UITableViewController
{
    NSArray* schools;
    NSArray* works;
}
@property (strong, nonatomic) IBOutlet UITableView *professionalTableView;
@property (nonatomic, readwrite) bool isMyProfile;
@property (weak, nonatomic) IBOutlet UIBarButtonItem *editButton;
@property (strong, nonatomic)ProfessionalProfile* proProfile;
@property (strong, nonatomic)NSString* user_id;
@property (nonatomic, readwrite) int schoolShowingCount;
@property (nonatomic, readwrite) int workShowingCount;
@property (nonatomic, readwrite) bool isShowing;
@property (nonatomic, readwrite) int selectedCell;
@end
