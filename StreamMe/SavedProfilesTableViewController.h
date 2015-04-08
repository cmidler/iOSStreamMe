//
//  SavedProfilesTableViewController.h
//  WhoYu
//
//  Created by Chase Midler on 1/25/15.
//  Copyright (c) 2015 midler. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "MainDatabase.h"
#import "SaveProfilesTableViewCell.h"
#import "ViewProfileViewController.h"
#import "SWRevealViewController.h"
#define PROFILES_PER_PAGE 10
#define PROFILE_CELL 0
#define LOADING_PROFILES_CELL 1337
@interface SavedProfilesTableViewController : UITableViewController
{
    NSMutableArray* profiles;
}
@property (strong, nonatomic) IBOutlet UITableView *profilesTableView;
@property (weak, nonatomic) IBOutlet UIBarButtonItem *sidebarButton;
@property (nonatomic, readwrite) int currentPage;
@property (nonatomic, readwrite) int totalPages;
@property (nonatomic, readwrite) double oldestTime;
@property (nonatomic, readwrite) int totalSavedProfiles;
@property (nonatomic, readwrite) int selectedCell;

@end
