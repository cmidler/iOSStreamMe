//
//  FilterTableViewCell.m
//  genesis
//
//  Created by Chase Midler on 10/2/14.
//  Copyright (c) 2014 midler. All rights reserved.
//

#import "FilterTableViewCell.h"

@implementation FilterTableViewCell

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
