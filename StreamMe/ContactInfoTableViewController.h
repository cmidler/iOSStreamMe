//
//  ContactInfoTableViewController.h
//  WhoYu
//
//  Created by Chase Midler on 1/30/15.
//  Copyright (c) 2015 midler. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "UserProfile.h"
#import "PrivateProfile.h"
#import "ContactInfoTableViewCell.h"
@import AddressBook;
@interface ContactInfoTableViewController : UITableViewController

@property (strong, nonatomic) UserProfile* profile;
@property (strong, nonatomic) PrivateProfile* privProfile;
@property (strong, nonatomic) IBOutlet UITableView *contactTableView;
@property (nonatomic, readwrite) ABAddressBookRef addressBook;
@property (strong, nonatomic) NSString* contactName;
@end
