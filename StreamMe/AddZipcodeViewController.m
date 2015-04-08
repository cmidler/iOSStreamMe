//
//  AddZipcodeViewController.m
//  WhoYu
//
//  Created by Chase Midler on 2/4/15.
//  Copyright (c) 2015 midler. All rights reserved.
//

#import "AddZipcodeViewController.h"

@interface AddZipcodeViewController ()

@end

@implementation AddZipcodeViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    // Do any additional setup after loading the view.
    
    UITapGestureRecognizer *tap = [[UITapGestureRecognizer alloc]
                                   initWithTarget:self
                                   action:@selector(dismissKeyboard)];
    tap.cancelsTouchesInView = NO;
    
    [self.view addGestureRecognizer:tap];
    
    
    //setting up notifications for the text fields
    [_emailTextField addTarget:self
                  action:@selector(emailDidChange:)
        forControlEvents:UIControlEventEditingChanged];
    [_zipcodeTextField addTarget:self
                        action:@selector(zipcodeDidChange:)
              forControlEvents:UIControlEventEditingChanged];
    
    _zipcode = _email = @"";
    
    _emailTextField.text = _email;
    [_emailTextField becomeFirstResponder];
    _zipcodeTextField.text = @"Enter Zipcode";
    _zipcodeTextField.textColor = [UIColor grayColor];
    
    _emailTextField.tag = EMAIL_TAG;
    _zipcodeTextField.tag = ZIPCODE_TAG;
    
    _currentTextField = _emailTextField;
    
    //make the submit button look better
    _submitButton.layer.cornerRadius = 17.5;
    _submitButton.layer.borderWidth = 1;
    _submitButton.layer.borderColor = [UIColor blackColor].CGColor;
    
    _submitButton.enabled = NO;
    _submitButton.alpha = 0.7;
    
    //same with cancel
    _cancelButton.layer.cornerRadius = 17.5;
    _cancelButton.layer.borderWidth = 1;
    _cancelButton.layer.borderColor = [UIColor blackColor].CGColor;
    
    //Set blue gradient background
    UIGraphicsBeginImageContext(self.view.frame.size);
    [[UIImage imageNamed:@"BlueGradient.png"] drawInRect:self.view.bounds];
    UIImage *image = UIGraphicsGetImageFromCurrentImageContext();
    UIGraphicsEndImageContext();
    
    self.view.backgroundColor = [UIColor colorWithPatternImage:image];

    
}

- (void) dismissKeyboard
{
    [_currentTextField resignFirstResponder];
}

//notifications that fire when you edited text
-(void) emailDidChange:(id)sender
{
    NSLog(@"email text field is %@", _emailTextField.text);
    _email = _emailTextField.text;
    
    //check to see if we can allow the submit button or not
    if(_email.length && _zipcode.length == MAX_ZIPCODE_CHARS && ![_email isEqualToString:@"Enter Email"] && ![_zipcode isEqualToString:@"Enter Zipcode"])
    {
        _submitButton.enabled = YES;
        _submitButton.alpha = 1.0f;
    }
    else
    {
        _submitButton.enabled = NO;
        _submitButton.alpha = 0.7f;
    }
}

-(void) zipcodeDidChange:(id)sender
{
    NSLog(@"zipcode text field is %@", _zipcodeTextField.text);
    _zipcode = _zipcodeTextField.text;
    
    //check to see if we can allow the submit button or not
    if(_email.length && _zipcode.length == MAX_ZIPCODE_CHARS && ![_email isEqualToString:@"Enter Email"] && ![_zipcode isEqualToString:@"Enter Zipcode"])
    {
        _submitButton.enabled = YES;
        _submitButton.alpha = 1.0f;
    }
    else
    {
        _submitButton.enabled = NO;
        _submitButton.alpha = 0.7f;
    }
}


//Delegates for helping textview have placeholder text
- (void)textFieldDidBeginEditing:(UITextField *)textField
{
    _currentTextField = textField;
    
    if([textField.text isEqualToString:@"Enter Zipcode"] || [textField.text isEqualToString:@"Enter Email"])
    {
        textField.text = @"";
    }
    textField.textColor = [UIColor blackColor];
    [textField becomeFirstResponder];
}

//Continuation delegate for placeholder text
- (void)textFieldDidEndEditing:(UITextField *)textField
{
    if ([textField.text isEqualToString:@""])
    {
        if(textField.tag == EMAIL_TAG)
            textField.text = @"Enter Email";
        else
            textField.text = @"Enter Zipcode";
        textField.textColor = [UIColor lightGrayColor];
    }
    //set email and zipcode
    if(textField.tag == EMAIL_TAG)
        _email = textField.text;
    else
        _zipcode = textField.text;
    
    [textField resignFirstResponder];
}


//used for updating status
- (BOOL)textField:(UITextField *)textField
shouldChangeCharactersInRange:(NSRange)range
replacementString:(NSString *)text
{
    
    int max_chars = 0;
    if(textField.tag == EMAIL_TAG)
    {
        max_chars = MAX_EMAIL_CHARS;
    }
    else
    {
        //make sure only numbers are entered here
        if(text.length)
        {
            NSNumberFormatter *f = [[NSNumberFormatter alloc] init];
            f.numberStyle = NSNumberFormatterDecimalStyle;
            NSNumber *myNumber = [f numberFromString:text];
            if(!myNumber)
                return NO;
        }
        max_chars = MAX_ZIPCODE_CHARS;
    }
    
    
    //check if they user is trying to enter too many characters
    if([[textField text] length] - range.length + text.length > max_chars && ![text isEqualToString:@"\n"])
    {
        return NO;
    }
    
    //Make return key try to save the new status
    if([text isEqualToString:@"\n"])
    {
        [textField resignFirstResponder];
    }
    return YES;
}


- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

//save the zipcode and email address to the backend database
- (IBAction)submitAction:(id)sender {
    
    
    //do some email regex
    NSString *emailRegex = @"[a-zA-Z0-9!#$%&'*+/=?^_`{|}~-]+(?:.[a-zA-Z0-9!#$%&'*+/=?^_`{|}~-]+)*@(?:[a-zA-Z0-9](?:[a-zA-Z0-9-]*[a-z0-9])?.)+\\.[a-zA-Z0-9](?:[a-zA-Z0-9-]*[a-zA-Z0-9])?";
    NSError  *error = nil;
    NSRange   searchedRange = NSMakeRange(0, _email.length);
    NSRegularExpression* regex = [NSRegularExpression regularExpressionWithPattern: emailRegex options:0 error:&error];
    
    NSArray* matches = [regex matchesInString:_email options:0 range:searchedRange];
    
    //check if the email address matches the regex
    if(!matches.count)
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
    
    //ok, time to save
    PFUser* user = [PFUser currentUser];
    user[@"zipcode"] = _zipcode;
    user[@"email"] = _email;
    _submitButton.enabled = NO;
    _submitButton.alpha = 0.7f;
    [_activityIndicator startAnimating];
    //Match installation with user for pushes
    PFInstallation *installation = [PFInstallation currentInstallation];
    installation[@"user"] = user;
    NSLog(@"user id is %@", user.objectId);
    [installation setValue:@"ios" forKey:@"deviceType"];
    PFACL *defaultACL = [PFACL ACL];
    [defaultACL setReadAccess:true forUser:user];
    [defaultACL setWriteAccess:true forUser:user];
    [defaultACL setPublicReadAccess:false];
    [defaultACL setPublicWriteAccess:false];
    [installation setACL:defaultACL];
    [installation saveEventually];
    NSLog(@"Installation is %@", installation);
    //save the user
    [user saveEventually];
    
    //check if the zipcode entered is allowed or not
    [PFCloud callFunctionInBackground:@"checkZipCode" withParameters:@{@"zipcode": _zipcode} block:^(id object, NSError *error)
     {
         
         
         //If error that means it isn't allowed yet
         if(error)
             [self performSegueWithIdentifier:@"notAllowedSegue" sender:self];
         else
         {
             user[@"isInvited"] = [NSNumber numberWithBool:1];
             [self performSegueWithIdentifier:@"loggedInSegue" sender:self];
         }
         
         _submitButton.enabled = YES;
         _submitButton.alpha = 1.0f;
         [_activityIndicator stopAnimating];
         return;
     }];
    
}
- (IBAction)cancelAction:(id)sender {
    [PFUser logOut];
    [self performSegueWithIdentifier:@"loggedOutSegue" sender:self];
}
@end
