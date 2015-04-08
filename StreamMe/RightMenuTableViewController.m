//
//  RightMenuTableViewController.m
//  WhoYu
//
//  Created by Chase Midler on 3/6/15.
//  Copyright (c) 2015 midler. All rights reserved.
//

#import "RightMenuTableViewController.h"

@interface RightMenuTableViewController ()

@end

@implementation RightMenuTableViewController
@synthesize menuTableView;
- (void)viewDidLoad {
    [super viewDidLoad];
    self.menuTableView.tableFooterView = [[UIView alloc] initWithFrame:CGRectZero];
    
}

-(void) viewWillAppear:(BOOL)animated
{
    NSLog(@"Origin controller is %@", _originController);
    if(!_originController || !_originController.length)
    {
        menuActions = nil;
        [menuTableView reloadData];
        return;
    }
    [self setMenuValues];
    [menuTableView reloadData];
}

-(void) viewWillDisappear:(BOOL)animated
{
    _originController = nil;
}

-(void) setMenuValues
{
    //decide which menu to display
    if([_originController isEqualToString:@"viewMyProfile"])
    {
        menuActions = @[@"Change Picture", @"Edit Phone Numbers", @"Edit Email Addresses"];
        StoreUserProfile* sup = [StoreUserProfile shared];
        UIImage* pictureImage = [UIImage imageWithData:sup.profile.picture_data];
        UIImage* phoneImage = [UIImage imageNamed:@"phone.png"];
        UIImage* emailImage = [self imageNamed:@"email.png" withColor:[UIColor blackColor]];
        menuImages = @[pictureImage, phoneImage, emailImage];
    }
    else
    {
        
        //get the main database
        MainDatabase* md = [MainDatabase shared];
        [md.queue inDatabase:^(FMDatabase *db) {
            NSString *countQuery = @"SELECT user_id FROM user WHERE user_id = ?";
            NSArray* values = @[_profile.user_id];
            FMResultSet* s = [db executeQuery:countQuery withArgumentsInArray:values];
            
            
            bool hasUser = NO;
            // there is a user
            while ([s next])
                hasUser = YES;
            
            
            bool hasContactInfo = NO;
            //See if we have any of the user's contact info saved
            //get phone info
            NSString *phoneQuery = @"SELECT type, number FROM phone WHERE user_id = ?";
             
             FMResultSet* phoneResult = [db executeQuery:phoneQuery withArgumentsInArray:values];
            _privProfile = [[PrivateProfile alloc] init];
             //Loop through all the returned rows and get the corresponding event data
             while( [phoneResult next] )
             {
                 Phone* phone = [[Phone alloc] init];
                 phone.type = [phoneResult stringForColumnIndex:0];
                 phone.number = [phoneResult stringForColumnIndex:1];
                 [_privProfile.phoneNumbers addObject:phone];
                 hasContactInfo = YES;
             }
            
             //emails
             NSString *emailQuery = @"SELECT type, address FROM email WHERE user_id = ?";
             FMResultSet* emailResult = [db executeQuery:emailQuery withArgumentsInArray:values];
             //Loop through all the returned rows and get the corresponding event data
             while( [emailResult next] )
             {
                 Email* email = [[Email alloc] init];
                 email.type = [emailResult stringForColumnIndex:0];
                 email.address = [emailResult stringForColumnIndex:1];
                 [_privProfile.emailAddresses addObject:email];
                 hasContactInfo = YES;
             }
            
            
            NSString *contactQuery = @"SELECT is_new FROM contact WHERE user_id = ?";
            
            FMResultSet* contactResult = [db executeQuery:contactQuery withArgumentsInArray:values];
            
            bool isPending = NO;
            //Loop through all the returned rows and get the corresponding event data
            while( [contactResult next] )
            {
                isPending = [contactResult boolForColumnIndex:0];
                hasContactInfo = YES;
            }
            
            NSLog(@"Has contact info = %d", hasContactInfo);
            
            if( hasUser)
            {
                //different menu layout depending on if we have contact info for the user or not
                if(hasContactInfo)
                {
                    if(isPending)
                        menuActions = @[[NSString stringWithFormat:@"Remove %@", _profile.first_name], @"Add Notes", @"(Pending) Contact Card", @"Send Contact Info"];
                    else
                        menuActions = @[[NSString stringWithFormat:@"Remove %@", _profile.first_name], @"Add Notes", @"Contact Card", @"Send Contact Info"];
                    UIImage* trashImage = [UIImage imageNamed:@"trash.png"];
                    UIImage* notepadImage = [UIImage imageNamed:@"notepad.png"];
                    UIImage* showContactImage = [UIImage imageNamed:@"contact_card.png"];
                    UIImage* sendContactImage = [UIImage imageNamed:@"sending_contact.png"];
                    menuImages = @[trashImage, notepadImage, showContactImage, sendContactImage];
                }
                else
                {
                    menuActions = @[[NSString stringWithFormat:@"Remove %@", _profile.first_name], @"Add Notes", @"Send Contact Info"];
                    UIImage* trashImage = [UIImage imageNamed:@"trash.png"];
                    UIImage* notepadImage = [UIImage imageNamed:@"notepad.png"];
                    UIImage* sendContactImage = [UIImage imageNamed:@"sending_contact.png"];
                    menuImages = @[trashImage, notepadImage, sendContactImage];
                }
            }
            else
            {
                //Static case if we don't have the user saved
                if(hasContactInfo)
                {
                    if(isPending)
                        menuActions = @[[NSString stringWithFormat:@"Save %@", _profile.first_name], @"Add Notes", @"(Pending) Contact Card", @"Send Contact Info"];
                    else
                        menuActions = @[[NSString stringWithFormat:@"Save %@", _profile.first_name], @"Add Notes", @"Contact Card", @"Send Contact Info"];
                    UIImage* saveImage = [UIImage imageNamed:@"save.png"];
                    UIImage* notepadImage = [UIImage imageNamed:@"notepad.png"];
                    UIImage* showContactImage = [UIImage imageNamed:@"contact_card.png"];
                    UIImage* sendContactImage = [UIImage imageNamed:@"sending_contact.png"];
                    menuImages = @[saveImage, notepadImage, showContactImage, sendContactImage];
                }
                else
                {
                    menuActions = @[[NSString stringWithFormat:@"Save %@", _profile.first_name], @"Add Notes", @"Send Contact Info"];
                    UIImage* saveImage = [UIImage imageNamed:@"save.png"];
                    UIImage* notepadImage = [UIImage imageNamed:@"notepad.png"];
                    UIImage* sendContactImage = [UIImage imageNamed:@"sending_contact.png"];
                    menuImages = @[saveImage, notepadImage, sendContactImage];
                }
            }
            [menuTableView reloadData];
        }];
    }
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

#pragma mark - Table view data source

- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView {
    // Return the number of sections.
    return 1;
}

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section {
    // Return the number of rows in the section.
    return menuActions.count;
}


- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath {
    RightMenuTableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:@"menuCell" forIndexPath:indexPath];
    cell.separatorInset = UIEdgeInsetsMake(0, RIGHT_SLIDE + 30, 0, 0);
    cell.menuLabel.text = menuActions[indexPath.row];
    cell.menuImageView.image = menuImages[indexPath.row];
    
    //round edges if profile picture
    if([menuActions[indexPath.row] isEqualToString:@"Change Picture"])
    {
        cell.menuImageView.layer.cornerRadius = 11;
        cell.menuImageView.clipsToBounds = YES;
    }
    return cell;
}

//On click of cell, segue
- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath
{
    UITableViewCell *cell = [tableView cellForRowAtIndexPath:indexPath];
    //[tableView dequeueReusableCellWithIdentifier:@"menuCell" forIndexPath:indexPath];
    [cell setSelectionStyle:UITableViewCellSelectionStyleDefault];
    
    NSString* mutualFriends = [NSString stringWithFormat:@"%d Mutual Friends", _numberOfFriends];
    if(_numberOfFriends == 1)
        mutualFriends = @"1 Mutual Friend";
    
    //based on what the cell says perform an ation
    if([menuActions[indexPath.row] isEqualToString:@"Change Picture"])
        [self performSegueWithIdentifier:@"changePictureSegue" sender:self];
    else if ([[((NSString*)menuActions[indexPath.row]) substringToIndex:4] isEqualToString:@"Save"] )
        [self saveAction];
    else if ([[((NSString*)menuActions[indexPath.row]) substringToIndex:6] isEqualToString:@"Remove"] )
        [self removeAction];
    else if([menuActions[indexPath.row] isEqualToString:@"Add Notes"])
        [self performSegueWithIdentifier:@"noteSegue" sender:self];
    else if([menuActions[indexPath.row] isEqualToString:@"Edit Phone Numbers"])
        [self performSegueWithIdentifier:@"phoneSegue" sender:self];
    else if([menuActions[indexPath.row] isEqualToString:@"Edit Email Addresses"])
        [self performSegueWithIdentifier:@"emailSegue" sender:self];
    else if([menuActions[indexPath.row] isEqualToString:@"Send Contact Info"])
        [self performSegueWithIdentifier:@"sendContactSegue" sender:self];
    else if([menuActions[indexPath.row] isEqualToString:@"Contact Card"])
        [self performSegueWithIdentifier:@"contactCardSegue" sender:self];
    else if([menuActions[indexPath.row] isEqualToString:@"(Pending) Contact Card"])
        [self checkPending];
}

- (CGFloat)tableView:(UITableView *)tableView heightForHeaderInSection:(NSInteger)section {
    return .1f;
}

-(void) checkPending
{
    //letting the user know
    UIAlertAction *newOkAction = [UIAlertAction
                                  actionWithTitle:NSLocalizedString(@"Accept", @"Accept action")
                                  style:UIAlertActionStyleDefault
                                  handler:^(UIAlertAction *action)
                                  {
                                      //update the database and segue
                                      //get the main database
                                      MainDatabase* md = [MainDatabase shared];
                                      [md.queue inDatabase:^(FMDatabase *db) {
                                          NSString *updateSQL = @"UPDATE contact SET is_new = ? WHERE user_id = ?";
                                          NSArray* values = @[[NSNumber numberWithInt:0], _profile.user_id];
                                          [db executeUpdate:updateSQL withArgumentsInArray:values];
                                          [self performSegueWithIdentifier:@"contactCardSegue" sender:self];
                                      }];
                                      return;
                                  }];
    UIAlertAction *cancelAction = [UIAlertAction
                                   actionWithTitle:NSLocalizedString(@"Discard", @"Discard action")
                                   style:UIAlertActionStyleCancel
                                   handler:^(UIAlertAction *action)
                                   {
                                       //delete the contact info for the user
                                       //get the main database
                                       bool __block inQuery = YES;
                                       MainDatabase* md = [MainDatabase shared];
                                       [md.queue inDatabase:^(FMDatabase *db) {
                                           //delete the user
                                           NSString *deleteUserSQL = @"DELETE FROM contact WHERE user_id = ?";
                                           NSArray* values = @[_profile.user_id];
                                           [db executeUpdate:deleteUserSQL withArgumentsInArray:values];
                                           //delete phones and emails too
                                           NSString *deletePhoneSQL = @"DELETE FROM phone WHERE user_id = ?";
                                           [db executeUpdate:deletePhoneSQL withArgumentsInArray:values];
                                           NSString *deleteEmailSQL = @"DELETE FROM email WHERE user_id = ?";
                                           [db executeUpdate:deleteEmailSQL withArgumentsInArray:values];
                                           inQuery = NO;
                                       }];
                                       //idle while in query
                                       while(inQuery)
                                           ;
                                       [self setMenuValues];
                                   }];
    
    UIAlertController *alertController = [UIAlertController
                                          alertControllerWithTitle:@"New Contact Card"
                                          message:[NSString stringWithFormat:@"%@ sent you a contact card.", _profile.first_name]
                                          preferredStyle:UIAlertControllerStyleAlert];
    
    [alertController addAction:cancelAction];
    [alertController addAction:newOkAction];
    [self presentViewController:alertController animated:YES completion:nil];
    return;
}

// In a storyboard-based application, you will often want to do a little preparation before navigation
- (void)prepareForSegue:(UIStoryboardSegue *)segue sender:(id)sender {
    if([segue.identifier isEqualToString:@"noteSegue"])
    {
        UINavigationController *navController = segue.destinationViewController;
        UserNotesViewController* controller = [navController childViewControllers].firstObject;
        controller.profile = _profile;
    }
    else if([segue.identifier isEqualToString:@"sendContactSegue"])
    {
        UINavigationController *navController = segue.destinationViewController;
        RequestPrivateDataTableViewController* controller = [navController childViewControllers].firstObject;
        controller.profile = _profile;
        controller.isMyProfile = NO;
    }
    else if([segue.identifier isEqualToString:@"contactCardSegue"])
    {
        UINavigationController *navController = segue.destinationViewController;
        ContactCardViewController* controller = [navController childViewControllers].firstObject;
        controller.profile = _profile;
        controller.privProfile = _privProfile;
    }
}

-(void) saveAction
{
    //get the main database
    MainDatabase* md = [MainDatabase shared];
    [md.queue inDatabase:^(FMDatabase *db) {
        NSString *insertUserSQL = @"INSERT INTO user (user_id, is_me, created_at, notes) VALUES (?, ?, ?, ?)";
        NSArray* values = @[_profile.user_id, [NSNumber numberWithInt:0], [NSNumber numberWithDouble:[[NSDate date] timeIntervalSince1970]], @"Add Notes"];
        [db executeUpdate:insertUserSQL withArgumentsInArray:values];
        
        //letting the user know
        UIAlertAction *newOkAction = [UIAlertAction
                                      actionWithTitle:NSLocalizedString(@"Ok", @"Ok action")
                                      style:UIAlertActionStyleDefault
                                      handler:^(UIAlertAction *action)
                                      {
                                          NSLog(@"Ok action");
                                          //reload the table
                                          [self setMenuValues];
                                          return;
                                      }];
        
        UIAlertController *alertController = [UIAlertController
                                              alertControllerWithTitle:[NSString stringWithFormat:@"Saved %@", _profile.first_name]
                                              message:[NSString stringWithFormat: @"%@ has been added to your saved profiles.", _profile.first_name]
                                              preferredStyle:UIAlertControllerStyleAlert];
        
        [alertController addAction:newOkAction];
        
        [self presentViewController:alertController animated:YES completion:nil];
        return;
    }];
}

-(void) removeAction
{
    //get the main database
    MainDatabase* md = [MainDatabase shared];
    [md.queue inDatabase:^(FMDatabase *db) {
        //delete the user
        NSString *deleteUserSQL = @"DELETE FROM user WHERE user_id = ?";
        NSArray* values = @[_profile.user_id];
        [db executeUpdate:deleteUserSQL withArgumentsInArray:values];
        
        //letting the user know
        UIAlertAction *newOkAction = [UIAlertAction
                                      actionWithTitle:NSLocalizedString(@"Ok", @"Ok action")
                                      style:UIAlertActionStyleDefault
                                      handler:^(UIAlertAction *action)
                                      {
                                          NSLog(@"Ok action");
                                          [self setMenuValues];
                                          return;
                                      }];
        
        UIAlertController *alertController = [UIAlertController
                                              alertControllerWithTitle:[NSString stringWithFormat:@"Removed %@", _profile.first_name]
                                              message:[NSString stringWithFormat: @"%@ has been removed from your saved profiles.", _profile.first_name]
                                              preferredStyle:UIAlertControllerStyleAlert];
        
        [alertController addAction:newOkAction];
        
        [self presentViewController:alertController animated:YES completion:nil];
        return;
    }];
}

-(UIImage *)imageNamed:(NSString *)name withColor:(UIColor *)color {
    
    UIImage *img = [UIImage imageNamed:name];
    CGRect rect = CGRectMake(0.0f, 0.0f, img.size.width, img.size.height);
    
    if (UIGraphicsBeginImageContextWithOptions) {
        CGFloat imageScale = 1.0f;
        if ([self respondsToSelector:@selector(scale)])  // The scale property is new with iOS4.
            imageScale = img.scale;
        UIGraphicsBeginImageContextWithOptions(img.size, NO, imageScale);
    }
    else {
        UIGraphicsBeginImageContext(img.size);
    }
    
    [img drawInRect:rect];
    
    CGContextRef context = UIGraphicsGetCurrentContext();
    CGContextSetBlendMode(context, kCGBlendModeSourceIn);
    
    CGContextSetFillColorWithColor(context, color.CGColor);
    CGContextFillRect(context, rect);
    
    UIImage *image = UIGraphicsGetImageFromCurrentImageContext();
    UIGraphicsEndImageContext();
    
    return image;
    
}


@end
