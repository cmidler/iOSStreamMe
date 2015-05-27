//
//  SelectStreamsTableViewController.h
//  WhoYu
//
//  Created by Chase Midler on 4/1/15.
//  Copyright (c) 2015 midler. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "SelectStreamsTableViewCell.h"
#import "AppDelegate.h"
#import "Stream.h"
#define TITLE_HEIGHT 44
@interface SelectStreamsTableViewController : UITableViewController
{
    NSMutableArray* streams;
}

@property (strong, nonatomic) IBOutlet UITableView *streamsTableView;
@property (strong, nonatomic) NSString* captionText;
@property (strong, nonatomic) NSData* imageData;
@property (strong, nonatomic) CLLocation* currentLocation;
@end
