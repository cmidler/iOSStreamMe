//
//  EditPrivateProfileTableViewController.h
//  WhoYu
//
//  Created by Chase Midler on 1/26/15.
//  Copyright (c) 2015 midler. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "EditPrivateProfileTableViewCell.h"
@interface EditPrivateProfileTableViewController : UITableViewController
{
    NSArray* types;
}
@property (strong, nonatomic) IBOutlet UITableView *privateTableView;
@end
