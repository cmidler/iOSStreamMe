//
//  PhoneNumbersTableViewCell.m
//  WhoYu
//
//  Created by Chase Midler on 1/26/15.
//  Copyright (c) 2015 midler. All rights reserved.
//

#import "PhoneNumbersTableViewCell.h"

@implementation PhoneNumbersTableViewCell

- (void)awakeFromNib {
    // Initialization code
}

- (void)setSelected:(BOOL)selected animated:(BOOL)animated {
    [super setSelected:selected animated:animated];

    // Configure the view for the selected state
}

// overriding
- (BOOL)canBecomeFirstResponder {
    return YES;
}
@end
