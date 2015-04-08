//
//  emailTableViewController.m
//  WhoYu
//
//  Created by Chase Midler on 1/28/15.
//  Copyright (c) 2015 midler. All rights reserved.
//

#import "EmailAddressesTableViewController.h"

@interface EmailAddressesTableViewController ()

@end

@implementation EmailAddressesTableViewController
@synthesize emailTableView;
- (void)viewDidLoad {
    [super viewDidLoad];
    
    // This will remove extra separators from tableview
    self.tableView.tableFooterView = [[UIView alloc] initWithFrame:CGRectZero];
    
    UITapGestureRecognizer *tap = [[UITapGestureRecognizer alloc]
                                   initWithTarget:self
                                   action:@selector(dismissKeyboard)];
    tap.cancelsTouchesInView = NO;
    [self.view addGestureRecognizer:tap];
    
    
    
    _isShowingBadCells = NO;
    _pickerViewShown = NO;
    _pickerSelection = @"";
    _toolBar.hidden = YES;
    _toolBar = nil;
    _numberOfCells = 0;
    
    emailAddresses = [[NSMutableArray alloc] init];
    emailAddressesStrings = [[NSMutableArray alloc] init];
    badCells = [[NSMutableArray alloc]init];
    pickerOptions = @[@"Personal Email", @"Work Email"];
    [self setupEmailAddresses];
}

//Helper function to populate the email numbers array
-(void) setupEmailAddresses
{
    StorePrivateProfile* spp = [StorePrivateProfile shared];
    PrivateProfile* profile = spp.profile;
    NSLog(@"profile addresses is %@", spp.profile.emailAddresses);
    
    //initialize emailAddresses array
    for(Email* email in profile.emailAddresses)
    {
        [emailAddressesStrings addObject:email.address];
        Email* e = [[Email alloc] init];
        e.type = email.type;
        e.address = email.address;
        e.email_id = email.email_id;
        [emailAddresses addObject:e];
    }
    
    if(emailAddresses.count == MAX_EMAIL_ADDRESSES)
        _addRowShowing = NO;
    else
        _addRowShowing = YES;
    
    [emailTableView reloadData];
}


//helper to occur when the add email cell is clicked
-(void) addEmail
{
    //adding a default email
    Email* email = [[Email alloc] init];
    email.type = @"Personal Email";
    email.address = @"example@whoYu.net";
    email.email_id = @"-1";//make it -1 so I know it isn't a real id
    
    [emailAddresses addObject:email];
    [emailAddressesStrings addObject:email.address];
    if(emailAddresses.count == MAX_EMAIL_ADDRESSES)
        _addRowShowing = NO;
    else
        _addRowShowing = YES;
    
}

- (void) dismissKeyboard
{
    [self.emailTableView endEditing:YES];
}

//Delegates for helping textview have placeholder text
- (void)textViewDidBeginEditing:(UITextView *)textView
{
    if([textView.text isEqualToString:@"example@whoYu.net"])
    {
        textView.text = @"";
        [emailAddressesStrings setObject:textView.text atIndexedSubscript:textView.tag];
    }
    
    [textView becomeFirstResponder];
}

-(void)textViewDidChange:(UITextView *)textView
{
    NSLog(@"tag for text did change is %d and text is %@", (int)textView.tag, textView.text);
    [emailAddressesStrings setObject:textView.text atIndexedSubscript:textView.tag];
}

//used for updating email address.  Don't do any email validation check here
- (BOOL)textView:(UITextView *)textView
shouldChangeTextInRange:(NSRange)range
 replacementText:(NSString *)text
{
    
    //check if they user is trying to enter too many characters
    if(([[textView text] length] - range.length + text.length > MAX_EMAIL_CHARS) && ![text isEqualToString:@"\n"])
    {
        return NO;
    }
    
    //Make return key try to save the new status
    if([text isEqualToString:@"\n"])
    {
        [textView resignFirstResponder];
    }
    return YES;
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}


- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView {
    // Return the number of sections.
    return 1;
}

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section {
    int additionalRows = _pickerViewShown + _addRowShowing;
    _numberOfCells = (int)emailAddresses.count + additionalRows;
    return _numberOfCells;
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath {
    EmailAddressesTableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:@"emailCell" forIndexPath:indexPath];
    cell.separatorInset = UIEdgeInsetsZero;
    [cell.activityIndicator stopAnimating];
    cell.activityIndicator.center = cell.center;
    //get section 0 row 0
    if(!indexPath.section && !indexPath.row)
        _firstCell = cell;
    
    
    cell.emailAddressTextView.hidden = YES;
    cell.emailTypeLabel.hidden = YES;
    cell.dropDownImageView.hidden = YES;
    cell.pickerView.hidden = YES;
    cell.addAnotherEmailButton.hidden = YES;
    cell.addAnotherEmailButton.userInteractionEnabled = NO;
    //give addanother email button dashed line border
    [self drawDashedBorderAroundView:cell.addAnotherEmailButton];
    cell.borderLabel.hidden = YES;
    cell.emailAddressTextView.layer.borderWidth = 1.0;
    cell.emailAddressTextView.layer.borderColor = [[UIColor clearColor] CGColor];
    NSLog(@"is showing bad cells is %d", _isShowingBadCells);
    
    //Easy display setting.  No picker view or there is one, but the rows are before it
    if(!_pickerViewShown || (indexPath.row<_pickerViewShownIndex))
    {
        //check if the row is less than the emailAddresses.count
        if(indexPath.row < emailAddresses.count)
        {
            cell.tag = NORMAL_CELL;
            cell.emailAddressTextView.tag = indexPath.row;
            cell.emailAddressTextView.hidden = NO;
            cell.emailTypeLabel.hidden = NO;
            //unhide the drop down image if the picker view is not the next cell
            if(!_pickerViewShown || (_pickerViewShownIndex != (indexPath.row+1)))
                cell.dropDownImageView.hidden = NO;
            cell.borderLabel.hidden = NO;
            cell.emailTypeLabel.text = ((Email*)emailAddresses[indexPath.row]).type;
            cell.emailAddressTextView.text = emailAddressesStrings[indexPath.row];
            if(_isShowingBadCells)
            {
                for(NSNumber* bad in badCells)
                {
                    NSLog(@"bad is %d and indexpath.row is %d", bad.intValue, (int) indexPath.row);
                    if(bad.intValue == indexPath.row)
                    {
                        cell.emailAddressTextView.layer.borderColor = [[UIColor redColor] CGColor];
                        break;
                    }
                }
            }
            
        }
        //we are on the add more rows
        else
        {
            cell.tag = ADD_CELL;
            cell.addAnotherEmailButton.hidden = NO;
        }
    }
    //picker row
    else if ( indexPath.row == _pickerViewShownIndex)
    {
        _toolBar.hidden = YES;
        _toolBar = nil;
        cell.pickerView.hidden = NO;
        cell.tag = PICKER_CELL;
        // add a toolbar with Cancel & Done button
        _toolBar = [[UIToolbar alloc] initWithFrame:CGRectMake(0, 0, 320, ROW_HEIGHT)];
        
        UIBarButtonItem *doneButton = [[UIBarButtonItem alloc] initWithBarButtonSystemItem:UIBarButtonSystemItemDone target:self action:@selector(doneTouched:)];
        UIBarButtonItem *cancelButton = [[UIBarButtonItem alloc] initWithBarButtonSystemItem:UIBarButtonSystemItemCancel target:self action:@selector(cancelTouched:)];
        
        // the middle button is to make the Done button align to right
        [_toolBar setItems:[NSArray arrayWithObjects:cancelButton, [[UIBarButtonItem alloc] initWithBarButtonSystemItem:UIBarButtonSystemItemFlexibleSpace target:nil action:nil], doneButton, nil]];
        [_toolBar removeFromSuperview];
        [cell.pickerView selectRow:0 inComponent:0 animated:NO];
        [cell addSubview:_toolBar];
    }
    //rows higher than picker view
    else
    {
        //check if it is a normal cell or an add row cell
        if(indexPath.row > emailAddresses.count) //(number of emails+pickerview)
        {
            cell.tag = ADD_CELL;
            cell.addAnotherEmailButton.hidden = NO;
        }
        else
        {
            cell.tag = NORMAL_CELL;
            int offsetIndex = (int)indexPath.row-1;
            cell.emailAddressTextView.tag = offsetIndex;
            cell.emailAddressTextView.hidden = NO;
            cell.emailTypeLabel.hidden = NO;
            cell.dropDownImageView.hidden = NO;
            cell.borderLabel.hidden = NO;
            cell.emailTypeLabel.text = ((Email*)emailAddresses[offsetIndex]).type;
            cell.emailAddressTextView.text = emailAddressesStrings[offsetIndex];
            if(_isShowingBadCells)
            {
                for(NSNumber* bad in badCells)
                {
                    if(bad.intValue == offsetIndex)
                    {
                        cell.emailAddressTextView.layer.borderColor = [[UIColor redColor] CGColor];
                        break;
                    }
                }
            }
        }
    }
    
    NSLog(@"cell.tag is %d", (int)cell.tag);
    //check if we are at the last cell and if bad cells are showing
    if(_isShowingBadCells && (indexPath.row == (_numberOfCells-1)))
    {
        NSLog(@"indexpath is %d and turning off showing bad cells", (int)indexPath.row);
        _isShowingBadCells = NO;
    }
    return cell;
}

//On click of cell, what happens
//On click of cell, segue or drop down
- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath
{
    UITableViewCell *cell = [tableView cellForRowAtIndexPath:indexPath];
    [cell setSelectionStyle:UITableViewCellSelectionStyleDefault];
    NSLog(@"cell.tag = %d",(int)cell.tag);
    //based on the cell tag, different actions happen when the cell is clicked
    switch (cell.tag) {
        case NORMAL_CELL:
            //need to find out which cell it currently is at
            if(_pickerViewShown && _pickerViewShownIndex < indexPath.row)
            {
                _pickerViewShownIndex = (int) indexPath.row;
            }
            //if we are below the picker cell or it is not shown then we are normal
            else
                _pickerViewShownIndex = (int)indexPath.row+1;
            
            //need to how the picker view
            _pickerViewShown = YES;
            break;
        case ADD_CELL:
            //want to add a new email address to the email addresses array
            [self addEmail];
            break;
        case PICKER_CELL:
            _pickerViewShown = YES;
            break;
        default:
            break;
    }
    
    //reload the table
    [emailTableView reloadData];
}

//don't allow editing of pickerview cell or add cell
- (BOOL)tableView:(UITableView *)tableView canEditRowAtIndexPath:(NSIndexPath *)indexPath
{
    //on pickerview row
    if(_pickerViewShown && _pickerViewShownIndex == indexPath.row)
        return NO;
    //this will be a normal row (can't be picker row since we check above for that and can't be add row since add row needs to be the last row)
    else if(_pickerViewShown && indexPath.row==emailAddresses.count)
        return YES;
    else if(indexPath.row >= emailAddresses.count)
        return NO;
    else
        return YES;
}

/*  Override to support editing the table view.
 If right swipe, delete
 */
- (void)tableView:(UITableView *)tableView commitEditingStyle:(UITableViewCellEditingStyle)editingStyle forRowAtIndexPath:(NSIndexPath *)indexPath {
    
    //if we swiped to delete
    if (editingStyle == UITableViewCellEditingStyleDelete) {
        
        UIAlertController *alertController = [UIAlertController
                                              alertControllerWithTitle:@"Warning"
                                              message:@"Are you sure?"
                                              preferredStyle:UIAlertControllerStyleAlert];
        
        UIAlertAction *cancelAction = [UIAlertAction
                                       actionWithTitle:NSLocalizedString(@"Cancel", @"Cancel action")
                                       style:UIAlertActionStyleCancel
                                       handler:^(UIAlertAction *action)
                                       {
                                           NSLog(@"Cancel action");
                                           return;
                                       }];
        
        //We do want to delete the row
        UIAlertAction *deleteAction = [UIAlertAction
                                       actionWithTitle:NSLocalizedString(@"Delete", @"Delete action")
                                       style:UIAlertActionStyleDestructive
                                       handler:^(UIAlertAction *action)
        {
            NSLog(@"Delete Action");


            //getting the object to be deleted
            Email* email;
            int row = (int)indexPath.row;
            //will be indexpath row
            if(!_pickerViewShown || indexPath.row<_pickerViewShownIndex)
               email = emailAddresses[row];
            else
               email = emailAddresses[--row];

            //nothing saved so just remove the row and be done
            if([email.email_id isEqualToString:@"-1"])
            {
               [emailAddressesStrings removeObjectAtIndex:row];
               [emailAddresses removeObjectAtIndex:row];
               _addRowShowing = YES;
               if(_pickerViewShown && indexPath.row==_pickerViewShownIndex)
                   _pickerViewShown = NO;
               [emailTableView reloadData];
               return;
            }

            NSString* emailId = email.email_id;
            
            PFQuery* emailQuery = [PFQuery queryWithClassName:@"EmailAddress"];
            [emailQuery whereKey:@"objectId" equalTo:email.email_id];
            [emailQuery findObjectsInBackgroundWithBlock:^(NSArray *objects, NSError *error) {
               
               //error checking
               if(error)
               {
                   NSLog(@"error or no object");
                   NSLog(@"email id to delete was %@", email.email_id);
                   [emailTableView reloadData];
                   return;
               }
               
               //delete from parse
               for(PFObject* email in objects)
                   [email deleteEventually];
               
               //delete from storedprivateprofile as well
               StorePrivateProfile* ssp = [StorePrivateProfile shared];
               PrivateProfile* profile = ssp.profile;
               for(int i = 0; i <profile.emailAddresses.count; i++)
               {
                   Email* p = profile.emailAddresses[i];
                   if([p.email_id isEqualToString:email.email_id])
                   {
                       [profile.emailAddresses removeObjectAtIndex:i];
                       break;
                   }
               }
               [ssp setProfile:profile];
               
               
               //remove the email from helper arrays as well
               [emailAddressesStrings removeObjectAtIndex:row];
               [emailAddresses removeObjectAtIndex:row];
               _addRowShowing = YES;
               if(_pickerViewShown && indexPath.row==_pickerViewShownIndex)
                   _pickerViewShown = NO;
               //get the main database
               MainDatabase* md = [MainDatabase shared];
               [md.queue inDatabase:^(FMDatabase *db) {
                   NSString *deleteSQL = @"DELETE FROM email WHERE email_id = ?";
                   NSArray* values = @[emailId];
                   [db executeUpdate:deleteSQL withArgumentsInArray:values];
                   [emailTableView reloadData];
               }];
            }];
            
        }];
        [alertController addAction:deleteAction];
        [alertController addAction:cancelAction];
        [self presentViewController:alertController animated:YES completion:nil];
    }
}


// Catpure the picker view selection
- (void)pickerView:(UIPickerView *)pickerView didSelectRow:(NSInteger)row inComponent:(NSInteger)component
{
    NSLog(@"Got component");
    _pickerSelection = pickerOptions[row];
}

// The number of columns of data
- (NSInteger)numberOfComponentsInPickerView:(UIPickerView *)pickerView
{
    return 1;
}

// The number of rows of data
- (NSInteger)pickerView:(UIPickerView *)pickerView numberOfRowsInComponent:(NSInteger)component
{
    NSLog(@"options count is %d", (int)pickerOptions.count);
    return pickerOptions.count;
}

// The data to return for the row and component (column) that's being passed in
- (NSString*)pickerView:(UIPickerView *)pickerView titleForRow:(NSInteger)row forComponent:(NSInteger)component
{
    NSLog(@"the option for picker view is %@", pickerOptions[row]);
    return pickerOptions[row];
}


- (CGFloat)tableView:(UITableView*)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath
{
    //if no picker view shown, make the table height be the default height
    if(!_pickerViewShown)
    {
        return ROW_HEIGHT;
    }
    
    //picker view is shown  it means we have to see if the row is the picker view or not
    if(indexPath.row == _pickerViewShownIndex)
    {
        return PICKER_HEIGHT;
    }
    else
        return ROW_HEIGHT;
    
}

- (CGFloat)tableView:(UITableView *)tableView heightForHeaderInSection:(NSInteger)section {
    return 0.1f;
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

//handle cancel button touched in pickerView
- (void)cancelTouched:(UIBarButtonItem *)sender
{
    NSLog(@"Cancel button touched");
    [self.emailTableView resignFirstResponder];
    _pickerViewShown = NO;
    _toolBar.hidden = YES;
    _toolBar = nil;
    _pickerSelection = @"";
    [emailTableView reloadData];
}

//handle done button touched in pickerview
- (void)doneTouched:(UIBarButtonItem *)sender
{
    NSLog(@"Done Button touched");
    [self.emailTableView resignFirstResponder];
    _pickerViewShown = NO;
    _toolBar.hidden = YES;
    _toolBar = nil;
    
    if(!_pickerSelection || !_pickerSelection.length)
    {
        _pickerSelection = pickerOptions[0];
    }
    
    //need to set the correct type for the email
    Email* email = ((Email*)emailAddresses[_pickerViewShownIndex-1]);
    email.type = _pickerSelection;
    
    [emailAddresses setObject:email atIndexedSubscript:_pickerViewShownIndex-1];
    _pickerSelection = @"";
    
    [emailTableView reloadData];
}


- (void)drawDashedBorderAroundView:(UIView *)v
{
    //border definitions
    CGFloat cornerRadius = 10;
    CGFloat borderWidth = 2;
    NSInteger dashPattern1 = 8;
    NSInteger dashPattern2 = 8;
    UIColor *lineColor = [UIColor grayColor];
    
    //drawing
    CGRect frame = v.bounds;
    
    CAShapeLayer *_shapeLayer = [CAShapeLayer layer];
    
    //creating a path
    CGMutablePathRef path = CGPathCreateMutable();
    
    //drawing a border around a view
    CGPathMoveToPoint(path, NULL, 0, frame.size.height - cornerRadius);
    CGPathAddLineToPoint(path, NULL, 0, cornerRadius);
    CGPathAddArc(path, NULL, cornerRadius, cornerRadius, cornerRadius, M_PI, -M_PI_2, NO);
    CGPathAddLineToPoint(path, NULL, frame.size.width - cornerRadius, 0);
    CGPathAddArc(path, NULL, frame.size.width - cornerRadius, cornerRadius, cornerRadius, -M_PI_2, 0, NO);
    CGPathAddLineToPoint(path, NULL, frame.size.width, frame.size.height - cornerRadius);
    CGPathAddArc(path, NULL, frame.size.width - cornerRadius, frame.size.height - cornerRadius, cornerRadius, 0, M_PI_2, NO);
    CGPathAddLineToPoint(path, NULL, cornerRadius, frame.size.height);
    CGPathAddArc(path, NULL, cornerRadius, frame.size.height - cornerRadius, cornerRadius, M_PI_2, M_PI, NO);
    
    //path is set as the _shapeLayer object's path
    _shapeLayer.path = path;
    CGPathRelease(path);
    
    _shapeLayer.backgroundColor = [[UIColor clearColor] CGColor];
    _shapeLayer.frame = frame;
    _shapeLayer.masksToBounds = NO;
    [_shapeLayer setValue:[NSNumber numberWithBool:NO] forKey:@"isCircle"];
    _shapeLayer.fillColor = [[UIColor clearColor] CGColor];
    _shapeLayer.strokeColor = [lineColor CGColor];
    _shapeLayer.lineWidth = borderWidth;
    _shapeLayer.lineDashPattern = [NSArray arrayWithObjects:[NSNumber numberWithInteger:dashPattern1], [NSNumber numberWithInteger:dashPattern2], nil];
    _shapeLayer.lineCap = kCALineCapRound;
    
    //_shapeLayer is added as a sublayer of the view, the border is visible
    [_shapeLayer removeFromSuperlayer];
    [v.layer addSublayer:_shapeLayer];
    v.layer.cornerRadius = cornerRadius;
}

//helper function to create emails for the backend
- (void) saveEmails:(NSArray*) emails
{
    [PFObject saveAllInBackground:emails block:^(BOOL succeeded, NSError *error) {
        
        //report error
        if(error || !succeeded)
        {
            //setting up the ok action if it is needed
            UIAlertAction *okAction = [UIAlertAction
                                       actionWithTitle:NSLocalizedString(@"Ok", @"Ok action")
                                       style:UIAlertActionStyleDefault
                                       handler:^(UIAlertAction *action)
                                       {
                                           NSLog(@"Ok action");
                                           _saveButton.enabled = YES;
                                           [_firstCell.activityIndicator stopAnimating];
                                           return;
                                       }];
            
            UIAlertController *alertController = [UIAlertController
                                                  alertControllerWithTitle:@"Can't Save"
                                                  message:@"Could not save at this time.  Check your internet connection and try again.  If this problem persists, please inform whoYu."
                                                  preferredStyle:UIAlertControllerStyleAlert];
            [alertController addAction:okAction];
            [self presentViewController:alertController animated:YES completion:nil];
            return;
        }
        
        //get the main database
        MainDatabase* md = [MainDatabase shared];
        [md.queue inDatabase:^(FMDatabase *db) {
            //add to local database as well
            for(PFObject* email in emails)
            {
                //did it now try to save the data
                NSString *insertSQL = @"INSERT INTO email (type, address, user_id, email_id) VALUES (?, ?, ?, ?)";
                NSArray* values = @[email[@"type"], email[@"address"], [PFUser currentUser].objectId, email.objectId];
                [db executeUpdate:insertSQL withArgumentsInArray:values];
                
                //loop through email addresses to update stored profile
                for(int i = 0; i <emailAddresses.count; i++)
                {
                    Email* p = emailAddresses[i];
                    //find the email match to save the user id
                    if([email[@"type"] isEqualToString:p.type] && [email[@"address"] isEqualToString:p.address])
                    {
                        p.email_id = email.objectId;
                        [emailAddresses setObject:p atIndexedSubscript:i];
                        break;
                    }
                }
            }
            //now save the email addresses to the stored private profiles
            StorePrivateProfile* spp = [StorePrivateProfile shared];
            PrivateProfile* profile = spp.profile;
            profile.emailAddresses = emailAddresses;
            NSLog(@"profile email addresses is %@", profile.emailAddresses);
            [spp setProfile:profile];
            //yay, saved.  Show a screen saying so and segue
            UIAlertAction *okAction = [UIAlertAction
                                       actionWithTitle:NSLocalizedString(@"Ok", @"Ok action")
                                       style:UIAlertActionStyleDefault
                                       handler:^(UIAlertAction *action)
                                       {
                                           NSLog(@"Ok action");
                                           _saveButton.enabled = YES;
                                           [_firstCell.activityIndicator stopAnimating];
                                           if(self.navigationController.viewControllers.count >1)
                                               [self.navigationController popViewControllerAnimated:YES];
                                           else
                                               [self performSegueWithIdentifier:@"myProfileSegue" sender:self];
                                           return;
                                       }];
            
            UIAlertController *alertController = [UIAlertController
                                                  alertControllerWithTitle:@"Save Successful"
                                                  message:@"Save was successful.  Your email address data is private.  Nothing is shared unless you specifically send your contact information to another person."
                                                  preferredStyle:UIAlertControllerStyleAlert];
            [alertController addAction:okAction];
            [self presentViewController:alertController animated:YES completion:nil];
            return;

        }];
    }];
    
}


//need to do lots of checks to validate data saved
- (IBAction)saveAction:(id)sender {
    _saveButton.enabled = NO;
    [_firstCell.activityIndicator startAnimating];
    _pickerViewShown = NO;
    [badCells removeAllObjects];
    
    int i = -1;
    //need to verify email addresses
    for(NSString* address in emailAddressesStrings)
    {
        //increment i to get current index
        i++;
        
        //setup regex to make sure email address is properly formatted
        NSString *emailRegex = @"[a-zA-Z0-9!#$%&'*+/=?^_`{|}~-]+(?:.[a-zA-Z0-9!#$%&'*+/=?^_`{|}~-]+)*@(?:[a-zA-Z0-9](?:[a-zA-Z0-9-]*[a-z0-9])?.)+\\.[a-zA-Z0-9](?:[a-zA-Z0-9-]*[a-zA-Z0-9])?";
        NSError  *error = nil;
        NSRange   searchedRange = NSMakeRange(0, address.length);
        NSRegularExpression* regex = [NSRegularExpression regularExpressionWithPattern: emailRegex options:0 error:&error];
        
        NSArray* matches = [regex matchesInString:address options:0 range:searchedRange];
        
        //check if the email address matches the regex
        if(!matches.count)
        {
            [badCells addObject:[NSNumber numberWithInt:i]];
            continue;
        }
    }
    
    //also make sure we only have one personal and one work email
    bool hasPersonal = NO;
    bool hasWork = NO;
    bool hasDuplicate = NO;
    for(Email* email in emailAddresses)
    {
        NSString* type = email.type;
        //MOBILE
        if([type isEqualToString:@"Personal Email"])
        {
            if(hasPersonal)
                hasDuplicate = YES;
            else
                hasPersonal = YES;
        }
        //WORK
        else if([type isEqualToString:@"Work Email"])
        {
            if(hasWork)
                hasDuplicate = YES;
            else
                hasWork = YES;
        }
    }
    
    //show error alert
    if(hasDuplicate)
    {
        UIAlertController *alertController = [UIAlertController
                                              alertControllerWithTitle:@"Can't Save"
                                              message:@"You can only have one of each type of email."
                                              preferredStyle:UIAlertControllerStyleAlert];
        UIAlertAction *okAction = [UIAlertAction
                                   actionWithTitle:NSLocalizedString(@"Ok", @"Ok action")
                                   style:UIAlertActionStyleDefault
                                   handler:^(UIAlertAction *action)
                                   {
                                       NSLog(@"Ok action");
                                       _saveButton.enabled = YES;
                                       [_firstCell.activityIndicator stopAnimating];
                                       return;
                                   }];
        
        [alertController addAction:okAction];
        [self presentViewController:alertController animated:YES completion:nil];
        return;
        
    }
    
    //reloading the table
    [emailTableView reloadData];
    
    NSLog(@"bad cells is %@", badCells);
    
    //if badcells have a count then return
    if(badCells.count)
    {
        UIAlertController *alertController = [UIAlertController
                                              alertControllerWithTitle:@"Can't Save"
                                              message:@"Email address not valid."
                                              preferredStyle:UIAlertControllerStyleAlert];
        
        UIAlertAction *okAction = [UIAlertAction
                                   actionWithTitle:NSLocalizedString(@"Ok", @"Ok action")
                                   style:UIAlertActionStyleDefault
                                   handler:^(UIAlertAction *action)
                                   {
                                       NSLog(@"Ok action");
                                       _isShowingBadCells = YES;
                                       _saveButton.enabled = YES;
                                       [_firstCell.activityIndicator stopAnimating];
                                       [emailTableView reloadData];//hack, the first one doesn't take for some reason
                                       
                                       return;
                                   }];
        
        [alertController addAction:okAction];
        [self presentViewController:alertController animated:YES completion:nil];
        return;
    }
    
    //get emails that need updates and get emails that need to be saved
    NSMutableArray* updateEmails = [[NSMutableArray alloc] init];
    NSMutableArray* emailObjects = [[NSMutableArray alloc] init];
    //set the email addresses
    for(int i = 0; i < emailAddresses.count; i++)
    {
        Email* email = (Email*)emailAddresses[i];
        email.address = emailAddressesStrings[i];
        [emailAddresses setObject:email atIndexedSubscript:i];
        
        //adding to update or create array
        if([email.email_id isEqualToString:@"-1"])
        {
            //save the new emails
            PFObject* p = [PFObject objectWithClassName:@"EmailAddress"];
            p[@"type"] = email.type;
            p[@"address"] = email.address;
            p[@"user"] = [PFUser currentUser];
            
            //setting acl
            PFACL *defaultACL = [PFACL ACL];
            [defaultACL setReadAccess:true forUser:[PFUser currentUser]];
            [defaultACL setWriteAccess:true forUser:[PFUser currentUser]];
            [defaultACL setPublicReadAccess:false];
            [defaultACL setPublicWriteAccess:false];
            [p setACL:defaultACL];
            
            NSLog(@"email address with %@ from email id %@", email.address, email.email_id);
            
            //add the pfobject to the objects array
            [emailObjects addObject:p];
        }
        else//make sure the email really needs to be updated
        {
            NSLog(@"trying to update email");
            StorePrivateProfile* spp = [StorePrivateProfile shared];
            PrivateProfile* profile = spp.profile;
            for(Email* p in profile.emailAddresses)
            {
                //found the email, now see if we want to add it to the array or not
                if([p.email_id isEqualToString:email.email_id])
                {
                    NSLog(@"p is %@ and email is %@", p, email);
                    //Either the type or address doesn't match so need to update
                    if(![p.type isEqualToString:email.type] || ![p.address isEqualToString:email.address])
                    {
                        NSLog(@"added email to update!");
                        [updateEmails addObject:email];
                    }
                    else
                    {
                        NSLog(@"didn't add email to update");
                    }
                }
            }
            
        }
    }
    
    //get the main database
    MainDatabase* md = [MainDatabase shared];
    [md.queue inDatabase:^(FMDatabase *db) {
        for(Email* email in updateEmails)
        {
            //want to first update the emails we have saved
            NSString *updateSQL = @"UPDATE email SET address = ?, type = ? WHERE user_id = ? AND email_id = ?";
            NSArray* values = @[email.address, email.type, [PFUser currentUser].objectId, email.email_id];
            [db executeUpdate:updateSQL withArgumentsInArray:values];
        }
        
    }];
    
    NSMutableArray* emailIds = [[NSMutableArray alloc] init];
    
    //create a list of email ids to update
    for(Email* email in updateEmails)
        [emailIds addObject:email.email_id];
    
    NSLog(@"email ids is %@", emailIds);
    //if the emailIds is empty we only need to create new ones so call function to do that
    if(!emailIds.count)
    {
        [self saveEmails:emailObjects];
        return;
    }
    
    //query the update list to update
    PFQuery* emailQuery = [PFQuery queryWithClassName:@"EmailAddress"];
    [emailQuery whereKey:@"user" equalTo:[PFUser currentUser]];
    [emailQuery whereKey:@"objectId" containedIn:emailIds];
    [emailQuery findObjectsInBackgroundWithBlock:^(NSArray *objects, NSError *error) {
        if(error)
        {
            //setting up the ok action if it is needed
            UIAlertAction *okAction = [UIAlertAction
                                       actionWithTitle:NSLocalizedString(@"Ok", @"Ok action")
                                       style:UIAlertActionStyleDefault
                                       handler:^(UIAlertAction *action)
                                       {
                                           NSLog(@"Ok action");
                                           _saveButton.enabled = YES;
                                           [_firstCell.activityIndicator stopAnimating];
                                           return;
                                       }];
            
            UIAlertController *alertController = [UIAlertController
                                                  alertControllerWithTitle:@"Can't Save"
                                                  message:@"Could not save at this time.  Check your internet connection and try again.  If this problem persists, please inform whoYu."
                                                  preferredStyle:UIAlertControllerStyleAlert];
            [alertController addAction:okAction];
            [self presentViewController:alertController animated:YES completion:nil];
            return;
        }
        
        //delete the old email addresses
        for(PFObject* obj in objects)
        {
            //find the right object to update
            for(Email* email in updateEmails)
            {
                //found it
                if([email.email_id isEqualToString:obj.objectId])
                {
                    obj[@"type"] = email.type;
                    obj[@"address"] = email.address;
                    //[obj saveEventually];
                    break;
                }
            }
        }
        
        [PFObject saveAllInBackground:objects];
        
        //call function to save emails
        [self saveEmails:emailObjects];
        
    }];
    
    
}

- (IBAction)cancelAction:(id)sender {
    if(self.navigationController.viewControllers.count > 1)
        [self.navigationController popViewControllerAnimated:YES];
    else
        [self performSegueWithIdentifier:@"myProfileSegue" sender:self];
}
@end
