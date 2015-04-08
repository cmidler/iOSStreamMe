//
//  PersonalDetailsTableViewController.h
//  Proximity
//
//  Created by Chase Midler on 1/5/15.
//  Copyright (c) 2015 midler. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "PersonalDetailsTableViewCell.h"
#import "UserProfile.h"
@interface PersonalDetailsTableViewController : UITableViewController
{
    NSArray* personalDetails;
}
@property (strong, nonatomic) IBOutlet UITableView *personalTableView;
@property (strong, nonatomic) UserProfile* profile;
@property (nonatomic, readwrite) bool isMyProfile;
@end
