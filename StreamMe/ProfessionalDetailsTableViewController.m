//
//  ProfessionalDetailsTableViewController.m
//  Proximity
//
//  Created by Chase Midler on 1/5/15.
//  Copyright (c) 2015 midler. All rights reserved.
//

#import "ProfessionalDetailsTableViewController.h"

@interface ProfessionalDetailsTableViewController ()

@end

@implementation ProfessionalDetailsTableViewController
@synthesize professionalTableView;
- (void)viewDidLoad {
    [super viewDidLoad];
    
    // This will remove extra separators from tableview
    self.tableView.tableFooterView = [[UIView alloc] initWithFrame:CGRectZero];
    
    //Adding pull to refresh
    if(!_isMyProfile)
    {
        self.refreshControl = [[UIRefreshControl alloc] init];
        [self.refreshControl addTarget:self
                                action:@selector(pullToRefresh)
                      forControlEvents:UIControlEventValueChanged];
    }
    
    //NSLog(@"profile is complete is %d and ismyprofile is %d with user_id = %@ and is showing = %d", _proProfile.isComplete, _isMyProfile, _user_id, _isShowing);

    
    //if we have to grab data from the internet
    if((!_proProfile || !_proProfile.isComplete) && !_isMyProfile)
    {
        _proProfile = [[ProfessionalProfile alloc] init];
        _proProfile.user_id = _user_id;
        _proProfile.isShowing = _isShowing;
        [self.refreshControl beginRefreshing];
        [professionalTableView setContentOffset:CGPointMake(0, -self.refreshControl.frame.size.height) animated:YES];
        [self pullToRefresh];
    }
    
}

-(void) viewWillAppear:(BOOL)animated
{
    [self setUp];
}

//helper to grab data from backend database
-(void) pullToRefresh
{
    NSLog(@"is showing is %d", _isShowing);
    
    //don't refresh if it is me
    if(_isMyProfile || !_isShowing)
    {
        [self.refreshControl endRefreshing];
        return;
    }
    
    
    //if there is an error then show an alert
    UIAlertView* errorAlert = [[UIAlertView alloc] initWithTitle:@"Cannot Get User Data"
                                                         message:@"An error occurred while trying access the user's data.  Please check your internet connection and try again."
                                                        delegate:nil
                                               cancelButtonTitle:@"ok"
                                               otherButtonTitles:nil];
    
    
    //get the user's work and school information from parse
    [PFCloud callFunctionInBackground:@"getUserWork" withParameters:@{@"user_id": _user_id} block:^(id object, NSError *error) {
        
        //if an error and we don't have a complete profile show the alert
        if(error && (!_proProfile || !_proProfile.isComplete))
        {
            [errorAlert show];
            //Stop the refreshing action
            [self.refreshControl endRefreshing];
            [self setUp];
        }
        
        //Save the works array
        //object is a JSON array of works
        NSError *e;
        NSArray* worksArray = nil;
        
        //NSLog(@"work object %@ is of type %@",object, NSStringFromClass([object class]));
       
        //if it is a null class then it is empty json
        if(object &&![object isKindOfClass:[NSNull class]])
            worksArray= [NSJSONSerialization JSONObjectWithData:[object dataUsingEncoding:NSUTF8StringEncoding] options:NSJSONReadingAllowFragments error:&e];
        
        [PFCloud callFunctionInBackground:@"getUserSchool" withParameters:@{@"user_id": _user_id} block:^(id object, NSError *error) {
            
            //if an error and we don't have a complete profile show the alert
            if(error && (!_proProfile || !_proProfile.isComplete))
            {
                [errorAlert show];
                //Stop the refreshing action
                [self.refreshControl endRefreshing];
                [self setUp];
            }
            
            //object is a JSON array of schools
            NSError *e;
            NSArray* schoolsArray = nil;
            //NSLog(@"school object %@ is of type array %@",object, NSStringFromClass([object class]));
            //if it is a null class then it is empty json
            if(object && ![object isKindOfClass:[NSNull class]])
                schoolsArray = [NSJSONSerialization JSONObjectWithData:[object dataUsingEncoding:NSUTF8StringEncoding] options:NSJSONReadingAllowFragments error:&e];
            
            
            //if schools or works array has objects, empty them
            if([_proProfile.schools count])
                [_proProfile.schools removeAllObjects];
            if([_proProfile.works count])
                [_proProfile.works removeAllObjects];
            
            //loop through the school objects
            for(NSDictionary* school in schoolsArray)
            {
                School* newSchool = [[School alloc] init];
                newSchool.school_name = school[@"name"];
                newSchool.year = school[@"year"];
                newSchool.type = school[@"type"];
                newSchool.isShowing = ((NSNumber*)school[@"isShowing"]).boolValue;
                NSArray* degrees = school[@"degrees"];
                
                for(NSArray* degree in degrees)
                {
                    if(![degree count])
                        continue;
                    NSDictionary* dict = degree[0];
                    NSString* degreeName = dict[@"name"];
                    NSNumber* isShowing = dict[@"isShowing"];
                    [newSchool.degrees addObject:@[degreeName, isShowing]];
                }
                [_proProfile.schools addObject:newSchool];
            }
            
            NSLog(@"before work array");
            //Loop through work objects
            for(NSDictionary* work in worksArray)
            {
                Work* newWork = [[Work alloc] init];
                newWork.employer_name = work[@"name"];
                newWork.position = work[@"position"];
                newWork.end_date = work[@"end_date"];
                newWork.isShowing = ((NSNumber*)work[@"isShowing"]).boolValue;
                [_proProfile.works addObject:newWork];
            }
            
            _proProfile.isComplete = YES;
            
            //Stop the refreshing action
            [self.refreshControl endRefreshing];
            [self setUp];
        }];
    }];
}

//Helper function to setup a few variables for displaying professional information
-(void) setUp
{
    NSMutableArray* tmpSchools = [[NSMutableArray alloc]init];
    NSMutableArray* tmpWorks = [[NSMutableArray alloc]init];
    
    //set counts to 0 if we aren't showing anything
    if(!_proProfile.isShowing)
    {
        _workShowingCount = _schoolShowingCount = 0;
        schools = nil;
        works = nil;
        [professionalTableView reloadData];
        return;
    }
    
    //Counting the number of schools and works to be displayed
    for(School* s in _proProfile.schools)
    {
        if(s.isShowing)
            [tmpSchools addObject:s];
    }
    
    _schoolShowingCount = (int)[tmpSchools count];
    //counting work showing
    for(Work* w in _proProfile.works)
    {
        if(w.isShowing)
           [tmpWorks addObject:w];
    }
    _workShowingCount = (int)[tmpWorks count];
    
    //Now sort the schools based on year
    schools = [tmpSchools sortedArrayUsingComparator: ^(School* obj1, School* obj2) {
        
        if (obj1.year.intValue > obj2.year.intValue) {
            
            return (NSComparisonResult)NSOrderedAscending;
        }
        if (obj1.year.intValue < obj2.year.intValue) {
            
            return (NSComparisonResult)NSOrderedDescending;
        }
        
        //same ordering, try college vs graduate school
        if([obj1.type isEqualToString:@"Graduate School"] && [obj2.type isEqualToString:@"College"])
            return (NSComparisonResult)NSOrderedAscending;
        if ([obj1.type isEqualToString:@"College"] && [obj2.type isEqualToString:@"Graduate School"])
            return (NSComparisonResult)NSOrderedDescending;
        
        return (NSComparisonResult)NSOrderedSame;
    }];
    
    
    //Now sort the works array based on "date"
    works = [tmpWorks sortedArrayUsingComparator: ^(Work* obj1, Work* obj2) {
        
        NSDate* obj1Date;
        NSDate* obj2Date;
        NSDateFormatter* myFormatter = [[NSDateFormatter alloc] init];
        [myFormatter setDateFormat:@"MM/dd/yyyy"];
        //See if string says today is present
        if([obj1.end_date isEqualToString:@"Present"])
            obj1Date = [NSDate date];
        else if([obj1.end_date length]>7)//not 0000-00
            obj1Date = [myFormatter dateFromString:obj1.end_date];
        else if([obj1.end_date length] == 4)//only year
            obj1Date = [myFormatter dateFromString:[NSString stringWithFormat:@"01/01/%@",obj1.end_date]];
        else
            obj1Date = [myFormatter dateFromString:@"01/01/1000"];
        
        //See if string says today is present
        if([obj2.end_date isEqualToString:@"Present"])
            obj2Date = [NSDate date];
        else if([obj2.end_date length]>7)//not 0000-00
            obj2Date = [myFormatter dateFromString:obj2.end_date];
        else if([obj2.end_date length] == 4)//only year
            obj2Date = [myFormatter dateFromString:[NSString stringWithFormat:@"01/01/%@",obj2.end_date]];
        else
            obj2Date = [myFormatter dateFromString:@"01/01/1000"];
        
        
        return [obj2Date compare:obj1Date];
        
    }];
    
    NSLog(@"school count is %d and work count is %d", (int)_schoolShowingCount, (int)_workShowingCount);
    
    [professionalTableView reloadData];
    
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

#pragma mark - Table view data source

- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView {

    // Return the number of sections based on showing schools or work
    
    int sectionNumber = ((!!_workShowingCount) + (!!_schoolShowingCount));
    
    if(sectionNumber)
    {
        self.professionalTableView.separatorStyle = UITableViewCellSeparatorStyleSingleLine;
        self.professionalTableView.backgroundView = nil;
    }
    else
    {
        // Display a message when the table is empty
        UILabel *messageLabel = [[UILabel alloc] initWithFrame:CGRectMake(0, 0, self.professionalTableView.bounds.size.width, self.professionalTableView.bounds.size.height)];
        
        messageLabel.text = @"The user is not sharing any professional information.";
        messageLabel.textColor = [UIColor blackColor];
        messageLabel.numberOfLines = 0;
        messageLabel.textAlignment = NSTextAlignmentCenter;
        messageLabel.font = [UIFont fontWithName:@"HelveticaNeue-Italic" size:20];
        [messageLabel sizeToFit];
        
        self.professionalTableView.backgroundView = messageLabel;
        self.professionalTableView.separatorStyle = UITableViewCellSeparatorStyleNone;
    }
    
    
    return sectionNumber;
}


//Do work followed by school
- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section {
    
    int sectionNumber = (!!_workShowingCount + !!_schoolShowingCount);
    
    //Displaying work and schools
    if(sectionNumber == 2)
    {
        //School
        if(section)
            return _schoolShowingCount;
        else//work
            return _workShowingCount;
            
    }
    //could be displaying schools or work, need to check
    else if(sectionNumber == 1)
    {
        //work has some showing
        if(_workShowingCount)
            return _workShowingCount;
        else//school has some showing
            return _schoolShowingCount;
    }
    else
        return 0;
}


- (NSString *)tableView:(UITableView *)tableView titleForHeaderInSection:(NSInteger)section
{
    int sectionNumber = (!!_workShowingCount + !!_schoolShowingCount);
    
    //Displaying work and schools
    if(sectionNumber == 2)
    {
        //School
        if(section)
            return @"School";
        else//work
            return @"Work";
        
    }
    //could be displaying schools or work, need to check
    else if(sectionNumber == 1)
    {
        //work has some showing
        if(_workShowingCount)
            return @"Work";
        else//school has some showing
            return @"School";
    }
    else
        return @"";
}

- (CGFloat)tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath
{
    //figure out how many sections we have
    int sectionNumber = (!!_workShowingCount + !!_schoolShowingCount);
    
    int isSchool = 0;
    
    //Displaying work and schools
    if(sectionNumber == 2)
    {
        //School
        if(indexPath.section)
            isSchool = 1;
        else//work
            isSchool = 0;
        
    }
    //could be displaying schools or work, need to check
    else if(sectionNumber == 1)
    {
        //work has some showing
        if(_workShowingCount)
            isSchool = 0;
        else//school has some showing
            isSchool = 1;
    }
    
    //if we have a school
    if(isSchool)
    {
        School* school = schools[indexPath.row];
        int i=0;
        NSString* degreeString;
        for(NSArray* degree in school.degrees)
        {
            if(((NSNumber*)degree[1]).boolValue)
            {
                //First degree
                if(i == 0)
                    degreeString = [NSString stringWithFormat:@"%@", degree[0]];
                else
                    degreeString = [NSString stringWithFormat:@"%@\n%@",degreeString, degree[0]];
                i++;
            }
        }
        
        //no degrees
        if(!i)
            return 50.0f;

        //degrees
        UILabel *gettingSizeLabel = [[UILabel alloc] init];
        gettingSizeLabel.font = [UIFont fontWithName:@"System" size:10];
        gettingSizeLabel.text = degreeString;
        gettingSizeLabel.numberOfLines = i;
        gettingSizeLabel.lineBreakMode = NSLineBreakByWordWrapping;
        CGSize maximumLabelSize = CGSizeMake(279, 9999);
        
        CGSize expectSize = [gettingSizeLabel sizeThatFits:maximumLabelSize];
        
        //NSLog(@"expect size for %@ is %d", degreeString, (int)expectSize.height);
        
        return 50.0f + expectSize.height;
    }
    else
        return 50.0f;
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath {
    ProfessionalDetailsTableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:@"professionalCell" forIndexPath:indexPath];
    cell.separatorInset = UIEdgeInsetsZero;

    //if it is my profile, make cells clickable and give them the accessory
    if(_isMyProfile)
    {
        cell.accessoryType = UITableViewCellAccessoryDisclosureIndicator;
        cell.userInteractionEnabled = YES;
    }
    else
    {
        cell.accessoryType = UITableViewCellAccessoryNone;
        cell.userInteractionEnabled = NO;
    }
    
    //figure out how many sections we have
    int sectionNumber = (!!_workShowingCount + !!_schoolShowingCount);
    
    int isSchool = 0;
    
    //Displaying work and schools
    if(sectionNumber == 2)
    {
        //School
        if(indexPath.section)
            isSchool = 1;
        else//work
            isSchool = 0;
        
    }
    //could be displaying schools or work, need to check
    else if(sectionNumber == 1)
    {
        //work has some showing
        if(_workShowingCount)
            isSchool = 0;
        else//school has some showing
            isSchool = 1;
    }
    
    //if we have a school
    if(isSchool)
    {
        int i=0;
        School* school = schools[indexPath.row];
        
        //Now that I have the correct school, populate the cell
        cell.nameLabel.text = school.school_name;
        cell.dateLabel.text = school.year;
        cell.typeLabel.text = school.type;
        
        //Now for degrees
        i = 0;
        NSString* degreeString;
        for(NSArray* degree in school.degrees)
        {
            if(((NSNumber*)degree[1]).boolValue)
            {
                //First degree
                if(i == 0)
                    degreeString = [NSString stringWithFormat:@"%@", degree[0]];
                else
                    degreeString = [NSString stringWithFormat:@"%@\n%@",degreeString, degree[0]];
                i++;
            }
        }
        //if there are no degrees listed just hide this field
        if(!i)
        {
            cell.degreesLabel.hidden = YES;
            cell.degreesLabel.numberOfLines = 0;
        }
        else
        {
            cell.degreesLabel.hidden = NO;
            cell.degreesLabel.text = degreeString;
            cell.degreesLabel.numberOfLines = 0;
            
            [cell.degreesLabel sizeToFit];
        }
        
    }
    else//this is a work object
    {
        Work* work = works[indexPath.row];
        
        //Now that I have the correct work, populate the cell
        cell.nameLabel.text = work.employer_name;
        
        //need to do customization of date if the end date is 0000-00
        if([work.end_date isEqualToString:@"0000-00"])
            cell.dateLabel.text = @"Not Showing";
        else if ([work.end_date isEqualToString:@"Present"])
            cell.dateLabel.text = work.end_date;
        else//get the year
            cell.dateLabel.text = [work.end_date substringFromIndex:(work.end_date.length)-4];
        cell.typeLabel.text = work.position;
        cell.degreesLabel.text = @"";
        cell.degreesLabel.hidden = YES;
        cell.degreesLabel.numberOfLines = 0;
    }
    
    
    return cell;
}

//On click of cell, segue
- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath
{
    UITableViewCell *cell = [tableView cellForRowAtIndexPath:indexPath];
    [cell setSelectionStyle:UITableViewCellSelectionStyleDefault];
    
    //figure out how many sections we have
    int sectionNumber = (!!_workShowingCount + !!_schoolShowingCount);
    
    int isSchool = 0;
    
    //Displaying work and schools
    if(sectionNumber == 2)
    {
        //School
        if(indexPath.section)
            isSchool = 1;
        else//work
            isSchool = 0;
        
    }
    //could be displaying schools or work, need to check
    else if(sectionNumber == 1)
    {
        //work has some showing
        if(_workShowingCount)
            isSchool = 0;
        else//school has some showing
            isSchool = 1;
    }
    
    //if we have a school
    if(isSchool)
    {
        _selectedCell = (int)indexPath.row;
        [self performSegueWithIdentifier:@"schoolSegue" sender:self];
    }
    else
    {
        _selectedCell = (int)indexPath.row;
        [self performSegueWithIdentifier:@"workSegue" sender:self];
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

// In a storyboard-based application, you will often want to do a little preparation before navigation
- (void)prepareForSegue:(UIStoryboardSegue *)segue sender:(id)sender {
    if([segue.identifier isEqualToString:@"schoolSegue"])
    {
        SchoolTableViewController *controller = (SchoolTableViewController *)segue.destinationViewController;
        //controller.school = schools[_selectedCell];
        controller.school_id = ((School*)schools[_selectedCell]).school_id;
    }
    else if ([segue.identifier isEqualToString:@"workSegue"])
    {
        WorkTableViewController *controller = (WorkTableViewController *)segue.destinationViewController;
        //controller.school = schools[_selectedCell];
        controller.work_id = ((Work*)works[_selectedCell]).work_id;
    }
}

- (CGFloat)tableView:(UITableView *)tableView heightForHeaderInSection:(NSInteger)section {
    if(!section)
        return 30;
    else
        return 20.0f;
}

@end
