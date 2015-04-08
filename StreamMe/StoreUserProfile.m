//
//  StoreUserProfile.m
//  genesis
//
//  Created by Chase Midler on 9/4/14.
//  Copyright (c) 2014 midler. All rights reserved.
//

#import "StoreUserProfile.h"

@implementation StoreUserProfile
static StoreUserProfile *shared = nil;
@synthesize profile;

+(StoreUserProfile*) shared
{
    @synchronized(self)
    {
        if(shared==nil)
            shared = [[self alloc ] init];
    }
    return shared;
}

@end
