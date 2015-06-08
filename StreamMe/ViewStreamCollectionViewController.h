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

#define TOOLBAR_HEIGHT 44
#define END_LOADING_SHARE_TAG 1111
//#define SHARES_PER_PAGE 25

@interface ViewStreamCollectionViewController : UICollectionViewController
{
    NSMutableArray* streamShares;
}
@property (strong, nonatomic) Stream* streamObject;
@property (nonatomic, readwrite) NSInteger currentRow;
@property (strong, nonatomic) IBOutlet UICollectionView *streamCollectionView;
@property (nonatomic, readwrite) bool navigationHidden;
@property (nonatomic, readwrite) bool reloadingData;
@property (nonatomic, readwrite) bool initialScrollDone;
@end
