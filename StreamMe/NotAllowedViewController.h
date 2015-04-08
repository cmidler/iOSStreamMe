//
//  NotAllowedViewController.h
//  WhoYu
//
//  Created by Chase Midler on 2/8/15.
//  Copyright (c) 2015 midler. All rights reserved.
//

#import <UIKit/UIKit.h>
#import <Parse/Parse.h>
#import "MainDatabase.h"
#define MAX_INVITE_CHARS 32
@interface NotAllowedViewController : UIViewController
@property (weak, nonatomic) IBOutlet UIButton *logoutButton;
- (IBAction)logoutAction:(id)sender;

@property (weak, nonatomic) IBOutlet UIButton *checkButton;
- (IBAction)checkAction:(id)sender;
@property (weak, nonatomic) IBOutlet UITextField *inviteCodeTextField;
@property (weak, nonatomic) IBOutlet UIActivityIndicatorView *activityIndicator;
@property (strong, nonatomic) NSString* inviteCode;
@property (nonatomic, readwrite) CGPoint originalCenter;
@property (weak, nonatomic) IBOutlet UILabel *notAvailableLabel;
@property (weak, nonatomic) IBOutlet UILabel *editZipcode;
@property (weak, nonatomic) IBOutlet UILabel *editEmail;

@property (weak, nonatomic) IBOutlet UILabel *logoutLabel;
@property (strong, nonatomic) NSString* email;
@property (strong, nonatomic) NSString* zip;
@end
