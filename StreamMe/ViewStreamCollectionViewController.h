//
//  ViewStreamCollectionViewController.h
//  WhoYu
//
//  Created by Chase Midler on 3/30/15.
//  Copyright (c) 2015 midler. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "ViewStreamCollectionViewCell.h"
#import "StreamCollectionViewController.h"
#import "AppDelegate.h"
#import "Stream.h"
#import "ShowCommentsViewController.h"

#define END_LOADING_SHARE_TAG 1111
#define QUICK_TYPE_OFFSET 29
//#define SHARES_PER_PAGE 25

@interface ViewStreamCollectionViewController : UICollectionViewController<UITextFieldDelegate>


    
@property (strong, nonatomic) NSMutableArray* streamShares;
@property (strong, nonatomic) Stream* streamObject;
@property (strong, nonatomic) UIViewController* showCommentsViewController;
@property (strong, nonatomic) UITableViewController *commentsViewController;
@property (nonatomic, readwrite) NSInteger currentRow;
@property (strong, nonatomic) IBOutlet UICollectionView *streamCollectionView;
@property (nonatomic, readwrite) bool navigationHidden;
@property (nonatomic, readwrite) bool reloadingData;
@property (nonatomic, readwrite) bool initialScrollDone;
@property (strong, nonatomic) UIToolbar* toolBar;
@property (strong, nonatomic) UIView* lineView;
@property (strong, nonatomic) UIBarButtonItem *composeComment;
@property (strong, nonatomic) UIView* commentView;
@property (strong, nonatomic) UITextField* commentTextField;
@property (strong, nonatomic) UIButton* cancelCommentButton;
@property (nonatomic, readwrite) CGPoint originalCenter;
@property (nonatomic, readwrite) bool didShowKeyboard;


@end
