//
//  SchoolTableViewCell.h
//  Proximity
//
//  Created by Chase Midler on 1/15/15.
//  Copyright (c) 2015 midler. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface SchoolTableViewCell : UITableViewCell
@property (weak, nonatomic) IBOutlet UITextView *fieldTextView;
@property (weak, nonatomic) IBOutlet UIActivityIndicatorView *activityIndicator;

@end
