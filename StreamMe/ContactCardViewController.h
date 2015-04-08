//
//  ContactCardViewController.h
//  WhoYu
//
//  Created by Chase Midler on 3/9/15.
//  Copyright (c) 2015 midler. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "ContactCardTableViewCell.h"
#import "UserProfile.h"
#import "PrivateProfile.h"
#import "ViewProfileViewController.h"
@import AddressBook;
@interface ContactCardViewController : UIViewController
{
    NSArray* phones;
    NSArray* emails;
}
@property (weak, nonatomic) IBOutlet UIImageView *pictureImageView;
@property (weak, nonatomic) IBOutlet UILabel *nameLabel;
@property (weak, nonatomic) IBOutlet UIBarButtonItem *saveButton;
@property (weak, nonatomic) IBOutlet UITableView *contactTableView;
@property (strong, nonatomic) UserProfile* profile;
@property (strong, nonatomic) PrivateProfile* privProfile;
- (IBAction)saveAction:(id)sender;
- (IBAction)backAction:(id)sender;
@property (weak, nonatomic) IBOutlet UIActivityIndicatorView *activityIndicator;
@property (nonatomic, readwrite) ABAddressBookRef addressBook;
@property (weak, nonatomic) IBOutlet UIButton *deleteButton;
- (IBAction)deleteAction:(id)sender;
@property (strong, nonatomic) NSString* contactName;
@end
