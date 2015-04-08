//
//  PersonalDetailsTableViewController.m
//  Proximity
//
//  Created by Chase Midler on 1/5/15.
//  Copyright (c) 2015 midler. All rights reserved.
//

#import "PersonalDetailsTableViewController.h"

@interface PersonalDetailsTableViewController ()

@end

@implementation PersonalDetailsTableViewController
@synthesize personalTableView;
- (void)viewDidLoad {
    [super viewDidLoad];
    
    // This will remove extra separators from tableview
    self.tableView.tableFooterView = [[UIView alloc] initWithFrame:CGRectZero];
    
}

-(void)viewWillAppear:(BOOL)animated
{
    [self setUp];
}

//helper function to populate table
-(void) setUp
{
    personalDetails = @[@"Age", @"Gender",  @"Relationship Status", @"Interested In"];
    [personalTableView reloadData];
    
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView {
    return 1;
}

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section {
    return [personalDetails count];
}


- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath {
    PersonalDetailsTableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:@"personalCell" forIndexPath:indexPath];
    cell.separatorInset = UIEdgeInsetsZero;
    
    int row = (int)indexPath.row;
    
    //Setting disabled or showing that you can click to edit if it is your profile
    if(_isMyProfile && row) //don't allow them to edit birthday
    {
        cell.userInteractionEnabled = YES;
        cell.accessoryType = UITableViewCellAccessoryDisclosureIndicator;
        NSLog(@"Should show chevrons!!");
    }
    else
    {
        cell.userInteractionEnabled = NO;
        cell.accessoryType = UITableViewCellAccessoryNone;
        NSLog(@"won't show chevrons");
    }
    
    
    
    cell.typeLabel.text = [NSString stringWithFormat:@"%@:",personalDetails[row]];
    //just do an if statement to see what to display
    if(!row)//AGE
    {
        NSString* age;
        NSString* birthday = _profile.birthday;
        if(!birthday || birthday.length ==0 || [birthday isEqualToString:@"01/01/1900"])
        {
            age = @"Not Sharing";
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
    else if (row == 1)//GENDER
    {
        cell.valueLabel.text = _profile.sex;
    }
    else if (row == 2)//relationship status
    {
        cell.valueLabel.text = _profile.relationship_status;
    }
    else if (row ==3)//interested in
    {
        cell.valueLabel.text = _profile.interested_in;
    }
    return cell;
}

//On click of cell, segue
- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath
{
    UITableViewCell *cell = [tableView cellForRowAtIndexPath:indexPath];
    [cell setSelectionStyle:UITableViewCellSelectionStyleGray];
    
    //Choose which segue to perform
    int row = (int)indexPath.row;
    //just do an if statement to see what to display
    if (row == 1)//GENDER
    {
        [self performSegueWithIdentifier:@"editSexSegue" sender:self];
    }
    else if (row == 2)//relationship status
    {
        [self performSegueWithIdentifier:@"editRelationshipStatusSegue" sender:self];
    }
    else if (row ==3)//interested in
    {
        [self performSegueWithIdentifier:@"editInterestedInSegue" sender:self];
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


@end
