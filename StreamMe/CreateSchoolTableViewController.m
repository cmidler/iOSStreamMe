//
//  CreateSchoolTableViewController.m
//  Proximity
//
//  Created by Chase Midler on 1/16/15.
//  Copyright (c) 2015 midler. All rights reserved.
//

#import "CreateSchoolTableViewController.h"

@interface CreateSchoolTableViewController ()

@end

@implementation CreateSchoolTableViewController
@synthesize schoolTableView;
- (void)viewDidLoad {
    [super viewDidLoad];
    
    UITapGestureRecognizer *tap = [[UITapGestureRecognizer alloc]
                                   initWithTarget:self
                                   action:@selector(dismissKeyboard)];
    tap.cancelsTouchesInView = NO;
    [self.view addGestureRecognizer:tap];

    _name = @"";//going to begin first responder with this
    //default the year to this year
    NSDateFormatter *formatter = [[NSDateFormatter alloc] init];
    [formatter setDateFormat:@"yyyy"];
    _year = [formatter stringFromDate:[NSDate date]];
    _type = 0;//default to graduate school
    _checkMarkedRow = 0; //default to yes;
    
    [schoolTableView reloadData];
    
}


- (void) dismissKeyboard
{
    [self.schoolTableView endEditing:YES];
}

//Delegates for helping textview have placeholder text
- (void)textViewDidBeginEditing:(UITextView *)textView
{
    if([textView.text isEqualToString:@""] || [textView.text isEqualToString:@"Enter School Name"])
    {
        textView.text = @"";
        _name = textView.text;
    }
    textView.textColor = [UIColor blackColor];
    [textView becomeFirstResponder];
}

//Continuation delegate for placeholder text
- (void)textViewDidEndEditing:(UITextView *)textView
{
    //resign first responder
    if(textView.tag == 0 && ([textView.text isEqualToString:@""] || [textView.text isEqualToString:@"Enter School Name"]))
    {
        textView.text = @"Enter School Name";
        textView.textColor = [UIColor grayColor];
        _name = textView.text;
    }
    else if (textView.tag == 1 && [textView.text isEqualToString:@""])
    {
        NSDateFormatter *formatter = [[NSDateFormatter alloc] init];
        [formatter setDateFormat:@"yyyy"];
        textView.text = [formatter stringFromDate:[NSDate date]];
        _year = textView.text;
    }
    [textView resignFirstResponder];
    
}

-(void)textViewDidChange:(UITextView *)textView
{
    if(textView.tag == 0)
        _name = textView.text;
    else if (textView.tag == 1)
        _year = textView.text;
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
    if(([[textView text] length] - range.length + text.length > max_chars) && ![text isEqualToString:@"\n"])    {
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
    return 4;
}

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section {

    // Return the number of rows in the section.
    if(section < 2)
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
        default:
            break;
    }
    return sectionTitle;
}


- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath {
    CreateSchoolTableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:@"schoolCell" forIndexPath:indexPath];
    
    cell.separatorInset = UIEdgeInsetsZero;
    [cell.activityIndicator stopAnimating];
    cell.activityIndicator.center = cell.center;
    //get section 0 row 0
    if(!indexPath.section && !indexPath.row)
        _firstCell = cell;

    
    cell.schoolTextView.tag = indexPath.section;
    
    //go between different sections and populate the data
    switch (indexPath.section) {
        case 0:
            cell.schoolTextView.userInteractionEnabled = YES;
            cell.accessoryType = UITableViewCellAccessoryNone;
            
            if(!cell.schoolTextView.text.length)
                [cell.schoolTextView becomeFirstResponder];//if this is blank, make it first responder
            //check what the name is
            if([_name isEqualToString:@"Enter School Name"])
                cell.schoolTextView.textColor = [UIColor grayColor];
            else
                cell.schoolTextView.textColor = [UIColor blackColor];
            
            cell.schoolTextView.text = _name;
            break;
        case 1:
            cell.schoolTextView.userInteractionEnabled = YES;
            cell.accessoryType = UITableViewCellAccessoryNone;
            cell.schoolTextView.text = _year;
            break;
        case 2:
            cell.schoolTextView.userInteractionEnabled = NO;
            if(indexPath.row)
            {
                cell.schoolTextView.text = @"College";
                if(_type)
                    cell.accessoryType = UITableViewCellAccessoryCheckmark;
                else
                    cell.accessoryType = UITableViewCellAccessoryNone;
            }
            else
            {
                cell.schoolTextView.text = @"Graduate School";
                if(!_type)
                    cell.accessoryType = UITableViewCellAccessoryCheckmark;
                else
                    cell.accessoryType = UITableViewCellAccessoryNone;
            }
            break;
        case 3:
            cell.schoolTextView.userInteractionEnabled = NO;
            if(indexPath.row)
            {
                cell.schoolTextView.text = @"No";
                if(_checkMarkedRow)
                    cell.accessoryType = UITableViewCellAccessoryCheckmark;
                else
                    cell.accessoryType = UITableViewCellAccessoryNone;
            }
            else
            {
                cell.schoolTextView.text = @"Yes";
                if(!_checkMarkedRow)
                    cell.accessoryType = UITableViewCellAccessoryCheckmark;
                else
                    cell.accessoryType = UITableViewCellAccessoryNone;
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
    CreateSchoolTableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:@"schoolCell" forIndexPath:indexPath];
    
    
    switch (indexPath.section) {
        case 0:
            [cell setSelectionStyle:UITableViewCellSelectionStyleNone];
            [schoolTableView reloadSections:[NSIndexSet indexSetWithIndex: 0] withRowAnimation:UITableViewRowAnimationAutomatic];
            [cell.schoolTextView becomeFirstResponder];
            break;
        case 1:
            [cell setSelectionStyle:UITableViewCellSelectionStyleNone];
            [schoolTableView reloadSections:[NSIndexSet indexSetWithIndex: 1] withRowAnimation:UITableViewRowAnimationAutomatic];
            [cell.schoolTextView becomeFirstResponder];
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
        default:
            break;
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


- (IBAction)saveAction:(id)sender {
    
    _saveButton.enabled = NO;
    [_firstCell.activityIndicator startAnimating];
    
    //Convert type row to string
    NSString* type =@"";
    if(_type)
        type = @"College";
    else
        type = @"Graduate School";
    
    
    NSLog(@"name is %@ type is %@ year is %@", _name, type, _year);
    
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
    
    //making sure they aren't using the default text if they didn't enter a school
    if([_name isEqualToString:@"Enter School Name"])
    {
        UIAlertView* defaultAlert = [[UIAlertView alloc] initWithTitle:@"Cannot Have Empty Values"
                                                             message:@"Please make sure all fields are completed."
                                                            delegate:nil
                                                   cancelButtonTitle:@"ok"
                                                   otherButtonTitles:nil];
        [defaultAlert show];
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
    
    //make sure the year is between 1900 and 10 years from now
    if(_year.intValue <1900 || _year.intValue > 10+yearString.intValue)
    {
        [badYearAlert show];
        _saveButton.enabled = YES;
        [_firstCell.activityIndicator stopAnimating];
        return;
    }
    
    //Try to save data to database
    UIAlertView* errorAlert = [[UIAlertView alloc] initWithTitle:@"Something Went Wrong"
                                                         message:@"Could not save the data.  Please check your internet connection and try again."
                                                        delegate:nil
                                               cancelButtonTitle:@"ok"
                                               otherButtonTitles:nil];
    
    PFObject* school = [PFObject objectWithClassName:@"School"];
    school[@"name"] = _name;
    school[@"type"] = type;
    school[@"year"] = _year;
    school[@"isShowing"] = [NSNumber numberWithBool:!_checkMarkedRow];
    school[@"user"] = [PFUser currentUser];
    PFACL *defaultACL = [PFACL ACL];
    [defaultACL setReadAccess:true forUser:[PFUser currentUser]];
    [defaultACL setWriteAccess:true forUser:[PFUser currentUser]];
    [defaultACL setPublicReadAccess:false];
    [defaultACL setPublicWriteAccess:false];
    [school setACL:defaultACL];

    //Save the school to the backend
    if(![school save])
    {
        [errorAlert show];
        _saveButton.enabled = YES;
        [_firstCell.activityIndicator stopAnimating];
        return;

    }
    
    StoreProfessionalProfile* ssp = [StoreProfessionalProfile shared];
    ProfessionalProfile* profile = ssp.profile;
    
    //allocate a new school
    School* newSchool = [[School alloc] init];
    newSchool.school_id = school.objectId;
    newSchool.school_name = [school objectForKey:@"name"];
    newSchool.year = [school objectForKey:@"year"];
    newSchool.type = [school objectForKey:@"type"];
    newSchool.isShowing = ((NSNumber*)[school objectForKey:@"isShowing"]).boolValue;
    
    NSLog(@"school id is %@, name is %@, year is %@, type is %@, is showing is %d", newSchool.school_id, newSchool.school_name, newSchool.year, newSchool.type, newSchool.isShowing);
    
    //get the main database
    MainDatabase* md = [MainDatabase shared];
    [md.queue inDatabase:^(FMDatabase *db) {
        NSString *insertSQL = @"INSERT INTO school (NAME, TYPE, YEAR, USER_ID, IS_SHOWING, SCHOOL_ID) VALUES (?, ?, ?, ?, ?, ?)";
        NSArray* values = @[newSchool.school_name, newSchool.type, newSchool.year, [PFUser currentUser].objectId, [NSNumber numberWithInt:newSchool.isShowing], newSchool.school_id];
        [db executeUpdate:insertSQL withArgumentsInArray:values];
            
        //now add the new school to the professional profile
        [profile.schools addObject:newSchool];
        [ssp setProfile:profile];
        
        //cleanup
        _saveButton.enabled = YES;
        [_firstCell.activityIndicator stopAnimating];
        [self.navigationController popViewControllerAnimated:YES];
            
            
    }];

    
}
@end
