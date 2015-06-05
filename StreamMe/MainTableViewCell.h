//
//  MainTableViewCell.h
//  genesis
//
//  Created by Chase Midler on 9/3/14.
//  Copyright (c) 2014 midler. All rights reserved.
//

#import <UIKit/UIKit.h>
#import <Parse/Parse.h>
#import <ParseUI/ParseUI.h>
//#import "StreamCollectionViewCell.h"
@interface MainTableViewCell : PFTableViewCell
@property (weak, nonatomic) IBOutlet UIActivityIndicatorView *activityIndicator;
//@property (weak, nonatomic) IBOutlet UICollectionView *streamCollectionView;
//-(void)setCollectionViewDataSourceDelegate:(id<UICollectionViewDataSource, UICollectionViewDelegate>)dataSourceDelegate index:(NSInteger)index;
@property (weak, nonatomic) IBOutlet PFImageView *shareImageView;

@end
