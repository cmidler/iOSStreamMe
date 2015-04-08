//
//  StreamCollectionViewCell.h
//  WhoYu
//
//  Created by Chase Midler on 3/27/15.
//  Copyright (c) 2015 midler. All rights reserved.
//

#import <UIKit/UIKit.h>
#import <Parse/Parse.h>
@interface StreamCollectionViewCell : UICollectionViewCell
@property (weak, nonatomic) IBOutlet PFImageView *shareImageView;

@end
