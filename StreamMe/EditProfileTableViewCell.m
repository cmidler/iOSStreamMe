//
//  EditProfileTableViewCell.m
//  genesis
//
//  Created by Chase Midler on 9/9/14.
//  Copyright (c) 2014 midler. All rights reserved.
//

#import "EditProfileTableViewCell.h"

@implementation EditProfileTableViewCell

- (id)initWithStyle:(UITableViewCellStyle)style reuseIdentifier:(NSString *)reuseIdentifier
{
    self = [super initWithStyle:style reuseIdentifier:reuseIdentifier];
    if (self) {
        // Initialization code
    }
    return self;
}

- (void)awakeFromNib
{
    // Initialization code
}

- (void)setSelected:(BOOL)selected animated:(BOOL)animated
{
    [super setSelected:selected animated:animated];

    // Configure the view for the selected state
}

// overriding
- (BOOL)canBecomeFirstResponder {
    return YES;
}



@end
