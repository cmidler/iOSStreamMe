//
//  ContactCardListTableViewController.m
//  WhoYu
//
//  Created by Chase Midler on 3/9/15.
//  Copyright (c) 2015 midler. All rights reserved.
//

#import "ContactCardListTableViewController.h"

@interface ContactCardListTableViewController ()

@end

@implementation ContactCardListTableViewController
@synthesize contactTableView;
- (void)viewDidLoad {
    [super viewDidLoad];
    
    //side bar
    SWRevealViewController *revealViewController = self.revealViewController;
    [revealViewController setRightViewRevealWidth:0];
    if ( revealViewController )
    {
        [self.sidebarButton setTarget: self.revealViewController];
        [self.sidebarButton setAction: @selector( revealToggle: )];
        [self.view addGestureRecognizer:self.revealViewController.panGestureRecognizer];
    }
    
    // This will remove extra separators from tableview
    self.tableView.tableFooterView = [[UIView alloc] initWithFrame:CGRectZero];
    
    _currentPage = _totalPages = 1;
    contacts = [[NSMutableArray alloc] init];
    
    //Adding pull to refresh
    self.refreshControl = [[UIRefreshControl alloc] init];
    [self.refreshControl addTarget:self
                            action:@selector(pullRefreshSavedProfiles)
                  forControlEvents:UIControlEventValueChanged];
    [self.refreshControl beginRefreshing];
    [contactTableView setContentOffset:CGPointMake(0, -self.refreshControl.frame.size.height) animated:YES];
    
    [self pullRefreshSavedProfiles];
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
        NSString *contactQuery = @"SELECT user_id, created_at, is_new FROM contact WHERE created_at < ? ORDER BY created_at DESC LIMIT ? ";
        NSArray* values = @[[NSNumber numberWithDouble:_oldestTime], [NSNumber numberWithInt:PROFILES_PER_PAGE]];
        FMResultSet* s = [db executeQuery:contactQuery withArgumentsInArray:values];
        
        //loop through returned users
        while ([s next])
        {
            
            NSString* user_id = [s stringForColumnIndex:0];
            double createdAt = [s doubleForColumnIndex:1];
            int isNew = [s intForColumnIndex:2];
            [userInfo addObject:@[user_id, [NSNumber numberWithDouble:createdAt], [NSNumber numberWithInt:isNew]]];
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
        _totalSavedContacts = (int)contacts.count;
        [contactTableView reloadData];
        return;
    }
    
    //Now we grab the user data from the backend
    [PFCloud callFunctionInBackground:@"getSavedContacts" withParameters:@{@"usersList":userIds} block:^(id object, NSError *error) {
        
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
                                              _totalSavedContacts = (int)contacts.count;
                                              [contactTableView reloadData];
                                              return;
                                          }];
            
            UIAlertController *alertController = [UIAlertController
                                                  alertControllerWithTitle:@"Something Went Wrong"
                                                  message:@"Could not get the contacts.  Please check your internet connection, pull to refresh, and try again."
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
            profile.first_name = user[@"first_name"];
            profile.imageFile = user[@"profilePicture"];
            profile.isComplete = 1;
            
            NSNumber* createdAt = [NSNumber numberWithDouble:0.0];
            NSNumber* isNew = [NSNumber numberWithInt:0];
            //get the created at time
            for(NSArray* u in userInfo)
            {
                if([u[0] isEqualToString:profile.user_id])
                {
                    createdAt = u[1];
                    isNew = u[2];
                    break;
                }
            }
            [tmpProfiles addObject:@[profile,createdAt, isNew]];
            
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
        [contacts addObjectsFromArray:tmpProfiles];
        
        NSLog(@"profiles is %@", contacts);
        [self.refreshControl endRefreshing];
        [contactTableView reloadData];
    }];
}

//method called when pull to refresh happens
-(void) pullRefreshSavedProfiles
{
    //reset the current page, oldest time, profiles, and recompute the total pages
    _currentPage = 1;
    _oldestTime = [[NSDate date] timeIntervalSince1970];
    _totalSavedContacts = 0;
    [contacts removeAllObjects];
    
    __block bool inQueue = YES;
    //get the main database
    MainDatabase* md = [MainDatabase shared];
    [md.queue inDatabase:^(FMDatabase *db) {
        NSString *countQuery = @"SELECT COUNT(*) FROM CONTACT";
        FMResultSet* s = [db executeQuery:countQuery];
        //Loop through all the returned rows (should be just one)
        while( [s next] )
        {
            _totalSavedContacts += [s intForColumnIndex:0];
        }
        
        //we have a count, so we can set the total pages
        _totalPages = (_totalSavedContacts/PROFILES_PER_PAGE)+1;
        inQueue = NO;
    }];
    
    //just loop
    while(inQueue)
        ;
    
    NSLog(@"total saved contacts is %d", (int)_totalSavedContacts);
    
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
    if(!contacts.count)
    {
        // Display a message when the table is empty
        UILabel *messageLabel = [[UILabel alloc] initWithFrame:CGRectMake(0, 0, self.contactTableView.bounds.size.width, self.contactTableView.bounds.size.height)];
        
        messageLabel.text = @"There are no saved contact cards.";
        messageLabel.textColor = [UIColor blackColor];
        messageLabel.numberOfLines = 0;
        messageLabel.textAlignment = NSTextAlignmentCenter;
        messageLabel.font = [UIFont fontWithName:@"HelveticaNeue-Italic" size:20];
        [messageLabel sizeToFit];
        
        self.contactTableView.backgroundView = messageLabel;
        self.contactTableView.separatorStyle = UITableViewCellSeparatorStyleNone;
        return 0;
    }
    
    //Need to make sure we fix the background properly
    self.contactTableView.separatorStyle = UITableViewCellSeparatorStyleSingleLine;
    self.contactTableView.backgroundView = nil;
    
    // Return the number of rows in the section.
    if((_currentPage<_totalPages) && (contacts.count != _totalSavedContacts))
    {
        NSLog(@"returning additional row %d", (int)contacts.count+1);
        return (contacts.count + 1);
    }
    else
    {
        NSLog(@"profiles count is %d", (int)contacts.count);
        return contacts.count;
    }
}

-(void) checkPending
{
    UserProfile* profile = contacts[_selectedCell][0];
    
    //letting the user know
    UIAlertAction *newOkAction = [UIAlertAction
                                  actionWithTitle:NSLocalizedString(@"Accept", @"Accept action")
                                  style:UIAlertActionStyleDefault
                                  handler:^(UIAlertAction *action)
                                  {
                                      //update the database and segue
                                      //get the main database
                                      bool __block inQuery = YES;
                                      MainDatabase* md = [MainDatabase shared];
                                      [md.queue inDatabase:^(FMDatabase *db) {
                                          NSString *updateSQL = @"UPDATE contact SET is_new = ? WHERE user_id = ?";
                                          NSArray* values = @[[NSNumber numberWithInt:0], profile.user_id];
                                          [db executeUpdate:updateSQL withArgumentsInArray:values];
                                          inQuery = NO;
                                      }];
                                      while(inQuery);
                                      //update the array item
                                      NSArray* tmp = @[contacts[_selectedCell][0],contacts[_selectedCell][1], [NSNumber numberWithInt:0]];
                                      [contacts setObject:tmp atIndexedSubscript:_selectedCell];
                                      [contactTableView reloadData];
                                      [self performSegueWithIdentifier:@"viewContactCardSegue" sender:self];
                                      return;
                                  }];
    UIAlertAction *cancelAction = [UIAlertAction
                                   actionWithTitle:NSLocalizedString(@"Discard", @"Discard action")
                                   style:UIAlertActionStyleCancel
                                   handler:^(UIAlertAction *action)
                                   {
                                       //delete the contact info for the user
                                       //get the main database
                                       bool __block inQuery = YES;
                                       MainDatabase* md = [MainDatabase shared];
                                       [md.queue inDatabase:^(FMDatabase *db) {
                                           //delete the user
                                           NSString *deleteUserSQL = @"DELETE FROM contact WHERE user_id = ?";
                                           NSArray* values = @[profile.user_id];
                                           [db executeUpdate:deleteUserSQL withArgumentsInArray:values];
                                           //delete phones and emails too
                                           NSString *deletePhoneSQL = @"DELETE FROM phone WHERE user_id = ?";
                                           [db executeUpdate:deletePhoneSQL withArgumentsInArray:values];
                                           NSString *deleteEmailSQL = @"DELETE FROM email WHERE user_id = ?";
                                           [db executeUpdate:deleteEmailSQL withArgumentsInArray:values];
                                           inQuery = NO;
                                       }];
                                       //idle while in query
                                       while(inQuery)
                                           ;
                                       [contacts removeObjectAtIndex:_selectedCell];
                                       [contactTableView reloadData];
                                   }];
    
    UIAlertController *alertController = [UIAlertController
                                          alertControllerWithTitle:@"New Contact Card"
                                          message:[NSString stringWithFormat:@"%@ sent you a contact card.", profile.first_name]
                                          preferredStyle:UIAlertControllerStyleAlert];
    
    [alertController addAction:cancelAction];
    [alertController addAction:newOkAction];
    [self presentViewController:alertController animated:YES completion:nil];
    return;
}



- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath {
    ContactCardListTableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:@"cardCell" forIndexPath:indexPath];
    cell.separatorInset = UIEdgeInsetsZero;
    cell.profileImageView.layer.cornerRadius = 5;
    cell.profileImageView.clipsToBounds = YES;
    cell.badgeLabel.hidden = YES;
    cell.accessoryType = UITableViewCellAccessoryNone;
    //normal other profiles cell
    if(indexPath.row < [contacts count])
    {
        cell.tag = PROFILE_CELL;
        cell.profileImageView.hidden = NO;
        cell.nameLabel.hidden = NO;
        cell.createdAtLabel.hidden = NO;
        cell.activityIndicator.hidden = YES;
        [cell.activityIndicator stopAnimating];
        
        UserProfile* profile = contacts[indexPath.row][0];
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
        
        NSDate* date = [NSDate dateWithTimeIntervalSince1970:((NSNumber*)contacts[indexPath.row][1]).doubleValue];
        NSDateFormatter *dateFormatter = [[NSDateFormatter alloc]init];
        dateFormatter.dateFormat = @"MM/dd/yy hh:mm a";
        NSString *dateString = [dateFormatter stringFromDate: date];
        
        cell.createdAtLabel.text = [NSString stringWithFormat:@"Received at %@",dateString];
        if(((NSNumber*)contacts[indexPath.row][2]).intValue)
        {
            cell.badgeLabel.hidden = NO;
            cell.badgeLabel.layer.cornerRadius = 10;
            cell.badgeLabel.clipsToBounds = YES;
        }
        
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
    //if pending then check pending
    if(((NSNumber*)contacts[indexPath.row][2]).intValue)
        [self checkPending];
    else
        [self performSegueWithIdentifier:@"viewContactCardSegue" sender:self];
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
    if([segue.identifier isEqualToString:@"viewContactCardSegue"])
    {
        ContactCardViewController* controller = (ContactCardViewController*)segue.destinationViewController;
        UserProfile* profile = contacts[_selectedCell][0];
        profile.picture_data = [profile.imageFile getData];
        profile.picture_data_length = [NSString stringWithFormat:@"%d",(int) profile.picture_data.length ];
        controller.profile = profile;
        PrivateProfile* privProfile = [[PrivateProfile alloc]init];
        
        bool __block inQueue = YES;
        //get the main database
        MainDatabase* md = [MainDatabase shared];
        [md.queue inDatabase:^(FMDatabase *db) {
            
            NSString *phoneQuery = @"SELECT type, number FROM phone WHERE user_id = ?";
            NSArray* values = @[profile.user_id];
            FMResultSet* phoneResult = [db executeQuery:phoneQuery withArgumentsInArray:values];
            //Loop through all the returned rows and get the corresponding event data
            while( [phoneResult next] )
            {
                Phone* phone = [[Phone alloc] init];
                phone.type = [phoneResult stringForColumnIndex:0];
                phone.number = [phoneResult stringForColumnIndex:1];
                [privProfile.phoneNumbers addObject:phone];
            }
            
            //emails
            NSString *emailQuery = @"SELECT type, address FROM email WHERE user_id = ?";
            FMResultSet* emailResult = [db executeQuery:emailQuery withArgumentsInArray:values];
            //Loop through all the returned rows and get the corresponding event data
            while( [emailResult next] )
            {
                Email* email = [[Email alloc] init];
                email.type = [emailResult stringForColumnIndex:0];
                email.address = [emailResult stringForColumnIndex:1];
                [privProfile.emailAddresses addObject:email];
            }
            
            controller.privProfile = privProfile;
            inQueue = NO;
        }];
        
        while(inQueue);
    }
}


@end
