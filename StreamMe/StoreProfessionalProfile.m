//
//  StoreProfessionalProfile.m
//  Proximity
//
//  Created by Chase Midler on 1/7/15.
//  Copyright (c) 2015 midler. All rights reserved.
//

#import "StoreProfessionalProfile.h"

@implementation StoreProfessionalProfile
static StoreProfessionalProfile *shared = nil;
@synthesize profile;

+(StoreProfessionalProfile*) shared
{
    @synchronized(self)
    {
        if(shared==nil)
            shared = [[self alloc ] init];
    }
    return shared;
}

@end
