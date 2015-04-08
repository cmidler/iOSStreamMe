//
//  MutualFriendsCollectionViewCell.h
//  WhoYu
//
//  Created by Chase Midler on 3/9/15.
//  Copyright (c) 2015 midler. All rights reserved.
//

#import <UIKit/UIKit.h>
#import <Parse/Parse.h>
@interface MutualFriendsCollectionViewCell : UICollectionViewCell
@property (weak, nonatomic) IBOutlet PFImageView *pictureImageView;
@property (weak, nonatomic) IBOutlet UILabel *nameLabel;
@property (weak, nonatomic) IBOutlet UIActivityIndicatorView *activityIndicator;

@end
