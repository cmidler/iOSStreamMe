//
//  RequestPrivateDataTableViewController.h
//  WhoYu
//
//  Created by Chase Midler on 1/28/15.
//  Copyright (c) 2015 midler. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "RequestPrivateDataTableViewCell.h"
#import "PrivateProfile.h"
#import "UserProfile.h"
#import "StorePrivateProfile.h"
#import "ViewProfileViewController.h"

#define MAX_PHONE_NUMBERS 3 // can only have 1 work, 1 mobile, and 1 home number
#define MAX_EMAIL_ADDRESSES 2 // can only have 1 work, 1 personal
#define ADD_CELL 1
#define CONTACT_CELL 0
@interface RequestPrivateDataTableViewController : UITableViewController
{
    NSMutableArray* phones;
    NSMutableArray* emails;
}
@property (weak, nonatomic) IBOutlet UIBarButtonItem *rightBarButton;
- (IBAction)rightBarButtonAction:(id)sender;
@property (strong, nonatomic) IBOutlet UITableView *requestTableView;
@property (strong, nonatomic) UserProfile* profile;
@property (nonatomic, readwrite) bool isMyProfile;
@property (strong, nonatomic) RequestPrivateDataTableViewCell* firstCell;
@end
