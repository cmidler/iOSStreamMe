//
//  MainNavigationViewController.m
//  Proximity
//
//  Created by Chase Midler on 11/10/14.
//  Copyright (c) 2014 midler. All rights reserved.
//

#import "MainNavigationViewController.h"

@interface MainNavigationViewController ()

@end

@implementation MainNavigationViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    // Do any additional setup after loading the view.
    NSString *localPath = [[NSBundle mainBundle]bundlePath];
    NSString *imageName = [localPath stringByAppendingPathComponent:[[NSString alloc]initWithFormat:@"menu.png"]];
    UIImageView *image = [[UIImageView alloc] initWithImage:[UIImage imageWithContentsOfFile:imageName]];
    UIBarButtonItem *leftBarButton = [[UIBarButtonItem alloc] initWithCustomView:image];
    self.navigationItem.leftBarButtonItem = leftBarButton;
    [self.navigationItem.leftBarButtonItem setTintColor:[UIColor whiteColor]];
    [self.navigationBar setBarTintColor:[UIColor colorWithPatternImage:[UIImage imageNamed:@"BlueGradient.png"]]];
    //const CGFloat* colors = CGColorGetComponents( self.navigationBar.tintColor.CGColor );
    //NSLog(@"R = %f, G = %f, B = %f, alpha = %f", colors[0], colors[1], colors[2], colors[3]);
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

- (void)navigationController:(UINavigationController *)navigationController
      willShowViewController:(UIViewController *)viewController animated:(BOOL)animated
{
    [viewController viewWillAppear:animated];
}

- (void)navigationController:(UINavigationController *)navigationController
       didShowViewController:(UIViewController *)viewController animated:(BOOL)animated
{
    [viewController viewDidAppear:animated];
}

/*
#pragma mark - Navigation

// In a storyboard-based application, you will often want to do a little preparation before navigation
- (void)prepareForSegue:(UIStoryboardSegue *)segue sender:(id)sender {
    // Get the new view controller using [segue destinationViewController].
    // Pass the selected object to the new view controller.
}
*/

@end
