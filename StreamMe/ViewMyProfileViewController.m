//
//  ViewMyProfileViewController.m
//  WhoYu
//
//  Created by Chase Midler on 3/5/15.
//  Copyright (c) 2015 midler. All rights reserved.
//

#import "ViewMyProfileViewController.h"

@interface ViewMyProfileViewController ()

@end

@implementation ViewMyProfileViewController
@synthesize profileTableView;
- (void)viewDidLoad
{
    [super viewDidLoad];
    //side bar
    SWRevealViewController *revealViewController = self.revealViewController;
    RightMenuTableViewController* rightController = (RightMenuTableViewController*)revealViewController.rightViewController;
    rightController.originController = @"viewMyProfile";
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
    
    UITapGestureRecognizer *tap = [[UITapGestureRecognizer alloc]
                                   initWithTarget:self
                                   action:@selector(dismissKeyboard)];
    tap.cancelsTouchesInView = NO;
    [self.view addGestureRecognizer:tap];
    
    self.automaticallyAdjustsScrollViewInsets = NO;
    [_activityIndicator stopAnimating];
    // This will remove extra separators from tableview
    self.profileTableView.tableFooterView = [[UIView alloc] initWithFrame:CGRectZero];
    
    [[NSNotificationCenter defaultCenter] addObserver:self
                                             selector:@selector(myProfileNotification:)
                                                 name:@"changedProfilePicture"
                                               object:nil];
    
    personalInformation = [[NSMutableArray alloc] init];
    
    NSLog(@"after personal information");
    
    //always do this
    [self setSharedValues];
    
    UITapGestureRecognizer *pictureTap = [[UITapGestureRecognizer alloc] initWithTarget:self action:@selector(tapDetected)];
    pictureTap.numberOfTapsRequired = 1;
    [_pictureImageView setUserInteractionEnabled:YES];
    [_pictureImageView addGestureRecognizer:pictureTap];
    
    
}

- (void) dismissKeyboard
{
    [_aboutTextView resignFirstResponder];
    if(!_aboutTextView.text.length || [_aboutTextView.text isEqualToString:@"Share something about whoYu are!"])
    {
        _aboutTextView.text = @"Share something about whoYu are!";
        _aboutTextView.textColor = [UIColor grayColor];
    }
    [self saveStatus];
    
}

//used for updating status
- (BOOL)textView:(UITextView *)textView
shouldChangeTextInRange:(NSRange)range
 replacementText:(NSString *)text
{
    
    //check if they user is trying to enter too many characters
    if(([[textView text] length] - range.length + text.length > MAX_CHARS) && ![text isEqualToString:@"\n"])
    {
        return NO;
    }
    
    //Make return key try to save the new status
    if([text isEqualToString:@"\n"])
    {
        [textView resignFirstResponder];
        [self saveStatus];
    }
    return YES;
}

//Delegates for helping textview have placeholder text
- (void)textViewDidBeginEditing:(UITextView *)textView
{
    if([textView.text isEqualToString:@"Share something about whoYu are!"] || [textView.text isEqualToString:@"I'm new to whoYu.  I should probably fill in my whoYu summary!"])
    {
        textView.text = @"";
    }
    textView.textColor = [UIColor blackColor];
    
    [textView becomeFirstResponder];
}

//Continuation delegate for placeholder text
- (void)textViewDidEndEditing:(UITextView *)textView
{
    if(!textView.text.length || [textView.text isEqualToString:@"Share something about whoYu are!"])
    {
        textView.text = @"Share something about whoYu are!";
        textView.textColor = [UIColor grayColor];
    }

    
    [textView resignFirstResponder];
    [self saveStatus];
}

//Delegate when something gets edited in the text view
- (void)textViewDidChange:(UITextView *)textView
{
    [self updateLabel];
}

//Save the new updated status
- (void) saveStatus
{
    NSLog(@"save status");
    //Need to save new status to database if it has changed
    StoreUserProfile* sup = [StoreUserProfile shared];
    UserProfile* profile = sup.profile;
    if(![_aboutTextView.text isEqualToString:profile.about])
    {
        
        PFUser* user = [PFUser currentUser];
        NSString* about = @"";
        //If update status to nothing then display correct status
        if(!_aboutTextView.text.length || [_aboutTextView.text isEqualToString:@"Share something about whoYu are!"])
            about = @"Not displaying";
        else
            about = _aboutTextView.text;
        
        //check if we aren't changing anything
        if([profile.about isEqualToString:about])
            return;
        
        profile.about = about;
        
        NSLog(@"profile.about = %@", profile.about);
        
        [sup setProfile:profile];
        
        //get the main database
        MainDatabase* md = [MainDatabase shared];
        [md.queue inDatabase:^(FMDatabase *db) {
            NSString *updateSQL = @"UPDATE user SET about = ? WHERE is_me = ?";
            NSArray* values = @[profile.about, [NSNumber numberWithInt:1]];
            [db executeUpdate:updateSQL withArgumentsInArray:values];
        }];
        
        
        [user setObject:profile.about forKey:@"about"];
        [user saveInBackground];
    }
}

-(void) setupMyData
{
    [personalInformation removeAllObjects];
    StoreUserProfile* sup = [StoreUserProfile shared];
    UserProfile* profile = sup.profile;
    
    //add data to personal information
    [personalInformation addObject:@[@"Age", profile.birthday]];
    [personalInformation addObject:@[@"Gender", profile.sex]];
    [personalInformation addObject:@[@"Interested in", profile.interested_in]];
    [personalInformation addObject:@[@"Relationship Status", profile.relationship_status]];
    
    
    //Check if we have stored professional data
    StoreProfessionalProfile* spp = [StoreProfessionalProfile shared];
    ProfessionalProfile* proP = spp.profile;
    
    
    //no professional data
    if(!profile.isShowingProfessional || !(proP.schools.count + proP.works.count))
        _hasProfessionalData = NO;
    else
        _hasProfessionalData = YES;
    
    [self sortProfessional];
}

- (void) viewWillAppear:(BOOL)animated
{
    /*CGRect frame = profileTableView.tableHeaderView.frame;
    frame.size.height = HEADER_HEIGHT;
    UIView *headerView = [[UIView alloc] initWithFrame:frame];
    [profileTableView setTableHeaderView:headerView];*/
    [self setupMyData];
    [self.profileTableView addObserver:self forKeyPath:@"contentSize" options:0 context:NULL];
    
}

-(void) viewWillDisappear:(BOOL)animated
{
    [self.profileTableView removeObserver:self forKeyPath:@"contentSize" context:NULL];
}

- (void) setSharedValues
{
    StoreUserProfile* sup = [StoreUserProfile shared];
    //Setting the profile picture image
    if(sup.profile.picture_data.length)
    {
        UIImageView *picture = [[UIImageView alloc] init];
        //picture.contentMode = UIViewContentModeScaleToFill;
        picture.image = [UIImage imageWithData:sup.profile.picture_data];
        _pictureImageView.image = picture.image;
    }
    else
    {
        NSString *localPath = [[NSBundle mainBundle]bundlePath];
        NSString *imageName = [localPath stringByAppendingPathComponent:[[NSString alloc]initWithFormat:@"whoYuLogo.png"]];
        _pictureImageView.image = [UIImage imageWithContentsOfFile:imageName];
    }
    
    [_aboutTextView.layer setBorderColor:[[[UIColor grayColor] colorWithAlphaComponent:0.5] CGColor]];
    [_aboutTextView.layer setBorderWidth:2.0];
    
    //The rounded corner part, where you specify your view's corner radius:
    _aboutTextView.layer.cornerRadius = 5;
    _aboutTextView.text = sup.profile.about;
    if(!sup.profile.about.length || [sup.profile.about isEqualToString:@"Share something about whoYu are!"] || [sup.profile.about isEqualToString:@"Not displaying"])
    {
        _aboutTextView.text = @"Share something about whoYu are!";
        _aboutTextView.textColor = [UIColor grayColor];
    }
    else if ([sup.profile.about isEqualToString:@"I'm new to whoYu.  I should probably fill in my whoYu summary!"])
    {
        _aboutTextView.textColor = [UIColor grayColor];
    }
    else
        _aboutTextView.textColor = [UIColor blackColor];
    
    //update character count
    [self updateLabel];
}

//Count the characters
- (void) updateLabel
{
    int length = (int)_aboutTextView.text.length;
    if([_aboutTextView.text isEqualToString:@"Share something about whoYu are!"])
        length = 0;
    int charLeft = MAX_CHARS - length;
    if(charLeft <0)
        charLeft = 0;
    NSString* charCountStr = [NSString stringWithFormat:@"%i", charLeft];
    NSLog(@"charsleft: %d", charLeft);
    [_countLabel setText:charCountStr];
}

//on picture tap segue to albums
-(void) tapDetected
{
    [self performSegueWithIdentifier:@"FacebookAlbumSegue" sender:self];
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
    StoreProfessionalProfile* spp = [StoreProfessionalProfile shared];
    ProfessionalProfile* proProfile = spp.profile;
    //Counting the number of schools and works to be displayed
    for(School* s in proProfile.schools)
        [tmpSchools addObject:s];
    
    //counting work showing
    for(Work* w in proProfile.works)
            [tmpWorks addObject:w];
    
    NSLog(@"School is %@", proProfile.schools);
    NSLog(@"work is %@", proProfile.works);
    
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


/* calling load values on notification since viewwillappear is not working */
- (void) myProfileNotification:(NSNotification *) notification
{
    if ([[notification name] isEqualToString:@"changedProfilePicture"])
    {
        [self setSharedValues ];
    }
}

- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView
{
    
    //Work, school, personal
    NSInteger numberOfSections = 3;
    
    return numberOfSections;
}

/*- (NSString *)tableView:(UITableView *)tableView titleForHeaderInSection:(NSInteger)section
{
    //personal first
    switch (section) {
        case 0:
            return @"Personal Information";
            break;
        case 1:
            return @"Work Information";
            break;
        case 2:
            return @"Education Information";
            break;
        default:
            return @"Default";
            break;
    }

}*/


//creating the header view so that we can have edit buttons as well
- (UIView *)tableView:(UITableView *)tableView viewForHeaderInSection:(NSInteger)section {
    
    UILabel *title = [[UILabel alloc] initWithFrame:CGRectMake(0, 0, 200, HEADER_HEIGHT)];
    UIButton* editButton = [[UIButton alloc] initWithFrame:CGRectMake(tableView.frame.size.width-40, 0, 50, HEADER_HEIGHT)];
    UIButton* editIcon = [[UIButton alloc] initWithFrame:CGRectMake(tableView.frame.size.width-48, 7, 14, 14)];
    //UIButton* editButton;
    //UIButton* editIcon;
    
    if(section == 0)
    {
        title = [[UILabel alloc] initWithFrame:CGRectMake(0, 10, 200, HEADER_HEIGHT)];
        editButton = [[UIButton alloc] initWithFrame:CGRectMake(tableView.frame.size.width-40, 10, 50, HEADER_HEIGHT)];
        editIcon = [[UIButton alloc] initWithFrame:CGRectMake(tableView.frame.size.width-48, 17, 14, 14)];
        title.text = @"PERSONAL INFORMATION";
    }
    else if (section == 1)
    {
        /*title = [[UILabel alloc] initWithFrame:CGRectMake(0, 0, 200, HEADER_HEIGHT)];
        editButton = [[UIButton alloc] initWithFrame:CGRectMake(tableView.frame.size.width-40, 0, 50, HEADER_HEIGHT)];
        editIcon = [[UIButton alloc] initWithFrame:CGRectMake(tableView.frame.size.width-48, 7, 14, 14)];*/
        title.text = @"WORK INFORMATION";
    }
    else if (section == 2)
    {
        /*title = [[UILabel alloc] initWithFrame:CGRectMake(0, 0, 200, HEADER_HEIGHT)];
        editButton = [[UIButton alloc] initWithFrame:CGRectMake(tableView.frame.size.width-40, 0, 50, HEADER_HEIGHT)];
        editIcon = [[UIButton alloc] initWithFrame:CGRectMake(tableView.frame.size.width-48, 7, 14, 14)];*/
        title.text = @"EDUCATION INFORMATION";
    }
    
    [editButton setTitle:@"EDIT" forState:UIControlStateNormal];
    [editButton setTitleColor:[UIColor colorWithRed:0.0 green:122.0/255.0 blue:1.0 alpha:1.0] forState:UIControlStateNormal];
    editButton.titleLabel.font = [UIFont boldSystemFontOfSize:14];
    title.font = [UIFont boldSystemFontOfSize:14];
    editButton.backgroundColor = [UIColor clearColor];
    title.textColor = [UIColor darkTextColor];
    UIImage* image = [self imageNamed:@"edit.png" withColor:[UIColor colorWithRed:0.0 green:122.0/255.0 blue:1.0 alpha:1.0]];
    
    [editIcon setBackgroundImage:image forState:UIControlStateNormal];
    
    [editButton addTarget:self action:@selector(editButtonTouchUpInside:) forControlEvents:UIControlEventTouchUpInside];
    [editIcon addTarget:self action:@selector(editButtonTouchUpInside:) forControlEvents:UIControlEventTouchUpInside];
    
    
    UIView *headerView = [[UIView alloc] initWithFrame:CGRectMake(0, 0, tableView.frame.size.width, HEADER_HEIGHT)];
    
    [headerView addSubview:title];
    [headerView addSubview:editIcon];
    [headerView addSubview:editButton];
    editButton.tag = section;
    editIcon.tag = section;
    return headerView;
}

//Handle touches of seciton header
-(void)editButtonTouchUpInside:(UIButton*)sender {
    int section = (int)sender.tag;
    
    //Displaying subscribed and not subscribed events
    if(section== 0)
    {
        [self performSegueWithIdentifier:@"editPersonalSegue" sender:self];
    }
    else if(section == 1)
    {
        [self performSegueWithIdentifier:@"editWorkSegue" sender:self];
    }
    else if(section == 2)
    {
        [self performSegueWithIdentifier:@"editSchoolSegue" sender:self];
    }
}


- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section
{
    switch (section) {
        case 0:
            return personalInformation.count;
            break;
        case 1:
            //see if there are work objects
            if(works.count)
            {
                //add an add works row
                if(works.count<MAX_WORKS)
                    return works.count+1;
                else//just return the number of works
                    return works.count;
            }
            else //add an add works row
                return 1;
            break;
        case 2:
            //see if there are school objects
            if(schools.count)
            {
                //add an add schools row
                if(schools.count < MAX_SCHOOLS)
                    return schools.count+1;
                else//just return the number of schools
                    return schools.count;
            }
            else//add an add schools row
                return 1;
            break;
        default:
            return 0;
            break;
    }
}

- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath
{
    UITableViewCell *cell = [tableView cellForRowAtIndexPath:indexPath];
    [cell setSelectionStyle:UITableViewCellSelectionStyleGray];
    
    //if we clicked on an add cell
    if(indexPath.section == 1)//work
        [self performSegueWithIdentifier:@"AddWorkSegue" sender:self];
    else if (indexPath.section == 2)//school
        [self performSegueWithIdentifier:@"AddSchoolSegue" sender:self];
    [profileTableView reloadData];
}

//Show data in cells
- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath
{
    
    static NSString *CellIdentifier = @"profileCell";
    ViewMyProfileTableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:CellIdentifier forIndexPath:indexPath];
    cell.separatorInset = UIEdgeInsetsZero;
    cell.userInteractionEnabled = NO;
    //hide all of the labels first
    cell.viewTypeLabel.hidden = YES;
    cell.valueLabel.hidden = YES;
    cell.degreesLabel.hidden = YES;
    cell.typeLabel.hidden = YES;
    cell.dateLabel.hidden = YES;
    cell.nameLabel.hidden = YES;
    cell.addProfessionalLabel.hidden = YES;
    
    //we know which section we are in so we can populate the data appropriately
    if(indexPath.section==0)
    {
        StoreUserProfile* sup = [StoreUserProfile shared];
        cell.valueLabel.hidden = NO;
        cell.viewTypeLabel.hidden = NO;
        
        if(![personalInformation[indexPath.row][0] isEqualToString:@"Age"])
            cell.valueLabel.text = personalInformation[indexPath.row][1];
        else
        {
            NSString* age;
            NSString* birthday = sup.profile.birthday;
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
    else if (indexPath.section == 1)
    {
        //now see if this is an add row or a work row
        if(indexPath.row >= works.count) //add row
        {
            cell.userInteractionEnabled = YES;
            cell.addProfessionalLabel.hidden = NO;
            cell.addProfessionalLabel.text = @"Add A Job";
            //give addanother phone button dashed line border
            [self drawDashedBorderAroundView:cell.addProfessionalLabel];
        }
        else // a work row
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
    }
    else if(indexPath.section == 2)
    {
        //now see if this is an add row or a school row
        if(indexPath.row >= schools.count) //add row
        {
            cell.userInteractionEnabled = YES;
            cell.addProfessionalLabel.hidden = NO;
            cell.addProfessionalLabel.text = @"Add A School";
            //give addanother phone button dashed line border
            [self drawDashedBorderAroundView:cell.addProfessionalLabel];
        }
        else // a school row
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
    }
    
    
    return cell;
}

- (CGFloat)tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath
{
    //need to figure out what section the data is in
    
    
    //if not schools, return height of 50
    if(indexPath.section != 2 || indexPath.row >= schools.count)
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
    NSLog(@"checking section header height");
    if(!section)
        return HEADER_HEIGHT+FIRST_HEADER_HEIGHT;
    else
        return HEADER_HEIGHT;
}



//observer to make sure we adjust the height of the tableview properly
- (void)observeValueForKeyPath:(NSString *)keyPath ofObject:(id)object change:(NSDictionary *)change context:(void *)context
{
    //NSLog(@"key path is %@", keyPath);
    NSLog(@"tableview height constraint is %f", _tableViewHeightConstraint.constant);
    NSLog(@"view height constraint is %f",  _heightConstraint.constant);
    CGRect frame = self.profileTableView.frame;
    frame.size = self.profileTableView.contentSize;
    
    [_tableViewHeightConstraint setConstant:frame.size.height];
    [_heightConstraint setConstant:(frame.size.height + _pictureImageView.frame.size.height)];
    
    
    /*NSLayoutConstraint* newHeightCon = [NSLayoutConstraint ]
     
     [self.dynamicView addConstraints:[NSLayoutConstraint constraintsWithVisualFormat:[NSString stringWithFormat: @"V:[dynamicView(==%f)]", self.profileTableView.frame.size.height + _pictureImageView.image.size.height]
     options:0
     metrics:nil
     views:NSDictionaryOfVariableBindings(self.dynamicView)]];*/
    
    
}

-(UIImage *)imageNamed:(NSString *)name withColor:(UIColor *)color {
    
    UIImage *img = [UIImage imageNamed:name];
    CGRect rect = CGRectMake(0.0f, 0.0f, img.size.width, img.size.height);
    
    if (UIGraphicsBeginImageContextWithOptions) {
        CGFloat imageScale = 1.0f;
        if ([self respondsToSelector:@selector(scale)])  // The scale property is new with iOS4.
            imageScale = img.scale;
        UIGraphicsBeginImageContextWithOptions(img.size, NO, imageScale);
    }
    else {
        UIGraphicsBeginImageContext(img.size);
    }
    
    [img drawInRect:rect];
    
    CGContextRef context = UIGraphicsGetCurrentContext();
    CGContextSetBlendMode(context, kCGBlendModeSourceIn);
    
    CGContextSetFillColorWithColor(context, color.CGColor);
    CGContextFillRect(context, rect);
    
    UIImage *image = UIGraphicsGetImageFromCurrentImageContext();
    UIGraphicsEndImageContext();
    
    return image;
    
}

- (void)drawDashedBorderAroundView:(UIView *)v
{
    //border definitions
    CGFloat cornerRadius = 10;
    CGFloat borderWidth = 2;
    NSInteger dashPattern1 = 8;
    NSInteger dashPattern2 = 8;
    UIColor *lineColor = [UIColor grayColor];
    
    //drawing
    CGRect frame = v.bounds;
    
    CAShapeLayer *_shapeLayer = [CAShapeLayer layer];
    
    //creating a path
    CGMutablePathRef path = CGPathCreateMutable();
    
    //drawing a border around a view
    CGPathMoveToPoint(path, NULL, 0, frame.size.height - cornerRadius);
    CGPathAddLineToPoint(path, NULL, 0, cornerRadius);
    CGPathAddArc(path, NULL, cornerRadius, cornerRadius, cornerRadius, M_PI, -M_PI_2, NO);
    CGPathAddLineToPoint(path, NULL, frame.size.width - cornerRadius, 0);
    CGPathAddArc(path, NULL, frame.size.width - cornerRadius, cornerRadius, cornerRadius, -M_PI_2, 0, NO);
    CGPathAddLineToPoint(path, NULL, frame.size.width, frame.size.height - cornerRadius);
    CGPathAddArc(path, NULL, frame.size.width - cornerRadius, frame.size.height - cornerRadius, cornerRadius, 0, M_PI_2, NO);
    CGPathAddLineToPoint(path, NULL, cornerRadius, frame.size.height);
    CGPathAddArc(path, NULL, cornerRadius, frame.size.height - cornerRadius, cornerRadius, M_PI_2, M_PI, NO);
    
    //path is set as the _shapeLayer object's path
    _shapeLayer.path = path;
    CGPathRelease(path);
    
    _shapeLayer.backgroundColor = [[UIColor clearColor] CGColor];
    _shapeLayer.frame = frame;
    _shapeLayer.masksToBounds = NO;
    [_shapeLayer setValue:[NSNumber numberWithBool:NO] forKey:@"isCircle"];
    _shapeLayer.fillColor = [[UIColor clearColor] CGColor];
    _shapeLayer.strokeColor = [lineColor CGColor];
    _shapeLayer.lineWidth = borderWidth;
    _shapeLayer.lineDashPattern = [NSArray arrayWithObjects:[NSNumber numberWithInteger:dashPattern1], [NSNumber numberWithInteger:dashPattern2], nil];
    _shapeLayer.lineCap = kCALineCapRound;
    
    //_shapeLayer is added as a sublayer of the view, the border is visible
    [_shapeLayer removeFromSuperlayer];
    [v.layer addSublayer:_shapeLayer];
    v.layer.cornerRadius = cornerRadius;
}


@end
