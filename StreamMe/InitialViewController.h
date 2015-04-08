//
//  InitialViewController.h
//  genesis
//
//  Created by Chase Midler on 9/3/14.
//  Copyright (c) 2014 midler. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "AppDelegate.h"
#import "MainTableViewController.h"
#define MAX_USERNAME_LENGTH 12
#define MAX_EMAIL_LENGTH 128
#define MAX_PASSWORD_LENGTH 16
#define EMAIL_TAG 1337
#define USERNAME_TAG 1111
#define PASSWORD_TAG 1234
@interface InitialViewController : UIViewController <UITextFieldDelegate>
@property (weak, nonatomic) IBOutlet UIActivityIndicatorView *activityIndicator;

@property (weak, nonatomic) IBOutlet UILabel *forgotPasswordLabel;
@property (strong, nonatomic) NSString* email;
@property (strong, nonatomic) NSString* username;
@property (strong, nonatomic) NSString* password;
- (IBAction)loginAction:(id)sender;
- (IBAction)registerAction:(id)sender;

@end
