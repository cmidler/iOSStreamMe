//
//  AddZipcodeViewController.h
//  WhoYu
//
//  Created by Chase Midler on 2/4/15.
//  Copyright (c) 2015 midler. All rights reserved.
//

#import <UIKit/UIKit.h>
#import <Parse/Parse.h>

#define MAX_ZIPCODE_CHARS 5
#define MAX_EMAIL_CHARS 64
#define EMAIL_TAG 1337
#define ZIPCODE_TAG 15213

@interface AddZipcodeViewController : UIViewController

@property (weak, nonatomic) IBOutlet UITextField *emailTextField;
@property (weak, nonatomic) IBOutlet UITextField *zipcodeTextField;
@property (strong, nonatomic) UITextField* currentTextField;
@property (weak, nonatomic) IBOutlet UIActivityIndicatorView *activityIndicator;
@property (strong, nonatomic) NSString* email;
@property (strong, nonatomic) NSString* zipcode;
@property (weak, nonatomic) IBOutlet UIButton *submitButton;
- (IBAction)submitAction:(id)sender;
@property (weak, nonatomic) IBOutlet UIButton *cancelButton;
- (IBAction)cancelAction:(id)sender;
@end
