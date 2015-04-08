//
//  ProfessionalProfile.m
//  Proximity
//
//  Created by Chase Midler on 1/7/15.
//  Copyright (c) 2015 midler. All rights reserved.
//

#import "ProfessionalProfile.h"

@implementation ProfessionalProfile
- (ProfessionalProfile *) init {
    self = [super init];
    if (self) {
        _schools = [[NSMutableArray alloc] init];
        _works = [[NSMutableArray alloc] init];
        _user_id = [[NSString alloc]init];
        _isComplete = NO;
        _isShowing = YES;
    }
    return self;
}

- (void)encodeWithCoder:(NSCoder *)coder {
    [coder encodeObject:_schools forKey:@"schools"];
    [coder encodeObject:_works forKey:@"works"];
    [coder encodeObject:_user_id forKey:@"user_id"];
    [coder encodeBool:_isShowing forKey:@"isShowing"];
    
}

- (id)initWithCoder:(NSCoder *)coder {
    self = [self init];
    self.schools = [coder decodeObjectForKey:@"schools"];
    self.works = [coder decodeObjectForKey:@"works"];
    self.user_id = [coder decodeObjectForKey:@"user_id"];
    self.isShowing = [coder decodeBoolForKey:@"isShowing"];
    return self;
}
@end
