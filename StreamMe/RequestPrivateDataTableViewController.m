//
//  RequestPrivateDataTableViewController.m
//  WhoYu
//
//  Created by Chase Midler on 1/28/15.
//  Copyright (c) 2015 midler. All rights reserved.
//

#import "RequestPrivateDataTableViewController.h"

@interface RequestPrivateDataTableViewController ()

@end

@implementation RequestPrivateDataTableViewController
@synthesize requestTableView;
- (void)viewDidLoad {
    [super viewDidLoad];
    self.tableView.tableFooterView = [[UIView alloc] initWithFrame:CGRectZero];
    
}

-(void) viewWillAppear:(BOOL)animated
{
    [self setup];
}

//helper function to setup the initial values
-(void) setup
{
    NSNumber* boolYes = [NSNumber numberWithBool:YES];
    phones = [[NSMutableArray alloc] init];
    emails = [[NSMutableArray alloc] init];
    StorePrivateProfile* spp = [StorePrivateProfile shared];
    PrivateProfile* profile = spp.profile;
    
    //want to have the phone numbers and email addresses in a certain order on each view so sort them
    NSArray* tmpPhones = [profile.phoneNumbers sortedArrayUsingComparator: ^(Phone* obj1, Phone* obj2) {
        
        //obj 1 is mobile phone
        if([obj1.type isEqualToString:@"Mobile Phone"])
            return (NSComparisonResult)NSOrderedAscending;
        //obj 2 is mobile phone
        else if ([obj2.type isEqualToString:@"Mobile Phone"])
            return (NSComparisonResult)NSOrderedDescending;
        //neither object is mobile phone so work has high priority
        else if ([obj1.type isEqualToString:@"Work Phone"])
            return (NSComparisonResult)NSOrderedAscending;
        //either the other phone is a home phone or there isn't one to compare with it
        else
            return (NSComparisonResult)NSOrderedDescending;
    }];
    
    NSArray* tmpEmails = [profile.emailAddresses sortedArrayUsingComparator: ^(Phone* obj1, Phone* obj2) {
        
        //obj 1 is mobile phone
        if([obj1.type isEqualToString:@"Personal Email"])
            return (NSComparisonResult)NSOrderedAscending;
        //obj 2 is mobile phone
        else if ([obj2.type isEqualToString:@"Personal Email"])
            return (NSComparisonResult)NSOrderedDescending;
        //neither object is mobile phone so work has high priority
        else if ([obj1.type isEqualToString:@"Work Email"])
            return (NSComparisonResult)NSOrderedAscending;
        //either the other phone is a home phone or there isn't one to compare with it
        else
            return (NSComparisonResult)NSOrderedDescending;
    }];
    
    //defaulting phones and emails to yes
    for(Phone* p in tmpPhones)
        [phones addObject:@[p,boolYes]];
    for(Email* e in tmpEmails)
        [emails addObject:@[e,boolYes]];
    
    NSLog(@"email count is %d and phones is %d", (int) emails.count, (int) phones.count);
    
    _rightBarButton.title = @"Send";
    if(phones.count + emails.count)
        _rightBarButton.enabled = YES;
    else
        _rightBarButton.enabled = NO;
    [requestTableView reloadData];
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}


- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView {
    return 2;
}

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section {
    // Return the number of rows in the section.
    if(section)
    {
        //there are emails
        if(emails.count)
        {
            //add an extra row for adding emails
            if(emails.count <MAX_EMAIL_ADDRESSES)
                return emails.count+1;
            else//already at max emails
                return emails.count;
        }
        else//have a row for adding emails
            return 1;
    }
    else
    {
        //there are phones
        if(phones.count)
        {
            //add an extra row for adding phones
            if(phones.count <MAX_PHONE_NUMBERS)
                return phones.count+1;
            else//already at max phones
                return phones.count;
        }
        else//have a row for adding phones
            return 1;
    }
}

//Get the title for each section
- (NSString *)tableView:(UITableView *)tableView titleForHeaderInSection:(NSInteger)section
{
    if(section)
        return [NSString stringWithFormat:@"Emails to send to %@", _profile.first_name];
    else
        return [NSString stringWithFormat:@"Numbers to send to %@", _profile.first_name];
}

//display cells
- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath {
    RequestPrivateDataTableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:@"privateCell" forIndexPath:indexPath];
    cell.separatorInset = UIEdgeInsetsZero;
    cell.addLabel.hidden = YES;
    cell.requestTypeLabel.hidden = YES;
    cell.requestValueLabel.hidden = YES;
    [cell.activityIndicator stopAnimating];
    cell.activityIndicator.center = cell.center;
    
    //emails first
    if(indexPath.section)
    {
        //check if we are on an add row or not
        if(indexPath.row>= emails.count)//add row
        {
            cell.addLabel.hidden = NO;
            cell.addLabel.text = @"Add Email";
            cell.accessoryType = UITableViewCellAccessoryNone;
            //give addanother phone button dashed line border
            [self drawDashedBorderAroundView:cell.addLabel];
            cell.tag = ADD_CELL;
        }
        else
        {
            cell.requestValueLabel.hidden = NO;
            cell.requestTypeLabel.hidden = NO;
            Email* email = emails[indexPath.row][0];
            cell.requestTypeLabel.text = email.type;
            cell.requestValueLabel.text = email.address;
            
            //see if it is check marked or not
            if(((NSNumber*)emails[indexPath.row][1]).boolValue)
                cell.accessoryType = UITableViewCellAccessoryCheckmark;
            else
                cell.accessoryType = UITableViewCellAccessoryNone;
            cell.tag = CONTACT_CELL;
        }
    }
    //phones
    else
    {
        //check if we are on an add row or not
        if(indexPath.row>= phones.count)//add row
        {
            cell.addLabel.hidden = NO;
            cell.addLabel.text = @"Add Number";
            cell.accessoryType = UITableViewCellAccessoryNone;
            //give addanother phone button dashed line border
            [self drawDashedBorderAroundView:cell.addLabel];
            cell.tag = ADD_CELL;
        }
        else
        {
            cell.requestValueLabel.hidden = NO;
            cell.requestTypeLabel.hidden = NO;
            Phone* phone = phones[indexPath.row][0];
            cell.requestTypeLabel.text = phone.type;
            cell.requestValueLabel.text = phone.number;
            
            //see if it is check marked or not
            if(((NSNumber*)phones[indexPath.row][1]).boolValue)
                cell.accessoryType = UITableViewCellAccessoryCheckmark;
            else
                cell.accessoryType = UITableViewCellAccessoryNone;
            cell.tag = CONTACT_CELL;
        }

    }
    return cell;
}

//click on cell
- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath
{
    UITableViewCell *cell = [tableView cellForRowAtIndexPath:indexPath];
    [cell setSelectionStyle:UITableViewCellSelectionStyleDefault];
    
    //emails
    if(indexPath.section)
    {
        //add cell
        if(cell.tag == ADD_CELL)
            [self performSegueWithIdentifier:@"emailSegue" sender:self];
        else//toggle
        {
            //not the bool value on click
            NSNumber* boolValue = [NSNumber numberWithBool:!((NSNumber*)emails[indexPath.row][1]).boolValue];
        
            //insert the new value into the array and reload the table
            [emails setObject:@[emails[indexPath.row][0],boolValue] atIndexedSubscript:indexPath.row];
            [requestTableView reloadData];
        }
    }
    else
    {
        //add cell
        if(cell.tag == ADD_CELL)
            [self performSegueWithIdentifier:@"phoneSegue" sender:self];
        else//toggle
        {
            //not the bool value on click
            NSNumber* boolValue = [NSNumber numberWithBool:!((NSNumber*)phones[indexPath.row][1]).boolValue];
            
            //insert the new value into the array and reload the table
            [phones setObject:@[phones[indexPath.row][0],boolValue] atIndexedSubscript:indexPath.row];
            [requestTableView reloadData];
        }
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
    
    UILabel *gettingSizeLabel = [[UILabel alloc] init];
    gettingSizeLabel.font = [UIFont fontWithName:@"System" size:12];
    gettingSizeLabel.text = [NSString stringWithFormat:@"Select contact info to send to %@", _profile.first_name];
    gettingSizeLabel.numberOfLines = 0;
    gettingSizeLabel.lineBreakMode = NSLineBreakByWordWrapping;
    CGSize maximumLabelSize = CGSizeMake(320, 9999);
    
    CGSize expectSize = [gettingSizeLabel sizeThatFits:maximumLabelSize];
    NSLog(@"expect size is %f", expectSize.height);
    return 10.0f + expectSize.height;
}


- (IBAction)rightBarButtonAction:(id)sender {
    
    _rightBarButton.enabled = NO;
    
    if([_rightBarButton.title isEqualToString:@"Send"])
    {
        //private info
        NSMutableArray* privateInfo = [[NSMutableArray alloc] init];
        
        
        for(NSArray* arr in phones)
        {
            if(((NSNumber*)arr[1]).boolValue)
            {
                Phone* phone = arr[0];
                [privateInfo addObject:@[phone.type,phone.number]];
            }
        }
    
        for(NSArray* arr in emails)
        {
            if(((NSNumber*)arr[1]).boolValue)
            {
                Email* email = arr[0];
                [privateInfo addObject:@[email.type, email.address]];
            }
        }
        //setting up the ok action if it is needed
        UIAlertAction *okAction = [UIAlertAction
                                   actionWithTitle:NSLocalizedString(@"Ok", @"Ok action")
                                   style:UIAlertActionStyleDefault
                                   handler:^(UIAlertAction *action)
                                   {
                                       NSLog(@"Ok action");
                                       _rightBarButton.enabled = YES;
                                       [_firstCell.activityIndicator stopAnimating];
                                       return;
                                   }];
        
        UIAlertController *alertController = [UIAlertController
                                              alertControllerWithTitle:@"Nothing Selected"
                                              message:@"You need to select some contact information to send to the user."
                                              preferredStyle:UIAlertControllerStyleAlert];
        [alertController addAction:okAction];
        
        //no user info
        if(!privateInfo.count)
        {
            [self presentViewController:alertController animated:YES completion:nil];
            return;
        }
        
        
        
        UIAlertController *newAlertController = [UIAlertController
                                              alertControllerWithTitle:@"Warning"
                                                 message:[NSString stringWithFormat:@"About to send sensitive data to %@.  Select send to continue.", _profile.first_name]
                                              preferredStyle:UIAlertControllerStyleAlert];
        
        UIAlertAction *cancelAction = [UIAlertAction
                                       actionWithTitle:NSLocalizedString(@"Cancel", @"Cancel action")
                                       style:UIAlertActionStyleCancel
                                       handler:^(UIAlertAction *action)
                                       {
                                           NSLog(@"Cancel action");
                                           _rightBarButton.enabled = YES;
                                           [_firstCell.activityIndicator stopAnimating];
                                           return;
                                       }];
        
        //We do send
        UIAlertAction *sendAction = [UIAlertAction
                                       actionWithTitle:NSLocalizedString(@"Send", @"Send action")
                                       style:UIAlertActionStyleDestructive
                                       handler:^(UIAlertAction *action)
        {
            [_firstCell.activityIndicator startAnimating];
            //we have user information, now go ahead and send it out
            [PFCloud callFunctionInBackground:@"createUserContacts" withParameters:@{@"user_id":_profile.user_id, @"contactList": privateInfo} block:^(id object, NSError *error) {
                //didn't send contact list
                if(error)
                {
                    UIAlertController* alertController = [UIAlertController
                                       alertControllerWithTitle:@"Sending Failed"
                                       message:@"Something went wrong sending the contact information to the user.  Please check your internet connection and try again."
                                       preferredStyle:UIAlertControllerStyleAlert];
                    UIAlertAction *okAction = [UIAlertAction
                                               actionWithTitle:NSLocalizedString(@"Ok", @"Ok action")
                                               style:UIAlertActionStyleDefault
                                               handler:^(UIAlertAction *action)
                                               {
                                                   NSLog(@"Ok action");
                                                   _rightBarButton.enabled = YES;
                                                   [_firstCell.activityIndicator stopAnimating];
                                                   return;
                                               }];

                    [alertController addAction:okAction];
                    [self presentViewController:alertController animated:YES completion:nil];
                    return;
                }
                
                //success
                _rightBarButton.enabled = YES;
                [self performSegueWithIdentifier:@"viewProfileSegue" sender:self];
            }];
        }];
        
        [newAlertController addAction:sendAction];
        [newAlertController addAction:cancelAction];
        [self presentViewController:newAlertController animated:YES completion:nil];
    }
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

// In a storyboard-based application, you will often want to do a little preparation before navigation
- (void)prepareForSegue:(UIStoryboardSegue *)segue sender:(id)sender
{
    if([segue.identifier isEqualToString:@"viewProfileSegue"])
    {
        UINavigationController *navController = segue.destinationViewController;
        ViewProfileViewController* controller = [navController childViewControllers].firstObject;
        controller.profile = _profile;
    }
}
@end
