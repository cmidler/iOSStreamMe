//
//  PassthroughView.m
//  StreamMe
//
//  Created by Chase Midler on 5/6/15.
//  Copyright (c) 2015 StreamMe. All rights reserved.
//

#import "PassthroughView.h"

@implementation PassthroughView

/*
// Only override drawRect: if you perform custom drawing.
// An empty implementation adversely affects performance during animation.
- (void)drawRect:(CGRect)rect {
    // Drawing code
}
*/
-(BOOL)pointInside:(CGPoint)point withEvent:(UIEvent *)event {
    for (UIView *view in self.subviews) {
        if (!view.hidden && view.alpha > 0 && view.userInteractionEnabled && [view pointInside:[self convertPoint:point toView:view] withEvent:event])
            return YES;
    }
    return NO;
}
@end
