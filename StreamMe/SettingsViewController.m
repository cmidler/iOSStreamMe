//
//  SettingsViewController.m
//  WhoYu
//
//  Created by Chase Midler on 3/5/15.
//  Copyright (c) 2015 midler. All rights reserved.
//

#import "SettingsViewController.h"

@interface SettingsViewController ()

@end

@implementation SettingsViewController
@synthesize settingsTableView;
- (void)viewDidLoad {
    [super viewDidLoad];
    // Do any additional setup after loading the view.
    self.automaticallyAdjustsScrollViewInsets = NO;
    if ([self respondsToSelector:@selector(edgesForExtendedLayout)])
        self.edgesForExtendedLayout = UIRectEdgeNone;
    //NSLog(@"nav height is %f", self.navigationController.navigationBar.frame.size.height);
    _spinner = [[UIActivityIndicatorView alloc] initWithActivityIndicatorStyle:UIActivityIndicatorViewStyleWhiteLarge];
    _spinner.color = [UIColor colorWithRed:0.0 green:122.0/255.0 blue:1.0 alpha:1.0];
    [self.view addSubview:_spinner];
    _spinner.center = self.view.center;
    _spinner.hidden = YES;
    
    UIBarButtonItem *buttonRight = [[UIBarButtonItem alloc] initWithBarButtonSystemItem:UIBarButtonSystemItemDone target:self action:@selector(doneSelected:)];
    self.navigationItem.rightBarButtonItem = buttonRight;
    self.navigationItem.hidesBackButton = YES;
    
    // This will remove extra separators from tableview
    self.settingsTableView.tableFooterView = [[UIView alloc] initWithFrame:CGRectZero];
    //setting up swipes
    UISwipeGestureRecognizer * recognizer = [[UISwipeGestureRecognizer alloc] initWithTarget:self action:@selector(myLeftAction:)];
    [recognizer setDirection:(UISwipeGestureRecognizerDirectionLeft)];
    [self.view addGestureRecognizer:recognizer];
    
    settings = @[@"Contact StreamMe",@"Logout"];
    images = @[[UIImage imageNamed:@"email.png"],[UIImage imageNamed:@"logout.png"]];
    [settingsTableView reloadData];
}

-(void) myLeftAction:(id) sender
{
    [self performSegueWithIdentifier:@"popSegue" sender:self];
}

-(void) doneSelected:(id)sender
{
    [self performSegueWithIdentifier:@"popSegue" sender:self];
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

//on picture tap segue to albums
-(void) switchChanged:(id) sender
{
    AppDelegate *appDelegate = [[UIApplication sharedApplication] delegate];
    CBCentralInterface* central = [appDelegate central];
    CBPeripheralInterface* peripheral = [appDelegate peripheral];
    [central toggleCentralOn];
    [peripheral togglePeripheralOn];
}

- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView {
    // Return the number of sections.
    return 1;
}

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section {
    return [settings count];
}


- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath {
    SettingsTableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:@"settingsCell" forIndexPath:indexPath];
    cell.separatorInset = UIEdgeInsetsZero;
    cell.settingsLabel.text = settings[indexPath.row];
    cell.settingsImageView.image = images[indexPath.row];
    return cell;
}

//On click of cell, segue
- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath
{
    UITableViewCell *cell = [tableView cellForRowAtIndexPath:indexPath];
    //[tableView dequeueReusableCellWithIdentifier:@"menuCell" forIndexPath:indexPath];
    [cell setSelectionStyle:UITableViewCellSelectionStyleDefault];
    
    switch (indexPath.row) {
        case 0:
            [self emailAction];
            break;
        case 1:
        {
            [PFUser logOut];
            //reset the central and peripheral and store user profile
            AppDelegate *appDelegate = [[UIApplication sharedApplication] delegate];
            [[appDelegate central] stopScanningForUserProfiles];
            [[appDelegate peripheral] stopAdvertisingProfile];
            [[appDelegate streams] removeAllObjects];
            //delete all items in database
            [self deleteAllTables];
            
            [self performSegueWithIdentifier:@"logoutSegue" sender:self];
            break;
        }
        default:
            break;
    }
    [settingsTableView reloadData];
    
}

- (void) mailComposeController:(MFMailComposeViewController *)controller didFinishWithResult:(MFMailComposeResult)result error:(NSError *)error
{
    switch (result)
    {
        case MFMailComposeResultCancelled:
            NSLog(@"Mail cancelled");
            break;
        case MFMailComposeResultSaved:
            NSLog(@"Mail saved");
            break;
        case MFMailComposeResultSent:
            NSLog(@"Mail sent");
            break;
        case MFMailComposeResultFailed:
            NSLog(@"Mail sent failure: %@", [error localizedDescription]);
            break;
        default:
            break;
    }
    
    // Close the Mail Interface
    [self dismissViewControllerAnimated:YES completion:NULL];
    [settingsTableView reloadData];
}

//Send invite via email
- (void)emailAction
{
    NSString *emailTitle = @"Feedback";
    MFMailComposeViewController *mc = [[MFMailComposeViewController alloc] init];
    mc.mailComposeDelegate = self;
    [mc setSubject:emailTitle];
    [mc setToRecipients:@[@"feedback@streamme.co"]];
    
    
    // Present mail view controller on screen
    [self presentViewController:mc animated:YES completion:NULL];
    
}

- (CGFloat)tableView:(UITableView *)tableView heightForHeaderInSection:(NSInteger)section {
    return .00000001f;
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

-(void) deleteAllTables
{
    NSString *deleteSQL = @"DELETE from USER;";
    //get the main database
    MainDatabase* md = [MainDatabase shared];
    [md.queue inDatabase:^(FMDatabase *db) {
        [db executeStatements:deleteSQL];
    }];
}

@end
