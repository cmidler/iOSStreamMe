//
//  RightMenuTableViewController.h
//  WhoYu
//
//  Created by Chase Midler on 3/6/15.
//  Copyright (c) 2015 midler. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "RightMenuTableViewCell.h"
#import "MainDatabase.h"
#import "StoreUserProfile.h"
#import "UserNotesViewController.h"
#import "PrivateProfile.h"
#import "ContactCardViewController.h"
#define RIGHT_SLIDE 60
@interface RightMenuTableViewController : UITableViewController
{
    NSArray* menuActions;
    NSArray* menuImages;
}
@property (strong, nonatomic) IBOutlet UITableView *menuTableView;
@property (strong, nonatomic) NSString* originController;
@property (strong, nonatomic) UserProfile* profile;
@property (strong, nonatomic) PrivateProfile* privProfile;
@property (strong, nonatomic) NSMutableArray* friendsList;
@property (nonatomic, readwrite) int numberOfFriends;
@end
