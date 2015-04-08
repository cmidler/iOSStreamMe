//
//  FilterViewController.h
//  whoYu
//
//  Created by Chase Midler on 10/2/14.
//  Copyright (c) 2014 midler. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "MainDatabase.h"
#import <Parse/Parse.h>
#import "StoreSexFilter.h"
#import "FilterTableViewCell.h"
#define PICKER_HEIGHT 162
#define TOOLBAR_HEIGHT 44
@interface FilterViewController : UIViewController <UIPickerViewDataSource, UIPickerViewDelegate>
{
    NSArray* filters;
    NSMutableArray* options;
}

@property (weak, nonatomic) IBOutlet UITableView *filterTableView;
@property (nonatomic, readwrite) int selectedCell;
@property (nonatomic, readwrite) bool pickerViewShown;
@property (nonatomic, readwrite) int pickerViewSection;
@property (strong, nonatomic) NSString* pickerSelection;
@property (strong, nonatomic) NSString* sexFilter;
@property (strong, nonatomic) NSString* eventFilter;
@property (strong, nonatomic) UIToolbar *toolBar;

- (IBAction)saveAction:(id)sender;

@end
