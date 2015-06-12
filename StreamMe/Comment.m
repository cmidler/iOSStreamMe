//
//  Comment.m
//  StreamMe
//
//  Created by Chase Midler on 6/11/15.
//  Copyright (c) 2015 StreamMe. All rights reserved.
//

#import "Comment.h"

@implementation Comment

- (Comment *) init {
    self = [super init];
    if (self) {
        _text = [[NSString alloc] init];
        _postingName = [[NSString alloc]init];
        _commentId = [[NSString alloc] init];
    }
    return self;
}

@end
