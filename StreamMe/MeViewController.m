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
    [self getPoints];
    meArray = @[@"Points:", @"Rank:"];
    _spinnerActive = YES;
    _points = 0;
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
    UILabel *navigationTitle=[[UILabel alloc]initWithFrame:CGRectMake(0, 0, 176, 44)];
    navigationTitle.text = @"StreamMe";
    navigationTitle.textColor = [UIColor whiteColor];
    navigationTitle.font = [UIFont boldSystemFontOfSize:17];
    navigationTitle.textAlignment = NSTextAlignmentCenter;
    UIImageView *workaroundView = [[UIImageView alloc] initWithFrame:CGRectMake(0, 0, 176, 44)];
    [workaroundView addSubview:navigationTitle];
    self.navigationItem.titleView=workaroundView;
    
    UIImage *image = [UIImage imageNamed:@"stream.png"];
    UIImage *leftImage = [UIImage imageNamed:@"settings.png"];
    UIBarButtonItem *buttonRight = [[UIBarButtonItem alloc] initWithImage:image style:UIBarButtonItemStyleDone target:self action:@selector(streamButton:)];
    self.navigationItem.rightBarButtonItem = buttonRight;
    
    UIBarButtonItem *buttonLeft = [[UIBarButtonItem alloc] initWithImage:leftImage style:UIBarButtonItemStyleDone target:self action:@selector(settingsButton:)];
    self.navigationItem.leftBarButtonItem = buttonLeft;

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
    return [NSString stringWithFormat:@"%@", [PFUser currentUser].username];
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
    //setup the labels
    cell.titleLabel.text = meArray[indexPath.row];
    if(!indexPath.row)
    {
        cell.valueLabel.text = [NSString stringWithFormat:@"%ld",(long)_points];
        return cell;
    }
    
    
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

@end
