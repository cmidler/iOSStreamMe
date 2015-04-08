//
//  MainDatabase.m
//  WhoYu
//
//  Created by Chase Midler on 2/14/15.
//  Copyright (c) 2015 midler. All rights reserved.
//

#import "MainDatabase.h"

@implementation MainDatabase
static MainDatabase *shared = nil;
@synthesize queue;

+(MainDatabase*) shared
{
    @synchronized(self)
    {
        if(shared==nil)
            shared = [[self alloc ] init];
    }
    return shared;
}

/* Initialize the variables for the main database*/
- (id)init {
    if (self = [super init]) {
        NSString *docsDir;
        NSArray *dirPaths;
        
        // Get the documents directory
        dirPaths = NSSearchPathForDirectoriesInDomains(NSDocumentDirectory, NSUserDomainMask, YES);
        docsDir = dirPaths[0];
        
        // Build the path to the database file
        NSString* databasePath = [[NSString alloc]
                                  initWithString: [docsDir stringByAppendingPathComponent:
                                                   @"main.db"]];
        
        queue = [FMDatabaseQueue databaseQueueWithPath:databasePath];

    }
    return self;
}
@end
