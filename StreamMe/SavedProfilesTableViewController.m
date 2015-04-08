//
//  SavedProfilesTableViewController.m
//  WhoYu
//
//  Created by Chase Midler on 1/25/15.
//  Copyright (c) 2015 midler. All rights reserved.
//

#import "SavedProfilesTableViewController.h"

@interface SavedProfilesTableViewController ()

@end

@implementation SavedProfilesTableViewController
@synthesize profilesTableView;
- (void)viewDidLoad {
    [super viewDidLoad];
    
    // This will remove extra separators from tableview
    self.tableView.tableFooterView = [[UIView alloc] initWithFrame:CGRectZero];
    
    _currentPage = _totalPages = 1;
    profiles = [[NSMutableArray alloc] init];
    
    //Adding pull to refresh
    self.refreshControl = [[UIRefreshControl alloc] init];
    [self.refreshControl addTarget:self
                            action:@selector(pullRefreshSavedProfiles)
                  forControlEvents:UIControlEventValueChanged];
    [self.refreshControl beginRefreshing];
    [profilesTableView setContentOffset:CGPointMake(0, -self.refreshControl.frame.size.height) animated:YES];
    
    [self pullRefreshSavedProfiles];
    
}

-(void) viewWillAppear:(BOOL)animated
{
    //side bar
    SWRevealViewController *revealViewController = self.revealViewController;
    [revealViewController setRightViewRevealWidth:0];
    if ( revealViewController )
    {
        [self.sidebarButton setTarget: self.revealViewController];
        [self.sidebarButton setAction: @selector( revealToggle: )];
        [self.view addGestureRecognizer:self.revealViewController.panGestureRecognizer];
    }
}

//Helper method to load profiles
-(void) loadProfiles
{
    
    NSLog(@"in loading profiles");
    
    //Mutable array of userids to download
    NSMutableArray* userInfo = [[NSMutableArray alloc] init];
    
    //creating a variable to see if we are in the queue or not
    __block bool inQueue = YES;
    
    //get the main database
    MainDatabase* md = [MainDatabase shared];
    [md.queue inDatabase:^(FMDatabase *db) {
        //need to see if the user is saved or not (can use less than since user is not fast enough to save more than 1 user at a time with the app
        NSString *userQuery = @"SELECT user_id, created_at FROM user WHERE is_me = ? AND created_at < ? ORDER BY created_at DESC LIMIT ? ";
        NSArray* values = @[[NSNumber numberWithInt:0],[NSNumber numberWithDouble:_oldestTime], [NSNumber numberWithInt:PROFILES_PER_PAGE]];
        FMResultSet* s = [db executeQuery:userQuery withArgumentsInArray:values];
        
        //loop through returned users
        while ([s next])
        {
            
            NSString* user_id = [s stringForColumnIndex:0];
            double createdAt = [s doubleForColumnIndex:1];
            [userInfo addObject:@[user_id, [NSNumber numberWithDouble:createdAt]]];
        }
        inQueue = NO;
    
    }];
    
    //just loop until the database query is finished
    while(inQueue)
        ;
    
    NSMutableArray* userIds = [[NSMutableArray alloc] init];
    //get the user ids
    for(NSArray* u in userInfo)
        [userIds addObject:u[0]];
    
    NSLog(@"user ids is %@", userIds);
    
    //if there are no users, don't make a query
    if(!userIds || !userIds.count)
    {
        [self.refreshControl endRefreshing];
        _currentPage = _totalPages;
        _totalSavedProfiles = (int)profiles.count;
        [profilesTableView reloadData];
        return;
    }
    
    //Now we grab the user data from the backend
    [PFCloud callFunctionInBackground:@"getSavedUsers" withParameters:@{@"usersList":userIds} block:^(id object, NSError *error) {
        
        if(error)
        {
            //letting the user know
            UIAlertAction *newOkAction = [UIAlertAction
                                          actionWithTitle:NSLocalizedString(@"Ok", @"Ok action")
                                          style:UIAlertActionStyleDefault
                                          handler:^(UIAlertAction *action)
                                          {
                                              NSLog(@"Ok action");
                                              [self.refreshControl endRefreshing];
                                              _currentPage = _totalPages;
                                              _totalSavedProfiles = (int)profiles.count;
                                              [profilesTableView reloadData];
                                              return;
                                          }];
            
            UIAlertController *alertController = [UIAlertController
                                                  alertControllerWithTitle:@"Something Went Wrong"
                                                  message:@"Could not get the profiles.  Please check your internet connection, pull to refresh, and try again."
                                                  preferredStyle:UIAlertControllerStyleAlert];
            
            [alertController addAction:newOkAction];
            
            [self presentViewController:alertController animated:YES completion:nil];
            return;
        }
        
        NSArray* users = object;
        NSMutableArray* tmpProfiles = [[NSMutableArray alloc]init];
        for( NSDictionary* user in users)
        {
            UserProfile* profile = [[UserProfile alloc] init];
            profile.user_id = user[@"objectId"];
            profile.sex = user[ @"sex"];
            profile.birthday = user[@"birthday"];
            profile.relationship_status = user[@"relationship_status"];
            profile.interested_in = user[@"interested_in"];
            profile.first_name = user[@"first_name"];
            profile.isShowingProfessional = ((NSNumber*)user[@"isShowingProfessional"]).boolValue;
            profile.imageFile = user[@"profilePicture"];
            profile.facebookID = user[@"facebookID"];
            profile.isComplete = 1;
            
            NSNumber* createdAt = [NSNumber numberWithDouble:0.0];
            //get the created at time
            for(NSArray* u in userInfo)
            {
                if([u[0] isEqualToString:profile.user_id])
                {
                    createdAt = u[1];
                    break;
                }
            }
            [tmpProfiles addObject:@[profile,createdAt]];
            
        }
        //sort tmp profiles and add to the end of profiles
        tmpProfiles = [NSMutableArray arrayWithArray:[tmpProfiles sortedArrayUsingComparator: ^(NSArray* obj1, NSArray* obj2) {
            
            double d1 = ((NSNumber*)obj1[1]).doubleValue;
            double d2 = ((NSNumber*)obj2[1]).doubleValue;
            
            if (d1 > d2) {
                
                return (NSComparisonResult)NSOrderedAscending;
            }
            if (d1 < d2) {
                
                return (NSComparisonResult)NSOrderedDescending;
            }
            return (NSComparisonResult)NSOrderedSame;
        }]];
        
        _oldestTime = ((NSNumber*)tmpProfiles[tmpProfiles.count-1][1]).doubleValue;
        
        //add the new objects to the profiles array
        [profiles addObjectsFromArray:tmpProfiles];
        
        NSLog(@"profiles is %@", profiles);
        [self.refreshControl endRefreshing];
        [profilesTableView reloadData];
    }];
}

//method called when pull to refresh happens
-(void) pullRefreshSavedProfiles
{
    //reset the current page, oldest time, profiles, and recompute the total pages
    _currentPage = 1;
    _oldestTime = [[NSDate date] timeIntervalSince1970];
    _totalSavedProfiles = 0;
    [profiles removeAllObjects];
    
    __block bool inQueue = YES;
    //get the main database
    MainDatabase* md = [MainDatabase shared];
    [md.queue inDatabase:^(FMDatabase *db) {
        NSString *countQuery = @"SELECT COUNT(*) FROM USER WHERE IS_ME = \"0\"";
        FMResultSet* s = [db executeQuery:countQuery];
        //Loop through all the returned rows (should be just one)
        while( [s next] )
        {
            _totalSavedProfiles += [s intForColumnIndex:0];
        }
        
        //we have a count, so we can set the total pages
        _totalPages = (_totalSavedProfiles/PROFILES_PER_PAGE)+1;
        inQueue = NO;
    }];
    
    //just loop
    while(inQueue)
        ;
    
    //Loading profile with time of right now or older
    [self loadProfiles];
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
    
    //if no profiles then set the tableview background properly
    if(!profiles.count)
    {
        // Display a message when the table is empty
        UILabel *messageLabel = [[UILabel alloc] initWithFrame:CGRectMake(0, 0, self.profilesTableView.bounds.size.width, self.profilesTableView.bounds.size.height)];
        
        messageLabel.text = @"There are no saved profiles.";
        messageLabel.textColor = [UIColor blackColor];
        messageLabel.numberOfLines = 0;
        messageLabel.textAlignment = NSTextAlignmentCenter;
        messageLabel.font = [UIFont fontWithName:@"HelveticaNeue-Italic" size:20];
        [messageLabel sizeToFit];
        
        self.profilesTableView.backgroundView = messageLabel;
        self.profilesTableView.separatorStyle = UITableViewCellSeparatorStyleNone;
        return 0;
    }
    
    //Need to make sure we fix the background properly
    self.profilesTableView.separatorStyle = UITableViewCellSeparatorStyleSingleLine;
    self.profilesTableView.backgroundView = nil;
    
    // Return the number of rows in the section.
    if((_currentPage<_totalPages) && (profiles.count != _totalSavedProfiles))
    {
        NSLog(@"returning additional row %d", (int)profiles.count+1);
        return (profiles.count + 1);
    }
    else
    {
        NSLog(@"profiles count is %d", (int)profiles.count);
        return profiles.count;
    }
}


- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath {
    SaveProfilesTableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:@"profileCell" forIndexPath:indexPath];
    cell.separatorInset = UIEdgeInsetsZero;
    cell.profileImageView.layer.cornerRadius = 5;
    cell.profileImageView.clipsToBounds = YES;
    cell.accessoryType = UITableViewCellAccessoryNone;
    //normal other profiles cell
    if(indexPath.row < [profiles count])
    {
        cell.tag = PROFILE_CELL;
        cell.profileImageView.hidden = NO;
        cell.nameLabel.hidden = NO;
        cell.createdAtLabel.hidden = NO;
        cell.activityIndicator.hidden = YES;
        [cell.activityIndicator stopAnimating];
        
        UserProfile* profile = profiles[indexPath.row][0];
        NSString *localPath = [[NSBundle mainBundle]bundlePath];
        NSString *imageName = [localPath stringByAppendingPathComponent:[[NSString alloc]initWithFormat:@"whoYuLogo.png"]];
        
        //Now set value for cells
        [cell setUserInteractionEnabled:NO];
        cell.profileImageView.image = [UIImage imageNamed:imageName];
        cell.profileImageView.file = profile.imageFile;
        [cell.profileImageView loadInBackground:^(UIImage *image, NSError *error) {
            [cell setUserInteractionEnabled:YES];
            cell.separatorInset = UIEdgeInsetsZero;
        }];
        cell.nameLabel.text = profile.first_name;
        
        NSDate* date = [NSDate dateWithTimeIntervalSince1970:((NSNumber*)profiles[indexPath.row][1]).doubleValue];
        NSDateFormatter *dateFormatter = [[NSDateFormatter alloc]init];
        dateFormatter.dateFormat = @"MM/dd/yy hh:mm a";
        NSString *dateString = [dateFormatter stringFromDate: date];
        
        cell.createdAtLabel.text = [NSString stringWithFormat:@"Saved at %@",dateString];
        cell.accessoryType = UITableViewCellAccessoryDisclosureIndicator;
        
    }
    //we are at the loading profile cell
    else
    {
        cell.tag = LOADING_PROFILES_CELL;
        cell.activityIndicator.hidden = NO;
        cell.profileImageView.hidden = YES;
        cell.nameLabel.hidden = YES;
        cell.createdAtLabel.hidden = YES;
        [cell setUserInteractionEnabled:NO];
        
        //activity indicator
        cell.activityIndicator.activityIndicatorViewStyle = UIActivityIndicatorViewStyleGray;
        cell.activityIndicator.center = cell.center;
        [cell.activityIndicator startAnimating];
        cell.accessoryType = UITableViewCellAccessoryNone;
        NSLog(@"activity indicator cell");
    }

    
    return cell;
}

//On click of cell, segue
- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath
{
    UITableViewCell *cell = [tableView cellForRowAtIndexPath:indexPath];
    [cell setSelectionStyle:UITableViewCellSelectionStyleDefault];

    _selectedCell = (int)indexPath.row;
    
    [self performSegueWithIdentifier:@"viewProfileSegue" sender:self];
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
    
    //get more profiles
    if(cell.tag == LOADING_PROFILES_CELL)
    {
        _currentPage++;
        [self loadProfiles];
    }
}

- (CGFloat)tableView:(UITableView *)tableView heightForHeaderInSection:(NSInteger)section {
    return 0.1f;
}



// In a storyboard-based application, you will often want to do a little preparation before navigation
- (void)prepareForSegue:(UIStoryboardSegue *)segue sender:(id)sender {
    if([segue.identifier isEqualToString:@"viewProfileSegue"]){
        
        UINavigationController *navController = segue.destinationViewController;
        ViewProfileViewController* controller = [navController childViewControllers].firstObject;
        controller.profile = profiles[_selectedCell][0];
        controller.profile.picture_data = [controller.profile.imageFile getData];
        controller.profile.picture_data_length = [NSString stringWithFormat:@"%d",(int) controller.profile.picture_data.length ];
    }
}


@end
