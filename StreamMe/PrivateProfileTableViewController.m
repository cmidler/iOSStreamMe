//
//  PrivateProfileTableViewController.m
//  WhoYu
//
//  Created by Chase Midler on 1/26/15.
//  Copyright (c) 2015 midler. All rights reserved.
//

#import "PrivateProfileTableViewController.h"

@interface PrivateProfileTableViewController ()

@end

@implementation PrivateProfileTableViewController
@synthesize privateTableView;
- (void)viewDidLoad {
    [super viewDidLoad];
    self.tableView.tableFooterView = [[UIView alloc] initWithFrame:CGRectZero];
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

-(void) viewWillAppear:(BOOL)animated
{
    [self setup];
    
}

-(void) setup
{
    [privateTableView reloadData];
}

- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView {
    // Return the number of sections.
    
    //check on phone numbers first
    StorePrivateProfile* spp = [StorePrivateProfile shared];
    PrivateProfile* profile = spp.profile;
    int numberOfSections = !!profile.phoneNumbers.count + !!profile.emailAddresses.count;
    //if number of sections is 0, let the user know there is no data stored
    if(!numberOfSections)
    {
        // Display a message when the table is empty
        UILabel *messageLabel = [[UILabel alloc] initWithFrame:CGRectMake(0, 0, self.privateTableView.bounds.size.width, self.privateTableView.bounds.size.height)];
        
        messageLabel.text = @"No private information is currently saved.";
        messageLabel.textColor = [UIColor blackColor];
        messageLabel.numberOfLines = 0;
        messageLabel.textAlignment = NSTextAlignmentCenter;
        messageLabel.font = [UIFont fontWithName:@"HelveticaNeue-Italic" size:20];
        [messageLabel sizeToFit];
        
        self.privateTableView.backgroundView = messageLabel;
        self.privateTableView.separatorStyle = UITableViewCellSeparatorStyleNone;
    }
    else
    {
        self.privateTableView.separatorStyle = UITableViewCellSeparatorStyleSingleLine;
        self.privateTableView.backgroundView = nil;
    }
    
    return numberOfSections;
}

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section {

    //need to find out how many sections there are and then figure out which section I am in
    //check on phone numbers first
    StorePrivateProfile* spp = [StorePrivateProfile shared];
    PrivateProfile* profile = spp.profile;
    int numberOfSections = !!profile.phoneNumbers.count + !!profile.emailAddresses.count;
    
    //both phones and emails
    if(numberOfSections == 2)
    {
        //phones are section 0
        if(section)
        {
            return profile.emailAddresses.count;
        }
        else
        {
            return profile.phoneNumbers.count;
        }
    }
    //Only 1 section so either emails or phones
    else if(profile.emailAddresses.count)
        return profile.emailAddresses.count;
    else
        return profile.phoneNumbers.count;
    
}

//Get the title for each section
- (NSString *)tableView:(UITableView *)tableView titleForHeaderInSection:(NSInteger)section
{
    StorePrivateProfile* spp = [StorePrivateProfile shared];
    PrivateProfile* profile = spp.profile;
    int numberOfSections = !!profile.phoneNumbers.count + !!profile.emailAddresses.count;
    //both phones and emails
    if(numberOfSections == 2)
    {
        //phones are section 0
        if(section)
        {
            return @"Email Addresses";
        }
        else
        {
            return @"Phone Numbers";
        }
    }
    //Only 1 section so either emails or phones
    else if(profile.emailAddresses.count)
        return @"Email Addresses";
    else
        return @"Phone Numbers";
    
}


- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath {
    PrivateProfileTableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:@"privateCell" forIndexPath:indexPath];
    cell.separatorInset = UIEdgeInsetsZero;
    cell.userInteractionEnabled = NO;
    StorePrivateProfile* spp = [StorePrivateProfile shared];
    PrivateProfile* profile = spp.profile;
    int numberOfSections = !!profile.phoneNumbers.count + !!profile.emailAddresses.count;
    
    //go through the sections and the rows to show the right data
    if(numberOfSections == 2)
    {
        //email addresses
        if(indexPath.section)
        {
            cell.typeLabel.text = ((Email*)profile.emailAddresses[indexPath.row]).type;
            cell.valueLabel.text = ((Email*)profile.emailAddresses[indexPath.row]).address;
        }
        //phone numbers
        else
        {
            cell.typeLabel.text = ((Phone*)profile.phoneNumbers[indexPath.row]).type;
            cell.valueLabel.text = ((Phone*)profile.phoneNumbers[indexPath.row]).number;
        }
    }
    //emails
    else if (profile.emailAddresses.count)
    {
        cell.typeLabel.text = ((Email*)profile.emailAddresses[indexPath.row]).type;
        cell.valueLabel.text = ((Email*)profile.emailAddresses[indexPath.row]).address;
    }
    //phone numbers
    else
    {
        cell.typeLabel.text = ((Phone*)profile.phoneNumbers[indexPath.row]).type;
        cell.valueLabel.text = ((Phone*)profile.phoneNumbers[indexPath.row]).number;
    }
    
    return cell;
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

- (IBAction)editAction:(id)sender {
    [self performSegueWithIdentifier:@"editPrivateSegue" sender:self];
}
@end
