//
//  StreamShare.h
//  StreamMe
//
//  Created by Chase Midler on 6/11/15.
//  Copyright (c) 2015 StreamMe. All rights reserved.
//

#import <Foundation/Foundation.h>
#import <Parse/Parse.h>
#import "Comment.h"
@interface StreamShare : NSObject
@property (strong, nonatomic) PFObject* streamShare;
@property (strong, nonatomic) NSMutableArray* comments;
 
@end
