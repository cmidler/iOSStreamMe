//
//  PrivateProfile.m
//  WhoYu
//
//  Created by Chase Midler on 1/26/15.
//  Copyright (c) 2015 midler. All rights reserved.
//

#import "PrivateProfile.h"

@implementation PrivateProfile
- (PrivateProfile *) init {
    self = [super init];
    if (self) {
        _emailAddresses = [[NSMutableArray alloc] init];
        _phoneNumbers = [[NSMutableArray alloc] init];
    }
    return self;
}
@end
