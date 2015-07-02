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

- (BOOL)shouldAutorotate
{
    [super shouldAutorotate];
    return NO;
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




/*- (void) touchesBegan:(NSSet *)touches withEvent:(UIEvent *)event{
    NSLog(@"touch count is %d", (int) ((UITouch*)[touches anyObject]).tapCount);
}*/


-(void)handleSingleTap
{
    NSLog(@"tapCount 1");
    self.takingVideo = NO;
    self.canTakePicture = NO;
    [self takePicture];
}

-(void)handleDoubleTap
{
    NSLog(@"tapCount 2");
    self.takingVideo = YES;
    //self.canTakePicture = NO;
    [self startVideoCapture];
}


- (void)touchesEnded:(NSSet *)touches withEvent:(UIEvent *)event {
    
    
    //see if I can take pictures or not
    if(!_canTakePicture)
    {
        //on touch event fire dismissing picker
        [[NSNotificationCenter defaultCenter] postNotificationName:@"dismissPickerEvent" object:self userInfo:nil];
        return;
    }
    
    
    [self performSelector:@selector(handleSingleTap) withObject:nil ];
    /*NSUInteger numTaps = [[touches anyObject] tapCount];
    float delay = 0.3;
    if (numTaps < 2)
    {
        [self performSelector:@selector(handleSingleTap) withObject:nil afterDelay:delay ];
        [self.nextResponder touchesEnded:touches withEvent:event];
    }
    else if(numTaps == 2)
    {
        [NSObject cancelPreviousPerformRequestsWithTarget:self];
        [self performSelector:@selector(handleDoubleTap) withObject:nil afterDelay:delay ];
    }
    
    return;
    
    
    // so tapping the screen will take a picture
    UITouch *touch = [touches anyObject];
    
    NSLog(@"tap count is %d", (int)touches.count);
    
    //todo stop video early
    
    
    
    
    if (touch.tapCount == 1) {
        //self.cameraCaptureMode = UIImagePickerControllerCameraCaptureModeVideo;
        self.takingVideo = NO;
        _canTakePicture = NO;
        [self takePicture];
    }
    else if(touch.tapCount == 2)
    {
        self.takingVideo = YES;
        self.videoMaximumDuration = 5.0f;
        self.videoQuality = UIImagePickerControllerQualityTypeHigh;
        self.mediaTypes = [NSArray arrayWithObject:(NSString *)kUTTypeMovie];
        [self startVideoCapture];
    }
    else
        [super touchesEnded:touches withEvent:event];
    */
}

- (UIModalPresentationStyle)adaptivePresentationStyleForPresentationController:(UIPresentationController *)controller {
    NSLog(@"in custom picker adaptivepresentation");
    return UIModalPresentationNone;
}

- (void)popoverPresentationControllerDidDismissPopover:(UIPopoverPresentationController *)popoverPresentationController
{
    [[NSNotificationCenter defaultCenter] postNotificationName:@"dismissCameraPopover" object:self userInfo:nil];
}



@end
