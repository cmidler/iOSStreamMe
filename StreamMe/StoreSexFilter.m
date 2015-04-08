//
//  StoreSexFilter.m
//  genesis
//
//  Created by Chase Midler on 10/1/14.
//  Copyright (c) 2014 midler. All rights reserved.
//

#import "StoreSexFilter.h"

@implementation StoreSexFilter
static StoreSexFilter *shared = nil;
@synthesize sex_filter;

+(StoreSexFilter*) shared
{
    @synchronized(self)
    {
        if(shared==nil)
            shared = [[self alloc ] init];
    }
    return shared;
}
@end
