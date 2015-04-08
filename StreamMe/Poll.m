//
//  Poll.m
//  proximity
//
//  Created by Chase Midler on 10/6/14.
//  Copyright (c) 2014 midler. All rights reserved.
//

#import "Poll.h"

@implementation Poll
- (Poll *) init {
    self = [super init];
    if (self) {
        _question = [[NSString alloc] init];
        _poll_uuid = [[NSString alloc] init];
        _choices_and_votes = [[NSMutableArray alloc] init];
    }
    return self;
}

- (void)encodeWithCoder:(NSCoder *)coder {
    [coder encodeObject:_poll_uuid forKey:@"poll_uuid"];
    [coder encodeObject:_question forKey:@"question"];
    [coder encodeDouble:_start_time forKey:@"start_time"];
    [coder encodeObject:_choices_and_votes forKey:@"choices_and_votes"];
}

- (id)initWithCoder:(NSCoder *)coder {
    self = [self init];
    self.poll_uuid = [coder decodeObjectForKey:@"poll_uuid"];
    self.question    = [coder decodeObjectForKey:@"question"];
    self.start_time = [coder decodeDoubleForKey:@"start_time"];
    self.choices_and_votes = [coder decodeObjectForKey:@"choices_and_votes"];
    return self;
}

@end
