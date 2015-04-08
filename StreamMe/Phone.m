//
//  Phone.m
//  WhoYu
//
//  Created by Chase Midler on 1/27/15.
//  Copyright (c) 2015 midler. All rights reserved.
//

#import "Phone.h"

@implementation Phone
- (Phone *) init {
    self = [super init];
    if (self) {
        _type = [[NSString alloc] init];
        _number = [[NSString alloc] init];
        _phone_id = [[NSString alloc] init];
    }
    return self;
}
@end
