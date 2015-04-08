//
//  Email.m
//  WhoYu
//
//  Created by Chase Midler on 1/27/15.
//  Copyright (c) 2015 midler. All rights reserved.
//

#import "Email.h"

@implementation Email
- (Email *) init {
    self = [super init];
    if (self) {
        _type = [[NSString alloc] init];
        _address = [[NSString alloc] init];
        _email_id = [[NSString alloc] init];
    }
    return self;
}
@end
