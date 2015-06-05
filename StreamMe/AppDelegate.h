//
//  AppDelegate.h
//  genesis
//
//  Created by Chase Midler on 9/3/14.
//  Copyright (c) 2014 midler. All rights reserved.
//

#import <UIKit/UIKit.h>
#import <Parse/Parse.h>
#import <ParseUI/ParseUI.h>
#import "MainNavigationViewController.h"
#import "CBCentralInterface.h"
#import "CBPeripheralInterface.h"
#import "MainDatabase.h"

#define GET_COUNT_TIMER 60
#define CHECK_FOR_USERS 90
@interface AppDelegate : UIResponder <UIApplicationDelegate>

- (void) resetCentralAndPeripheral;

@property (strong, nonatomic) CBCentralInterface* central;
@property (strong, nonatomic) CBPeripheralInterface* peripheral;
@property (strong, nonatomic) NSTimer* periodicTimer;
@property (strong, nonatomic) UIWindow *window;
@property (strong, nonatomic) NSMutableArray* streams;
@property (strong, nonatomic) NSTimer* timer;
@end
