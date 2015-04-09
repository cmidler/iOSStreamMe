//
//  BluetoothProfile.h
//  genesis
//
//  Created by Chase Midler on 9/5/14.
//  Copyright (c) 2014 midler. All rights reserved.
//

#import <Foundation/Foundation.h>
#import <CoreBluetooth/CoreBluetooth.h>
#define RSSI_COUNT 25

@interface BluetoothProfile : NSObject //<NSCoding>
@property (nonatomic, readwrite) BOOL isMarkedForDelete;
@property (nonatomic, readwrite) BOOL isMarkedAsOld;
//@property (nonatomic, readwrite) double timestamp;
//@property (nonatomic, readwrite) double initialTime;
//@property (nonatomic, readwrite) BOOL isConnectedProfile;
@property (strong, nonatomic) NSMutableDictionary* dataDict;
@property (strong, nonatomic) CBPeripheral* peripheral;
//@property (nonatomic, readwrite) BOOL hasUserId;
@property (strong, nonatomic) NSString* user_id;



@end