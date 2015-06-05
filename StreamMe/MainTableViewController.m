//
//  MainTableViewController.m
//  StreamMe
//
//  Created by Chase Midler on 9/3/14.
//  Copyright (c) 2014 midler. All rights reserved.
//

#import "MainTableViewController.h"

@interface MainTableViewController ()

@end

@implementation MainTableViewController
@synthesize streamsTableView;
@synthesize customPicker;
@synthesize toolBar;
@synthesize caption;
@synthesize cameraOverlayView;
@synthesize flashButton;
@synthesize pickerView;
@synthesize timeLabel;
@synthesize activityIndicator;
@synthesize activityView;
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
    __block PFUser* user = [PFUser currentUser];
    NSNumber* userSort = [user objectForKey:@"sort"];
    if(userSort)
        _sortBy = userSort.intValue;
    else
        _sortBy = 0;
    
    user[@"sort"] = [NSNumber numberWithInt:_sortBy];
    [user saveInBackground];
    [user fetchIfNeededInBackground];
    
    
    [self setNavigationTitle];
    
    
    //setting up dropdown
    REMenuItem *newestItem = [[REMenuItem alloc] initWithTitle:@"Newest"
                                                      subtitle:@"Sort by the newest streams nearby"
                                                         image:nil
                                              highlightedImage:nil
                                                        action:^(REMenuItem *item) {
                                                            bool oldSort = _sortBy;
                                                            _sortBy = 2;
                                                            _showingAnywhere = NO;
                                                            [self setNavigationTitle];
                                                            if(oldSort != _sortBy)
                                                            {
                                                                user[@"sort"] = [NSNumber numberWithInt:_sortBy];
                                                                [user saveInBackground];
                                                                [user fetchIfNeededInBackground];
                                                                [self sortStreams];
                                                            }
                                                            _menuOpened = NO;
                                                        }];
    
    REMenuItem *popularNearbyItem = [[REMenuItem alloc] initWithTitle:@"Popular"
                                                     subtitle:@"Sort by the streams with the most content nearby"
                                                        image:nil
                                             highlightedImage:nil
                                                       action:^(REMenuItem *item) {
                                                           bool oldSort = _sortBy;
                                                           _sortBy = 1;
                                                           _showingAnywhere = NO;
                                                           [self setNavigationTitle];
                                                           if(oldSort != _sortBy)
                                                           {
                                                               user[@"sort"] = [NSNumber numberWithInt:_sortBy];
                                                               [user saveInBackground];
                                                               [user fetchIfNeededInBackground];
                                                               [self sortStreams];
                                                           }
                                                           _menuOpened = NO;
                                                           
                                                       }];
    REMenuItem *nearbyItem = [[REMenuItem alloc] initWithTitle:@"Closest"
                                                             subtitle:@"Sort by the streams that are closest to you"
                                                                image:nil
                                                     highlightedImage:nil
                                                               action:^(REMenuItem *item) {
                                                                   bool oldSort = _sortBy;
                                                                   _sortBy = 0;
                                                                   _showingAnywhere = NO;
                                                                   [self setNavigationTitle];
                                                                   if(oldSort != _sortBy)
                                                                   {
                                                                       user[@"sort"] = [NSNumber numberWithInt:_sortBy];
                                                                       [user saveInBackground];
                                                                       [user fetchIfNeededInBackground];
                                                                       [self sortStreams];
                                                                   }
                                                                   _menuOpened = NO;
                                                                   
                                                               }];
    _menu = [[REMenu alloc] initWithItems:@[nearbyItem,popularNearbyItem,newestItem]];
    [_menu setTextColor:[UIColor whiteColor]];
    [_menu setBackgroundColor:[UIColor blackColor]];
    _locationManager = [[CLLocationManager alloc] init];
    _currentLocation = nil;
    AppDelegate *appDelegate = [[UIApplication sharedApplication] delegate];
    _central = [appDelegate central];
    _finishedDownload = YES;
    //streams = [[NSMutableArray alloc]init];
    _queue= dispatch_queue_create("user_queue", DISPATCH_QUEUE_SERIAL);
    _totalValidStreams = 0;
    _currentPage = _totalPages = 1;
    _refreshingStreams = NO;
    _gettingLocation = NO;
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
    [[NSNotificationCenter defaultCenter] addObserver:self
                                             selector:@selector(mainNotification:)
                                                 name:@"reloadSection"
                                               object:nil];
    [[NSNotificationCenter defaultCenter] addObserver:self
                                             selector:@selector(mainNotification:)
                                                 name:@"refreshStreams"
                                               object:nil];
    [[NSNotificationCenter defaultCenter] addObserver:self
                                             selector:@selector(mainNotification:)
                                                 name:@"dismissCameraPopover"
                                               object:nil];
    [[NSNotificationCenter defaultCenter] addObserver:self
                                             selector:@selector(mainNotification:)
                                                 name:@"updatedLocation"
                                               object:nil];
    [[NSNotificationCenter defaultCenter] addObserver:self
                                             selector:@selector(mainNotification:)
                                                 name:@"updatedLocationForCreation"
                                               object:nil];
    //authorization check
    if([CLLocationManager authorizationStatus] == kCLAuthorizationStatusNotDetermined)
    {
        //NSLog(@"authorization status is not determined");
        _locationManager.delegate = self;
        [_locationManager requestWhenInUseAuthorization];
        
    }
    else
    {
        NSLog(@"authorization status is %d", [CLLocationManager authorizationStatus]);
    
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
    //[self checkCreateStreamInfo];
}

-(void) mainTutorial
{
    
    //don't want to give a popup when we aren't on the page
    if(_imagePickerOpen)
        return;
    
    //if we have already done the streams of content then return
    /*NSNumber *showStreamOfContentTutorial =
    [[NSUserDefaults standardUserDefaults] objectForKey:@"ShowStreamOfContentTutorial"];
    if(showStreamOfContentTutorial)
        return;*/
    
    //see if we have to do the popover right now
    NSNumber *showedAddStreamMainTutorial =
    [[NSUserDefaults standardUserDefaults] objectForKey:@"ShowedAddStreamMainTutorial"];
    if (showedAddStreamMainTutorial )//&& (!showStreamsArray || !showStreamsArray.count))
        return;
    
    //ok we have to show tutorials
    
    //show add stream tutorial
    if(!showedAddStreamMainTutorial)
    {
        PopoverViewController* pvc = [self.storyboard instantiateViewControllerWithIdentifier:@"PopoverViewController"];
        [pvc setModalPresentationStyle:UIModalPresentationPopover];
        pvc.preferredContentSize = CGSizeMake(280, 80);
        
        NSLog(@"pvc height is %f", pvc.view.frame.size.height);
        UIPopoverPresentationController* popoverController = pvc.popoverPresentationController;
        [caption setHidden:YES];
        popoverController.barButtonItem = self.navigationItem.rightBarButtonItem;
        NSLog(@"popover controller = %@", popoverController);
        
        //NSLog(@"bar button view is %@", barButtonView);
        popoverController.sourceView = [self.navigationItem.rightBarButtonItem valueForKey:@"view"];
        popoverController.sourceRect = CGRectMake(0,0,280,80);
        popoverController.permittedArrowDirections = UIPopoverArrowDirectionUp;
        popoverController.delegate = self;
        [self presentViewController:pvc animated:YES completion:nil];
        pvc.popoverLabel.text = @"Add your own stream of photos here.";
        pvc.popoverLabel.textAlignment = NSTextAlignmentCenter;
        pvc.popoverLabel.numberOfLines = 0;
        NSUserDefaults *defaults = [NSUserDefaults standardUserDefaults];
        [defaults setObject:@"YES" forKey:@"ShowedAddStreamMainTutorial"];
        [defaults synchronize];
        _popoverOpen = 1;
    }
    
    //show stream content tutorial
    /*if(!showStreamOfContentTutorial && showStreamsArray && showStreamsArray.count && !_popoverOpen)
    {
        NSLog(@"inside of main tutorial for stream");
        if(!_currentPopover)
        {
            NSLog(@"current popover is %@", _currentPopover);
            _currentPopover = @"addStream";
            _popoverOpen = YES;
            PopoverViewController* pvc = [self.storyboard instantiateViewControllerWithIdentifier:@"PopoverViewController"];
            [pvc setModalPresentationStyle:UIModalPresentationPopover];
            pvc.preferredContentSize = CGSizeMake(280, 80);
            
            UIPopoverPresentationController* popoverController = pvc.popoverPresentationController;
            [caption setHidden:YES];
            
            //NSLog(@"bar button view is %@", barButtonView);
            NSIndexPath* tableViewPath = [NSIndexPath indexPathForRow:0 inSection:0];
            MainTableViewCell *cell = (MainTableViewCell*)[streamsTableView cellForRowAtIndexPath:tableViewPath];
            //make sure the cell is there
            if(!cell)
            {
                NSLog(@"cell is nil");
                return;
            }
            
            UIView* sourceView;
            for(UIView* view in cell.subviews)
            {
                if(view.tag == TUTORIAL_VIEW_TAG)
                {
                    sourceView = view;
                    break;
                }
            }
            
            if(!sourceView)
            {
                NSLog(@"sourceview is nil");
                return;
            }
            
            popoverController.sourceView = sourceView;
            popoverController.sourceRect = CGRectMake(0,0,280,80);
            popoverController.permittedArrowDirections = UIPopoverArrowDirectionUp;
            popoverController.delegate = self;
            [self presentViewController:pvc animated:YES completion:nil];
            pvc.popoverLabel.text = @"Click the picture to see all of the photos in the stream.";
            pvc.popoverLabel.textAlignment = NSTextAlignmentCenter;
            pvc.popoverLabel.numberOfLines = 0;
            
        }
        else if([_currentPopover isEqualToString:@"addStream"] && !_popoverOpen)
        {
            _currentPopover = @"addPhoto";
            _popoverOpen = YES;
            PopoverViewController* pvc = [self.storyboard instantiateViewControllerWithIdentifier:@"PopoverViewController"];
            [pvc setModalPresentationStyle:UIModalPresentationPopover];
            pvc.preferredContentSize = CGSizeMake(280, 80);
            
            NSLog(@"pvc height is %f", pvc.view.frame.size.height);
            UIPopoverPresentationController* popoverController = pvc.popoverPresentationController;
            [caption setHidden:YES];
            NSLog(@"popover controller = %@", popoverController);
            
            //NSLog(@"bar button view is %@", barButtonView);
            //now need to find the headerview
            if(!_firstHeaderView)
            {
                NSLog(@"bad first header");
                return;
            }
            UIView* sourceView = _firstHeaderView.subviews[4];
            if(!sourceView)
            {
                NSLog(@"sourceview is null %@", sourceView);
                return;
            }
            sourceView.backgroundColor = [UIColor grayColor];
            popoverController.sourceView = sourceView;
            popoverController.sourceRect = CGRectMake(0,0,280,80);
            popoverController.permittedArrowDirections = UIPopoverArrowDirectionDown;
            popoverController.delegate = self;
            [self presentViewController:pvc animated:YES completion:nil];
            pvc.popoverLabel.text = @"Click the add content button to contribute your own vision to the existing stream!";
            pvc.popoverLabel.textAlignment = NSTextAlignmentCenter;
            pvc.popoverLabel.numberOfLines = 0;
            
        }
        else if(!_popoverOpen)
        {
            NSLog(@"current popover is in else %@", _currentPopover);
            UIView* sourceView = _firstHeaderView.subviews[4];
            if(!sourceView)
            {
                NSLog(@"sourceview is null %@", sourceView);
                return;
            }
            sourceView.backgroundColor = [UIColor clearColor];
            _currentPopover = nil;
            _popoverOpen = NO;
            NSUserDefaults *defaults = [NSUserDefaults standardUserDefaults];
            [defaults setObject:@"YES" forKey:@"ShowStreamOfContentTutorial"];
            [defaults synchronize];
            
        }
    }*/
    
}

-(void) setNavigationTitle
{
    //creating container to hold the button
    UIView * container = [[UIView alloc]initWithFrame:CGRectMake(0, 0, 176, 22)];
    UIButton * menuButton = [[UIButton alloc]initWithFrame:CGRectMake(0, 0, 176, 22)];
    [menuButton addTarget:self action:@selector(menuSelected:) forControlEvents:UIControlEventTouchUpInside];
    //setting the title
    if(!_sortBy)
        [menuButton setTitle:@"Closest" forState:UIControlStateNormal];
    else if(_sortBy==1)
        [menuButton setTitle:@"Popular" forState:UIControlStateNormal];
    else if(_sortBy == 2)
        [menuButton setTitle:@"Newest" forState:UIControlStateNormal];
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
        //if no bluetooth then just present the alert
        if(!_central.bluetoothOn)
        {
            [self presentNoBluetoothAlert];
            return;
        }
        
        AVAuthorizationStatus status = [AVCaptureDevice authorizationStatusForMediaType:AVMediaTypeVideo];
        //camera permission is denied
        if(status == AVAuthorizationStatusDenied){ // denied
            [self presentNoCameraAlert];
            return;
        }
        // Explicit user permission is required for media capture, but the user has not yet granted or denied such permission.
        else if(status == AVAuthorizationStatusNotDetermined){
            __block bool allowed = NO;
            __block bool checkingPermissions = YES;
            [AVCaptureDevice requestAccessForMediaType:AVMediaTypeVideo completionHandler:^(BOOL granted){
                NSLog(@"granted is %d", granted);
                allowed = granted;
                checkingPermissions = NO;
            }];
            
            while(checkingPermissions)
                ;
            if(!allowed)
                return;
            
        }


        
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

//helper to not let the user do stuff if bluetooth is turned off
-(void) presentNoBluetoothAlert
{
    UIAlertController *alertController = [UIAlertController
                                          alertControllerWithTitle:@"Bluetooth Turned Off"
                                          message:@"Bluetooth Is Turned Off. Please Go To Settings->Bluetooth and Make Sure Bluetooth Is Turned On!"
                                          preferredStyle:UIAlertControllerStyleAlert];
    UIAlertAction *okAction = [UIAlertAction
                               actionWithTitle:NSLocalizedString(@"Ok", @"Ok action")
                               style:UIAlertActionStyleDefault
                               handler:^(UIAlertAction *action)
                               {
                                   [self mainTutorial];
                                   return;
                               }];
    /*UIAlertAction *settingsAction = [UIAlertAction
                                     actionWithTitle:NSLocalizedString(@"Settings", @"Settings action")
                                     style:UIAlertActionStyleDefault
                                     handler:^(UIAlertAction *action)
                                     {
                                         NSString* settingString = @"settings:";
                                         NSLog(@"Settings String is %@", settingString);
                                         if (UIApplicationOpenSettingsURLString != NULL) {
                                             [[UIApplication sharedApplication] openURL:[NSURL URLWithString:settingString]];
                                         }
                                         return;
                                     }];
    [alertController addAction:settingsAction];*/
    [alertController addAction:okAction];
    
    [self presentViewController:alertController animated:YES completion:nil];
    return;

}

- (void)getCurrentLocation{
    NSLog(@"getting current location");
    _timerGPS =[NSTimer scheduledTimerWithTimeInterval:GPS_TIME target:self selector:@selector(timerGPSFired) userInfo:nil repeats:NO];
    
    _gettingLocation = YES;
    _locationManager.delegate = self;
    [_locationManager requestWhenInUseAuthorization];
    _locationManager.desiredAccuracy = kCLLocationAccuracyBest;
    NSLog(@"location manager is %@", _locationManager);
    [_locationManager startUpdatingLocation];
    
}

-(void) timerGPSFired
{
    NSLog(@"timer gps fired");
    if(_refreshingStreams)
        [[NSNotificationCenter defaultCenter] postNotificationName:@"updatedLocation" object:self];
    else
        [[NSNotificationCenter defaultCenter] postNotificationName:@"updatedLocationForCreation" object:self];
    _refreshingStreams = NO;
    [_timerGPS invalidate];
}

/*-(void) timeoutTimerFired
{
    NSLog(@"timer publish fired");
    [_timeoutTimer invalidate];
    NSLog(@"error saving share");
    UIAlertController *alertController = [UIAlertController
                                          alertControllerWithTitle:@"Timeout Occurred"
                                          message:@"Your connection timed out.  Check your internet connection and try again."
                                          preferredStyle:UIAlertControllerStyleAlert];
    UIAlertAction *okAction = [UIAlertAction
                               actionWithTitle:NSLocalizedString(@"Ok", @"Ok action")
                               style:UIAlertActionStyleDefault
                               handler:^(UIAlertAction *action)
                               {
                                   [activityView setHidden:YES];
                                   [activityIndicator setHidden:YES];
                                   [toolBar setHidden:NO];
                                   [caption setHidden:NO];
                                   return;
                               }];
    
    [alertController addAction:okAction];
    [customPicker presentViewController:alertController animated:YES completion:nil];
    return;
    
}*/

-(void) presentNoCameraAlert
{
    UIAlertController *alertController = [UIAlertController
                                          alertControllerWithTitle:@"Camera Not Allowed!"
                                          message:@"Camera Permission Is Not Allowed. Turn On The Camera Permission For This App Through The Settings To Use The Camera."
                                          preferredStyle:UIAlertControllerStyleAlert];
    UIAlertAction *okAction = [UIAlertAction
                               actionWithTitle:NSLocalizedString(@"Ok", @"Ok action")
                               style:UIAlertActionStyleDefault
                               handler:^(UIAlertAction *action)
                               {
                                   return;
                               }];
    UIAlertAction *settingsAction = [UIAlertAction
                                     actionWithTitle:NSLocalizedString(@"Settings", @"Settings action")
                                     style:UIAlertActionStyleDefault
                                     handler:^(UIAlertAction *action)
                                     {
                                         if (UIApplicationOpenSettingsURLString != NULL) {
                                             [[UIApplication sharedApplication] openURL:[NSURL URLWithString:UIApplicationOpenSettingsURLString]];
                                         }
                                         return;
                                     }];
    
    [alertController addAction:settingsAction];
    [alertController addAction:okAction];
    
    [self presentViewController:alertController animated:YES completion:nil];

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
        NSLog(@"count timer fired");
        [self countStreamShares:streamIds];
    }
    else if ([[notification name] isEqualToString:@"newUserStreams"])
    {
        //get the total amount of streams
        [PFCloud callFunctionInBackground:@"countUserStreams" withParameters:@{} block:^(id object, NSError *error) {
            if(error)
            {
                NSLog(@"error in counting streams");
                return;
            }
            else
            {
                int number = ((NSNumber*)object).intValue;
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
        NSLog(@"count streams fired");
        NSDictionary* userInfo = [notification userInfo];
        [self countStreamShares:[userInfo objectForKey:@"streamIds"]];
    }
    else if ([[notification name] isEqualToString:@"reloadSection"])
    {
        NSLog(@"reload section called");
        [self sortStreams];
    }
    else if([[notification name] isEqualToString:@"refreshStreams"])
    {
        NSLog(@"reload section called");
        [self pullToRefresh];
    }

    
    else if ([[notification name] isEqualToString:@"dismissCameraPopover"])
        [self popoverDismissed];
    else if ([[notification name] isEqualToString:@"updatedLocation"])
    {
        NSLog(@"updated location being called");
        [self getStreams];
    }
    else if ([[notification name] isEqualToString:@"updatedLocationForCreation"])
    {
        [self publishNew];
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
    
    [PFCloud callFunctionInBackground:@"countUserStreams" withParameters:@{} block:^(id object, NSError *error) {
        if(error)
        {
            NSLog(@"error in counting streams");
           return;
        }
        else
        {
            int number = ((NSNumber*)object).intValue;
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
    
    //first get the location
    _refreshingStreams = YES;
    [self getCurrentLocation];
    
}

-(void) getStreams{
    
    NSLog(@"get streams called");
    
    AppDelegate* appDelegate = [[UIApplication sharedApplication] delegate];
    NSMutableArray* streams = [appDelegate streams];
    
    NSMutableArray* streamIds = [[NSMutableArray alloc] init];
    for(Stream* stream in streams)
        [streamIds addObject:stream.stream.objectId];
    
    NSDictionary* parameters;
    NSDictionary* gpsParameters;
    PFGeoPoint* currentLocation= nil;
    if(_currentLocation)
        currentLocation = [PFGeoPoint geoPointWithLocation:_currentLocation];
    
    if(currentLocation)
    {
        parameters = @{@"currentStreamsIds":streamIds, @"limit":[NSNumber numberWithInt:STREAMS_PER_PAGE], @"currentLocation":currentLocation};
        gpsParameters = @{@"currentLocation":currentLocation};
    }
    else
    {
        parameters = @{@"currentStreamsIds":streamIds, @"limit":[NSNumber numberWithInt:STREAMS_PER_PAGE]};
        gpsParameters = @{};
    }
    
    
    [PFCloud callFunctionInBackground:@"findStreamsByGPS" withParameters:gpsParameters block:^(id object, NSError *error) {
        //error
        if(error)
        {
            NSLog(@"error for find streams by gps is %@", error);
        }
    
        [PFCloud callFunctionInBackground:@"getStreamsForUser" withParameters:parameters block:^(id object, NSError *error) {
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
            //NSLog(@"new streams = %@", newStreams);
            
            //get array of all of the stream objects we have
            NSMutableArray* streamObjects = [[NSMutableArray alloc] init];
            
            //have array of streams in streams array
            for(Stream* s in streams)
                [streamObjects addObject:s.stream.objectId];
            //see if the array already contains it before we add it
            for(NSDictionary* dict in newStreams)
            {
                PFObject* stream = [dict objectForKey:@"stream"];
                PFObject* share = [dict objectForKey:@"share"];
                PFObject* streamShare = [dict objectForKey:@"stream_share"];
                streamShare[@"share"] = share;
                NSString* username = [dict objectForKey:@"username"];
                bool gotByBluetooth = ((NSNumber*)[dict objectForKey:@"gotByBluetooth"]).boolValue;

                //add id to the streamids array
                [streamIds addObject:stream.objectId];
                
                //if the stream isn't in the array then add it
                if(![streamObjects containsObject:stream.objectId])
                {
                    NSLog(@"new stream object id is %@", stream.objectId);
                    //initialize a new stream
                    Stream* newStream = [[Stream alloc] init];
                    newStream.stream = stream;
                    
                    //want to create an array of shares so we can lazy load the next ones
                    [newStream.streamShares addObject:streamShare];
                    //add the username
                    newStream.username = username;
                    //newest time of streamShare
                    newStream.newestShareCreationTime = streamShare.createdAt;
                    newStream.gotByBluetooth = gotByBluetooth;
                    
                    NSLog(@"got by bluetooth is %d", newStream.gotByBluetooth);
                    //add the new stream object to the streams array
                    [streams addObject:newStream];
                    //get first share
                    /*NSString* firstShareId = ((PFObject*)[stream objectForKey:@"firstShare"]).objectId;
                    if([firstShareId isEqualToString:share.objectId])
                        [self loadSharesRight:stream limitOf:SHARES_PER_PAGE];
                    else
                        [self loadSharesCenter:stream];*/
                    [streamObjects addObject:stream.objectId];
                }
            }
            _tableFirstLoad = NO;
            _downloadingStreams = NO;
            [self countStreamShares:streamIds];
        }];
    }];
}

//lazy load shares right
/*-(void) loadSharesRight:(PFObject*) stream limitOf:(int)limit
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
        //dispatch_async(dispatch_get_main_queue(), ^{
            [self sortStreams];
        //});
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
        //dispatch_async(dispatch_get_main_queue(), ^{
            //reload section
            [self sortStreams];
        //});
        //[streamsTableView reloadSections:[NSIndexSet indexSetWithIndex:0] withRowAnimation:UITableViewRowAnimationNone];
    }];
}*/

-(void) sortStreams
{
    NSLog(@"sort streams called");
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
    if(!_sortBy)
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
            
            //sort on bluetooth first
            if(obj1.gotByBluetooth && !obj2.gotByBluetooth)
                return (NSComparisonResult)NSOrderedAscending;
            else if (!obj1.gotByBluetooth && obj2.gotByBluetooth)
                return (NSComparisonResult)NSOrderedDescending;
            
            //they have the same bluetooth value.  check for geo now
            if(_currentLocation)
            {
                PFGeoPoint* geo1 = ((PFGeoPoint*)[stream1 objectForKey:@"location"]);
                PFGeoPoint* geo2 = ((PFGeoPoint*)[stream2 objectForKey:@"location"]);
                
                if((geo1.latitude || geo1.longitude) && (!geo2.latitude && !geo2.longitude))//1 has location and 2 doesn't
                    return (NSComparisonResult)NSOrderedAscending;
                else if ((!geo1.latitude && !geo1.longitude) && (geo2.latitude || geo2.longitude))//1 does not have location and 2 does
                    return (NSComparisonResult)NSOrderedDescending;
                else if (geo1.longitude || geo1.latitude) //both of a location
                {
                    CLLocation* loc1 = [[CLLocation alloc] initWithLatitude:geo1.latitude longitude:geo1.longitude];
                    CLLocation* loc2 = [[CLLocation alloc] initWithLatitude:geo2.latitude longitude:geo2.longitude];
                    
                    //need to get the distance from the current location
                    CLLocationDistance distanceInMeters1 = [_currentLocation distanceFromLocation:loc1];
                    CLLocationDistance distanceInMeters2 = [_currentLocation distanceFromLocation:loc2];
                    
                    if(distanceInMeters1<distanceInMeters2)
                        return (NSComparisonResult)NSOrderedAscending;//1 is closer
                    else if(distanceInMeters1>distanceInMeters2)
                        return (NSComparisonResult)NSOrderedDescending;//2 is closer
                }
            }

            //either the distance can't be figured out or they are the same distance apart
            
            //sort by popular
            if(obj1.totalShares > obj2.totalShares)
                return (NSComparisonResult)NSOrderedAscending;
            else if(obj1.totalShares < obj2.totalShares)
                return (NSComparisonResult)NSOrderedDescending;
            
            //sort by newest
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
            
            //sort on bluetooth first
            if(obj1.gotByBluetooth && !obj2.gotByBluetooth)
                return (NSComparisonResult)NSOrderedAscending;
            else if (!obj1.gotByBluetooth && obj2.gotByBluetooth)
                return (NSComparisonResult)NSOrderedDescending;
            
            //they have the same bluetooth value.  check for geo now
            if(_currentLocation)
            {
                PFGeoPoint* geo1 = ((PFGeoPoint*)[stream1 objectForKey:@"location"]);
                PFGeoPoint* geo2 = ((PFGeoPoint*)[stream2 objectForKey:@"location"]);
                
                if((geo1.latitude || geo1.longitude) && (!geo2.latitude && !geo2.longitude))//1 has location and 2 doesn't
                    return (NSComparisonResult)NSOrderedAscending;
                else if ((!geo1.latitude && !geo1.longitude) && (geo2.latitude || geo2.longitude))//1 does not have location and 2 does
                    return (NSComparisonResult)NSOrderedDescending;
                else if (geo1.longitude || geo1.latitude) //both of a location
                {
                    CLLocation* loc1 = [[CLLocation alloc] initWithLatitude:geo1.latitude longitude:geo1.longitude];
                    CLLocation* loc2 = [[CLLocation alloc] initWithLatitude:geo2.latitude longitude:geo2.longitude];
                    
                    //need to get the distance from the current location
                    CLLocationDistance distanceInMeters1 = [_currentLocation distanceFromLocation:loc1];
                    CLLocationDistance distanceInMeters2 = [_currentLocation distanceFromLocation:loc2];
                    
                    if(distanceInMeters1<distanceInMeters2)
                        return (NSComparisonResult)NSOrderedAscending;//1 is closer
                    else if(distanceInMeters1>distanceInMeters2)
                        return (NSComparisonResult)NSOrderedDescending;//2 is closer
                }
            }

            
            
            
            return [stream2.createdAt compare:stream1.createdAt];
            
        }];
    }
    //Sort by newest
    else if(_sortBy == 2)
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
    //if no stream ids then return
    if(!streamIds.count)
    {
        //dispatch_async(dispatch_get_main_queue(), ^{
            [self sortStreams];
        //});
    }
    //NSLog(@"countStreamShares:()");
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
            
            //NSLog(@"in count shares for streams");
            //find the correct stream and update the last value in the array
            for(Stream* s in streams)
            {
                //NSLog(@"getting count for stream %@", [s.stream objectForKey:@"name"]);
                //found the match
                if([s.stream.objectId isEqualToString:streamId])
                {
                    //get total shares and total
                    NSNumber* totalShares = object[0];
                    
                    PFObject* streamShare = object[1];
                    //NSInteger previousShareTotal = s.totalShares;
                    //update the total shares in the array
                    s.totalShares = totalShares.integerValue;
                    s.newestShareCreationTime = streamShare.createdAt;
                    
                    //send notification that the total shares are updated
                    [[NSNotificationCenter defaultCenter] postNotificationName:@"streamCountDone" object:self userInfo:nil];
                    
                    //NSLog(@"new total shares count is %d", (int)s.totalShares);
                    //see if we got more shares
                    /*if(totalShares.integerValue > previousShareTotal)
                    {
                        //get the number of shares until the next page
                        int numberOfSharesUntilNextPage = SHARES_PER_PAGE - previousShareTotal%SHARES_PER_PAGE;
                        
                        @synchronized(self)
                        {
                            //if downloading then return
                            if(s.isDownloadingAfter)
                            {
                                NSLog(@"downloading after so break");
                                break;
                            }
                        
                            //if number of shares until next page is not shares per page then update
                            if(numberOfSharesUntilNextPage != SHARES_PER_PAGE)
                            {
                                //getting more shares
                                [self loadSharesRight:s.stream limitOf:numberOfSharesUntilNextPage];
                            }
                        }
                    }*/
                    break;
                }
            }
            i++;
            
            //when looped through all count results go ahead and update
            if(i == streamIds.count)
            {
                NSLog(@"i is at stream count and will sort streams");
                //dispatch_async(dispatch_get_main_queue(), ^{
                    [self sortStreams];
                //});
            }
        }];
        
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
    _selectedCellIndex = -(int)gesture.view.tag;
    _creatingStream = NO;
    _openedWithShake = NO;
    _selectedStream = ((Stream*)showStreamsArray[_selectedCellIndex]).stream;
    AVAuthorizationStatus status = [AVCaptureDevice authorizationStatusForMediaType:AVMediaTypeVideo];
    //camera permission is denied
    if(status == AVAuthorizationStatusDenied){ // denied
        [self presentNoCameraAlert];
        return;
    }
    // Explicit user permission is required for media capture, but the user has not yet granted or denied such permission.
    else if(status == AVAuthorizationStatusNotDetermined){
        __block bool allowed = NO;
        __block bool checkingPermissions = YES;
        [AVCaptureDevice requestAccessForMediaType:AVMediaTypeVideo completionHandler:^(BOOL granted){
            NSLog(@"granted is %d", granted);
            allowed = granted;
            checkingPermissions = NO;
            
        }];
        
        while(checkingPermissions)
            ;
        if(!allowed)
            return;
        
    }

    [self takePhoto];
}

-(void) viewWillAppear:(BOOL)animated
{
    [super viewWillAppear:animated];
    //if no bluetooth then just present the alert
    if(!_central.bluetoothOn)
    {
        [self presentNoBluetoothAlert];
        return;
    }
    else
    {
        [self mainTutorial];
    }
    _menuOpened = NO;
    NSLog(@"current row is %d", (int)_selectedCellIndex);
    //scroll to right position
    /*if(_isPoppingBack)
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
    [self sortStreams];*/
}


- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}


- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView
{
    
    //if bluetooth is turned off, hide everything
    if(!_central.bluetoothOn)
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
        messageLabel.text = @"Your bluetooth is turned off!  Go to Settings->Bluetooth and make sure bluetooth is enabled to get the full functionality of this application! ";
        
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
    //the number of streams
    else if([showStreamsArray count])
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
    //NSLog(@"in number of rows with count = %d", (int) showStreamsArray.count);
    
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

//Show data in cells
- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath
{
    NSLog(@"cell for row at index path called");
    static NSString *CellIdentifier = @"mainCell";
    MainTableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:CellIdentifier forIndexPath:indexPath];
    cell.separatorInset = UIEdgeInsetsZero;
    cell.activityIndicator.hidden = YES;
    [cell.activityIndicator stopAnimating];
    [cell setUserInteractionEnabled:NO];
    [cell.shareImageView setUserInteractionEnabled:NO];
    //[cell setUserInteractionEnabled:NO];
    //cell.streamCollectionView.hidden = YES;
    //cell.streamCollectionView.tag = indexPath.section;
    
    //loop through subviews and if pfimage is there remove it
    for(UIView* view in cell.subviews)
    {
        //remove imageview
        //remove old headerview
        if(view.tag == HEADER_TAG)
        {
            NSLog(@"removing tag");
            [view removeFromSuperview];
        }
    }
    
    //now check if we are using the profile cell or pagination
    if(indexPath.section < showStreamsArray.count && !indexPath.row)
    {
        
        //get the stream
        Stream* s = showStreamsArray[indexPath.section];
        
        
        float width = tableView.frame.size.width;
        float halfHeight = HEADER_HEIGHT/2.0;
        float quarterHeight = HEADER_HEIGHT/4.0;
        float threeQuarterHeight = HEADER_HEIGHT*3.0/4.0;
        
        //create the view to hold all of the other views
        PassthroughView *headerView = [[PassthroughView alloc] initWithFrame:CGRectMake(0, cell.frame.size.height-HEADER_HEIGHT, tableView.frame.size.width, HEADER_HEIGHT)];
        headerView.tag = HEADER_TAG;
        headerView.backgroundColor = [[UIColor blackColor] colorWithAlphaComponent:0.2];
        if(!indexPath.section)
            _firstHeaderView = headerView;
        
        //create the title with the name of the stream
        UILabel *title = [[UILabel alloc] initWithFrame:CGRectMake(5, 5, width-threeQuarterHeight, halfHeight)];
        title.font = [UIFont boldSystemFontOfSize:17.0];
        title.textColor = [UIColor whiteColor];
        title.text = [NSString stringWithFormat:@"#%@",[s.stream objectForKey:@"name"] ];
        title.textAlignment = NSTextAlignmentLeft;
        title.numberOfLines = 1;
        title.minimumScaleFactor = 8./title.font.pointSize;
        title.adjustsFontSizeToFitWidth = YES;
        
        
        //set when it expires
        UILabel *expiration = [[UILabel alloc] initWithFrame:CGRectMake(5, threeQuarterHeight, width-10, quarterHeight)];
        expiration.font = [UIFont boldSystemFontOfSize:10.0];
        expiration.numberOfLines = 1;
        //get time left label
        NSDate* endTime = [s.stream objectForKey:@"endTime"];
        NSString* timeLeft;
        NSTimeInterval interval = [endTime timeIntervalSinceDate:[NSDate date]];
        expiration.textColor = [UIColor whiteColor];
        //stream if over
        if(isnan(interval) || interval<=0)
        {
            timeLeft = @"Stream Expired";
            [expiration setTextColor:[UIColor redColor]];
            [headerView setUserInteractionEnabled:NO];
        }
        else
        {
            interval = interval/60;//let's get minutes accuracy
            if(interval > 720)
                timeLeft = @"Never Expires!";
            //if more 30 minutes left then say less than the rounded up hour
            else if(interval>30)
                timeLeft = [NSString stringWithFormat:@"Expires: < %dh",(int) ceil(interval/60)];
            else
                timeLeft = [NSString stringWithFormat:@"Expires: < %dm",(int) ceil(interval)];
        }
        expiration.text = timeLeft;
        //add image for pictures
        UIImageView* pictureImageView = [[UIImageView alloc] initWithFrame:CGRectMake(2.5, halfHeight+2.5, quarterHeight, quarterHeight)];
        pictureImageView.image = [UIImage imageNamed:@"white_pictures.png"];
        
        //add number of pictures
        UILabel *contributions = [[UILabel alloc] initWithFrame:CGRectMake(pictureImageView.frame.origin.x + pictureImageView.frame.size.width+5, halfHeight+2.5, width/2, quarterHeight)];
        contributions.font = [UIFont boldSystemFontOfSize:10.0];
        contributions.numberOfLines = 1;
        contributions.text = [NSString stringWithFormat:@"%d",(int)s.totalShares];
        contributions.textColor = [UIColor whiteColor];
        
        //add distance label
        UILabel* distance = [[UILabel alloc] initWithFrame:CGRectMake(0, threeQuarterHeight, width-threeQuarterHeight-10, quarterHeight)];
        distance.font = [UIFont boldSystemFontOfSize:10.0];
        distance.numberOfLines = 1;
        distance.textColor = [UIColor whiteColor];
        distance.textAlignment = NSTextAlignmentRight;
        PFGeoPoint* geo = ((PFGeoPoint*)[s.stream objectForKey:@"location"]);
        NSLog(@"geo latitude is %f and long %f", geo.latitude, geo.latitude);
        //figure out the distance from current location
        if(s.gotByBluetooth)
            distance.text = @"Right Here!";
        else if((!_currentLocation && !s.gotByBluetooth) || !geo ||  (!geo.latitude && !geo.longitude))
            distance.text = @"Distance Unknown";
        else
        {
            CLLocation* streamDistance = [[CLLocation alloc] initWithLatitude:geo.latitude longitude:geo.longitude];
            
            CLLocationDistance distanceInMeters = [_currentLocation distanceFromLocation:streamDistance];
            NSLog(@"distance in meters is %f", distanceInMeters);
            
            int miles = floor(distanceInMeters*0.000621371192);//meters to miles conversion
            if(!miles)
                distance.text = @"< 1 Mile Away";
            else if (miles ==1)
                distance.text = @"1 Mile Away";
            else
                distance.text = [NSString stringWithFormat:@"%d Miles Away", miles];
        }
        
        //image view to help
        UIImageView* addSharesImageView = [[UIImageView alloc] initWithFrame:CGRectMake(width-threeQuarterHeight-2.5, quarterHeight/2+2.5,threeQuarterHeight-5, threeQuarterHeight-5)];
        addSharesImageView.image = [UIImage imageNamed:@"thick_plus_circle.png"];
        addSharesImageView.tag = -indexPath.section;
        UITapGestureRecognizer *headerTap =  [[UITapGestureRecognizer alloc] initWithTarget:self action:@selector(headerTapDetected:)];
        headerTap.numberOfTapsRequired = 1;
        [addSharesImageView setUserInteractionEnabled:YES];
        [addSharesImageView addGestureRecognizer:headerTap];
        
        //add a line going underneath the title
        UIView *lineView = [[UIView alloc] initWithFrame:CGRectMake(0, halfHeight, width-threeQuarterHeight-10, 1)];
        lineView.backgroundColor = [UIColor whiteColor];
        
        [headerView addSubview:title];
        [headerView addSubview:expiration];
        [headerView addSubview:pictureImageView];
        [headerView addSubview:contributions];
        [headerView addSubview:addSharesImageView];
        [headerView addSubview:distance];
        [headerView addSubview:lineView];
        [cell addSubview:headerView];
        
        //for tutorial purposes add a view at the bottom for it to be hooked to
        UIView* tutorialView = [[UIView alloc] initWithFrame:CGRectMake(cell.frame.size.width/2, cell.frame.size.height/2.0, 1, 1)];
        [tutorialView setBackgroundColor:[UIColor clearColor]];
        tutorialView.tag = TUTORIAL_VIEW_TAG;
        [cell addSubview:tutorialView];
        
        
        cell.tag = STREAM_CELL_TAG;
        cell.backgroundView = nil;
        
        PFImageView* cellImageView = cell.shareImageView;
        //see if we have a thumbnail already
        if(s.thumbnail)
        {
            cellImageView.image = s.thumbnail;
            [cell setUserInteractionEnabled:YES];
            [cell.shareImageView setUserInteractionEnabled:YES];
            NSLog(@"using thumbnail on section %d", (int)indexPath.section);
        }
        else
        {
            PFObject* share = [s.streamShares[0] objectForKey:@"share"];
            cell.activityIndicator.hidden = NO;
            [cell.activityIndicator startAnimating];
            [cell bringSubviewToFront:cell.activityIndicator];
            cellImageView.image = [UIImage imageNamed:@"pictures-320.png"];
            cellImageView.file = [share objectForKey:@"file"];
            [cell setUserInteractionEnabled:NO];
            [cell.shareImageView setUserInteractionEnabled:NO];
            NSLog(@"before loading image %@", [s.stream objectForKey:@"name"]);
            [cellImageView loadInBackground:^(UIImage *image, NSError *error) {
                if(error)
                    NSLog(@"error loading pffile");
                else
                    NSLog(@"loading stream %@", [s.stream objectForKey:@"name"]);
                image = [self imageWithImage:image scaledToFillSize:cell.frame.size];
                UIImage* tmpImage = [self fixOrientation:image withOrientation:image.imageOrientation];
                s.thumbnail = cellImageView.image = tmpImage;
                [cell setUserInteractionEnabled:YES];
                [cell.shareImageView setUserInteractionEnabled:YES];
                cellImageView.backgroundColor = [UIColor blackColor];
                cell.activityIndicator.hidden = YES;
                [cell.activityIndicator stopAnimating];
            }];
        }
        if(isnan(interval) || interval<=0)
        {
            [cell setUserInteractionEnabled:NO];
            [cell.shareImageView setUserInteractionEnabled:NO];
            // create effect
            UIBlurEffect *blur = [UIBlurEffect effectWithStyle:UIBlurEffectStyleLight];
            
            // add effect to an effect view
            UIVisualEffectView *effectView = [[UIVisualEffectView alloc]initWithEffect:blur];
            effectView.frame = cellImageView.frame;
            
            // add the effect view to the image view
            [cellImageView addSubview:effectView];
            [cellImageView bringSubviewToFront:effectView];
        }
        else
        {
            //loop through subviews and remove blue effects
            for(UIView* view in cellImageView.subviews)
            {
                if([view isKindOfClass:[UIVisualEffectView class]])
                {
                    NSLog(@"removing tag");
                    [view removeFromSuperview];
                }
            }
            UITapGestureRecognizer *pictureImageTap =  [[UITapGestureRecognizer alloc] initWithTarget:self action:@selector(singlePictureTapDetected:)];
            pictureImageTap.numberOfTapsRequired = 1;
            [cell setUserInteractionEnabled:YES];
            [cell.shareImageView setUserInteractionEnabled:YES];
            cellImageView.tag = indexPath.section;
            [cellImageView addGestureRecognizer:pictureImageTap];
            [cell setUserInteractionEnabled:YES];
        }
        
            
        //}
        [cell bringSubviewToFront:headerView];
        [cell bringSubviewToFront:tutorialView];
        
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
            NSLog(@"current page is now %d", _currentPage);
            [self pullToRefresh];
        }
    }
    
    
}

/*- (void)tableView:(UITableView *)tableView
didEndDisplayingCell:(UITableViewCell *)cell
forRowAtIndexPath:(NSIndexPath *)indexPath
{
    if([indexPath row] == ((NSIndexPath*)[[tableView indexPathsForVisibleRows] lastObject]).row){
        //end of loading
        //if we have already done the streams of content then return
        NSNumber *showStreamOfContentTutorial =
        [[NSUserDefaults standardUserDefaults] objectForKey:@"ShowStreamOfContentTutorial"];
        //NSLog(@"at end of tableview with content %d", showStreamOfContentTutorial.boolValue);
        
        if(!showStreamOfContentTutorial && showStreamsArray && showStreamsArray.count)
        {
            NSLog(@"loading main tutorial");
            [self mainTutorial];
        }
    }
}*/

/*- (void)scrollViewDidEndDecelerating:(UIScrollView *)scrollView{
    
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

//collection view delegates
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
    NSComparisonResult comp = [newestShareTime compare:lastShare.createdAt];
    if(NSOrderedSame == comp || NSOrderedAscending == comp)
    {
        hasNewestShare = YES;
    }
    
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
        collectionActivityIndicator.backgroundColor = [[UIColor blackColor] colorWithAlphaComponent:0.2];
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
        collectionActivityIndicator.backgroundColor = [[UIColor blackColor] colorWithAlphaComponent:0.2];
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
            image = [self imageWithImage:image scaledToFillSize:cell.frame.size];
            UIImage* tmpImage = [self fixOrientation:image withOrientation:image.imageOrientation];
            cell.shareImageView.image = tmpImage;
            for(UIView* view in [cell.shareImageView subviews])
                if([view isKindOfClass:[UIActivityIndicatorView class]])
                    [view removeFromSuperview];
        }];
        //NSLog(@"got to end of row");
    }
    else
    {
        //see if we have the share with the most recent time
        PFObject* lastShare = [s.streamShares lastObject];
        NSDate* newestShareTime = s.newestShareCreationTime;
        bool hasNewestShare = NO;
        NSComparisonResult comp = [newestShareTime compare:lastShare.createdAt];
        if(NSOrderedSame == comp || NSOrderedAscending == comp)
        {
            hasNewestShare = YES;
        }
        NSLog(@"at end loading with count %d, has first share %d, and has newest %d", (int)s.streamShares.count, hasFirstShare, hasNewestShare);
        cell.tag = END_LOADING_SHARE_TAG;
        cell.shareImageView.image = [UIImage imageNamed:@"pictures-512.png"];
        UIActivityIndicatorView* collectionActivityIndicator = [[UIActivityIndicatorView alloc] initWithActivityIndicatorStyle:UIActivityIndicatorViewStyleWhiteLarge];
        collectionActivityIndicator.backgroundColor = [[UIColor blackColor] colorWithAlphaComponent:0.2];
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
}*/

//Prepare segue
- (void) prepareForSegue:(UIStoryboardSegue *)segue sender:(id)sender {
    //If we are segueing to selectedProfile then we need to save profile ID
    if([segue.identifier isEqualToString:@"viewStreamSegue"]){
        StreamCollectionViewController* controller = (StreamCollectionViewController*)segue.destinationViewController;
        //NSLog(@"selected section and row %d, %d", _selectedSectionIndex, _selectedCellIndex);
        
        controller.streamObject = showStreamsArray[_selectedSectionIndex];
        controller.currentRow = _selectedCellIndex;
        _selectedStream = ((Stream*)showStreamsArray[_selectedSectionIndex]).stream;
    }
    else if ([segue.identifier isEqualToString:@"chooseStreamsSegue"]){
        SelectStreamsTableViewController* controller = (SelectStreamsTableViewController*)segue.destinationViewController;
        controller.imageData = _imageData;
        controller.captionText = caption.text;
        controller.currentLocation = _currentLocation;
    }
}

- (CGFloat)tableView:(UITableView *)tableView heightForHeaderInSection:(NSInteger)section {
    return 0.1f;
}

- (IBAction)addStreamAction:(id)sender {
    if(!_central.bluetoothOn)
    {
        [self presentNoBluetoothAlert];
        return;
    }
    
    AVAuthorizationStatus status = [AVCaptureDevice authorizationStatusForMediaType:AVMediaTypeVideo];
    //camera permission is denied
    if(status == AVAuthorizationStatusDenied){ // denied
        [self presentNoCameraAlert];
        return;
    }
    // Explicit user permission is required for media capture, but the user has not yet granted or denied such permission.
    else if(status == AVAuthorizationStatusNotDetermined){
        __block bool allowed = NO;
        __block bool checkingPermissions = YES;
        [AVCaptureDevice requestAccessForMediaType:AVMediaTypeVideo completionHandler:^(BOOL granted) {
            
            NSLog(@"granted is %d", granted);
            allowed = granted;
            checkingPermissions = NO;
        }];
        
        while(checkingPermissions)
            ;
        if(!allowed)
            return;
        
    }
    
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
    _popoverOpen = NO;
    _currentPopover = nil;
    _imagePickerOpen = YES;
    customPicker = [[CustomPickerViewController alloc] init];
    customPicker.delegate = self;
    customPicker.allowsEditing = NO;
    customPicker.sourceType = UIImagePickerControllerSourceTypeCamera;
    customPicker.showsCameraControls = NO;
    customPicker.canTakePicture = YES;
    //helper variables
    float screenWidth = self.view.frame.size.width;
    float transformNumber = self.view.frame.size.height/self.view.frame.size.width;
    NSLog(@"transform number is %f", transformNumber);
    float pickerHeight = self.view.frame.size.height;
    
    CGFloat cameraAspectRatio = 4.0f/3.0f;
    
    CGFloat camViewHeight = screenWidth * cameraAspectRatio;
    CGFloat scale = self.view.frame.size.height / camViewHeight;
    //CGFloat adjustedXPosition = (screenWidth*scale - screenWidth)/2;
    
    CGFloat adjustedYPosition = (pickerHeight - camViewHeight) / 2;
    NSLog(@"adjusted y position is %f", adjustedYPosition);
    NSLog(@"scale is %f",scale);
    CGAffineTransform translate = CGAffineTransformMakeTranslation(0, adjustedYPosition);
    customPicker.cameraViewTransform = translate;
    customPicker.cameraViewTransform = CGAffineTransformScale(translate, scale, scale);
    
    _flashMode = UIImagePickerControllerCameraFlashModeAuto;
    _isTakingPicture = YES;
    //set original center
    _originalCenter = customPicker.view.center;
    
    // overlay on top of camera lens view
    cameraOverlayView = [[UIImageView alloc] initWithFrame:CGRectMake(0,0,screenWidth, pickerHeight)];
    [cameraOverlayView setContentMode:UIViewContentModeScaleToFill];
    cameraOverlayView.alpha = 0.0f;

    //make a textview for the caption on the camera
    caption = [[UITextView alloc] initWithFrame:CGRectMake(0, pickerHeight-2*TOOLBAR_HEIGHT, screenWidth, TOOLBAR_HEIGHT)];
    caption.delegate = self;
    caption.text = @"Enter Caption:";
    caption.textColor = [UIColor whiteColor];
    [caption.layer setBorderColor:[[[UIColor grayColor] colorWithAlphaComponent:0.5] CGColor]];
    [caption.layer setBorderWidth:2.0];
    //The rounded corner part, where you specify your view's corner radius:
    caption.layer.cornerRadius = 10;
    caption.returnKeyType = UIReturnKeyDone;
    [caption setBackgroundColor:[[UIColor blackColor] colorWithAlphaComponent:0.2]];
    
    //setup the toolbar
    toolBar = [[UIToolbar alloc] initWithFrame:CGRectMake(0, self.view.frame.size.height-TOOLBAR_HEIGHT, screenWidth, TOOLBAR_HEIGHT)];
    UIBarButtonItem *cancelButton = [[UIBarButtonItem alloc] initWithBarButtonSystemItem:UIBarButtonSystemItemCancel target:self action:@selector(cancelClicked:)];
    UIBarButtonItem *flipButton = [[UIBarButtonItem alloc] initWithImage:[UIImage imageNamed:@"cameraFlip.png"] style:UIBarButtonItemStyleDone target:self action:@selector(flipCamera:)];
    flashButton = [[UIBarButtonItem alloc] initWithImage:[UIImage imageNamed:@"automaticFlash.png"] style:UIBarButtonItemStyleDone target:self action:@selector(cameraFlash:)];
    [flipButton setTintColor:[UIColor whiteColor]];
    [flashButton setTintColor:[UIColor whiteColor]];
    [cancelButton setTintColor:[UIColor whiteColor]];
    [toolBar setItems:[NSArray arrayWithObjects:cancelButton,[[UIBarButtonItem alloc] initWithBarButtonSystemItem:UIBarButtonSystemItemFlexibleSpace target:nil action:nil], flashButton, [[UIBarButtonItem alloc] initWithBarButtonSystemItem:UIBarButtonSystemItemFlexibleSpace target:nil action:nil], flipButton, nil]];
    [toolBar setBackgroundImage:[UIImage new]
                  forToolbarPosition:UIBarPositionAny
                          barMetrics:UIBarMetricsDefault];
    [toolBar setShadowImage:[UIImage new]
              forToolbarPosition:UIToolbarPositionAny];
    [toolBar setBarStyle:UIBarStyleBlack];
    [toolBar setBackgroundColor:[[UIColor blackColor] colorWithAlphaComponent:0.2]];
    [toolBar setTranslucent:YES];
    
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
    //hide the caption at first
    caption.hidden = YES;
    
    [self presentViewController:customPicker animated:YES completion:^{
        //present an alert to tell the person to tap the screen to take the photo
        NSNumber *showTouchScreenForPhoto =
        [[NSUserDefaults standardUserDefaults] objectForKey:@"ShowTouchScreenForPhoto"];
        if (showTouchScreenForPhoto == nil) {
            UIAlertController *alertController = [UIAlertController
                                                  alertControllerWithTitle:@"Take A Photo"
                                                  message:@"To take a photograph with the camera just tap anywhere on the screen!"
                                                  preferredStyle:UIAlertControllerStyleAlert];
            UIAlertAction *okAction = [UIAlertAction
                                       actionWithTitle:NSLocalizedString(@"Ok", @"Ok action")
                                       style:UIAlertActionStyleDefault
                                       handler:^(UIAlertAction *action)
                                       {
                                           UIAlertController *alertController = [UIAlertController
                                                                                 alertControllerWithTitle:@"Fast Open And Close The Camera"
                                                                                 message:@"Shake your phone to quickly open and close the camera.  This also allows you to share to multiple screens!"
                                                                                 preferredStyle:UIAlertControllerStyleAlert];
                                           UIAlertAction *okAction = [UIAlertAction
                                                                      actionWithTitle:NSLocalizedString(@"Ok", @"Ok action")
                                                                      style:UIAlertActionStyleDefault
                                                                      handler:^(UIAlertAction *action)
                                                                      {
                                                                          NSUserDefaults *defaults = [NSUserDefaults standardUserDefaults];
                                                                          [defaults setObject:@"YES" forKey:@"ShowTouchScreenForPhoto"];
                                                                          [defaults synchronize];
                                                                          return;
                                                                      }];
                                           [alertController addAction:okAction];
                                           
                                           [customPicker presentViewController:alertController animated:YES completion:nil];
                                           return;
                                       }];
            [alertController addAction:okAction];
            
            [customPicker presentViewController:alertController animated:YES completion:nil];
        }
    }];
}

- (void)imagePickerController:(UIImagePickerController *)picker didFinishPickingMediaWithInfo:(NSDictionary *)info {
    
    //Don't allow pictures to be taken
    customPicker.canTakePicture = NO;
    _isTakingPicture = NO;
    caption.hidden = NO;
    //helper var
    float screenWidth = self.view.frame.size.width;
    _expirationTime = ((NSNumber*)[[PFUser currentUser] objectForKey:@"streamTimeHours"]).floatValue;
    
    //figure out the image
    UIImage* originalImage =[info objectForKey:UIImagePickerControllerOriginalImage];
    
    CGFloat imageHeight = originalImage.size.height;
    CGFloat imageWidth = originalImage.size.width;
    CGFloat cameraAspectRatio = 4.0f/3.0f;
    CGFloat camViewHeight = screenWidth * cameraAspectRatio;
    CGFloat scale = self.view.frame.size.height / camViewHeight;
    //NSLog(@"scale is %f", scale);
    CGFloat adjustedXPosition = (imageWidth*scale - imageWidth)/(2.0f*scale);
    CGFloat adjustedYPosition = (imageHeight*scale - imageHeight)/(2.0f*scale);
    //NSLog(@"adjusted x = %f", adjustedXPosition);
    //NSLog(@"image width and height are %f, %f", imageWidth, imageHeight);
    // Create rectangle that represents a cropped image
    CGRect rect = CGRectMake(adjustedXPosition, 0 ,imageWidth-2.0f*adjustedXPosition, imageHeight);
    
    //NSLog(@"rect width is %f and height is %f", rect.size.width, rect.size.height);
    CGAffineTransform rectTransform = CGAffineTransformIdentity;
    switch (originalImage.imageOrientation)
    {
        case UIImageOrientationLeft: //down
            //NSLog(@"orientation left");
            rectTransform = CGAffineTransformTranslate(CGAffineTransformMakeRotation(M_PI_2), 0, -originalImage.size.height);
            break;
        case UIImageOrientationRight: // normal
            //NSLog(@"orientation right");
            rectTransform = CGAffineTransformTranslate(CGAffineTransformMakeRotation(-M_PI_2), -originalImage.size.width, 0);
            break;
        case UIImageOrientationDown: //right
            //NSLog(@"orientation down");
            rect = CGRectMake(0, adjustedYPosition ,imageWidth, imageHeight-2.0f*adjustedYPosition);
            rectTransform = CGAffineTransformTranslate(CGAffineTransformMakeRotation(-M_PI), -originalImage.size.width, -originalImage.size.height);
            break;
        default:
            //NSLog(@"orientation default"); // left
            rect = CGRectMake(0, adjustedYPosition ,imageWidth, imageHeight-2.0f*adjustedYPosition);
            rectTransform = CGAffineTransformIdentity;
    };
    rectTransform = CGAffineTransformScale(rectTransform, originalImage.scale, originalImage.scale);
    
    CGImageRef imageRef = CGImageCreateWithImageInRect([originalImage CGImage], CGRectApplyAffineTransform(rect, rectTransform));
    UIImage *result = [UIImage imageWithCGImage:imageRef scale:originalImage.scale orientation:originalImage.imageOrientation];
    
    int imageOrientation = 3 - result.imageOrientation;
    if(result.imageOrientation == 1 || result.imageOrientation == 2)
        imageOrientation = 3;
    UIImage* fixedImage = [self fixOrientation:result withOrientation:imageOrientation];
    
    
    //if the image is from front camera, need to flip horizontally
    if(customPicker.cameraDevice == UIImagePickerControllerCameraDeviceFront)
    {
        //depending on the orientation is how we flip it
        if(fixedImage.imageOrientation == 3)
            fixedImage = [UIImage imageWithCGImage:fixedImage.CGImage
                                               scale:fixedImage.scale
                                         orientation:UIImageOrientationLeftMirrored];
        else
            fixedImage = [UIImage imageWithCGImage:fixedImage.CGImage
                                               scale:fixedImage.scale
                                         orientation:UIImageOrientationUpMirrored];
    }
    
    //set the image data
    _imageData = UIImageJPEGRepresentation(fixedImage, 1.0f);
    cameraOverlayView.image = fixedImage;
    
    //reset the toolbar
    UIBarButtonItem *cancelButton = [[UIBarButtonItem alloc] initWithBarButtonSystemItem:UIBarButtonSystemItemCancel target:self action:@selector(cancelClicked:)];
    UIBarButtonItem *publishButton = [[UIBarButtonItem alloc] initWithImage:[UIImage imageNamed:@"publish.png"] style:UIBarButtonItemStyleDone target:self action:@selector(publishClicked:)];
    UIBarButtonItem *saveButton = [[UIBarButtonItem alloc] initWithImage:[UIImage imageNamed:@"save.png"] style:UIBarButtonItemStyleDone target:self action:@selector(saveClicked:)];
    
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
        //add the bar button items to the toolbar
        [toolBar setItems:[NSArray arrayWithObjects:cancelButton,[[UIBarButtonItem alloc] initWithBarButtonSystemItem:UIBarButtonSystemItemFlexibleSpace target:nil action:nil], saveButton, [[UIBarButtonItem alloc] initWithBarButtonSystemItem:UIBarButtonSystemItemFlexibleSpace target:nil action:nil],timerBarButtonItem, [[UIBarButtonItem alloc] initWithBarButtonSystemItem:UIBarButtonSystemItemFlexibleSpace target:nil action:nil],publishButton, nil]];
        
        //also setup the pickerview
        [self setupPicker];
    }
    
    
    [self popoverDismissed];
    

    /*UIImage* backgroundImage = [UIImage imageNamed:@"black_box.png"];
     [self.navigationItem.rightBarButtonItem setBackgroundImage:backgroundImage forState:UIControlStateNormal barMetrics:UIBarMetricsDefault ];*/
    //barButtonView.backgroundColor = [UIColor blackColor];
    
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


-(void) popoverDismissed
{
    //see if we have to do the popover right now
    NSNumber *showedCreateStreamTutorial =
    [[NSUserDefaults standardUserDefaults] objectForKey:@"ShowedCreateStreamTutorial"];
    if (showedCreateStreamTutorial)
        return;
    
    //if we showed the add to stream tutorial and are adding again then no need for popovers
    NSNumber *showedAddToStreamTutorial =
    [[NSUserDefaults standardUserDefaults] objectForKey:@"ShowedAddToStreamTutorial"];
    if(showedAddToStreamTutorial && !_creatingStream)
        return;
    
    //Ok, we need to show some tutorial
    UIView* barButtonView;
    UIBarButtonItem* selectedButton;
    
    
    //neither tutorial has been shown
    if(!showedAddToStreamTutorial && !showedAddToStreamTutorial)
    {
        //if no value for current popover then we are on caption
        if(!_currentPopover)
        {
            PopoverViewController* pvc = [self.storyboard instantiateViewControllerWithIdentifier:@"PopoverViewController"];
            [pvc setModalPresentationStyle:UIModalPresentationPopover];
            pvc.preferredContentSize = CGSizeMake(280, 80);
            
            NSLog(@"pvc height is %f", pvc.view.frame.size.height);
            UIPopoverPresentationController* popoverController = pvc.popoverPresentationController;
            NSLog(@"popover controller = %@", popoverController);
            
            //NSLog(@"bar button view is %@", barButtonView);
            popoverController.sourceView = caption;
            popoverController.sourceRect = CGRectMake(0,0,280,80);
            popoverController.permittedArrowDirections = UIPopoverArrowDirectionDown;
            popoverController.delegate = customPicker;
            [customPicker presentViewController:pvc animated:YES completion:nil];
            
            pvc.popoverLabel.text = @"Add a caption to the picture.";
            pvc.popoverLabel.textAlignment = NSTextAlignmentCenter;
            pvc.popoverLabel.numberOfLines = 0;
            _currentPopover = @"caption";
            [caption setEditable:NO];
            return;
        }
        //publish
        else if([_currentPopover isEqualToString:@"caption"])
        {
            //set the publish button as the first to be explained
            selectedButton = toolBar.items[toolBar.items.count-1];
            barButtonView = [selectedButton valueForKey:@"view"];
            //set which popover we are using
            _currentPopover = @"publish";
        }
        else if([_currentPopover isEqualToString:@"publish"] && _creatingStream)
        {
            //set the publish button as the first to be explained
            selectedButton = toolBar.items[4]; // probably shouldn't hardcode it, but oh well
            barButtonView = [selectedButton valueForKey:@"view"];
            //set which popover we are using
            _currentPopover = @"timer";
        }
        else if([_currentPopover isEqualToString:@"publish"] || [_currentPopover isEqualToString:@"timer"])//we are on save
        {
            //set the publish button as the first to be explained
            selectedButton = toolBar.items[2]; // probably shouldn't hardcode it, but oh well
            barButtonView = [selectedButton valueForKey:@"view"];
            //set which popover we are using
            _currentPopover = @"save";
        }
        else if([_currentPopover isEqualToString:@"save"])//on cancel
        {
            //set the publish button as the first to be explained
            selectedButton = toolBar.items[0]; // probably shouldn't hardcode it, but oh well
            barButtonView = [selectedButton valueForKey:@"view"];
            //set which popover we are using
            _currentPopover = @"cancel";
        }
        else//done with popovers
        {
            caption.hidden = NO;
            [caption setEditable:YES];
            _currentPopover = nil;
            for(UIBarButtonItem* barButton in toolBar.items)
            {
                UIView* buttonView = [barButton valueForKey:@"view"];
                buttonView.backgroundColor = [UIColor clearColor];
            }
            
            //set the correct user default
            if(_creatingStream)
            {
                NSUserDefaults *defaults = [NSUserDefaults standardUserDefaults];
                [defaults setObject:@"YES" forKey:@"ShowedCreateStreamTutorial"];
                [defaults setObject:@"YES" forKey:@"ShowedAddToStreamTutorial"];
                [defaults synchronize];
            }
            else
            {
                NSUserDefaults *defaults = [NSUserDefaults standardUserDefaults];
                [defaults setObject:@"YES" forKey:@"ShowedAddToStreamTutorial"];
                [defaults synchronize];
            }
            
            
            return;
        }
    }
    //means
    else if (showedAddToStreamTutorial && !showedCreateStreamTutorial && _creatingStream)
    {
        //if no value for current popover then we are on timer
        if(!_currentPopover)
        {
            //set the publish button as the first to be explained
            selectedButton = toolBar.items[4]; // probably shouldn't hardcode it, but oh well
            barButtonView = [selectedButton valueForKey:@"view"];
            //set which popover we are using
            _currentPopover = @"timer";
        }
        else
        {
            caption.hidden = NO;
            [caption setEditable:YES];
            _currentPopover = nil;
            for(UIBarButtonItem* barButton in toolBar.items)
            {
                UIView* buttonView = [barButton valueForKey:@"view"];
                buttonView.backgroundColor = [UIColor clearColor];
            }
            
            //set the correct user default
            NSUserDefaults *defaults = [NSUserDefaults standardUserDefaults];
            [defaults setObject:@"YES" forKey:@"ShowedCreateStreamTutorial"];
            [defaults synchronize];
            
            return;
        }
    }
    
    //disable the other buttons
    int i = 0;
    for(UIBarButtonItem* barButton in toolBar.items)
    {
        UIView* buttonView = [barButton valueForKey:@"view"];
        //want to highlight
        if(![barButton isEqual:selectedButton])
        {
            buttonView.backgroundColor = [UIColor clearColor];
        }
        else
        {
            buttonView.backgroundColor = [UIColor grayColor];
        }
        i++;
    }
    
    
    PopoverViewController* pvc = [self.storyboard instantiateViewControllerWithIdentifier:@"PopoverViewController"];
    [pvc setModalPresentationStyle:UIModalPresentationPopover];
    pvc.preferredContentSize = CGSizeMake(280, 80);
    
    NSLog(@"pvc height is %f", pvc.view.frame.size.height);
    UIPopoverPresentationController* popoverController = pvc.popoverPresentationController;
    [caption setHidden:YES];
    popoverController.barButtonItem = selectedButton;
    NSLog(@"popover controller = %@", popoverController);
    
    //NSLog(@"bar button view is %@", barButtonView);
    popoverController.sourceView = barButtonView;
    popoverController.sourceRect = CGRectMake(0,0,280,80);
    popoverController.permittedArrowDirections = UIPopoverArrowDirectionDown;
    popoverController.delegate = customPicker;
    [customPicker presentViewController:pvc animated:YES completion:nil];
    if([_currentPopover isEqualToString:@"publish"])
        pvc.popoverLabel.text = @"Publish the photo.";
    if([_currentPopover isEqualToString:@"timer"])
        pvc.popoverLabel.text = @"Set how long you want the stream to last.";
    if([_currentPopover isEqualToString:@"save"])
        pvc.popoverLabel.text = @"Save the photo to your phone's library.";
    if([_currentPopover isEqualToString:@"cancel"])
        pvc.popoverLabel.text = @"Retake the picture";
    pvc.popoverLabel.textAlignment = NSTextAlignmentCenter;
    pvc.popoverLabel.numberOfLines = 0;
}

-(void) timerLabelSelected:(id) sender
{
    if(_currentPopover)
        return;
    [self timerSelected:self];
}

//helper to change the timer
-(void) timerSelected:(id)sender
{
    if(_currentPopover)
        return;
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
    if(_currentPopover)
        return;
    UIImage* imageTaken = [UIImage imageWithData:_imageData];
    UIImageWriteToSavedPhotosAlbum(imageTaken, self, @selector(image:didFinishSavingWithError:contextInfo:), nil);
}

- (void)image:(UIImage *)image didFinishSavingWithError:(NSError *)error contextInfo:(void *)contextInfo {
    NSLog(@"trying to save photo");
    if (error) {
        UIAlertController *alertController = [UIAlertController
                                              alertControllerWithTitle:@"Photos Not Allowed!"
                                              message:@"Photos Permission Is Not Allowed. Turn On The Photos Permission For This App Through The Settings To Save Your Photo."
                                              preferredStyle:UIAlertControllerStyleAlert];
        UIAlertAction *okAction = [UIAlertAction
                                   actionWithTitle:NSLocalizedString(@"Ok", @"Ok action")
                                   style:UIAlertActionStyleDefault
                                   handler:^(UIAlertAction *action)
                                   {
                                       return;
                                   }];
        UIAlertAction *settingsAction = [UIAlertAction
                                         actionWithTitle:NSLocalizedString(@"Settings", @"Settings action")
                                         style:UIAlertActionStyleDefault
                                         handler:^(UIAlertAction *action)
                                         {
                                             if (UIApplicationOpenSettingsURLString != NULL) {
                                                 [[UIApplication sharedApplication] openURL:[NSURL URLWithString:UIApplicationOpenSettingsURLString]];
                                             }
                                             return;
                                         }];

        [alertController addAction:settingsAction];
        [alertController addAction:okAction];
        
        [customPicker presentViewController:alertController animated:YES completion:nil];
    }
    else
    {
        UIAlertController *alertController = [UIAlertController
                                              alertControllerWithTitle:@"Success!"
                                              message:@"Photo was saved to your library."
                                              preferredStyle:UIAlertControllerStyleAlert];
        UIAlertAction *okAction = [UIAlertAction
                                   actionWithTitle:NSLocalizedString(@"Ok", @"Ok action")
                                   style:UIAlertActionStyleDefault
                                   handler:^(UIAlertAction *action)
                                   {
                                       return;
                                   }];
        
        [alertController addAction:okAction];
        
        [customPicker presentViewController:alertController animated:YES completion:nil];
    }
        
    
}

-(void) publishClicked:(id)sender
{
    [self getCurrentLocation];
}

-(void) publishNew
{
    
    //start the timer
    //_timeoutTimer =[NSTimer scheduledTimerWithTimeInterval:TIMEOUT_TIMER_TIME target:self selector:@selector(timeoutTimerFired) userInfo:nil repeats:NO];
    
    if(_currentPopover)
        return;
    
    activityIndicator = [[UIActivityIndicatorView alloc] initWithActivityIndicatorStyle:UIActivityIndicatorViewStyleWhiteLarge];
    activityView = [[UIView alloc] initWithFrame:CGRectMake(0, 0, activityIndicator.frame.size.width*2, activityIndicator.frame.size.height*2)];
    activityView.backgroundColor = [UIColor blackColor];
    activityView.center = cameraOverlayView.center;
    activityIndicator.center = cameraOverlayView.center;
    activityView.layer.cornerRadius = 5;
    activityView.clipsToBounds = YES;
    
    [activityIndicator startAnimating];
    [activityIndicator setHidden:NO];
    [activityView setHidden:NO];
    [customPicker.view addSubview:activityView];
    [customPicker.view addSubview:activityIndicator];
    [customPicker.view bringSubviewToFront:activityIndicator];
    [toolBar setHidden:YES];
    [caption setHidden:YES];
    
    
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
    if(_currentPopover)
        return;
    //first picture
    if(_isTakingPicture)
    {
        _openedWithShake = NO;
        [self dismissImagePickerView];
    }
    //second picture
    else
    {
        caption.hidden = YES;
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
        cameraOverlayView.image = nil;//[UIImage imageNamed:@"camera_overlay.png"];
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
    [user fetchIfNeededInBackground];
    
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
    [caption setBackgroundColor: [[UIColor blackColor] colorWithAlphaComponent:0.2]];
    NSLog(@"before user");
    PFUser* user = [[PFUser alloc] init];
    user.objectId = [NSString stringWithString:[PFUser currentUser].objectId];
    user.username = [NSString stringWithString:[PFUser currentUser].username];
    NSLog(@"after assigning user");

    //Create the default acl
    PFACL *defaultACL = [PFACL ACL];
    [defaultACL setReadAccess:true forUser:user];
    [defaultACL setWriteAccess:true forUser:user];
    [defaultACL setPublicReadAccess:false];
    [defaultACL setPublicWriteAccess:false];
    NSLog(@"after using user");
    
    //create the file
    PFFile *pictureFile = [PFFile fileWithData:_imageData];
    
    NSString* cap = [[NSString alloc] initWithString:caption.text];
    NSString* streamName = [[NSString alloc] initWithString:_streamName];
    
    
    //create the share
    PFObject* share = [PFObject objectWithClassName:@"Share"];
    share[@"caption"] = cap;
    NSLog(@"before assigning user to user in share");
    share[@"user"] = user;
    share[@"username"] = user.username;
    share[@"isPrivate"] = [NSNumber numberWithBool:NO];
    share[@"type"] = @"img";
    PFGeoPoint* currentLocation = [PFGeoPoint geoPointWithLocation:_currentLocation];
    if(currentLocation)
        share[@"location"] = currentLocation;
    [share setObject:pictureFile forKey:@"file"];
    [share setACL:defaultACL];
    
    NSLog(@"about to save new stream");
    
    //do 4 requests so we know it actually saves
    [share saveInBackgroundWithBlock:^(BOOL succeeded, NSError *error) {
        if(error)
        {
            NSLog(@"error saving share");
            /*UIAlertController *alertController = [UIAlertController
                                                  alertControllerWithTitle:@"Error Starting Stream"
                                                  message:@"An error occurred starting the stream.  Check your internet connection and try again."
                                                  preferredStyle:UIAlertControllerStyleAlert];
            UIAlertAction *okAction = [UIAlertAction
                                       actionWithTitle:NSLocalizedString(@"Ok", @"Ok action")
                                       style:UIAlertActionStyleDefault
                                       handler:^(UIAlertAction *action)
                                       {
                                           [share deleteInBackground];
                                           [activityView setHidden:YES];
                                           [activityIndicator setHidden:YES];
                                           [toolBar setHidden:NO];
                                           [caption setHidden:NO];
                                           return;
                                       }];
            
            [alertController addAction:okAction];
            [customPicker presentViewController:alertController animated:YES completion:nil];
            */
            [share deleteInBackground];
            return;
            
        }
        NSLog(@"saved share");
        //create the new stream
        PFObject* stream = [PFObject objectWithClassName:@"Stream"];
        stream[@"isPrivate"] = [NSNumber numberWithBool:NO]; //Just hardcoding this for now
        stream[@"name"] = streamName;
        stream[@"creator"] = user;
        stream[@"endTime"] = endDate;
        stream[@"firstShare"] = share;
        stream[@"isValid"] = [NSNumber numberWithBool:YES];
        if(currentLocation)
            stream[@"location"] = currentLocation;
        [stream setACL:defaultACL];
        
        [stream saveInBackgroundWithBlock:^(BOOL succeeded, NSError *error) {
            if(error)
            {
                NSLog(@"error saving stream");
                /*UIAlertController *alertController = [UIAlertController
                                                      alertControllerWithTitle:@"Error Starting Stream"
                                                      message:@"An error occurred starting the stream.  Check your internet connection and try again."
                                                      preferredStyle:UIAlertControllerStyleAlert];
                UIAlertAction *okAction = [UIAlertAction
                                           actionWithTitle:NSLocalizedString(@"Ok", @"Ok action")
                                           style:UIAlertActionStyleDefault
                                           handler:^(UIAlertAction *action)
                                           {
                                               NSArray* pfObjects = [[NSArray alloc] initWithObjects:share,stream, nil];
                                               [PFObject deleteAllInBackground:pfObjects];
                                               [activityIndicator setHidden:YES];
                                               [activityView setHidden:YES];
                                               [toolBar setHidden:NO];
                                               [caption setHidden:NO];
                                               return;
                                           }];
                
                [alertController addAction:okAction];
                [customPicker presentViewController:alertController animated:YES completion:nil];*/
                NSArray* pfObjects = [[NSArray alloc] initWithObjects:share,stream, nil];
                [PFObject deleteAllInBackground:pfObjects];
                return;
                
            }
            
            //create the stream share
            PFObject* streamShare = [PFObject objectWithClassName:@"StreamShares"];
            streamShare[@"stream"] = stream;
            streamShare[@"share"] = share;
            streamShare[@"user"] = user;
            streamShare[@"isIgnored"] = [NSNumber numberWithBool:NO];
            [streamShare setACL:defaultACL];
            
            [streamShare saveInBackgroundWithBlock:^(BOOL succeeded, NSError *error) {
                if(error)
                {
                    NSLog(@"error saving streamshare");
                    /*UIAlertController *alertController = [UIAlertController
                                                          alertControllerWithTitle:@"Error Starting Stream"
                                                          message:@"An error occurred starting the stream.  Check your internet connection and try again."
                                                          preferredStyle:UIAlertControllerStyleAlert];
                    UIAlertAction *okAction = [UIAlertAction
                                               actionWithTitle:NSLocalizedString(@"Ok", @"Ok action")
                                               style:UIAlertActionStyleDefault
                                               handler:^(UIAlertAction *action)
                                               {
                                                   NSArray* pfObjects = [[NSArray alloc] initWithObjects:share,stream,streamShare, nil];
                                                   [PFObject deleteAllInBackground:pfObjects];
                                                   [activityView setHidden:YES];
                                                   [activityIndicator setHidden:YES];
                                                   [toolBar setHidden:NO];
                                                   [caption setHidden:NO];
                                                   return;
                                               }];
                    
                    [alertController addAction:okAction];
                    [customPicker presentViewController:alertController animated:YES completion:nil];*/
                    NSArray* pfObjects = [[NSArray alloc] initWithObjects:share,stream,streamShare, nil];
                    [PFObject deleteAllInBackground:pfObjects];
                    return;
                    
                }
                //create the user stream
                PFObject* userStream = [PFObject objectWithClassName:@"UserStreams"];
                userStream[@"user"] = user;
                userStream[@"stream"] = stream;
                userStream[@"stream_share"] = streamShare;
                userStream[@"share"] = share;
                userStream[@"creator"] = user;
                userStream[@"isIgnored"] = [NSNumber numberWithBool:NO];
                if(currentLocation)
                    userStream[@"location"] = currentLocation;
                userStream[@"gotByBluetooth"] = [NSNumber numberWithBool:YES];
                userStream[@"isValid"] = [NSNumber numberWithBool:YES];
                [userStream setACL:defaultACL];
                
                [userStream saveInBackgroundWithBlock:^(BOOL succeeded, NSError *error) {
                    if(error)
                    {
                        NSLog(@"error saving userstream");
                        /*UIAlertController *alertController = [UIAlertController
                                                              alertControllerWithTitle:@"Error Starting Stream"
                                                              message:@"An error occurred starting the stream.  Check your internet connection and try again."
                                                              preferredStyle:UIAlertControllerStyleAlert];
                        UIAlertAction *okAction = [UIAlertAction
                                                   actionWithTitle:NSLocalizedString(@"Ok", @"Ok action")
                                                   style:UIAlertActionStyleDefault
                                                   handler:^(UIAlertAction *action)
                                                   {
                                                       NSArray* pfObjects = [[NSArray alloc] initWithObjects:share,stream,streamShare,userStream, nil];
                                                       [PFObject deleteAllInBackground:pfObjects];
                                                       [activityView setHidden:YES];
                                                       [activityIndicator setHidden:YES];
                                                       [toolBar setHidden:NO];
                                                       [caption setHidden:NO];
                                                       return;
                                                   }];
                        
                        [alertController addAction:okAction];
                        [customPicker presentViewController:alertController animated:YES completion:nil];*/
                        NSArray* pfObjects = [[NSArray alloc] initWithObjects:share,stream,streamShare,userStream, nil];
                        [PFObject deleteAllInBackground:pfObjects];
                        return;
                        
                    }
                    
                    //invalidate the timer
                    //[_timeoutTimer invalidate];
                    
                    //no error.  Pop and return
                    AppDelegate* appDelegate = [[UIApplication sharedApplication] delegate];
                    NSMutableArray* streams = [appDelegate streams];
                    Stream* newStream = [[Stream alloc] init];
                    newStream.stream = stream;
                    //want to create an array of shares so we can lazy load the next ones
                    [newStream.streamShares addObject:streamShare];
                    newStream.username = user.username;
                    //newest time of streamshare
                    newStream.newestShareCreationTime = streamShare.createdAt;
                    newStream.gotByBluetooth = YES;
                    [streams addObject:newStream];
                    [self sortStreams];
                    //update the user's points total
                    [PFCloud callFunctionInBackground:@"createStreamUpdatePoints" withParameters:@{} block:^(id object, NSError *error) {}];
                    //send push to users
                    
                    //see if any of the users are stale
                    
                    //get nearby user streams first
                    MainDatabase* md = [MainDatabase shared];
                    __block bool inQueue = YES;
                    NSMutableArray* userIds = [[NSMutableArray alloc] init];
                    [md.queue inDatabase:^(FMDatabase *db) {
                        double currentTime = [[NSDate date]timeIntervalSince1970];
                        double expirationTime = currentTime-TIMEOUT_TIME;
                        //delete all expired user ids
                        NSString *deleteSQL = @"DELETE FROM user WHERE time_since_update < ? AND is_me != ?";
                         NSArray* values = @[[NSNumber numberWithDouble:expirationTime], [NSNumber numberWithInt:1]];
                        [db executeUpdate:deleteSQL withArgumentsInArray:values];
                        
                        //need to delete the peripherals that are about to expire
                        NSString *userSQL = @"SELECT DISTINCT user_id FROM user WHERE is_me != ?";
                        values = @[[NSNumber numberWithInt:1]];
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
                    
                    for(NSString* userId in userIds)
                        NSLog(@"user id is %@",userId);
                    
                    //send push
                    if(userIds && userIds.count)
                        [PFCloud callFunctionInBackground:@"sendPushForStream" withParameters:@{@"streamId":newStream.stream.objectId, @"userIds":userIds} block:^(id object, NSError *error) {}];
                    //[self dismissImagePickerView];
                }];
                
            }];
            
        }];

    }];
    
    [self dismissImagePickerView];
    
    /*[PFObject saveAllInBackground:pfObjects block:^(BOOL succeeded, NSError *error) {
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
        
    }];*/

}

//add photo to share
- (void) addNewShareToStream:(NSString*)captionText
{
    if(!captionText.length || [captionText isEqualToString:@"Enter Caption:"])
        captionText = @"No caption.";
    [caption setBackgroundColor:[[UIColor blackColor] colorWithAlphaComponent:0.2]];
    
    NSString* cap = [[NSString alloc] initWithString:caption.text];
    PFUser* user = [[PFUser alloc] init];
    user.objectId = [NSString stringWithString:[PFUser currentUser].objectId];
    user.username = [NSString stringWithString:[PFUser currentUser].username];

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
    share[@"caption"] = cap;
    share[@"user"] = user;
    share[@"username"] = user.username;
    share[@"isPrivate"] = [NSNumber numberWithBool:NO];
    share[@"type"] = @"img";
    PFGeoPoint* currentLocation = [PFGeoPoint geoPointWithLocation:_currentLocation];
    if(currentLocation)
        share[@"location"] = currentLocation;    [share setObject:pictureFile forKey:@"file"];
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
    textView.textColor = [UIColor whiteColor];
    
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
        textView.textColor = [UIColor whiteColor];
    }
    customPicker.view.center = _originalCenter;
    [textView resignFirstResponder];
}

- (UIImage *)fixOrientation:(UIImage*)image withOrientation:(int)orientation {
    
    //NSLog(@"image orientation is %d", orientation);
    //NSLog(@"up = %d, down = %d, right = %d, left = %d", (int)UIImageOrientationUp, (int)UIImageOrientationDown, (int)UIImageOrientationRight, (int)UIImageOrientationLeft);
    
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

- (UIImage *)imageWithImage:(UIImage *)image scaledToFillSize:(CGSize)size
{
    CGFloat scale = MAX(size.width/image.size.width, size.height/image.size.height);
    //int imageOrientation = image.imageOrientation;
    CGFloat width = image.size.width * scale;
    CGFloat height = image.size.height * scale;
    if(image.size.width>image.size.height)
    {
        width =image.size.height * scale;
        height =image.size.width * scale;
    }
    CGRect imageRect = CGRectMake((size.width - width)/2.0f,
                                  (size.height - height)/2.0f,
                                  width,
                                  height);
    
    UIGraphicsBeginImageContextWithOptions(size, NO, 0);
    [image drawInRect:imageRect];
    UIImage *newImage = UIGraphicsGetImageFromCurrentImageContext();
    UIGraphicsEndImageContext();
    return newImage;
}

#pragma mark - CLLocationManagerDelegate

- (void)locationManager:(CLLocationManager *)manager didFailWithError:(NSError *)error
{
    NSLog(@"current location is %@ in failed with error", _currentLocation);
    if(!_gettingLocation)
        return;
    [_locationManager stopUpdatingLocation];
    
    if(_refreshingStreams)
        [[NSNotificationCenter defaultCenter] postNotificationName:@"updatedLocation" object:self];
    else
        [[NSNotificationCenter defaultCenter] postNotificationName:@"updatedLocationForCreation" object:self];
    _refreshingStreams = NO;
    _gettingLocation = NO;
    [_timerGPS invalidate];
}

- (void)locationManager:(CLLocationManager *)manager didUpdateToLocation:(CLLocation *)newLocation fromLocation:(CLLocation *)oldLocation
{
    NSLog(@"didUpdateToLocation: %@", newLocation);
    if(!_gettingLocation)
        return;
    
    _currentLocation = newLocation;
    NSLog(@"current location is %@", _currentLocation);
    if(!_currentLocation)
        return;
    [_locationManager stopUpdatingLocation];
    if(_refreshingStreams)
        [[NSNotificationCenter defaultCenter] postNotificationName:@"updatedLocation" object:self];
    else
        [[NSNotificationCenter defaultCenter] postNotificationName:@"updatedLocationForCreation" object:self];
    _refreshingStreams = NO;
    _gettingLocation = NO;
    [_timerGPS invalidate];
    
}

- (void)locationManager:(CLLocationManager *)manager
didChangeAuthorizationStatus:(CLAuthorizationStatus)status
{
    NSLog(@"authorization status is %d", [CLLocationManager authorizationStatus]);
    
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


- (UIModalPresentationStyle)adaptivePresentationStyleForPresentationController:(UIPresentationController *)controller {
    NSLog(@"in main adaptivepresentation");
    return UIModalPresentationNone;
}
- (void)didEnterBackground:(NSNotification *)notification
{
    NSLog(@"entered background");
    [self.presentedViewController dismissViewControllerAnimated:NO completion:nil];
}

- (void)popoverPresentationControllerDidDismissPopover:(UIPopoverPresentationController *)popoverPresentationController
{
    _popoverOpen = NO;
    [self mainTutorial];
    
}

@end
