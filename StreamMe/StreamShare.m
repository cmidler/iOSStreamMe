//
//  StreamShare.m
//  StreamMe
//
//  Created by Chase Midler on 6/11/15.
//  Copyright (c) 2015 StreamMe. All rights reserved.
//

#import "StreamShare.h"

@implementation StreamShare
- (StreamShare *) init {
    self = [super init];
    if (self) {
        _comments = [[NSMutableArray alloc] init];
        _likeValue = 0;
        _fixedImage = nil;
        _contentMode = UIViewContentModeScaleAspectFill;
    }
    return self;
}
@end
