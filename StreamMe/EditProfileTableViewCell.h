//
//  EditProfileTableViewCell.h
//  genesis
//
//  Created by Chase Midler on 9/9/14.
//  Copyright (c) 2014 midler. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface EditProfileTableViewCell : UITableViewCell
@property (weak, nonatomic) IBOutlet UILabel *fieldTitleLabel;
@property (weak, nonatomic) IBOutlet UILabel *fieldStatusLabel;

@property (weak, nonatomic) IBOutlet UIPickerView *pickerView;
@property (weak, nonatomic) IBOutlet UITextField *nameTextField;
@property (weak, nonatomic) IBOutlet UIDatePicker *datePicker;
@property (weak, nonatomic) IBOutlet UIImageView *dropDownImageView;
@property (weak, nonatomic) IBOutlet UIActivityIndicatorView *activityIndicator;
@end
