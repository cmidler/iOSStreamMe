//
//  ContactInfoTableViewCell.h
//  WhoYu
//
//  Created by Chase Midler on 1/30/15.
//  Copyright (c) 2015 midler. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface ContactInfoTableViewCell : UITableViewCell
@property (weak, nonatomic) IBOutlet UILabel *typeLabel;
@property (weak, nonatomic) IBOutlet UILabel *valueLabel;
@property (weak, nonatomic) IBOutlet UILabel *saveContactLabel;

@end
