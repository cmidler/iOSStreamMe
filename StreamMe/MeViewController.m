//
//  MeViewController.m
//  StreamMe
//
//  Created by Chase Midler on 3/26/15.
//  Copyright (c) 2015 midler. All rights reserved.
//

#import "MeViewController.h"

@interface MeViewController ()

@end

@implementation MeViewController
@synthesize meTableView;
- (void)viewDidLoad {
    [super viewDidLoad];
    // This will remove extra separators from tableview
    meTableView.tableFooterView = [[UIView alloc] initWithFrame:CGRectZero];
    if ([self respondsToSelector:@selector(edgesForExtendedLayout)])
        self.edgesForExtendedLayout = UIRectEdgeNone;
    meTableView.contentInset = UIEdgeInsetsMake(self.navigationController.navigationBar.frame.size.height*3.0/2.0,0,0,0);
    self.automaticallyAdjustsScrollViewInsets=NO;
    [self getPoints];
    meArray = @[@"Name:", @"Points:", @"Rank:"];
    _spinnerActive = YES;
    _points = 0;
    _name = [[PFUser currentUser] objectForKey:@"posting_name"];
    
    //setting up swipes
    UISwipeGestureRecognizer * recognizer = [[UISwipeGestureRecognizer alloc] initWithTarget:self action:@selector(myLeftAction:)];
    [recognizer setDirection:(UISwipeGestureRecognizerDirectionLeft)];
    //setting up swipes
    UISwipeGestureRecognizer * rightRecognizer = [[UISwipeGestureRecognizer alloc] initWithTarget:self action:@selector(myRightAction:)];
    [rightRecognizer setDirection:(UISwipeGestureRecognizerDirectionRight)];
    [self.view addGestureRecognizer:rightRecognizer];
    [self.view addGestureRecognizer:recognizer];
    
    
    
    //present an alert to tell the person to tap the screen to take the photo
    NSNumber *showPoints =
    [[NSUserDefaults standardUserDefaults] objectForKey:@"ShowPoints"];
    if (!showPoints) {
        UIAlertController *alertController = [UIAlertController
                                              alertControllerWithTitle:@"Earn StreamMe Points"
                                              message:@"Earn points by starting streams or adding content to existing ones to increase your rank!"
                                              preferredStyle:UIAlertControllerStyleAlert];
        UIAlertAction *okAction = [UIAlertAction
                                   actionWithTitle:NSLocalizedString(@"Ok", @"Ok action")
                                   style:UIAlertActionStyleDefault
                                   handler:^(UIAlertAction *action)
                                   {
                                       NSUserDefaults *defaults = [NSUserDefaults standardUserDefaults];
                                       [defaults setObject:@"YES" forKey:@"ShowPoints"];
                                       [defaults synchronize];
                                       return;
                                   }];
        [alertController addAction:okAction];
        [self presentViewController:alertController animated:YES completion:nil];
    }
}

-(void) myLeftAction:(id) sender
{
    NSLog(@"left action swipe");
    [self performSegueWithIdentifier:@"popSegue" sender:self];
}

-(void) myRightAction:(id) sender
{
    NSLog(@"right action swipe");
    [self performSegueWithIdentifier:@"settingsSegue" sender:self];
}

//query to get points
-(void) getPoints
{
    PFUser* user = [PFUser currentUser];
    PFQuery* privateQuery = [PFQuery queryWithClassName:@"UserPrivate"];
    [privateQuery whereKey:@"user" equalTo:user];
    [privateQuery findObjectsInBackgroundWithBlock:^(NSArray *objects, NSError *error) {
        if(error || !objects.count)
        {
            _spinnerActive = NO;
            [meTableView reloadData];
            return;
        }
        
        PFObject* obj = objects[0];
        _points = ((NSNumber*)[ obj objectForKey:@"points"]).integerValue;
        _spinnerActive = NO;
        [meTableView reloadData];
    }];
}

- (void) viewWillAppear:(BOOL)animated
{
    // Do any additional setup after loading the view.
    [self setupNavigation];

}

- (void) setupNavigation
{
    //Set blue gradient background
    /*UIGraphicsBeginImageContext(self.view.frame.size);
    [[UIImage imageNamed:@"BlueGradient.png"] drawInRect:self.view.bounds];
    UIImage *image = UIGraphicsGetImageFromCurrentImageContext();
    UIGraphicsEndImageContext();*/
    
    //self.view.backgroundColor = [UIColor colorWithPatternImage:image];
    
    UIImageView* navigationTitle = [[UIImageView alloc] initWithFrame:CGRectMake(0, 0, 88, 44)];
    navigationTitle.image = [UIImage imageNamed:@"streamme_banner_1.png"];
    [self.view addSubview:navigationTitle];
    UIImageView *workaroundView = [[UIImageView alloc] initWithFrame:CGRectMake(0, 0, 88, 44)];
    [workaroundView addSubview:navigationTitle];
    self.navigationItem.titleView=workaroundView;
    
    /*UILabel *navigationTitle=[[UILabel alloc]initWithFrame:CGRectMake(0, 0, 176, 44)];
    navigationTitle.text = @"StreamMe";
    navigationTitle.textColor = [UIColor whiteColor];
    navigationTitle.font = [UIFont boldSystemFontOfSize:17];
    navigationTitle.textAlignment = NSTextAlignmentCenter;
    UIImageView *workaroundView = [[UIImageView alloc] initWithFrame:CGRectMake(0, 0, 176, 44)];
    [workaroundView addSubview:navigationTitle];
    self.navigationItem.titleView=workaroundView;*/
    
    UIImage *image = [UIImage imageNamed:@"forward_arrow.png"];
    UIImage *leftImage = [UIImage imageNamed:@"settings.png"];
    UIBarButtonItem *buttonRight = [[UIBarButtonItem alloc] initWithImage:image style:UIBarButtonItemStyleDone target:self action:@selector(streamButton:)];
    self.navigationItem.rightBarButtonItem = buttonRight;
    
    UIBarButtonItem *buttonLeft = [[UIBarButtonItem alloc] initWithImage:leftImage style:UIBarButtonItemStyleDone target:self action:@selector(settingsButton:)];
    self.navigationItem.leftBarButtonItem = buttonLeft;
    NSLog(@"nav height is %f", self.navigationController.navigationBar.frame.size.height);
    
}

-(void) streamButton:(id) sender
{
    [self performSegueWithIdentifier:@"popSegue" sender:self];
}

-(void) settingsButton:(id) sender
{
    [self performSegueWithIdentifier:@"settingsSegue" sender:self];
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView
{
    // Return the number of sections.
    return 1;
}

- (NSString *)tableView:(UITableView *)tableView titleForHeaderInSection:(NSInteger)section
{
    return @"You!";
    //return [NSString stringWithFormat:@"%@", [[PFUser currentUser] objectForKey:@"posting_name"]];
}

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section
{
    
    return [meArray count];
}

//Show data in cells
- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath
{
    
    static NSString *CellIdentifier = @"meCell";
    MeTableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:CellIdentifier forIndexPath:indexPath];
    cell.separatorInset = UIEdgeInsetsZero;
    if(_spinnerActive)
        cell.activityIndicator.hidden = NO;
    else
        cell.activityIndicator.hidden = YES;
    cell.activityIndicator.center = cell.center;
    [cell setUserInteractionEnabled:NO];
    cell.nameTextField.hidden = YES;
    cell.valueLabel.hidden = YES;
    
    
    //setup the labels
    cell.titleLabel.text = meArray[indexPath.row];
    if(!indexPath.row)
    {
        [cell setUserInteractionEnabled:YES];
        cell.nameTextField.hidden = NO;
        cell.nameTextField.text = _name;
    }
    else if(indexPath.row == 1)
    {
        cell.valueLabel.hidden = NO;
        cell.valueLabel.text = [NSString stringWithFormat:@"%ld",(long)_points];
    }
    else
    {
        cell.valueLabel.hidden = NO;
        NSString* level = @"";
        //figure out the level first
        if(_points < LEVEL_ONE_POINTS)
            level = @LEVEL_ONE;
        else if(_points < LEVEL_TWO_POINTS)
            level = @LEVEL_TWO;
        else if(_points < LEVEL_THREE_POINTS)
            level = @LEVEL_THREE;
        else if(_points < LEVEL_FOUR_POINTS)
            level = @LEVEL_FOUR;
        else if(_points < LEVEL_FIVE_POINTS)
            level = @LEVEL_FIVE;
        else if(_points < LEVEL_SIX_POINTS)
            level = @LEVEL_SIX;
        else if(_points < LEVEL_SEVEN_POINTS)
            level = @LEVEL_SEVEN;
        else if(_points < LEVEL_EIGHT_POINTS)
            level = @LEVEL_EIGHT;
        else if(_points < LEVEL_NINE_POINTS)
            level = @LEVEL_NINE;
        else
            level = @LEVEL_TEN;
        
        cell.valueLabel.text = level;
    }
    return cell;
}

- (CGFloat)tableView:(UITableView *)tableView heightForHeaderInSection:(NSInteger)section {
    return .0000001f;
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

//Delegates for helping textview have placeholder text
- (void)textFieldDidBeginEditing:(UITextField *)textField
{
    [textField becomeFirstResponder];
}

//Continuation delegate for placeholder text
- (void)textFieldDidEndEditing:(UITextField *)textField
{
    if ([textField.text isEqualToString:@""])
    {
        textField.text = [[PFUser currentUser] objectForKey:@"posting_name"];
    }
    _name = textField.text;
    [textField resignFirstResponder];
}


//used for updating status
- (BOOL)textField:(UITextField *)textField
shouldChangeCharactersInRange:(NSRange)range
replacementString:(NSString *)text
{
    
    //check if they user is trying to enter too many characters
    if([[textField text] length] - range.length + text.length > MAX_NAME_CHARS && ![text isEqualToString:@"\n"])
    {
        return NO;
    }
    
    //Make return key try to save the new status
    if([text isEqualToString:@"\n"])
    {
        _name = textField.text;
        PFUser* user = [PFUser currentUser];
        NSString* postingName = [user objectForKey:@"posting_name"];
        //save the new posting name
        if(_name.length && ![_name isEqualToString:postingName])
        {
            [user setObject:_name forKey:@"posting_name"];
            [user saveInBackgroundWithBlock:^(BOOL succeeded, NSError *error) {
                if(succeeded && !error)
                {
                    [user fetchIfNeededInBackground];
                }
            }];
        }
        [textField resignFirstResponder];
    }
    return YES;
}


@end
