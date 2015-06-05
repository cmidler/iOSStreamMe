//
//  AppDelegate.m
//  genesis
//
//  Created by Chase Midler on 9/3/14.
//  Copyright (c) 2014 midler. All rights reserved.
//

#import "AppDelegate.h"


@implementation AppDelegate

- (BOOL)application:(UIApplication *)application didFinishLaunchingWithOptions:(NSDictionary *)launchOptions
{
    [Parse setApplicationId:@"kS3R0NQNdM1tIUJvRJjuIROjKnqWCEHG6qNPo1R7"
                  clientKey:@"opUN4DvIo77ZD5TdDHyr78h2HhhMJFmrBkbws6Ww"];
    [PFUser enableRevocableSessionInBackground];
    [PFAnalytics trackAppOpenedWithLaunchOptions:launchOptions];
    [[UIApplication sharedApplication] setStatusBarStyle:UIStatusBarStyleLightContent];
    
    //setting up page controls
    UIPageControl *pageControl = [UIPageControl appearance];
    pageControl.pageIndicatorTintColor = [UIColor lightGrayColor];
    pageControl.currentPageIndicatorTintColor = [UIColor blackColor];
    pageControl.backgroundColor = [UIColor whiteColor];
    
    
    // Register for Push Notitications, if running iOS 8
    if ([application respondsToSelector:@selector(registerUserNotificationSettings:)]) {
        UIUserNotificationType userNotificationTypes = (UIUserNotificationTypeAlert |
                                                        UIUserNotificationTypeBadge |
                                                        UIUserNotificationTypeSound);
        UIUserNotificationSettings *settings = [UIUserNotificationSettings settingsForTypes:userNotificationTypes
                                                                                 categories:nil];
        [application registerUserNotificationSettings:settings];
        [application registerForRemoteNotifications];
    }
    
    //if the badges count is over 0, check for usercontact info
    PFInstallation *currentInstallation = [PFInstallation currentInstallation];
    
    if(currentInstallation.badge>0)
    {
        //we received a notification so make sure to update a badge for "New"
        [[NSNotificationCenter defaultCenter] postNotificationName:@"addBadge" object:self];
    }
    
    [self setupDB];
    
    //setting up variables
    _streams = [[NSMutableArray alloc] init];
    _timer =[NSTimer scheduledTimerWithTimeInterval:GET_COUNT_TIMER target:self selector:@selector(countTimer) userInfo:nil repeats:YES];
    //_periodicTimer =[NSTimer scheduledTimerWithTimeInterval:CHECK_FOR_USERS target:self selector:@selector(resetPeripheral) userInfo:nil repeats:YES];
    _central = [[CBCentralInterface alloc]init];
    _peripheral = [[CBPeripheralInterface alloc] init];
    
    
    // initialize defaults
    NSString *dateKey    = @"dateKey";
    NSDate *lastRead    = (NSDate *)[[NSUserDefaults standardUserDefaults] objectForKey:dateKey];
    if (lastRead == nil)     // App first run: set up user defaults.
    {
        NSDictionary *appDefaults  = [NSDictionary dictionaryWithObjectsAndKeys:[NSDate date], dateKey, nil];
        
        // sync the defaults to disk
        [[NSUserDefaults standardUserDefaults] registerDefaults:appDefaults];
        [[NSUserDefaults standardUserDefaults] synchronize];
    }
    [[NSUserDefaults standardUserDefaults] setObject:[NSDate date] forKey:dateKey];
    
    
    
    NSLog(@"did finish launching");
    [[NSNotificationCenter defaultCenter] postNotificationName:@"reloadSection" object:self];
    return YES;
}

//fire the count timer every minute seconds to see if there were updates to the streams
-(void) countTimer
{
    [[NSNotificationCenter defaultCenter] postNotificationName:@"countTimerFired" object:self userInfo:nil];
    
}

- (void) resetCentralAndPeripheral
{
    NSLog(@"resetting central");
    _central = [[CBCentralInterface alloc]init];
    _peripheral = [[CBPeripheralInterface alloc] init];
    [_central startScanningForUserProfiles];
    [_peripheral startAdvertisingProfile];
}

//reset central
-(void) resetCentral
{
    NSLog(@"resetting central");
    _central = [[CBCentralInterface alloc]init];
    [_central startScanningForUserProfiles];
}

//reset peripheral
-(void) resetPeripheral
{
    NSLog(@"resetting peripheral");
    _peripheral = [[CBPeripheralInterface alloc] init];
    [_peripheral startAdvertisingProfile];
}


/* Setting up push notifications through parse*/
- (void)application:(UIApplication *)application didRegisterForRemoteNotificationsWithDeviceToken:(NSData *)deviceToken {
    // Store the deviceToken in the current installation and save it to Parse.
    PFInstallation *currentInstallation = [PFInstallation currentInstallation];
    [currentInstallation setDeviceTokenFromData:deviceToken];
    currentInstallation.channels = @[ @"global" ];
    [currentInstallation saveInBackground];
}


- (void)application:(UIApplication *)application didReceiveRemoteNotification:(NSDictionary *)userInfo
{
    NSLog(@"received remote notification");
    
    //Don't want to show push info if we are in the application
    if (application.applicationState != UIApplicationStateActive)
    {
        NSLog(@"handle push");
        [[NSNotificationCenter defaultCenter] postNotificationName:@"newUserStreams" object:self userInfo:nil];
        [PFPush handlePush:userInfo];
        return;
    }
    NSString* data = [userInfo objectForKey:@"data"];
    //see if the push is telling me about a new userstream
    if(data && data.length)
    {
        
        //query my userstreams to see if I already have a userstream for it
        PFQuery* query = [PFQuery queryWithClassName:@"UserStream"];
        PFObject * stream = [PFObject objectWithoutDataWithClassName:@"Stream" objectId:data];
        [query whereKey:@"stream" equalTo:stream];
        [query whereKey:@"user" equalTo:[PFUser currentUser]];
        [query findObjectsInBackgroundWithBlock:^(NSArray *objects, NSError *error) {
            if(error || (objects && objects.count))
            {
                NSLog(@"Don't do anything on this push notification");
            }
            else
            {
                //create the userstream
                [PFCloud callFunctionInBackground:@"createNewUserStream" withParameters:@{@"streamId":data} block:^(id object, NSError *error) {
                    
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
                        [PFCloud callFunctionInBackground:@"sendPushForStream" withParameters:@{@"streamId":data, @"userIds":userIds} block:^(id object, NSError *error) {}];
                    
                    //Set badge number to 0 if active
                    PFInstallation *currentInstallation = [PFInstallation currentInstallation];
                    if (currentInstallation.badge != 0) {
                        currentInstallation.badge = 0;
                        [currentInstallation saveEventually];
                    }
                    [[NSNotificationCenter defaultCenter] postNotificationName:@"newUserStreams" object:self userInfo:nil];

                }];
            }
        }];
    }
    else
    {
        //Set badge number to 0 if active
        PFInstallation *currentInstallation = [PFInstallation currentInstallation];
        if (currentInstallation.badge != 0) {
            currentInstallation.badge = 0;
            [currentInstallation saveEventually];
        }
    }
    
}

- (void)application:(UIApplication *)application
didReceiveRemoteNotification:(NSDictionary *)userInfo
fetchCompletionHandler:(void (^)(UIBackgroundFetchResult))handler {
    
    NSString* data = [userInfo objectForKey:@"data"];
    //see if the push is telling me about a new userstream
    if(data && data.length)
    {
        //query my userstreams to see if I already have a userstream for it
        PFQuery* query = [PFQuery queryWithClassName:@"UserStream"];
        PFObject * stream = [PFObject objectWithoutDataWithClassName:@"Stream" objectId:data];
        [query whereKey:@"stream" equalTo:stream];
        [query whereKey:@"user" equalTo:[PFUser currentUser]];
        [query findObjectsInBackgroundWithBlock:^(NSArray *objects, NSError *error) {
            if(error || (objects && objects.count))
            {
                NSLog(@"Don't do anything on this push notification");
            }
            else
            {
        
                //create the userstream
                [PFCloud callFunctionInBackground:@"createNewUserStream" withParameters:@{@"streamId":data} block:^(id object, NSError *error) {
                    
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
                        [PFCloud callFunctionInBackground:@"sendPushForStream" withParameters:@{@"streamId":data, @"userIds":userIds} block:^(id object, NSError *error) {}];
                    [[NSNotificationCenter defaultCenter] postNotificationName:@"newUserStreams" object:self userInfo:nil];
                }];
            }
        }];
    }
    else
        [[NSNotificationCenter defaultCenter] postNotificationName:@"newUserStreams" object:self userInfo:nil];
    NSLog(@"new stream detected");
}

-(void) setupDB
{
    //get the main database
    MainDatabase* md = [MainDatabase shared];
    [md.queue inDatabase:^(FMDatabase *db) {
        
        //create user table
        if(![db tableExists:@"USER"])
        {
            NSString* userString = @"CREATE TABLE IF NOT EXISTS USER (ID INTEGER PRIMARY KEY AUTOINCREMENT, IS_ME INTEGER, USER_ID TEXT, TIME_SINCE_UPDATE DOUBLE, PERIPHERAL_ID TEXT)";
            [db executeUpdate:userString withArgumentsInArray:nil];
            NSString* timerString = @"CREATE TABLE IF NOT EXISTS TIMER (ID INTEGER PRIMARY KEY AUTOINCREMENT, LAST_TIME_STORED DOUBLE)";
            [db executeUpdate:timerString];
            NSString* timerInsert = @"INSERT INTO timer (LAST_TIME_STORED) VALUES (?)";
            NSArray* timeValues = @[[NSNumber numberWithDouble:[[NSDate date] timeIntervalSince1970]]];
            [db executeUpdate:timerInsert withArgumentsInArray:timeValues];
        }
    }];
}



- (void)applicationWillResignActive:(UIApplication *)application
{
    // Sent when the application is about to move from active to inactive state. This can occur for certain types of temporary interruptions (such as an incoming phone call or SMS message) or when the user quits the application and it begins the transition to the background state.
    // Use this method to pause ongoing tasks, disable timers, and throttle down OpenGL ES frame rates. Games should use this method to pause the game.
    [[NSNotificationCenter defaultCenter] postNotificationName:@"updateTimeElapsed" object:self userInfo:nil];
}

- (void)applicationDidEnterBackground:(UIApplication *)application
{
    //Turning central off and make sure peripheral is still advertising
    if(!_central)
        _central = [[CBCentralInterface alloc]init];
    [_central startScanningForUserProfiles];
    [_timer invalidate];
    //[_periodicTimer invalidate];
    [[NSNotificationCenter defaultCenter] postNotificationName:@"updateTimeElapsed" object:self userInfo:nil];
    if(!_peripheral)
        _peripheral = [[CBPeripheralInterface alloc] init];
    [_peripheral startAdvertisingProfile];
}

- (void)applicationWillEnterForeground:(UIApplication *)application
{
    //_periodicTimer =[NSTimer scheduledTimerWithTimeInterval:CHECK_FOR_USERS target:self selector:@selector(resetPeripheral) userInfo:nil repeats:YES];
    //Fire immediately every time we launch
    //[_periodicTimer fire];
    _timer =[NSTimer scheduledTimerWithTimeInterval:GET_COUNT_TIMER target:self selector:@selector(countTimer) userInfo:nil repeats:YES];
    
    if([PFUser currentUser])
        [[NSNotificationCenter defaultCenter] postNotificationName:@"refreshStreams" object:self userInfo:nil];
    //[[NSNotificationCenter defaultCenter] postNotificationName:@"reloadSection" object:self];
    //Turning central and peripheral on
    if(!_central)
        _central = [[CBCentralInterface alloc]init];
    
    [_central startScanningForUserProfiles];
   
    if(!_peripheral)
        _peripheral = [[CBPeripheralInterface alloc] init];
    [_peripheral startAdvertisingProfile];
}

- (void)applicationDidBecomeActive:(UIApplication *)application
{
    // Restart any tasks that were paused (or not yet started) while the application was inactive. If the application was previously in the background, optionally refresh the user interface.
    PFInstallation *currentInstallation = [PFInstallation currentInstallation];
    if (currentInstallation.badge != 0) {
        currentInstallation.badge = 0;
        [currentInstallation saveEventually];
    }
    //_periodicTimer =[NSTimer scheduledTimerWithTimeInterval:3600.0 target:self selector:@selector(checkMarkedDeletion) userInfo:nil repeats:YES];
    //Fire immediately every time we launch
    //[_periodicTimer fire];
    
    //Turning central and peripheral on
    if(!_central)
        _central = [[CBCentralInterface alloc]init];
    [_central startScanningForUserProfiles];
    
    if(!_peripheral)
        _peripheral = [[CBPeripheralInterface alloc] init];
    [_peripheral startAdvertisingProfile];

}

- (void)applicationWillTerminate:(UIApplication *)application
{
    // Called when the application is about to terminate. Save data if appropriate. See also applicationDidEnterBackground:.
    //Turning central and peripheral on
    if(!_central)
        _central = [[CBCentralInterface alloc]init];
    [_central startScanningForUserProfiles];
    
    if(!_peripheral)
        _peripheral = [[CBPeripheralInterface alloc] init];
    [_peripheral startAdvertisingProfile];

}

//State preservation and restoration opt-in
/*-(BOOL)application:(UIApplication *)application shouldRestoreApplicationState:(NSCoder *)coder
{
    return YES;
}

-(BOOL)application:(UIApplication *)application shouldSaveApplicationState:(NSCoder *)coder
{
    return YES;
}*/



@end
