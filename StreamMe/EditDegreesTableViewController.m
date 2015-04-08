//
//  EditDegreesTableViewController.m
//  Proximity
//
//  Created by Chase Midler on 1/15/15.
//  Copyright (c) 2015 midler. All rights reserved.
//

#import "EditDegreesTableViewController.h"

@interface EditDegreesTableViewController ()

@end

@implementation EditDegreesTableViewController
@synthesize degreeTableView;
- (void)viewDidLoad {
    [super viewDidLoad];
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

- (void) viewWillAppear:(BOOL)animated
{
    [self getSchool];
}

-(void) getSchool
{
    StoreProfessionalProfile* ssp = [StoreProfessionalProfile shared];
    for(School* school in ssp.profile.schools)
        if([school.school_id isEqualToString:_school_id])
        {
            _school = school;
            break;
        }
    if([_school.degrees count]>= MAX_DEGREES)
        _addButton.enabled = NO;
    else
        _addButton.enabled = YES;
    [degreeTableView reloadData];

}

- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView {
    if([_school.degrees count])
    {
        self.degreeTableView.separatorStyle = UITableViewCellSeparatorStyleSingleLine;
        self.degreeTableView.backgroundView = nil;
        return 1;
    }
    else
    {
        // Display a message when the table is empty
        UILabel *messageLabel = [[UILabel alloc] initWithFrame:CGRectMake(0, 0, self.degreeTableView.bounds.size.width, self.degreeTableView.bounds.size.height)];
        
        messageLabel.text = [NSString stringWithFormat:@"You have no degrees for %@.", _school.school_name ];
        messageLabel.textColor = [UIColor blackColor];
        messageLabel.numberOfLines = 0;
        messageLabel.textAlignment = NSTextAlignmentCenter;
        messageLabel.font = [UIFont fontWithName:@"HelveticaNeue-Italic" size:20];
        [messageLabel sizeToFit];
        
        self.degreeTableView.backgroundView = messageLabel;
        self.degreeTableView.separatorStyle = UITableViewCellSeparatorStyleNone;
        return 0;
    }
}

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section {
    // Return the number of rows in the section.
    
    return [_school.degrees count];
}


- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath {
    EditDegreesTableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:@"degreeCell" forIndexPath:indexPath];
    [cell.activityIndicator stopAnimating];
    cell.activityIndicator.center = cell.center;
    cell.degreeLabel.text = _school.degrees[indexPath.row][0];
    return cell;
}

//On click of cell, segue
- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath
{
    UITableViewCell *cell = [tableView cellForRowAtIndexPath:indexPath];
    [cell setSelectionStyle:UITableViewCellSelectionStyleDefault];
    _selectedCell = (int)indexPath.row;
    
    [self performSegueWithIdentifier:@"degreeSegue" sender:self];
    
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

// In a storyboard-based application, you will often want to do a little preparation before navigation
- (void)prepareForSegue:(UIStoryboardSegue *)segue sender:(id)sender {
    if([segue.identifier isEqualToString:@"degreeSegue"])
    {
        DegreeTableViewController *controller = (DegreeTableViewController *)segue.destinationViewController;
        controller.degree = _school.degrees[_selectedCell];
        controller.school = _school;
    }
    else if([segue.identifier isEqualToString:@"createDegreeSegue"])
    {
        CreateDegreeTableViewController *controller = (CreateDegreeTableViewController *)segue.destinationViewController;
        controller.school = _school;
    }
}

/*  Override to support editing the table view.
 If right swipe, delete
 */
- (void)tableView:(UITableView *)tableView commitEditingStyle:(UITableViewCellEditingStyle)editingStyle forRowAtIndexPath:(NSIndexPath *)indexPath {
    
    //if we swiped to delete
    if (editingStyle == UITableViewCellEditingStyleDelete) {
        
        EditDegreesTableViewCell* cell = [tableView dequeueReusableCellWithIdentifier:@"degreeCell" forIndexPath:indexPath];
        [cell.activityIndicator startAnimating];
        
        //get the degree to delete
        NSArray* d = _school.degrees[indexPath.row];
        
        
            
        PFQuery* degreeQuery = [PFQuery queryWithClassName:@"Degree"];
        [degreeQuery whereKey:@"objectId" equalTo:d[2]];
        [degreeQuery findObjectsInBackgroundWithBlock:^(NSArray *objects, NSError *error) {
            //error checking
            if(error)
            {
                [cell.activityIndicator stopAnimating];
                [self getSchool];
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
            newSchool.degrees = [NSMutableArray arrayWithArray:_school.degrees];
            [newSchool.degrees removeObject:d];
            [profile.schools removeObject:_school];
            [profile.schools addObject:newSchool];
            [ssp setProfile:profile];
            
            //cleanup
            //get the main database
            MainDatabase* md = [MainDatabase shared];
            [md.queue inDatabase:^(FMDatabase *db) {
                //delete degrees first
                NSString *deleteDegreesSQL = @"DELETE FROM degree WHERE degree_id = ?";
                NSArray* values = @[d[2]];
                [db executeUpdate:deleteDegreesSQL withArgumentsInArray:values];
                [cell.activityIndicator stopAnimating];
                [self getSchool];
            }];
        }];
    }
}


- (IBAction)addAction:(id)sender {
}
@end
