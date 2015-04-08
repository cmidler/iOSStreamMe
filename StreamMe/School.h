//
//  School.h
//  Proximity
//
//  Created by Chase Midler on 1/7/15.
//  Copyright (c) 2015 midler. All rights reserved.
//

#import <Foundation/Foundation.h>
@interface School : NSObject<NSCoding>

@property (strong,nonatomic) NSString* school_name;
@property (strong, nonatomic) NSString* year;
@property (strong, nonatomic) NSString* type;
@property (strong, nonatomic) NSString* school_id;
@property (strong,nonatomic) NSMutableArray* degrees;

@property (nonatomic, readwrite) bool isShowing;
@end
