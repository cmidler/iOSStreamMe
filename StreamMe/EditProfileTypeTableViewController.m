//
//  EditProfileTypeTableViewController.m
//  WhoYu
//
//  Created by Chase Midler on 2/7/15.
//  Copyright (c) 2015 midler. All rights reserved.
//

#import "EditProfileTypeTableViewController.h"

@interface EditProfileTypeTableViewController ()

@end

@implementation EditProfileTypeTableViewController
@synthesize editTableView;
- (void)viewDidLoad {
    [super viewDidLoad];
    self.editTableView.tableFooterView = [[UIView alloc] initWithFrame:CGRectZero];
    
}

- (void) viewWillAppear:(BOOL)animated
{
    [self loadTable];
}

//helper method for loading table data
- (void) loadTable
{
    editFields = @[@"Edit Personal Profile", @"Edit Professional Profile", @"Edit Private Profile"];
    [editTableView reloadData];
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
    
    // Return the number of rows in the section.
    return [editFields count];
}


- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath {
    EditProfileTypeTableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:@"editCell" forIndexPath:indexPath];
    cell.separatorInset = UIEdgeInsetsZero;
    
    cell.typeLabel.text = editFields[indexPath.row];
    return cell;
}

//On click of cell, segue
- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath
{
    UITableViewCell *cell = [tableView cellForRowAtIndexPath:indexPath];
    [cell setSelectionStyle:UITableViewCellSelectionStyleDefault];
    
    
    //Switch statement for segue to edit
    switch(indexPath.row)
    {
        case 0:
            [self performSegueWithIdentifier:@"PersonalSegue" sender:self];
            break;
        case 1:
            [self performSegueWithIdentifier:@"ProfessionalSegue" sender:self];
            break;
        case 2:
            [self performSegueWithIdentifier:@"PrivateSegue" sender:self];
            break;
        default:
            break;
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
