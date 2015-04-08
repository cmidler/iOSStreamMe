//
//  MainTutorialContentViewController.h
//  WhoYu
//
//  Created by Chase Midler on 4/1/15.
//  Copyright (c) 2015 midler. All rights reserved.
//

#import <UIKit/UIKit.h>
//#import "MainTableViewController.h"
@interface MainTutorialContentViewController : UIViewController
@property (weak, nonatomic) IBOutlet UILabel *titleLabel;
@property (weak, nonatomic) IBOutlet UIImageView *imageView;
- (IBAction)okAction:(id)sender;
@property NSUInteger pageIndex;
@property NSString *titleText;
@property NSString *imageFile;
@end
