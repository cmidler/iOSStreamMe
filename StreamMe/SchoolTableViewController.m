//
//  SchoolTableViewController.m
//  Proximity
//
//  Created by Chase Midler on 1/15/15.
//  Copyright (c) 2015 midler. All rights reserved.
//

#import "SchoolTableViewController.h"

@interface SchoolTableViewController ()

@end

@implementation SchoolTableViewController
@synthesize schoolTableView;
- (void)viewDidLoad {
    [super viewDidLoad];
    
    UITapGestureRecognizer *tap = [[UITapGestureRecognizer alloc]
                                   initWithTarget:self
                                   action:@selector(dismissKeyboard)];
    tap.cancelsTouchesInView = NO;
    [self.view addGestureRecognizer:tap];
    
    StoreProfessionalProfile* ssp = [StoreProfessionalProfile shared];
    for(School* school in ssp.profile.schools)
        if([school.school_id isEqualToString:_school_id])
        {
            _school = school;
            break;
        }
    
    //initializing helper variables
    //_lastEditedSection = 0;
    _name = _school.school_name;//_lastEditedString = _school.school_name
    _year = _school.year;
    if([_school.type isEqualToString:@"Graduate School"])
        _type = 0;
    else
        _type = 1;
    if(_school.isShowing)
        _checkMarkedRow = 0;
    else
        _checkMarkedRow = 1;
}

- (void) dismissKeyboard
{
    [self.schoolTableView endEditing:YES];
}

//Delegates for helping textview have placeholder text
- (void)textViewDidBeginEditing:(UITextView *)textView
{
    
    [textView becomeFirstResponder];
}

-(void)textViewDidChange:(UITextView *)textView
{
    if(textView.tag == 0)
    {
        _name = textView.text;
    }
    else if (textView.tag == 1)
    {
        _year = textView.text;
    }
}

//used for updating status
- (BOOL)textView:(UITextView *)textView
shouldChangeTextInRange:(NSRange)range
 replacementText:(NSString *)text
{
    int max_chars = 0;
    //then we use the year max chars
    if(textView.tag)
        max_chars = MAX_YEAR_CHARS;
    else
        max_chars = MAX_NAME_CHARS;
    
    //check if they user is trying to enter too many characters
    if(([[textView text] length] - range.length + text.length > max_chars) && ![text isEqualToString:@"\n"])
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
    // Return the number of sections. This is year/name/type
    return 5;
}

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section {
    // Return the number of rows in the section.  Only 1 row per section
    if(section <2)
        return 1;
    else
        return 2;
}

//Get the title for each section
- (NSString *)tableView:(UITableView *)tableView titleForHeaderInSection:(NSInteger)section
{
    NSString* sectionTitle = @"";
    
    switch (section) {
        case 0:
            sectionTitle = @"School Name";
            break;
        case 1:
            sectionTitle = @"Graduation Year";
            break;
        case 2:
            sectionTitle = @"Type Of School";
            break;
        case 3:
            sectionTitle = @"Share School Information";
            break;
        case 4:
            sectionTitle = @"More Actions";
            break;
        default:
            break;
    }
    return sectionTitle;
}


- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath {
    SchoolTableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:@"schoolCell" forIndexPath:indexPath];
    cell.separatorInset = UIEdgeInsetsZero;
    [cell.activityIndicator stopAnimating];
    cell.activityIndicator.center = cell.center;
    //get section 0 row 0
    if(!indexPath.section && !indexPath.row)
        _firstCell = cell;
    cell.fieldTextView.tag = indexPath.section;
    
    //go between different sections and populate the data
    switch (indexPath.section) {
        case 0:
            cell.fieldTextView.userInteractionEnabled = YES;
            cell.accessoryType = UITableViewCellAccessoryNone;
            cell.fieldTextView.text = _name;
            //[cell.fieldTextView becomeFirstResponder];//if this is blank, make it first responder
            break;
        case 1:
            cell.fieldTextView.userInteractionEnabled = YES;
            cell.accessoryType = UITableViewCellAccessoryNone;
            cell.fieldTextView.text = _year;
            break;
        case 2:
            cell.fieldTextView.userInteractionEnabled = NO;
            if(indexPath.row)
            {
                cell.fieldTextView.text = @"College";
                if(_type)
                    cell.accessoryType = UITableViewCellAccessoryCheckmark;
                else
                    cell.accessoryType = UITableViewCellAccessoryNone;
            }
            else
            {
                cell.fieldTextView.text = @"Graduate School";
                if(!_type)
                    cell.accessoryType = UITableViewCellAccessoryCheckmark;
                else
                    cell.accessoryType = UITableViewCellAccessoryNone;
            }
            break;
        case 3:
            cell.fieldTextView.userInteractionEnabled = NO;
            if(indexPath.row)
            {
                cell.fieldTextView.text = @"No";
                if(_checkMarkedRow)
                    cell.accessoryType = UITableViewCellAccessoryCheckmark;
                else
                    cell.accessoryType = UITableViewCellAccessoryNone;
            }
            else
            {
                cell.fieldTextView.text = @"Yes";
                if(!_checkMarkedRow)
                    cell.accessoryType = UITableViewCellAccessoryCheckmark;
                else
                    cell.accessoryType = UITableViewCellAccessoryNone;
            }
            break;
        case 4:
            cell.fieldTextView.userInteractionEnabled = NO;
            if(indexPath.row)
            {
                cell.accessoryType = UITableViewCellAccessoryDisclosureIndicator;
                cell.fieldTextView.text = @"Degrees";
            }
            else
            {
                cell.accessoryType = UITableViewCellAccessoryNone;
                cell.fieldTextView.text = @"Delete School";
            }
            break;
        default:
            cell.accessoryType = UITableViewCellAccessoryNone;
            NSLog(@"getting to default");
            break;
    }

    return cell;
}

//On click of cell, segue
- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath
{
    SchoolTableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:@"schoolCell" forIndexPath:indexPath];
    
    
    switch (indexPath.section) {
        case 0:
            [cell setSelectionStyle:UITableViewCellSelectionStyleNone];
            [schoolTableView reloadSections:[NSIndexSet indexSetWithIndex: 0] withRowAnimation:UITableViewRowAnimationAutomatic];
            [cell.fieldTextView becomeFirstResponder];
            break;
        case 1:
            [cell setSelectionStyle:UITableViewCellSelectionStyleNone];
            [schoolTableView reloadSections:[NSIndexSet indexSetWithIndex: 1] withRowAnimation:UITableViewRowAnimationAutomatic];
            [cell.fieldTextView becomeFirstResponder];
            break;
        case 2:
            [cell setSelectionStyle:UITableViewCellSelectionStyleDefault];
            _type = (int)indexPath.row;
            [schoolTableView reloadSections:[NSIndexSet indexSetWithIndex: 2] withRowAnimation:UITableViewRowAnimationAutomatic];
            break;
        case 3:
            [cell setSelectionStyle:UITableViewCellSelectionStyleDefault];
            _checkMarkedRow = (int)indexPath.row;
            [schoolTableView reloadSections:[NSIndexSet indexSetWithIndex: 3] withRowAnimation:UITableViewRowAnimationAutomatic];
            break;
        case 4:
            [cell setSelectionStyle:UITableViewCellSelectionStyleDefault];
            [schoolTableView reloadSections:[NSIndexSet indexSetWithIndex: 4] withRowAnimation:UITableViewRowAnimationAutomatic];
            if(indexPath.row)
                [self performSegueWithIdentifier:@"degreeSegue" sender:self];
            else
                [self deleteAction];
            break;
        default:
            break;
    }
    
    
}

// In a storyboard-based application, you will often want to do a little preparation before navigation
- (void)prepareForSegue:(UIStoryboardSegue *)segue sender:(id)sender {
    if([segue.identifier isEqualToString:@"degreeSegue"])
    {
        EditDegreesTableViewController *controller = (EditDegreesTableViewController *)segue.destinationViewController;
        controller.school_id = _school.school_id;
    }
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

//do a confirmation
- (void) deleteAction
{
    UIAlertController *newAlertController = [UIAlertController
                                             alertControllerWithTitle:@"Warning"
                                             message:@"About to delete school information."
                                             preferredStyle:UIAlertControllerStyleAlert];
    
    UIAlertAction *cancelAction = [UIAlertAction
                                   actionWithTitle:NSLocalizedString(@"Cancel", @"Cancel action")
                                   style:UIAlertActionStyleCancel
                                   handler:^(UIAlertAction *action)
                                   {
                                       NSLog(@"Cancel action");
                                       return;
                                   }];
    
    //We do delete
    UIAlertAction *deleteAction = [UIAlertAction
                                   actionWithTitle:NSLocalizedString(@"Delete", @"Delete action")
                                   style:UIAlertActionStyleDestructive
                                   handler:^(UIAlertAction *action)
    {
                                       
                                       
       NSLog(@"Delete the cell");
       
       _saveButton.enabled = NO;
       [_firstCell.activityIndicator startAnimating];
        
                    
        PFQuery* schoolQuery = [PFQuery queryWithClassName:@"School"];
        [schoolQuery whereKey:@"objectId" equalTo:_school.school_id];
        [schoolQuery findObjectsInBackgroundWithBlock:^(NSArray *objects, NSError *error) {
            
            //Try to save delete from database
            UIAlertAction *newOkAction = [UIAlertAction
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
                                                  alertControllerWithTitle:@"Something Went Wrong"
                                                  message:@"Could not delete the data.  Please try again.  If this persists please let us know."
                                                  preferredStyle:UIAlertControllerStyleAlert];
            
            [alertController addAction:newOkAction];
            
            
            //error checking
            if(error)
            {
                [self presentViewController:alertController animated:YES completion:nil];
                return;
            }

            
            PFObject* school = objects[0];
            
            //delete the school and degrees
            [school deleteEventually];
            
            //delete from storedprofessionalprofile as well
            StoreProfessionalProfile* ssp = [StoreProfessionalProfile shared];
            ProfessionalProfile* profile = ssp.profile;
            [profile.schools removeObject:_school];
            [ssp setProfile:profile];
            
            //get the main database
            MainDatabase* md = [MainDatabase shared];
            [md.queue inDatabase:^(FMDatabase *db) {
                //delete degrees first
                NSString *deleteDegreesSQL = @"DELETE FROM degree WHERE school_id = ?";
                NSArray* values = @[_school.school_id];
                [db executeUpdate:deleteDegreesSQL withArgumentsInArray:values];
                //delete schools
                NSString *deleteSQL = @"DELETE FROM school WHERE school_id = ?";
                [db executeUpdate:deleteSQL withArgumentsInArray:values];
                _saveButton.enabled = YES;
                [_firstCell.activityIndicator stopAnimating];
                [self.navigationController popViewControllerAnimated:YES];
            }];
        }];
    }];
    
    [newAlertController addAction:deleteAction];
    [newAlertController addAction:cancelAction];
    [self presentViewController:newAlertController animated:YES completion:nil];
    return;
}

//Save the school
- (IBAction)saveAction:(id)sender {
    _saveButton.enabled = NO;
    [_firstCell.activityIndicator startAnimating];
    //Convert type row to string
    NSString* type =@"";
    if(_type)
        type = @"College";
    else
        type = @"Graduate School";
    
    //if the values are the same as when we started then just pop the view controller
    if([_name isEqualToString:_school.school_name] && [type isEqualToString:_school.type] && [_year isEqualToString:_school.year] && _checkMarkedRow != _school.isShowing)
    {
        
        _saveButton.enabled = YES;
        [_firstCell.activityIndicator stopAnimating];
        [self.navigationController popViewControllerAnimated:YES];
        return;
    }
    
    //can't have empty values
    if(!_name.length || !type.length || !_year.length)
    {
        UIAlertView* emptyAlert = [[UIAlertView alloc] initWithTitle:@"Cannot Have Empty Values"
                                                             message:@"Please make sure all fields are completed."
                                                            delegate:nil
                                                   cancelButtonTitle:@"ok"
                                                   otherButtonTitles:nil];
        [emptyAlert show];
        _saveButton.enabled = YES;
        [_firstCell.activityIndicator stopAnimating];
        return;
        
    }
    
    UIAlertView* badYearAlert = [[UIAlertView alloc] initWithTitle:@"Bad Year"
                                                           message:@"Please use a valid year value."
                                                          delegate:nil
                                                 cancelButtonTitle:@"ok"
                                                 otherButtonTitles:nil];
    
    NSDateFormatter *formatter = [[NSDateFormatter alloc] init];
    [formatter setDateFormat:@"yyyy"];
    NSString *yearString = [formatter stringFromDate:[NSDate date]];
    
    //NSLog(@"last edited section is %d in save", _lastEditedSection);
    
    
    
    NSLog(@"year is %@",_year);
    
    //make sure the year is between 1900 and 10 years from now
    if(_year.intValue <1900 || _year.intValue > 10+yearString.intValue)
    {
        [badYearAlert show];
        _saveButton.enabled = YES;
        [_firstCell.activityIndicator stopAnimating];
        return;
    }
    
    //Otherwise we have to actually save the data.
    StoreProfessionalProfile* ssp = [StoreProfessionalProfile shared];
    ProfessionalProfile* proProfile = ssp.profile;
    
    //allocate a new school
    School* newSchool = [[School alloc] init];
    newSchool.school_id = _school.school_id;
    newSchool.school_name = _name;
    newSchool.year = _year;
    newSchool.type = type;
    newSchool.degrees = [NSMutableArray arrayWithArray: _school.degrees];
    newSchool.isShowing = !_checkMarkedRow;
    
    
    
    PFQuery *query = [PFQuery queryWithClassName:@"School"];
    
    // Retrieve the object by id
    [query getObjectInBackgroundWithId:newSchool.school_id block:^(PFObject *school, NSError *error) {
        
        //error check
        if(error || !school)
        {
            //Try to save data to database
            UIAlertView* errorAlert = [[UIAlertView alloc] initWithTitle:@"Something Went Wrong"
                                                                 message:@"Could not save the data.  Please check your internet connection and try again."
                                                                delegate:nil
                                                       cancelButtonTitle:@"ok"
                                                       otherButtonTitles:nil];
            [errorAlert show];
            _saveButton.enabled = YES;
            [_firstCell.activityIndicator stopAnimating];
            return;
        }
        
        //out with the old and in with the new
        for(School* s in proProfile.schools)
        {
            if([s.school_id isEqualToString:_school.school_id])
            {
                [proProfile.schools removeObject:s];
                break;
            }
        }
        [proProfile.schools removeObject:_school];
        [proProfile.schools addObject:newSchool];
        [ssp setProfile:proProfile];
        
        school[@"name"] = _name;
        school[@"year"] = _year;
        school[@"type"] = type;
        school[@"isShowing"] = [NSNumber numberWithBool:newSchool.isShowing];
        [school saveEventually];
        
        //get the main database
        MainDatabase* md = [MainDatabase shared];
        [md.queue inDatabase:^(FMDatabase *db) {
            NSString *updateSQL = @"UPDATE school SET name = ?, type = ?, year = ?, is_showing = ? WHERE school_id = ?";
            NSArray* values = @[_name, type, _year, [NSNumber numberWithBool:!_checkMarkedRow], _school.school_id];
            [db executeUpdate:updateSQL withArgumentsInArray:values];
            _saveButton.enabled = YES;
            [_firstCell.activityIndicator stopAnimating];
            [self.navigationController popViewControllerAnimated:YES];
        }];
    }];
}

@end
