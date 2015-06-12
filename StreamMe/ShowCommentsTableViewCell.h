//
//  ShowCommentsTableViewCell.h
//  StreamMe
//
//  Created by Chase Midler on 6/8/15.
//  Copyright (c) 2015 StreamMe. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface ShowCommentsTableViewCell : UITableViewCell
@property (weak, nonatomic) IBOutlet UILabel *timeLabel;
@property (weak, nonatomic) IBOutlet UILabel *usernameLabel;
@property (weak, nonatomic) IBOutlet UILabel *commentLabel;
@property (weak, nonatomic) IBOutlet UIButton *moreButton;

@end
