//
//  EditSchoolsTableViewController.m
//  Proximity
//
//  Created by Chase Midler on 1/15/15.
//  Copyright (c) 2015 midler. All rights reserved.
//

#import "EditSchoolsTableViewController.h"

@interface EditSchoolsTableViewController ()

@end

@implementation EditSchoolsTableViewController
@synthesize schoolTableView;
- (void)viewDidLoad {
    [super viewDidLoad];
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
}

-(void) viewDidAppear:(BOOL)animated
{
    [self orderSchools];
}

-(void) orderSchools
{
    StoreProfessionalProfile* spp = [StoreProfessionalProfile shared];
    //Now sort the schools based on year
    schools = [spp.profile.schools sortedArrayUsingComparator: ^(School* obj1, School* obj2) {
        
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
    
    if([schools count]>=MAX_SCHOOLS)
        _addButton.enabled = NO;
    else
        _addButton.enabled = YES;
    
    [schoolTableView reloadData];
}

- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView {
    if([schools count])
    {
        self.schoolTableView.separatorStyle = UITableViewCellSeparatorStyleSingleLine;
        self.schoolTableView.backgroundView = nil;
        return 1;
    }
    else
    {
        // Display a message when the table is empty
        UILabel *messageLabel = [[UILabel alloc] initWithFrame:CGRectMake(0, 0, self.schoolTableView.bounds.size.width, self.schoolTableView.bounds.size.height)];
        
        messageLabel.text = @"You have no schools on your profile.";
        messageLabel.textColor = [UIColor blackColor];
        messageLabel.numberOfLines = 0;
        messageLabel.textAlignment = NSTextAlignmentCenter;
        messageLabel.font = [UIFont fontWithName:@"HelveticaNeue-Italic" size:20];
        [messageLabel sizeToFit];
        
        self.schoolTableView.backgroundView = messageLabel;
        self.schoolTableView.separatorStyle = UITableViewCellSeparatorStyleNone;
        return 0;
    }

}

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section {
    // Return the number of rows in the section.
    return [schools count];
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath {
    EditSchoolsTableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:@"schoolCell" forIndexPath:indexPath];
    [cell setSelectionStyle:UITableViewCellSelectionStyleDefault];
    [cell.activityIndicator stopAnimating];
    cell.activityIndicator.center = cell.center;
    int i=0;
    School* school = schools[indexPath.row];
    
    //Now that I have the correct school, populate the cell
    cell.nameLabel.text = school.school_name;
    cell.yearLabel.text = school.year;
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
    
    return cell;
}

//On click of cell, segue
- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath
{
    UITableViewCell *cell = [tableView cellForRowAtIndexPath:indexPath];
    [cell setSelectionStyle:UITableViewCellSelectionStyleDefault];
    _selectedCell = (int)indexPath.row;
    
    [self performSegueWithIdentifier:@"schoolSegue" sender:self];
    
}

- (CGFloat)tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath
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
    gettingSizeLabel.lineBreakMode = NSLineBreakByTruncatingTail;
    CGSize maximumLabelSize = CGSizeMake(279, 44);
    
    CGSize expectSize = [gettingSizeLabel sizeThatFits:maximumLabelSize];
    
    //NSLog(@"expect size for %@ is %d", degreeString, (int)expectSize.height);
    
    return 50.0f + expectSize.height;
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

/*  Override to support editing the table view.
 If right swipe, delete
 */
- (void)tableView:(UITableView *)tableView commitEditingStyle:(UITableViewCellEditingStyle)editingStyle forRowAtIndexPath:(NSIndexPath *)indexPath {
    
    //if we swiped to delete
    if (editingStyle == UITableViewCellEditingStyleDelete) {
        EditSchoolsTableViewCell* cell = [tableView dequeueReusableCellWithIdentifier:@"schoolCell" forIndexPath:indexPath];
        [cell.activityIndicator startAnimating];
        School* schoolObject = schools[indexPath.row];
        PFQuery* schoolQuery = [PFQuery queryWithClassName:@"School"];
        [schoolQuery whereKey:@"objectId" equalTo:schoolObject.school_id];
        [schoolQuery findObjectsInBackgroundWithBlock:^(NSArray *objects, NSError *error) {
            
            //error checking
            if(error)
            {
                [cell.activityIndicator stopAnimating];
                [self orderSchools];
                return;
            }
            
            PFObject* school = objects[0];
            
            //delete the school and degrees
            [school deleteEventually];
            
            //delete from storedprofessionalprofile as well
            StoreProfessionalProfile* ssp = [StoreProfessionalProfile shared];
            ProfessionalProfile* profile = ssp.profile;
            [profile.schools removeObject:schoolObject];
            [ssp setProfile:profile];
            
            //cleanup
            //get the main database
            MainDatabase* md = [MainDatabase shared];
            [md.queue inDatabase:^(FMDatabase *db) {
                //delete degrees first
                NSString *deleteDegreesSQL = @"DELETE FROM degree WHERE school_id = ?";
                NSArray* values = @[schoolObject.school_id];
                [db executeUpdate:deleteDegreesSQL withArgumentsInArray:values];
                //delete school
                NSString *deleteSQL = @"DELETE FROM school WHERE school_id = ?";
                [db executeUpdate:deleteSQL withArgumentsInArray:values];
                [cell.activityIndicator stopAnimating];
                [self orderSchools];
            }];
        }];
    }
}

// In a storyboard-based application, you will often want to do a little preparation before navigation
- (void)prepareForSegue:(UIStoryboardSegue *)segue sender:(id)sender {
    if([segue.identifier isEqualToString:@"schoolSegue"])
    {
        SchoolTableViewController *controller = (SchoolTableViewController *)segue.destinationViewController;
        controller.school_id = ((School*)schools[_selectedCell]).school_id;
    }
}

@end
