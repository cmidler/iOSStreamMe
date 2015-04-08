//
//  RequestPrivateDataTableViewCell.h
//  WhoYu
//
//  Created by Chase Midler on 1/28/15.
//  Copyright (c) 2015 midler. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface RequestPrivateDataTableViewCell : UITableViewCell
@property (weak, nonatomic) IBOutlet UILabel *requestTypeLabel;
@property (weak, nonatomic) IBOutlet UILabel *requestValueLabel;
@property (weak, nonatomic) IBOutlet UIActivityIndicatorView *activityIndicator;
@property (weak, nonatomic) IBOutlet UILabel *addLabel;

@end
