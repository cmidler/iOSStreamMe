//
//  MenuTableViewController.m
//  StreamMe
//
//  Created by Chase Midler on 1/25/15.
//  Copyright (c) 2015 midler. All rights reserved.
//

#import "MenuTableViewController.h"

@interface MenuTableViewController ()

@end

@implementation MenuTableViewController
@synthesize menuTableView;
- (void)viewDidLoad {
    [super viewDidLoad];
    self.menuTableView.tableFooterView = [[UIView alloc] initWithFrame:CGRectZero];
    //Set blue gradient background
    UIGraphicsBeginImageContext(self.view.frame.size);
    [[UIImage imageNamed:@"lightBlue.png"] drawInRect:self.view.bounds];
    UIImage *image = UIGraphicsGetImageFromCurrentImageContext();
    UIGraphicsEndImageContext();
    
    self.view.backgroundColor = [UIColor colorWithPatternImage:image];
}

-(void) viewWillAppear:(BOOL)animated
{
    [self loadTable];
    _indicatorShowing = NO;
}

//helper method for loading table data
- (void) loadTable
{
    menuActions = @[@"Me", @"Streams", @"Saved Profiles", @"Contact Cards", @"Settings"];
    [menuTableView reloadData];
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
    return [menuActions count];
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath {
    MenuTableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:@"menuCell" forIndexPath:indexPath];
    cell.separatorInset = UIEdgeInsetsMake(0, 30, 0, 0);
    cell.activityIndicator.hidden = YES;
    cell.accessoryType = UITableViewCellAccessoryNone;
    cell.actionLabel.text = menuActions[indexPath.row];
    
    //set the right accessory next to the cell
    switch (indexPath.row) {
        case 0:
            cell.menuImageView.layer.cornerRadius = 11;
            cell.menuImageView.clipsToBounds = YES;
            cell.menuImageView.image = [UIImage imageNamed:@"whoYuLogo.png"];
            break;
        case 1:
            cell.menuImageView.layer.cornerRadius = 11;
            cell.menuImageView.clipsToBounds = YES;
            cell.menuImageView.image = [UIImage imageNamed:@"stream.png"];
            break;
        case 2:
            cell.menuImageView.image = [UIImage imageNamed:@"people.png"];
            break;
        case 3:
            cell.menuImageView.image = [UIImage imageNamed:@"contact_card"];
            break;
        case 4:
            cell.menuImageView.image = [UIImage imageNamed:@"settings.png"];
            break;
        default:
            break;
    }
    
    return cell;
}

//On click of cell, segue
- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath
{
    UITableViewCell *cell = [tableView cellForRowAtIndexPath:indexPath];
    //[tableView dequeueReusableCellWithIdentifier:@"menuCell" forIndexPath:indexPath];
    [cell setSelectionStyle:UITableViewCellSelectionStyleDefault];
    
    
    //Switch statement for segue to edit
    switch(indexPath.row)
    {
        case 0:
            [self performSegueWithIdentifier:@"viewProfileSegue" sender:self];
            break;
        case 1:
            [self performSegueWithIdentifier:@"mainSegue" sender:self];
            break;
        case 2:
            [self performSegueWithIdentifier:@"viewSavedProfilesSegue" sender:self];
            break;
        case 3:
            [self performSegueWithIdentifier:@"contactCardListSegue" sender:self];
            break;
        case 4:
            [self performSegueWithIdentifier:@"settingsSegue" sender:self];
            break;
        default:
            break;
    }
    
    //[menuTableView reloadData];
}

- (CGFloat)tableView:(UITableView *)tableView heightForHeaderInSection:(NSInteger)section {
    return .1f;
}


- (void) prepareForSegue:(UIStoryboardSegue *)segue sender:(id)sender {
    
    /*if([segue.identifier isEqualToString:@"viewProfileSegue"]){
        
        UINavigationController *navController = segue.destinationViewController;
        ViewProfileViewController *controller = [navController childViewControllers].firstObject;
        StoreUserProfile* sup = [StoreUserProfile shared];
        controller.profile = sup.profile;
        controller.isMyProfile = YES;
        StoreProfessionalProfile* spp = [StoreProfessionalProfile shared];
        controller.proProfile = spp.profile;
        [self.navigationController pushViewController:controller animated:YES];
    }*/
}

@end
