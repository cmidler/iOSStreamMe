//
//  CharacteristicData.h
//  genesis
//
//  Created by Chase Midler on 9/5/14.
//  Copyright (c) 2014 midler. All rights reserved.
//

#import <Foundation/Foundation.h>
#import <CoreBluetooth/CoreBluetooth.h>
#import "SERVICES.h"
@interface CharacteristicData : NSObject
@property (strong, nonatomic) NSData *dataToSend;
@property (nonatomic, readwrite) NSInteger sendDataIndex;
@property (nonatomic, readwrite) BOOL eomSent;
@property (nonatomic, readwrite) NSInteger centralMaximumUpdateValueLength;
@property (strong, nonatomic) CBCharacteristic* characteristic;
@end
