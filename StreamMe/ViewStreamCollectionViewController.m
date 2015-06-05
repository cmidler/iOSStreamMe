//
//  ViewStreamCollectionViewController.m
//  WhoYu
//
//  Created by Chase Midler on 3/30/15.
//  Copyright (c) 2015 midler. All rights reserved.
//

#import "ViewStreamCollectionViewController.h"

@interface ViewStreamCollectionViewController ()

@end

@implementation ViewStreamCollectionViewController
@synthesize streamCollectionView;
- (void)viewDidLoad {
    [super viewDidLoad];
    
    streamShares = _streamObject.streamShares;
    
    [[NSNotificationCenter defaultCenter] addObserver:self
                                             selector:@selector(streamMonitor:)
                                                 name:@"streamCountDone"
                                               object:nil];
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

/* calling load values on notification since viewwillappear is not working */
- (void) streamMonitor:(NSNotification *) notification
{
    if ([[notification name] isEqualToString:@"streamCountDone"])
    {
        NSLog(@"stream count done");
        [streamCollectionView reloadData];
    }
}

- (void) viewWillAppear:(BOOL)animated
{
    _navigationHidden = NO;
    [self toggleHideNavigation];
    
}

-(void)viewDidLayoutSubviews {
    
    // If we haven't done the initial scroll, do it once.
    if (!_initialScrollDone) {
        _initialScrollDone = YES;
        
        NSIndexPath* path = [NSIndexPath indexPathForRow:_currentRow inSection:0];
        [streamCollectionView scrollToItemAtIndexPath:path atScrollPosition:UICollectionViewScrollPositionCenteredHorizontally animated:NO];
        //[self reloadDataFunction];
    }
}

- (void) toggleHideNavigation
{
    [[UIApplication sharedApplication] setStatusBarHidden:!_navigationHidden
                                            withAnimation:UIStatusBarAnimationNone];
    [self.navigationController setNavigationBarHidden:!_navigationHidden];
    //toggle boolean value
    _navigationHidden = !_navigationHidden;
}

-(void) streamButton:(id) sender
{
    [self.navigationController popViewControllerAnimated:YES];
}

-(void) pictureTapped:(id) sender
{
    NSLog(@"picture is tapped");
    [self toggleHideNavigation];
    UITapGestureRecognizer *gesture = (UITapGestureRecognizer *) sender;
    _currentRow = (int)gesture.view.tag;

    [self performSegueWithIdentifier:@"popSegue" sender:self];
}
/*
#pragma mark - Navigation

// In a storyboard-based application, you will often want to do a little preparation before navigation
- (void)prepareForSegue:(UIStoryboardSegue *)segue sender:(id)sender {
    // Get the new view controller using [segue destinationViewController].
    // Pass the selected object to the new view controller.
}
*/

#pragma mark <UICollectionViewDataSource>

- (NSInteger)numberOfSectionsInCollectionView:(UICollectionView *)collectionView {
    return 1;
}


- (NSInteger)collectionView:(UICollectionView *)collectionView numberOfItemsInSection:(NSInteger)section {
    //see if we have the share with the most recent time
    PFObject* lastShare = [streamShares lastObject];
    NSDate* newestShareTime = _streamObject.newestShareCreationTime;
    bool hasNewestShare = NO;
    if(NSOrderedSame == ([newestShareTime compare:lastShare.createdAt]))
        hasNewestShare = YES;
    
    return streamShares.count+!hasNewestShare;
    
}

- (UICollectionViewCell *)collectionView:(UICollectionView *)collectionView cellForItemAtIndexPath:(NSIndexPath *)indexPath {
    ViewStreamCollectionViewCell *cell = [collectionView dequeueReusableCellWithReuseIdentifier:@"shareCell" forIndexPath:indexPath];
    
    //setup imageview size first
    float width = cell.frame.size.width;
    float height = cell.frame.size.height;
    [cell setUserInteractionEnabled:YES];
    
    
    cell.captionTextView.hidden = YES;
    cell.usernameLabel.hidden = YES;
    cell.createdLabel.hidden = YES;
    cell.shareImageView.frame = CGRectMake(0, 0, width, height);
    cell.usernameLabel.frame = CGRectMake(0, height-3.0/2.0*TOOLBAR_HEIGHT, width, TOOLBAR_HEIGHT/2+1);
    cell.captionTextView.frame = CGRectMake(0,height-TOOLBAR_HEIGHT, width, TOOLBAR_HEIGHT);
    cell.createdLabel.frame = CGRectMake(0, height-3.0/2.0*TOOLBAR_HEIGHT, width, TOOLBAR_HEIGHT/2+1);
    [cell.shareImageView setContentMode:UIViewContentModeScaleToFill];
    cell.shareImageView.translatesAutoresizingMaskIntoConstraints = YES;
    cell.usernameLabel.translatesAutoresizingMaskIntoConstraints = YES;
    cell.createdLabel.translatesAutoresizingMaskIntoConstraints = YES;
    cell.captionTextView.translatesAutoresizingMaskIntoConstraints = YES;
    cell.createdLabel.backgroundColor = [UIColor clearColor];
    cell.captionTextView.backgroundColor = [[UIColor blackColor] colorWithAlphaComponent:0.2];
    cell.usernameLabel.backgroundColor = [[UIColor blackColor] colorWithAlphaComponent:0.2];
    //we are in the beginning loading row
    if(indexPath.row < streamShares.count)
    {
        cell.captionTextView.hidden = NO;
        cell.usernameLabel.hidden = NO;
        cell.createdLabel.hidden = NO;
        PFObject* streamShare = streamShares[indexPath.row];
        PFObject* share = [streamShare objectForKey:@"share"];
        NSLog(@"caption is %@", [share objectForKey:@"caption"]);
            cell.shareImageView.image = [UIImage imageNamed:@"pictures-512.png"];
            cell.shareImageView.file = [share objectForKey:@"file"];
            [cell.shareImageView loadInBackground:^(UIImage *image, NSError *error) {
                
                UITapGestureRecognizer *pictureTap =  [[UITapGestureRecognizer alloc] initWithTarget:self action:@selector(pictureTapped:)];
                pictureTap.numberOfTapsRequired = 1;
                [cell.shareImageView setUserInteractionEnabled:YES];
                [cell.shareImageView addGestureRecognizer:pictureTap];
                cell.shareImageView.tag = indexPath.row;
                for(UIView* view in [cell.shareImageView subviews])
                    if([view isKindOfClass:[UIActivityIndicatorView class]])
                        [view removeFromSuperview];
        }];
        cell.usernameLabel.text = [NSString stringWithFormat:@"From: %@",[share objectForKey:@"username"] ];
        cell.captionTextView.text = [share objectForKey:@"caption"];
        cell.captionTextView.textAlignment = NSTextAlignmentCenter;
        NSString* timeSince;
        //calculate the time since creation
        NSDate* createdAt = share.createdAt;
        NSTimeInterval interval = [[NSDate date] timeIntervalSinceDate:createdAt];
        interval = interval/60;//let's get minutes accuracy
        //if more 30 minutes left then say less than the rounded up hour
        if(interval > 1440)
            timeSince = [NSString stringWithFormat:@"%dd ago",(int) floor(interval/1440)];
        else if(interval>60)
            timeSince = [NSString stringWithFormat:@"%dh ago",(int) floor(interval/60)];
        else
            timeSince = [NSString stringWithFormat:@"%dm ago",(int) ceil(interval)];
        cell.createdLabel.text = timeSince;
        
    }
    else
    {
        cell.tag = END_LOADING_SHARE_TAG;
        cell.shareImageView.image = [UIImage imageNamed:@"pictures-512.png"];
        UIActivityIndicatorView* collectionActivityIndicator = [[UIActivityIndicatorView alloc] initWithActivityIndicatorStyle:UIActivityIndicatorViewStyleWhiteLarge];
        collectionActivityIndicator.hidesWhenStopped = YES;
        collectionActivityIndicator.hidden = NO;
        [collectionActivityIndicator startAnimating];
        collectionActivityIndicator.center = cell.shareImageView.center;
        [cell.shareImageView addSubview:collectionActivityIndicator];
    }
    return cell;
}

- (void)scrollViewDidEndDecelerating:(UIScrollView *)scrollView{
    for (ViewStreamCollectionViewCell *cell in [streamCollectionView visibleCells]) {
        
        //don't do anything here until we initially scroll
        if(!_initialScrollDone)
            return;
        
        
        //checking if we hit a loading row.  If so, we want to increment the current page, and get the new users
        if(cell.tag == END_LOADING_SHARE_TAG)
        {
            @synchronized(self)
            {
                //if downloading then return
                if(_streamObject.isDownloadingAfter)
                    return;
                NSLog(@"at end loading cell");
                //the section into the tableviewarray
                [self loadSharesRight:_streamObject.stream limitOf:SHARES_PER_PAGE];
            }
        }
        else
        {
            //see if we have the first share in the array or not
            NSIndexPath *indexPath = [streamCollectionView indexPathForCell:cell];
            _currentRow = indexPath.row;
        }
    }
}

-(void) reloadDataFunction:(int)rows
{
    //make sure we aren't constantly reloading data
    @synchronized(self)
    {
        if(_reloadingData)
            return;
        _reloadingData = YES;
    }
    @synchronized(self)
    {
        [streamCollectionView reloadData];
        [streamCollectionView layoutIfNeeded];
        
        if(rows)
        {
            int row = rows;
            row+=_currentRow;
            NSIndexPath* path = [NSIndexPath indexPathForRow:row inSection:0];
            [streamCollectionView scrollToItemAtIndexPath:path atScrollPosition:UICollectionViewScrollPositionCenteredHorizontally animated:NO];
        }
        _reloadingData = NO;
    }

}

/*- (CGSize)collectionView:(UICollectionView *)collectionView layout:(UICollectionViewLayout*)collectionViewLayout sizeForItemAtIndexPath:(NSIndexPath *)indexPath
{
    NSLog(@"frame size is %f, %f", self.view.frame.size.width, self.view.frame.size.height);
    return self.view.frame.size;
}*/

- (CGFloat)collectionView:(UICollectionView *)collectionView layout:(UICollectionViewLayout *)collectionViewLayout minimumInteritemSpacingForSectionAtIndex:(NSInteger)section {
    return 0.0f;
}
- (CGFloat)collectionView:(UICollectionView *)collectionView layout:(UICollectionViewLayout *)collectionViewLayout minimumLineSpacingForSectionAtIndex:(NSInteger)section {
    return 0.0f;
}


//lazy load shares right
-(void) loadSharesRight:(PFObject*) stream limitOf:(int)limit
{
    @synchronized(self)
    {
        if(_streamObject.isDownloadingAfter)
            return;
        //change the boolean for downloading after
        _streamObject.isDownloadingAfter = YES;
    }
    //now get the current streamshare
    PFObject* streamShare = (PFObject*)[streamShares lastObject];
    
    //load shares with a time greater than current share's
    [PFCloud callFunctionInBackground:@"getSharesForStream" withParameters:@{@"streamId":stream.objectId, @"lastShareTime":streamShare.createdAt, @"maxShares":[NSNumber numberWithInt:limit], @"direction":@"right"} block:^(id object, NSError *error) {
        if(error)
        {
            //change the boolean for downloading previous
            _streamObject.isDownloadingAfter = NO;
            return;
        }
        
        //object returns an array of PFObjects
        NSArray* streamShareObjects = object;
        for(PFObject* streamShare in streamShareObjects)
        {
            NSLog(@"streamshare right is %@", streamShare.objectId);
            if(![streamShares containsObject:streamShare])
                [streamShares addObject:streamShare];
        }
        //change the boolean for downloading previous
        _streamObject.isDownloadingAfter = NO;
        //reload section
        [self reloadDataFunction:0];
    }];
}

@end
