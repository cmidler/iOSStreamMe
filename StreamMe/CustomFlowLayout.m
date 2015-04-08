//
//  CustomFlowLayout.m
//  WhoYu
//
//  Created by Chase Midler on 3/31/15.
//  Copyright (c) 2015 midler. All rights reserved.
//

#import "CustomFlowLayout.h"

@implementation CustomFlowLayout

// a change to do initialization or pre-determined layout for cells
- (void)prepareLayout {
    CGRect screenRect = [[UIScreen mainScreen] bounds];
    self.itemSize = screenRect.size;
    self.minimumInteritemSpacing = 0;
    self.scrollDirection = UICollectionViewScrollDirectionHorizontal;
}

// called continuously as the rect changes
- (NSArray *)layoutAttributesForElementsInRect:(CGRect)rect {
    NSArray *attribs = [super layoutAttributesForElementsInRect:rect];
    
    return attribs;
}

// indicate that we want to redraw as we scroll
- (BOOL)shouldInvalidateLayoutForBoundsChange:(CGRect)newBounds {
    return YES;
}
@end
