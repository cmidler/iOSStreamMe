//
//  EditWorkTableViewController.m
//  Proximity
//
//  Created by Chase Midler on 1/15/15.
//  Copyright (c) 2015 midler. All rights reserved.
//

#import "EditWorkTableViewController.h"

@interface EditWorkTableViewController ()

@end

@implementation EditWorkTableViewController
@synthesize workTableView;
- (void)viewDidLoad {
    [super viewDidLoad];
    
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

-(void) viewDidAppear:(BOOL)animated
{
    [self orderWorks];
}

-(void) orderWorks
{
    StoreProfessionalProfile* spp = [StoreProfessionalProfile shared];
    //Now sort the works array based on "date"
    works = [spp.profile.works sortedArrayUsingComparator: ^(Work* obj1, Work* obj2) {
        
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

    
    if([works count]>=MAX_WORKS)
        _addButton.enabled = NO;
    else
        _addButton.enabled = YES;
    
    [workTableView reloadData];
}

- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView {
    if([works count])
    {
        self.workTableView.separatorStyle = UITableViewCellSeparatorStyleSingleLine;
        self.workTableView.backgroundView = nil;
        return 1;
    }
    else
    {
        // Display a message when the table is empty
        UILabel *messageLabel = [[UILabel alloc] initWithFrame:CGRectMake(0, 0, self.workTableView.bounds.size.width, self.workTableView.bounds.size.height)];
        
        messageLabel.text = @"You have no work on your profile.";
        messageLabel.textColor = [UIColor blackColor];
        messageLabel.numberOfLines = 0;
        messageLabel.textAlignment = NSTextAlignmentCenter;
        messageLabel.font = [UIFont fontWithName:@"HelveticaNeue-Italic" size:20];
        [messageLabel sizeToFit];
        
        self.workTableView.backgroundView = messageLabel;
        self.workTableView.separatorStyle = UITableViewCellSeparatorStyleNone;
        return 0;
    }
    
}

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section {
    // Return the number of rows in the section.
    return [works count];
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath {
    EditWorkTableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:@"workCell" forIndexPath:indexPath];
    [cell.activityIndicator stopAnimating];
    cell.activityIndicator.center = cell.center;
    //Configure the cell...
    Work* work = works[indexPath.row];
    
    //Now that I have the correct work, populate the cell
    cell.employerLabel.text = work.employer_name;
    
    //need to do customization of date if the end date is 0000-00
    if([work.end_date isEqualToString:@"0000-00"])
        cell.endDateLabel.text = @"Not Showing";
    else if ([work.end_date isEqualToString:@"Present"])
        cell.endDateLabel.text = work.end_date;
    else//get the year
        cell.endDateLabel.text = [work.end_date substringFromIndex:(work.end_date.length)-4];
    
    cell.positionLabel.text = work.position;
    
    return cell;
}

//On click of cell, segue
- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath
{
    UITableViewCell *cell = [tableView cellForRowAtIndexPath:indexPath];
    [cell setSelectionStyle:UITableViewCellSelectionStyleDefault];
    _selectedCell = (int)indexPath.row;
    
    [self performSegueWithIdentifier:@"workSegue" sender:self];
    
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
        EditWorkTableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:@"workCell" forIndexPath:indexPath];
        [cell.activityIndicator startAnimating];
        Work* workObject = works[indexPath.row];
        PFQuery* workQuery = [PFQuery queryWithClassName:@"Work"];
        [workQuery whereKey:@"objectId" equalTo:workObject.work_id];
        [workQuery findObjectsInBackgroundWithBlock:^(NSArray *objects, NSError *error) {
            
            //error checking
            if(error)
            {
                [cell.activityIndicator stopAnimating];
                [self orderWorks];
                return;
            }
            
            
            for(PFObject* work in objects)
                [work deleteEventually];
                
            //delete from storedprofessionalprofile as well
            StoreProfessionalProfile* ssp = [StoreProfessionalProfile shared];
            ProfessionalProfile* profile = ssp.profile;
            [profile.works removeObject:workObject];
            [ssp setProfile:profile];
            
            //cleanup
            //get the main database
            MainDatabase* md = [MainDatabase shared];
            [md.queue inDatabase:^(FMDatabase *db) {
                NSString *deleteSQL = @"DELETE FROM work WHERE work_id = ?";
                NSArray* values = @[workObject.work_id];
                [db executeUpdate:deleteSQL withArgumentsInArray:values];
                [cell.activityIndicator stopAnimating];
                [self orderWorks];
            }];
        }];
    }
}

// In a storyboard-based application, you will often want to do a little preparation before navigation
- (void)prepareForSegue:(UIStoryboardSegue *)segue sender:(id)sender {
    if([segue.identifier isEqualToString:@"workSegue"])
    {
        WorkTableViewController *controller = (WorkTableViewController *)segue.destinationViewController;
        controller.work_id = ((Work*)works[_selectedCell]).work_id;
    }
}



@end
