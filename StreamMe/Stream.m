//
//  Stream.m
//  WhoYu
//
//  Created by Chase Midler on 4/1/15.
//  Copyright (c) 2015 midler. All rights reserved.
//

#import "Stream.h"

@implementation Stream
- (Stream *) init {
    self = [super init];
    if (self) {
        _streamShares = [[NSMutableArray alloc] init];
        _totalShares = 1;
        _currentShareIndex = 0;
        _offset = 0;
        _isDownloadingPrevious = NO;
        _isDownloadingAfter = NO;
        _thumbnail = nil;
    }
    return self;
}
@end
