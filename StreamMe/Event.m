//
//  Event.m
//  Proximity
//
//  Created by Chase Midler on 11/6/14.
//  Copyright (c) 2014 midler. All rights reserved.
//

#import "Event.h"

@implementation Event
- (Event *) init {
    self = [super init];
    if (self) {
        _title = [[NSString alloc] init];
        _event_uuid = [[NSString alloc] init];
        /*_skin_title = [[NSString alloc] init];
        _skin = [[NSData alloc] init];
        _logo = [[NSData alloc] init];*/
    }
    return self;
}

- (void)encodeWithCoder:(NSCoder *)coder {
    [coder encodeObject:_event_uuid forKey:@"event_uuid"];
    [coder encodeObject:_title forKey:@"title"];
    [coder encodeDouble:_start_time forKey:@"start_time"];
    [coder encodeDouble:_end_time forKey:@"end_time"];
    [coder encodeBool:_isPrivate forKey:@"isPrivate"];
    /*[coder encodeObject:_skin_title forKey:@"skin_title"];
    [coder encodeObject:_skin forKey:@"skin"];
    [coder encodeObject:_logo forKey:@"logo"];
    [coder encodeInt:_logo_length forKey:@"logo_length"];
    [coder encodeInt:_skin_length forKey:@"skin_length"];*/
    [coder encodeBool:_isSubscribed forKey:@"isSubscribed"];
    
}

- (id)initWithCoder:(NSCoder *)coder {
    self = [self init];
    self.event_uuid = [coder decodeObjectForKey:@"event_uuid"];
    self.title    = [coder decodeObjectForKey:@"title"];
    self.start_time = [coder decodeDoubleForKey:@"start_time"];
    self.end_time = [coder decodeDoubleForKey:@"end_time"];
    self.isPrivate = [coder decodeBoolForKey:@"isPrivate"];
    /*self.skin    = [coder decodeObjectForKey:@"skin"];
    self.skin_title    = [coder decodeObjectForKey:@"skin_title"];
    self.logo    = [coder decodeObjectForKey:@"logo"];
    self.skin_length = [coder decodeIntForKey:@"skin_length"];
    self.logo_length = [coder decodeIntForKey:@"logo_length"];*/
    self.isSubscribed = [coder decodeBoolForKey:@"isSubscribed"];
    return self;
}
@end
