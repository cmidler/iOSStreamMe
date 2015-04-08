//
//  Work.m
//  Proximity
//
//  Created by Chase Midler on 1/7/15.
//  Copyright (c) 2015 midler. All rights reserved.
//

#import "Work.h"

@implementation Work
- (Work *) init {
    self = [super init];
    if (self) {
        _employer_name = [[NSString alloc] init];
        _position = [[NSString alloc] init];
        _end_date = [[NSString alloc]init];
        _work_id = [[NSString alloc]init];
        _isShowing = NO;
        
    }
    return self;
}

- (void)encodeWithCoder:(NSCoder *)coder {
    [coder encodeObject:_employer_name forKey:@"employer_name"];
    [coder encodeObject:_position forKey:@"position"];
    [coder encodeObject:_end_date forKey:@"end_date"];
    [coder encodeBool:_isShowing forKey:@"isShowing"];
}

- (id)initWithCoder:(NSCoder *)coder {
    self = [self init];
    self.employer_name = [coder decodeObjectForKey:@"employer_name"];
    self.position = [coder decodeObjectForKey:@"position"];
    self.end_date = [coder decodeObjectForKey:@"end_date"];
    self.isShowing = [coder decodeBoolForKey:@"isShowing"];
    return self;
}
@end
