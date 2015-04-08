//
//  FilterViewController.m
//  genesis
//
//  Created by Chase Midler on 10/2/14.
//  Copyright (c) 2014 midler. All rights reserved.
//

#import "FilterViewController.h"

@interface FilterViewController ()

@end

@implementation FilterViewController
@synthesize filterTableView;
- (void)viewDidLoad {
    [super viewDidLoad];
    self.automaticallyAdjustsScrollViewInsets = NO;
    // This will remove extra separators from tableview
    self.filterTableView.tableFooterView = [[UIView alloc] initWithFrame:CGRectZero];
    _pickerViewShown = NO;
    filters = @[@"Gender", @"Events"];
    options = [[NSMutableArray alloc] init];
    StoreSexFilter* ssf = [StoreSexFilter shared];
    _sexFilter = ssf.sex_filter;
    [filterTableView reloadData];
}

-(void) viewWillAppear:(BOOL)animated
{
    _toolBar.hidden = YES;
    _toolBar = nil;
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView
{
    // Return the number of sections.
    return filters.count;
}

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section
{
    
    // Return the number of rows in the section.
    if(_pickerViewShown && _pickerViewSection == section)
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
            sectionTitle = @"Gender Filter";
            break;
        case 1:
            sectionTitle = @"Event Filter";
            break;
        default:
            break;
    }
    return sectionTitle;
}

//Show data in cells
- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath
{
    
    static NSString *CellIdentifier = @"editCell";
    FilterTableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:CellIdentifier forIndexPath:indexPath];
    cell.separatorInset = UIEdgeInsetsZero;
    //make all of the cell fields hidden (only set them not hidden when it is that cell)
    cell.filterLabel.hidden = YES;
    cell.dropDownImageView.hidden = YES;
    cell.pickerView.hidden = YES;
    cell.accessoryType = UITableViewCellAccessoryNone;
    
    //by sections
    switch (indexPath.section) {
        case 0:
            if(indexPath.row)
            {
                cell.pickerView.hidden = NO;
                _toolBar.hidden = YES;
                _toolBar = nil;
                // add a toolbar with Cancel & Done button
                _toolBar = [[UIToolbar alloc] initWithFrame:CGRectMake(0, 0, 320, 64)];
                
                UIBarButtonItem *doneButton = [[UIBarButtonItem alloc] initWithBarButtonSystemItem:UIBarButtonSystemItemDone target:self action:@selector(doneTouched:)];
                UIBarButtonItem *cancelButton = [[UIBarButtonItem alloc] initWithBarButtonSystemItem:UIBarButtonSystemItemCancel target:self action:@selector(cancelTouched:)];
                
                // the middle button is to make the Done button align to right
                [_toolBar setItems:[NSArray arrayWithObjects:cancelButton, [[UIBarButtonItem alloc] initWithBarButtonSystemItem:UIBarButtonSystemItemFlexibleSpace target:nil action:nil], doneButton, nil]];
                
                cell.inputAccessoryView = _toolBar;
                [cell.pickerView selectRow:0 inComponent:0 animated:NO];
                [_toolBar removeFromSuperview];
                [cell addSubview:_toolBar];

            }
            else
            {
                cell.filterLabel.hidden = NO;
                if(!_pickerViewShown || _pickerViewSection)
                    cell.dropDownImageView.hidden = NO;
                cell.filterLabel.text = _sexFilter;
            }
            break;
        case 1:
            if(indexPath.row)
            {
                cell.pickerView.hidden = NO;
            }
            else
            {
                cell.filterLabel.hidden = NO;
                if(!_pickerViewShown || !_pickerViewSection)
                    cell.dropDownImageView.hidden = NO;
                cell.filterLabel.text = _eventFilter;
            }
            break;
        default:
            break;
    }
    /*
    
    if(indexPath.row == _selectedCell)
    {
        cell.accessoryType = UITableViewCellAccessoryCheckmark;
    }
    else
    {
        cell.accessoryType = UITableViewCellAccessoryNone;
    }
    if([sexFilterOptions[indexPath.row] isEqualToString:@"All"])
        cell.sexFilterLabel.text = [NSString stringWithFormat:@"Show %@", sexFilterOptions[indexPath.row]];
    else
        cell.sexFilterLabel.text = [NSString stringWithFormat:@"Show %@s", sexFilterOptions[indexPath.row]];
     */
    return cell;
}

//On click of cell, segue
- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath
{
    UITableViewCell *cell = [tableView cellForRowAtIndexPath:indexPath];
    [cell setSelectionStyle:UITableViewCellSelectionStyleGray];
    //by sections
    switch (indexPath.section) {
        case 0:
            if(!indexPath.row)
            {
                _pickerViewSection = 0;
                _pickerViewShown = 1;
                options = [NSMutableArray arrayWithArray: @[@"Show All", @"Show Males", @"Show Females"]];
            }
            break;
        case 1:
            if(!indexPath.row)
            {
                [options removeAllObjects];
                [options addObject:@"No Event Filter"];
                //need to populate the events they can select from
                //get the main database
                MainDatabase* md = [MainDatabase shared];
                [md.queue inDatabase:^(FMDatabase *db) {
                    NSString *eventQuery = @"SELECT EVENT_UUID, EVENT_TITLE FROM EVENT WHERE IS_SUBSCRIBED = ? AND MARKED_FOR_DELETE = ?";
                    NSArray* values = @[[NSNumber numberWithInt:1], [NSNumber numberWithInt:0]];
                    FMResultSet* eventSet = [db executeQuery:eventQuery withArgumentsInArray:values];
                    //Loop through all the returned rows and get the corresponding event data
                    while( [eventSet next] )
                    {
                        NSString* uuid = [eventSet stringForColumnIndex:0];
                        NSString* title = [eventSet stringForColumnIndex:1];
                        [options addObject:[NSString stringWithFormat:@"%@ - %@,",title, uuid]];
                    }
                    _pickerViewSection = 1;
                    _pickerViewShown = 1;
                    
                }];
            }
            break;
        default:
            break;
    }
    [filterTableView reloadData];
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
    NSLog(@"the option for picker view is %@", options[row]);
    return options[row];
}


- (CGFloat)tableView:(UITableView*)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath
{
    //if no picker view shown, make the table height be the default height
    if(!_pickerViewShown)
    {
        return TOOLBAR_HEIGHT;
    }
    
    //picker view is shown  it means we have to see if the row is the picker view or not
    if(indexPath.section == _pickerViewSection)
    {
        if(indexPath.row)
            return PICKER_HEIGHT;
        else
            return TOOLBAR_HEIGHT;
    }
    else
        return TOOLBAR_HEIGHT;
    
}

//handle cancel button touched in pickerView
- (void)cancelTouched:(UIBarButtonItem *)sender
{
    NSLog(@"Cancel button touched");
    [self.filterTableView resignFirstResponder];
    _pickerViewShown = NO;
    _toolBar.hidden = YES;
    _toolBar = nil;
    _pickerSelection = @"";
    [filterTableView reloadData];
}

//handle done button touched in pickerview
- (void)doneTouched:(UIBarButtonItem *)sender
{
    NSLog(@"Done Button touched");
    [self.filterTableView resignFirstResponder];
    _pickerViewShown = NO;
    _toolBar.hidden = YES;
    _toolBar = nil;
    
    if(!_pickerSelection || !_pickerSelection.length)
    {
        _pickerSelection = options[0];
    }
    
    //need to get the selection
    switch (_pickerViewSection) {
        //GENDER
        case 0:
            //don't have the show or space in the string
            _pickerSelection = [_pickerSelection substringFromIndex:5];
            _sexFilter = _pickerSelection;
            break;
        //Event Filter
        case 1:
            _eventFilter = _pickerSelection;
            break;
        default:
            break;
    }
    _pickerSelection = @"";
    
    [filterTableView reloadData];
}

- (IBAction)saveAction:(id)sender {
    
    //Store sex filter
    /*StoreSexFilter* ssf = [StoreSexFilter shared];
    [ssf setSex_filter:sexFilterOptions[_selectedCell]];
    
    PFUser* user = [PFUser currentUser];
    
    [user setObject:ssf.sex_filter forKey:@"sex_filter"];
    [user saveInBackground];
    
    [[NSNotificationCenter defaultCenter] postNotificationName:@"reloadSection" object:self];
    
    //SQL DB Stuff
    NSString *docsDir;
    NSArray *dirPaths;
    
    // Get the documents directory
    dirPaths = NSSearchPathForDirectoriesInDomains(NSDocumentDirectory, NSUserDomainMask, YES);
    docsDir = dirPaths[0];
    
    // Build the path to the database file
    NSString* databasePath = [[NSString alloc]
                              initWithString: [docsDir stringByAppendingPathComponent:@"proximity.db"]];
    sqlite3_stmt    *statement;
    sqlite3 *proximityDB;
    const char *dbpath = [databasePath UTF8String];
    
    if (sqlite3_open(dbpath, &proximityDB) == SQLITE_OK)
    {
        NSString *updateSQL = [NSString stringWithFormat:@"UPDATE user SET sex_filter = \"%@\" WHERE is_me = 1", ssf.sex_filter];
        
        const char *insert_stmt = [updateSQL UTF8String];
        sqlite3_prepare_v2(proximityDB, insert_stmt,
                           -1, &statement, NULL);
        if (sqlite3_step(statement) == SQLITE_DONE)
        {
            NSLog(@"added values to sqlite database");
        } else
        {
            NSLog(@"Failed to add user");
        }
        sqlite3_finalize(statement);
        sqlite3_close(proximityDB);
    }
    else
        NSLog(@"Failed to update sqlite");
    
    [self.navigationController popViewControllerAnimated:YES];*/
    
}

@end
