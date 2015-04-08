//
//  EditWorkTableViewCell.h
//  Proximity
//
//  Created by Chase Midler on 1/15/15.
//  Copyright (c) 2015 midler. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface EditWorkTableViewCell : UITableViewCell

@property (weak, nonatomic) IBOutlet UILabel *employerLabel;
@property (weak, nonatomic) IBOutlet UILabel *positionLabel;
@property (weak, nonatomic) IBOutlet UILabel *endDateLabel;
@property (weak, nonatomic) IBOutlet UIActivityIndicatorView *activityIndicator;
@end
