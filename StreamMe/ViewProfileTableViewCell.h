//
//  ViewProfileTableViewCell.h
//  Proximity
//
//  Created by Chase Midler on 1/5/15.
//  Copyright (c) 2015 midler. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface ViewProfileTableViewCell : UITableViewCell
@property (weak, nonatomic) IBOutlet UILabel *viewTypeLabel;
@property (weak, nonatomic) IBOutlet UILabel *valueLabel;
@property (weak, nonatomic) IBOutlet UILabel *nameLabel;
@property (weak, nonatomic) IBOutlet UILabel *typeLabel;
@property (weak, nonatomic) IBOutlet UILabel *dateLabel;
@property (weak, nonatomic) IBOutlet UILabel *degreesLabel;
@end
