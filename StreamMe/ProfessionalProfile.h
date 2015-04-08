//
//  ProfessionalProfile.h
//  Proximity
//
//  Created by Chase Midler on 1/7/15.
//  Copyright (c) 2015 midler. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "Work.h"
#import "School.h"

@interface ProfessionalProfile : NSObject <NSCoding>
@property (strong, nonatomic) NSMutableArray* schools;
@property (strong, nonatomic) NSMutableArray* works;
@property (strong, nonatomic) NSString* user_id;

@property (nonatomic, readwrite) bool isShowing;
@property (nonatomic, readwrite) bool isComplete;
@end
