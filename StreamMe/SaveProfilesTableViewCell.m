//
//  SaveProfilesTableViewCell.m
//  WhoYu
//
//  Created by Chase Midler on 1/25/15.
//  Copyright (c) 2015 midler. All rights reserved.
//

#import "SaveProfilesTableViewCell.h"

@implementation SaveProfilesTableViewCell

- (void)awakeFromNib {
    // Initialization code
}

- (void)setSelected:(BOOL)selected animated:(BOOL)animated {
    [super setSelected:selected animated:animated];

    // Configure the view for the selected state
}

- (void) layoutSubviews
{
    [super layoutSubviews];
    self.profileImageView.frame = CGRectMake( 0, 2.5, 100, 100 );
}

@end
