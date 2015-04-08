//
//  ViewMyProfileTableViewCell.h
//  WhoYu
//
//  Created by Chase Midler on 3/5/15.
//  Copyright (c) 2015 midler. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface ViewMyProfileTableViewCell : UITableViewCell
@property (weak, nonatomic) IBOutlet UILabel *viewTypeLabel;
@property (weak, nonatomic) IBOutlet UILabel *valueLabel;
@property (weak, nonatomic) IBOutlet UILabel *nameLabel;
@property (weak, nonatomic) IBOutlet UILabel *typeLabel;
@property (weak, nonatomic) IBOutlet UILabel *dateLabel;
@property (weak, nonatomic) IBOutlet UILabel *degreesLabel;
@property (weak, nonatomic) IBOutlet UILabel *addProfessionalLabel;
@end
