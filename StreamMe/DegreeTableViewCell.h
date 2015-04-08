//
//  DegreeTableViewCell.h
//  Proximity
//
//  Created by Chase Midler on 1/16/15.
//  Copyright (c) 2015 midler. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface DegreeTableViewCell : UITableViewCell

@property (weak, nonatomic) IBOutlet UITextView *degreeTextView;
@property (weak, nonatomic) IBOutlet UIActivityIndicatorView *activityIndicator;
@end
