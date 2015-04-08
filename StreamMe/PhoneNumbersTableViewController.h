//
//  PhoneNumbersTableViewController.h
//  WhoYu
//
//  Created by Chase Midler on 1/26/15.
//  Copyright (c) 2015 midler. All rights reserved.
//

#import <UIKit/UIKit.h>
#import <Parse/Parse.h>
#import "MainDatabase.h"
#import "StorePrivateProfile.h"
#import "PhoneNumbersTableViewCell.h"
#import "ViewProfileViewController.h"

#define PICKER_HEIGHT 162
#define ROW_HEIGHT 44
#define MAX_PHONE_NUMBERS 3 // can only have 1 work, 1 mobile, and 1 home number
#define MAX_PHONE_CHARS 14 //(xxx)-xxx-xxxx
#define NORMAL_CELL 0
#define ADD_CELL 1
#define PICKER_CELL 2
@interface PhoneNumbersTableViewController : UITableViewController<UIPickerViewDataSource, UIPickerViewDelegate>
{
    NSMutableArray* phoneNumbers;
    NSMutableArray* phoneNumberStrings;
    NSArray* pickerOptions;
    NSMutableArray* badCells;
}

- (IBAction)cancelAction:(id)sender;
@property (strong, nonatomic) IBOutlet UITableView *phoneNumbersTableView;
@property (weak, nonatomic) IBOutlet UIBarButtonItem *saveButton;
- (IBAction)saveAction:(id)sender;
@property (strong, nonatomic) PhoneNumbersTableViewCell* firstCell;
@property (nonatomic, readwrite) BOOL pickerViewShown;
@property (nonatomic, readwrite) int pickerViewShownIndex;
@property (strong, nonatomic) UIToolbar *toolBar;
@property (strong, nonatomic) NSString* pickerSelection;
@property (nonatomic, readwrite) bool addRowShowing;
@property (nonatomic, readwrite) bool isShowingBadCells;
@property (nonatomic, readwrite) int numberOfCells;

@end
