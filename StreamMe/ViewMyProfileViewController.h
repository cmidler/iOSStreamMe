//
//  ViewMyProfileViewController.h
//  WhoYu
//
//  Created by Chase Midler on 3/5/15.
//  Copyright (c) 2015 midler. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "ViewMyProfileTableViewCell.h"
#import "SWRevealViewController.h"
#import "StoreProfessionalProfile.h"
#import "StoreUserProfile.h"
#import "RightMenuTableViewController.h"
#define MAX_CHARS 128
#define HEADER_HEIGHT 30
#define FIRST_HEADER_HEIGHT 10
#define MAX_WORKS 10
#define MAX_SCHOOLS 10
@interface ViewMyProfileViewController : UIViewController
{
    NSMutableArray* personalInformation;
    NSArray* works;
    NSArray* schools;
}
@property (weak, nonatomic) IBOutlet UIBarButtonItem *sidebarButton;
@property (weak, nonatomic) IBOutlet UIBarButtonItem *rightBarButton;
@property (weak, nonatomic) IBOutlet UITableView *profileTableView;
@property (weak, nonatomic) IBOutlet UIImageView *pictureImageView;
@property (weak, nonatomic) IBOutlet UIActivityIndicatorView *activityIndicator;
@property (weak, nonatomic) IBOutlet NSLayoutConstraint *heightConstraint;
@property (weak, nonatomic) IBOutlet UITextView *aboutTextView;
@property (weak, nonatomic) IBOutlet NSLayoutConstraint *tableViewHeightConstraint;
@property (weak, nonatomic) IBOutlet UILabel *countLabel;
@property (nonatomic, readwrite) bool hasProfessionalData;

@end
