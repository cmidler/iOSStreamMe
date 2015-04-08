//
//  Stream.h
//  WhoYu
//
//  Created by Chase Midler on 4/1/15.
//  Copyright (c) 2015 midler. All rights reserved.
//

#import <Foundation/Foundation.h>
#import <Parse/Parse.h>
@interface Stream : NSObject

@property (strong,nonatomic) PFObject* stream;
@property (strong, nonatomic) NSMutableArray* streamShares;
@property (nonatomic, readwrite) NSInteger totalShares;
@property (nonatomic, readwrite) NSInteger totalViewers;
@property (strong, nonatomic) NSString* username;
@property (nonatomic, readwrite) NSInteger currentShareIndex;
@property (nonatomic, readwrite) NSInteger offset;
@property (strong, nonatomic) NSDate* newestShareCreationTime;
@property (nonatomic, readwrite) BOOL isDownloadingPrevious;
@property (nonatomic, readwrite) BOOL isDownloadingAfter;
@end
