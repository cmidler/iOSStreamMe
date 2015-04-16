//
//  MainTableViewController.m
//  StreamMe
//
//  Created by Chase Midler on 9/3/14.
//  Copyright (c) 2014 midler. All rights reserved.
//

#import "MainTableViewController.h"
#define restorationKey @"profileDataKey"
@interface MainTableViewController ()

@end

@implementation MainTableViewController
@synthesize streamsTableView;
@synthesize customPicker;
@synthesize toolBar;
@synthesize caption;
@synthesize streamLengthButton;
@synthesize cameraOverlayView;
@synthesize flashButton;
@synthesize pickerView;
@synthesize timeLabel;
@synthesize activityIndicator;
- (id)initWithStyle:(UITableViewStyle)style
{
    self = [super initWithStyle:style];
    if (self) {
    }
    return self;
}

- (void)viewDidLoad
{
    [super viewDidLoad];
    
    NSLog(@"table first load is %d", _tableFirstLoad);
    
    // This will remove extra separators from tableview
    self.tableView.tableFooterView = [[UIView alloc] initWithFrame:CGRectZero];
    
    
    //setting up title
    _sortBy = 0;
    [self setNavigationTitle];
    
    
    //setting up dropdown
    REMenuItem *newestItem = [[REMenuItem alloc] initWithTitle:@"Newest"
                                                      subtitle:@"Sort by the newest streams nearby"
                                                         image:nil
                                              highlightedImage:nil
                                                        action:^(REMenuItem *item) {
                                                            _sortBy = 0;
                                                            _showingAnywhere = NO;
                                                            [self setNavigationTitle];
                                                            [self sortStreams];
                                                            _menuOpened = NO;
                                                        }];
    
    REMenuItem *viralNearbyItem = [[REMenuItem alloc] initWithTitle:@"Viral"
                                                     subtitle:@"Sort by the streams with the most content nearby"
                                                        image:nil
                                             highlightedImage:nil
                                                       action:^(REMenuItem *item) {
                                                           _sortBy = 1;
                                                           _showingAnywhere = NO;
                                                           [self setNavigationTitle];
                                                           [self sortStreams];
                                                           _menuOpened = NO;
                                                           
                                                       }];
    _menu = [[REMenu alloc] initWithItems:@[newestItem,viralNearbyItem]];
    [_menu setTextColor:[UIColor whiteColor]];
    [_menu setBackgroundColor:[UIColor blackColor]];
    
    AppDelegate *appDelegate = [[UIApplication sharedApplication] delegate];
    _central = [appDelegate central];
    _finishedDownload = YES;
    //streams = [[NSMutableArray alloc]init];
    _queue= dispatch_queue_create("user_queue", DISPATCH_QUEUE_SERIAL);
    _totalValidStreams = 0;
    _currentPage = _totalPages = 1;
    
    _isReloading = NO;
    _openedWithShake = NO;
    _downloadingStreams = NO;
    _loadingTableView = NO;
    _showingAnywhere = NO;
    //setting up notifications
    [[NSNotificationCenter defaultCenter] addObserver:self
                                             selector:@selector(mainNotification:)
                                                 name:@"dismissPickerEvent"
                                               object:nil];
    [[NSNotificationCenter defaultCenter] addObserver:self
                                             selector:@selector(mainNotification:)
                                                 name:@"dismissCameraEvent"
                                               object:nil];
    [[NSNotificationCenter defaultCenter] addObserver:self
                                             selector:@selector(mainNotification:)
                                                 name:@"countTimerFired"
                                               object:nil];
    [[NSNotificationCenter defaultCenter] addObserver:self
                                             selector:@selector(mainNotification:)
                                                 name:@"newUserStreams"
                                               object:nil];
    [[NSNotificationCenter defaultCenter] addObserver:self
                                             selector:@selector(mainNotification:)
                                                 name:@"countStreams"
                                               object:nil];
    
    
    //Adding pull to refresh
    self.refreshControl = [[UIRefreshControl alloc] init];
    [self.refreshControl addTarget:self
                            action:@selector(pullToRefresh)
                  forControlEvents:UIControlEventValueChanged];
    //force refreshing on view load
    NSLog(@"forcing refreshing");
    [self.refreshControl beginRefreshing];
    [streamsTableView setContentOffset:CGPointMake(0, -self.refreshControl.frame.size.height) animated:YES];

    
    [self pullToRefresh];
}

-(void) setNavigationTitle
{
    //creating container to hold the button
    UIView * container = [[UIView alloc]initWithFrame:CGRectMake(0, 0, 176, 22)];
    UIButton * menuButton = [[UIButton alloc]initWithFrame:CGRectMake(0, 0, 176, 22)];
    [menuButton addTarget:self action:@selector(menuSelected:) forControlEvents:UIControlEventTouchUpInside];
    //setting the title
    if(!_sortBy)
        [menuButton setTitle:@"Newest" forState:UIControlStateNormal];
    else if(_sortBy==1)
        [menuButton setTitle:@"Viral" forState:UIControlStateNormal];
    menuButton.titleLabel.textColor = [UIColor whiteColor];
    UIImage* image = [UIImage imageNamed:@"white-down-arrow.png"];
    //setting the down arrow
    [menuButton setImage:image forState:UIControlStateNormal];
    //moving the arrow to the right
    menuButton.titleEdgeInsets = UIEdgeInsetsMake(0, -menuButton.imageView.frame.size.width, 0, menuButton.imageView.frame.size.width);
    menuButton.imageEdgeInsets = UIEdgeInsetsMake(0, menuButton.titleLabel.frame.size.width, 0, -menuButton.titleLabel.frame.size.width);
    [container addSubview:menuButton];
    
    
    //setting up text attributes
    self.navigationItem.titleView = container;
    self.navigationController.navigationBar.titleTextAttributes = @{NSForegroundColorAttributeName : [UIColor whiteColor]};
    [self.navigationController.navigationBar setTintColor:[UIColor whiteColor]];
}

- (BOOL)canBecomeFirstResponder
{
    return YES;
}

-(void) menuSelected:(id) sender
{
    if(_menuOpened)
        [_menu close];
    else
        [_menu showFromNavigationController:self.navigationController];
    _menuOpened = !_menuOpened;
}
- (void)motionEnded:(UIEventSubtype)motion withEvent:(UIEvent *)event
{
    //shake gesture
    if (motion == UIEventSubtypeMotionShake)
    {
        AppDelegate* appDelegate = [[UIApplication sharedApplication] delegate];
        NSMutableArray* streams = [appDelegate streams];
        
        //there are streams so open camera automatically
        bool shouldCreate = YES;
        for(Stream* s in streams)
        {
            //check to see if the match is still valid
            NSDate* date = [s.stream objectForKey:@"endTime"];
            NSTimeInterval interval = [date timeIntervalSinceDate:[NSDate date]];
            if(!isnan(interval) && interval>0)
            {
                shouldCreate = NO;
                break;
            }
        }
        if(!shouldCreate)
        {
            //open the camera
            _openedWithShake = YES;
            _creatingStream = NO;
            [self takePhoto];
        }
        else
        {
            _creatingStream = YES;
            [self setTitleForStream];
        }
        
        NSLog(@"shake gesture");
    } 
}

-(void) viewWillDisappear:(BOOL)animated
{
    if(_menuOpened)
        [_menu close];
    _menuOpened = NO;
}

/* calling load values on notification since viewwillappear is not working */
- (void) mainNotification:(NSNotification *) notification
{
    if ([[notification name] isEqualToString:@"dismissPickerEvent"])
    {
        //fire this only if we are creating a stream
        if(_creatingStream)
            [self dismissPicker:self ];
    }
    else if ([[notification name] isEqualToString:@"dismissCameraEvent"])
    {
        _openedWithShake = NO;
        [self dismissImagePickerView];
    }
    else if ([[notification name] isEqualToString:@"countTimerFired"])
    {
        AppDelegate* appDelegate = [[UIApplication sharedApplication] delegate];
        NSMutableArray* streams = [appDelegate streams];
        NSMutableArray* streamIds = [[NSMutableArray alloc] init];
        for(Stream* s in streams)
        {
            //don't want to waste queries on expired
            NSDate* date = [s.stream objectForKey:@"endTime"];
            NSTimeInterval interval = [date timeIntervalSinceDate:[NSDate date]];
            if(isnan(interval) || interval<=0)
                continue;
            [streamIds addObject:s.stream.objectId];
        }
        
        [self countStreamShares:streamIds];
    }
    else if ([[notification name] isEqualToString:@"newUserStreams"])
    {
        //get the total amount of streams
        PFQuery* countStreamsQuery = [PFQuery queryWithClassName:@"UserStreams"];
        [countStreamsQuery whereKey:@"user" equalTo:[PFUser currentUser]];
        [countStreamsQuery whereKey:@"isIgnored" equalTo:[NSNumber numberWithBool:NO]];
        [countStreamsQuery countObjectsInBackgroundWithBlock:^(int number, NSError *error) {
            if(error)
            {
                NSLog(@"error in counting streams");
                return;
            }
            else
            {
                _totalValidStreams = number;
                NSLog(@"total valid streams is %d", _totalValidStreams);
                //total pages is 1 if there aren't any streams
                if(!_totalValidStreams)
                {
                    _totalPages = 1;
                    return;
                }
                _totalPages = (number/STREAMS_PER_PAGE)+1;
            }
        }];
        UILabel* newLabel = [[UILabel alloc] initWithFrame:CGRectMake(0, 0, self.view.frame.size.width, TOOLBAR_HEIGHT/2)];
        newLabel.text = @"Pull To Refresh New Nearby Streams";
        newLabel.textAlignment = NSTextAlignmentCenter;
        newLabel.font = [UIFont systemFontOfSize:12];
        newLabel.textColor = [UIColor grayColor];
        [self.refreshControl addSubview:newLabel];
        [streamsTableView setContentOffset:CGPointMake(0, -self.refreshControl.frame.size.height-self.navigationController.navigationBar.frame.size.height+(TOOLBAR_HEIGHT/2)) animated:YES];
    }
    else if ([[notification name] isEqualToString:@"countStreams"])
    {
        NSDictionary* userInfo = [notification userInfo];
        [self countStreamShares:[userInfo objectForKey:@"streamIds"]];
    }
}


//look for new subscribers
-(void) pullToRefresh
{
    for(UIView* view in [self.refreshControl subviews])
    {
        if([view isKindOfClass:[UILabel class]])
            [view removeFromSuperview];
    }
    self.refreshControl.attributedTitle = [[NSAttributedString alloc] initWithString:@""];
    NSLog(@"calling pull to refresh with downloadingStream = %d", _downloadingStreams);
    //need to protect critical section
    @synchronized(self){
        //checking if we are already in pull to refresh
        if(_downloadingStreams)
            return;
        
        _downloadingStreams = YES;
    }
    
    
    NSLog(@"PAGE LOAD");
    
    AppDelegate* appDelegate = [[UIApplication sharedApplication] delegate];
    NSMutableArray* streams = [appDelegate streams];
    
    NSMutableArray* streamIds = [[NSMutableArray alloc] init];
    for(Stream* stream in streams)
        [streamIds addObject:stream.stream.objectId];
    
    //get the total amount of streams
    PFQuery* countStreamsQuery = [PFQuery queryWithClassName:@"UserStreams"];
    [countStreamsQuery whereKey:@"user" equalTo:[PFUser currentUser]];
    [countStreamsQuery whereKey:@"isIgnored" equalTo:[NSNumber numberWithBool:NO]];
    [countStreamsQuery countObjectsInBackgroundWithBlock:^(int number, NSError *error) {
        if(error)
        {
            NSLog(@"error in counting streams");
           return;
        }
        else
        {
            _totalValidStreams = number;
            NSLog(@"total valid streams is %d", _totalValidStreams);
            //total pages is 1 if there aren't any streams
            if(!_totalValidStreams)
            {
                _totalPages = 1;
                return;
            }
            _totalPages = (number/STREAMS_PER_PAGE)+1;
        }
    }];
    
    
    
    //get nearby user streams first
    MainDatabase* md = [MainDatabase shared];
    __block bool inQueue = YES;
    NSMutableArray* userIds = [[NSMutableArray alloc] init];
    [md.queue inDatabase:^(FMDatabase *db) {
        
        
        //need to delete the peripherals that are about to expire
        NSString *userSQL = @"SELECT DISTINCT user_id FROM user WHERE is_me != ?";
        NSArray* values = @[[NSNumber numberWithInt:1]];
        FMResultSet *s = [db executeQuery:userSQL withArgumentsInArray:values];
        //get the peripheral ids
        while([s next])
        {
            NSLog(@"found user");
            [userIds addObject:[s stringForColumnIndex:0]];
        }
        inQueue = NO;
    }];
    
    //busy loop
    while(inQueue)
        ;
    
    //count the user ids
    if(userIds.count)
    {
        NSLog(@"calling new streams from nearby users");
        [PFCloud callFunctionInBackground:@"getNewStreamsFromNearbyUsers" withParameters:@{@"userIds":userIds} block:^(id object, NSError *error) {
            //error
            if(error)
            {
                NSLog(@"error for nearby user streams is %@", error);
            }
            
            
            //either way call get streams for user
            [PFCloud callFunctionInBackground:@"getStreamsForUser" withParameters:@{@"currentStreamsIds":streamIds, @"limit":[NSNumber numberWithInt:STREAMS_PER_PAGE]} block:^(id object, NSError *error) {
                if(error)
                {
                    _tableFirstLoad = NO;
                    _downloadingStreams = NO;
                    NSLog(@"error is %@", error);
                    [self.refreshControl endRefreshing];
                    [self sortStreams];
                    return;
                }
                
                NSArray* newStreams = object;
                NSLog(@"new streams = %@", newStreams);
                
                //see if the array already contains it before we add it
                for(NSDictionary* dict in newStreams)
                {
                    PFObject* stream = [dict objectForKey:@"stream"];
                    PFObject* share = [dict objectForKey:@"share"];
                    PFObject* streamShare = [dict objectForKey:@"stream_share"];
                    streamShare[@"share"] = share;
                    NSString* username = [dict objectForKey:@"username"];
                    //add id to the streamids array
                    [streamIds addObject:stream.objectId];
                    
                    //get array of all of the stream objects we have
                    NSMutableArray* streamObjects = [[NSMutableArray alloc] init];
                    
                    //have array of streams in streams array
                    for(Stream* s in streams)
                        [streamObjects addObject:s.stream];
                    
                    //if the stream isn't in the array then add it
                    if(![streamObjects containsObject:stream])
                    {
                        //initialize a new stream
                        Stream* newStream = [[Stream alloc] init];
                        newStream.stream = stream;
                        
                        //want to create an array of shares so we can lazy load the next ones
                        [newStream.streamShares addObject:streamShare];
                        
                        
                        //if I am the creator then just me otherwise someone had to share it with me
                        if([((PFUser*)[stream objectForKey:@"creator"]).objectId isEqualToString: [PFUser currentUser].objectId])
                            newStream.totalViewers = 1;
                        else
                            newStream.totalViewers = 2;
                        //add the username
                        newStream.username = username;
                        //newest time of streamShare
                        newStream.newestShareCreationTime = streamShare.createdAt;
                        //add the new stream object to the streams array
                        [streams addObject:newStream];
                        //get first share
                        NSString* firstShareId = ((PFObject*)[stream objectForKey:@"firstShare"]).objectId;
                        if([firstShareId isEqualToString:share.objectId])
                            [self loadSharesRight:stream limitOf:SHARES_PER_PAGE];
                        else
                            [self loadSharesCenter:stream];
                    }
                }
                _tableFirstLoad = NO;
                _downloadingStreams = NO;
                [self countStreamShares:streamIds];
                dispatch_async(dispatch_get_main_queue(), ^{
                    [self sortStreams];
                });
            }];
            
            
        }];
    }
    else
    {
    
        [PFCloud callFunctionInBackground:@"getStreamsForUser" withParameters:@{@"currentStreamsIds":streamIds, @"limit":[NSNumber numberWithInt:STREAMS_PER_PAGE]} block:^(id object, NSError *error) {
            if(error)
            {
                _tableFirstLoad = NO;
                _downloadingStreams = NO;
                NSLog(@"error is %@", error);
                [self.refreshControl endRefreshing];
                [self sortStreams];
                return;
            }
            
            NSArray* newStreams = object;
            NSLog(@"new streams = %@", newStreams);
            
            //see if the array already contains it before we add it
            for(NSDictionary* dict in newStreams)
            {
                PFObject* stream = [dict objectForKey:@"stream"];
                PFObject* share = [dict objectForKey:@"share"];
                PFObject* streamShare = [dict objectForKey:@"stream_share"];
                streamShare[@"share"] = share;
                NSString* username = [dict objectForKey:@"username"];
                //add id to the streamids array
                [streamIds addObject:stream.objectId];
                
                //get array of all of the stream objects we have
                NSMutableArray* streamObjects = [[NSMutableArray alloc] init];
                
                //have array of streams in streams array
                for(Stream* s in streams)
                    [streamObjects addObject:s.stream];
                
                //if the stream isn't in the array then add it
                if(![streamObjects containsObject:stream])
                {
                    //initialize a new stream
                    Stream* newStream = [[Stream alloc] init];
                    newStream.stream = stream;
                    
                    //want to create an array of shares so we can lazy load the next ones
                    [newStream.streamShares addObject:streamShare];
                    
                    
                    //if I am the creator then just me otherwise someone had to share it with me
                    if([((PFUser*)[stream objectForKey:@"creator"]).objectId isEqualToString: [PFUser currentUser].objectId])
                        newStream.totalViewers = 1;
                    else
                        newStream.totalViewers = 2;
                    //add the username
                    newStream.username = username;
                    //newest time of streamShare
                    newStream.newestShareCreationTime = streamShare.createdAt;
                    //add the new stream object to the streams array
                    [streams addObject:newStream];
                    //get first share
                    NSString* firstShareId = ((PFObject*)[stream objectForKey:@"firstShare"]).objectId;
                    if([firstShareId isEqualToString:share.objectId])
                        [self loadSharesRight:stream limitOf:SHARES_PER_PAGE];
                    else
                        [self loadSharesCenter:stream];
                }
            }
            _tableFirstLoad = NO;
            _downloadingStreams = NO;
            [self countStreamShares:streamIds];
            dispatch_async(dispatch_get_main_queue(), ^{
                [self sortStreams];
            });
        }];
    }
    
}

//lazy load shares right
-(void) loadSharesRight:(PFObject*) stream limitOf:(int)limit
{
    [self countStreamShares:@[stream.objectId]];
    //get the streams
    AppDelegate* appDelegate = [[UIApplication sharedApplication] delegate];
    NSMutableArray* streams = [appDelegate streams];
    Stream* streamObj = nil;
    //need to find the current array for the stream
    for(Stream* s in streams)
    {
        //match
        if([s.stream isEqual: stream])
        {
            streamObj = s;
            break;
        }
    }
    
    
    //error checking
    if(!streamObj)
    {
        [self sortStreams];
        return;
    }
    @synchronized(self)
    {
        if(streamObj.isDownloadingAfter)
            return;
        //change the boolean for downloading after
        streamObj.isDownloadingAfter = YES;
    }
    //now get the current streamshare
    PFObject* streamShare = (PFObject*)[streamObj.streamShares lastObject];
    
    
    
    //load shares with a time greater than current share's
    [PFCloud callFunctionInBackground:@"getSharesForStream" withParameters:@{@"streamId":stream.objectId, @"lastShareTime":streamShare.createdAt, @"maxShares":[NSNumber numberWithInt:limit], @"direction":@"right"} block:^(id object, NSError *error) {
        if(error)
        {
            //change the boolean for downloading previous
            streamObj.isDownloadingAfter = NO;
            return;
        }
        
        //object returns an array of PFObjects
        NSArray* streamShareObjects = object;
        for(PFObject* streamShare in streamShareObjects)
        {
            NSLog(@"streamshare right is %@", streamShare.objectId);
            if(![streamObj.streamShares containsObject:streamShare])
                [streamObj.streamShares addObject:streamShare];
        }
        //change the boolean for downloading previous
        streamObj.isDownloadingAfter = NO;
        //reload section
        dispatch_async(dispatch_get_main_queue(), ^{
            [self sortStreams];
        });
    }];
}

//lazy load shares center
-(void) loadSharesCenter:(PFObject*) stream
{
    [self loadSharesLeft:stream limitOf:SHARES_PER_PAGE/2];
    [self loadSharesRight:stream limitOf:SHARES_PER_PAGE/2];
}

//lazy load shares left
-(void) loadSharesLeft:(PFObject*) stream limitOf:(int)limit
{
    
    [self countStreamShares:@[stream.objectId]];
    
    //get the streams
    AppDelegate* appDelegate = [[UIApplication sharedApplication] delegate];
    NSMutableArray* streams = [appDelegate streams];
    Stream* streamObj = nil;
    //need to find the current array for the stream
    for(Stream*s in streams)
    {
        //match
        if([s.stream isEqual: stream])
        {
            streamObj = s;
            break;
        }
    }
    
    //error checking
    if(!streamObj)
    {
        [self sortStreams];
        return;
    }
    @synchronized(self)
    {
        if(streamObj.isDownloadingPrevious)
            return;
        //change the boolean for downloading previous
        streamObj.isDownloadingPrevious = YES;
    }
    
    //now get the current streamshare
    PFObject* streamShare = [streamObj.streamShares objectAtIndex:0];
    
    //load shares with a time greater than current share's
    [PFCloud callFunctionInBackground:@"getSharesForStream" withParameters:@{@"streamId":stream.objectId, @"lastShareTime":streamShare.createdAt, @"maxShares":[NSNumber numberWithInt:limit], @"direction":@"left"} block:^(id object, NSError *error) {
        if(error)
        {
            //change the boolean for downloading previous
            streamObj.isDownloadingPrevious = NO;
            return;
        }
        
        //object returns an array of PFObjects
        NSArray* streamShareObjects = object;
        int i = 0;
        for(PFObject* streamShare in streamShareObjects)
        {
            NSLog(@"streamshare left is %@", streamShare);
            if(![streamObj.streamShares containsObject:streamShare])
            {
                i++;
                [streamObj.streamShares insertObject:streamShare atIndex:0];
            }
        }
        
        //if we loaded previous objects, then make sure we stay on the correct cell
        if(i)
        {
            //see if we have the first share in the array or not
            bool hasFirstShare = NO;
            PFObject* firstShare = [streamObj.streamShares[0] objectForKey:@"share"];
            if([((PFObject*)[stream objectForKey:@"firstShare"]).objectId isEqualToString:firstShare.objectId])
                hasFirstShare = YES;

            streamObj.currentShareIndex +=i;
            streamObj.offset = i+!hasFirstShare;
        }
        
        //change the boolean for downloading previous
        streamObj.isDownloadingPrevious = NO;
        dispatch_async(dispatch_get_main_queue(), ^{
            //reload section
            [self sortStreams];
        });
        //[streamsTableView reloadSections:[NSIndexSet indexSetWithIndex:0] withRowAnimation:UITableViewRowAnimationNone];
    }];
}

-(void) sortStreams
{
    @synchronized(self)
    {
        if(_loadingTableView)
            return;
        _loadingTableView = YES;
    }
    AppDelegate* appDelegate = [[UIApplication sharedApplication] delegate];
    NSMutableArray* streams = [appDelegate streams];
    NSMutableArray* removeStreams = [[NSMutableArray alloc] init];
    //loop through and get streams that have been expired for 30 minutes and remove them
    for(Stream* s in streams)
    {
        
        //check to see if the match is still valid
        NSDate* date = [s.stream objectForKey:@"endTime"];
        NSTimeInterval interval = [[NSDate date] timeIntervalSinceDate:date];
        if(interval>1800)
        {
            [removeStreams addObject:s];
            NSLog(@"removing stream");
        }
    }
    
    //now remove the streams
    if(removeStreams.count)
        [streams removeObjectsInArray:removeStreams];
    
    //sort the stream
    
    //Sort by newest
    if(_sortBy == 0)
    {
        showStreamsArray = [streams sortedArrayUsingComparator: ^(Stream* obj1, Stream* obj2) {
        
            //get the streams to sort upon
            PFObject* stream1 = obj1.stream;
            PFObject* stream2 = obj2.stream;
            NSDate* date1 = [stream1 objectForKey:@"endTime"];
            NSDate* date2 = [stream2 objectForKey:@"endTime"];
            NSDate* now = [NSDate date];
            NSTimeInterval interval1 = [date1 timeIntervalSinceDate:now];
            NSTimeInterval interval2 = [date2 timeIntervalSinceDate:now];
            
            
            //compare the date objects to see if they are in the past
            if(isnan(interval1) || interval1<=0)
                return (NSComparisonResult)NSOrderedDescending;
            if(isnan(interval2) || interval2<=0)
                return (NSComparisonResult)NSOrderedAscending;
            
            //compare on created at
            return [stream2.createdAt compare:stream1.createdAt];
        }];
    }
    //sort by popular
    else if(_sortBy == 1)
    {
        showStreamsArray = [streams sortedArrayUsingComparator: ^(Stream* obj1, Stream* obj2) {
            
            //get the streams to sort upon
            PFObject* stream1 = obj1.stream;
            PFObject* stream2 = obj2.stream;
            NSDate* date1 = [stream1 objectForKey:@"endTime"];
            NSDate* date2 = [stream2 objectForKey:@"endTime"];
            NSDate* now = [NSDate date];
            NSTimeInterval interval1 = [date1 timeIntervalSinceDate:now];
            NSTimeInterval interval2 = [date2 timeIntervalSinceDate:now];
            
            
            //compare the date objects to see if they are in the past
            if(isnan(interval1) || interval1<=0)
                return (NSComparisonResult)NSOrderedDescending;
            if(isnan(interval2) || interval2<=0)
                return (NSComparisonResult)NSOrderedAscending;
            
            if(obj1.totalShares > obj2.totalShares)
                return (NSComparisonResult)NSOrderedAscending;
            else if(obj1.totalShares < obj2.totalShares)
                return (NSComparisonResult)NSOrderedDescending;
            else
                return (NSComparisonResult)NSOrderedSame;
            
        }];
    }
    
    //now sort the stream based on how many photos it has
    [self.refreshControl endRefreshing];
    NSLog(@"reload data");
    
    
    [streamsTableView reloadData];
    [streamsTableView layoutIfNeeded];
    @synchronized(self)
    {
        _loadingTableView = NO;
    }
}


//helper function to update the count of shares in the background for the list of provided stream ids
-(void) countStreamShares:(NSArray*)streamIds
{
    NSLog(@"countStreamShares:()");
    AppDelegate* appDelegate = [[UIApplication sharedApplication] delegate];
    NSMutableArray* streams = [appDelegate streams];
    __block int i = 0;
    //do background queries to update the amount of shares
    for(NSString* streamId in streamIds)
    {
        [PFCloud callFunctionInBackground:@"countSharesForStreams" withParameters:@{@"streamId":streamId} block:^(id object, NSError *error) {
            //just return if an error
            if(error)
            {
                i++;
                return;
            }
            NSLog(@"in count shares for streams");
            //find the correct stream and update the last value in the array
            for(Stream* s in streams)
            {
                //found the match
                if([s.stream.objectId isEqualToString:streamId])
                {
                    //get total shares and total
                    NSNumber* totalShares = object[0];
                    
                    PFObject* streamShare = object[1];
                    NSInteger previousShareTotal = s.totalShares;
                    //see if we got more shares
                    if(totalShares.integerValue > previousShareTotal)
                    {
                        //get the number of shares until the next page
                        int numberOfSharesUntilNextPage = SHARES_PER_PAGE - previousShareTotal%SHARES_PER_PAGE;
                        
                        @synchronized(self)
                        {
                            //if downloading then return
                            if(s.isDownloadingAfter)
                                break;
                        
                            //if number of shares until next page is not shares per page then update
                            if(numberOfSharesUntilNextPage != SHARES_PER_PAGE)
                            {
                                //getting more shares
                                [self loadSharesRight:s.stream limitOf:numberOfSharesUntilNextPage];
                            }
                        }
                        
                        
                    }
                    
                    //update the total shares in the array
                    s.totalShares = totalShares.integerValue;
                    s.newestShareCreationTime = streamShare.createdAt;
                    break;
                }
            }
            i++;
            
            //when looped through all count results go ahead and update
            if(i == streamIds.count)
            {
                dispatch_async(dispatch_get_main_queue(), ^{
                    [self sortStreams];
                });
            }
        }];
        
        //loop through all of the streams and query if it is not expired
        for (Stream* s in streams)
        {
            //found match
            if([s.stream.objectId isEqualToString:streamId])
            {
                //check to see if the match is still valid
                NSDate* date = [s.stream objectForKey:@"endTime"];
                NSTimeInterval interval = [date timeIntervalSinceDate:[NSDate date]];
                if(isnan(interval) || interval<=0)
                    continue;//not valid
                
                //found valid match
                [PFCloud callFunctionInBackground:@"countUsersForStreams" withParameters:@{@"streamId":streamId} block:^(id object, NSError *error) {
                    //just return if an error
                    if(error)
                        return;
                    s.totalViewers = ((NSNumber*)object).integerValue;
                    NSLog(@"total viewers is %d", (int)s.totalViewers);
                }];
            }
        }
    }
}

//on picture tap segue to view profile
-(void) pictureTapDetected:(id) sender
{
    [self addStreamAction:self];
}

-(void) singlePictureTapDetected:(id) sender
{
    NSLog(@"single picture tap detected");
    UITapGestureRecognizer *gesture = (UITapGestureRecognizer *) sender;
    _selectedSectionIndex = (int)gesture.view.tag;
    _selectedCellIndex = 0;
    [self performSegueWithIdentifier:@"viewStreamSegue" sender:self];
}


//on header tap add to stream
-(void) headerTapDetected:(id) sender
{
    UITapGestureRecognizer *gesture = (UITapGestureRecognizer *) sender;
    _selectedCellIndex = (int)gesture.view.tag;
    _creatingStream = NO;
    _openedWithShake = NO;
    _selectedStream = ((Stream*)showStreamsArray[_selectedCellIndex]).stream;
    [self takePhoto];
}

-(void) viewWillAppear:(BOOL)animated
{
    [super viewWillAppear:animated];
    _menuOpened = NO;
    NSLog(@"current row is %d", (int)_selectedCellIndex);
    //scroll to right position
    if(_isPoppingBack)
    {
        @synchronized(self)
        {
            NSLog(@"selected cell index in did pop back is %d",(int)_selectedCellIndex);
            //need to find the right section
            int i =0;
            for(Stream* s in showStreamsArray)
            {
                if([s.stream isEqual:_selectedStream])
                    break;
                i++;
            }
                
            NSIndexPath* collectionPath = [NSIndexPath indexPathForRow:_selectedCellIndex inSection:0];
            NSIndexPath* tableViewPath = [NSIndexPath indexPathForRow:0 inSection:i];
            MainTableViewCell *cell = (MainTableViewCell*)[streamsTableView cellForRowAtIndexPath:tableViewPath];
            UICollectionView* collectionView = cell.streamCollectionView;
            [collectionView reloadData];
            [collectionView scrollToItemAtIndexPath:collectionPath atScrollPosition:UICollectionViewScrollPositionCenteredHorizontally animated:NO];
        }
    }
    _isPoppingBack = NO;
    [self sortStreams];
}


- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}


- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView
{
    //the number of streams
    if([showStreamsArray count])
    {
        self.tableView.separatorStyle = UITableViewCellSeparatorStyleSingleLine;
        streamsTableView.backgroundView = nil;
        return showStreamsArray.count;
    }
    else if (_tableFirstLoad)
    {
        // Display a message when the table is empty
        UILabel *messageLabel = [[UILabel alloc] initWithFrame:CGRectMake(0, streamsTableView.center.y, streamsTableView.bounds.size.width, streamsTableView.bounds.size.height)];
        messageLabel.text = @"Loading Streams...";
        
        /*else
         messageLabel.text = @"You are currently undiscoverable and cannot see other profiles.  Toggle discoverable in settings to see other people!";*/
        messageLabel.textColor = [UIColor lightGrayColor];
        messageLabel.numberOfLines = 1;
        messageLabel.textAlignment = NSTextAlignmentCenter;
        messageLabel.font = [UIFont fontWithName:@"HelveticaNeue-Italic" size:20];
        [messageLabel sizeToFit];
        streamsTableView.backgroundView = [[UIView alloc] initWithFrame:CGRectMake(0, 0, streamsTableView.bounds.size.width, streamsTableView.bounds.size.height)];
        messageLabel.center = streamsTableView.backgroundView.center;
        [streamsTableView.backgroundView addSubview:messageLabel];
        self.tableView.separatorStyle = UITableViewCellSeparatorStyleNone;
        return 0;
    }
    else
    {
        // Display a message when the table is empty
        UILabel *messageLabel = [[UILabel alloc] initWithFrame:CGRectMake(TABLE_VIEW_X_ORIGIN, streamsTableView.center.y, streamsTableView.bounds.size.width-TABLE_VIEW_X_ORIGIN*2, streamsTableView.bounds.size.height)]; //initWithFrame:CGRectMake(0, 0, streamsTableView.bounds.size.width, streamsTableView.bounds.size.height)];
        
        UIImageView *picture = [[UIImageView alloc] initWithFrame:CGRectMake(streamsTableView.center.x-(PICTURE_SIZE/2), streamsTableView.center.y -(PICTURE_SIZE), PICTURE_SIZE, PICTURE_SIZE)];
        picture.layer.cornerRadius = PICTURE_SIZE/2;
        picture.clipsToBounds = YES;
        //picture.contentMode = UIViewContentModeScaleToFill;
        picture.image = [UIImage imageNamed:@"stream-128.png"];
        
        UITapGestureRecognizer *pictureTap =  [[UITapGestureRecognizer alloc] initWithTarget:self action:@selector(pictureTapDetected:)];
        pictureTap.numberOfTapsRequired = 1;
        [picture setUserInteractionEnabled:YES];
        [picture addGestureRecognizer:pictureTap];
        
        //bluetooth isn't on naturally
        if(!_central.bluetoothOn)
            messageLabel.text = @"Your bluetooth is turned off!  Go to Settings->Bluetooth and make sure bluetooth is enable to get the full functionality of this application! ";
        else
            messageLabel.text = @"No streams around you.  Go ahead and start up the first one!";
        
        /*else
         messageLabel.text = @"You are currently undiscoverable and cannot see other profiles.  Toggle discoverable in settings to see other people!";*/
        messageLabel.textColor = [UIColor blackColor];
        messageLabel.numberOfLines = 0;
        messageLabel.textAlignment = NSTextAlignmentCenter;
        messageLabel.font = [UIFont fontWithName:@"HelveticaNeue-Italic" size:20];
        [messageLabel sizeToFit];
        
        streamsTableView.backgroundView = [[UIView alloc] initWithFrame:CGRectMake(0, 0, streamsTableView.bounds.size.width, streamsTableView.bounds.size.height)];
        [streamsTableView.backgroundView addSubview:picture];
        [streamsTableView.backgroundView addSubview:messageLabel];
        [streamsTableView sendSubviewToBack:picture];
        self.tableView.separatorStyle = UITableViewCellSeparatorStyleNone;
        return 0;
    }
}


- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section
{
    NSLog(@"in number of rows with count = %d", (int) showStreamsArray.count);
    
    //Want to add an extra row if we filled up all of the pages so far and there are still more to download
    if((_currentPage<_totalPages) && ([showStreamsArray count] < _totalValidStreams))
    {
        if(section == showStreamsArray.count-1)
            return [showStreamsArray count]+1;
        else
            return 1;
    }
    
    return 1;
    
}

//creating the header view so that we can have edit buttons as well
- (UIView *)tableView:(UITableView *)tableView viewForHeaderInSection:(NSInteger)section {
    
    Stream* s = showStreamsArray[section];
    
    float width = tableView.frame.size.width;
    float halfHeight = HEADER_HEIGHT/2.0;
    float quarterHeight = HEADER_HEIGHT/4.0;
    float threeQuarterHeight = HEADER_HEIGHT*3.0/4.0;
    
    //create the view to hold all of the other views
    UIView *headerView = [[UIView alloc] initWithFrame:CGRectMake(0, 0, tableView.frame.size.width, HEADER_HEIGHT)];
    headerView.tag = section;
    headerView.backgroundColor = [UIColor whiteColor];
    UITapGestureRecognizer *headerTap =  [[UITapGestureRecognizer alloc] initWithTarget:self action:@selector(headerTapDetected:)];
    headerTap.numberOfTapsRequired = 1;
    [headerView setUserInteractionEnabled:YES];
    [headerView addGestureRecognizer:headerTap];
    
    
    //set when it expires
    UILabel *expiration = [[UILabel alloc] initWithFrame:CGRectMake(5, halfHeight+10, width/3.0, halfHeight-10)];
    expiration.font = [UIFont boldSystemFontOfSize:12.0];
    expiration.numberOfLines = 1;
    //get time left label
    NSDate* endTime = [s.stream objectForKey:@"endTime"];
    NSString* timeLeft;
    NSTimeInterval interval = [endTime timeIntervalSinceDate:[NSDate date]];
    //stream if over
    if(isnan(interval) || interval<=0)
    {
        timeLeft = @"Stream Expired";
        headerView.backgroundColor = [UIColor grayColor];
        [headerView setUserInteractionEnabled:NO];
    }
    else
    {
        interval = interval/60;//let's get minutes accuracy
        //if more 30 minutes left then say less than the rounded up hour
        if(interval>30)
            timeLeft = [NSString stringWithFormat:@"Expires: < %dh",(int) ceil(interval/60)];
        else
            timeLeft = [NSString stringWithFormat:@"Expires: < %dm",(int) ceil(interval)];
    }
    expiration.text = timeLeft;
    
    //creation time label
    UILabel *creationLabel = [[UILabel alloc] initWithFrame:CGRectMake(5, 5, width/3.0, halfHeight-5)];
    creationLabel.font = [UIFont systemFontOfSize:12.0];
    creationLabel.numberOfLines = 1;
    NSDate* createdAt = s.stream.createdAt;
    NSDateFormatter *dateFormatter = [[NSDateFormatter alloc]init];
    dateFormatter.dateFormat = @"hh:mm a";
    NSString *dateString = [dateFormatter stringFromDate: createdAt];
    creationLabel.text = [NSString stringWithFormat:@"Started: %@",dateString];
    
    //add image for people
    UIImageView* peopleImageView = [[UIImageView alloc] initWithFrame:CGRectMake(width/3.0 +5, halfHeight+10, halfHeight*3.0/4.0, halfHeight-10)];
    peopleImageView.image = [UIImage imageNamed:@"people.png"];
    
    //add number of people
    UILabel *viewers = [[UILabel alloc] initWithFrame:CGRectMake(peopleImageView.frame.origin.x+peopleImageView.frame.size.width + 10, halfHeight+10, width/3, halfHeight-10)];
    viewers.font = [UIFont systemFontOfSize:12.0];
    viewers.numberOfLines = 1;
    viewers.text = [NSString stringWithFormat:@"%d",(int)s.totalViewers ];
    //[viewers sizeToFit];
    
    //add image for pictures
    UIImageView* pictureImageView = [[UIImageView alloc] initWithFrame:CGRectMake(width/3.0 +5, 5, halfHeight*3.0/4.0, halfHeight-5)];
    pictureImageView.image = [UIImage imageNamed:@"pictures.png"];
    
    //add number of pictures
    UILabel *contributions = [[UILabel alloc] initWithFrame:CGRectMake(pictureImageView.frame.origin.x + pictureImageView.frame.size.width+10, 5, width/3, halfHeight-5)];
    contributions.font = [UIFont systemFontOfSize:12.0];
    contributions.numberOfLines = 1;
    contributions.text = [NSString stringWithFormat:@"%d",(int)s.totalShares];
    //[contributions sizeToFit];
    
    //add the creator's username
    UILabel* usernameLabel = [[UILabel alloc] initWithFrame:CGRectMake(contributions.frame.origin.x+contributions.frame.size.width, threeQuarterHeight, width -(contributions.frame.origin.x+contributions.frame.size.width)-5 , quarterHeight)];
    usernameLabel.font = [UIFont boldSystemFontOfSize:12.0];
    usernameLabel.numberOfLines = 0;
    usernameLabel.text = s.username;
    usernameLabel.textAlignment = NSTextAlignmentRight;
    
    //image view to help
    UIImageView* addSharesImageView = [[UIImageView alloc] initWithFrame:CGRectMake(width-threeQuarterHeight, 5,threeQuarterHeight-5, threeQuarterHeight-5)];
    addSharesImageView.image = [UIImage imageNamed:@"add-pictures-128.png"];
    
    //add a line going underneath the title
    UIView *lineView = [[UIView alloc] initWithFrame:CGRectMake(0, halfHeight, width-threeQuarterHeight-10, 1)];
    lineView.backgroundColor = [UIColor lightGrayColor];
    
    [headerView addSubview:expiration];
    [headerView addSubview:creationLabel];
    [headerView addSubview:peopleImageView];
    [headerView addSubview:viewers];
    [headerView addSubview:pictureImageView];
    [headerView addSubview:contributions];
    [headerView addSubview:addSharesImageView];
    [headerView addSubview:lineView];
    [headerView addSubview:usernameLabel];
    
    return headerView;
}

//Show data in cells
- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath
{
    static NSString *CellIdentifier = @"mainCell";
    MainTableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:CellIdentifier forIndexPath:indexPath];
    cell.separatorInset = UIEdgeInsetsZero;
    cell.activityIndicator.hidden = YES;
    [cell.activityIndicator stopAnimating];
    [cell setUserInteractionEnabled:YES];
    //[cell setUserInteractionEnabled:NO];
    cell.streamCollectionView.hidden = YES;
    cell.streamCollectionView.tag = indexPath.section;
    
    //loop through subviews and if pfimage is there remove it
    for(UIView* view in cell.subviews)
    {
        if([view isKindOfClass:[PFImageView class]])
            [view removeFromSuperview];
    }
    
    //now check if we are using the profile cell or pagination
    if(indexPath.section < showStreamsArray.count && !indexPath.row)
    {
        
        //get the stream
        Stream* s = showStreamsArray[indexPath.section];
        
        
        //create the view to hold all of the other views
        UILabel *titleLabel = [[UILabel alloc] initWithFrame:CGRectMake(cell.frame.size.width/4, cell.frame.size.height/2-HEADER_HEIGHT/2, cell.frame.size.width/2, HEADER_HEIGHT)];
        titleLabel.backgroundColor = [UIColor whiteColor];
        titleLabel.font = [UIFont boldSystemFontOfSize:17.0];
        titleLabel.textColor = [UIColor darkTextColor];
        titleLabel.textAlignment = NSTextAlignmentCenter;
        titleLabel.numberOfLines = 0;
        titleLabel.layer.cornerRadius = 10;
        titleLabel.clipsToBounds = YES;
        titleLabel.text = [NSString stringWithFormat:@"#%@",[s.stream objectForKey:@"name"] ];
        //titleLabel.center = cell.center;
        [cell addSubview:titleLabel];
        cell.tag = STREAM_CELL_TAG;
        cell.backgroundView = nil;
        NSDate* endTime = [s.stream objectForKey:@"endTime"];
        NSTimeInterval interval = [endTime timeIntervalSinceDate:[NSDate date]];
        
        //if there is only one photo, then make an image view to fit the cell
        //otherwise allow the collection view
        if(s.streamShares.count > 1 && !isnan(interval) && interval>0)
        {
            
            NSInteger offset = s.offset*COLLECTION_VIEW_WIDTH;
            cell.backgroundColor = [UIColor whiteColor];
            cell.streamCollectionView.hidden = NO;
            [cell.streamCollectionView reloadData];
            if(offset)
            {
                [cell.streamCollectionView setContentOffset:CGPointMake(offset,0)];
                NSLog(@"offset is %d", (int)offset);
            }
            s.offset = 0;
            
        }
        else // create an imageview
        {
            CGRect rect = CGRectMake(0, 0, cell.frame.size.width, cell.frame.size.height);
            PFImageView* cellImageView = [[PFImageView alloc] initWithFrame:rect];
            //[cellImageView setContentMode:UIViewContentModeScaleToFill];
            [cellImageView setBounds:rect];
            PFObject* share = [s.streamShares[0] objectForKey:@"share"];
            cell.activityIndicator.hidden = NO;
            [cell.activityIndicator startAnimating];
            cellImageView.image = [UIImage imageNamed:@"pictures-512.png"];
            cellImageView.file = [share objectForKey:@"file"];
            [cellImageView loadInBackground:^(UIImage *image, NSError *error) {
                CGRect rect = CGRectMake(image.size.width/2-cell.frame.size.width/2, image.size.height/2-cell.frame.size.height/2, cell.frame.size.width, cell.frame.size.height);
                UIImage* tmpImage = [self fixOrientation:image withOrientation:image.imageOrientation];
                CGImageRef imageRef = CGImageCreateWithImageInRect([tmpImage CGImage], rect);
                UIImage *newImage = [UIImage imageWithCGImage:imageRef];
                
                cellImageView.image = newImage;
                cell.activityIndicator.hidden = YES;
                [cell.activityIndicator stopAnimating];
            }];
            if(isnan(interval) || interval<=0)
            {
                [cell setUserInteractionEnabled:NO];
                cell.backgroundColor = [UIColor grayColor];
            }
            else
            {
                UITapGestureRecognizer *pictureImageTap =  [[UITapGestureRecognizer alloc] initWithTarget:self action:@selector(singlePictureTapDetected:)];
                pictureImageTap.numberOfTapsRequired = 1;
                [cellImageView setUserInteractionEnabled:YES];
                cellImageView.tag = indexPath.section;
                [cellImageView addGestureRecognizer:pictureImageTap];
                [cell setUserInteractionEnabled:YES];
                cell.backgroundColor = [UIColor whiteColor];
            }
            [cell addSubview:cellImageView];
            
        }
        [cell bringSubviewToFront:titleLabel];
        
    }
    //Loading cell
    else
    {
        cell.tag = LOADING_CELL_TAG;
        cell.activityIndicator.hidden = NO;
        self.tableView.separatorStyle = UITableViewCellSeparatorStyleSingleLine;

        //activity indicator
        cell.activityIndicator.activityIndicatorViewStyle = UIActivityIndicatorViewStyleGray;
        cell.activityIndicator.center = cell.center;
        [cell.activityIndicator startAnimating];
        
        NSLog(@"activity indicator cell");
    }
    
    return cell;
}

-(void)tableView:(UITableView *)tableView willDisplayCell:(MainTableViewCell *)cell forRowAtIndexPath:(NSIndexPath *)indexPath
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
    
    //checking if we hit a loading row.  If so, we want to increment the current page, and get the new users
    if(cell.tag == LOADING_CELL_TAG)
    {
        if(!_downloadingStreams)
        {
            NSLog(@"at loading cell");
            _currentPage++;
            [self pullToRefresh];
        }
    }
    
    
}

- (void)scrollViewDidEndDecelerating:(UIScrollView *)scrollView{
    
    if(![scrollView isKindOfClass:[UICollectionView class]])
        return;
    UICollectionView* collectionView = (UICollectionView*)scrollView;
    //we will try to take the most middle cell or the smallest if there isn't a middle
    int cellIndex = INT_MAX;
    if([collectionView visibleCells].count == 3)
    {
        UICollectionViewCell* cell = [collectionView visibleCells][1];
        NSIndexPath *indexPath = [collectionView indexPathForCell:cell];
        cellIndex = (int) indexPath.row;
    }
    else
    {
        //get the smallest
        for(UICollectionViewCell* cell in [collectionView visibleCells])
        {
            NSIndexPath *indexPath = [collectionView indexPathForCell:cell];
            if(indexPath.row < cellIndex)
                cellIndex = (int)indexPath.row;
        }
    }
    int section = (int)collectionView.tag;
    Stream* s = showStreamsArray[section];
    
    //update the current share index
    s.currentShareIndex = cellIndex;
    
    //if we are in a loading cell then just return
    if(cellIndex >= s.streamShares.count)
        return;
    
    PFObject* streamShare = [s.streamShares objectAtIndex:cellIndex];
    PFObject* share = [streamShare objectForKey:@"share"];
    
    // NSLog(@"row is %d", row);
    
    PFQuery* query = [PFQuery queryWithClassName:@"UserStreams"];
    [query whereKey:@"user" equalTo:[PFUser currentUser]];
    [query whereKey:@"stream" equalTo:s.stream];
    [query findObjectsInBackgroundWithBlock:^(NSArray *objects, NSError *error) {
         if(error || !objects || !objects.count || !objects[0])
             return;
         PFObject* userStream = objects[0];
         userStream[@"stream_share"] = streamShare;
         userStream[@"share"] = share;
         [userStream saveInBackground];
     }];

}


//need to save the current share in the background and update the array index
- (void)collectionView:(UICollectionView *)collectionView willDisplayCell:(StreamCollectionViewCell *)cell forItemAtIndexPath:(NSIndexPath *)indexPath
{
    
    //helper vars
    int section = (int)collectionView.tag;
    Stream* s = showStreamsArray[section];
    
    //checking if we hit a loading row.  If so, we want to increment the current page, and get the new users
    if(cell.tag == END_LOADING_SHARE_TAG)
    {
        @synchronized(self)
        {
            //if downloading then return
            if(s.isDownloadingAfter)
                return;
            NSLog(@"at end loading cell");
            [self loadSharesRight:s.stream limitOf:SHARES_PER_PAGE];
        }
    }
    else if(cell.tag == BEGINNING_LOADING_SHARE_TAG)
    {
        @synchronized(self)
        {
            //if downloading then return
            if(s.isDownloadingPrevious)
                return;
            
            NSLog(@"at beginning loading cell with time %@", [NSDate date]);
            //make sure we didn't download the beggining cell
            //see if we have the first share in the array or not
            PFObject* firstShare = [s.streamShares[0] objectForKey:@"share"];
            if([((PFObject*)[s.stream objectForKey:@"firstShare"]).objectId isEqualToString:firstShare.objectId])
            {
                [self sortStreams];
                return;
            }
            [self loadSharesLeft:s.stream limitOf:SHARES_PER_PAGE];
        }
    }

}

/*collection view delegates*/
-(NSInteger)numberOfSectionsInCollectionView:(UICollectionView *)collectionView {
    return 1;
}

-(NSInteger)collectionView:(UICollectionView *)collectionView numberOfItemsInSection:(NSInteger)section {
    //get the stream object for this collection view
    Stream* s = showStreamsArray[collectionView.tag];
    int count = (int) s.streamShares.count;
    
    //see if we have the first share in the array or not
    bool hasFirstShare = NO;
    PFObject* firstShare = [s.streamShares[0] objectForKey:@"share"];
    if([((PFObject*)[s.stream objectForKey:@"firstShare"]).objectId isEqualToString:firstShare.objectId])
        hasFirstShare = YES;
        
    //see if we have the share with the most recent time
    PFObject* lastShare = [s.streamShares lastObject];
    NSDate* newestShareTime = s.newestShareCreationTime;
    bool hasNewestShare = NO;
    if(NSOrderedSame == ([newestShareTime compare:lastShare.createdAt]))
        hasNewestShare = YES;
    
    return count+!hasNewestShare+!hasFirstShare;
}
-(UICollectionViewCell *)collectionView:(UICollectionView *)collectionView cellForItemAtIndexPath:(NSIndexPath *)indexPath
{
    StreamCollectionViewCell* cell = [collectionView dequeueReusableCellWithReuseIdentifier:@"streamCell" forIndexPath:indexPath];
    [cell setUserInteractionEnabled:NO];
    //get the correct list of shares
    Stream* s = showStreamsArray[collectionView.tag];
    bool hasFirstShare = NO;
    PFObject* firstShare = [s.streamShares[0] objectForKey:@"share"];
    if([((PFObject*)[s.stream objectForKey:@"firstShare"]).objectId isEqualToString:firstShare.objectId])
        hasFirstShare = YES;
    
    
    //NSLog(@"firstshare is %@ and first in streamshares is %@", ((PFObject*)[stream objectForKey:@"firstShare"]).objectId, firstShare.objectId);
    
    //we are in the beginning loading row
    if(!hasFirstShare && !indexPath.row)
    {
        cell.tag = BEGINNING_LOADING_SHARE_TAG;
        cell.shareImageView.image = [UIImage imageNamed:@"pictures-512.png"];
        UIActivityIndicatorView* collectionActivityIndicator = [[UIActivityIndicatorView alloc] initWithActivityIndicatorStyle:UIActivityIndicatorViewStyleWhiteLarge];
        collectionActivityIndicator.hidesWhenStopped = YES;
        collectionActivityIndicator.hidden = NO;
        [collectionActivityIndicator startAnimating];
        collectionActivityIndicator.center = cell.shareImageView.center;
        [cell.shareImageView addSubview:collectionActivityIndicator];
        
    }
    //in an image row
    else if(indexPath.row < s.streamShares.count+!hasFirstShare)
    {
        cell.tag = SHARE_CELL_TAG;
        UIActivityIndicatorView* collectionActivityIndicator = [[UIActivityIndicatorView alloc] initWithActivityIndicatorStyle:UIActivityIndicatorViewStyleWhiteLarge];
        collectionActivityIndicator.hidesWhenStopped = YES;
        collectionActivityIndicator.hidden = NO;
        [collectionActivityIndicator startAnimating];
        collectionActivityIndicator.center = cell.shareImageView.center;
        [cell.shareImageView addSubview:collectionActivityIndicator];
        
        PFObject* streamShare = s.streamShares[indexPath.row-!hasFirstShare];
        PFObject* share = [streamShare objectForKey:@"share"];
        NSLog(@"after stream share");
        //get imageview
        cell.shareImageView.image = [UIImage imageNamed:@"pictures-512.png"];
        cell.shareImageView.file = [share objectForKey:@"file"];
        [cell.shareImageView loadInBackground:^(UIImage *image, NSError *error) {
            [cell setUserInteractionEnabled:YES];
            CGRect rect = CGRectMake(image.size.width/2-cell.frame.size.width/2, image.size.height/2-cell.frame.size.height/2, cell.frame.size.width, cell.frame.size.height);
            UIImage* tmpImage = [self fixOrientation:image withOrientation:image.imageOrientation];
            CGImageRef imageRef = CGImageCreateWithImageInRect([tmpImage CGImage], rect);
            UIImage *newImage = [UIImage imageWithCGImage:imageRef];
            cell.shareImageView.image = newImage;
            for(UIView* view in [cell.shareImageView subviews])
                if([view isKindOfClass:[UIActivityIndicatorView class]])
                    [view removeFromSuperview];
        }];
        NSLog(@"got to end of row");
    }
    else
    {
        cell.tag = END_LOADING_SHARE_TAG;
        cell.shareImageView.image = [UIImage imageNamed:@"pictures-512.png"];
        UIActivityIndicatorView* collectionActivityIndicator = [[UIActivityIndicatorView alloc] initWithActivityIndicatorStyle:UIActivityIndicatorViewStyleWhiteLarge];
        collectionActivityIndicator.hidesWhenStopped = YES;
        collectionActivityIndicator.hidden = NO;
        [collectionActivityIndicator startAnimating];
        collectionActivityIndicator.center = cell.shareImageView.center;
        
        [cell.shareImageView addSubview:collectionActivityIndicator];
    }
    return cell;
}

//click on cell
-(void)collectionView:(UICollectionView *)collectionView
didSelectItemAtIndexPath:(NSIndexPath *)indexPath {
    Stream* s = showStreamsArray[collectionView.tag];
    bool hasFirstShare = NO;
    PFObject* firstShare = [s.streamShares[0] objectForKey:@"share"];
    if([((PFObject*)[s.stream objectForKey:@"firstShare"]).objectId isEqualToString:firstShare.objectId])
        hasFirstShare = YES;
    
    _selectedSectionIndex = collectionView.tag;
    _selectedCellIndex = indexPath.row-!hasFirstShare;
    [self performSegueWithIdentifier:@"viewStreamSegue" sender:self];
}

//Prepare segue
- (void) prepareForSegue:(UIStoryboardSegue *)segue sender:(id)sender {
    //If we are segueing to selectedProfile then we need to save profile ID
    if([segue.identifier isEqualToString:@"viewStreamSegue"]){
        ViewStreamCollectionViewController* controller = (ViewStreamCollectionViewController*)segue.destinationViewController;
        //NSLog(@"selected section and row %d, %d", _selectedSectionIndex, _selectedCellIndex);
        
        controller.streamObject = showStreamsArray[_selectedSectionIndex];
        controller.currentRow = _selectedCellIndex;
        _selectedStream = ((Stream*)showStreamsArray[_selectedSectionIndex]).stream;
    }
    else if ([segue.identifier isEqualToString:@"chooseStreamsSegue"]){
        SelectStreamsTableViewController* controller = (SelectStreamsTableViewController*)segue.destinationViewController;
        controller.imageData = _imageData;
        controller.captionText = caption.text;
    }
}

- (CGFloat)tableView:(UITableView *)tableView heightForHeaderInSection:(NSInteger)section {
    return HEADER_HEIGHT;
}

- (IBAction)addStreamAction:(id)sender {
    _creatingStream = YES;
    [self setTitleForStream];
}

//set the title and expiration for a stream
-(void) setTitleForStream
{
    UIAlertController *alertController = [UIAlertController
                                          alertControllerWithTitle:@"Create A New Stream"
                                          message:@"Name the new stream:"
                                          preferredStyle:UIAlertControllerStyleAlert];
    
    [alertController addTextFieldWithConfigurationHandler:^(UITextField *textField)
     {
         textField.placeholder = NSLocalizedString(@"Stream Name", @"Stream Name");
         textField.delegate = self;
     }];
    
    UIAlertAction *okAction = [UIAlertAction
                               actionWithTitle:NSLocalizedString(@"OK", @"OK action")
                               style:UIAlertActionStyleDefault
                               handler:^(UIAlertAction *action)
                               {
                                   UITextField *name = alertController.textFields.firstObject;
                                   _streamName = name.text;
                                   
                                   //present error for nil length
                                   if(!_streamName.length)
                                   {
                                       UIAlertController *alertController = [UIAlertController
                                                                             alertControllerWithTitle:@"Empty Name"
                                                                             message:@"Make sure to name the new stream."
                                                                             preferredStyle:UIAlertControllerStyleAlert];
                                       UIAlertAction *okAction = [UIAlertAction
                                                                  actionWithTitle:NSLocalizedString(@"Ok", @"Ok action")
                                                                  style:UIAlertActionStyleDefault
                                                                  handler:^(UIAlertAction *action)
                                                                  {
                                                                      [self setTitleForStream];
                                                                      return;
                                                                  }];
                                       
                                       [alertController addAction:okAction];
                                       [self presentViewController:alertController animated:YES completion:nil];
                                       return;
                                   }
                                   
                                   //take the photo
                                   [self takePhoto];
                                   
                               }];
    
    UIAlertAction *cancelAction = [UIAlertAction
                                   actionWithTitle:NSLocalizedString(@"Cancel", @"Cancel action")
                                   style:UIAlertActionStyleCancel
                                   handler:^(UIAlertAction *action)
                                   {
                                       [self.navigationController popViewControllerAnimated:YES];
                                       return;
                                   }];
    
    [alertController addAction:cancelAction];
    [alertController addAction:okAction];
    [self presentViewController:alertController animated:YES completion:nil];
}


//helper function to setup the camera
-(void) takePhoto
{
    _imagePickerOpen = YES;
    customPicker = [[CustomPickerViewController alloc] init];
    customPicker.delegate = self;
    customPicker.allowsEditing = NO;
    customPicker.sourceType = UIImagePickerControllerSourceTypeCamera;
    customPicker.showsCameraControls = NO;
    customPicker.canTakePicture = YES;
    _flashMode = UIImagePickerControllerCameraFlashModeAuto;
    _isTakingPicture = YES;
    //set original center
    _originalCenter = customPicker.view.center;
    
    //helper variables
    float screenWidth = self.view.frame.size.width;
    float pickerHeight = (4.0/3.0*screenWidth);
    
    NSLog(@"picker height is %f",pickerHeight);
    
    // overlay on top of camera lens view
    cameraOverlayView = [[UIImageView alloc] initWithFrame:CGRectMake(0,0,screenWidth, pickerHeight)];
    UIImage* overlay = [UIImage imageNamed:@"camera_overlay.png"];
    [cameraOverlayView setContentMode:UIViewContentModeScaleToFill];
    cameraOverlayView.image = overlay;
    cameraOverlayView.alpha = 0.0f;

    //make a textview for the caption on the camera
    caption = [[UITextView alloc] initWithFrame:CGRectMake(0, 2+ pickerHeight, screenWidth, self.view.frame.size.height-pickerHeight-TOOLBAR_HEIGHT-2)];
    caption.delegate = self;
    caption.text = @"Enter Caption:";
    caption.textColor = [UIColor grayColor];
    [caption.layer setBorderColor:[[[UIColor grayColor] colorWithAlphaComponent:0.5] CGColor]];
    [caption.layer setBorderWidth:2.0];
    //The rounded corner part, where you specify your view's corner radius:
    caption.layer.cornerRadius = 10;
    caption.returnKeyType = UIReturnKeyDone;
    
    //setup the toolbar
    toolBar = [[UIToolbar alloc] initWithFrame:CGRectMake(0, pickerHeight+caption.frame.size.height+2, screenWidth, TOOLBAR_HEIGHT)];
    UIBarButtonItem *cancelButton = [[UIBarButtonItem alloc] initWithBarButtonSystemItem:UIBarButtonSystemItemCancel target:self action:@selector(cancelClicked:)];
    UIBarButtonItem *flipButton = [[UIBarButtonItem alloc] initWithImage:[UIImage imageNamed:@"cameraFlip.png"] style:UIBarButtonItemStyleDone target:self action:@selector(flipCamera:)];
    flashButton = [[UIBarButtonItem alloc] initWithImage:[UIImage imageNamed:@"automaticFlash.png"] style:UIBarButtonItemStyleDone target:self action:@selector(cameraFlash:)];
    [flipButton setTintColor:[UIColor whiteColor]];
    [flashButton setTintColor:[UIColor whiteColor]];
    [cancelButton setTintColor:[UIColor whiteColor]];
    [toolBar setItems:[NSArray arrayWithObjects:cancelButton,[[UIBarButtonItem alloc] initWithBarButtonSystemItem:UIBarButtonSystemItemFlexibleSpace target:nil action:nil], flashButton, [[UIBarButtonItem alloc] initWithBarButtonSystemItem:UIBarButtonSystemItemFlexibleSpace target:nil action:nil], flipButton, nil]];
    [toolBar setBarStyle:UIBarStyleBlack];
    [toolBar setBackgroundColor:[UIColor blackColor]];
    
    //check if I have to redo caption height
    if(caption.frame.size.height < TABLE_VIEW_BAR_HEIGHT)
    {
        caption.frame = CGRectMake(0, toolBar.frame.origin.y-TABLE_VIEW_BAR_HEIGHT, screenWidth, TABLE_VIEW_BAR_HEIGHT);
    }
    
    //add the subviews
    [customPicker.view addSubview:cameraOverlayView];
    [customPicker.view addSubview:caption];
    [customPicker.view addSubview:toolBar];
    
    NSLog(@"textview height is %f", caption.frame.size.height);
    
    // animate the fade in after the shutter opens
    [UIView beginAnimations:nil context:NULL];
    [UIView setAnimationDelay:2.2f];
    cameraOverlayView.alpha = 1.0f;
    [UIView commitAnimations];
    
    
    [self presentViewController:customPicker animated:YES completion:NULL];
}

- (void)imagePickerController:(UIImagePickerController *)picker didFinishPickingMediaWithInfo:(NSDictionary *)info {
    
    //Don't allow pictures to be taken
    customPicker.canTakePicture = NO;
    _isTakingPicture = NO;
    
    //helper var
    float screenWidth = self.view.frame.size.width;
    _expirationTime = ((NSNumber*)[[PFUser currentUser] objectForKey:@"streamTimeHours"]).floatValue;
    
    //figure out the image
    UIImage* image =[info objectForKey:UIImagePickerControllerOriginalImage];
    //NSNumber* orientation = [((NSDictionary*)[info objectForKey:UIImagePickerControllerMediaMetadata]) objectForKey:@"Orientation"];
    //NSLog(@"image metadata is %@", [info objectForKey:UIImagePickerControllerMediaMetadata]);
    
    //NSLog(@"image orientation is %d", orientation.intValue);
    
   /* NSLog(@"image is %f, %f", image.size.width, image.size.height);
    NSLog(@"overlay is %f, %f, %f, %f", cameraOverlayView.frame.origin.x, cameraOverlayView.frame.origin.y, cameraOverlayView.frame.size.width, cameraOverlayView.frame.size.height);
    CGRect rect = CGRectMake(image.size.width/2-screenWidth/2, TOOLBAR_HEIGHT, screenWidth, screenWidth*4.0/3.0);
    CGImageRef imageRef = CGImageCreateWithImageInRect([image CGImage], rect);
    UIImage *newImage = [UIImage imageWithCGImage:imageRef];*/
    NSLog(@"image orientation is = %d", (int)image.imageOrientation);
    int imageOrientation = 3 - image.imageOrientation;
    if(image.imageOrientation == 1)
        imageOrientation = 3;
    UIImage* fixedImage = [self fixOrientation:image withOrientation:imageOrientation];
    CGSize destinationSize = CGSizeMake(screenWidth, 4.0/3.0*screenWidth);
    UIGraphicsBeginImageContext(destinationSize);
    [fixedImage drawInRect:CGRectMake(0,0,destinationSize.width,destinationSize.height)];
    UIImage *newImage = UIGraphicsGetImageFromCurrentImageContext();
    UIGraphicsEndImageContext();
    
    //if the image is from front camera, need to flip horizontally
    if(customPicker.cameraDevice == UIImagePickerControllerCameraDeviceFront)
    {
        //depending on the orientation is how we flip it
        if(image.imageOrientation == 3 || image.imageOrientation == 0 || image.imageOrientation == 1)
            newImage = [UIImage imageWithCGImage:newImage.CGImage
                                       scale:newImage.scale
                                 orientation:UIImageOrientationUpMirrored];
        else
            newImage = [UIImage imageWithCGImage:newImage.CGImage
                                           scale:newImage.scale
                                     orientation:UIImageOrientationRightMirrored];
    }
    //set the image data
    _imageData = UIImageJPEGRepresentation(newImage, 1.0f);
    cameraOverlayView.image = newImage;
    
    //reset the toolbar
    UIBarButtonItem *cancelButton = [[UIBarButtonItem alloc] initWithBarButtonSystemItem:UIBarButtonSystemItemCancel target:self action:@selector(cancelClicked:)];
    UIBarButtonItem *publishButton = [[UIBarButtonItem alloc] initWithImage:[UIImage imageNamed:@"publish.png"] style:UIBarButtonItemStyleDone target:self action:@selector(publishClicked:)];
    UIBarButtonItem *saveButton = [[UIBarButtonItem alloc] initWithImage:[UIImage imageNamed:@"save.png"] style:UIBarButtonItemStyleDone target:self action:@selector(saveClicked:)];
    
    [cancelButton setTintColor:[UIColor whiteColor]];
    [publishButton setTintColor:[UIColor whiteColor]];
    [saveButton setTintColor:[UIColor whiteColor]];
    //if we are contribute to an existing stream, then it is easy
    if(!_creatingStream)
    {
        [toolBar setItems:[NSArray arrayWithObjects:cancelButton, [[UIBarButtonItem alloc] initWithBarButtonSystemItem:UIBarButtonSystemItemFlexibleSpace target:nil action:nil], saveButton, [[UIBarButtonItem alloc] initWithBarButtonSystemItem:UIBarButtonSystemItemFlexibleSpace target:nil action:nil],publishButton, nil]];
    }
    else//need to add timer as well
    {
        //create a custom timer view
        UIView* timerView = [[UIView alloc] initWithFrame:CGRectMake(0,0,TOOLBAR_HEIGHT, TOOLBAR_HEIGHT)];
        [timerView setUserInteractionEnabled:YES];
        UITapGestureRecognizer *timerTap =  [[UITapGestureRecognizer alloc] initWithTarget:self action:@selector(timerSelected:)];
        timerTap.numberOfTapsRequired = 1;
        [timerView addGestureRecognizer:timerTap];
        
        //create a button with a timer image
        UIButton* customButton = [UIButton buttonWithType:UIButtonTypeCustom];
        customButton.frame = CGRectMake(0,0,TOOLBAR_HEIGHT/2, TOOLBAR_HEIGHT/2);
        [customButton setBackgroundImage:[UIImage imageNamed:@"timer.png"] forState:UIControlStateNormal];
        [customButton addTarget:self action:@selector(timerSelected:) forControlEvents:UIControlEventTouchUpInside];
        customButton.center = timerView.center;
        
        //create a label to store the default time for the user
        timeLabel = [[UILabel alloc] initWithFrame:CGRectMake(0,0,TOOLBAR_HEIGHT/2, TOOLBAR_HEIGHT/2)];
        timeLabel.center = timerView.center;
        timeLabel.text = [NSString stringWithFormat:@"%.01f", _expirationTime];
        timeLabel.font = [UIFont boldSystemFontOfSize:9.0];
        timeLabel.textColor = [UIColor whiteColor];
        timeLabel.numberOfLines = 1;
        timeLabel.textAlignment = NSTextAlignmentCenter;
        UITapGestureRecognizer *labelTap =  [[UITapGestureRecognizer alloc] initWithTarget:self action:@selector(timerLabelSelected:)];
        labelTap.numberOfTapsRequired = 1;
        [timeLabel addGestureRecognizer:labelTap];
        
        //add the button and label to the view
        [timerView addSubview:customButton];
        [timerView addSubview:timeLabel];
        
        //create the bar button item based on the view
        UIBarButtonItem* timerBarButtonItem = [[UIBarButtonItem alloc] initWithCustomView:timerView];
        [timerBarButtonItem setTintColor:[UIColor whiteColor]];
        //add the bar button items to the toolbar
        [toolBar setItems:[NSArray arrayWithObjects:cancelButton,[[UIBarButtonItem alloc] initWithBarButtonSystemItem:UIBarButtonSystemItemFlexibleSpace target:nil action:nil], saveButton, [[UIBarButtonItem alloc] initWithBarButtonSystemItem:UIBarButtonSystemItemFlexibleSpace target:nil action:nil],timerBarButtonItem, [[UIBarButtonItem alloc] initWithBarButtonSystemItem:UIBarButtonSystemItemFlexibleSpace target:nil action:nil],publishButton, nil]];
        
        //also setup the pickerview
        [self setupPicker];
    }
    
}

//Method to define how many columns/dials to show
- (NSInteger)numberOfComponentsInPickerView:(UIPickerView *)pickerView
{
    return 2;
}


// Method to define the numberOfRows in a component using the array.
- (NSInteger)pickerView:(UIPickerView *)pickerView numberOfRowsInComponent :(NSInteger)component
{
    if(component == 0)
        return 12;
    
    return 2;
    
}

- (CGFloat)pickerView:(UIPickerView *)pickerView rowHeightForComponent:(NSInteger)component
{
    return 30;
}

// Method to show the title of row for a component.
- (NSString *)pickerView:(UIPickerView *)pickerView titleForRow:(NSInteger)row forComponent:(NSInteger)component
{
    //every 30 mins
    if(component)
        return [NSString stringWithFormat:@"%d",(int)row*30 ];
    return [NSString stringWithFormat:@"%d",(int)row+1 ];
}

- (NSAttributedString *)pickerView:(UIPickerView *)pickerView attributedTitleForRow:(NSInteger)row forComponent:(NSInteger)component
{
    NSString *title = [NSString stringWithFormat:@"%d",(int)row+1 ];
    if(component)
        title = [NSString stringWithFormat:@"%d",(int)row*30 ];
    NSAttributedString *attString = [[NSAttributedString alloc] initWithString:title attributes:@{NSForegroundColorAttributeName:[UIColor whiteColor]}];
    
    return attString;
    
}


// Catpure the picker view selection
- (void)pickerView:(UIPickerView *)pickerView didSelectRow:(NSInteger)row inComponent:(NSInteger)component
{
    switch (component)
    {
        case 0:
            _hours = [NSString stringWithFormat:@"%d",(int)row+1 ];
            break;
        case 1:
            _mins = [NSString stringWithFormat:@"%d",(int)row*30 ];
            break;
    }
}



-(void) setupPicker
{
    pickerView = [[UIPickerView alloc] initWithFrame:CGRectMake(10,self.view.frame.size.height, self.view.frame.size.width-10, TOOLBAR_HEIGHT)];
    pickerView.layer.cornerRadius = PICTURE_SIZE/10;
    pickerView.clipsToBounds = YES;
    pickerView.backgroundColor = [UIColor blackColor];
    pickerView.center = CGPointMake(self.view.center.x,pickerView.frame.size.height+self.view.frame.size.height);
    [self.customPicker.view addSubview:pickerView];
    
    
    [pickerView setDataSource: self];
    [pickerView setDelegate: self];
    
    UILabel *hourLabel = [[UILabel alloc] initWithFrame:CGRectMake(pickerView.frame.size.width/2 -42, pickerView.frame.size.height / 2 - 15, 75, 30)];
    hourLabel.text = @"hours";
    hourLabel.textColor = [UIColor whiteColor];
    [pickerView addSubview:hourLabel];
    
    UILabel *minsLabel = [[UILabel alloc] initWithFrame:CGRectMake(pickerView.frame.size.width-42, pickerView.frame.size.height / 2 - 15, 75, 30)];
    minsLabel.text = @"mins";
    minsLabel.textColor = [UIColor whiteColor];
    [pickerView addSubview:minsLabel];
    
    _expirationTime = ((NSNumber*)[[PFUser currentUser] objectForKey:@"streamTimeHours"]).floatValue;
    
    int hours = floor(_expirationTime);
    int mins;
    if(floor(_expirationTime)==_expirationTime)
        mins = 0;
    else
        mins = 30;
    
    _hours = [NSString stringWithFormat:@"%d", hours];
    _mins = [NSString stringWithFormat:@"%d", mins];
    [pickerView selectRow:hours-1 inComponent:0 animated:NO];
    [pickerView selectRow:!!mins inComponent:1 animated:NO];
    _pickerShown = NO;
    
}

-(void) timerLabelSelected:(id) sender
{
    [self timerSelected:self];
}

//helper to change the timer
-(void) timerSelected:(id)sender
{
    NSLog(@"timer selected fired");
    //toggle showing the picker
    if(_pickerShown)
    {
        [self dismissPicker:self];
    }
    else
    {
        [UIView animateWithDuration:0.5
                         animations:^{
                             pickerView.center = CGPointMake(self.view.center.x,self.view.frame.size.height-pickerView.frame.size.height/2);
                             [self.view layoutIfNeeded];
                         }];
        //picker is showing
        _pickerShown = YES;

    }
    
    
    

}

//save the image to your photo library
-(void) saveClicked:(id) sender
{
    UIImage* imageTaken = [UIImage imageWithData:_imageData];
    UIImageWriteToSavedPhotosAlbum(imageTaken, self, @selector(image:didFinishSavingWithError:contextInfo:), nil);
}

- (void)image:(UIImage *)image didFinishSavingWithError:(NSError *)error contextInfo:(void *)contextInfo {
    UIAlertView *alert;
    //NSLog(@"Image:%@", image);
    if (error) {
        alert = [[UIAlertView alloc] initWithTitle:@"Error!"
                                           message:@"Please add Photos permissions for this app!"
                                          delegate:nil
                                 cancelButtonTitle:@"OK"
                                 otherButtonTitles:nil];
        [alert show];
    }
    else
    {
        alert = [[UIAlertView alloc] initWithTitle:@"Success!"
                                           message:@"Photo was saved to your library."
                                          delegate:nil
                                 cancelButtonTitle:@"OK"
                                 otherButtonTitles:nil];
        [alert show];
    }
        
    
}

-(void) publishClicked:(id)sender
{
    activityIndicator = [[UIActivityIndicatorView alloc] initWithActivityIndicatorStyle:UIActivityIndicatorViewStyleWhiteLarge];
    activityIndicator.center = cameraOverlayView.center;
    [activityIndicator startAnimating];
    [activityIndicator setHidden:NO];
    [customPicker.view addSubview:activityIndicator];
    UIBarButtonItem* publish = [[toolBar items] lastObject];
    publish.enabled = NO;
    //deciding if I am creating the stream or just a share
    if(_creatingStream)
        [self createStream];
    else if(_openedWithShake)
    {
        //check if there is 1 stream only
        int count = 0;
        AppDelegate* appDelegate = [[UIApplication sharedApplication] delegate];
        NSMutableArray* streams = [appDelegate streams];
        for(Stream* s in streams)
        {
            //check to see if the match is still valid
            NSDate* date = [s.stream objectForKey:@"endTime"];
            NSTimeInterval interval = [date timeIntervalSinceDate:[NSDate date]];
            if(!isnan(interval) && interval>0)
            {
                count++;
                _selectedStream = s.stream;
            }
        }
        if(count > 1)
            [self dismissImagePickerView];
        else
        {
            _openedWithShake = NO;
            [self addNewShareToStream:caption.text];
        }
    }
    else
        [self addNewShareToStream:caption.text];
}

//helper to dismiss image pickers
-(void) dismissImagePickerView
{
    [self sortStreams];
    CATransition* transition = [CATransition animation];
    transition.duration = .5;
    transition.timingFunction = [CAMediaTimingFunction functionWithName:kCAMediaTimingFunctionEaseInEaseOut];
    transition.type = kCATransitionReveal; //kCATransitionMoveIn; //, kCATransitionPush, kCATransitionReveal, kCATransitionFade
    transition.subtype = kCATransitionFromBottom; //kCATransitionFromLeft, kCATransitionFromRight, kCATransitionFromTop, kCATransitionFromBottom
    
    [self.navigationController.view.layer addAnimation:transition
                                                forKey:kCATransition];
    
    _imagePickerOpen = NO;
    if(_openedWithShake)
    {
        _openedWithShake = NO;
        
        [customPicker dismissViewControllerAnimated:NO completion:^{
           [self performSegueWithIdentifier:@"chooseStreamsSegue" sender:self];
        }];
    }
    else
        [customPicker dismissViewControllerAnimated:NO completion:NULL];
}

-(void) cancelClicked:(id)sender
{
    //first picture
    if(_isTakingPicture)
    {
        _openedWithShake = NO;
        [self dismissImagePickerView];
    }
    //second picture
    else
    {
        //remove pickerview from picture if it is there
        if(_creatingStream)
            [pickerView removeFromSuperview];
        
        //reset toolbar
        UIBarButtonItem *cancelButton = [[UIBarButtonItem alloc] initWithBarButtonSystemItem:UIBarButtonSystemItemCancel target:self action:@selector(cancelClicked:)];
        UIBarButtonItem *flipButton = [[UIBarButtonItem alloc] initWithImage:[UIImage imageNamed:@"cameraFlip.png"] style:UIBarButtonItemStyleDone target:self action:@selector(flipCamera:)];
        
        [toolBar setItems:[NSArray arrayWithObjects:cancelButton,[[UIBarButtonItem alloc] initWithBarButtonSystemItem:UIBarButtonSystemItemFlexibleSpace target:nil action:nil], flashButton, [[UIBarButtonItem alloc] initWithBarButtonSystemItem:UIBarButtonSystemItemFlexibleSpace target:nil action:nil], flipButton, nil]];
        [flipButton setTintColor:[UIColor whiteColor]];
        [cancelButton setTintColor:[UIColor whiteColor]];
        
        
        //return to taking picture
        _isTakingPicture = YES;
        customPicker.canTakePicture = YES;
        cameraOverlayView.image = [UIImage imageNamed:@"camera_overlay.png"];
    }
}

-(void) flipCamera:(id)sender
{
    [UIView transitionWithView:customPicker.view duration:1.0 options:UIViewAnimationOptionAllowAnimatedContent | UIViewAnimationOptionTransitionFlipFromLeft animations:^{
        if(customPicker.cameraDevice == UIImagePickerControllerCameraDeviceFront)
            customPicker.cameraDevice = UIImagePickerControllerCameraDeviceRear;
        else
            customPicker.cameraDevice = UIImagePickerControllerCameraDeviceFront;
    } completion:NULL];
}

-(void) cameraFlash:(id) sender
{
    //set the correct flash mode
    if (self.flashMode == UIImagePickerControllerCameraFlashModeAuto)
    {
        //toggle your button to "on"
        self.flashMode = self.customPicker.cameraFlashMode = UIImagePickerControllerCameraFlashModeOn;
        flashButton.image = [UIImage imageNamed:@"flash.png"];
    }
    else if (self.flashMode == UIImagePickerControllerCameraFlashModeOn)
    {
        //toggle your button to "Off"
        self.flashMode = self.customPicker.cameraFlashMode = UIImagePickerControllerCameraFlashModeOff;
        flashButton.image = [UIImage imageNamed:@"noFlash.png"];
    }
    else if (self.flashMode == UIImagePickerControllerCameraFlashModeOff)
    {
        //toggle your button to "Auto"
        self.flashMode = self.customPicker.cameraFlashMode = UIImagePickerControllerCameraFlashModeAuto;
        flashButton.image = [UIImage imageNamed:@"automaticFlash.png"];
    }
}

-(void) dismissPicker:(id) sender
{
    NSLog(@"dismiss picker fired");
    [UIView animateWithDuration:0.5
                     animations:^{
                         pickerView.center = CGPointMake(self.view.center.x,self.view.frame.size.height+pickerView.frame.size.height);
                         [self.view layoutIfNeeded];
                     }];
    _pickerShown = NO;
    
    //also need to now see if the time changed so get the expiration time in hours
    int hours = _hours.intValue;
    int mins = _mins.intValue;
    float expTime = hours;
    if (mins)
        expTime +=.5;
    
    //if the expTime is the same as _expiration time then just return since there was no change
    if(expTime == _expirationTime)
        return;
    
    //we need to update the preferred expiration time
    _expirationTime = expTime;
    __block PFUser* user = [PFUser currentUser];
    user[@"streamTimeHours"] = [NSNumber numberWithFloat:_expirationTime];
    [user saveInBackground];
    [user refreshInBackgroundWithBlock:^(PFObject *object, NSError *error) {if(!error)user = (PFUser*)object;}];
    
    //now we need to update the label
    timeLabel.text = [NSString stringWithFormat:@"%.01f",_expirationTime ];
    
}



//create the share
-(void) createStream
{
    //Figure out the end time
    NSLog(@"hours = %@, min = %@", _hours, _mins);
    float secs = (_hours.intValue*3600 + _mins.intValue*60);
    NSLog(@"secs is %f", secs);
    float endTime = secs + [[NSDate date] timeIntervalSince1970];
    NSDate* endDate = [NSDate dateWithTimeIntervalSince1970:endTime];
    if(!caption.text.length || [caption.text isEqualToString:@"Enter Caption:"])
        caption.text = @"No caption.";
    PFUser* user = [PFUser currentUser];

    //Create the default acl
    PFACL *defaultACL = [PFACL ACL];
    [defaultACL setReadAccess:true forUser:user];
    [defaultACL setWriteAccess:true forUser:user];
    [defaultACL setPublicReadAccess:false];
    [defaultACL setPublicWriteAccess:false];
    
    
    //create the file
    PFFile *pictureFile = [PFFile fileWithData:_imageData];
    
    //create the share
    PFObject* share = [PFObject objectWithClassName:@"Share"];
    share[@"caption"] = caption.text;
    share[@"user"] = user;
    share[@"username"] = user.username;
    share[@"isPrivate"] = [NSNumber numberWithBool:NO];
    share[@"type"] = @"img";
    [share setObject:pictureFile forKey:@"file"];
    [share setACL:defaultACL];
    
    //create the new stream
    PFObject* stream = [PFObject objectWithClassName:@"Stream"];
    stream[@"isPrivate"] = [NSNumber numberWithBool:NO]; //Just hardcoding this for now
    stream[@"name"] = _streamName;
    stream[@"creator"] = user;
    stream[@"endTime"] = endDate;
    stream[@"firstShare"] = share;
    [stream setACL:defaultACL];
    
    //create the stream share
    PFObject* streamShare = [PFObject objectWithClassName:@"StreamShares"];
    streamShare[@"stream"] = stream;
    streamShare[@"share"] = share;
    streamShare[@"user"] = user;
    streamShare[@"isIgnored"] = [NSNumber numberWithBool:NO];
    [streamShare setACL:defaultACL];
    
    //create the user stream
    PFObject* userStream = [PFObject objectWithClassName:@"UserStreams"];
    userStream[@"user"] = user;
    userStream[@"stream"] = stream;
    userStream[@"stream_share"] = streamShare;
    userStream[@"share"] = share;
    userStream[@"creator"] = user;
    userStream[@"isIgnored"] = [NSNumber numberWithBool:NO];
    [userStream setACL:defaultACL];
    
    
    
    NSArray* pfObjects = [[NSArray alloc] initWithObjects:share,stream,streamShare,userStream, nil];
    [PFObject saveAllInBackground:pfObjects block:^(BOOL succeeded, NSError *error) {
        if(error)
        {
            UIAlertController *alertController = [UIAlertController
                                                  alertControllerWithTitle:@"Error Starting Stream"
                                                  message:@"An error occurred starting the stream.  Check your internet connection and try again."
                                                  preferredStyle:UIAlertControllerStyleAlert];
            UIAlertAction *okAction = [UIAlertAction
                                       actionWithTitle:NSLocalizedString(@"Ok", @"Ok action")
                                       style:UIAlertActionStyleDefault
                                       handler:^(UIAlertAction *action)
                                       {
                                           [PFObject deleteAllInBackground:pfObjects];
                                           [activityIndicator setHidden:YES];
                                           UIBarButtonItem* publish = [[toolBar items] lastObject];
                                           publish.enabled = NO;
                                           return;
                                       }];
            
            [alertController addAction:okAction];
            [self presentViewController:alertController animated:YES completion:nil];
            return;
            
        }
        
        //no error.  Pop and return
        AppDelegate* appDelegate = [[UIApplication sharedApplication] delegate];
        NSMutableArray* streams = [appDelegate streams];
        Stream* newStream = [[Stream alloc] init];
        newStream.stream = stream;
        //want to create an array of shares so we can lazy load the next ones
        [newStream.streamShares addObject:streamShare];
        newStream.totalViewers = 1;
        newStream.username = user.username;
        //newest time of streamshare
        newStream.newestShareCreationTime = streamShare.createdAt;
        [streams addObject:newStream];
        //update the user's points total
        [PFCloud callFunctionInBackground:@"createStreamUpdatePoints" withParameters:@{} block:^(id object, NSError *error) {}];
        //send push to users
        //get nearby user streams first
        MainDatabase* md = [MainDatabase shared];
        __block bool inQueue = YES;
        NSMutableArray* userIds = [[NSMutableArray alloc] init];
        [md.queue inDatabase:^(FMDatabase *db) {
            
            
            //need to delete the peripherals that are about to expire
            NSString *userSQL = @"SELECT DISTINCT user_id FROM user WHERE is_me != ?";
            NSArray* values = @[[NSNumber numberWithInt:1]];
            FMResultSet *s = [db executeQuery:userSQL withArgumentsInArray:values];
            //get the peripheral ids
            while([s next])
            {
                NSLog(@"found user");
                [userIds addObject:[s stringForColumnIndex:0]];
            }
            inQueue = NO;
        }];
        
        while(inQueue)
            ;
        
        //send push
        if(userIds && userIds.count)
            [PFCloud callFunctionInBackground:@"sendPushForStream" withParameters:@{@"streamId":newStream.stream.objectId, @"userIds":userIds} block:^(id object, NSError *error) {}];
        [self dismissImagePickerView];
        
    }];

}

//add photo to share
- (void) addNewShareToStream:(NSString*)captionText
{
    if(!captionText.length || [captionText isEqualToString:@"Enter Caption:"])
        captionText = @"No caption.";
    PFUser* user = [PFUser currentUser];
    
    //update the user's points total
    [PFCloud callFunctionInBackground:@"addToStreamUpdatePoints" withParameters:@{} block:^(id object, NSError *error) {}];
    
    //Create the default acl
    PFACL *defaultACL = [PFACL ACL];
    [defaultACL setReadAccess:true forUser:user];
    [defaultACL setWriteAccess:true forUser:user];
    [defaultACL setPublicReadAccess:false];
    [defaultACL setPublicWriteAccess:false];

    AppDelegate* appDelegate = [[UIApplication sharedApplication] delegate];
    NSMutableArray* streams = [appDelegate streams];
    //get the stream to add this share to
    Stream* streamObj = nil;
    for(Stream* s in streams)
    {
        if([s.stream isEqual:_selectedStream])
        {
            streamObj = s;
            break;
        }
    }
    
    //check if it got removed
    if(!streamObj)
    {
        NSLog(@"couldn't add new share to stream");
        [self dismissImagePickerView];
        return;
    }
    
    //create the file
    PFFile *pictureFile = [PFFile fileWithData:_imageData];
    
    PFObject* share = [PFObject objectWithClassName:@"Share"];
    share[@"caption"] = captionText;
    share[@"user"] = user;
    share[@"username"] = user.username;
    share[@"isPrivate"] = [NSNumber numberWithBool:NO];
    share[@"type"] = @"img";
    [share setObject:pictureFile forKey:@"file"];
    [share setACL:defaultACL];
    
    //create the stream share
    PFObject* streamShare = [PFObject objectWithClassName:@"StreamShares"];
    streamShare[@"stream"] = streamObj.stream;
    streamShare[@"share"] = share;
    streamShare[@"user"] = user;
    streamShare[@"isIgnored"] = [NSNumber numberWithBool:NO];
    [streamShare setACL:defaultACL];
    
    //upload and don't care about an error for now
    NSArray* pfObjects = [[NSArray alloc] initWithObjects:share,streamShare, nil];
    [PFObject saveAllInBackground:pfObjects block:^(BOOL succeeded, NSError *error) {
        [self countStreamShares:@[streamObj.stream.objectId]];
    }];
    [self dismissImagePickerView];
    
}



- (BOOL)textField:(UITextField *)textField
shouldChangeCharactersInRange:(NSRange)range
replacementString:(NSString *)string
{
    //check if they user is trying to enter too many characters
    if([[textField text] length] - range.length + string.length > MAX_TITLE_CHARS)
    {
        return NO;
    }
    
    
    return YES;
}

//used for updating status
- (BOOL)textView:(UITextView *)textView
shouldChangeTextInRange:(NSRange)range
 replacementText:(NSString *)text
{
    
    //check if they user is trying to enter too many characters
    if(([[textView text] length] - range.length + text.length > MAX_CAPTION_CHARS) && ![text isEqualToString:@"\n"])
    {
        return NO;
    }
    
    if([text isEqualToString:@"\n"])
    {
        customPicker.view.center = _originalCenter;
        [textView resignFirstResponder];
        return NO;
    }
    
    return YES;
}

//Delegates for helping textview have placeholder text
- (void)textViewDidBeginEditing:(UITextView *)textView
{
    if([textView.text isEqualToString:@"Enter Caption:"])
    {
        textView.text = @"";
    }
    textView.textColor = [UIColor blackColor];
    
    NSLog(@"set center");
    customPicker.view.center = CGPointMake(self.originalCenter.x, self.originalCenter.y + (self.originalCenter.y - textView.frame.origin.y-textView.frame.size.height/2));
    
    [textView becomeFirstResponder];
}

//Continuation delegate for placeholder text
- (void)textViewDidEndEditing:(UITextView *)textView
{
    if(!textView.text.length || [textView.text isEqualToString:@"Enter Caption:"])
    {
        textView.text = @"Enter Caption:";
        textView.textColor = [UIColor grayColor];
    }
    customPicker.view.center = _originalCenter;
    [textView resignFirstResponder];
}

- (UIImage *)fixOrientation:(UIImage*)image withOrientation:(int)orientation {
    
    //NSLog(@"image orientation is %d", orientation);
    NSLog(@"up = %d, down = %d, right = %d, left = %d", (int)UIImageOrientationUp, (int)UIImageOrientationDown, (int)UIImageOrientationRight, (int)UIImageOrientationLeft);
    
    // No-op if the orientation is already correct
    if (orientation == UIImageOrientationUp) return image;
    
    // We need to calculate the proper transformation to make the image upright.
    // We do it in 2 steps: Rotate if Left/Right/Down, and then flip if Mirrored.
    CGAffineTransform transform = CGAffineTransformIdentity;
    
    switch (orientation) {
        case UIImageOrientationDown:
        case UIImageOrientationDownMirrored:
            transform = CGAffineTransformTranslate(transform, image.size.width, image.size.height);
            transform = CGAffineTransformRotate(transform, M_PI);
            break;
            
        case UIImageOrientationLeft:
        case UIImageOrientationLeftMirrored:
            transform = CGAffineTransformTranslate(transform, image.size.width, 0);
            transform = CGAffineTransformRotate(transform, M_PI_2);
            break;
            
        case UIImageOrientationRight:
        case UIImageOrientationRightMirrored:
            transform = CGAffineTransformTranslate(transform, 0, image.size.height);
            transform = CGAffineTransformRotate(transform, -M_PI_2);
            break;
        case UIImageOrientationUp:
        case UIImageOrientationUpMirrored:
            break;
    }
    
    switch (orientation) {
        case UIImageOrientationUpMirrored:
        case UIImageOrientationDownMirrored:
            transform = CGAffineTransformTranslate(transform, image.size.width, 0);
            transform = CGAffineTransformScale(transform, -1, 1);
            break;
            
        case UIImageOrientationLeftMirrored:
        case UIImageOrientationRightMirrored:
            transform = CGAffineTransformTranslate(transform, image.size.height, 0);
            transform = CGAffineTransformScale(transform, -1, 1);
            break;
        case UIImageOrientationUp:
        case UIImageOrientationDown:
        case UIImageOrientationLeft:
        case UIImageOrientationRight:
            break;
    }
    
    // Now we draw the underlying CGImage into a new context, applying the transform
    // calculated above.
    CGContextRef ctx = CGBitmapContextCreate(NULL, image.size.width, image.size.height,
                                             CGImageGetBitsPerComponent(image.CGImage), 0,
                                             CGImageGetColorSpace(image.CGImage),
                                             CGImageGetBitmapInfo(image.CGImage));
    CGContextConcatCTM(ctx, transform);
    switch (orientation) {
        case UIImageOrientationLeft:
        case UIImageOrientationLeftMirrored:
        case UIImageOrientationRight:
        case UIImageOrientationRightMirrored:
            // Grr...
            CGContextDrawImage(ctx, CGRectMake(0,0,image.size.height,image.size.width), image.CGImage);
            break;
            
        default:
            CGContextDrawImage(ctx, CGRectMake(0,0,image.size.width,image.size.height), image.CGImage);
            break;
    }
    
    // And now we just create a new UIImage from the drawing context
    CGImageRef cgimg = CGBitmapContextCreateImage(ctx);
    UIImage *img = [UIImage imageWithCGImage:cgimg];
    CGContextRelease(ctx);
    CGImageRelease(cgimg);
    return img;
}



@end
