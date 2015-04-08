//
//  EditProfileTypeTableViewController.h
//  WhoYu
//
//  Created by Chase Midler on 2/7/15.
//  Copyright (c) 2015 midler. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "EditProfileTypeTableViewCell.h"
#import "EditProfessionalProfileTableViewController.h"
#import "EditPrivateProfileTableViewController.h"
#import "EditProfileViewController.h"

@interface EditProfileTypeTableViewController : UITableViewController
{
    NSArray* editFields;
}
@property (strong, nonatomic) IBOutlet UITableView *editTableView;

@end
