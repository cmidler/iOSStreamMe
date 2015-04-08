//
//  UserNotesViewController.h
//  WhoYu
//
//  Created by Chase Midler on 2/3/15.
//  Copyright (c) 2015 midler. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "MainDatabase.h"
#import "ViewProfileViewController.h"
#import "UserProfile.h"
#define MAX_NOTES_CHARS 2048
@interface UserNotesViewController : UIViewController
@property (weak, nonatomic) IBOutlet UIBarButtonItem *saveButton;
- (IBAction)saveAction:(id)sender;
@property (weak, nonatomic) IBOutlet UITextView *noteTextView;
@property (weak, nonatomic) IBOutlet UIActivityIndicatorView *activityIndicator;
@property (strong, nonatomic)UserProfile* profile;
@property (strong, nonatomic)NSString* notes;
/*@property (strong, nonatomic)NSString* user_id;
@property (strong, nonatomic)NSString* first_name;*/
- (IBAction)cancelAction:(id)sender;
@end
