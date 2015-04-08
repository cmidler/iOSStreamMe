//
//  DegreeTableViewController.m
//  Proximity
//
//  Created by Chase Midler on 1/16/15.
//  Copyright (c) 2015 midler. All rights reserved.
//

#import "DegreeTableViewController.h"

@interface DegreeTableViewController ()

@end

@implementation DegreeTableViewController
@synthesize degreeTableView;
- (void)viewDidLoad {
    [super viewDidLoad];
    //initialize the name and if it is showing or not
    _lastEditedString = _degree[0];
    _checkMarkedRow = !((NSNumber*)_degree[1]).boolValue;
    
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


- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView {
    // Return the number of sections.
    return 3;
}

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section {

    // Return the number of rows in the section.
    if(section==1)
        return 2;
    else
        return 1;
}

//Get the title for each section
- (NSString *)tableView:(UITableView *)tableView titleForHeaderInSection:(NSInteger)section
{
    NSString* sectionTitle = @"";
    
    switch (section) {
        case 0:
            sectionTitle = @"Degree Name";
            break;
        case 1:
            sectionTitle = @"Share Degree Information";
            break;
        case 2:
            sectionTitle = @"Delete Degree";
            break;
        default:
            break;
    }
    return sectionTitle;
}


- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath {
    DegreeTableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:@"degreeCell" forIndexPath:indexPath];
    cell.separatorInset = UIEdgeInsetsZero;
    [cell.activityIndicator stopAnimating];
    cell.activityIndicator.center = cell.center;
    //get section 0 row 0
    if(!indexPath.section && !indexPath.row)
        _firstCell = cell;
    switch (indexPath.section) {
        case 0:
            cell.degreeTextView.userInteractionEnabled = YES;
            cell.accessoryType = UITableViewCellAccessoryNone;
            if(!cell.degreeTextView.text.length)
            {
                [cell.degreeTextView becomeFirstResponder];//if this is blank, make it first responder
            }
            cell.degreeTextView.text = _lastEditedString;
            break;
        case 1:
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
            break;
        case 2:
            cell.degreeTextView.userInteractionEnabled = NO;
            cell.accessoryType = UITableViewCellAccessoryNone;
            cell.degreeTextView.text = @"Delete Degree";
            break;
        default:
            cell.accessoryType = UITableViewCellAccessoryNone;
            NSLog(@"getting to default");
            break;

    }
    
    return cell;
}

- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath
{
    DegreeTableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:@"degreeCell" forIndexPath:indexPath];
    
    
    switch (indexPath.section) {
        case 0:
            [cell setSelectionStyle:UITableViewCellSelectionStyleNone];
            [degreeTableView reloadSections:[NSIndexSet indexSetWithIndex: 0] withRowAnimation:UITableViewRowAnimationAutomatic];
            [cell.degreeTextView becomeFirstResponder];
            break;
        case 1:
            [cell setSelectionStyle:UITableViewCellSelectionStyleDefault];
            _checkMarkedRow = (int)indexPath.row;
            [degreeTableView reloadSections:[NSIndexSet indexSetWithIndex: 1] withRowAnimation:UITableViewRowAnimationAutomatic];
            break;
        case 2:
            [cell setSelectionStyle:UITableViewCellSelectionStyleNone];
            [degreeTableView reloadSections:[NSIndexSet indexSetWithIndex: 2] withRowAnimation:UITableViewRowAnimationAutomatic];
            [self deleteAction];
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

//do a confirmation
- (void) deleteAction
{
    UIAlertController *newAlertController = [UIAlertController
                                             alertControllerWithTitle:@"Warning"
                                             message:@"About to delete degree information."
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
        NSLog(@"Delete the degree");
        
        
        
        
        PFQuery* degreeQuery = [PFQuery queryWithClassName:@"Degree"];
        [degreeQuery whereKey:@"objectId" equalTo:_degree[2]];
        [degreeQuery findObjectsInBackgroundWithBlock:^(NSArray *objects, NSError *error) {
            //error checking
            if(error)
            {
                [self.navigationController popViewControllerAnimated:YES];
                return;
            }
            
            for(PFObject* degree in objects)
                [degree deleteEventually];
            
            //delete from storedprofessionalprofile as well
            StoreProfessionalProfile* ssp = [StoreProfessionalProfile shared];
            ProfessionalProfile* profile = ssp.profile;
            
            //out with the old
            School* newSchool = [[School alloc] init];
            newSchool.school_name = _school.school_name;
            newSchool.type = _school.type;
            newSchool.year = _school.year;
            newSchool.school_id = _school.school_id;
            newSchool.isShowing = _school.isShowing;
            newSchool.degrees = _school.degrees;
            [newSchool.degrees removeObject:_degree];
            
            for(School* s in profile.schools)
                if([s.school_id isEqualToString:_school.school_id])
                {
                    [profile.schools removeObject:s];
                    break;
                }
            
            [profile.schools addObject:newSchool];
            [ssp setProfile:profile];

            //get the main database
            MainDatabase* md = [MainDatabase shared];
            [md.queue inDatabase:^(FMDatabase *db) {
                //delete degree
                NSString *deleteDegreesSQL = @"DELETE FROM degree WHERE degree_id = ?";
                NSArray* values = @[_degree[2]];
                [db executeUpdate:deleteDegreesSQL withArgumentsInArray:values];
                [self.navigationController popViewControllerAnimated:YES];
            }];
        }];
        
    }];
    [newAlertController addAction:deleteAction];
    [newAlertController addAction:cancelAction];
    [self presentViewController:newAlertController animated:YES completion:nil];
    return;
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
    
    //if the values haven't changed, just pop the controller
    if([_lastEditedString isEqualToString:_degree[0]] && !_checkMarkedRow == ((NSNumber*)_degree[1]).boolValue)
    {
        _saveButton.enabled = YES;
        [_firstCell.activityIndicator stopAnimating];
        [self.navigationController popViewControllerAnimated:YES];
        return;
    }
    
    //Otherwise we have to actually save the data.
    StoreProfessionalProfile* ssp = [StoreProfessionalProfile shared];
    ProfessionalProfile* proProfile = ssp.profile;
    
    //allocate a new degree
    NSArray* newDegree = @[_lastEditedString, [NSNumber numberWithBool:!_checkMarkedRow], _degree[2]];
    
    PFQuery *query = [PFQuery queryWithClassName:@"Degree"];
    
    // Retrieve the object by id
    [query getObjectInBackgroundWithId:_degree[2] block:^(PFObject *degree, NSError *error) {
        
        //error check
        if(error)
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
        School* newSchool = [[School alloc] init];
        newSchool.school_name = _school.school_name;
        newSchool.type = _school.type;
        newSchool.year = _school.year;
        newSchool.school_id = _school.school_id;
        newSchool.isShowing = _school.isShowing;
        newSchool.degrees = [NSMutableArray arrayWithArray:_school.degrees];
        for(NSArray* d in newSchool.degrees)
            if([d[2] isEqualToString:_degree[2]])
            {
                [newSchool.degrees removeObject:d];
                break;
            }
        [newSchool.degrees removeObject:_degree];
        [newSchool.degrees addObject:newDegree];
        
        
        for(School* s in proProfile.schools)
            if([s.school_id isEqualToString:_school.school_id])
            {
                [proProfile.schools removeObject:s];
                break;
            }
        
        [proProfile.schools addObject:newSchool];
        [ssp setProfile:proProfile];
        degree[@"name"] = _lastEditedString;
        degree[@"isShowing"] = [NSNumber numberWithBool:!_checkMarkedRow];
        [degree saveEventually];
        
        //get the main database
        MainDatabase* md = [MainDatabase shared];
        [md.queue inDatabase:^(FMDatabase *db) {
            NSString *updateSQL = @"UPDATE degree SET name = ?, is_showing = ? WHERE degree_id = ?";
            NSArray* values = @[_lastEditedString, [NSNumber numberWithInt:!_checkMarkedRow], _degree[2]];
            [db executeUpdate:updateSQL withArgumentsInArray:values];
            _saveButton.enabled = YES;
            [_firstCell.activityIndicator stopAnimating];
            [self.navigationController popViewControllerAnimated:YES];
        }];
    }];

}
@end
