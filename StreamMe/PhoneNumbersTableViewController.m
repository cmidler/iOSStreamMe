//
//  PhoneNumbersTableViewController.m
//  WhoYu
//
//  Created by Chase Midler on 1/26/15.
//  Copyright (c) 2015 midler. All rights reserved.
//

#import "PhoneNumbersTableViewController.h"

@interface PhoneNumbersTableViewController ()

@end

@implementation PhoneNumbersTableViewController
@synthesize phoneNumbersTableView;
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
    
    phoneNumbers = [[NSMutableArray alloc] init];
    phoneNumberStrings = [[NSMutableArray alloc] init];
    badCells = [[NSMutableArray alloc]init];
    pickerOptions = @[@"Mobile Phone", @"Work Phone", @"Home Phone"];
    [self setupPhoneNumbers];
}

//Helper function to populate the phone numbers array
-(void) setupPhoneNumbers
{
    StorePrivateProfile* spp = [StorePrivateProfile shared];
    PrivateProfile* profile = spp.profile;
    NSLog(@"profile numbers is %@", spp.profile.phoneNumbers);
    
    //initialize phonenumbers array
    for(Phone* phone in profile.phoneNumbers)
    {
        [phoneNumberStrings addObject:phone.number];
        Phone* p = [[Phone alloc] init];
        p.type = phone.type;
        p.number = phone.number;
        p.phone_id = phone.phone_id;
        [phoneNumbers addObject:p];
    }
    
    if(phoneNumbers.count == MAX_PHONE_NUMBERS)
        _addRowShowing = NO;
    else
        _addRowShowing = YES;
    
    [phoneNumbersTableView reloadData];
}


//helper to occur when the add phone cell is clicked
-(void) addPhone
{
    //adding a default phone
    Phone* phone = [[Phone alloc] init];
    phone.type = @"Mobile Phone";
    phone.number = @"(123) 456-7890";
    phone.phone_id = @"-1";//make it -1 so I know it isn't a real id
    
    [phoneNumbers addObject:phone];
    [phoneNumberStrings addObject:phone.number];
    if(phoneNumbers.count == MAX_PHONE_NUMBERS)
        _addRowShowing = NO;
    else
        _addRowShowing = YES;

}

- (void) dismissKeyboard
{
    [self.phoneNumbersTableView endEditing:YES];
}

//Delegates for helping textview have placeholder text
- (void)textViewDidBeginEditing:(UITextView *)textView
{
    if([textView.text isEqualToString:@"(123) 456-7890"])
    {
        textView.text = @"";
        [phoneNumberStrings setObject:textView.text atIndexedSubscript:textView.tag];
    }
    
    [textView becomeFirstResponder];
}

-(void)textViewDidChange:(UITextView *)textView
{
    NSLog(@"tag for text did change is %d and text is %@", (int)textView.tag, textView.text);
    [phoneNumberStrings setObject:textView.text atIndexedSubscript:textView.tag];
}

//used for updating status
- (BOOL)textView:(UITextView *)textView
shouldChangeTextInRange:(NSRange)range
 replacementText:(NSString *)text
{
    //NSLog(@"entered text should change");
    //don't let the user enter anything but numbers, and do not let them enter more than 1 character
    if(text.length > 1)
    {
        return NO;
    }
    
    //check that the number is between 0-9 and not something else
    if(text.length)
    {
        NSNumberFormatter *f = [[NSNumberFormatter alloc] init];
        f.numberStyle = NSNumberFormatterDecimalStyle;
        NSNumber *myNumber = [f numberFromString:text];
        if(!myNumber)
            return NO;
    }
    int length = [self getLength:textView.text];
    //NSLog(@"Length  =  %d ",length);
    
    if(length == 10)
    {
        if(range.length == 0)
            return NO;
    }
    
    if(length == 3)
    {
        NSString *num = [self formatNumber:textView.text];
        textView.text = [NSString stringWithFormat:@"(%@) ",num];
        if(range.length > 0)
            textView.text = [NSString stringWithFormat:@"%@",[num substringToIndex:3]];
    }
    else if(length == 6)
    {
        NSString *num = [self formatNumber:textView.text];
        //NSLog(@"%@",[num  substringToIndex:3]);
        //NSLog(@"%@",[num substringFromIndex:3]);
        textView.text = [NSString stringWithFormat:@"(%@) %@-",[num  substringToIndex:3],[num substringFromIndex:3]];
        if(range.length > 0)
            textView.text = [NSString stringWithFormat:@"(%@) %@",[num substringToIndex:3],[num substringFromIndex:3]];
    }
    
    return YES;
}

-(NSString*)formatNumber:(NSString*)mobileNumber
{
    
    mobileNumber = [mobileNumber stringByReplacingOccurrencesOfString:@"(" withString:@""];
    mobileNumber = [mobileNumber stringByReplacingOccurrencesOfString:@")" withString:@""];
    mobileNumber = [mobileNumber stringByReplacingOccurrencesOfString:@" " withString:@""];
    mobileNumber = [mobileNumber stringByReplacingOccurrencesOfString:@"-" withString:@""];
    mobileNumber = [mobileNumber stringByReplacingOccurrencesOfString:@"+" withString:@""];
    
    NSLog(@"%@", mobileNumber);
    
    int length = (int)[mobileNumber length];
    if(length > 10)
    {
        mobileNumber = [mobileNumber substringFromIndex: length-10];
        NSLog(@"%@", mobileNumber);
        
    }
    
    
    return mobileNumber;
}


-(int)getLength:(NSString*)mobileNumber
{
    
    mobileNumber = [mobileNumber stringByReplacingOccurrencesOfString:@"(" withString:@""];
    mobileNumber = [mobileNumber stringByReplacingOccurrencesOfString:@")" withString:@""];
    mobileNumber = [mobileNumber stringByReplacingOccurrencesOfString:@" " withString:@""];
    mobileNumber = [mobileNumber stringByReplacingOccurrencesOfString:@"-" withString:@""];
    mobileNumber = [mobileNumber stringByReplacingOccurrencesOfString:@"+" withString:@""];
    
    int length = (int)[mobileNumber length];
    
    return length;
    
    
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
    // Return the number of rows in the section
    int additionalRows = _pickerViewShown + _addRowShowing;
    _numberOfCells = (int)phoneNumbers.count + additionalRows;
    return _numberOfCells;
}


- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath {
    PhoneNumbersTableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:@"phoneCell" forIndexPath:indexPath];
    cell.separatorInset = UIEdgeInsetsZero;
    [cell.activityIndicator stopAnimating];
    cell.activityIndicator.center = cell.center;
    //get section 0 row 0
    if(!indexPath.section && !indexPath.row)
        _firstCell = cell;
    
    
    cell.phoneNumberTextView.hidden = YES;
    cell.phoneTypeLabel.hidden = YES;
    cell.dropDownImageView.hidden = YES;
    cell.pickerView.hidden = YES;
    cell.addAnotherPhoneButton.hidden = YES;
    cell.addAnotherPhoneButton.userInteractionEnabled = NO;
    //give addanother phone button dashed line border
    [self drawDashedBorderAroundView:cell.addAnotherPhoneButton];
    cell.borderLabel.hidden = YES;
    cell.phoneNumberTextView.layer.borderWidth = 1.0;
    cell.phoneNumberTextView.layer.borderColor = [[UIColor clearColor] CGColor];
    NSLog(@"is showing bad cells is %d", _isShowingBadCells);
    
    //Easy display setting.  No picker view or there is one, but the rows are before it
    if(!_pickerViewShown || (indexPath.row<_pickerViewShownIndex))
    {
        //check if the row is less than the phoneNumbers.count
        if(indexPath.row < phoneNumbers.count)
        {
            cell.tag = NORMAL_CELL;
            cell.phoneNumberTextView.tag = indexPath.row;
            cell.phoneNumberTextView.hidden = NO;
            cell.phoneTypeLabel.hidden = NO;
            //unhide the drop down image if the picker view is not the next cell
            if(!_pickerViewShown || (_pickerViewShownIndex != (indexPath.row+1)))
                cell.dropDownImageView.hidden = NO;
            cell.borderLabel.hidden = NO;
            cell.phoneTypeLabel.text = ((Phone*)phoneNumbers[indexPath.row]).type;
            cell.phoneNumberTextView.text = phoneNumberStrings[indexPath.row];
            if(_isShowingBadCells)
            {
                for(NSNumber* bad in badCells)
                {
                    NSLog(@"bad is %d and indexpath.row is %d", bad.intValue, (int) indexPath.row);
                    if(bad.intValue == indexPath.row)
                    {
                        cell.phoneNumberTextView.layer.borderColor = [[UIColor redColor] CGColor];
                        break;
                    }
                }
            }
            
        }
        //we are on the add more rows
        else
        {
            cell.tag = ADD_CELL;
            cell.addAnotherPhoneButton.hidden = NO;
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
        if(indexPath.row > phoneNumbers.count) //(number of phones+pickerview)
        {
            cell.tag = ADD_CELL;
            cell.addAnotherPhoneButton.hidden = NO;
        }
        else
        {
            cell.tag = NORMAL_CELL;
            int offsetIndex = (int)indexPath.row-1;
            cell.phoneNumberTextView.tag = offsetIndex;
            cell.phoneNumberTextView.hidden = NO;
            cell.phoneTypeLabel.hidden = NO;
            cell.dropDownImageView.hidden = NO;
            cell.borderLabel.hidden = NO;
            cell.phoneTypeLabel.text = ((Phone*)phoneNumbers[offsetIndex]).type;
            cell.phoneNumberTextView.text = phoneNumberStrings[offsetIndex];
            if(_isShowingBadCells)
            {
                for(NSNumber* bad in badCells)
                {
                    if(bad.intValue == offsetIndex)
                    {
                        cell.phoneNumberTextView.layer.borderColor = [[UIColor redColor] CGColor];
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
            //want to add a new phone number to the phone numbers array
            [self addPhone];
            break;
        case PICKER_CELL:
            _pickerViewShown = YES;
            break;
        default:
            break;
    }
    
    //reload the table
    [phoneNumbersTableView reloadData];
}

//don't allow editing of pickerview cell or add cell
- (BOOL)tableView:(UITableView *)tableView canEditRowAtIndexPath:(NSIndexPath *)indexPath
{
    //on pickerview row
    if(_pickerViewShown && _pickerViewShownIndex == indexPath.row)
        return NO;
    //this will be a normal row (can't be picker row since we check above for that and can't be add row since add row needs to be the last row)
    else if(_pickerViewShown && indexPath.row==phoneNumbers.count)
        return YES;
    else if(indexPath.row >= phoneNumbers.count)
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
            Phone* phone;
            int row = (int)indexPath.row;
            //will be indexpath row
            if(!_pickerViewShown || indexPath.row<_pickerViewShownIndex)
                phone = phoneNumbers[row];
            else
                phone = phoneNumbers[--row];
            
            //nothing saved so just remove the row and be done
            if([phone.phone_id isEqualToString:@"-1"])
            {
                [phoneNumberStrings removeObjectAtIndex:row];
                [phoneNumbers removeObjectAtIndex:row];
                _addRowShowing = YES;
                if(_pickerViewShown && indexPath.row==_pickerViewShownIndex)
                    _pickerViewShown = NO;
                [phoneNumbersTableView reloadData];
                return;
            }
            //saving the phone id
            NSString* phoneId = phone.phone_id;
            PFQuery* phoneQuery = [PFQuery queryWithClassName:@"PhoneNumber"];
            [phoneQuery whereKey:@"objectId" equalTo:phone.phone_id];
            [phoneQuery findObjectsInBackgroundWithBlock:^(NSArray *objects, NSError *error) {
                
                //error checking
                if(error || !objects || ![objects count])
                {
                    [phoneNumbersTableView reloadData];
                    return;
                }
                
                //delete from parse
                for(PFObject* phone in objects)
                    [phone deleteEventually];
                
                //delete from storedprivateprofile as well
                StorePrivateProfile* ssp = [StorePrivateProfile shared];
                PrivateProfile* profile = ssp.profile;
                for(int i = 0; i <profile.phoneNumbers.count; i++)
                {
                    Phone* p = profile.phoneNumbers[i];
                    if([p.phone_id isEqualToString:phone.phone_id])
                    {
                        [profile.phoneNumbers removeObjectAtIndex:i];
                        break;
                    }
                }
                [ssp setProfile:profile];
                
                
                //remove the phone from helper arrays as well
                [phoneNumberStrings removeObjectAtIndex:row];
                [phoneNumbers removeObjectAtIndex:row];
                _addRowShowing = YES;
                if(_pickerViewShown && indexPath.row==_pickerViewShownIndex)
                    _pickerViewShown = NO;
                
                //get the main database
                MainDatabase* md = [MainDatabase shared];
                [md.queue inDatabase:^(FMDatabase *db) {
                    NSString *deleteSQL = @"DELETE FROM phone WHERE phone_id = ?";
                    NSArray* values = @[phoneId];
                    [db executeUpdate:deleteSQL withArgumentsInArray:values];
                
                    [phoneNumbersTableView reloadData];
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
    [self.phoneNumbersTableView resignFirstResponder];
    _pickerViewShown = NO;
    _toolBar.hidden = YES;
    _toolBar = nil;
    _pickerSelection = @"";
    [phoneNumbersTableView reloadData];
}

//handle done button touched in pickerview
- (void)doneTouched:(UIBarButtonItem *)sender
{
    NSLog(@"Done Button touched");
    [self.phoneNumbersTableView resignFirstResponder];
    _pickerViewShown = NO;
    _toolBar.hidden = YES;
    _toolBar = nil;
    
    if(!_pickerSelection || !_pickerSelection.length)
    {
        _pickerSelection = pickerOptions[0];
    }
    
    //need to set the correct type for the phone
    Phone* phone = ((Phone*)phoneNumbers[_pickerViewShownIndex-1]);
    phone.type = _pickerSelection;
    
    [phoneNumbers setObject:phone atIndexedSubscript:_pickerViewShownIndex-1];
    _pickerSelection = @"";
    
    [phoneNumbersTableView reloadData];
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

//helper function to create phones for the backend
- (void) savePhones:(NSArray*) phones
{
    [PFObject saveAllInBackground:phones block:^(BOOL succeeded, NSError *error) {
        
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
        else
        {
            //get the main database
            MainDatabase* md = [MainDatabase shared];
            [md.queue inDatabase:^(FMDatabase *db) {
                //add to local database as well
                for(PFObject* phone in phones)
                {
                    //did it now try to save the data
                    NSString *insertSQL = @"INSERT INTO phone (type, number, user_id, phone_id) VALUES (?, ?, ?, ?)";
                    NSArray* values = @[phone[@"type"], phone[@"number"], [PFUser currentUser].objectId, phone.objectId];
                    [db executeUpdate:insertSQL withArgumentsInArray:values];
                    
                    //now make sure we update the index on the stored profile
                    //loop through phone numbers to
                    for(int i = 0; i <phoneNumbers.count; i++)
                    {
                        Phone* p = phoneNumbers[i];
                        //find the phone match to save the user id
                        if([phone[@"type"] isEqualToString:p.type] && [phone[@"number"] isEqualToString:p.number])
                        {
                            p.phone_id = phone.objectId;
                            [phoneNumbers setObject:p atIndexedSubscript:i];
                            break;
                        }
                    }
                    
                }
                //now save the phone number to the stored private profiles
                StorePrivateProfile* spp = [StorePrivateProfile shared];
                PrivateProfile* profile = spp.profile;
                profile.phoneNumbers = phoneNumbers;
                NSLog(@"profile phone numbers is %@", profile.phoneNumbers);
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
                                                      message:@"Save was successful.  Your phone number data is private.  Nothing is shared unless you specifically send your contact information to another person."
                                                      preferredStyle:UIAlertControllerStyleAlert];
                [alertController addAction:okAction];
                [self presentViewController:alertController animated:YES completion:nil];
                return;
            }];
        }
    }];
    
}


//need to do lots of checks to validate data saved
- (IBAction)saveAction:(id)sender {
    _saveButton.enabled = NO;
    [_firstCell.activityIndicator startAnimating];
    _pickerViewShown = NO;
    [badCells removeAllObjects];
    
    int i = -1;
    //need to verify phone numbers
    for(NSString* number in phoneNumberStrings)
    {
        //increment i to get current index
        i++;
        //check if number is empty
        if(number.length!=MAX_PHONE_CHARS)
        {
            [badCells addObject:[NSNumber numberWithInt:i]];
            continue;
        }
        NSLog(@"Number is %@", number);
        
        //setup regex to make sure phone number is properly formatted
        NSString *phoneRegex = @"^\\([0-9]{3}\\)\\s[0-9]{3}-[0-9]{4}$";
        NSError  *error = nil;
        NSRange   searchedRange = NSMakeRange(0, number.length);
        NSRegularExpression* regex = [NSRegularExpression regularExpressionWithPattern: phoneRegex options:0 error:&error];
        
        NSArray* matches = [regex matchesInString:number options:0 range:searchedRange];
        
        //check if the phone number matches the regex
        if(!matches.count)
        {
            [badCells addObject:[NSNumber numberWithInt:i]];
            continue;
        }
    }
    
    //also make sure we only have one mobile, one home, and one work number
    bool hasHome = NO;
    bool hasMobile = NO;
    bool hasWork = NO;
    bool hasDuplicate = NO;
    for(Phone* phone in phoneNumbers)
    {
        NSString* type = phone.type;
        //MOBILE
        if([type isEqualToString:@"Mobile Phone"])
        {
            if(hasMobile)
                hasDuplicate = YES;
            else
                hasMobile = YES;
        }
        //WORK
        else if([type isEqualToString:@"Work Phone"])
        {
            if(hasWork)
                hasDuplicate = YES;
            else
                hasWork = YES;
        }
        //HOME
        else
        {
            if(hasHome)
                hasDuplicate = YES;
            else
                hasHome = YES;
        }
    }
    
    //show error alert
    if(hasDuplicate)
    {
        
        UIAlertController *alertController = [UIAlertController
                                              alertControllerWithTitle:@"Can't Save"
                                              message:@"You can only have one of each type of phone."
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
    [phoneNumbersTableView reloadData];
    
    NSLog(@"bad cells is %@", badCells);
    
    //if badcells have a count then return
    if(badCells.count)
    {
        UIAlertController *alertController = [UIAlertController
                                              alertControllerWithTitle:@"Can't Save"
                                              message:@"Make sure phone numbers are listed in the following format: (123) 456-7890."
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
                                       [phoneNumbersTableView reloadData];//hack, the first one doesn't take for some reason

                                       return;
                                   }];
        
        [alertController addAction:okAction];
        [self presentViewController:alertController animated:YES completion:nil];
        return;
    }
    
    //get phones that need updates and get phones that need to be saved
    NSMutableArray* updatePhones = [[NSMutableArray alloc] init];
    NSMutableArray* phoneObjects = [[NSMutableArray alloc] init];
    //set the phone numbers
    for(int i = 0; i < phoneNumbers.count; i++)
    {
        Phone* phone = (Phone*)phoneNumbers[i];
        phone.number = phoneNumberStrings[i];
        [phoneNumbers setObject:phone atIndexedSubscript:i];
        
        //adding to update or create array
        if([phone.phone_id isEqualToString:@"-1"])
        {
            //save the new phones
            PFObject* p = [PFObject objectWithClassName:@"PhoneNumber"];
            p[@"type"] = phone.type;
            p[@"number"] = phone.number;
            p[@"user"] = [PFUser currentUser];
            
            //setting acl
            PFACL *defaultACL = [PFACL ACL];
            [defaultACL setReadAccess:true forUser:[PFUser currentUser]];
            [defaultACL setWriteAccess:true forUser:[PFUser currentUser]];
            [defaultACL setPublicReadAccess:false];
            [defaultACL setPublicWriteAccess:false];
            [p setACL:defaultACL];
            
            NSLog(@"phone number with %@ from phone id %@", phone.number, phone.phone_id);
            
            //add the pfobject to the objects array
            [phoneObjects addObject:p];
        }
        else//make sure the phone really needs to be updated
        {
            NSLog(@"trying to update phone");
            StorePrivateProfile* spp = [StorePrivateProfile shared];
            PrivateProfile* profile = spp.profile;
            for(Phone* p in profile.phoneNumbers)
            {
                //found the phone, now see if we want to add it to the array or not
                if([p.phone_id isEqualToString:phone.phone_id])
                {
                    NSLog(@"p is %@ and phone is %@", p, phone);
                    //Either the type or number doesn't match so need to update
                    if(![p.type isEqualToString:phone.type] || ![p.number isEqualToString:phone.number])
                    {
                        NSLog(@"added phone to update!");
                        [updatePhones addObject:phone];
                    }
                    else
                    {
                        NSLog(@"didn't add phone to update");
                    }
                }
            }
            
        }
    }
    
    //get the main database
    MainDatabase* md = [MainDatabase shared];
    [md.queue inDatabase:^(FMDatabase *db) {
        for(Phone* phone in updatePhones)
        {
            //want to first update the phones we have saved
            NSString *updateSQL = @"UPDATE phone SET number = ?, type = ? WHERE user_id = ? AND phone_id = ?";
            NSArray* values = @[phone.number, phone.type, [PFUser currentUser].objectId, phone.phone_id];
            [db executeUpdate:updateSQL withArgumentsInArray:values];
        }
        
    }];
    
    
    NSMutableArray* phoneIds = [[NSMutableArray alloc] init];
    
    //create a list of phone ids to update
    for(Phone* phone in updatePhones)
        [phoneIds addObject:phone.phone_id];
    
    NSLog(@"Phone ids is %@", phoneIds);
    //if the phoneIds is empty we only need to create new ones so call function to do that
    if(!phoneIds.count)
    {
        [self savePhones:phoneObjects];
        return;
    }
    
    //query the update list to update
    PFQuery* phoneQuery = [PFQuery queryWithClassName:@"PhoneNumber"];
    [phoneQuery whereKey:@"user" equalTo:[PFUser currentUser]];
    [phoneQuery whereKey:@"objectId" containedIn:phoneIds];
    [phoneQuery findObjectsInBackgroundWithBlock:^(NSArray *objects, NSError *error) {
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
        
        //delete the old phone numbers
        for(PFObject* obj in objects)
        {
            //find the right object to update
            for(Phone* phone in updatePhones)
            {
                //found it
                if([phone.phone_id isEqualToString:obj.objectId])
                {
                    obj[@"type"] = phone.type;
                    obj[@"number"] = phone.number;
                    //[obj saveEventually];
                    break;
                }
            }
        }
        
        [PFObject saveAllInBackground:objects];
        
        //call function to save phones
        [self savePhones:phoneObjects];
        
    }];
}

- (IBAction)cancelAction:(id)sender {
    if(self.navigationController.viewControllers.count > 1)
    {
        NSLog(@"Count is %d", (int) self.navigationController.viewControllers.count);
        [self.navigationController popViewControllerAnimated:YES];
    }
    else
        [self performSegueWithIdentifier:@"myProfileSegue" sender:self];
}
@end
