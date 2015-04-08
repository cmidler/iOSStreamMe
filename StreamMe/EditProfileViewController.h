//
//  EditProfileViewController.h
//  genesis
//
//  Created by Chase Midler on 9/9/14.
//  Copyright (c) 2014 midler. All rights reserved.
//

#import <UIKit/UIKit.h>
#import <Parse/Parse.h>
#import "MainDatabase.h"
#import "SERVICES.h"
#import "StoreUserProfile.h"
#import "EditProfileTableViewCell.h"

#define MAX_NAME_CHARS 16
#define PICKER_HEIGHT 162
#define TOOL_BAR_HEIGHT 44
@interface EditProfileViewController : UIViewController <UITableViewDelegate, UIPickerViewDataSource, UIPickerViewDelegate>
{
    NSArray* editFields;
    NSArray* options;
}
@property (weak, nonatomic) IBOutlet UITableView *editMeTable;
- (IBAction)saveAction:(id)sender;
@property (weak, nonatomic) IBOutlet UIBarButtonItem *saveButton;
@property (nonatomic, readwrite) BOOL pickerViewShown;
@property (nonatomic, readwrite) int pickerViewShownIndex;
@property (strong, nonatomic) UIToolbar *toolBar;
@property (strong, nonatomic) NSString* firstName;
@property (strong, nonatomic) NSString* interestedIn;
@property (strong, nonatomic) NSString* relationshipStatus;
@property (strong, nonatomic) NSString* birthday;
@property (strong, nonatomic) NSString* sex;
@property (strong, nonatomic) NSString* pickerSelection;
- (IBAction)dateValueChanged:(id)sender;
@property (strong, nonatomic) EditProfileTableViewCell* firstCell;
@property (strong, nonatomic) NSString* originalOption;
@end
