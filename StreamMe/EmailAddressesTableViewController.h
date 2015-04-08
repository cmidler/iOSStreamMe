//
//  EmailAddressesTableViewController.h
//  WhoYu
//
//  Created by Chase Midler on 1/28/15.
//  Copyright (c) 2015 midler. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "MainDatabase.h"
#import <Parse/Parse.h>
#import "EmailAddressesTableViewCell.h"
#import "StorePrivateProfile.h"

#define PICKER_HEIGHT 162
#define ROW_HEIGHT 44
#define MAX_EMAIL_ADDRESSES 2 // can only have 1 work email and 1 personal email
#define MAX_EMAIL_CHARS 64 //x@x.x is the format
#define NORMAL_CELL 0
#define ADD_CELL 1
#define PICKER_CELL 2

@interface EmailAddressesTableViewController : UITableViewController <UIPickerViewDataSource, UIPickerViewDelegate>
{
    NSMutableArray* emailAddresses;
    NSMutableArray* emailAddressesStrings;
    NSArray* pickerOptions;
    NSMutableArray* badCells;
}
- (IBAction)cancelAction:(id)sender;

@property (weak, nonatomic) IBOutlet UIBarButtonItem *saveButton;
- (IBAction)saveAction:(id)sender;
@property (strong, nonatomic) IBOutlet UITableView *emailTableView;
@property (strong, nonatomic) EmailAddressesTableViewCell* firstCell;
@property (nonatomic, readwrite) BOOL pickerViewShown;
@property (nonatomic, readwrite) int pickerViewShownIndex;
@property (strong, nonatomic) UIToolbar *toolBar;
@property (strong, nonatomic) NSString* pickerSelection;
@property (nonatomic, readwrite) bool addRowShowing;
@property (nonatomic, readwrite) bool isShowingBadCells;
@property (nonatomic, readwrite) int numberOfCells;

@end
