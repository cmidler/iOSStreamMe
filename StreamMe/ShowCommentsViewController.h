//
//  ShowCommentsViewController.h
//  StreamMe
//
//  Created by Chase Midler on 6/9/15.
//  Copyright (c) 2015 StreamMe. All rights reserved.
//

#import <UIKit/UIKit.h>
#import <Parse/Parse.h>
#import "ShowCommentsTableViewCell.h"
#import "ViewStreamCollectionViewController.h"
#import "Stream.h"
#define MAX_COMMENT_CHARS 140
#define TOOLBAR_HEIGHT 44
@interface ShowCommentsViewController : UIViewController

-(void) redoHeight;
@property (strong, nonatomic) NSMutableArray* comments;
@property (weak, nonatomic) IBOutlet UIView *commentView;
@property (weak, nonatomic) IBOutlet UITextField *commentTextField;
@property (weak, nonatomic) IBOutlet UIButton *cancelCommentButton;
@property (weak, nonatomic) IBOutlet UITableView *commentsTableView;
@property (strong, nonatomic) PFObject* streamShare;
@property (weak, nonatomic) IBOutlet NSLayoutConstraint *tableViewHeightConstraint;
@property (nonatomic, readwrite) float keyboardHeight;
@property (nonatomic, readwrite) bool didShowKeyboard;
- (IBAction)cancelComment:(id)sender;


@end
