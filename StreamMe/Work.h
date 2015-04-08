//
//  Work.h
//  Proximity
//
//  Created by Chase Midler on 1/7/15.
//  Copyright (c) 2015 midler. All rights reserved.
//

#import <Foundation/Foundation.h>

@interface Work : NSObject<NSCoding>
@property (strong, nonatomic) NSString* employer_name;
@property (strong, nonatomic) NSString* position;
@property (strong, nonatomic) NSString* end_date;
@property (strong, nonatomic) NSString* work_id;
@property (nonatomic, readwrite) bool isShowing;
@end
