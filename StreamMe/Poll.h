//
//  Poll.h
//  proximity
//
//  Created by Chase Midler on 10/6/14.
//  Copyright (c) 2014 midler. All rights reserved.
//

#import <Foundation/Foundation.h>

@interface Poll : NSObject <NSCoding>


@property (strong, nonatomic) NSString* question;
@property (strong, nonatomic) NSString* poll_uuid;
@property (nonatomic, readwrite) double start_time;
@property (strong, nonatomic) NSMutableArray* choices_and_votes;

@end
