//
//  TopToBottomSegue.m
//  WhoYu
//
//  Created by Chase Midler on 3/26/15.
//  Copyright (c) 2015 midler. All rights reserved.
//

#import "TopToBottomSegue.h"

@implementation TopToBottomSegue
-(void)perform {
    
    __block UIViewController *sourceViewController = (UIViewController*)[self sourceViewController];
    
    CATransition* transition = [CATransition animation];
    transition.duration = .5;
    transition.timingFunction = [CAMediaTimingFunction functionWithName:kCAMediaTimingFunctionEaseInEaseOut];
    transition.type = kCATransitionReveal; //kCATransitionMoveIn; //, kCATransitionPush, kCATransitionReveal, kCATransitionFade
    transition.subtype = kCATransitionFromBottom; //kCATransitionFromLeft, kCATransitionFromRight, kCATransitionFromTop, kCATransitionFromBottom
    
    
    
    [sourceViewController.navigationController.view.layer addAnimation:transition
                                                                forKey:kCATransition];
    
    [sourceViewController.navigationController popViewControllerAnimated:NO];
    
    
}
@end
