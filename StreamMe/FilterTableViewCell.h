//
//  FilterTableViewCell.h
//  genesis
//
//  Created by Chase Midler on 10/2/14.
//  Copyright (c) 2014 midler. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface FilterTableViewCell : UITableViewCell

@property (weak, nonatomic) IBOutlet UILabel *filterLabel;
@property (weak, nonatomic) IBOutlet UIImageView *dropDownImageView;
@property (weak, nonatomic) IBOutlet UIPickerView *pickerView;

@property (readwrite, strong, nonatomic) UIView *inputView;
@property (readwrite, strong, nonatomic) UIView *inputAccessoryView;
@end
