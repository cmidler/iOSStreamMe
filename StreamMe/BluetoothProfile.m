//
//  BluetoothProfile.m
//  genesis
//
//  Created by Chase Midler on 9/5/14.
//  Copyright (c) 2014 midler. All rights reserved.
//

#import "BluetoothProfile.h"

@implementation BluetoothProfile
- (BluetoothProfile *) init {
    self = [super init];
    if (self) {
        _isMarkedForDelete = NO;
        _isMarkedAsOld = NO;
        //_profileListRank = 0;
        _dataDict = [[NSMutableDictionary alloc]init];
        //_isConnectedProfile = NO;
        //_hasUserId = NO;
        _user_id = [[NSString alloc]init];
        _peripheral = nil;
        
        
    }
    return self;
}


@end
