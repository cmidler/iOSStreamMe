//
//  ViewStreamCollectionViewCell.m
//  WhoYu
//
//  Created by Chase Midler on 3/30/15.
//  Copyright (c) 2015 midler. All rights reserved.
//

#import "ViewStreamCollectionViewCell.h"

@implementation ViewStreamCollectionViewCell

- (void)awakeFromNib
{
    [super awakeFromNib];
    
    NSLog(@"awaking from nib");
    
    //self.shareImageView.autoresizingMask = UIViewAutoresizingFlexibleHeight | UIViewAutoresizingFlexibleWidth;
    self.shareImageView.translatesAutoresizingMaskIntoConstraints = YES;
    
    //self.usernameLabel.autoresizingMask = UIViewAutoresizingFlexibleHeight | UIViewAutoresizingFlexibleWidth;
    self.usernameLabel.translatesAutoresizingMaskIntoConstraints = YES;
    
    //self.createdLabel.autoresizingMask = UIViewAutoresizingFlexibleHeight | UIViewAutoresizingFlexibleWidth;
    self.createdLabel.translatesAutoresizingMaskIntoConstraints = YES;
    
    //self.captionTextView.autoresizingMask = UIViewAutoresizingFlexibleHeight | UIViewAutoresizingFlexibleWidth;
    self.captionTextView.translatesAutoresizingMaskIntoConstraints = YES;
    //self.shareImageView.hidden = YES;
}

/*- (void) layoutSubviews
{
    [super layoutSubviews];
    NSLog(@"frame is %f, %f", self.contentView.frame.size.width, self.contentView.frame.size.height);
    self.frame = self.contentView.frame;
}*/
@end
