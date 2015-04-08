//
//  MainTabBarViewController.m
//  proximity
//
//  Created by Chase Midler on 10/17/14.
//  Copyright (c) 2014 midler. All rights reserved.
//

#import "MainTabBarViewController.h"

@interface MainTabBarViewController ()

@end

@implementation MainTabBarViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    // Do any additional setup after loading the view.
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

-(void) viewWillAppear:(BOOL)animated
{
    //Setup notification center
    [[NSNotificationCenter defaultCenter] addObserver:self
                                             selector:@selector(newActivityUpdate:)
                                                 name:@"addBadge"
                                               object:nil];
    [[NSNotificationCenter defaultCenter] addObserver:self
                                             selector:@selector(newActivityUpdate:)
                                                 name:@"removeBadge"
                                               object:nil];
}

//Notification based on new event
- (void) newActivityUpdate:(NSNotification *) notification
{
    //Check if the user is busy or available
    //StoreUserProfile* sup = [StoreUserProfile shared];
    //if([sup.profile.is_open isEqualToString:@"off"])
    //    return;
    
    if ([[notification name] isEqualToString:@"addBadge"])
    {
        //Activity index
        UITabBarItem *activitiesTabBarItem = [[[self tabBar] items] objectAtIndex:1];
        
        /*//If it is over 99 just leave it at 99
        if([activitiesTabBarItem.badgeValue isEqualToString:@"99+"])
            return;
        
        int badgeCount = [activitiesTabBarItem.badgeValue intValue] + 1;
        
        //If badge count is going to be over 99 set it to 99+
        if(badgeCount >= 100)
            activitiesTabBarItem.badgeValue = @"99+";
        else
            activitiesTabBarItem.badgeValue = [NSString stringWithFormat:@"%d",badgeCount];*/
        activitiesTabBarItem.badgeValue = @"New";
       
    }
    else if ([[notification name] isEqualToString:@"removeBadge"])
    {
        //Activity index
        UITabBarItem *activitiesTabBarItem = [[[self tabBar] items] objectAtIndex:1];
        activitiesTabBarItem.badgeValue = nil;
    }
}

/*
#pragma mark - Navigation

// In a storyboard-based application, you will often want to do a little preparation before navigation
- (void)prepareForSegue:(UIStoryboardSegue *)segue sender:(id)sender {
    // Get the new view controller using [segue destinationViewController].
    // Pass the selected object to the new view controller.
}
*/

@end
