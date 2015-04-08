//
//  CreateWorkTableViewController.m
//  Proximity
//
//  Created by Chase Midler on 1/16/15.
//  Copyright (c) 2015 midler. All rights reserved.
//

#import "CreateWorkTableViewController.h"

@interface CreateWorkTableViewController ()

@end

@implementation CreateWorkTableViewController
@synthesize workTableView;
- (void)viewDidLoad {
    [super viewDidLoad];
    
    [super viewDidLoad];
    
    UITapGestureRecognizer *tap = [[UITapGestureRecognizer alloc]
                                   initWithTarget:self
                                   action:@selector(dismissKeyboard)];
    tap.cancelsTouchesInView = NO;
    [self.view addGestureRecognizer:tap];
    
    _name = @"";//going to begin first responder with this
    _position = @"Enter Company Position";
    //default the year to this year
    NSDateFormatter *formatter = [[NSDateFormatter alloc] init];
    [formatter setDateFormat:@"yyyy"];
    _end_date = [formatter stringFromDate:[NSDate date]];
    _isPresent = 1;//default to yes
    _checkMarkedRow = 0; //default to yes;
    [workTableView reloadData];
    
}


- (void) dismissKeyboard
{
    [self.workTableView endEditing:YES];
}

//Delegates for helping textview have placeholder text
- (void)textViewDidBeginEditing:(UITextView *)textView
{
    if(textView.tag == 0 && ([textView.text isEqualToString:@""] || [textView.text isEqualToString:@"Enter Company Name"]))
    {
        textView.text = @"";
        _name = textView.text;
    }
    else if( textView.tag == 1 && ([textView.text isEqualToString:@""] || [textView.text isEqualToString:@"Enter Company Position"]))
    {
        textView.text = @"";
        _position = textView.text;
    }
    textView.textColor = [UIColor blackColor];
    [textView becomeFirstResponder];
}

//Continuation delegate for placeholder text
- (void)textViewDidEndEditing:(UITextView *)textView
{
    //resign first responder
    if(textView.tag == 0 && ([textView.text isEqualToString:@""] || [textView.text isEqualToString:@"Enter Company Name"]))
    {
        textView.text = @"Enter Company Name";
        textView.textColor = [UIColor grayColor];
        _name = textView.text;
    }
    else if (textView.tag == 1 && ([textView.text isEqualToString:@""] || [textView.text isEqualToString:@"Enter Company Position"]))
    {
        textView.text = @"Enter Company Position";
        textView.textColor = [UIColor grayColor];
        _position = textView.text;
    }
    else if(textView.tag == 3)
    {
        _end_date = textView.text;
    }
    [textView resignFirstResponder];
    
}

-(void)textViewDidChange:(UITextView *)textView
{
    if(textView.tag == 0)
        _name = textView.text;
    else if (textView.tag == 1)
        _position = textView.text;
    else if (textView.tag == 3)
        _end_date = textView.text;
}


//used for updating status
- (BOOL)textView:(UITextView *)textView
shouldChangeTextInRange:(NSRange)range
 replacementText:(NSString *)text
{
    int max_chars = 0;
    //then we use the year max chars
    if(textView.tag == 3)
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
    return 5;
}

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section {
    // Return the number of rows in the section.
    if(section <4)
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
            sectionTitle = @"Company Name";
            break;
        case 1:
            sectionTitle = @"Company Position (Optional)";
            break;
        case 2:
            sectionTitle = @"Still Work Here (Check for Yes)";
            break;
        case 3:
            sectionTitle = @"Work End Year (Optional)";
            break;
        case 4:
            sectionTitle = @"Share Work Information";
            break;
        default:
            break;
    }
    return sectionTitle;
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath {
    CreateWorkTableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:@"workCell" forIndexPath:indexPath];
    cell.separatorInset = UIEdgeInsetsZero;
    
    [cell.activityIndicator stopAnimating];
    cell.activityIndicator.center = cell.center;
    //get section 0 row 0
    if(!indexPath.section && !indexPath.row)
        _firstCell = cell;
    
    cell.workTextView.tag = indexPath.section;
    cell.backgroundColor = [UIColor whiteColor];
    cell.workTextView.backgroundColor = [UIColor whiteColor];
    cell.workTextView.textColor = [UIColor blackColor];
    
    
    //go between different sections and populate the data
    switch (indexPath.section) {
        case 0:
            cell.workTextView.userInteractionEnabled = YES;
            cell.accessoryType = UITableViewCellAccessoryNone;
            cell.workTextView.text = _name;
            if(!_name.length)
                [cell.workTextView becomeFirstResponder];//if this is blank, make it first responder
            //check what the name is
            if([_name isEqualToString:@"Enter Company Name"])
                cell.workTextView.textColor = [UIColor grayColor];
            else
                cell.workTextView.textColor = [UIColor blackColor];
            break;
        case 1:
            cell.workTextView.userInteractionEnabled = YES;
            cell.accessoryType = UITableViewCellAccessoryNone;
            cell.workTextView.text = _position;
            //check what the position is
            if([_position isEqualToString:@"Enter Company Position"])
                cell.workTextView.textColor = [UIColor grayColor];
            else
                cell.workTextView.textColor = [UIColor blackColor];
            break;
        case 2:
            cell.workTextView.userInteractionEnabled = NO;
            cell.workTextView.text = @"Still Employed Here?";
            if(_isPresent)
                cell.accessoryType = UITableViewCellAccessoryCheckmark;
            else
                cell.accessoryType = UITableViewCellAccessoryNone;
            break;
        case 3:
            //Don't let the user edit the year if is present is checked
            if(_isPresent)
            {
                cell.userInteractionEnabled = NO;
                cell.workTextView.userInteractionEnabled = NO;
                cell.backgroundColor = [UIColor lightGrayColor];
                cell.workTextView.backgroundColor = [UIColor lightGrayColor];
            }
            else
            {
                cell.userInteractionEnabled = YES;
                cell.workTextView.userInteractionEnabled = YES;
                cell.backgroundColor = [UIColor whiteColor];
                cell.workTextView.backgroundColor = [UIColor whiteColor];
            }
            cell.workTextView.text = _end_date;
            cell.accessoryType = UITableViewCellAccessoryNone;
            break;
        case 4:
            cell.workTextView.userInteractionEnabled = NO;
            if(indexPath.row)
            {
                cell.workTextView.text = @"No";
                if(_checkMarkedRow)
                    cell.accessoryType = UITableViewCellAccessoryCheckmark;
                else
                    cell.accessoryType = UITableViewCellAccessoryNone;
            }
            else
            {
                cell.workTextView.text = @"Yes";
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
    CreateWorkTableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:@"workCell" forIndexPath:indexPath];
    
    
    //Switch case to see what happens when a section row is clicked
    switch (indexPath.section) {
        case 0:
            [cell setSelectionStyle:UITableViewCellSelectionStyleNone];
            [workTableView reloadSections:[NSIndexSet indexSetWithIndex: 0] withRowAnimation:UITableViewRowAnimationAutomatic];
            [cell.workTextView becomeFirstResponder];
            break;
        case 1:
            [cell setSelectionStyle:UITableViewCellSelectionStyleNone];
            [workTableView reloadSections:[NSIndexSet indexSetWithIndex: 1] withRowAnimation:UITableViewRowAnimationAutomatic];
            [cell.workTextView becomeFirstResponder];
            break;
        case 2:
            [cell setSelectionStyle:UITableViewCellSelectionStyleDefault];
            _isPresent = !_isPresent;
            //reload both this cell and the next
            [workTableView reloadSections:[NSIndexSet indexSetWithIndex: 2] withRowAnimation:UITableViewRowAnimationAutomatic];
            [workTableView reloadSections:[NSIndexSet indexSetWithIndex: 3] withRowAnimation:UITableViewRowAnimationAutomatic];
            break;
        case 3:
            [cell setSelectionStyle:UITableViewCellSelectionStyleNone];
            //allow that cell to be the first responder if isPresent isn't true
            if(!_isPresent)
                [cell.workTextView becomeFirstResponder];
            [workTableView reloadSections:[NSIndexSet indexSetWithIndex: 3] withRowAnimation:UITableViewRowAnimationAutomatic];
            break;
        case 4:
            [cell setSelectionStyle:UITableViewCellSelectionStyleDefault];
            _checkMarkedRow = (int)indexPath.row;
            [workTableView reloadSections:[NSIndexSet indexSetWithIndex: 4] withRowAnimation:UITableViewRowAnimationAutomatic];
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

//Save the work
- (IBAction)saveAction:(id)sender {
    _saveButton.enabled = NO;
    [_firstCell.activityIndicator startAnimating];
    //Convert year to proper format
    NSString* year =_end_date;
    if(_isPresent)
        year = @"Present";
    else if (!_end_date.length)
        year = @"Not Showing";
    
    //make sure position has a string value
    if(!_position.length || [_position isEqualToString:@"Enter Company Position"])
        _position = @"Not Showing";
    
    //can't have empty values
    if(!_name.length)
    {
        UIAlertView* emptyAlert = [[UIAlertView alloc] initWithTitle:@"Cannot Have Empty Value For Company Name"
                                                             message:@"Please make sure the company name is completed."
                                                            delegate:nil
                                                   cancelButtonTitle:@"ok"
                                                   otherButtonTitles:nil];
        [emptyAlert show];
        _saveButton.enabled = YES;
        [_firstCell.activityIndicator stopAnimating];
        return;
        
    }
    
    
    
    //see if I need to check the year format
    if(![year isEqualToString:@"Present"] && ![year isEqualToString:@"Not Showing"])
    {
        UIAlertView* badYearAlert = [[UIAlertView alloc] initWithTitle:@"Bad Year"
                                                               message:@"Please use a valid year value."
                                                              delegate:nil
                                                     cancelButtonTitle:@"ok"
                                                     otherButtonTitles:nil];
        
        NSDateFormatter *formatter = [[NSDateFormatter alloc] init];
        [formatter setDateFormat:@"yyyy"];
        NSString *yearString = [formatter stringFromDate:[NSDate date]];
        
        //make sure the year is between 1900 and this year
        if(year.intValue <1900 || year.intValue > yearString.intValue)
        {
            [badYearAlert show];
            _saveButton.enabled = YES;
            [_firstCell.activityIndicator stopAnimating];
            return;
        }
    }
    
    //Try to save data to database
    UIAlertView* errorAlert = [[UIAlertView alloc] initWithTitle:@"Something Went Wrong"
                                                         message:@"Could not save the data.  Please check your internet connection and try again."
                                                        delegate:nil
                                               cancelButtonTitle:@"ok"
                                               otherButtonTitles:nil];

    
    PFObject* work = [PFObject objectWithClassName:@"Work"];
    work[@"name"] = _name;
    work[@"position"] = _position;
    work[@"end_date"] = year;
    work[@"isShowing"] = [NSNumber numberWithBool:!_checkMarkedRow];
    work[@"user"] = [PFUser currentUser];
    PFACL *defaultACL = [PFACL ACL];
    [defaultACL setReadAccess:true forUser:[PFUser currentUser]];
    [defaultACL setWriteAccess:true forUser:[PFUser currentUser]];
    [defaultACL setPublicReadAccess:false];
    [defaultACL setPublicWriteAccess:false];
    [work setACL:defaultACL];
    
    //Save the work to the backend
    if(![work save])
    {
        [errorAlert show];
        _saveButton.enabled = YES;
        [_firstCell.activityIndicator stopAnimating];
        return;
        
    }

    //allocate a new work
    Work* newWork = [[Work alloc] init];
    newWork.work_id = work.objectId;
    newWork.employer_name = _name;
    newWork.end_date = year;
    newWork.position = _position;
    newWork.isShowing = !_checkMarkedRow;
    
    
    //Otherwise we have to actually save the data.
    StoreProfessionalProfile* ssp = [StoreProfessionalProfile shared];
    ProfessionalProfile* proProfile = ssp.profile;
    
    //get the main database
    MainDatabase* md = [MainDatabase shared];
    [md.queue inDatabase:^(FMDatabase *db) {
        NSString *updateSQL = @"INSERT INTO work (name, position, end_date, user_id, is_showing, work_id) VALUES (?, ?, ?, ?, ?, ?)";
        
        NSArray* values = @[_name, _position, year, [PFUser currentUser].objectId, [NSNumber numberWithInt:!_checkMarkedRow], newWork.work_id];
        [db executeUpdate:updateSQL withArgumentsInArray:values];
        //now add the new work to the professional profile
        [proProfile.works addObject:newWork];
        [ssp setProfile:proProfile];
        
        _saveButton.enabled = YES;
        [_firstCell.activityIndicator stopAnimating];
        [self.navigationController popViewControllerAnimated:YES];
            
    }];
}
@end
