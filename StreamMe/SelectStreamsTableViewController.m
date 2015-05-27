//
//  SelectStreamsTableViewController.m
//  StreamMe
//
//  Created by Chase Midler on 4/1/15.
//  Copyright (c) 2015 midler. All rights reserved.
//

#import "SelectStreamsTableViewController.h"

@interface SelectStreamsTableViewController ()

@end

@implementation SelectStreamsTableViewController
@synthesize streamsTableView;

- (void)viewDidLoad {
    [super viewDidLoad];
    // This will remove extra separators from tableview
    self.tableView.tableFooterView = [[UIView alloc] initWithFrame:CGRectZero];
    AppDelegate* appDelegate = [[UIApplication sharedApplication] delegate];
    streams = [[NSMutableArray alloc] init];
    for(Stream* s in [appDelegate streams])
    {
        //check to see if the match is still valid
        NSDate* date = [s.stream objectForKey:@"endTime"];
        NSTimeInterval interval = [date timeIntervalSinceDate:[NSDate date]];
        if(isnan(interval) || interval<=0)
        {
            continue;
        }

        
        
        NSMutableArray* stream = [[NSMutableArray alloc]init];
        [stream addObject:s];
        [stream addObject:[NSNumber numberWithBool:NO]];
        [streams addObject:stream];
    }
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}


- (void) viewWillAppear:(BOOL)animated
{
    // Do any additional setup after loading the view.
    [self setupNavigation];
    
}

- (void) setupNavigation
{
    UIImageView *navigationImage=[[UIImageView alloc]initWithFrame:CGRectMake(0, 0, 22, 22)];
    navigationImage.image=[UIImage imageNamed:@"add-pictures-white.png"];
    
    UIImageView *workaroundImageView = [[UIImageView alloc] initWithFrame:CGRectMake(0, 0, 22, 22)];
    [workaroundImageView addSubview:navigationImage];
    self.navigationItem.titleView=workaroundImageView;
    UIBarButtonItem *buttonRight = [[UIBarButtonItem alloc] initWithBarButtonSystemItem:UIBarButtonSystemItemDone target:self action:@selector(doneClicked:)];
    self.navigationItem.rightBarButtonItem = buttonRight;
    
    UIBarButtonItem *buttonLeft = [[UIBarButtonItem alloc] initWithBarButtonSystemItem:UIBarButtonSystemItemCancel target:self action:@selector(cancelClicked:)];
    self.navigationItem.leftBarButtonItem = buttonLeft;
    
}

-(void) doneClicked:(id)sender
{
    [self addNewShareToSelectedStreams:_captionText];
}

-(void) cancelClicked:(id)sender
{
    [self.navigationController popViewControllerAnimated:YES];
}

- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView {

    // Return the number of sections.
    return 1;
}

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section {

    // Return the number of rows in the section.
    return streams.count;
}

//creating the header view so that we can have edit buttons as well
- (UIView *)tableView:(UITableView *)tableView viewForHeaderInSection:(NSInteger)section {
    //create the view to hold all of the other views
    UIView *headerView = [[UIView alloc] initWithFrame:CGRectMake(0, 0, tableView.frame.size.width, TITLE_HEIGHT)];
    
    //create the title with the name of the stream
    UILabel *title = [[UILabel alloc] initWithFrame:CGRectMake(5, 5, tableView.frame.size.width-10, TITLE_HEIGHT-10)];
    title.font = [UIFont boldSystemFontOfSize:17.0];
    title.textColor = [UIColor darkTextColor];
    title.text = @"Add To Selected Streams";
    [headerView addSubview:title];
    return headerView;
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath {
    SelectStreamsTableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:@"streamCell" forIndexPath:indexPath];
    
    Stream* streamObject = streams[indexPath.row][0];
    NSString* name = [streamObject.stream objectForKey:@"name"];
    bool checkMark = ((NSNumber*)streams[indexPath.row][1]).boolValue;
    cell.nameLabel.text = name;
    cell.usernameLabel.text = [NSString stringWithFormat:@"From: %@", streamObject.username ];
    
    if(checkMark)
        cell.accessoryType = UITableViewCellAccessoryCheckmark;
    else
        cell.accessoryType = UITableViewCellAccessoryNone;
    
    return cell;
}

//click on cell
- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath
{
    UITableViewCell *cell = [tableView cellForRowAtIndexPath:indexPath];
    [cell setSelectionStyle:UITableViewCellSelectionStyleDefault];
    
    bool checkMark = ((NSNumber*)streams[indexPath.row][1]).boolValue;
    checkMark = !checkMark;
    NSNumber* newCheckmark = [NSNumber numberWithBool:checkMark];
    NSMutableArray* streamObject = streams[indexPath.row];
    [streamObject setObject:newCheckmark atIndexedSubscript:1];
    
    NSArray* indexPaths = @[indexPath];
    [streamsTableView reloadRowsAtIndexPaths:indexPaths withRowAnimation:UITableViewRowAnimationNone];
}

//sharing to all streams
-(void) addNewShareToSelectedStreams:(NSString*) captionText
{
    
    if(!captionText.length || [captionText isEqualToString:@"Enter Caption:"])
        captionText = @"No caption.";
    PFUser* user = [PFUser currentUser];
    
    //Create the default acl
    PFACL *defaultACL = [PFACL ACL];
    [defaultACL setReadAccess:true forUser:user];
    [defaultACL setWriteAccess:true forUser:user];
    [defaultACL setPublicReadAccess:false];
    [defaultACL setPublicWriteAccess:false];
    
    //upload and don't care about an error for now
    NSMutableArray* pfObjects = [[NSMutableArray alloc] init];
    
    //create the file
    PFFile *pictureFile = [PFFile fileWithData:_imageData];
    
    PFObject* share = [PFObject objectWithClassName:@"Share"];
    share[@"caption"] = captionText;
    share[@"user"] = user;
    share[@"username"] = user.username;
    share[@"isPrivate"] = [NSNumber numberWithBool:NO];
    share[@"type"] = @"img";
    
    PFGeoPoint* currentLocation = [PFGeoPoint geoPointWithLocation:_currentLocation];
    if(currentLocation)
        share[@"location"] = currentLocation;    [share setObject:pictureFile forKey:@"file"];
    [share setACL:defaultACL];
    
    //add share to pfobjects
    [pfObjects addObject:share];
    NSMutableArray* streamIds = [[NSMutableArray alloc] init];
    //loop through all streams
    for(NSMutableArray* array in streams)
    {
        //NSLog(@"in array loop with array = %@", array);
        NSNumber* checkMark = array[1];
        if(!checkMark.boolValue)
            continue;
        
        
        Stream* streamObject = array[0];
        //need to check if the stream is expired or not
        //check to see if the match is still valid
        NSDate* date = [streamObject.stream objectForKey:@"endTime"];
        NSTimeInterval interval = [date timeIntervalSinceDate:[NSDate date]];
        if(isnan(interval) || interval<=0)
            continue;
        
        //create the stream share
        PFObject* streamShare = [PFObject objectWithClassName:@"StreamShares"];
        streamShare[@"stream"] = streamObject.stream;
        streamShare[@"share"] = share;
        streamShare[@"user"] = user;
        streamShare[@"isIgnored"] = [NSNumber numberWithBool:NO];
        [streamShare setACL:defaultACL];
        [pfObjects addObject:streamShare];
        [streamIds addObject:streamObject.stream.objectId];
    }
    
    //if there are objects then save them
    if(pfObjects.count>1)
    {
        //update the user's points total
        [PFCloud callFunctionInBackground:@"addToStreamUpdatePoints" withParameters:@{} block:^(id object, NSError *error) {}];
        //save all streamshares
        [PFObject saveAllInBackground:pfObjects block:^(BOOL succeeded, NSError *error) {
            NSDictionary* userInfo = @{@"streamIds":streamIds};
            [[NSNotificationCenter defaultCenter] postNotificationName:@"countStreams" object:self userInfo:userInfo];
        }];
    }
    //pop back to main screen
    [self.navigationController popViewControllerAnimated:YES];
}

-(void)tableView:(UITableView *)tableView willDisplayCell:(SelectStreamsTableViewCell *)cell forRowAtIndexPath:(NSIndexPath *)indexPath
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
    return TITLE_HEIGHT;
}



@end
