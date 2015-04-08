//
//  CBPeripheralSubclass.h
//  WhoYu
//
//  Created by Chase Midler on 4/3/15.
//  Copyright (c) 2015 midler. All rights reserved.
//

#import <CoreBluetooth/CoreBluetooth.h>

@interface CBPeripheralSubclass : CBPeripheral
@property (strong, readwrite) NSUUID* identifier;
@end
