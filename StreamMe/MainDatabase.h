//
//  MainDatabase.h
//  WhoYu
//
//  Created by Chase Midler on 2/14/15.
//  Copyright (c) 2015 midler. All rights reserved.
//

#import <Foundation/Foundation.h>
#import <FMDB/FMDatabase.h>
#import <FMDB/FMDatabaseQueue.h>
#import <FMDB/FMDatabaseAdditions.h>
@interface MainDatabase : NSObject
{
    FMDatabaseQueue *queue;
}

@property FMDatabaseQueue *queue;
+ (MainDatabase *) shared;
@end
