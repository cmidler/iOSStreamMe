//
//  CBPeripheralInterface.h
//  Genesis
//
//  Created by Chase Midler on 9/4/14.
//  Copyright (c) 2014 Genesis. All rights reserved.
//


#import <Foundation/Foundation.h>
#import "MainDatabase.h"
#import <Parse/Parse.h>
#import "CharacteristicData.h"
//#import "Poll.h"
//#import "Event.h"

@interface CBPeripheralInterface : NSObject <CBPeripheralManagerDelegate>

- (void) startAdvertisingProfile;
- (void) stopAdvertisingProfile;
- (void) togglePeripheralOn;

@property (strong, nonatomic) NSString* userId;
@property (strong, nonatomic) CBPeripheralManager *peripheralManager;
//service arrays
@property (strong, nonatomic) NSArray* uuidArray;


//characteristic arrays
@property (strong, nonatomic) NSMutableArray* characteristicsArray;


//helper storage
@property (strong, nonatomic) NSMutableDictionary* centralsDict;
@property (strong, nonatomic) NSMutableDictionary* advertisedServices;

@property (nonatomic, readwrite) bool peripheralOn;

@end
