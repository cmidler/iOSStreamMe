//
//  ViewStreamCollectionViewCell.h
//  WhoYu
//
//  Created by Chase Midler on 3/30/15.
//  Copyright (c) 2015 midler. All rights reserved.
//

#import <UIKit/UIKit.h>
#import <Parse/Parse.h>
@interface ViewStreamCollectionViewCell : UICollectionViewCell
@property (weak, nonatomic) IBOutlet PFImageView *shareImageView;
@property (weak, nonatomic) IBOutlet UILabel *usernameLabel;
@property (weak, nonatomic) IBOutlet UITextView *captionTextView;


@end
