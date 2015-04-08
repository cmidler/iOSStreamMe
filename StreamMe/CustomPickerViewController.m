//
//  CustomPickerViewController.m
//  WhoYu
//
//  Created by Chase Midler on 3/26/15.
//  Copyright (c) 2015 midler. All rights reserved.
//

#import "CustomPickerViewController.h"

@interface CustomPickerViewController ()

@end

@implementation CustomPickerViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    // Do any additional setup after loading the view.
    _canTakePicture = YES;
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

- (BOOL)canBecomeFirstResponder
{
    return YES;
}

- (void)motionEnded:(UIEventSubtype)motion withEvent:(UIEvent *)event
{
    //shake gesture
    if (motion == UIEventSubtypeMotionShake)
    {
        NSLog(@"dismiss camera");
        //on touch event fire dismissing picker
        [[NSNotificationCenter defaultCenter] postNotificationName:@"dismissCameraEvent" object:self userInfo:nil];
    }
}


- (void)touchesEnded:(NSSet *)touches withEvent:(UIEvent *)event {
    //see if I can take pictures or not
    if(!_canTakePicture)
    {
        //on touch event fire dismissing picker
        [[NSNotificationCenter defaultCenter] postNotificationName:@"dismissPickerEvent" object:self userInfo:nil];
        return;
    }
    // override the touches ended method
    // so tapping the screen will take a picture
    UITouch *touch = [touches anyObject];
    if (touch.tapCount == 1) {
        [self takePicture];
    }
    else
        [super touchesEnded:touches withEvent:event];
    
}



@end
