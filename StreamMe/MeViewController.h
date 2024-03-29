//
//  MeViewController.h
//  WhoYu
//
//  Created by Chase Midler on 3/26/15.
//  Copyright (c) 2015 midler. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "MeTableViewCell.h"
#import <Parse/Parse.h>
#define LEVEL_ONE_POINTS   100
#define LEVEL_TWO_POINTS   1000
#define LEVEL_THREE_POINTS 5000
#define LEVEL_FOUR_POINTS  10000
#define LEVEL_FIVE_POINTS  20000
#define LEVEL_SIX_POINTS   32500
#define LEVEL_SEVEN_POINTS 50000
#define LEVEL_EIGHT_POINTS 75000
#define LEVEL_NINE_POINTS  125000

#define LEVEL_ONE   "Noob"
#define LEVEL_TWO   "Upstart"
#define LEVEL_THREE "You have some skill"
#define LEVEL_FOUR  "Gettin' there"
#define LEVEL_FIVE  "Selfie master"
#define LEVEL_SIX   "The real deal"
#define LEVEL_SEVEN "That's excessive"
#define LEVEL_EIGHT "Stream pillager"
#define LEVEL_NINE  "Too Powerful"
#define LEVEL_TEN   "Wow... just wow."
#define MAX_NAME_CHARS 24
#define TITLE_HEIGHT 44


@interface MeViewController : UIViewController
{
    NSArray* meArray;
}

@property (weak, nonatomic) IBOutlet UITableView *meTableView;
@property (nonatomic, readwrite) NSInteger points;
@property (nonatomic, readwrite) bool spinnerActive;
@property (strong, nonatomic) NSString* name;
@end
