//
//  MainTableViewCell.m
//  genesis
//
//  Created by Chase Midler on 9/3/14.
//  Copyright (c) 2014 midler. All rights reserved.
//

#import "MainTableViewCell.h"

@implementation MainTableViewCell

- (id)initWithStyle:(UITableViewCellStyle)style reuseIdentifier:(NSString *)reuseIdentifier
{
    self = [super initWithStyle:style reuseIdentifier:reuseIdentifier];
    if (self) {
        // Initialization code
    }
    return self;
}

- (void)awakeFromNib
{
    // Initialization code
}

- (void)setSelected:(BOOL)selected animated:(BOOL)animated
{
    //[super setSelected:selected animated:animated];
    NSLog(@"set selected!!!");
    // Configure the view for the selected state
}

-(void) setHighlighted:(BOOL)selected animated:(BOOL)animated
{
    // set highlighted
    NSLog(@"set highlighted!!!");
}

-(void)setCollectionViewDataSourceDelegate:(id<UICollectionViewDataSource, UICollectionViewDelegate>)dataSourceDelegate index:(NSInteger)index
{
    self.streamCollectionView.dataSource = dataSourceDelegate;
    self.streamCollectionView.delegate = dataSourceDelegate;
    self.streamCollectionView.tag = index;
    self.streamCollectionView.alwaysBounceHorizontal = YES;
    [self.streamCollectionView reloadData];
}


@end
