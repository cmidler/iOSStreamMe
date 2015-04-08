//
//  ContactInfoTableViewController.m
//  WhoYu
//
//  Created by Chase Midler on 1/30/15.
//  Copyright (c) 2015 midler. All rights reserved.
//

#import "ContactInfoTableViewController.h"

@interface ContactInfoTableViewController ()

@end

@implementation ContactInfoTableViewController
@synthesize contactTableView;
- (void)viewDidLoad {
    [super viewDidLoad];
    self.tableView.tableFooterView = [[UIView alloc] initWithFrame:CGRectZero];
    _contactName = _profile.first_name;
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
    
}


- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView {
    // Return the number of sections.
    int numberOfSections = !!_privProfile.phoneNumbers.count + !!_privProfile.emailAddresses.count+1;
    return numberOfSections;
}

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section {
    // Return the number of rows in the section.
    int numberOfSections = !!_privProfile.phoneNumbers.count + !!_privProfile.emailAddresses.count+1;
    
    //both phones and emails
    if(numberOfSections == 3)
    {
        //phones are section 0
        if(section ==2)
            return 1;
        else if(section==1)
        {
            return _privProfile.emailAddresses.count;
        }
        else
        {
            return _privProfile.phoneNumbers.count;
        }
    }
    //Only 2 section so either emails or phones
    else if(_privProfile.emailAddresses.count)
    {
        //save contact section
        if(section)
            return 1;
        else
            return _privProfile.emailAddresses.count;
    }
    else
    {
        //save contact section
        if(section)
            return 1;
        else
            return _privProfile.phoneNumbers.count;
    }
}

//Get the title for each section
- (NSString *)tableView:(UITableView *)tableView titleForHeaderInSection:(NSInteger)section
{
    int numberOfSections = !!_privProfile.phoneNumbers.count + !!_privProfile.emailAddresses.count+1;
    //both phones and emails
    if(numberOfSections == 3)
    {
        //phones are section 0
        if(section==2)
        {
            return @"Save Contact";
        }
        else if (section ==1)
        {
            return @"Email Addresses";
        }
        else
        {
            return @"Phone Numbers";
        }
    }
    //Only 2 section so either emails or phones
    else if(_privProfile.emailAddresses.count)
    {
        if(section)
            return @"Save Contact";
        else
            return @"Email Addresses";
    }
    else
    {
        if(section)
            return @"Save Contact";
        else
            return @"Phone Numbers";
    }
    
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath {
    ContactInfoTableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:@"contactCell" forIndexPath:indexPath];
    // Configure the cell...
    cell.separatorInset = UIEdgeInsetsZero;
    cell.typeLabel.hidden = YES;
    cell.valueLabel.hidden = YES;
    cell.saveContactLabel.hidden = YES;
    cell.userInteractionEnabled = NO;
    
    int numberOfSections = !!_privProfile.phoneNumbers.count + !!_privProfile.emailAddresses.count+1;
    
    //go through the sections and the rows to show the right data
    if(numberOfSections == 3)
    {
        if(indexPath.section == 2)
        {
            cell.userInteractionEnabled = YES;
            cell.saveContactLabel.hidden = NO;
        }
        //email addresses
        else if(indexPath.section == 1)
        {
            cell.typeLabel.hidden = NO;
            cell.valueLabel.hidden = NO;
            cell.typeLabel.text = ((Email*)_privProfile.emailAddresses[indexPath.row]).type;
            cell.valueLabel.text = ((Email*)_privProfile.emailAddresses[indexPath.row]).address;
        }
        //phone numbers
        else
        {
            cell.typeLabel.hidden = NO;
            cell.valueLabel.hidden = NO;
            cell.typeLabel.text = ((Phone*)_privProfile.phoneNumbers[indexPath.row]).type;
            cell.valueLabel.text = ((Phone*)_privProfile.phoneNumbers[indexPath.row]).number;
        }
    }
    //emails
    else if (_privProfile.emailAddresses.count)
    {
        if(indexPath.section)
        {
            cell.userInteractionEnabled = YES;
            cell.saveContactLabel.hidden = NO;
        }
        else
        {
            cell.typeLabel.hidden = NO;
            cell.valueLabel.hidden = NO;
            cell.typeLabel.text = ((Email*)_privProfile.emailAddresses[indexPath.row]).type;
            cell.valueLabel.text = ((Email*)_privProfile.emailAddresses[indexPath.row]).address;
        }
    }
    //phone numbers
    else
    {
        if(indexPath.section)
        {
            cell.userInteractionEnabled = YES;
            cell.saveContactLabel.hidden = NO;
        }
        else
        {
            cell.typeLabel.hidden = NO;
            cell.valueLabel.hidden = NO;
            cell.typeLabel.text = ((Phone*)_privProfile.phoneNumbers[indexPath.row]).type;
            cell.valueLabel.text = ((Phone*)_privProfile.phoneNumbers[indexPath.row]).number;
        }
    }

    
    return cell;
}


- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath
{
    //only cell that can be selected is the save contacts
    [self askForPermissions];
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
                                                       [contactTableView reloadData];
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
                                      NSString* number = [[phone.number componentsSeparatedByCharactersInSet:
                                                           [[NSCharacterSet decimalDigitCharacterSet] invertedSet]]
                                                          componentsJoinedByString:@""];
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
                                                                    [self.navigationController popViewControllerAnimated:YES];
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
@end
