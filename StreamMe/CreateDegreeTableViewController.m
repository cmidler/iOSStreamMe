//
//  CreateDegreeTableViewController.m
//  Proximity
//
//  Created by Chase Midler on 1/16/15.
//  Copyright (c) 2015 midler. All rights reserved.
//

#import "CreateDegreeTableViewController.h"

@interface CreateDegreeTableViewController ()

@end

@implementation CreateDegreeTableViewController
@synthesize degreeTableView;
- (void)viewDidLoad {
    [super viewDidLoad];
    
    //initialize the name and if it is showing or not
    _lastEditedString = @"";
    _checkMarkedRow = 0;
    
    UITapGestureRecognizer *tap = [[UITapGestureRecognizer alloc]
                                   initWithTarget:self
                                   action:@selector(dismissKeyboard)];
    tap.cancelsTouchesInView = NO;
    [self.view addGestureRecognizer:tap];
    
}

- (void) dismissKeyboard
{
    [self.degreeTableView endEditing:YES];
}

//Delegates for helping textview have placeholder text
- (void)textViewDidBeginEditing:(UITextView *)textView
{
    if([textView.text isEqualToString:@"Enter Degree Name"])
    {
        textView.text = @"";
    }
    textView.textColor = [UIColor blackColor];

    [textView becomeFirstResponder];
}


-(void)textViewDidChange:(UITextView *)textView
{
    _lastEditedString = textView.text;
}


//used for updating status
- (BOOL)textView:(UITextView *)textView
shouldChangeTextInRange:(NSRange)range
 replacementText:(NSString *)text
{
    //check if they user is trying to enter too many characters
    if(([[textView text] length] - range.length + text.length > MAX_DEGREE_CHARS) && ![text isEqualToString:@"\n"])
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

//Continuation delegate for placeholder text
- (void)textViewDidEndEditing:(UITextView *)textView
{
    //resign first responder
    if([textView.text isEqualToString:@""] || [textView.text isEqualToString:@"Enter Degree Name"])
    {
        textView.text = @"Enter Degree Name";
        textView.textColor = [UIColor grayColor];
    }
    [textView resignFirstResponder];

}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

#pragma mark - Table view data source

- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView {
    // Return the number of sections.
    return 2;
}

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section {
    if(section)
        return 2;
    else
        return 1;
}

//Get the title for each section
- (NSString *)tableView:(UITableView *)tableView titleForHeaderInSection:(NSInteger)section
{
    
    if(section)
        return @"Share Degree Information";
    else
        return @"Degree Name";

}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath {
    CreateDegreeTableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:@"degreeCell" forIndexPath:indexPath];
    cell.separatorInset = UIEdgeInsetsZero;
    
    cell.separatorInset = UIEdgeInsetsZero;
    [cell.activityIndicator stopAnimating];
    cell.activityIndicator.center = cell.center;
    //get section 0 row 0
    if(!indexPath.section && !indexPath.row)
        _firstCell = cell;
    
    if(indexPath.section)
    {
        cell.degreeTextView.userInteractionEnabled = NO;
        if(indexPath.row)
        {
            cell.degreeTextView.text = @"No";
            if(_checkMarkedRow)
                cell.accessoryType = UITableViewCellAccessoryCheckmark;
            else
                cell.accessoryType = UITableViewCellAccessoryNone;
        }
        else
        {
            cell.degreeTextView.text = @"Yes";
            if(!_checkMarkedRow)
                cell.accessoryType = UITableViewCellAccessoryCheckmark;
            else
                cell.accessoryType = UITableViewCellAccessoryNone;
        }
    }
    else
    {
        cell.degreeTextView.userInteractionEnabled = YES;
        cell.accessoryType = UITableViewCellAccessoryNone;
        if(!cell.degreeTextView.text.length)
        {
            [cell.degreeTextView becomeFirstResponder];//if this is blank, make it first responder
        }
        cell.degreeTextView.text = _lastEditedString;
        if([_lastEditedString isEqualToString:@"Enter Degree Name"])
            cell.degreeTextView.textColor = [UIColor grayColor];
        else
            cell.degreeTextView.textColor = [UIColor blackColor];
        
    }
    
    return cell;
}

- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath
{
    CreateDegreeTableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:@"degreeCell" forIndexPath:indexPath];
    
    if(indexPath.section)
    {
        [cell setSelectionStyle:UITableViewCellSelectionStyleDefault];
        _checkMarkedRow = (int)indexPath.row;
        [degreeTableView reloadSections:[NSIndexSet indexSetWithIndex: 1] withRowAnimation:UITableViewRowAnimationAutomatic];
    }
    else
    {
        [cell setSelectionStyle:UITableViewCellSelectionStyleNone];
        [degreeTableView reloadSections:[NSIndexSet indexSetWithIndex: 0] withRowAnimation:UITableViewRowAnimationAutomatic];
        [cell.degreeTextView becomeFirstResponder];
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


//save the degree
- (IBAction)saveAction:(id)sender {
    _saveButton.enabled = NO;
    [_firstCell.activityIndicator startAnimating];
    
    //can't have empty values
    if(!_lastEditedString || !_lastEditedString.length)
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
    
    UIAlertView* errorAlert = [[UIAlertView alloc] initWithTitle:@"Something Went Wrong"
                                                         message:@"Could not save the data.  Please check your internet connection and try again."
                                                        delegate:nil
                                               cancelButtonTitle:@"ok"
                                               otherButtonTitles:nil];
    
    //get the correct school to get the object to save
    PFQuery* schoolQuery = [PFQuery queryWithClassName:@"School"];
    [schoolQuery whereKey:@"objectId" equalTo:_school.school_id];
    [schoolQuery findObjectsInBackgroundWithBlock:^(NSArray *objects, NSError *error) {
        if(error)
        {
            [errorAlert show];
            _saveButton.enabled = YES;
            [_firstCell.activityIndicator stopAnimating];
            return;
        }
        
        //first object back is the school we will worry about
        PFObject* school = objects[0];
        PFObject* degree = [PFObject objectWithClassName:@"Degree"];
        degree[@"name"] = _lastEditedString;
        degree[@"isShowing"] = [NSNumber numberWithBool:!_checkMarkedRow];
        degree[@"school"] = school;
        PFACL *defaultACL = [PFACL ACL];
        [defaultACL setReadAccess:true forUser:[PFUser currentUser]];
        [defaultACL setWriteAccess:true forUser:[PFUser currentUser]];
        [defaultACL setPublicReadAccess:false];
        [defaultACL setPublicWriteAccess:false];
        [degree setACL:defaultACL];
        if(![degree save])
        {
            [errorAlert show];
            _saveButton.enabled = YES;
            [_firstCell.activityIndicator stopAnimating];
            return;
        }
        
        //get the main database
        MainDatabase* md = [MainDatabase shared];
        [md.queue inDatabase:^(FMDatabase *db) {
            
            StoreProfessionalProfile* ssp = [StoreProfessionalProfile shared];
            ProfessionalProfile* profile = ssp.profile;
            
            //delete degrees first
            NSString *degreesSQL = @"INSERT INTO degree (name, school_id, user_id, is_showing, degree_id) VALUES (?, ?, ?, ?, ?)";
            NSArray* values = @[[degree objectForKey:@"name"], _school.school_id, profile.user_id, [degree objectForKey:@"isShowing"], degree.objectId];
            [db executeUpdate:degreesSQL withArgumentsInArray:values];
            
            NSLog(@"inserted the degrees!");
            
            //out with the old
            School* newSchool = [[School alloc] init];
            newSchool.school_name = _school.school_name;
            newSchool.type = _school.type;
            newSchool.year = _school.year;
            newSchool.school_id = _school.school_id;
            newSchool.isShowing = _school.isShowing;
            newSchool.degrees = [NSMutableArray arrayWithArray:_school.degrees];
            [newSchool.degrees addObject:@[[degree objectForKey:@"name"], [degree objectForKey:@"isShowing"], degree.objectId]];
            [profile.schools removeObject:_school];
            [profile.schools addObject:newSchool];
            [ssp setProfile:profile];
            
            //cleanup
            _saveButton.enabled = YES;
            [_firstCell.activityIndicator stopAnimating];
            [self.navigationController popViewControllerAnimated:YES];
            return;

        }];

    }];
        
}
@end
