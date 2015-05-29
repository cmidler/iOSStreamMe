//
//  MainTutorialContentViewController.h
//  WhoYu
//
//  Created by Chase Midler on 4/1/15.
//  Copyright (c) 2015 midler. All rights reserved.
//

#import <UIKit/UIKit.h>
#import <Parse/Parse.h>
#define EMAIL_TAG 1337
//#import "MainTableViewController.h"
@interface MainTutorialContentViewController : UIViewController<UITextFieldDelegate>
@property (weak, nonatomic) IBOutlet UILabel *titleLabel;
@property (weak, nonatomic) IBOutlet UIImageView *imageView;
@property (weak, nonatomic) IBOutlet UILabel *forgotPasswordLabel;
@property NSUInteger pageIndex;
@property NSString *titleText;
@property NSString *imageFile;
@property (strong, nonatomic) NSString* email;
@property (weak, nonatomic) IBOutlet UIView *activityView;
@end
