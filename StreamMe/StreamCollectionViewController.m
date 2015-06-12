//
//  StreamCollectionViewController.m
//  StreamMe
//
//  Created by Chase Midler on 5/29/15.
//  Copyright (c) 2015 StreamMe. All rights reserved.
//

#import "StreamCollectionViewController.h"

@interface StreamCollectionViewController ()

@end

@implementation StreamCollectionViewController

@synthesize streamCollectionView;

- (void)viewDidLoad {
    [super viewDidLoad];
    
    //make sure the streamshares the array from stream object
    streamShares = _streamObject.streamShares;
    _sortBy = 0;
    
    UILabel *navigationTitle=[[UILabel alloc]initWithFrame:CGRectMake(0, 0, 176, 44)];
    navigationTitle.text = @"Stream Story";
    navigationTitle.textColor = [UIColor whiteColor];
    navigationTitle.font = [UIFont boldSystemFontOfSize:17];
    navigationTitle.textAlignment = NSTextAlignmentCenter;
    UIImageView *workaroundView = [[UIImageView alloc] initWithFrame:CGRectMake(0, 0, 176, 44)];
    [workaroundView addSubview:navigationTitle];
    self.navigationItem.titleView=workaroundView;
    
    self.navigationItem.leftBarButtonItem = [[UIBarButtonItem alloc] initWithImage:[UIImage imageNamed:@"back_arrow.png"] style:UIBarButtonItemStyleDone target:self action:@selector(backClicked:)];
    self.navigationItem.rightBarButtonItem = [[UIBarButtonItem alloc] initWithImage:[UIImage imageNamed:@"shuffle.png"] style:UIBarButtonItemStyleDone target:self action:@selector(shuffleClicked:)];
    //see if we need to download more streams
    if(_streamObject.totalShares > streamShares.count)
    {
        NSLog(@"call downloadshares");
        [self downloadShares];
    }
    else
    {
        NSLog(@"totalShares = %d and streamsharescount = %d", (int)_streamObject.totalShares, (int)streamShares.count);
    }
    
    [[NSNotificationCenter defaultCenter] addObserver:self
                                             selector:@selector(streamMonitor:)
                                                 name:@"streamCountDone"
                                               object:nil];
    //setting up swipes
    UISwipeGestureRecognizer * recognizer = [[UISwipeGestureRecognizer alloc] initWithTarget:self action:@selector(myRightAction:)];
    [recognizer setDirection:(UISwipeGestureRecognizerDirectionRight)];
    [self.view addGestureRecognizer:recognizer];

    
}

-(void) viewWillAppear:(BOOL)animated
{
    [self sortStreamShares];
}

-(void) backClicked:(id)sender
{
    [self performSegueWithIdentifier:@"popSegue" sender:self];
}

-(void) shuffleClicked:(id)sender
{
    
    //select random cell
    _selectedCellIndex = arc4random_uniform((int)streamShares.count);
    [self performSegueWithIdentifier:@"viewShareSegue" sender:self];
}

-(void) myRightAction:(id) sender
{
    [self performSegueWithIdentifier:@"popSegue" sender:self];
}

/* calling load values on notification since viewwillappear is not working */
- (void) streamMonitor:(NSNotification *) notification
{
    if ([[notification name] isEqualToString:@"streamCountDone"])
    {
        NSLog(@"stream count done");
        [self sortStreamShares];
    }
}

-(void) sortStreamShares
{
    
    if(!_sortBy)
    {
        _streamObject.streamShares = streamShares = [[NSMutableArray alloc] initWithArray: [streamShares sortedArrayUsingComparator: ^(StreamShare* obj1, StreamShare* obj2) {
            
            //compare on created at
            return [obj1.streamShare.createdAt compare:obj2.streamShare.createdAt];
        }]];
    }
    
    [streamCollectionView reloadData];
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}


//helper function to properly download shares
-(void) downloadShares
{
    //get an array of the streamshare ids
    NSMutableArray* streamShareIds = [[NSMutableArray alloc] init];
    for(StreamShare* streamShare in streamShares)
        [streamShareIds addObject:streamShare.streamShare.objectId];
    
    if(!_sortBy)
        [self getNewestShares:streamShareIds];
    
}


//get newest shares
-(void) getNewestShares:(NSMutableArray*)streamShareIds{
    NSLog(@"get newest shares");
    @synchronized(self)
    {
        if(_streamObject.isDownloadingAfter)
            return;
        //change the boolean for downloading after
        _streamObject.isDownloadingAfter = YES;
    }
    
    //load shares with a time greater than current share's
    [PFCloud callFunctionInBackground:@"getNewestSharesForStream" withParameters:@{@"streamId":_streamObject.stream.objectId, @"maxShares":[NSNumber numberWithInt:SHARES_PER_PAGE], @"streamShareIds":streamShareIds} block:^(id object, NSError *error) {
        if(error)
        {
            NSLog(@"error getting shares for stream");
            //change the boolean for downloading previous
            _streamObject.isDownloadingAfter = NO;
            return;
        }
        
        //NSLog(@"object is %@", object);
        NSLog(@"got newest streams!");
        //object returns an array of PFObjects
        NSArray* streamShareObjects = object;
        for(NSDictionary* dict in streamShareObjects)
        {
            PFObject* newStreamShare = dict[@"stream_share"];
            NSLog(@"new streamshare is %@", newStreamShare);
            int i = 0;
            //make sure we don't already have the stream share
            for(StreamShare* streamShare in streamShares)
            {
                //NSLog(@"streamshare right is %@", streamShare.objectId);
                PFObject* ssObject = streamShare.streamShare;
                if([newStreamShare.objectId isEqualToString:ssObject.objectId])
                {
                    NSLog(@"breaking!");
                    break;
                }
                i++;
            }
            
            if(i!= streamShares.count)
                continue;
            
            NSArray* comments = dict[@"comments"];
            StreamShare* ss = [[StreamShare alloc] init];
            ss.streamShare = newStreamShare;
            for(NSDictionary* commentDict in comments)
            {
                Comment* comment = [[Comment alloc] init];
                comment.text = commentDict[@"text"];
                comment.postingName = commentDict[@"username"];
                comment.createdAt = commentDict[@"createdAt"];
                [ss.comments addObject:comment];
            }
            NSLog(@"adding new stream share to stream shares");
            [streamShares addObject:ss];
            
        }

        //change the boolean for downloading previous
        _streamObject.isDownloadingAfter = NO;
        //reload section
        [self sortStreamShares];
    }];

    
}


#pragma mark <UICollectionViewDataSource>

- (NSInteger)numberOfSectionsInCollectionView:(UICollectionView *)collectionView {
    return 1;
}


- (NSInteger)collectionView:(UICollectionView *)collectionView numberOfItemsInSection:(NSInteger)section {
    //see if we have the share with the most recent time
    PFObject* lastShare = ((StreamShare*)[streamShares lastObject]).streamShare;
    NSDate* newestShareTime = _streamObject.newestShareCreationTime;
    bool hasNewestShare = NO;
    NSComparisonResult comp = [newestShareTime compare:lastShare.createdAt];
    if(NSOrderedSame == comp || NSOrderedAscending == comp)
    {
        hasNewestShare = YES;
    }

    
    return streamShares.count+!hasNewestShare;
    
}

- (UICollectionViewCell *)collectionView:(UICollectionView *)collectionView cellForItemAtIndexPath:(NSIndexPath *)indexPath {
    StreamCollectionViewCell *cell = [collectionView dequeueReusableCellWithReuseIdentifier:@"streamCell" forIndexPath:indexPath];
    
    //setup imageview size first
    float width = cell.frame.size.width;
    float height = cell.frame.size.height;
    
    
    cell.shareImageView.frame = CGRectMake(0, 0, width, height);
    [cell.shareImageView setContentMode:UIViewContentModeScaleToFill];
    cell.shareImageView.translatesAutoresizingMaskIntoConstraints = YES;
    if(indexPath.row < streamShares.count)
    {
        cell.tag = 0;
        PFObject* streamShare = ((StreamShare*)streamShares[indexPath.row]).streamShare;
        PFObject* share = [streamShare objectForKey:@"share"];
        cell.shareImageView.image = [UIImage imageNamed:@"pictures-320.png"];
        cell.shareImageView.file = [share objectForKey:@"file"];
        [cell setUserInteractionEnabled:NO];
        UIActivityIndicatorView* collectionActivityIndicator = [[UIActivityIndicatorView alloc] initWithActivityIndicatorStyle:UIActivityIndicatorViewStyleWhiteLarge];
        collectionActivityIndicator.hidesWhenStopped = YES;
        collectionActivityIndicator.hidden = NO;
        [collectionActivityIndicator startAnimating];
        collectionActivityIndicator.center = cell.shareImageView.center;
        [cell.shareImageView addSubview:collectionActivityIndicator];
        
        
        [cell.shareImageView loadInBackground:^(UIImage *image, NSError *error) {
            [cell setUserInteractionEnabled:YES];
            cell.shareImageView.tag = indexPath.row;
            for(UIView* view in [cell.shareImageView subviews])
                if([view isKindOfClass:[UIActivityIndicatorView class]])
                    [view removeFromSuperview];
            cell.shareImageView.image = [self imageWithImage:image scaledToFillSize:cell.frame.size];
            
        }];
        
    }
    else
    {
        cell.tag = END_LOADING_SHARE_TAG;
        /*cell.shareImageView.image = [UIImage imageNamed:@"pictures-512.png"];
        UIActivityIndicatorView* collectionActivityIndicator = [[UIActivityIndicatorView alloc] initWithActivityIndicatorStyle:UIActivityIndicatorViewStyleWhiteLarge];
        collectionActivityIndicator.hidesWhenStopped = YES;
        collectionActivityIndicator.hidden = NO;
        [collectionActivityIndicator startAnimating];
        collectionActivityIndicator.center = cell.shareImageView.center;
        [cell.shareImageView addSubview:collectionActivityIndicator];*/
    }
    return cell;
}


- (void)collectionView:(UICollectionView *)collectionView
       willDisplayCell:(UICollectionViewCell *)cell
    forItemAtIndexPath:(NSIndexPath *)indexPath
{
    
    //checking if we hit a loading row.  If so, we want to increment the current page, and get the new users
    if(cell.tag == END_LOADING_SHARE_TAG)
    {
        NSLog(@"showing loading share");
        [self downloadShares];
    }
    
    
}

-(void)collectionView:(UICollectionView *)collectionView
didSelectItemAtIndexPath:(NSIndexPath *)indexPath {
    _selectedCellIndex = (int)indexPath.row;
    [self performSegueWithIdentifier:@"viewShareSegue" sender:self];
}

//Prepare segue
- (void) prepareForSegue:(UIStoryboardSegue *)segue sender:(id)sender {
    //If we are segueing to selectedProfile then we need to save profile ID
    if([segue.identifier isEqualToString:@"viewShareSegue"]){
        ViewStreamCollectionViewController* controller = (ViewStreamCollectionViewController*)segue.destinationViewController;
        //NSLog(@"selected section and row %d, %d", _selectedSectionIndex, _selectedCellIndex);
        
        controller.streamObject = _streamObject;
        controller.currentRow = _selectedCellIndex;
        NSLog(@"selected bitch cell is %d", _selectedCellIndex);
    }
}


- (CGFloat)collectionView:(UICollectionView *)collectionView layout:(UICollectionViewLayout *)collectionViewLayout minimumInteritemSpacingForSectionAtIndex:(NSInteger)section {
    return 0.0f;
}
- (CGFloat)collectionView:(UICollectionView *)collectionView layout:(UICollectionViewLayout *)collectionViewLayout minimumLineSpacingForSectionAtIndex:(NSInteger)section {
    return 0.0f;
}


- (UIImage *)imageWithImage:(UIImage *)image scaledToFillSize:(CGSize)size
{
    CGFloat scale = MAX(size.width/image.size.width, size.height/image.size.height);
    //int imageOrientation = image.imageOrientation;
    CGFloat width = image.size.width * scale;
    CGFloat height = image.size.height * scale;
    if(image.size.width>image.size.height)
    {
        width =image.size.height * scale;
        height =image.size.width * scale;
    }
    CGRect imageRect = CGRectMake((size.width - width)/2.0f,
                                  (size.height - height)/2.0f,
                                  width,
                                  height);
    
    UIGraphicsBeginImageContextWithOptions(size, NO, 0);
    [image drawInRect:imageRect];
    UIImage *newImage = UIGraphicsGetImageFromCurrentImageContext();
    UIGraphicsEndImageContext();
    return newImage;
}


@end
