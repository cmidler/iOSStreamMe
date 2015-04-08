//
//  EditProfileViewController.m
//  genesis
//
//  Created by Chase Midler on 9/9/14.
//  Copyright (c) 2014 midler. All rights reserved.
//

#import "EditProfileViewController.h"

@interface EditProfileViewController ()

@end

@implementation EditProfileViewController
@synthesize editMeTable;
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
    // This will remove extra separators from tableview
    self.editMeTable.tableFooterView = [[UIView alloc] initWithFrame:CGRectZero];
    UITapGestureRecognizer *tap = [[UITapGestureRecognizer alloc]
                                   initWithTarget:self
                                   action:@selector(dismissKeyboard)];
    tap.cancelsTouchesInView = NO;
    
    StoreUserProfile* sup = [StoreUserProfile shared];
    UserProfile* profile = sup.profile;
    _firstName = profile.first_name;
    _relationshipStatus = profile.relationship_status;
    _sex = profile.sex;
    _interestedIn = profile.interested_in;
    _birthday = profile.birthday;
    _pickerViewShown = NO;
    _pickerSelection = @"";
    
    [self.view addGestureRecognizer:tap];
}

- (void) dismissKeyboard
{
    [self.editMeTable endEditing:YES];
}

//Delegates for helping textview have placeholder text
- (void)textFieldDidBeginEditing:(UITextField *)textField
{
    if([textField.text isEqualToString:@"Enter Name"])
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
        textField.text = @"Enter Name";
        textField.textColor = [UIColor lightGrayColor];
    }
    _firstName = textField.text;
    [textField resignFirstResponder];
}
 
 
 //used for updating status
 - (BOOL)textField:(UITextField *)textField
 shouldChangeCharactersInRange:(NSRange)range
 replacementString:(NSString *)text
{
 
    //check if they user is trying to enter too many characters
    if([[textField text] length] - range.length + text.length > MAX_NAME_CHARS && ![text isEqualToString:@"\n"])
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
 

- (void) viewWillAppear:(BOOL)animated
{
    self.automaticallyAdjustsScrollViewInsets = NO;
    _pickerViewShown = NO;
    _toolBar.hidden = YES;
    _toolBar = nil;
    [self loadTable];
}

//helper method for loading table data
- (void) loadTable
{
    StoreUserProfile* sup = [StoreUserProfile shared];
    UserProfile* profile = sup.profile;
    editFields = @[profile.first_name,profile.sex, profile.interested_in, profile.relationship_status, profile.birthday];
    [editMeTable reloadData];
}

- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView
{
    // Return the number of sections.
    return 1;
}

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section
{
    
    // Return the number of rows in the section.
    if(_pickerViewShown)
        return (editFields.count+1);
    return [editFields count];
}

//Show data in cells
- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath
{
    
    static NSString *CellIdentifier = @"editCell";
    EditProfileTableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:CellIdentifier forIndexPath:indexPath];
    cell.separatorInset = UIEdgeInsetsZero;
    cell.pickerView.hidden = YES;
    cell.datePicker.hidden = YES;
    cell.fieldStatusLabel.hidden = NO;
    cell.fieldTitleLabel.hidden = NO;
    cell.nameTextField.hidden = YES;
    cell.dropDownImageView.hidden = YES;
    cell.accessoryType = UITableViewCellAccessoryNone;
    
    [cell.activityIndicator stopAnimating];
    cell.activityIndicator.center = cell.center;
    //get section 0 row 0
    if(!indexPath.section && !indexPath.row)
        _firstCell = cell;
    
    //since I hardset the array I know what each row will represent
    if(!_pickerViewShown)
    {
        //UIButton *accessoryBtn = [UIButton buttonWithType:UIButtonTypeSystem];
        
        switch(indexPath.row)
        {
            case 0:
                cell.fieldTitleLabel.text = @"First name is:";
                if([_firstName isEqualToString:@"Enter Name"])
                    cell.nameTextField.textColor = [UIColor grayColor];
                else
                    cell.nameTextField.textColor = [UIColor blackColor];
                cell.nameTextField.text = _firstName;
                cell.fieldStatusLabel.hidden = YES;
                cell.nameTextField.hidden = NO;
                break;
            case 1:
                cell.fieldTitleLabel.text = @"Gender is:";
                cell.fieldStatusLabel.text = _sex;
                cell.dropDownImageView.hidden = NO;
                break;
            case 2:
                cell.fieldTitleLabel.text = @"Interested in:";
                cell.fieldStatusLabel.text = _interestedIn;
                cell.dropDownImageView.hidden = NO;
                break;
            case 3:
                cell.fieldTitleLabel.text = @"Relationship status is:";
                cell.fieldStatusLabel.text = _relationshipStatus;
                cell.dropDownImageView.hidden = NO;
                break;
            case 4:
                cell.fieldTitleLabel.text = @"Birthday is:";
                if([_birthday isEqualToString:@"01/01/1900"])
                    cell.fieldStatusLabel.text = @"Not displaying";
                else
                    cell.fieldStatusLabel.text = _birthday;
                cell.dropDownImageView.hidden = NO;
                break;
            default:
                cell.fieldTitleLabel.text = @"Unknown error";
                cell.fieldStatusLabel.text = @"Unknown error";
                break;
        }
    }
    //a picker view is shown.  different info based on the cell
    else
    {
        //the cell is less than the pickerview cell, equal to, or greater than
        if(indexPath.row < _pickerViewShownIndex)
        {
            //normal case
            switch(indexPath.row)
            {
                case 0:
                    cell.fieldTitleLabel.text = @"First name is:";
                    if([_firstName isEqualToString:@"Enter Name"])
                        cell.nameTextField.textColor = [UIColor grayColor];
                    else
                        cell.nameTextField.textColor = [UIColor blackColor];
                    cell.nameTextField.text = _firstName;
                    cell.fieldStatusLabel.hidden = YES;
                    cell.nameTextField.hidden = NO;
                    break;
                case 1:
                    cell.fieldTitleLabel.text = @"Gender is:";
                    cell.fieldStatusLabel.text = _sex;
                    if(_pickerViewShownIndex != indexPath.row+1)
                    {
                        cell.dropDownImageView.hidden = NO;
                    }
                    break;
                case 2:
                    cell.fieldTitleLabel.text = @"Interested in:";
                    cell.fieldStatusLabel.text = _interestedIn;
                    if(_pickerViewShownIndex != indexPath.row+1)
                    {
                        cell.dropDownImageView.hidden = NO;
                    }
                    break;
                case 3:
                    cell.fieldTitleLabel.text = @"Relationship status is:";
                    cell.fieldStatusLabel.text = _relationshipStatus;
                    if(_pickerViewShownIndex != indexPath.row+1)
                    {
                        cell.dropDownImageView.hidden = NO;
                    }
                    break;
                case 4:
                    cell.fieldTitleLabel.text = @"Birthday is:";
                    if([_birthday isEqualToString:@"01/01/1900"])
                        cell.fieldStatusLabel.text = @"Not Displaying";
                    else
                        cell.fieldStatusLabel.text = _birthday;
                    if(_pickerViewShownIndex != indexPath.row+1)
                    {
                        cell.dropDownImageView.hidden = NO;
                    }
                    break;

                default:
                    cell.fieldTitleLabel.text = @"Unknown error";
                    cell.fieldStatusLabel.text = @"Unknown error";
                    break;
            }
        }
        //cell if greater than picker view
        else if(indexPath.row>_pickerViewShownIndex)
        {
            //increase the switch case by 1 for everything
            switch((indexPath.row-1))
            {
                case 2:
                    cell.fieldTitleLabel.text = @"Interested in:";
                    cell.fieldStatusLabel.text = _interestedIn;
                    cell.dropDownImageView.hidden = NO;
                    break;
                case 3:
                    cell.fieldTitleLabel.text = @"Relationship status is:";
                    cell.fieldStatusLabel.text = _relationshipStatus;
                    cell.dropDownImageView.hidden = NO;
                    break;
                case 4:
                    NSLog(@"hit birthday!");
                    cell.fieldTitleLabel.text = @"Birthday is:";
                    if([_birthday isEqualToString:@"01/01/1900"])
                        cell.fieldStatusLabel.text = @"Not displaying";
                    else
                        cell.fieldStatusLabel.text = _birthday;
                    cell.dropDownImageView.hidden = NO;
                    break;
                default:
                    cell.fieldTitleLabel.text = @"Unknown error";
                    cell.fieldStatusLabel.text = @"Unknown error";
                    break;
            }
        }
        //we are on the picker cell, need to figure out which one so we know what data to display
        else
        {
            NSLog(@"picker cell is %d", (int)indexPath.row);
            _toolBar.hidden = YES;
            _toolBar = nil;
            cell.nameTextField.hidden = YES;
            cell.fieldStatusLabel.hidden = YES;
            cell.fieldTitleLabel.hidden = YES;
            _originalOption = cell.fieldStatusLabel.text;
            //pickerView
            if(indexPath.row >1 && indexPath.row<5)
            {
                // add a toolbar with Cancel & Done button
                _toolBar = [[UIToolbar alloc] initWithFrame:CGRectMake(0, 0, 320, 64)];
                
                UIBarButtonItem *doneButton = [[UIBarButtonItem alloc] initWithBarButtonSystemItem:UIBarButtonSystemItemDone target:self action:@selector(doneTouched:)];
                UIBarButtonItem *cancelButton = [[UIBarButtonItem alloc] initWithBarButtonSystemItem:UIBarButtonSystemItemCancel target:self action:@selector(cancelTouched:)];
                
                // the middle button is to make the Done button align to right
                [_toolBar setItems:[NSArray arrayWithObjects:cancelButton, [[UIBarButtonItem alloc] initWithBarButtonSystemItem:UIBarButtonSystemItemFlexibleSpace target:nil action:nil], doneButton, nil]];
                
                [_toolBar removeFromSuperview];
                //cell.inputAccessoryView = _toolBar;
                [cell.pickerView selectRow:0 inComponent:0 animated:NO];
                [cell addSubview:_toolBar];
                //cell.inputView = _toolBar;
            }
            //datePicker
            else
            {
                cell.datePicker.datePickerMode = UIDatePickerModeDate;
                
                // add a toolbar with Cancel & Done button
                _toolBar = [[UIToolbar alloc] initWithFrame:CGRectMake(0, 0, 320, TOOL_BAR_HEIGHT)];
                
                UIBarButtonItem *doneButton = [[UIBarButtonItem alloc] initWithBarButtonSystemItem:UIBarButtonSystemItemDone target:self action:@selector(doneTouched:)];
                UIBarButtonItem *notDisplayingButton = [[UIBarButtonItem alloc] initWithTitle:@"Not Displaying" style:UIBarButtonItemStylePlain target:self action:@selector(notDisplayingTouched:)];
                UIBarButtonItem *cancelButton = [[UIBarButtonItem alloc] initWithBarButtonSystemItem:UIBarButtonSystemItemCancel target:self action:@selector(cancelTouched:)];
                
                // the middle button is to make the Done button align to right
                [_toolBar setItems:[NSArray arrayWithObjects:cancelButton, [[UIBarButtonItem alloc] initWithBarButtonSystemItem:UIBarButtonSystemItemFlexibleSpace target:nil action:nil], notDisplayingButton, [[UIBarButtonItem alloc] initWithBarButtonSystemItem:UIBarButtonSystemItemFlexibleSpace target:nil action:nil], doneButton, nil]];
                
                //we want the maximum date to be 18 years ago and the minimum date to be 01/01/1900
                NSDateFormatter *dateFormatter = [[NSDateFormatter alloc] init];
                [dateFormatter setDateFormat:@"MM/dd/yyyy"];
                NSDate* minDate = [dateFormatter dateFromString:@"01/01/1900"];
                
                NSCalendar *calendar = [[NSCalendar alloc] initWithCalendarIdentifier:NSCalendarIdentifierGregorian];
                NSDateComponents * comps = [[NSDateComponents alloc] init];
                [comps setYear: -18];
                NSDate * maxDate = [calendar dateByAddingComponents: comps toDate: [NSDate date] options: 0];
                
                [cell.datePicker setMaximumDate:maxDate];
                [cell.datePicker setMinimumDate:minDate];
                
                //if the date is the "Not Displaying" date then set to max date otherwise set to the stored date
                NSLog(@"birthday is %@", _birthday);
                if([_birthday isEqualToString:@"01/01/1900"] || [_birthday isEqualToString:@"Not displaying"])
                {
                    NSLog(@"birthday is true");
                    [cell.datePicker setDate:maxDate];
                }
                else
                {
                    NSDateFormatter *dateFormatter = [[NSDateFormatter alloc] init];
                    [dateFormatter setDateFormat:@"MM/dd/yyyy"];
                    NSDate *date = [dateFormatter dateFromString:_birthday];
                    [cell.datePicker setDate:date];
                }

                [_toolBar removeFromSuperview];
                //cell.inputAccessoryView = _toolBar;
                [cell addSubview:_toolBar];
                //cell.inputView = _toolBar;

            }
            //self.pickerViewTextField.inputAccessoryView = toolBar;
            //increase the switch case by 1 for everything
            switch((indexPath.row-1))
            {
                case 1:
                    //GENDER
                    cell.pickerView.hidden = NO;
                    
                    break;
                case 2:
                    //INTERESTED IN
                    cell.pickerView.hidden = NO;
                    break;
                case 3:
                    //RELATIONSHIP STATUS
                    cell.pickerView.hidden = NO;
                    break;
                case 4:
                    //BIRTHDAY
                    cell.datePicker.hidden = NO;
                    break;
                default:
                    break;
            }

        }
        
    }
    
    return cell;
}

//On click of cell, segue or drop down
- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath
{
    static NSString *CellIdentifier = @"editCell";
    EditProfileTableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:CellIdentifier forIndexPath:indexPath];
    [cell setSelectionStyle:UITableViewCellSelectionStyleDefault];
    
    //Switch statement for segue to edit
    if(!_pickerViewShown)
    {
        switch(indexPath.row)
        {
            case 0:
                [editMeTable reloadData];
                break;
            case 1:
                _pickerViewShown = YES;
                _pickerViewShownIndex = (int)indexPath.row+1;
                options = @[@"Not displaying",@"Male", @"Female", @"Other"];
                /*[cell becomeFirstResponder];
                 [cell reloadInputViews];*/
                [editMeTable reloadData];
                break;
            case 2:
                _pickerViewShown = YES;
                _pickerViewShownIndex = (int)indexPath.row+1;
                options= @[@"Not displaying", @"Men", @"Women", @"Men & Women"];
                /*[cell becomeFirstResponder];
                 [cell reloadInputViews];*/
                [editMeTable reloadData];
                break;
            case 3:
                _pickerViewShown = YES;
                _pickerViewShownIndex = (int)indexPath.row+1;
                options= @[@"Not displaying", @"Single", @"Taken"];
                /*[cell becomeFirstResponder];
                 [cell reloadInputViews];*/
                [editMeTable reloadData];
                break;
            case 4:
                _pickerViewShown = YES;
                _pickerViewShownIndex = (int)indexPath.row+1;
                [editMeTable reloadData];
                break;
            default:
                break;
        }
    }
    else
    {
        //the cell is less than the pickerview cell, equal to, or greater than
        if(indexPath.row < _pickerViewShownIndex)
        {
            //normal case
            switch(indexPath.row)
            {
                case 0:
                    [cell.nameTextField becomeFirstResponder];
                    _pickerViewShown = NO;
                    [editMeTable reloadData];
                    break;
                case 1:
                    _pickerViewShown = YES;
                    _pickerViewShownIndex = (int)indexPath.row+1;
                    options = @[@"Not displaying",@"Male", @"Female"];
                    /*[cell becomeFirstResponder];
                    [cell reloadInputViews];*/
                    [editMeTable reloadData];
                    break;
                case 2:
                    _pickerViewShown = YES;
                    _pickerViewShownIndex = (int)indexPath.row+1;
                    options= @[@"Not displaying", @"Men", @"Women", @"Men & Women"];
                    /*[cell becomeFirstResponder];
                     [cell reloadInputViews];*/
                    [editMeTable reloadData];
                    break;
                case 3:
                    _pickerViewShown = YES;
                    _pickerViewShownIndex = (int)indexPath.row+1;
                    options= @[@"Not displaying", @"Single", @"Taken"];
                    /*[cell becomeFirstResponder];
                     [cell reloadInputViews];*/
                    [editMeTable reloadData];
                    break;
                case 4:
                    _pickerViewShown = YES;
                    _pickerViewShownIndex = (int)indexPath.row+1;
                    [editMeTable reloadData];
                default:
                    break;
            }
        }
        //cell if greater than picker view
        else if(indexPath.row>_pickerViewShownIndex)
        {
            //increase the switch case by 1 for everything
            switch((indexPath.row-1))
            {
                case 2:
                    _pickerViewShown = YES;
                    _pickerViewShownIndex = (int)indexPath.row;
                    options= @[@"Not displaying", @"Men", @"Women", @"Men & Women"];
                    /*[cell becomeFirstResponder];
                     [cell reloadInputViews];*/
                    [editMeTable reloadData];
                    break;
                case 3:
                    _pickerViewShown = YES;
                    _pickerViewShownIndex = (int)indexPath.row;
                    options= @[@"Not displaying", @"Single", @"Taken"];
                    /*[cell becomeFirstResponder];
                     [cell reloadInputViews];*/
                    [editMeTable reloadData];
                    break;
                case 4:
                    _pickerViewShown = YES;
                    _pickerViewShownIndex = (int)indexPath.row;
                    [editMeTable reloadData];
                    break;
                default:
                    break;
            }
        }
        //we are on the picker cell, need to figure out which one so we know what data to display
        else
        {
            //increase the switch case by 1 for everything
            switch((indexPath.row))
            {
                case 2:
                    //GENDER
                    cell.pickerView.hidden = NO;
                    
                    //Generate the array for gender
                    //options = @[@"Male", @"Female", @"Not displaying"];
                    break;
                case 3:
                    //INTERESTED IN
                    cell.pickerView.hidden = NO;
                    //options= @[@"Not sharing", @"Men", @"Women", @"Men & Women"];
                    break;
                case 4:
                    //RELATIONSHIP STATUS
                    cell.pickerView.hidden = NO;
                    //options= @[@"Not sharing", @"Single", @"Taken"];
                    break;
                case 5:
                    //BIRTHDAY
                    cell.datePicker.hidden = NO;
                    //cell.datePicker.hidden = NO;
                    break;
                default:
                    cell.fieldTitleLabel.text = @"Unknown error";
                    cell.fieldStatusLabel.text = @"Unknown error";
                    break;
            }
            
        }

    }
}

// Catpure the picker view selection
- (void)pickerView:(UIPickerView *)pickerView didSelectRow:(NSInteger)row inComponent:(NSInteger)component
{
    NSLog(@"Got component");
    _pickerSelection = options[row];
}

// The number of columns of data
- (NSInteger)numberOfComponentsInPickerView:(UIPickerView *)pickerView
{
    return 1;
}

// The number of rows of data
- (NSInteger)pickerView:(UIPickerView *)pickerView numberOfRowsInComponent:(NSInteger)component
{
    NSLog(@"options count is %d", (int)options.count);
    return options.count;
}

// The data to return for the row and component (column) that's being passed in
- (NSString*)pickerView:(UIPickerView *)pickerView titleForRow:(NSInteger)row forComponent:(NSInteger)component
{
    //NSLog(@"the option for picker view is %@", options[row]);
    if(row >= options.count) //return the old selected option
        return _originalOption;
    return options[row];
}


- (CGFloat)tableView:(UITableView*)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath
{
    //if no picker view shown, make the table height be the default height
    if(!_pickerViewShown)
        return tableView.rowHeight;
    
    //picker view is shown  it means we have to see if the row is the picker view or not
    if(indexPath.row == _pickerViewShownIndex)
    {
        //see if it is a date picker or picker view
        if(_pickerViewShownIndex >=5)
        {
            NSLog(@"getting a bigger height for date picker");
            return PICKER_HEIGHT + TOOL_BAR_HEIGHT;
        }
        else
            return PICKER_HEIGHT;
    }
    else
        return tableView.rowHeight;
    
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
    [self.editMeTable resignFirstResponder];
    _pickerViewShown = NO;
    _toolBar.hidden = YES;
    _toolBar = nil;
    _pickerSelection = @"";
    [editMeTable reloadData];
}

- (void)notDisplayingTouched:(UIBarButtonItem *)sender
{
    [self.editMeTable resignFirstResponder];
    _pickerViewShown = NO;
    _toolBar.hidden = YES;
    _toolBar = nil;
    _birthday = @"01/01/1900";
    _pickerSelection = @"";
    [editMeTable reloadData];
}

//handle done button touched in pickerview
- (void)doneTouched:(UIBarButtonItem *)sender
{
    NSLog(@"Done Button touched");
    [self.editMeTable resignFirstResponder];
    _pickerViewShown = NO;
    _toolBar.hidden = YES;
    _toolBar = nil;
    
    if(!_pickerSelection || !_pickerSelection.length)
    {
        if(_pickerViewShownIndex>=5)
        {
            //see if it is default (means we should save today's date
            if([_pickerSelection isEqualToString:@"01/01/1900"])
            {
                NSDateFormatter *formatter = [[NSDateFormatter alloc] init];
                [formatter setDateFormat:@"MM/dd/yyyy"];
                _pickerSelection = [formatter stringFromDate:[NSDate date]];
            }
            else if(!_pickerSelection.length)
            {
                NSDateFormatter *formatter = [[NSDateFormatter alloc] init];
                [formatter setDateFormat:@"MM/dd/yyyy"];
                
                NSCalendar *calendar = [[NSCalendar alloc] initWithCalendarIdentifier:NSCalendarIdentifierGregorian];
                NSDateComponents * comps = [[NSDateComponents alloc] init];
                [comps setYear: -18];
                NSDate * maxDate = [calendar dateByAddingComponents: comps toDate: [NSDate date] options: 0];
                
                _pickerSelection = [formatter stringFromDate:maxDate];
            }
            //save the birthday already selected
            else
                _pickerSelection = _birthday;
        }
        else
            _pickerSelection = options[0];
    }
    
    //need to get the selection
    switch (_pickerViewShownIndex) {
        //GENDER
        case 2:
            _sex = _pickerSelection;
            break;
        case 3:
            _interestedIn = _pickerSelection;
            break;
        case 4:
            _relationshipStatus = _pickerSelection;
            break;
        case 5:
            _birthday = _pickerSelection;
            break;
        default:
            break;
    }
    _pickerSelection = @"";
    
    [editMeTable reloadData];
}

- (void) saveHelper
{
    PFUser* user = [PFUser currentUser];
    StoreUserProfile* sup = [StoreUserProfile shared];
    UserProfile* profile = sup.profile;
    
    //make sure the first name is not empty
    if(!_firstName || !_firstName.length || [_firstName isEqualToString:@"Enter Name"])
    {
        UIAlertView* nameAlert = [[UIAlertView alloc] initWithTitle:@"Name Cannot Be Blank"
                                                            message:@"Cannot save your profile because the name is empty."
                                                           delegate:nil
                                                  cancelButtonTitle:@"ok"
                                                  otherButtonTitles:nil];
        [nameAlert show];
        _saveButton.enabled = YES;
        [_firstCell.activityIndicator stopAnimating];
        return;
    }
    
    
    //see if any data changed.  If nothing did, just pop
    if([_firstName isEqualToString:profile.first_name] && [_relationshipStatus isEqualToString:profile.relationship_status] && [_interestedIn isEqualToString:profile.interested_in] && [_birthday isEqualToString:profile.birthday] && [_sex isEqualToString:profile.sex])
    {
        _saveButton.enabled = YES;
        [_firstCell.activityIndicator stopAnimating];
        [self.navigationController popViewControllerAnimated:YES];
        return;
    }
    
    
    //Now need to see what has actually changed
    NSMutableArray* uuids = [[NSMutableArray alloc] init];
    
    profile.first_name = _firstName;
    profile.birthday = _birthday;
    profile.sex = _sex;
    profile.relationship_status = _relationshipStatus;
    profile.interested_in = _interestedIn;
    
    [sup setProfile:profile];
    
    //get the main database
    MainDatabase* md = [MainDatabase shared];
    [md.queue inDatabase:^(FMDatabase *db) {
        NSString *updateSQL = @"UPDATE user SET first_name = ?, interested_in = ?, sex = ?, relationship_status = ?, birthday = ? WHERE is_me = ?";
        NSArray* values = @[_firstName, _interestedIn, _sex, _relationshipStatus, _birthday, [NSNumber numberWithInt:1]];
        [db executeUpdate:updateSQL withArgumentsInArray:values];
    }];
    
    [user saveEventually:^(BOOL succeeded, NSError *error) {
        if(!error && succeeded)
        {
            //only makes sense to call this function after it actually saves
            NSDictionary* userInfo = @{@"uuids": uuids};
            NSLog(@"user uuids were %@", uuids);
            [[NSNotificationCenter defaultCenter] postNotificationName:@"changedProfile" object:self userInfo:userInfo];
        }
        else
            NSLog(@"User save eventually failed");
    }];
    
    _saveButton.enabled = YES;
    [_firstCell.activityIndicator stopAnimating];
    NSLog(@"added values to sqlite database");
    [self.navigationController popViewControllerAnimated:YES];
}

- (IBAction)saveAction:(id)sender
{
    dispatch_async(dispatch_get_main_queue(), ^{
        _saveButton.enabled = NO;
        [_firstCell.activityIndicator startAnimating];
    });
    [editMeTable reloadData];
    [self performSelector:@selector(saveHelper) withObject:nil afterDelay:1];
}

//method for when the date value is changed
- (IBAction)dateValueChanged:(id)sender {
    
    NSDateFormatter *formatter = [[NSDateFormatter alloc] init];
    [formatter setDateFormat:@"MM/dd/yyyy"];
    
    NSDate* date = ((UIDatePicker*)sender).date;
    
    _pickerSelection = [formatter stringFromDate:date];
    NSLog(@"picker selection is %@ in date", _pickerSelection);
}
@end
