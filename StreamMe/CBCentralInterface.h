//
//  CBCentralInterface.h
//  Genesis
//
//  Created by Chase Midler on 9/4/14.
//  Copyright (c) 2014 Genesis. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "MainDatabase.h"
#import "SERVICES.h"
#import "BluetoothProfile.h"
#import "StoreUserProfile.h"
#import "CBPeripheralSubclass.h"
//#import "Poll.h"
//#import "Event.h"

#define DOWNLOAD_TIME 10 //Need to be able to download events/polls over bluetooth
#define TIMEOUT_TIME 1200 //Timeout if I don't get the user id again after 20 minutes
//#define RESET_TIME 90
#define POLL_TIME 35
#define EVENT_TIME 180
#define QUERY_USER_TIME 5
#define MAX_DATA_SIZE 25000
@interface CBCentralInterface : NSObject <CBCentralManagerDelegate, CBPeripheralDelegate>

- (void) startScanningForUserProfiles;
- (void) stopScanningForUserProfiles;
- (void)cleanup:(NSString*)UUID;
- (void) toggleCentralOn;
- (bool) getBluetoothOnValue;
@property (strong, nonatomic) CBCentralManager *centralManager;
@property (strong, nonatomic) NSMutableDictionary *bluetoothProfiles;
//@property (strong, nonatomic) NSTimer* timer;
//@property (nonatomic, readwrite) int isScanning;
//@property (nonatomic, readwrite) int isConnected;
//@property (nonatomic, readwrite) double lastQueryTime;
@property (nonatomic, readwrite) bool centralOn;
@property (nonatomic, readwrite) bool bluetoothOn;
@end
