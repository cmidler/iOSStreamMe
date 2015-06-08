//
//  PopToRootSlideSegue.m
//  StreamMe
//
//  Created by Chase Midler on 6/8/15.
//  Copyright (c) 2015 StreamMe. All rights reserved.
//

#import "PopToRootSlideSegue.h"

@implementation PopToRootSlideSegue
-(void)perform {
    
    __block UIViewController *sourceViewController = (UIViewController*)[self sourceViewController];
    
    CATransition* transition = [CATransition animation];
    transition.duration = .5;
    transition.timingFunction = [CAMediaTimingFunction functionWithName:kCAMediaTimingFunctionEaseInEaseOut];
    transition.type = kCATransitionPush; //kCATransitionMoveIn; //, kCATransitionPush, kCATransitionReveal, kCATransitionFade
    transition.subtype = kCATransitionFromLeft; //kCATransitionFromLeft, kCATransitionFromRight, kCATransitionFromTop, kCATransitionFromBottom
    
    
    
    [sourceViewController.navigationController.view.layer addAnimation:transition
                                                                forKey:kCATransition];
    
    [sourceViewController.navigationController popToRootViewControllerAnimated:NO];
    
    
}
@end
