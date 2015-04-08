//
//  StorePrivateProfile.m
//  WhoYu
//
//  Created by Chase Midler on 1/26/15.
//  Copyright (c) 2015 midler. All rights reserved.
//

#import "StorePrivateProfile.h"

@implementation StorePrivateProfile
static StorePrivateProfile *shared = nil;
@synthesize profile;

+(StorePrivateProfile*) shared
{
    @synchronized(self)
    {
        if(shared==nil)
            shared = [[self alloc ] init];
    }
    return shared;
}

@end
