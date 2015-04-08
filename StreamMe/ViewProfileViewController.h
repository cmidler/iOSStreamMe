//
//  ViewProfileViewController.h
//  genesis
//
//  Created by Chase Midler on 9/4/14.
//  Copyright (c) 2014 midler. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "MainDatabase.h"
#import "AppDelegate.h"
#import "UserProfile.h"
#import "ProfessionalProfile.h"
#import "ViewProfileTableViewCell.h"
#import "PersonalDetailsTableViewController.h"
#import "ProfessionalDetailsTableViewController.h"
#import "RequestPrivateDataTableViewController.h"
#import "ContactInfoTableViewController.h"
#import "SWRevealViewController.h"
#import "RightMenuTableViewController.h"
#import "MutualFriendsCollectionViewCell.h"

/*
 * MAX Number of sections-1 * 20 + 30  = 90
 * 3 mobile phones, 2 emails, age, interested in, relationship status, gender, 10 works  * 50 = 950
 * Schools max 10 *88 = 880
 * total is 880+90+950 = 1920
 *Max image view height is 320 so 320 + 1920 =
*/
//#define MAX_TABLEVIEW_HEIGHT 1920
//#define MAX_VIEW_HEIGHT = 2240

#define FRIENDS_PER_PAGE 10
#define FRIEND_CELL 1337
#define ADD_FRIEND_CELL 69
#define HEADER_HEIGHT 30
@interface ViewProfileViewController : UIViewController
{
    NSMutableArray* personalInformation;
    NSArray* works;
    NSArray* schools;
    NSMutableArray* friends;
}
@property (weak, nonatomic) IBOutlet UIBarButtonItem *sidebarButton;
@property (strong, nonatomic) UserProfile *profile;
@property (strong, nonatomic) ProfessionalProfile *proProfile;
@property (weak, nonatomic) IBOutlet UITableView *profileTableView;
@property (weak, nonatomic) IBOutlet UIImageView *pictureImageView;
- (IBAction)barButtonAction:(id)sender;
@property (weak, nonatomic) IBOutlet UIBarButtonItem *rightBarButton;
@property (weak, nonatomic) IBOutlet UIActivityIndicatorView *activityIndicator;
@property (strong, nonatomic) UITableViewController *tableViewController;
@property (nonatomic, readwrite) bool hasPersonalData;
@property (nonatomic, readwrite) bool hasProfessionalData;
@property (nonatomic, readwrite) bool inRangeProfile;
@property (strong, nonatomic) NSMutableArray* friendsList;
@property (nonatomic, readwrite) int numberOfFriends;
@property (nonatomic, readwrite) int totalPages;
@property (nonatomic, readwrite) int currentPage;
@property (nonatomic, readwrite) int numberOfFriendsLoaded;
@property (nonatomic, readwrite) bool errorOccurred;
@property (weak, nonatomic) IBOutlet UILabel *friendsLabel;

@property (weak, nonatomic) IBOutlet UICollectionView *mutualFriendsCollectionView;
@property (weak, nonatomic) IBOutlet UICollectionView *mutualInterestsCollectionView;

@property (weak, nonatomic) IBOutlet NSLayoutConstraint *heightConstraint;

@property (weak, nonatomic) IBOutlet NSLayoutConstraint *tableViewHeightConstraint;


/*@property (weak, nonatomic) IBOutlet UILabel *sexLabel;
@property (weak, nonatomic) IBOutlet UILabel *ageLabel;
@property (weak, nonatomic) IBOutlet UILabel *statusLabel;
@property (weak, nonatomic) IBOutlet UILabel *interestedLabel;
@property (weak, nonatomic) IBOutlet UITextView *aboutText;*/
@end
