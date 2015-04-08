//
//  Event.h
//  Proximity
//
//  Created by Chase Midler on 11/6/14.
//  Copyright (c) 2014 midler. All rights reserved.
//

#import <Foundation/Foundation.h>

@interface Event : NSObject <NSCoding>

@property (strong, nonatomic) NSString* title;
@property (strong, nonatomic) NSString* event_uuid;
@property (nonatomic, readwrite) double start_time;
@property (nonatomic, readwrite) double end_time;
@property (nonatomic, readwrite) BOOL isPrivate;
//@property (strong, nonatomic) NSData* skin;
//@property (strong, nonatomic) NSData* logo;
//@property (strong, nonatomic) NSString* skin_title;
//@property (nonatomic, readwrite) int skin_length;
//@property (nonatomic, readwrite) int logo_length;
@property (nonatomic, readwrite) BOOL isSubscribed;
@end
