//
//  NotAllowedViewController.m
//  WhoYu
//
//  Created by Chase Midler on 2/8/15.
//  Copyright (c) 2015 midler. All rights reserved.
//

#import "NotAllowedViewController.h"

@interface NotAllowedViewController ()

@end

@implementation NotAllowedViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    // Do any additional setup after loading the view.
    //Set blue gradient background
    UIGraphicsBeginImageContext(self.view.frame.size);
    [[UIImage imageNamed:@"BlueGradient.png"] drawInRect:self.view.bounds];
    UIImage *image = UIGraphicsGetImageFromCurrentImageContext();
    UIGraphicsEndImageContext();
    
    self.view.backgroundColor = [UIColor colorWithPatternImage:image];
    
    UITapGestureRecognizer *tap = [[UITapGestureRecognizer alloc]
                                   initWithTarget:self
                                   action:@selector(dismissKeyboard)];
    tap.cancelsTouchesInView = NO;
    [self.view addGestureRecognizer:tap];

    [_inviteCodeTextField addTarget:self
                        action:@selector(inviteCodeDidChange:)
              forControlEvents:UIControlEventEditingChanged];
    [_activityIndicator stopAnimating];
    
    //setup invite code
    _inviteCode = @"";
    _inviteCodeTextField.text = @"Enter Invite Code";
    _inviteCodeTextField.textColor = [UIColor grayColor];
    
    //make the submit button look better
    _checkButton.layer.cornerRadius = 7.5;
    _checkButton.layer.borderWidth = 1;
    _checkButton.layer.borderColor = [UIColor blackColor].CGColor;
    
    _checkButton.enabled = NO;
    _checkButton.alpha = 0.7;
    
    [_logoutLabel setUserInteractionEnabled:YES];
    [_editZipcode setUserInteractionEnabled:YES];
    [_editEmail setUserInteractionEnabled:YES];
    
    UITapGestureRecognizer *logoutTap =  [[UITapGestureRecognizer alloc] initWithTarget:self action:@selector(logoutTapDetected:)];
    logoutTap.numberOfTapsRequired = 1;
    [_logoutLabel addGestureRecognizer:logoutTap];
    
    UITapGestureRecognizer *editZipTap =  [[UITapGestureRecognizer alloc] initWithTarget:self action:@selector(editZipTapDetected:)];
    editZipTap.numberOfTapsRequired = 1;
    [_editZipcode addGestureRecognizer:editZipTap];
    
    UITapGestureRecognizer *editEmailTap =  [[UITapGestureRecognizer alloc] initWithTarget:self action:@selector(editEmailTapDetected:)];
    editEmailTap.numberOfTapsRequired = 1;
    [_editEmail addGestureRecognizer:editEmailTap];
    
    _email = [PFUser currentUser].email;
    _zip = [[PFUser currentUser] objectForKey:@"zipcode"];
    
}

-(void) logoutTapDetected:(id) sender
{
    [PFUser logOut];
    [self performSegueWithIdentifier:@"loggedOutSegue" sender:self];
}

-(void) editZipTapDetected:(id) sender
{
    //alert to get zip
    UIAlertController *alertController = [UIAlertController
                                          alertControllerWithTitle:@"New Zipcode"
                                          message:@"Enter the zipcode you wish to save."
                                          preferredStyle:UIAlertControllerStyleAlert];
    
    [alertController addTextFieldWithConfigurationHandler:^(UITextField *textField)
     {
         textField.text = _zip;
     }];
    UIAlertAction *okAction = [UIAlertAction
                               actionWithTitle:NSLocalizedString(@"Save", @"Save action")
                               style:UIAlertActionStyleDefault
                               handler:^(UIAlertAction *action)
                               {
                                   
                                   
                                   _zip = ((UITextField*)alertController.textFields.firstObject).text;
                                   
                                   //do some zip regex
                                   NSString *zipRegex = @"^[0-9]{5}";
                                   NSError  *error = nil;
                                   NSRange   searchedRange = NSMakeRange(0, _zip.length);
                                   NSRegularExpression* regex = [NSRegularExpression regularExpressionWithPattern: zipRegex options:0 error:&error];
                                   
                                   NSArray* matches = [regex matchesInString:_zip options:0 range:searchedRange];
                                   
                                   //check if the zipcode matches the regex
                                   if(_zip.length!=5 || !matches.count)
                                   {
                                       UIAlertController *alertController = [UIAlertController
                                                                             alertControllerWithTitle:@"Bad Zipcode"
                                                                             message:@"Please enter a valid zipcode (#####)."
                                                                             preferredStyle:UIAlertControllerStyleAlert];
                                       UIAlertAction *okAction = [UIAlertAction
                                                                  actionWithTitle:NSLocalizedString(@"Ok", @"Ok action")
                                                                  style:UIAlertActionStyleDefault
                                                                  handler:^(UIAlertAction *action)
                                                                  {
                                                                      NSLog(@"Ok action");
                                                                      return;
                                                                  }];
                                       
                                       [alertController addAction:okAction];
                                       [self presentViewController:alertController animated:YES completion:nil];
                                       return;
                                   }
                                   else
                                   {
                                       PFUser* user = [PFUser currentUser];
                                       user[@"zipcode"] = _zip;
                                       [user saveInBackgroundWithBlock:^(BOOL succeeded, NSError *error) {
                                           if(!error && succeeded)
                                           {
                                               [user refresh];
                                           }
                                       }];
                                   }
                               }];
    
    UIAlertAction *cancelAction = [UIAlertAction
                                   actionWithTitle:NSLocalizedString(@"Cancel", @"Cancel action")
                                   style:UIAlertActionStyleCancel
                                   handler:^(UIAlertAction *action)
                                   {
                                       _zip = ((UITextField*)alertController.textFields.firstObject).text;
                                       NSLog(@"Cancel action");
                                       return;
                                   }];
    
    [alertController addAction:cancelAction];
    [alertController addAction:okAction];
    [self presentViewController:alertController animated:YES completion:nil];
}

-(void) editEmailTapDetected:(id) sender
{
    //alert to get email
    UIAlertController *alertController = [UIAlertController
                                          alertControllerWithTitle:@"New Email Address"
                                          message:@"Enter the email address you wish to save."
                                          preferredStyle:UIAlertControllerStyleAlert];
    
    [alertController addTextFieldWithConfigurationHandler:^(UITextField *textField)
     {
         textField.text = _email;
     }];
    UIAlertAction *okAction = [UIAlertAction
                               actionWithTitle:NSLocalizedString(@"Save", @"Save action")
                               style:UIAlertActionStyleDefault
                               handler:^(UIAlertAction *action)
                               {
                                   
                                   _email = ((UITextField*)alertController.textFields.firstObject).text;
                                   
                                   //do some email regex
                                   NSString *emailRegex = @"[a-zA-Z0-9!#$%&'*+/=?^_`{|}~-]+(?:.[a-zA-Z0-9!#$%&'*+/=?^_`{|}~-]+)*@(?:[a-zA-Z0-9](?:[a-zA-Z0-9-]*[a-z0-9])?.)+\\.[a-zA-Z0-9](?:[a-zA-Z0-9-]*[a-zA-Z0-9])?";
                                   NSError  *error = nil;
                                   NSRange   searchedRange = NSMakeRange(0, _email.length);
                                   NSRegularExpression* regex = [NSRegularExpression regularExpressionWithPattern: emailRegex options:0 error:&error];
                                   
                                   NSArray* matches = [regex matchesInString:_email options:0 range:searchedRange];
                                   
                                   //check if the email address matches the regex
                                   if(!_email.length || !matches.count)
                                   {
                                       UIAlertController *alertController = [UIAlertController
                                                                             alertControllerWithTitle:@"Bad Email"
                                                                             message:@"Please enter a valid email address."
                                                                             preferredStyle:UIAlertControllerStyleAlert];
                                       UIAlertAction *okAction = [UIAlertAction
                                                                  actionWithTitle:NSLocalizedString(@"Ok", @"Ok action")
                                                                  style:UIAlertActionStyleDefault
                                                                  handler:^(UIAlertAction *action)
                                                                  {
                                                                      NSLog(@"Ok action");
                                                                      return;
                                                                  }];
                                       
                                       [alertController addAction:okAction];
                                       [self presentViewController:alertController animated:YES completion:nil];
                                       return;
                                   }
                                   else
                                   {
                                       PFUser* user = [PFUser currentUser];
                                       user[@"email"] = _email;
                                       [user saveInBackgroundWithBlock:^(BOOL succeeded, NSError *error) {
                                           if(!error && succeeded)
                                           {
                                               [user refresh];
                                           }
                                       }];
                                   }
                               }];
    
    UIAlertAction *cancelAction = [UIAlertAction
                                   actionWithTitle:NSLocalizedString(@"Cancel", @"Cancel action")
                                   style:UIAlertActionStyleCancel
                                   handler:^(UIAlertAction *action)
                                   {
                                       _email = ((UITextField*)alertController.textFields.firstObject).text;
                                       NSLog(@"Cancel action");
                                       return;
                                   }];
    
    [alertController addAction:cancelAction];
    [alertController addAction:okAction];
    [self presentViewController:alertController animated:YES completion:nil];

}

-(void) viewDidAppear:(BOOL)animated
{
    //get view original center
    _originalCenter = self.view.center;
}

- (void) dismissKeyboard
{
    [_inviteCodeTextField resignFirstResponder];
    self.view.center = _originalCenter;
    _notAvailableLabel.hidden= NO;
    
}

//notifications that fire when you edited text
-(void) inviteCodeDidChange:(id)sender
{
    _inviteCode = _inviteCodeTextField.text;
    
    //check to see if we can allow the submit button or not
    if(_inviteCode.length)
    {
        _checkButton.enabled = YES;
        _checkButton.alpha = 1.0f;
    }
    else
    {
        _checkButton.enabled = NO;
        _checkButton.alpha = 0.7f;
    }
}



//Delegates for helping textview have placeholder text
- (void)textFieldDidBeginEditing:(UITextField *)textField
{
    
    if([textField.text isEqualToString:@"Enter Invite Code"])
    {
        textField.text = @"";
    }
    textField.textColor = [UIColor blackColor];
    [textField becomeFirstResponder];
    
    NSLog(@"invitecode center = %f", _inviteCodeTextField.center.y);
    NSLog(@"original center is %f", self.originalCenter.y);
    _notAvailableLabel.hidden= YES;
    self.view.center = CGPointMake(self.originalCenter.x, self.originalCenter.y + (self.originalCenter.y - _inviteCodeTextField.center.y)); //- _inviteCodeTextField.frame.size.height); //+ textField.frame.size.height);
}

//Continuation delegate for placeholder text
- (void)textFieldDidEndEditing:(UITextField *)textField
{
    if ([textField.text isEqualToString:@""])
    {
        textField.text = @"Enter Invite Code";
        textField.textColor = [UIColor lightGrayColor];
    }
    _inviteCode = textField.text;
    
    [textField resignFirstResponder];
    self.view.center = _originalCenter;
    _notAvailableLabel.hidden= NO;
}


//used for updating status
- (BOOL)textField:(UITextField *)textField
shouldChangeCharactersInRange:(NSRange)range
replacementString:(NSString *)text
{
    
    //check if they user is trying to enter too many characters
    if([[textField text] length] - range.length + text.length > MAX_INVITE_CHARS && ![text isEqualToString:@"\n"])
    {
        return NO;
    }
    
    //Make return key try to save the new status
    if([text isEqualToString:@"\n"])
    {
        [textField resignFirstResponder];
        _notAvailableLabel.hidden= NO;
        [self checkAction:self];
    }
    return YES;
}



- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}



- (IBAction)logoutAction:(id)sender {
    [PFUser logOut];
    [self performSegueWithIdentifier:@"loggedOutSegue" sender:self];
}

//helper to check the invite code for the user
- (IBAction)checkAction:(id)sender {
    
    _checkButton.enabled = NO;
    _checkButton.alpha = 0.7f;
    [_activityIndicator startAnimating];
    
    //check if the zipcode entered is allowed or not
    [PFCloud callFunctionInBackground:@"checkInviteCode" withParameters:@{@"invite_id": _inviteCode} block:^(id object, NSError *error)
     {
         
         
         //If error that means it isn't allowed yet
         
         NSLog(@"Error is %@", error.userInfo[@"error"]);
         
         if(error && [error.userInfo[@"error"] isEqualToString:@"-3"])
         {
             UIAlertController *alertController = [UIAlertController
                                                   alertControllerWithTitle:@"Wrong Code"
                                                   message:@"The code you gave is invalid.  Enter a valid code."
                                                   preferredStyle:UIAlertControllerStyleAlert];
             UIAlertAction *okAction = [UIAlertAction
                                        actionWithTitle:NSLocalizedString(@"Ok", @"Ok action")
                                        style:UIAlertActionStyleDefault
                                        handler:^(UIAlertAction *action)
                                        {
                                            NSLog(@"Ok action");
                                            _checkButton.enabled = YES;
                                            _checkButton.alpha = 1.0f;
                                            [_activityIndicator stopAnimating];
                                            return;
                                        }];
             
             [alertController addAction:okAction];
             [self presentViewController:alertController animated:YES completion:nil];
             return;
         }
         else if (error)
         {
             UIAlertController *alertController = [UIAlertController
                                                   alertControllerWithTitle:@"Something Happened"
                                                   message:@"An error occurred while trying to check the invite code.  Check your internet connection and try again."
                                                   preferredStyle:UIAlertControllerStyleAlert];
             UIAlertAction *okAction = [UIAlertAction
                                        actionWithTitle:NSLocalizedString(@"Ok", @"Ok action")
                                        style:UIAlertActionStyleDefault
                                        handler:^(UIAlertAction *action)
                                        {
                                            NSLog(@"Ok action");
                                            _checkButton.enabled = YES;
                                            _checkButton.alpha = 1.0f;
                                            [_activityIndicator stopAnimating];
                                            return;
                                        }];
             
             [alertController addAction:okAction];
             [self presentViewController:alertController animated:YES completion:nil];
             return;
         }
         else
         {
             //set the user as invited
             PFUser* user = [PFUser currentUser];
             user[@"isInvited"] = [NSNumber numberWithBool:YES];
             user[@"inviteCode"] = _inviteCode;
             [user saveEventually:^(BOOL succeeded, NSError *error) {
                 [user refresh];
             }];
             
            _checkButton.enabled = YES;
            _checkButton.alpha = 1.0f;
            [_activityIndicator stopAnimating];
            [self performSegueWithIdentifier:@"loggedInSegue" sender:self];
            return;
         
         }
         
         
     }];
    
}
@end
