//
//  PopoverViewController.m
//  StreamMe
//
//  Created by Chase Midler on 5/4/15.
//  Copyright (c) 2015 StreamMe. All rights reserved.
//

#import "PopoverViewController.h"

@interface PopoverViewController ()

@end

@implementation PopoverViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    // Do any additional setup after loading the view.
    UITapGestureRecognizer *labelTap =  [[UITapGestureRecognizer alloc] initWithTarget:self action:@selector(labelTapped:)];
    labelTap.numberOfTapsRequired = 1;
    [_popoverLabel setUserInteractionEnabled:YES];
    [_popoverLabel addGestureRecognizer:labelTap];
}

-(void) labelTapped:(id) sender
{
    //UIPopoverPresentationController* pop = (UIPopoverPresentationController*)self;
    
    [self dismissViewControllerAnimated:YES completion:NULL];
    //put notification down
    [[NSNotificationCenter defaultCenter] postNotificationName:@"popoverDismissed" object:self];
    //[self performSegueWithIdentifier:@"popSegue" sender:self];
}


- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

@end
