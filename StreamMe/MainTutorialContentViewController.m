//
//  MainTutorialContentViewController.m
//  WhoYu
//
//  Created by Chase Midler on 4/1/15.
//  Copyright (c) 2015 midler. All rights reserved.
//

#import "MainTutorialContentViewController.h"

@interface MainTutorialContentViewController ()

@end

@implementation MainTutorialContentViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    UIGraphicsBeginImageContext(self.view.frame.size);
    [[UIImage imageNamed:@"Default-736.png"] drawInRect:self.view.bounds];
    UIImage *image = UIGraphicsGetImageFromCurrentImageContext();
    UIGraphicsEndImageContext();
    
    self.view.backgroundColor = [UIColor colorWithPatternImage:image]; 
    self.imageView.image = [UIImage imageNamed:self.imageFile];
    self.imageView.layer.cornerRadius = 37;
    self.imageView.clipsToBounds = YES;
    self.titleLabel.text = self.titleText;
    self.activityView.backgroundColor = [UIColor blackColor];
    self.activityView.hidden = YES;
    
    [_forgotPasswordLabel setUserInteractionEnabled:YES];
    UITapGestureRecognizer *forgotTap =  [[UITapGestureRecognizer alloc] initWithTarget:self action:@selector(forgotTapDetected:)];
    forgotTap.numberOfTapsRequired = 1;
    [_forgotPasswordLabel addGestureRecognizer:forgotTap];
    
    [[NSNotificationCenter defaultCenter] addObserver:self
                                             selector:@selector(activityNotification:)
                                                 name:@"showActivityView"
                                               object:nil];
    [[NSNotificationCenter defaultCenter] addObserver:self
                                             selector:@selector(activityNotification:)
                                                 name:@"hideActivityView"
                                               object:nil];
}

/* calling load values on notification since viewwillappear is not working */
- (void) activityNotification:(NSNotification *) notification
{
    if ([[notification name] isEqualToString:@"showActivityView"])
    {
        self.activityView.hidden = NO;
    }
    else if ([[notification name] isEqualToString:@"hideActivityView"])
    {
        self.activityView.hidden = YES;
    }
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

-(void) forgotTapDetected:(id) sender
{
    
    //alert to get email
    UIAlertController *alertController = [UIAlertController
                                          alertControllerWithTitle:@"Enter Email Address"
                                          message:@"Enter the email address with which you registered your account."
                                          preferredStyle:UIAlertControllerStyleAlert];
    [alertController addTextFieldWithConfigurationHandler:^(UITextField *textField)
     {
         textField.tag = EMAIL_TAG;
         textField.delegate = self;
         textField.placeholder = NSLocalizedString(@"Email", @"Email");
         if(_email)
             textField.text = _email;
         [textField setKeyboardType: UIKeyboardTypeEmailAddress];
     }];
    UIAlertAction *okAction = [UIAlertAction
                               actionWithTitle:NSLocalizedString(@"OK", @"Ok action")
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
                                   //[_activityIndicator startAnimating];
                                   //[_activityIndicator setHidden:NO];
                                   [[NSNotificationCenter defaultCenter] postNotificationName:@"showActivityView" object:self userInfo:nil];
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
                                                                      [[NSNotificationCenter defaultCenter] postNotificationName:@"hideActivityView" object:self userInfo:nil];
                                                                      [self forgotTapDetected:self];
                                                                      return;
                                                                  }];
                                       
                                       [alertController addAction:okAction];
                                       [self presentViewController:alertController animated:YES completion:nil];
                                       return;
                                   }
                                   
                                   //send reset email
                                   [PFUser requestPasswordResetForEmailInBackground:_email block:^(BOOL succeeded, NSError *error) {
                                       
                                       UIAlertController *alertController;
                                       UIAlertAction *okAction;
                                       //email not found for user
                                       if(error.code == 205)
                                       {
                                           alertController = [UIAlertController alertControllerWithTitle:@"Email Not Sent"
                                                                                                 message:@"That email address is not associated with a user.  Make sure you entered the correct email address and try again."
                                                                                          preferredStyle:UIAlertControllerStyleAlert];
                                           okAction = [UIAlertAction
                                                       actionWithTitle:NSLocalizedString(@"Ok", @"Ok action")
                                                       style:UIAlertActionStyleDefault
                                                       handler:^(UIAlertAction *action)
                                                       {
                                                           NSLog(@"Ok action");
                                                           //[_activityIndicator stopAnimating];
                                                           //[_activityIndicator setHidden:YES];
                                                           [[NSNotificationCenter defaultCenter] postNotificationName:@"hideActivityView" object:self userInfo:nil];
                                                           [self forgotTapDetected:self];
                                                           return;
                                                       }];
                                           
                                       }
                                       else if (error)
                                       {
                                           alertController = [UIAlertController alertControllerWithTitle:@"Email Could Not Be Sent"
                                                                                                 message:@"An error occurred.  Check your internet connection and try again."
                                                                                          preferredStyle:UIAlertControllerStyleAlert];
                                           okAction = [UIAlertAction
                                                       actionWithTitle:NSLocalizedString(@"Ok", @"Ok action")
                                                       style:UIAlertActionStyleDefault
                                                       handler:^(UIAlertAction *action)
                                                       {
                                                           NSLog(@"Ok action");
                                                           //[_activityIndicator stopAnimating];
                                                           //[_activityIndicator setHidden:YES];
                                                           [[NSNotificationCenter defaultCenter] postNotificationName:@"hideActivityView" object:self userInfo:nil];
                                                           [self forgotTapDetected:self];
                                                           return;
                                                       }];
                                           
                                       }
                                       else
                                       {
                                           alertController = [UIAlertController alertControllerWithTitle:@"Password Reset Email Sent"
                                                                                                 message:@"You will receive an email shortly with a link to reset your password."
                                                                                          preferredStyle:UIAlertControllerStyleAlert];
                                           okAction = [UIAlertAction
                                                       actionWithTitle:NSLocalizedString(@"Ok", @"Ok action")
                                                       style:UIAlertActionStyleDefault
                                                       handler:^(UIAlertAction *action)
                                                       {
                                                           NSLog(@"Ok action");
                                                           //[_activityIndicator stopAnimating];
                                                           //[_activityIndicator setHidden:YES];
                                                           [[NSNotificationCenter defaultCenter] postNotificationName:@"hideActivityView" object:self userInfo:nil];
                                                           return;
                                                       }];
                                       }
                                       [alertController addAction:okAction];
                                       [self presentViewController:alertController animated:YES completion:nil];
                                       return;
                                   }];
                               }];
    
    UIAlertAction *cancelAction = [UIAlertAction
                                   actionWithTitle:NSLocalizedString(@"Cancel", @"Cancel action")
                                   style:UIAlertActionStyleCancel
                                   handler:^(UIAlertAction *action)
                                   {
                                       _email = nil;
                                       NSLog(@"Cancel action");
                                       return;
                                   }];
    
    [alertController addAction:cancelAction];
    [alertController addAction:okAction];
    [self presentViewController:alertController animated:YES completion:nil];
    
}




/*
#pragma mark - Navigation

// In a storyboard-based application, you will often want to do a little preparation before navigation
- (void)prepareForSegue:(UIStoryboardSegue *)segue sender:(id)sender {
    // Get the new view controller using [segue destinationViewController].
    // Pass the selected object to the new view controller.
}
*/
@end
