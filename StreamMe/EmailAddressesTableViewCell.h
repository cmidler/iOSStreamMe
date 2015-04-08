//
//  EmailAddressesTableViewCell.h
//  WhoYu
//
//  Created by Chase Midler on 1/28/15.
//  Copyright (c) 2015 midler. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface EmailAddressesTableViewCell : UITableViewCell
@property (weak, nonatomic) IBOutlet UILabel *emailTypeLabel;
@property (weak, nonatomic) IBOutlet UIImageView *dropDownImageView;
@property (weak, nonatomic) IBOutlet UITextView *emailAddressTextView;
@property (weak, nonatomic) IBOutlet UIPickerView *pickerView;
@property (weak, nonatomic) IBOutlet UIButton *addAnotherEmailButton;
@property (weak, nonatomic) IBOutlet UILabel *borderLabel;
@property (weak, nonatomic) IBOutlet UIActivityIndicatorView *activityIndicator;
@end
