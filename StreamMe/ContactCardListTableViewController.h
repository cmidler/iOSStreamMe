//
//  ContactCardListTableViewController.h
//  WhoYu
//
//  Created by Chase Midler on 3/9/15.
//  Copyright (c) 2015 midler. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "ContactCardListTableViewCell.h"
#import "MainDatabase.h"
#import "ContactCardViewController.h"
#import "SWRevealViewController.h"
#define PROFILES_PER_PAGE 10
#define PROFILE_CELL 0
#define LOADING_PROFILES_CELL 1337
@interface ContactCardListTableViewController : UITableViewController
{
    NSMutableArray* contacts;
}
@property (strong, nonatomic) IBOutlet UITableView *contactTableView;
@property (weak, nonatomic) IBOutlet UIBarButtonItem *sidebarButton;
@property (nonatomic, readwrite) int currentPage;
@property (nonatomic, readwrite) int totalPages;
@property (nonatomic, readwrite) double oldestTime;
@property (nonatomic, readwrite) int totalSavedContacts;
@property (nonatomic, readwrite) int selectedCell;
@end
