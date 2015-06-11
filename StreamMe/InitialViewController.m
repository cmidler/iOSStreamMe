//
//  InitialViewController.m
//  genesis
//
//  Created by Chase Midler on 9/3/14.
//  Copyright (c) 2014 midler. All rights reserved.
//

#import "InitialViewController.h"

@interface InitialViewController ()

@end

@implementation InitialViewController

- (id)initWithNibName:(NSString *)nibNameOrNil bundle:(NSBundle *)nibBundleOrNil
{
    self = [super initWithNibName:nibNameOrNil bundle:nibBundleOrNil];
    if (self) {
        // Custom initialization
    }
    return self;
}

- (void)viewDidLoad
{
    [super viewDidLoad];
    //Adding the data to the picture

    _activityIndicator.hidden = YES;
    [[NSNotificationCenter defaultCenter] postNotificationName:@"hideActivityView" object:self userInfo:nil];
    _email = nil;
    _password = nil;
    _username = nil;
    
    
    
    [[NSNotificationCenter defaultCenter] addObserver:self
                                             selector:@selector(initialNotification:)
                                                 name:@"showRegisterOption"
                                               object:nil];
}

/* calling load values on notification since viewwillappear is not working */
- (void) initialNotification:(NSNotification *) notification
{
    if ([[notification name] isEqualToString:@"showRegisterOption"])
    {
        [self registerAction:self];
    }
}


- (void) viewWillAppear:(BOOL)animated
{
    _showTutorial = NO;
    //Set blue gradient background
    UIGraphicsBeginImageContext(self.view.frame.size);
    [[UIImage imageNamed:@"BlueGradient.png"] drawInRect:self.view.bounds];
    UIImage *image = UIGraphicsGetImageFromCurrentImageContext();
    UIGraphicsEndImageContext();
    
    UIGraphicsBeginImageContext(self.view.frame.size);
    [[UIImage imageNamed:@"Default-736.png"] drawInRect:self.view.bounds];
    UIImage *bgImage = UIGraphicsGetImageFromCurrentImageContext();
    UIGraphicsEndImageContext();
    self.view.backgroundColor = [UIColor colorWithPatternImage:bgImage];
    
    UIImageView* navigationTitle = [[UIImageView alloc] initWithFrame:CGRectMake(0, 0, 88, 44)];
    navigationTitle.image = [UIImage imageNamed:@"streamme_banner_1.png"];
    [self.view addSubview:navigationTitle];
    UIImageView *workaroundView = [[UIImageView alloc] initWithFrame:CGRectMake(0, 0, 88, 44)];
    [workaroundView addSubview:navigationTitle];
    self.navigationItem.titleView=workaroundView;
    [self.navigationController.navigationBar setBarTintColor:[UIColor colorWithPatternImage:image]];
    
    [self loggedIn];
    
}



//Notification on if the loggedin event succeeded
-(void) loggedIn
{
    
    PFUser* user = [PFUser currentUser];
    

    //if the user is logged in, don't present navigation bar.  If not, then present the navigation bar
    if(user)
    {
        [self.navigationController setNavigationBarHidden:YES];
        //self.forgotPasswordLabel.hidden = YES;
    }
    else
    {
        [self.navigationController setNavigationBarHidden:NO];
        [self tutorial];
        //self.forgotPasswordLabel.hidden = NO;
        
    }
}


- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

- (void) viewDidAppear:(BOOL)animated
{
    __block PFUser* user = [PFUser currentUser];
    if(user)
    {
        
        NSLog(@"user is %@", user.username);
        
        //user has logged in before.  See if an older version of login or not
        NSString* postingName = [user objectForKey:@"posting_name"];
        if(!postingName)
        {
            _activityIndicator.hidden = NO;
            [_activityIndicator startAnimating];
            self.navigationItem.rightBarButtonItem.enabled = NO;
            [[NSNotificationCenter defaultCenter] postNotificationName:@"showActivityView" object:self userInfo:nil];
            /*UIAlertController *alertController = [UIAlertController
                                                  alertControllerWithTitle:@"Error Logging In"
                                                  message:@"An error happened while trying to login.  Check your internet connection and try again."
                                                  preferredStyle:UIAlertControllerStyleAlert];
            UIAlertAction *okAction = [UIAlertAction
                                       actionWithTitle:NSLocalizedString(@"Ok", @"Ok action")
                                       style:UIAlertActionStyleDefault
                                       handler:^(UIAlertAction *action)
                                       {
                                           _activityIndicator.hidden = YES;
                                           [_activityIndicator stopAnimating];
                                           self.navigationItem.rightBarButtonItem.enabled = YES;
                                           [[NSNotificationCenter defaultCenter] postNotificationName:@"hideActivityView" object:self userInfo:nil];
                                           return;
                                       }];*/
            
            
            
            //set password to nil, generate a random username for this user and set the old username to the posting name
            postingName = [NSString stringWithString:user.username];
            [user setObject:postingName forKey:@"posting_name"];
            user.password = @"";
            user.username = [self randomStringWithLength:32];
            [user saveInBackgroundWithBlock:^(BOOL succeeded, NSError *error) {
                if(succeeded && !error)
                {
                    NSLog(@"saved in background!");
                }
                else
                {
                    
                    NSLog(@"error at 1");
                    /*[alertController addAction:okAction];
                    [self presentViewController:alertController animated:YES completion:nil];
                    return;*/
                }
                [PFUser logOutInBackgroundWithBlock:^(NSError* error)
                 {
                     _activityIndicator.hidden = YES;
                     [_activityIndicator stopAnimating];
                     [[NSNotificationCenter defaultCenter] postNotificationName:@"hideActivityView" object:self userInfo:nil];
                     [self loginAction:self];
                 }];

            }];
        }
        else
        {
            _activityIndicator.hidden = NO;
            [_activityIndicator startAnimating];
            [[NSNotificationCenter defaultCenter] postNotificationName:@"showActivityView" object:self userInfo:nil];
            AppDelegate* appDelegate = [[UIApplication sharedApplication] delegate];
            CBPeripheralInterface* peripheral = [appDelegate peripheral];
            peripheral.userId = [PFUser currentUser].objectId;
            [peripheral startAdvertisingProfile];
            [self performSegueWithIdentifier:@"loggedInSegue" sender:self];
            return;
        }
    }

}

NSString *letters = @"abcdefghijklmnopqrstuvwxyzABCDEFGHIJKLMNOPQRSTUVWXYZ0123456789";

-(NSString *) randomStringWithLength: (int) len {
    
    NSMutableString *randomString = [NSMutableString stringWithCapacity: len];
    
    for (int i=0; i<len; i++) {
        [randomString appendFormat: @"%C", [letters characterAtIndex: arc4random_uniform((int)[letters length])]];
    }
    
    return randomString;
}


-(void) loginUser:(PFUser*) user
{
    
    NSLog(@"logging in user");
    UIAlertController *alertController = [UIAlertController
                                          alertControllerWithTitle:@"Error Logging In"
                                          message:@"An error happened while trying to login.  Check your internet connection and try again."
                                          preferredStyle:UIAlertControllerStyleAlert];
    UIAlertAction *okAction = [UIAlertAction
                               actionWithTitle:NSLocalizedString(@"Ok", @"Ok action")
                               style:UIAlertActionStyleDefault
                               handler:^(UIAlertAction *action)
                               {
                                   _activityIndicator.hidden = YES;
                                   [_activityIndicator stopAnimating];
                                   self.navigationItem.rightBarButtonItem.enabled = YES;
                                   [[NSNotificationCenter defaultCenter] postNotificationName:@"hideActivityView" object:self userInfo:nil];
                                   [self.navigationController setNavigationBarHidden:NO];
                                   [self tutorial];
                                   return;
                               }];
    //login the user
    [PFUser logInWithUsernameInBackground:user.username password:@"" block:^(PFUser *user, NSError *error)
     {
         if(error)
         {
             [alertController addAction:okAction];
             [self presentViewController:alertController animated:YES completion:nil];
             return;
         }
         
         [PFCloud callFunctionInBackground:@"addUserPrivate" withParameters:@{} block:^(id object, NSError *error) {
             
             if(error)
             {
                 NSLog(@"error running cloud function");
                 [alertController addAction:okAction];
                 [self presentViewController:alertController animated:YES completion:nil];
                 return;
             }

         
             //make sure we change the user to be the current user
             __block PFUser* currentUser = [PFUser currentUser];
             //no error so we are now logged in.  now to see if we have to change the posting name or not
             //user has logged in before.  See if an older version of login or not
             NSString* postingName = [currentUser objectForKey:@"posting_name"];
             if(!postingName)
             {
                //set password to nil, generate a random username for this user and set the old username to the posting name
                 postingName = [NSString stringWithString:user.username];
                 [currentUser setObject:postingName forKey:@"posting_name"];
                 currentUser.password = @"";
                 currentUser.username = [self randomStringWithLength:32];
                 [user saveInBackgroundWithBlock:^(BOOL succeeded, NSError *error) {
                     if(succeeded && !error)
                     {
                         [currentUser fetchIfNeededInBackground];
                         PFInstallation *installation = [PFInstallation currentInstallation];
                         [installation setValue:@"ios" forKey:@"deviceType"];
                         installation[@"user"] = currentUser;
                         installation[@"badge"] = [NSNumber numberWithInt:0];
                         PFACL *defaultACL = [PFACL ACL];
                         [defaultACL setReadAccess:true forUser:currentUser];
                         [defaultACL setWriteAccess:true forUser:currentUser];
                         [defaultACL setPublicReadAccess:false];
                         [defaultACL setPublicWriteAccess:false];
                         [installation setACL:defaultACL];
                         [installation saveInBackground];
                         
                         //get the main database
                         PFUser* user = [PFUser currentUser];
                         MainDatabase* md = [MainDatabase shared];
                         [md.queue inDatabase:^(FMDatabase *db) {
                             NSString *insertUserSQL = @"INSERT INTO user (user_id, is_me) VALUES (?,?)";
                             NSArray* userValues = @[user.objectId, [NSNumber numberWithInt:1]];
                             [db executeUpdate:insertUserSQL withArgumentsInArray:userValues];
                         }];
                         AppDelegate* appDelegate = [[UIApplication sharedApplication] delegate];
                         CBPeripheralInterface* peripheral = [appDelegate peripheral];
                         peripheral.userId = [PFUser currentUser].objectId;
                         [peripheral startAdvertisingProfile];
                         
                         [self performSegueWithIdentifier:@"loggedInSegue"
                                                   sender:self];
                     }
                     else
                     {
                         [alertController addAction:okAction];
                         [self presentViewController:alertController animated:YES completion:nil];
                         return;
                     }
                     
                 }];
             }
             else
             {
                 PFInstallation *installation = [PFInstallation currentInstallation];
                 [installation setValue:@"ios" forKey:@"deviceType"];
                 installation[@"user"] = currentUser;
                 installation[@"badge"] = [NSNumber numberWithInt:0];
                 PFACL *defaultACL = [PFACL ACL];
                 [defaultACL setReadAccess:true forUser:currentUser];
                 [defaultACL setWriteAccess:true forUser:currentUser];
                 [defaultACL setPublicReadAccess:false];
                 [defaultACL setPublicWriteAccess:false];
                 [installation setACL:defaultACL];
                 [installation saveInBackground];
                 
                 //get the main database
                 PFUser* user = [PFUser currentUser];
                 MainDatabase* md = [MainDatabase shared];
                 [md.queue inDatabase:^(FMDatabase *db) {
                     NSString *insertUserSQL = @"INSERT INTO user (user_id, is_me) VALUES (?,?)";
                     NSArray* userValues = @[user.objectId, [NSNumber numberWithInt:1]];
                     [db executeUpdate:insertUserSQL withArgumentsInArray:userValues];
                 }];
                 AppDelegate* appDelegate = [[UIApplication sharedApplication] delegate];
                 CBPeripheralInterface* peripheral = [appDelegate peripheral];
                 peripheral.userId = [PFUser currentUser].objectId;
                 [peripheral startAdvertisingProfile];
                 
                 [self performSegueWithIdentifier:@"loggedInSegue"
                                           sender:self];
             }
         }];
     }];
}


- (IBAction)loginAction:(id)sender {
    
    UIAlertController *alertController = [UIAlertController
                                          alertControllerWithTitle:@"Error Logging In"
                                          message:@"An error happened while trying to login.  Check your internet connection and try again."
                                          preferredStyle:UIAlertControllerStyleAlert];
    UIAlertAction *okAction = [UIAlertAction
                               actionWithTitle:NSLocalizedString(@"Ok", @"Ok action")
                               style:UIAlertActionStyleDefault
                               handler:^(UIAlertAction *action)
                               {
                                   _activityIndicator.hidden = YES;
                                   [_activityIndicator stopAnimating];
                                   self.navigationItem.rightBarButtonItem.enabled = YES;
                                   [[NSNotificationCenter defaultCenter] postNotificationName:@"hideActivityView" object:self userInfo:nil];
                                   [self.navigationController setNavigationBarHidden:NO];
                                   [self tutorial];
                                   return;
                               }];

    
    
    
    //query to see if we are registering the user or logging the user in
    PFInstallation *installation = [PFInstallation currentInstallation];
    _activityIndicator.hidden = NO;
    self.navigationItem.rightBarButtonItem.enabled = NO;
    [_activityIndicator startAnimating];
    [[NSNotificationCenter defaultCenter] postNotificationName:@"showActivityView" object:self userInfo:nil];
    
    NSLog(@"deviceToken is %@", installation.deviceToken);
    if(installation.deviceToken)
    {
        [PFCloud callFunctionInBackground:@"getInstallationForIOS" withParameters:@{@"deviceToken":installation.deviceToken} block:^(id object, NSError *error) {
            
            if(error)
            {
                [alertController addAction:okAction];
                [self presentViewController:alertController animated:YES completion:nil];
                return;
            }
        
            NSLog(@"object is %@", object);
            
            //see if there are objects
            if(!object || object == [NSNull null])
            {
                //register user
                NSLog(@"object is null so register");
                [self registerAction:self];
                return;
            }
            else
            {
                //we have the installation so it needs to be a login and not a register
                PFUser* user = [((PFInstallation*)object) objectForKey:@"user"];
                NSLog(@"user is %@", user.objectId);
                //if there is no postingname then we need to reset the password to nil on the server
                NSString* postingName = [user objectForKey:@"posting_name"];
                if(!postingName)
                {
                    //reset the password to empty
                    [PFCloud callFunctionInBackground:@"resetPassword" withParameters:@{@"userId":user.objectId} block:^(id object, NSError *error) {
                        
                        if(error)
                        {
                            [alertController addAction:okAction];
                            [self presentViewController:alertController animated:YES completion:nil];
                            return;
                        }
                        
                        //check if we didn't find a user to reset passwords
                        if([object isEqualToString:@"Register"])
                        {
                            //register user
                            NSLog(@"need to register user");
                            [self registerAction:self];
                            return;
                        }
                        
                        //ok we can now login the user
                        [self loginUser:user];
                        
                    }];
                }
                else
                    [self loginUser:user];
            }
        }];
    }
    else
    {
        [self registerAction:self];
        return;
    }
    
    /*UIAlertController *alertController = [UIAlertController
                                          alertControllerWithTitle:@"Log In"
                                          message:@"Enter Your Email And Password:"
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
    
    [alertController addTextFieldWithConfigurationHandler:^(UITextField *textField)
     {
         textField.tag = PASSWORD_TAG;
         textField.delegate = self;
         textField.placeholder = NSLocalizedString(@"Password", @"Password");
         textField.secureTextEntry = YES;
     }];
    
    UIAlertAction *okAction = [UIAlertAction
                               actionWithTitle:NSLocalizedString(@"Log In", @"OK action")
                               style:UIAlertActionStyleDefault
                               handler:^(UIAlertAction *action)
                               {
                                   UITextField *login = alertController.textFields.firstObject;
                                   UITextField *password = alertController.textFields.lastObject;
                                   
                                   _email = login.text;
                                   _password = password.text;
                                   
                                   //present error for nil length
     
                                   if(!_email.length || !_password.length)
                                   {
                                       UIAlertController *alertController = [UIAlertController
                                                                             alertControllerWithTitle:@"Empty Fields"
                                                                             message:@"Make sure to fill out all fields to register for an account."
                                                                             preferredStyle:UIAlertControllerStyleAlert];
                                       UIAlertAction *okAction = [UIAlertAction
                                                                  actionWithTitle:NSLocalizedString(@"Ok", @"Ok action")
                                                                  style:UIAlertActionStyleDefault
                                                                  handler:^(UIAlertAction *action)
                                                                  {
                                                                      if(!_email.length)
                                                                          _email = nil;
                                                                      _password = nil;
                                                                      [self loginAction:self];
                                                                      return;
                                                                  }];
                                       
                                       [alertController addAction:okAction];
                                       [self presentViewController:alertController animated:YES completion:nil];
                                       return;
                                   }
                                   
                                   //we have info in both fields
                                   _activityIndicator.hidden = NO;
                                   [_activityIndicator startAnimating];
                                   [[NSNotificationCenter defaultCenter] postNotificationName:@"showActivityView" object:self userInfo:nil];
                                   //get the username from backend based on email and then try to login
                                   
                                   PFQuery* userQuery = [PFUser query];
                                   [userQuery whereKey:@"email" equalTo:[_email lowercaseString]];
                                   NSLog(@"email is %@", [_email lowercaseString]);
                                   
                                   [userQuery findObjectsInBackgroundWithBlock:^(NSArray *objects, NSError *error) {
                                       UIAlertController *alertController = [UIAlertController
                                                                             alertControllerWithTitle:@"Incorrect Email Or Password"
                                                                             message:@"Check the email address and password and try to login again."
                                                                             preferredStyle:UIAlertControllerStyleAlert];
                                       UIAlertAction *okAction = [UIAlertAction
                                                                  actionWithTitle:NSLocalizedString(@"Ok", @"Ok action")
                                                                  style:UIAlertActionStyleDefault
                                                                  handler:^(UIAlertAction *action)
                                                                  {
                                                                      _password = nil;
                                                                      [self loginAction:self];
                                                                      return;
                                                                  }];
                                       
                                       NSLog(@"objects is %@", objects);
                                       
                                       //error
                                       if(error || !objects || !objects.count)
                                       {
                                           _activityIndicator.hidden = YES;
                                           [_activityIndicator stopAnimating];
                                           [[NSNotificationCenter defaultCenter] postNotificationName:@"hideActivityView" object:self userInfo:nil];
                                           [alertController addAction:okAction];
                                           [self presentViewController:alertController animated:YES completion:nil];
                                           return;
                                       }
                                       
                                       PFUser* newUser = objects[0];
                                   
                                       NSLog(@"newuser is %@", newUser.username);
                                       [PFUser logInWithUsernameInBackground:newUser.username password:_password block:^(PFUser *user, NSError *error)
                                        {
                                            if(!error)
                                            {
                                                NSLog(@"User logged in!");
                                                PFInstallation *installation = [PFInstallation currentInstallation];
                                                [installation setValue:@"ios" forKey:@"deviceType"];
                                                installation[@"user"] = newUser;
                                                installation[@"badge"] = [NSNumber numberWithInt:0];
                                                PFACL *defaultACL = [PFACL ACL];
                                                [defaultACL setReadAccess:true forUser:newUser];
                                                [defaultACL setWriteAccess:true forUser:newUser];
                                                [defaultACL setPublicReadAccess:false];
                                                [defaultACL setPublicWriteAccess:false];
                                                [installation setACL:defaultACL];
                                                [installation saveInBackground];
                                                
                                                //get the main database
                                                PFUser* user = [PFUser currentUser];
                                                MainDatabase* md = [MainDatabase shared];
                                                [md.queue inDatabase:^(FMDatabase *db) {
                                                    NSString *insertUserSQL = @"INSERT INTO user (user_id, is_me) VALUES (?,?)";
                                                    NSArray* userValues = @[user.objectId, [NSNumber numberWithInt:1]];
                                                    [db executeUpdate:insertUserSQL withArgumentsInArray:userValues];
                                                }];
                                                AppDelegate* appDelegate = [[UIApplication sharedApplication] delegate];
                                                CBPeripheralInterface* peripheral = [appDelegate peripheral];
                                                peripheral.userId = [PFUser currentUser].objectId;
                                                [peripheral startAdvertisingProfile];
                                                
                                                [self performSegueWithIdentifier:@"loggedInSegue"
                                                                          sender:self];
                                            }
                                            else
                                            {
                                                _activityIndicator.hidden = YES;
                                                [_activityIndicator stopAnimating];
                                                [[NSNotificationCenter defaultCenter] postNotificationName:@"hideActivityView" object:self userInfo:nil];
                                                [alertController addAction:okAction];
                                                [self presentViewController:alertController animated:YES completion:nil];
                                                return;
                                            }
                                        }];
                                   }];
                                   
                               }];
    
    UIAlertAction *cancelAction = [UIAlertAction
                                   actionWithTitle:NSLocalizedString(@"Cancel", @"Cancel action")
                                   style:UIAlertActionStyleCancel
                                   handler:^(UIAlertAction *action)
                                   {
                                       _email = nil;
                                       _password = nil;
                                       _username = nil;
                                       return;
                                   }];
    
    [alertController addAction:cancelAction];
    [alertController addAction:okAction];
    [self presentViewController:alertController animated:YES completion:nil];*/
    
}

- (IBAction)registerAction:(id)sender {
    
    //just create a new random user
    UIAlertController *alertController = [UIAlertController
                                          alertControllerWithTitle:@"Error Logging In"
                                          message:@"An error happened while trying to login.  Check your internet connection and try again."
                                          preferredStyle:UIAlertControllerStyleAlert];
    UIAlertAction *okAction = [UIAlertAction
                               actionWithTitle:NSLocalizedString(@"Ok", @"Ok action")
                               style:UIAlertActionStyleDefault
                               handler:^(UIAlertAction *action)
                               {
                                   _activityIndicator.hidden = YES;
                                   [_activityIndicator stopAnimating];
                                   self.navigationItem.rightBarButtonItem.enabled = YES;
                                   [[NSNotificationCenter defaultCenter] postNotificationName:@"hideActivityView" object:self userInfo:nil];
                                   [self.navigationController setNavigationBarHidden:NO];
                                   [self tutorial];
                                   return;
                               }];

    //set user data to be registered
    PFUser* newUser = [PFUser user];
    newUser.username = [self randomStringWithLength:32];
    newUser.password = @"";
    [newUser setObject:@"anon" forKey:@"posting_name"];
    [newUser setObject:[NSNumber numberWithInt:0] forKey:@"sort"];
    [newUser setObject:[NSNumber numberWithInt:2] forKey:@"streamTimeHours"];
    _activityIndicator.hidden = NO;
    [_activityIndicator startAnimating];
    [[NSNotificationCenter defaultCenter] postNotificationName:@"showActivityView" object:self userInfo:nil];
    
    
    //Sign up the user if possible and redirect to main page
    [newUser signUpInBackgroundWithBlock:^(BOOL succeeded, NSError *error)
     {
         if(error)
         {
             [alertController addAction:okAction];
             [self presentViewController:alertController animated:YES completion:nil];
             return;
         }
         
         //successfully registered the new user
         PFInstallation *installation = [PFInstallation currentInstallation];
         if(installation.deviceToken)
         {
             [installation setValue:@"ios" forKey:@"deviceType"];
             installation[@"user"] = newUser;
             installation[@"badge"] = [NSNumber numberWithInt:0];
             PFACL *defaultACL = [PFACL ACL];
             [defaultACL setReadAccess:true forUser:newUser];
             [defaultACL setWriteAccess:true forUser:newUser];
             [defaultACL setPublicReadAccess:false];
             [defaultACL setPublicWriteAccess:false];
             [installation setACL:defaultACL];
             [installation saveInBackground];
         }
         //save user id to database and add to peripheral
         //get the main database
         __block PFUser* user = [PFUser currentUser];
         MainDatabase* md = [MainDatabase shared];
         [md.queue inDatabase:^(FMDatabase *db) {
             NSString *insertUserSQL = @"INSERT INTO user (user_id, is_me) VALUES (?,?)";
             NSArray* userValues = @[user.objectId, [NSNumber numberWithInt:1]];
             [db executeUpdate:insertUserSQL withArgumentsInArray:userValues];
         }];
         AppDelegate* appDelegate = [[UIApplication sharedApplication] delegate];
         CBPeripheralInterface* peripheral = [appDelegate peripheral];
         peripheral.userId = [PFUser currentUser].objectId;
         [peripheral startAdvertisingProfile];
         
         
         [PFCloud callFunctionInBackground:@"addUserPrivate" withParameters:@{} block:^(id object, NSError *error) {
             
             if(error)
             {
                 NSLog(@"error running cloud function");
                 [alertController addAction:okAction];
                 [self presentViewController:alertController animated:YES completion:nil];
                 return;
             }
             else
             {
                 [user fetchIfNeededInBackground];
                 NSLog(@"successful save.");
                 [self performSegueWithIdentifier:@"loggedInSegue"
                                           sender:self];
             }
         }];
         
     }];
    
    
    
    
    /*UIAlertController *alertController = [UIAlertController
                                          alertControllerWithTitle:@"Register"
                                          message:@"Register For An Account:"
                                          preferredStyle:UIAlertControllerStyleAlert];
    
    [alertController addTextFieldWithConfigurationHandler:^(UITextField *textField)
     {
         textField.tag = EMAIL_TAG;
         textField.delegate = self;
         textField.placeholder = NSLocalizedString(@"Email (This is never visible)", @"Email (This is never visible)");
         if(_email)
             textField.text = _email;
         [textField setKeyboardType: UIKeyboardTypeEmailAddress];
     }];
    [alertController addTextFieldWithConfigurationHandler:^(UITextField *textField)
     {
         textField.tag = USERNAME_TAG;
         textField.delegate = self;
         textField.placeholder = NSLocalizedString(@"Posting Name", @"Username");
         if(_username)
             textField.text = _username;
     }];
    
    [alertController addTextFieldWithConfigurationHandler:^(UITextField *textField)
     {
         textField.tag = PASSWORD_TAG;
         textField.delegate = self;
         textField.placeholder = NSLocalizedString(@"Password", @"Password");
         textField.secureTextEntry = YES;
         if(_password)
             textField.text = _password;
     }];
    
    UIAlertAction *okAction = [UIAlertAction
                               actionWithTitle:NSLocalizedString(@"Register", @"OK action")
                               style:UIAlertActionStyleDefault
                               handler:^(UIAlertAction *action)
                               {
                                   UITextField *email = alertController.textFields.firstObject;
                                   UITextField *username = alertController.textFields[1];
                                   UITextField *password = alertController.textFields.lastObject;
                                   
                                   
                                   _email = email.text;
                                   _username = username.text;
                                   _password = password.text;
                                   
                                   //present error for nil length
                                   if(!_email.length || !_username.length || !_password.length)
                                   {
                                       UIAlertController *alertController = [UIAlertController
                                                                             alertControllerWithTitle:@"Empty Fields"
                                                                             message:@"Make sure to fill out all fields to register for an account."
                                                                             preferredStyle:UIAlertControllerStyleAlert];
                                       UIAlertAction *okAction = [UIAlertAction
                                                                  actionWithTitle:NSLocalizedString(@"Ok", @"Ok action")
                                                                  style:UIAlertActionStyleDefault
                                                                  handler:^(UIAlertAction *action)
                                                                  {
                                                                      if(!_email.length)
                                                                          _email = nil;
                                                                      if(!_password.length)
                                                                          _password = nil;
                                                                      if(!_username.length)
                                                                          _username = nil;
                                                                      [self registerAction:self];
                                                                      return;
                                                                  }];
                                       
                                       [alertController addAction:okAction];
                                       [self presentViewController:alertController animated:YES completion:nil];
                                       return;
                                   }
                                   
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

                                   
                                   //all fields are filled in
                                   //set user data to be registered
                                   PFUser* newUser = [PFUser user];
                                   newUser.email = [_email lowercaseString];
                                   newUser.username = _username;
                                   newUser.password = _password;
                                   _activityIndicator.hidden = NO;
                                   [_activityIndicator startAnimating];
                                   [[NSNotificationCenter defaultCenter] postNotificationName:@"showActivityView" object:self userInfo:nil];
                                       
                                   
                                   //Sign up the user if possible and redirect to main page
                                   [newUser signUpInBackgroundWithBlock:^(BOOL succeeded, NSError *error)
                                    {
                                        __block UIAlertController *alertController;
                                        __block UIAlertAction *okAction;
                                        if(!error)
                                        {
                                            NSLog(@"Successfully registered");
                                            PFInstallation *installation = [PFInstallation currentInstallation];
                                            [installation setValue:@"ios" forKey:@"deviceType"];
                                            installation[@"user"] = newUser;
                                            installation[@"badge"] = [NSNumber numberWithInt:0];
                                            PFACL *defaultACL = [PFACL ACL];
                                            [defaultACL setReadAccess:true forUser:newUser];
                                            [defaultACL setWriteAccess:true forUser:newUser];
                                            [defaultACL setPublicReadAccess:false];
                                            [defaultACL setPublicWriteAccess:false];
                                            [installation setACL:defaultACL];
                                            [installation saveInBackground];
                                            //save user id to database and add to peripheral
                                            //get the main database
                                            __block PFUser* user = [PFUser currentUser];
                                            MainDatabase* md = [MainDatabase shared];
                                            [md.queue inDatabase:^(FMDatabase *db) {
                                                NSString *insertUserSQL = @"INSERT INTO user (user_id, is_me) VALUES (?,?)";
                                                NSArray* userValues = @[user.objectId, [NSNumber numberWithInt:1]];
                                                [db executeUpdate:insertUserSQL withArgumentsInArray:userValues];
                                            }];
                                            AppDelegate* appDelegate = [[UIApplication sharedApplication] delegate];
                                            CBPeripheralInterface* peripheral = [appDelegate peripheral];
                                            peripheral.userId = [PFUser currentUser].objectId;
                                            [peripheral startAdvertisingProfile];
                                            
                                            
                                            [PFCloud callFunctionInBackground:@"addUserPrivate" withParameters:@{} block:^(id object, NSError *error) {
                                            
                                                if(error)
                                                {
                                                    NSLog(@"error running cloud function");
                                                    alertController = [UIAlertController
                                                                       alertControllerWithTitle:@"Error Registering"
                                                                       message:@"Couldn't register account.  Please check your internet connection and try again."
                                                                       preferredStyle:UIAlertControllerStyleAlert];
                                                    
                                                    okAction= [UIAlertAction
                                                               actionWithTitle:NSLocalizedString(@"Ok", @"Ok action")
                                                               style:UIAlertActionStyleDefault
                                                               handler:^(UIAlertAction *action)
                                                               {
                                                                   _activityIndicator.hidden = YES;
                                                                   [_activityIndicator stopAnimating];
                                                                   [[NSNotificationCenter defaultCenter] postNotificationName:@"hideActivityView" object:self userInfo:nil];
                                                                   [user deleteEventually];
                                                                   [self registerAction:self];
                                                                   return;
                                                               }];
                                                    [alertController addAction:okAction];
                                                    [self presentViewController:alertController animated:YES completion:nil];
                                                    return;
                                                }
                                                else
                                                {
                                                    [user fetchIfNeededInBackground];
                                                    NSLog(@"successful save.");
                                                    [self performSegueWithIdentifier:@"loggedInSegue"
                                                                              sender:self];
                                                }
                                            }];
                                        }
                                        else{
                                            NSLog(@"Failed to register");
                                            
                                            //email error code
                                            if(error.code == 203)
                                            {
                                                alertController = [UIAlertController
                                                                   alertControllerWithTitle:@"Email Address Is Already Taken"
                                                                   message:@"Select A Different Email Address"
                                                                   preferredStyle:UIAlertControllerStyleAlert];
                                                
                                                okAction= [UIAlertAction
                                                           actionWithTitle:NSLocalizedString(@"Ok", @"Ok action")
                                                           style:UIAlertActionStyleDefault
                                                           handler:^(UIAlertAction *action)
                                                           {
                                                               _email = nil;
                                                               _activityIndicator.hidden = YES;
                                                               [_activityIndicator stopAnimating];
                                                               [[NSNotificationCenter defaultCenter] postNotificationName:@"hideActivityView" object:self userInfo:nil];
                                                               [self registerAction:self];
                                                               return;
                                                           }];
                                            }
                                            else if(error.code == 202)
                                            {
                                                alertController = [UIAlertController
                                                                                      alertControllerWithTitle:@"Username Is Already Taken"
                                                                                      message:@"Select A Different Username"
                                                                                      preferredStyle:UIAlertControllerStyleAlert];
                                                
                                                 okAction= [UIAlertAction
                                                                           actionWithTitle:NSLocalizedString(@"Ok", @"Ok action")
                                                                           style:UIAlertActionStyleDefault
                                                                           handler:^(UIAlertAction *action)
                                                                           {
                                                                               _username = nil;
                                                                               _activityIndicator.hidden = YES;
                                                                               [_activityIndicator stopAnimating];
                                                                               [[NSNotificationCenter defaultCenter] postNotificationName:@"hideActivityView" object:self userInfo:nil];
                                                                               [self registerAction:self];
                                                                               return;
                                                                           }];
                                            }
                                            else
                                            {
                                                alertController = [UIAlertController
                                                                   alertControllerWithTitle:@"Error Registering"
                                                                   message:@"Couldn't register account.  Please check your internet connection and try again."
                                                                   preferredStyle:UIAlertControllerStyleAlert];
                                                
                                                okAction= [UIAlertAction
                                                           actionWithTitle:NSLocalizedString(@"Ok", @"Ok action")
                                                           style:UIAlertActionStyleDefault
                                                           handler:^(UIAlertAction *action)
                                                           {
                                                               _activityIndicator.hidden = YES;
                                                               [_activityIndicator stopAnimating];
                                                               [[NSNotificationCenter defaultCenter] postNotificationName:@"hideActivityView" object:self userInfo:nil];
                                                               
                                                               [self registerAction:self];
                                                               return;
                                                           }];
                                            }
                                            
                                            [alertController addAction:okAction];
                                            [self presentViewController:alertController animated:YES completion:nil];
                                            return;
                                        }
                                        
                                   }];

                               }];
    
    UIAlertAction *cancelAction = [UIAlertAction
                                   actionWithTitle:NSLocalizedString(@"Cancel", @"Cancel action")
                                   style:UIAlertActionStyleCancel
                                   handler:^(UIAlertAction *action)
                                   {
                                       _email = nil;
                                       _password = nil;
                                       _username = nil;
                                       return;
                                   }];
    
    [alertController addAction:cancelAction];
    [alertController addAction:okAction];
    [self presentViewController:alertController animated:YES completion:nil];*/
}

- (UIViewController *)pageViewController:(UIPageViewController *)pageViewController viewControllerBeforeViewController:(UIViewController *)viewController
{
    NSUInteger index = ((MainTutorialContentViewController*) viewController).pageIndex;
    
    if ((index == 0) || (index == NSNotFound)) {
        return nil;
    }
    
    index--;
    return [self viewControllerAtIndex:index];
}

- (UIViewController *)pageViewController:(UIPageViewController *)pageViewController viewControllerAfterViewController:(UIViewController *)viewController
{
    NSUInteger index = ((MainTutorialContentViewController*) viewController).pageIndex;
    
    if (index == NSNotFound) {
        return nil;
    }
    
    index++;
    if (index == [self.pageTitles count]) {
        return nil;
    }
    return [self viewControllerAtIndex:index];
}

- (MainTutorialContentViewController *)viewControllerAtIndex:(NSUInteger)index
{
    if (([self.pageTitles count] == 0) || (index >= [self.pageTitles count])) {
        return nil;
    }
    
    // Create a new view controller and pass suitable data.
    MainTutorialContentViewController *pageContentViewController = [self.storyboard instantiateViewControllerWithIdentifier:@"PageContentController"];
    pageContentViewController.imageFile = self.pageImages[index];
    pageContentViewController.titleText = self.pageTitles[index];
    pageContentViewController.pageIndex = index;
    
    return pageContentViewController;
}
- (NSInteger)presentationCountForPageViewController:(UIPageViewController *)pageViewController
{
    return [self.pageTitles count];
}

- (NSInteger)presentationIndexForPageViewController:(UIPageViewController *)pageViewController
{
    return 0;
}

-(void) tutorial
{
    // Store the data
    if(_showTutorial)
        return;
    _showTutorial = YES;
    //reset the background color to white
    self.view.backgroundColor = [UIColor whiteColor];
    //setup pages for tutorial
    _pageTitles = @[@"Anonymously share streams of photos to those around you.", @"View content that actually matters to you right here and now."];
    _pageImages = @[@"iphone_stock_1.png", @"iphone_stock_2.png"];
    
    // Create page view controller
    self.pageViewController = [self.storyboard instantiateViewControllerWithIdentifier:@"MainTutorialPageViewController"];
    self.pageViewController.dataSource = self;
    
    MainTutorialContentViewController *startingViewController = [self viewControllerAtIndex:0];
    NSArray *viewControllers = @[startingViewController];
    [self.pageViewController setViewControllers:viewControllers direction:UIPageViewControllerNavigationDirectionForward animated:NO completion:nil];
    
    CGFloat navBarHeight = self.navigationController.navigationBar.frame.size.height;
    // Change the size of page view controller
    self.pageViewController.view.frame = CGRectMake(0, navBarHeight, self.view.frame.size.width, self.view.frame.size.height-navBarHeight);
    
    [self addChildViewController:_pageViewController];
    [self.view addSubview:_pageViewController.view];
    [self.pageViewController didMoveToParentViewController:self];
    //[self addChildViewController:_pageViewController];
    //[self.view addSubview:_pageViewController.view];
    //[self presentViewController:self.pageViewController animated:YES completion:NULL];
    //[self.pageViewController didMoveToParentViewController:self];
    
}


//Prepare segue
- (void) prepareForSegue:(UIStoryboardSegue *)segue sender:(id)sender {
    //If we are segueing to selectedProfile then we need to save profile ID
    if([segue.identifier isEqualToString:@"loggedInSegue"]){
        UINavigationController *navController = segue.destinationViewController;
        MainTableViewController* controller = [navController childViewControllers].firstObject;
        controller.tableFirstLoad = YES;
        
    }
}

- (BOOL)textField:(UITextField *)textField
shouldChangeCharactersInRange:(NSRange)range
replacementString:(NSString *)string
{
    int max_chars = MAX_EMAIL_LENGTH;
    
    if(textField.tag == USERNAME_TAG)
        max_chars = MAX_USERNAME_LENGTH;
    else if (textField.tag == PASSWORD_TAG)
        max_chars = MAX_PASSWORD_LENGTH;
        
    //check if they user is trying to enter too many characters
    if([[textField text] length] - range.length + string.length > max_chars)
    {
        return NO;
    }
    
    
    return YES;
}
@end
