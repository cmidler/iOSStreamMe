//
//  PhoneNumbersTableViewCell.h
//  WhoYu
//
//  Created by Chase Midler on 1/26/15.
//  Copyright (c) 2015 midler. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface PhoneNumbersTableViewCell : UITableViewCell
@property (weak, nonatomic) IBOutlet UILabel *phoneTypeLabel;
@property (weak, nonatomic) IBOutlet UIImageView *dropDownImageView;
@property (weak, nonatomic) IBOutlet UITextView *phoneNumberTextView;
@property (weak, nonatomic) IBOutlet UIPickerView *pickerView;
@property (weak, nonatomic) IBOutlet UIButton *addAnotherPhoneButton;
@property (weak, nonatomic) IBOutlet UILabel *borderLabel;
@property (weak, nonatomic) IBOutlet UIActivityIndicatorView *activityIndicator;
@end
