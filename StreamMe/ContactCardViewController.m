//
//  ContactCardViewController.m
//  WhoYu
//
//  Created by Chase Midler on 3/9/15.
//  Copyright (c) 2015 midler. All rights reserved.
//

#import "ContactCardViewController.h"

@interface ContactCardViewController ()

@end

@implementation ContactCardViewController
@synthesize contactTableView;
- (void)viewDidLoad {
    [super viewDidLoad];
    self.automaticallyAdjustsScrollViewInsets = NO;
    [_activityIndicator stopAnimating];
    // This will remove extra separators from tableview
    self.contactTableView.tableFooterView = [[UIView alloc] initWithFrame:CGRectZero];
    _contactName = _profile.first_name;
    _pictureImageView.image = [UIImage imageWithData:_profile.picture_data];
    _pictureImageView.layer.cornerRadius = 40;
    _pictureImageView.clipsToBounds = YES;
    _deleteButton.layer.cornerRadius = 5;
    _nameLabel.text = _profile.first_name;
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView {
    // Return the number of sections.
    int numberOfSections = !!_privProfile.phoneNumbers.count + !!_privProfile.emailAddresses.count;
    return numberOfSections;
}

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section {
    // Return the number of rows in the section.
    int numberOfSections = !!_privProfile.phoneNumbers.count + !!_privProfile.emailAddresses.count;
    
    //both phones and emails
    if(numberOfSections == 1)
    {
        //phones are section 0
        if(section==1)
        {
            return _privProfile.emailAddresses.count;
        }
        else
        {
            return _privProfile.phoneNumbers.count;
        }
    }
    //Only 1 section so either emails or phones
    else if(_privProfile.emailAddresses.count)
    {
        return _privProfile.emailAddresses.count;
    }
    else
    {
        return _privProfile.phoneNumbers.count;
    }
}

//Get the title for each section
- (NSString *)tableView:(UITableView *)tableView titleForHeaderInSection:(NSInteger)section
{
    int numberOfSections = !!_privProfile.phoneNumbers.count + !!_privProfile.emailAddresses.count;
    //both phones and emails
    if(numberOfSections == 2)
    {
        //phones are section 0
        if (section ==1)
        {
            return @"Email Addresses";
        }
        else
        {
            return @"Phone Numbers";
        }
    }
    //Only 1 section so either emails or phones
    else if(_privProfile.emailAddresses.count)
    {
        return @"Email Addresses";
    }
    else
    {
        return @"Phone Numbers";
    }
    
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath {
    ContactCardTableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:@"contactCell" forIndexPath:indexPath];
    // Configure the cell...
    cell.separatorInset = UIEdgeInsetsZero;
    cell.userInteractionEnabled = NO;
    int numberOfSections = !!_privProfile.phoneNumbers.count + !!_privProfile.emailAddresses.count;
    
    //go through the sections and the rows to show the right data
    if(numberOfSections == 2)
    {
        //email addresses
        if(indexPath.section == 1)
        {
            cell.typeLabel.text = ((Email*)_privProfile.emailAddresses[indexPath.row]).type;
            cell.valueLabel.text = ((Email*)_privProfile.emailAddresses[indexPath.row]).address;
        }
        //phone numbers
        else
        {
            cell.typeLabel.text = ((Phone*)_privProfile.phoneNumbers[indexPath.row]).type;
            cell.valueLabel.text = ((Phone*)_privProfile.phoneNumbers[indexPath.row]).number;
        }
    }
    //emails
    else if (_privProfile.emailAddresses.count)
    {
        cell.typeLabel.text = ((Email*)_privProfile.emailAddresses[indexPath.row]).type;
        cell.valueLabel.text = ((Email*)_privProfile.emailAddresses[indexPath.row]).address;
    }
    //phone numbers
    else
    {
        cell.typeLabel.text = ((Phone*)_privProfile.phoneNumbers[indexPath.row]).type;
        cell.valueLabel.text = ((Phone*)_privProfile.phoneNumbers[indexPath.row]).number;
    }
    
    return cell;
}


-(void)tableView:(UITableView *)tableView willDisplayCell:(UITableViewCell *)cell forRowAtIndexPath:(NSIndexPath *)indexPath
{
    // Remove seperator inset
    if ([cell respondsToSelector:@selector(setSeparatorInset:)]) {
        [cell setSeparatorInset:UIEdgeInsetsZero];
    }
    
    // Prevent the cell from inheriting the Table View's margin settings
    if ([cell respondsToSelector:@selector(setPreservesSuperviewLayoutMargins:)]) {
        [cell setPreservesSuperviewLayoutMargins:NO];
    }
    
    // Explictly set your cell's layout margins
    if ([cell respondsToSelector:@selector(setLayoutMargins:)]) {
        [cell setLayoutMargins:UIEdgeInsetsZero];
    }
}

- (CGFloat)tableView:(UITableView *)tableView heightForHeaderInSection:(NSInteger)section {
    if(!section)
        return 30;
    else
        return 20.0f;
}

//helper to get address book permissions
-(void) askForPermissions
{
    [_saveButton setEnabled: NO];
    [_activityIndicator startAnimating];
    //Only call get authorizations status once per click
    ABAuthorizationStatus status = ABAddressBookGetAuthorizationStatus();
    //Authorized
    if (status == kABAuthorizationStatusAuthorized){
        //Make this on main queue otherwise a random queue is chosen and can take a while for any feedback
        dispatch_async(dispatch_get_main_queue(), ^{
            _addressBook = ABAddressBookCreateWithOptions(NULL, nil);
            
            [self saveContactInfo];
            NSLog(@"Authorized");
        });
    }
    //not authorized so try to ask for permissions again
    else
    {
        ABAddressBookRequestAccessWithCompletion(_addressBook = ABAddressBookCreateWithOptions(NULL, nil), ^(bool granted, CFErrorRef error)
                                                 {
                                                     //Make this on main queue otherwise a random queue is chosen and can take a while for any feedback
                                                     dispatch_async(dispatch_get_main_queue(), ^{
                                                         //Not granted or an error occurred.
                                                         if (!granted || error)
                                                         {
                                                             UIAlertAction *newOkAction = [UIAlertAction
                                                                                           actionWithTitle:NSLocalizedString(@"Ok", @"Ok action")
                                                                                           style:UIAlertActionStyleDefault
                                                                                           handler:^(UIAlertAction *action)
                                                                                           {
                                                                                               NSLog(@"Ok action");
                                                                                               [_saveButton setEnabled: YES];
                                                                                               [_activityIndicator stopAnimating];                       [contactTableView reloadData];
                                                                                               return;
                                                                                           }];
                                                             
                                                             UIAlertController *alertController = [UIAlertController
                                                                                                   alertControllerWithTitle:@"Can't Add Contact"
                                                                                                   message:@"Cannot add the contact because the application is denied permissions.  Please go to Settings->WhoYu->Contacts to enable access, then try again."
                                                                                                   preferredStyle:UIAlertControllerStyleAlert];
                                                             [alertController addAction:newOkAction];
                                                             [self presentViewController:alertController animated:YES completion:nil];
                                                             NSLog(@"Not authorized granted = %c, error = %@", granted, error);
                                                             return;
                                                         }
                                                         
                                                         //granted permissions
                                                         [self saveContactInfo];
                                                         NSLog(@"Authorized");
                                                     });
                                                 });
        
    }
}

-(void) saveContactInfo
{
    
    
    //alert to get name to save contact as
    UIAlertController *alertController = [UIAlertController
                                          alertControllerWithTitle:@"Name For Contact"
                                          message:@"Enter the name you wish to save the contact as."
                                          preferredStyle:UIAlertControllerStyleAlert];
    
    [alertController addTextFieldWithConfigurationHandler:^(UITextField *textField)
     {
         [[NSNotificationCenter defaultCenter] addObserver:self
                                                  selector:@selector(alertTextFieldDidChange:)
                                                      name:UITextFieldTextDidChangeNotification
                                                    object:textField];
         
         
         
         textField.text = _contactName;
     }];
    UIAlertAction *okAction = [UIAlertAction
                               actionWithTitle:NSLocalizedString(@"OK", @"OK action")
                               style:UIAlertActionStyleDefault
                               handler:^(UIAlertAction *action)
                               {
                                   
                                   [[NSNotificationCenter defaultCenter] removeObserver:self
                                                                                   name:UITextFieldTextDidChangeNotification
                                                                                 object:nil];
                                   
                                   _contactName = ((UITextField*)alertController.textFields.firstObject).text;
                                   
                                   //set values for the new contact
                                   ABRecordRef newContact = ABPersonCreate();
                                   ABRecordSetValue(newContact, kABPersonFirstNameProperty, (__bridge CFStringRef)_contactName, nil);
                                   
                                   ABMutableMultiValueRef phoneNumbers = ABMultiValueCreateMutable(kABMultiStringPropertyType);
                                   ABMutableMultiValueRef emailAddresses = ABMultiValueCreateMutable(kABMultiStringPropertyType);
                                   
                                   //for each phone type add the number
                                   for(Phone* phone in _privProfile.phoneNumbers)
                                   {
                                       //need to extract digits
                                       NSString* number = [NSString stringWithFormat:@"1%@",[[phone.number componentsSeparatedByCharactersInSet:
                                                            [[NSCharacterSet decimalDigitCharacterSet] invertedSet]]
                                                           componentsJoinedByString:@""]];
                                       
                                        //mobile
                                       if([phone.type isEqualToString:@"Mobile Phone"])
                                           ABMultiValueAddValueAndLabel(phoneNumbers, (__bridge CFStringRef)number, kABPersonPhoneMobileLabel, NULL);
                                       //work
                                       else if([phone.type isEqualToString:@"Work Phone"])
                                           ABMultiValueAddValueAndLabel(phoneNumbers, (__bridge CFStringRef)number, kABWorkLabel, NULL);
                                       //home
                                       else
                                           ABMultiValueAddValueAndLabel(phoneNumbers, (__bridge CFStringRef)number, kABHomeLabel, NULL);
                                   }
                                   
                                   //for each email add the email
                                   for(Email* email in _privProfile.emailAddresses)
                                   {
                                       //personal email
                                       if([email.type isEqualToString:@"Personal Email"])
                                           ABMultiValueAddValueAndLabel(emailAddresses, (__bridge CFStringRef)email.address, kABHomeLabel, NULL);
                                       //work email
                                       else
                                       {
                                           ABMultiValueAddValueAndLabel(emailAddresses, (__bridge CFStringRef)email.address, kABWorkLabel, NULL);
                                       }
                                   }
                                   
                                   //if there are emails or phone numbers add them to contacts
                                   if(ABMultiValueGetCount(phoneNumbers))
                                       ABRecordSetValue(newContact, kABPersonPhoneProperty, phoneNumbers, nil);
                                   if(ABMultiValueGetCount(emailAddresses))
                                       ABRecordSetValue(newContact, kABPersonEmailProperty, emailAddresses, nil);
                                   
                                   //set picture
                                   ABPersonSetImageData(newContact, (__bridge CFDataRef)_profile.picture_data, nil);
                                   
                                   //save
                                   ABAddressBookAddRecord(_addressBook, newContact, nil);
                                   ABAddressBookSave(_addressBook, nil);
                                   
                                   UIAlertAction *newOkAction = [UIAlertAction
                                                                 actionWithTitle:NSLocalizedString(@"Ok", @"Ok action")
                                                                 style:UIAlertActionStyleDefault
                                                                 handler:^(UIAlertAction *action)
                                                                 {
                                                                     NSLog(@"Ok action");
                                                                     [_saveButton setEnabled: YES];
                                                                     [_activityIndicator stopAnimating];
                                                                     [self backSegue];
                                                                     return;
                                                                 }];
                                   
                                   UIAlertController *alertController = [UIAlertController
                                                                         alertControllerWithTitle:@"Added Contact"
                                                                         message:[NSString stringWithFormat:@"%@ was added successfully!", _contactName]
                                                                         preferredStyle:UIAlertControllerStyleAlert];
                                   [alertController addAction:newOkAction];
                                   [self presentViewController:alertController animated:YES completion:nil];
                               }];
    
    UIAlertAction *cancelAction = [UIAlertAction
                                   actionWithTitle:NSLocalizedString(@"Cancel", @"Cancel action")
                                   style:UIAlertActionStyleCancel
                                   handler:^(UIAlertAction *action)
                                   {
                                       [[NSNotificationCenter defaultCenter] removeObserver:self
                                                                                       name:UITextFieldTextDidChangeNotification
                                                                                     object:nil];
                                       
                                       _contactName = ((UITextField*)alertController.textFields.firstObject).text;
                                       NSLog(@"Cancel action");
                                       [_saveButton setEnabled: YES];
                                       [_activityIndicator stopAnimating];
                                       [contactTableView reloadData];
                                       return;
                                   }];
    
    [alertController addAction:cancelAction];
    [alertController addAction:okAction];
    [self presentViewController:alertController animated:YES completion:nil];
    
}

//enabling or disabling ok button
- (void)alertTextFieldDidChange:(NSNotification *)notification
{
    UIAlertController *alertController = (UIAlertController *)self.presentedViewController;
    if (alertController)
    {
        _contactName = ((UITextField*)alertController.textFields.firstObject).text;
        UIAlertAction *okAction = alertController.actions.lastObject;
        okAction.enabled = !!_contactName.length;
    }
}

- (IBAction)saveAction:(id)sender {
    //save contacts
    [self askForPermissions];

}

- (void) backSegue
{
    if(self.navigationController.viewControllers.count > 1)
    {
        NSLog(@"Count is %d", (int) self.navigationController.viewControllers.count);
        [self.navigationController popViewControllerAnimated:YES];
    }
    else
        [self performSegueWithIdentifier:@"viewProfileSegue" sender:self];
}

- (IBAction)backAction:(id)sender {
    [self backSegue];
}

// In a storyboard-based application, you will often want to do a little preparation before navigation
- (void)prepareForSegue:(UIStoryboardSegue *)segue sender:(id)sender
{
    if([segue.identifier isEqualToString:@"viewProfileSegue"])
    {
        UINavigationController *navController = segue.destinationViewController;
        ViewProfileViewController* controller = [navController childViewControllers].firstObject;
        controller.profile = _profile;
    }

}

- (IBAction)deleteAction:(id)sender {
    
    //letting the user know
    UIAlertAction *deleteAction = [UIAlertAction
                                 actionWithTitle:NSLocalizedString(@"Delete", @"Send action")
                                 style:UIAlertActionStyleDestructive
                                 handler:^(UIAlertAction *action)
                                 {
                                     __block bool inQueue = YES;
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
                                         inQueue = NO;
                                     }];
                                     while(inQueue);
                                     [self performSegueWithIdentifier:@"viewAllContacts" sender:self];
                                  }];
    UIAlertAction *cancelAction = [UIAlertAction
                                   actionWithTitle:NSLocalizedString(@"Cancel", @"Cancel action")
                                   style:UIAlertActionStyleCancel
                                   handler:^(UIAlertAction *action)
                                   {
                                       return;
                                   }];
    
    UIAlertController *alertController = [UIAlertController
                                          alertControllerWithTitle:@"Delete Contact Card"
                                          message:@"This is a permenent action, and the contact card will be removed."
                                          preferredStyle:UIAlertControllerStyleAlert];
    
    [alertController addAction:cancelAction];
    [alertController addAction:deleteAction];
    [self presentViewController:alertController animated:YES completion:nil];
    return;

    
}
@end
