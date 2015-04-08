//
//  EditProfessionalProfileTableViewController.m
//  Proximity
//
//  Created by Chase Midler on 1/15/15.
//  Copyright (c) 2015 midler. All rights reserved.
//

#import "EditProfessionalProfileTableViewController.h"

@interface EditProfessionalProfileTableViewController ()

@end

@implementation EditProfessionalProfileTableViewController
@synthesize editTableView;
- (void)viewDidLoad {
    [super viewDidLoad];
    self.editTableView.tableFooterView = [[UIView alloc] initWithFrame:CGRectZero];
    
}

- (void) viewWillAppear:(BOOL)animated
{
    [self loadTable];
}

//helper method for loading table data
- (void) loadTable
{
    StoreProfessionalProfile* ssp = [StoreProfessionalProfile shared];
    if(ssp.profile.isShowing)
        _checkMarkedRow = 2;
    else
        _checkMarkedRow = 3;
    editFields = @[@"Schools", @"Work", @"Share Professional Details", @"Don't Share Professional Details"];
    [editTableView reloadData];
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

    // Return the number of rows in the section.
    return [editFields count];
}


- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath {
    EditProfessionalProfileTableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:@"editCell" forIndexPath:indexPath];
    cell.separatorInset = UIEdgeInsetsZero;
    
    [cell.activityIndicator stopAnimating];
    cell.activityIndicator.center = cell.center;
    //get section 0 row 0
    if(!indexPath.section && !indexPath.row)
        _firstCell = cell;
    
    cell.fieldLabel.text = editFields[indexPath.row];
    switch(indexPath.row)
    {
        case 0:
            cell.accessoryType = UITableViewCellAccessoryDisclosureIndicator;
            break;
        case 1:
            cell.accessoryType = UITableViewCellAccessoryDisclosureIndicator;
            break;
        case 2:
            if(_checkMarkedRow == 2)
                cell.accessoryType = UITableViewCellAccessoryCheckmark;
            else
                cell.accessoryType = UITableViewCellAccessoryNone;
            break;
        case 3:
            if(_checkMarkedRow == 3)
                cell.accessoryType = UITableViewCellAccessoryCheckmark;
            else
                cell.accessoryType = UITableViewCellAccessoryNone;
            break;
    }
    
    return cell;
}

//On click of cell, segue
- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath
{
    UITableViewCell *cell = [tableView cellForRowAtIndexPath:indexPath];
    [cell setSelectionStyle:UITableViewCellSelectionStyleDefault];
    
    
    //Switch statement for segue to edit
    switch(indexPath.row)
    {
        case 0:
            [self performSegueWithIdentifier:@"editSchoolSegue" sender:self];
            break;
        case 1:
            [self performSegueWithIdentifier:@"editWorkSegue" sender:self];
            break;
        case 2:
            _checkMarkedRow = 2;
            [editTableView reloadData];
            break;
        case 3:
            _checkMarkedRow = 3;
            [editTableView reloadData];
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
    return 0.1f;
}


//Save if you are showing or not showing professional data
- (IBAction)saveAction:(id)sender {
    
    StoreProfessionalProfile* ssp = [StoreProfessionalProfile shared];
    //allow the segue, but don't save if the value is the same
    if((_checkMarkedRow == 2 && ssp.profile.isShowing) || (_checkMarkedRow == 3 && !ssp.profile.isShowing))
    {
        [self.navigationController popViewControllerAnimated:YES];
        return;
    }
    
    
    _saveButton.enabled = NO;
    [_firstCell.activityIndicator startAnimating];
    
    
    //Otherwise we have to actually save the data.
    PFUser* user = [PFUser currentUser];
    StoreUserProfile* sup = [StoreUserProfile shared];
    UserProfile* profile = sup.profile;
    ProfessionalProfile* proProfile = ssp.profile;
    
    //get the main database
    MainDatabase* md = [MainDatabase shared];
    [md.queue inDatabase:^(FMDatabase *db) {
        NSString *updateSQL = @"UPDATE user SET is_showing_professional = ? WHERE is_me = ?";
        NSArray* values = @[[NSNumber numberWithInt:!proProfile.isShowing],[NSNumber numberWithInt:1]];
        [db executeUpdate:updateSQL withArgumentsInArray:values];
        
        profile.isShowingProfessional = ssp.profile.isShowing = !ssp.profile.isShowing;
        [sup setProfile:profile];
        [ssp setProfile:proProfile];
        [user setObject:[NSNumber numberWithBool:proProfile.isShowing] forKey:@"isShowingProfessional"];
        [user saveEventually];
        
    
        _saveButton.enabled = YES;
        [_firstCell.activityIndicator stopAnimating];
        [self.navigationController popViewControllerAnimated:YES];
    }];
    
}
@end
