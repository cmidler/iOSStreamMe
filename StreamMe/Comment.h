//
//  Comment.h
//  StreamMe
//
//  Created by Chase Midler on 6/11/15.
//  Copyright (c) 2015 StreamMe. All rights reserved.
//

#import <Foundation/Foundation.h>

@interface Comment : NSObject

@property (strong, nonatomic) NSString* text;
@property (strong, nonatomic) NSString* postingName;
@property (strong, nonatomic) NSDate* createdAt;
@property (strong, nonatomic) NSString* commentId;
@end
