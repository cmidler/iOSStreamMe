//
//  CharacteristicData.m
//  genesis
//
//  Created by Chase Midler on 9/5/14.
//  Copyright (c) 2014 midler. All rights reserved.
//

#import "CharacteristicData.h"

@implementation CharacteristicData
- (CharacteristicData *) init {
    self = [super init];
    if (self) {
        _eomSent = YES;
        _sendDataIndex = 0;
        _dataToSend = [[NSMutableData alloc]init];
        _centralMaximumUpdateValueLength = NOTIFY_MTU;
        _characteristic = nil;
    }
    return self;
}
@end
