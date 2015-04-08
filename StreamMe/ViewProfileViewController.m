//
//  ViewProfileViewController.m
//  genesis
//
//  Created by Chase Midler on 9/4/14.
//  Copyright (c) 2014 midler. All rights reserved.
//

#import "ViewProfileViewController.h"

@interface ViewProfileViewController ()

@end

@implementation ViewProfileViewController
@synthesize profileTableView;
@synthesize tableViewController;
@synthesize mutualFriendsCollectionView;
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
    
    self.automaticallyAdjustsScrollViewInsets = NO;
    [_activityIndicator stopAnimating];
    // This will remove extra separators from tableview
    self.profileTableView.tableFooterView = [[UIView alloc] initWithFrame:CGRectZero];
    personalInformation = [[NSMutableArray alloc] init];
    
    
    //always do this
    [self setSharedValues];
    
    tableViewController = [[UITableViewController alloc] init];
    tableViewController.tableView = self.profileTableView;
    
    tableViewController.refreshControl = [[UIRefreshControl alloc] init];
    [tableViewController.refreshControl addTarget:self action:@selector(setup) forControlEvents:UIControlEventValueChanged];
    tableViewController.refreshControl = tableViewController.refreshControl;
    [tableViewController.refreshControl beginRefreshing];
    [profileTableView setContentOffset:CGPointMake(320, -tableViewController.refreshControl.frame.size.height) animated:YES];
    
    _hasPersonalData = NO;
    _hasProfessionalData = NO;
    
}

- (void) viewWillAppear:(BOOL)animated
{
    //side bar
    SWRevealViewController *revealViewController = self.revealViewController;
    RightMenuTableViewController* rightController = (RightMenuTableViewController*)revealViewController.rightViewController;
    rightController.originController = @"viewProfile";
    rightController.profile = _profile;
    [revealViewController setRightViewRevealWidth:self.view.frame.size.width-RIGHT_SLIDE];
    if ( revealViewController )
    {
        [self.sidebarButton setTarget: self.revealViewController];
        [self.sidebarButton setAction: @selector( revealToggle: )];
        [self.view addGestureRecognizer:self.revealViewController.panGestureRecognizer];
        
        [self.rightBarButton setTarget: self.revealViewController];
        [self.rightBarButton setAction: @selector( rightRevealToggle: )];
        [self.view addGestureRecognizer:self.revealViewController.panGestureRecognizer];
        
    }
    
    _friendsLabel.text = @"0 MUTUAL FRIENDS";
    [self setup];
    [self.profileTableView addObserver:self forKeyPath:@"contentSize" options:0 context:NULL];
    
}

-(void) viewWillDisappear:(BOOL)animated
{
    [self.profileTableView removeObserver:self forKeyPath:@"contentSize" context:NULL];
}

- (void) setSharedValues
{
    //Setting the title to be the name
    self.navigationItem.title = _profile.first_name;
    
    //Setting the profile picture image
    if(_profile.picture_data.length)
    {
        UIImageView *picture = [[UIImageView alloc] init];
        //picture.contentMode = UIViewContentModeScaleToFill;
        picture.image = [UIImage imageWithData:_profile.picture_data];
        _pictureImageView.image = picture.image;
    }
    else
    {
        NSString *localPath = [[NSBundle mainBundle]bundlePath];
        
        NSString *imageName = [localPath stringByAppendingPathComponent:[[NSString alloc]initWithFormat:@"whoYuLogo.png"]];
        _pictureImageView.image = [UIImage imageWithContentsOfFile:imageName];
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


//populate the values on display accordingly
- (void) setup
{
    //NSLog(@"profile user id is %@ and is showing is %d", _profile.user_id, _profile.isShowingProfessional);
    
    [personalInformation removeAllObjects];
    //see if the user has personal information
    if(!([_profile.birthday isEqualToString:@"01/01/1900"] || [_profile.birthday isEqualToString:@"Not displaying"]) || ![_profile.interested_in isEqualToString:@"Not displaying"] || ![_profile.sex isEqualToString:@"Not displaying"] || ![_profile.relationship_status isEqualToString:@"Not displaying"])
    {
        _hasPersonalData = YES;
        if(!([_profile.birthday isEqualToString:@"01/01/1900"] || [_profile.birthday isEqualToString:@"Not displaying"]))
            [personalInformation addObject:@[@"Age", _profile.birthday]];
        if(![_profile.sex isEqualToString:@"Not displaying"])
            [personalInformation addObject:@[@"Gender", _profile.sex]];
        if(![_profile.interested_in isEqualToString:@"Not displaying"])
            [personalInformation addObject:@[@"Interested in", _profile.interested_in]];
        if(![_profile.relationship_status isEqualToString:@"Not displaying"])
            [personalInformation addObject:@[@"Relationship Status", _profile.relationship_status]];
    }
    
    //see if the profile is in range
    AppDelegate* appDelegate = [[UIApplication sharedApplication] delegate];
    for(NSString* key in [[[appDelegate central] bluetoothProfiles] allKeys])
    {
        BluetoothProfile* bp = [[[appDelegate central] bluetoothProfiles] objectForKey:key];
        if(bp.isMarkedAsOld)
            continue;
        
        //Found the user
        if([bp.user_id isEqualToString:_profile.user_id])
        {
            _inRangeProfile = YES;
            break;
        }
    }
    
    //if the user is not showing professional profiles then just return
    if(!_profile.isShowingProfessional)
    {
        [tableViewController.refreshControl endRefreshing];
        [self sortProfessional];
        return;
    }
    
    _proProfile = [[ProfessionalProfile alloc] init];
            
    //if there is an error then show an alert
    UIAlertView* errorAlert = [[UIAlertView alloc] initWithTitle:@"Error Occurred"
                                                         message:@"An error occurred while trying to access the user's data.  Please check your internet connection and try again."
                                                        delegate:nil
                                               cancelButtonTitle:@"ok"
                                               otherButtonTitles:nil];
        
    
    //get the user's work and school information from parse
    [PFCloud callFunctionInBackground:@"getUserWork" withParameters:@{@"user_id": _profile.user_id} block:^(id object, NSError *error) {
        
        //if an error and we don't have a complete profile show the alert
        if(error && (!_proProfile || !_proProfile.isComplete))
        {
            [errorAlert show];
            //Stop the refreshing action
            [tableViewController.refreshControl endRefreshing];
            [self sortProfessional];
            return;
        }
        
        NSArray* worksArray = object;
        
        [PFCloud callFunctionInBackground:@"getUserSchool" withParameters:@{@"user_id": _profile.user_id} block:^(id object, NSError *error) {
            
            //if an error and we don't have a complete profile show the alert
            if(error && (!_proProfile || !_proProfile.isComplete))
            {
                [errorAlert show];
                NSLog(@"error is %@", error);
                //Stop the refreshing action
                [tableViewController.refreshControl endRefreshing];
                [self sortProfessional];
                return;
            }
            
            NSArray* schoolsArray = object;
            
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
                
                for(NSDictionary* degree in degrees)
                {
                    if(![degree count])
                        continue;
                    //NSDictionary* dict = degree[0];
                    NSString* degreeName = degree[@"name"];
                    NSNumber* isShowing = degree[@"isShowing"];
                    [newSchool.degrees addObject:@[degreeName, isShowing]];
                }
                [_proProfile.schools addObject:newSchool];
            }
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
            
        }];
    }];
    
}

//helper function to setup the professional data
-(void) sortProfessional
{
    NSMutableArray* tmpSchools = [[NSMutableArray alloc]init];
    NSMutableArray* tmpWorks = [[NSMutableArray alloc]init];
    
    //set counts to 0 if we aren't showing anything
    if(!_hasProfessionalData)
    {
        schools = [[NSArray alloc] init];
        works = [[NSArray alloc] init];
        [profileTableView reloadData];
        return;
    }
    
    NSLog(@"Sorting professional data");
    
    //Counting the number of schools and works to be displayed
    for(School* s in _proProfile.schools)
    {
        if(s.isShowing)
            [tmpSchools addObject:s];
    }
    
    //counting work showing
    for(Work* w in _proProfile.works)
    {
        if(w.isShowing)
            [tmpWorks addObject:w];
    }
    
    NSLog(@"School is %@", _proProfile.schools);
    NSLog(@"work is %@", _proProfile.works);
    
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
    
    [profileTableView reloadData];
}


- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView
{
    // Return the number of sections.
    //calculate number of sections based on if the user is saved, has personal info, has professional info, and has private info
    int numberOfSections = 0;
    //if this is a saved profile, need notes
    /*if([_rightBarButton.title isEqualToString:@"Remove"])
        numberOfSections++;*/
    
    numberOfSections += (!!works.count + !!schools.count + _hasPersonalData);
    
    if(numberOfSections)
    {
        self.profileTableView.separatorStyle = UITableViewCellSeparatorStyleSingleLine;
        self.profileTableView.backgroundView = nil;
    }
    else
    {
        // Display a message when the table is empty
        UILabel *messageLabel = [[UILabel alloc] initWithFrame:CGRectMake(0, 0, self.profileTableView.bounds.size.width, self.profileTableView.bounds.size.height)];
        
        messageLabel.text = @"The user is not sharing any other information.";
        messageLabel.textColor = [UIColor blackColor];
        messageLabel.numberOfLines = 0;
        messageLabel.textAlignment = NSTextAlignmentCenter;
        messageLabel.font = [UIFont fontWithName:@"HelveticaNeue-Italic" size:20];
        [messageLabel sizeToFit];
        
        self.profileTableView.backgroundView = messageLabel;
        self.profileTableView.separatorStyle = UITableViewCellSeparatorStyleNone;
    }
    
    return numberOfSections;
}

- (NSString *)tableView:(UITableView *)tableView titleForHeaderInSection:(NSInteger)section
{
    
    int numberOfSections = (!!works.count + !!schools.count + _hasPersonalData);
    
    bool isSchool = NO;
    bool isWork = NO;
    bool isPersonal = NO;
    
    if(numberOfSections == 3)
    {
        if(section == 2)
            isSchool = YES;
        else if (section ==1)
            isWork = YES;
        else
            isPersonal = YES;
    }
    else if (numberOfSections == 2)
    {
        //personal and work
        if(_hasPersonalData && works.count)
        {
            if(section)
                isWork = YES;
            else
                isPersonal = YES;
        }
        //personal and school
        else if(_hasPersonalData && schools.count)
        {
            if(section)
                isSchool = YES;
            else
                isPersonal = YES;
        }
        //not personal, try work and school
        else
        {
            if(section)
                isSchool = YES;
            else
                isWork = YES;
        }
    }
    //only 1 section
    else
    {
        if(_hasPersonalData)
            isPersonal = YES;
        else if(works.count)
            isWork = YES;
        else if (schools.count)
            isSchool = YES;
    }
    
    //return the string based on which boolean is true
    if(isPersonal)
        return @"Personal Information";
    else if(isWork)
        return @"Work Information";
    else
        return @"Education Information";
    
}




- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section
{
    int numberOfSections = (!!works.count + !!schools.count + _hasPersonalData);
    
    bool isSchool = NO;
    bool isWork = NO;
    bool isPersonal = NO;
    
    if(numberOfSections == 3)
    {
        if(section == 2)
            isSchool = YES;
        else if (section ==1)
            isWork = YES;
        else
            isPersonal = YES;
    }
    else if (numberOfSections == 2)
    {
        //personal and work
        if(_hasPersonalData && works.count)
        {
            if(section)
                isWork = YES;
            else
                isPersonal = YES;
        }
        //personal and school
        else if(_hasPersonalData && schools.count)
        {
            if(section)
                isSchool = YES;
            else
                isPersonal = YES;
        }
        //not personal, try work and school
        else
        {
            if(section)
                isSchool = YES;
            else
                isWork = YES;
        }
    }
    //only 1 section
    else
    {
        if(_hasPersonalData)
            isPersonal = YES;
        else if(works.count)
            isWork = YES;
        else if (schools.count)
            isSchool = YES;
    }
    if(isPersonal)
        return personalInformation.count;
    else if (isWork)
        return works.count;
    else
        return schools.count;
}

//Show data in cells
- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath
{
    
    static NSString *CellIdentifier = @"detailCell";
    ViewProfileTableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:CellIdentifier forIndexPath:indexPath];
    cell.separatorInset = UIEdgeInsetsZero;
    cell.userInteractionEnabled = NO;
    //hide all of the labels first
    cell.viewTypeLabel.hidden = YES;
    cell.valueLabel.hidden = YES;
    cell.degreesLabel.hidden = YES;
    cell.typeLabel.hidden = YES;
    cell.dateLabel.hidden = YES;
    cell.nameLabel.hidden = YES;
    
    int numberOfSections = (!!works.count + !!schools.count + _hasPersonalData);
    
    bool isSchool = NO;
    bool isWork = NO;
    bool isPersonal = NO;
    
    if(numberOfSections == 3)
    {
        if(indexPath.section == 2)
            isSchool = YES;
        else if (indexPath.section ==1)
            isWork = YES;
        else
            isPersonal = YES;
    }
    else if (numberOfSections == 2)
    {
        //personal and work
        if(_hasPersonalData && works.count)
        {
            if(indexPath.section)
                isWork = YES;
            else
                isPersonal = YES;
        }
        //personal and school
        else if(_hasPersonalData && schools.count)
        {
            if(indexPath.section)
                isSchool = YES;
            else
                isPersonal = YES;
        }
        //not personal, try work and school
        else
        {
            if(indexPath.section)
                isSchool = YES;
            else
                isWork = YES;
        }
    }
    //only 1 section
    else
    {
        if(_hasPersonalData)
            isPersonal = YES;
        else if(works.count)
            isWork = YES;
        else if (schools.count)
            isSchool = YES;
    }
    
    //we know which section we are in so we can populate the data appropriately
    if(isPersonal)
    {
        cell.valueLabel.hidden = NO;
        cell.viewTypeLabel.hidden = NO;
        
        if(![personalInformation[indexPath.row][0] isEqualToString:@"Age"])
            cell.valueLabel.text = personalInformation[indexPath.row][1];
        else
        {
            NSString* age;
            NSString* birthday = _profile.birthday;
            if(!birthday || birthday.length ==0 || [birthday isEqualToString:@"01/01/1900"])
            {
                age = @"Not displaying";
            }
            else
            {
                NSLog(@" getting birthday info");
                NSDateFormatter* myFormatter = [[NSDateFormatter alloc] init];
                [myFormatter setDateFormat:@"MM/dd/yyyy"];
                NSDate* myDate = [myFormatter dateFromString:birthday];
                NSDate* now = [NSDate date];
                NSDateComponents* ageComponents = [[NSCalendar currentCalendar] components:NSCalendarUnitYear fromDate:myDate toDate:now options:0];
                age = [NSString stringWithFormat:@"%ld",(long)[ageComponents year]];
            }
            cell.valueLabel.text = age;

        }
        cell.viewTypeLabel.text = personalInformation[indexPath.row][0];
    }
    else if(isSchool)
    {
        int i=0;
        School* school = schools[indexPath.row];
        
        //Now that I have the correct school, populate the cell
        cell.nameLabel.text = school.school_name;
        cell.dateLabel.text = school.year;
        cell.typeLabel.text = school.type;
        cell.nameLabel.hidden = NO;
        cell.dateLabel.hidden = NO;
        cell.typeLabel.hidden = NO;
        
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
        
        NSLog(@"Degree string is %@", degreeString);
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
    else
    {
        Work* work = works[indexPath.row];
        
        cell.nameLabel.hidden = NO;
        cell.dateLabel.hidden = NO;
        cell.typeLabel.hidden = NO;
        
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

- (CGFloat)tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath
{
    int numberOfSections = (!!works.count + !!schools.count + _hasPersonalData);
    
    bool isSchool = NO;
    bool isWork = NO;
    bool isPersonal = NO;
    
    if(numberOfSections == 3)
    {
        if(indexPath.section == 2)
            isSchool = YES;
        else if (indexPath.section ==1)
            isWork = YES;
        else
            isPersonal = YES;
    }
    else if (numberOfSections == 2)
    {
        //personal and work
        if(_hasPersonalData && works.count)
        {
            if(indexPath.section)
                isWork = YES;
            else
                isPersonal = YES;
        }
        //personal and school
        else if(_hasPersonalData && schools.count)
        {
            if(indexPath.section)
                isSchool = YES;
            else
                isPersonal = YES;
        }
        //not personal, try work and school
        else
        {
            if(indexPath.section)
                isSchool = YES;
            else
                isWork = YES;
        }
    }
    //only 1 section
    else
    {
        if(_hasPersonalData)
            isPersonal = YES;
        else if(works.count)
            isWork = YES;
        else if (schools.count)
            isSchool = YES;
    }
    
    //if not schools, return height of 50
    if(!isSchool)
        return 50.0f;
    
    //ok we are in schools, calculate how much we need and return
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


- (CGFloat)tableView:(UITableView *)tableView heightForHeaderInSection:(NSInteger)section {
    if(!section)
        return 30;
    else
        return 20.0f;
}

- (NSInteger)numberOfSectionsInCollectionView:(UICollectionView *)collectionView {
    return 1;
}


- (NSInteger)collectionView:(UICollectionView *)collectionView numberOfItemsInSection:(NSInteger)section {
    if((_currentPage<_totalPages) && ([friends count] != _friendsList.count) && !_errorOccurred)
    {
        //NSLog(@"returning additional row %d", (int)profiles.count+1);
        return ([friends count] + 1);
    }
    else
        return friends.count;
}

- (UICollectionViewCell *)collectionView:(UICollectionView *)collectionView cellForItemAtIndexPath:(NSIndexPath *)indexPath {
    MutualFriendsCollectionViewCell *cell = [collectionView dequeueReusableCellWithReuseIdentifier:@"friendCell" forIndexPath:indexPath];
    cell.userInteractionEnabled = NO;
    cell.nameLabel.hidden = YES;
    cell.activityIndicator.hidden = YES;
    cell.pictureImageView.hidden = YES;
    
    //add cell
    if(indexPath.row >= friends.count)
    {
        cell.tag = ADD_FRIEND_CELL;
        cell.activityIndicator.hidden = NO;
        cell.activityIndicator.center = cell.center;
        [cell.activityIndicator startAnimating];
    }
    //normal cell
    else
    {
        cell.tag = FRIEND_CELL;
        cell.nameLabel.hidden = NO;
        cell.pictureImageView.hidden = NO;
        UserProfile* profile = friends[indexPath.row];
        cell.nameLabel.text = profile.first_name;
        cell.pictureImageView.layer.cornerRadius = 20;
        cell.pictureImageView.clipsToBounds = YES;
        cell.pictureImageView.image = [UIImage imageNamed:@"whoYuLogo.png"];
        cell.pictureImageView.file = profile.imageFile;
        [cell.pictureImageView loadInBackground];
        NSLog(@"friends count is %d and current name is %@", (int)friends.count, profile.first_name);
    }
    
    return cell;
}

- (void)collectionView:(UICollectionView *)collectionView willDisplayCell:(UICollectionViewCell *)cell forItemAtIndexPath:(NSIndexPath *)indexPath NS_AVAILABLE_IOS(8_0)
{
    //get more profiles
    if(cell.tag == ADD_FRIEND_CELL  && !_errorOccurred)
    {
        _currentPage++;
        [self loadMutualFriends];
    }
    
}

-(void) loadMutualFriends
{
    //if there is an error then show an alert
    UIAlertView* errorAlert = [[UIAlertView alloc] initWithTitle:@"Cannot Find Event Data"
                                                         message:@"An error occurred while trying to check for mutual friends.  Please check your internet connection and try again."
                                                        delegate:nil
                                               cancelButtonTitle:@"ok"
                                               otherButtonTitles:nil];
    
    int i = _numberOfFriendsLoaded;
    NSMutableArray* userList = [[NSMutableArray alloc] init];
    for(; i< _numberOfFriendsLoaded + FRIENDS_PER_PAGE; i++)
    {
        if(i>= _friendsList.count)
            break;
        
        NSString* facebookID = [((NSDictionary*)_friendsList[i]) objectForKey:@"id"];
        
        [userList addObject:facebookID];
    }
    
    //don't run query if we have all of the mutual friends
    if(![userList count])
    {
        return;
    }
    
    
    //Ok we got the event so now let's cloud code the users
    [PFCloud callFunctionInBackground:@"getMutualFriends" withParameters:@{@"usersList":userList} block:^(id object, NSError *error) {
        if(error || !object)
        {
            //Stop the refreshing action
            _errorOccurred = YES;
            [errorAlert show];
            return;
        }
        
        //object is an array of dictionarys
        NSArray* users = object;
        
        NSLog(@"users = %@", users);
        
        for( NSDictionary* user in users)
        {
            UserProfile* profile = [[UserProfile alloc] init];
            profile.user_id = user[@"objectId"];
            profile.facebookID = user[@"facebookID"];
            profile.first_name = user[@"first_name"];
            profile.imageFile = user[@"profilePicture"];
            profile.isComplete = 1;
            [friends addObject:profile];
            _numberOfFriendsLoaded++;
            NSLog(@"got profiles here");
        }
        
        //compute the total pages and reset current page to the beginning
        _currentPage = 1;
        
        //Stop the refreshing action
        [mutualFriendsCollectionView reloadData];
    }];
}

/*- (UICollectionReusableView *)collectionView:(UICollectionView *)collectionView viewForSupplementaryElementOfKind:(NSString *)kind atIndexPath:(NSIndexPath *)indexPath
{
    if (kind == UICollectionElementKindSectionHeader) {
        NSLog(@"in header");
        UICollectionReusableView *headerView = [mutualFriendsCollectionView dequeueReusableSupplementaryViewOfKind:UICollectionElementKindSectionHeader withReuseIdentifier:@"collectionHeader" forIndexPath:indexPath];
        
        UILabel * title =[[UILabel alloc]initWithFrame:CGRectMake(0, 0, collectionView.frame.size.width, HEADER_HEIGHT )];
        title.font = [UIFont boldSystemFontOfSize:14];
        title.textColor = [UIColor darkTextColor];
        if(_numberOfFriends ==1)
            title.text = @"1 Mutual Friend";
        else
            title.text = [NSString stringWithFormat:@"%d Mutual Friends", _numberOfFriends];
        [headerView addSubview:title];
        
        return headerView;
    
    }
    else
        return nil;
}*/


// In a storyboard-based application, you will often want to do a little preparation before navigation
- (void)prepareForSegue:(UIStoryboardSegue *)segue sender:(id)sender
{
    if([segue.identifier isEqualToString:@"PersonalSegue"])
    {
        PersonalDetailsTableViewController* controller = (PersonalDetailsTableViewController*)segue.destinationViewController;
        controller.isMyProfile = NO;
        controller.profile = _profile;
    }
    else if([segue.identifier isEqualToString:@"ProfessionalSegue"])
    {
        ProfessionalDetailsTableViewController* controller = (ProfessionalDetailsTableViewController*)segue.destinationViewController;
        controller.isMyProfile = NO;
        controller.proProfile = _proProfile;
        controller.user_id = _profile.user_id; //getting from profile since we always have that at view page
        controller.isShowing = _profile.isShowingProfessional;
        
        //NSLog(@"profile user id is %@ and is showing is %d", _profile.user_id, _profile.isShowingProfessional);
        
        if(!controller.isMyProfile)
            controller.navigationItem.rightBarButtonItem = nil;
        
        //controller.profile = _profile;
    }
    else if([segue.identifier isEqualToString:@"SendSegue"])
    {
        
        RequestPrivateDataTableViewController* controller = (RequestPrivateDataTableViewController*)segue.destinationViewController;
        controller.profile = _profile;
        controller.isMyProfile = NO;
    }
    
}


//do different actions based on the title!
- (IBAction) barButtonAction:(id)sender {
}

//observer to make sure we adjust the height of the tableview properly
- (void)observeValueForKeyPath:(NSString *)keyPath ofObject:(id)object change:(NSDictionary *)change context:(void *)context
{
    //NSLog(@"key path is %@", keyPath);
    NSLog(@"tableview height constraint is %f", _tableViewHeightConstraint.constant);
    NSLog(@"view height constraint is %f",  _heightConstraint.constant);
    CGRect frame = self.profileTableView.frame;
    frame.size = self.profileTableView.contentSize;
    
    [_tableViewHeightConstraint setConstant:frame.size.height-30];
    [_heightConstraint setConstant:(frame.size.height + _pictureImageView.frame.size.height) + mutualFriendsCollectionView.frame.size.height];
    
    
    /*NSLayoutConstraint* newHeightCon = [NSLayoutConstraint ]
    
    [self.dynamicView addConstraints:[NSLayoutConstraint constraintsWithVisualFormat:[NSString stringWithFormat: @"V:[dynamicView(==%f)]", self.profileTableView.frame.size.height + _pictureImageView.image.size.height]
                                                                   options:0
                                                                   metrics:nil
                                                                     views:NSDictionaryOfVariableBindings(self.dynamicView)]];*/
    
    
}
@end
