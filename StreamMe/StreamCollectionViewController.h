//
//  StreamCollectionViewController.h
//  StreamMe
//
//  Created by Chase Midler on 5/29/15.
//  Copyright (c) 2015 StreamMe. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "StreamCollectionViewCell.h"
#import "MainTableViewController.h"
#import "ViewStreamCollectionViewController.h"
#import "Stream.h"

#define SHARES_PER_PAGE 25
@interface StreamCollectionViewController : UICollectionViewController
{
    NSMutableArray* streamShares;
}

@property (strong, nonatomic) IBOutlet UICollectionView *streamCollectionView;
@property (strong, nonatomic) Stream* streamObject;
@property (nonatomic, readwrite) NSInteger currentRow;
@property (nonatomic, readwrite) bool navigationHidden;
@property (nonatomic, readwrite) bool reloadingData;
@property (nonatomic, readwrite) bool initialScrollDone;
@property (nonatomic, readwrite) int sortBy;
@property (nonatomic, readwrite) int selectedCellIndex;
@end
