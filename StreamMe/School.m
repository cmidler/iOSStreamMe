//
//  School.m
//  Proximity
//
//  Created by Chase Midler on 1/7/15.
//  Copyright (c) 2015 midler. All rights reserved.
//

#import "School.h"

@implementation School
- (School *) init {
    self = [super init];
    if (self) {
        _school_name = [[NSString alloc] init];
        _year = [[NSString alloc] init];
        _type = [[NSString alloc]init];
        _degrees = [[NSMutableArray alloc]init];
        _school_id = [[NSString alloc] init];
        _isShowing = NO;
    }
    return self;
}

- (void)encodeWithCoder:(NSCoder *)coder {
    [coder encodeObject:_school_name forKey:@"school_name"];
    [coder encodeObject:_year forKey:@"year"];
    [coder encodeObject:_type forKey:@"type"];
    [coder encodeObject:_degrees forKey:@"degrees"];
    [coder encodeBool:_isShowing forKey:@"isShowing"];
}

- (id)initWithCoder:(NSCoder *)coder {
    self = [self init];
    self.school_name = [coder decodeObjectForKey:@"school_name"];
    self.year = [coder decodeObjectForKey:@"year"];
    self.type = [coder decodeObjectForKey:@"type"];
    self.degrees = [coder decodeObjectForKey:@"degrees"];
    self.isShowing = [coder decodeBoolForKey:@"isShowing"];
    return self;
}

@end
