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
@synthesize streamShares;
@synthesize streamCollectionView;
@synthesize composeComment;
@synthesize toolBar;
@synthesize lineView;
@synthesize showCommentsViewController;
- (void)viewDidLoad {
    [super viewDidLoad];
    [[NSNotificationCenter defaultCenter] addObserver:self
                                             selector:@selector(streamMonitor:)
                                                 name:@"streamCountDone"
                                               object:nil];
    /*[[NSNotificationCenter defaultCenter] addObserver:self
                                            selector:@selector(keyboardWasShown:)
                                            name:UIKeyboardDidShowNotification
                                            object:nil];*/
    [[NSNotificationCenter defaultCenter] addObserver:self
                                             selector:@selector(keyboardWillShow:)
                                                 name:UIKeyboardWillChangeFrameNotification
                                               object:nil];
    
    [[NSNotificationCenter defaultCenter] addObserver:self
                                             selector:@selector(cancelComment:)
                                                 name:@"dismissComments"
                                               object:nil];
}

- (void)keyboardWillShow:(NSNotification *)notification
{
    [self.view layoutIfNeeded];
    // Get the size of the keyboard.
    CGRect keyboard = [[[notification userInfo] objectForKey:UIKeyboardFrameBeginUserInfoKey] CGRectValue];
    NSTimeInterval duration = [[[notification userInfo] objectForKey:UIKeyboardAnimationDurationUserInfoKey] doubleValue];
    UIViewAnimationCurve curve = [[[notification userInfo] objectForKey:UIKeyboardAnimationCurveUserInfoKey] intValue];
    //CGRect screenRect = [[UIScreen mainScreen] bounds];
    
    NSLog(@"keyboard height is %f", keyboard.size.height);
    NSLog(@"did show keyboard is %d", _didShowKeyboard);
    [UIView animateWithDuration:duration
                     animations:^{
                         [UIView setAnimationCurve:curve];
                         //hack because it isn't giving the proper notification
                         if(_didShowKeyboard)
                         {
                             if(keyboard.size.height == 224)
                             {
                                 ((ShowCommentsViewController*)showCommentsViewController).keyboardHeight = keyboard.size.height+QUICK_TYPE_OFFSET-TOOLBAR_HEIGHT;
                                 [((ShowCommentsViewController*)showCommentsViewController) redoHeight];
                                 //commentView.frame = CGRectMake(0, screenRect.size.height-keyboard.size.height-QUICK_TYPE_OFFSET-40, screenRect.size.width, 40);
                                 
                             }
                             else
                             {
                                 ((ShowCommentsViewController*)showCommentsViewController).keyboardHeight = keyboard.size.height-QUICK_TYPE_OFFSET-TOOLBAR_HEIGHT;
                                 [((ShowCommentsViewController*)showCommentsViewController) redoHeight];
                                 //commentView.frame = CGRectMake(0, screenRect.size.height-keyboard.size.height+QUICK_TYPE_OFFSET-40, screenRect.size.width, 40);
                             }
                         }
                         else
                         {
                             ((ShowCommentsViewController*)showCommentsViewController).keyboardHeight = keyboard.size.height-TOOLBAR_HEIGHT;
                             [((ShowCommentsViewController*)showCommentsViewController) redoHeight];
                             //commentView.frame = CGRectMake(0, screenRect.size.height-keyboard.size.height-40, screenRect.size.width, 40);
                         }
                         [self.view layoutIfNeeded];
                     }];
    _didShowKeyboard = YES;
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

-(void) viewDidAppear:(BOOL)animated
{
    //get view original center
    _originalCenter = self.view.center;
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
    streamShares = _streamObject.streamShares;
    _navigationHidden = NO;
    [[UIApplication sharedApplication] setStatusBarHidden:YES
                                            withAnimation:UIStatusBarAnimationNone];
    [self.navigationController.navigationBar setBackgroundImage:[UIImage new] forBarPosition:UIBarPositionAny barMetrics:UIBarMetricsDefault];
    [self.navigationController.navigationBar setShadowImage:[UIImage new]];
    //[self.navigationController.navigationBar setBarStyle:UIBarStyleBlack];
    [self.navigationController.navigationBar setBackgroundColor:[UIColor blackColor]];
    [self.navigationController.navigationBar setTranslucent:YES];

    [self.navigationController.navigationBar setBarTintColor:[UIColor blackColor]];
    UIBarButtonItem *buttonRight = [[UIBarButtonItem alloc] initWithImage:[UIImage imageNamed:@"gallery.png"] style:UIBarButtonItemStyleDone target:self action:@selector(galleryButton:)];
    self.navigationItem.rightBarButtonItem = buttonRight;
    UIBarButtonItem *buttonLeft = [[UIBarButtonItem alloc] initWithImage:[UIImage imageNamed:@"back_arrow"] style:UIBarButtonItemStyleDone target:self action:@selector(backButton:)];
    self.navigationItem.leftBarButtonItem = buttonLeft;
    
    [self setupToolbar];
    
}

-(void) setupToolbar
{
    CGRect screenRect = [[UIScreen mainScreen] bounds];
    toolBar = [[UIToolbar alloc] initWithFrame:CGRectMake(0, screenRect.size.height-TOOLBAR_HEIGHT, screenRect.size.width, TOOLBAR_HEIGHT)];
    lineView = [[UIView alloc] initWithFrame:CGRectMake(0, screenRect.size.height-TOOLBAR_HEIGHT, screenRect.size.width, 1)];
    lineView.backgroundColor = [UIColor whiteColor];
    composeComment = [[UIBarButtonItem alloc] initWithImage:[UIImage imageNamed:@"comment.png"] style:UIBarButtonItemStyleDone target:self action:@selector(showComments:)];
    [composeComment setTintColor:[UIColor whiteColor]];
    
    //add the uibarbuttonitems to the toolbar
    [toolBar setItems:[NSArray arrayWithObjects:composeComment,[[UIBarButtonItem alloc] initWithBarButtonSystemItem:UIBarButtonSystemItemFlexibleSpace target:nil action:nil], nil]];
    
    //setup the toolbar
    [toolBar setBackgroundImage:[UIImage new]
                  forToolbarPosition:UIBarPositionAny
                          barMetrics:UIBarMetricsDefault];
    [toolBar setShadowImage:[UIImage new]
              forToolbarPosition:UIToolbarPositionAny];
    [toolBar setBarStyle:UIBarStyleBlack];
    [toolBar setBackgroundColor:[UIColor blackColor]];
    [toolBar setTranslucent:YES];
    
    
    [self.view addSubview:lineView];
    [self.view addSubview:toolBar];
    [self.view bringSubviewToFront:lineView];
    [self.view bringSubviewToFront:toolBar];
    
}

-(void) showComments:(id)sender
{
    if(showCommentsViewController)
    {
        [self dismissComment];
        return;
    }
    
    showCommentsViewController = [self.storyboard instantiateViewControllerWithIdentifier:@"CommentsViewController"];
    ((ShowCommentsViewController*)showCommentsViewController).comments = ((StreamShare*)streamShares[_currentRow]).comments;
    ((ShowCommentsViewController*)showCommentsViewController).keyboardHeight = 0;
    //showCommentsViewController.streamShare = streamShares[_currentRow];
    _didShowKeyboard = NO;
    [self addChildViewController:showCommentsViewController];
    [self.view addSubview:showCommentsViewController.view];
    [self.showCommentsViewController didMoveToParentViewController:self];
    //[self presentViewController:showCommentsViewController animated:YES completion:nil];
    //showCommentsViewController.preferredContentSize = showCommentsViewController.view.frame.size;
    [composeComment setTintColor:[UIColor colorWithRed:0.0 green:122.0/255.0 blue:1.0 alpha:1.0]];
    
    
}



-(void) cancelComment:(id)sender
{
    [self dismissComment];
}

-(void) dismissComment
{
    [composeComment setTintColor:[UIColor whiteColor]];
    NSLog(@"show comments view controller is %@", showCommentsViewController);
    if(showCommentsViewController)
    {
        [showCommentsViewController.view removeFromSuperview];
        [showCommentsViewController removeFromParentViewController];
        showCommentsViewController = nil;
    }
    
    _didShowKeyboard = NO;
    if(self.view.center.x != _originalCenter.x || self.view.center.y != _originalCenter.y)
        self.view.center = _originalCenter;
}





-(void) viewWillDisappear:(BOOL)animated
{
    _navigationHidden = NO;
    [[UIApplication sharedApplication] setStatusBarHidden:NO
                                            withAnimation:UIStatusBarAnimationNone];
    UIGraphicsBeginImageContext(self.view.frame.size);
    [[UIImage imageNamed:@"BlueGradient.png"] drawInRect:self.view.bounds];
    UIImage *image = UIGraphicsGetImageFromCurrentImageContext();
    UIGraphicsEndImageContext();
    [self.navigationController.navigationBar setBarTintColor:[UIColor colorWithPatternImage:image]];
    [self.navigationController.navigationBar setBackgroundColor:[UIColor colorWithPatternImage:image]];
    [self.navigationController.navigationBar setTranslucent:NO];
    self.navigationController.navigationBar.hidden = NO;
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

-(void) backButton:(id) sender
{
    [self dismissComment];
    [self performSegueWithIdentifier:@"popSegue" sender:self];
}

-(void) galleryButton:(id) sender
{
    [self dismissComment];
    UITapGestureRecognizer *gesture = (UITapGestureRecognizer *) sender;
    _currentRow = (int)gesture.view.tag;
    
    [self performSegueWithIdentifier:@"gallerySegue" sender:self];
}

-(void) pictureTapped:(id) sender
{
    NSLog(@"picture is tapped");
    
    if(showCommentsViewController)
    {
        [((ShowCommentsViewController*)showCommentsViewController) cancelComment:self];
        return;
    }
    
    //[self toggleHideNavigation];
    UITapGestureRecognizer *gesture = (UITapGestureRecognizer *) sender;
    _currentRow = (int)gesture.view.tag;

    _navigationHidden = !_navigationHidden;
    [self.navigationController.navigationBar setHidden:_navigationHidden];
    
    
    [streamCollectionView reloadData];
    
    //[self performSegueWithIdentifier:@"popSegue" sender:self];
}



// In a storyboard-based application, you will often want to do a little preparation before navigation
- (void)prepareForSegue:(UIStoryboardSegue *)segue sender:(id)sender {
    // Get the new view controller using [segue destinationViewController].
    // Pass the selected object to the new view controller.
    if([segue.identifier isEqualToString:@"gallerySegue"]){
        StreamCollectionViewController* controller = (StreamCollectionViewController*)segue.destinationViewController;
        //NSLog(@"selected section and row %d, %d", _selectedSectionIndex, _selectedCellIndex);
        
        controller.streamObject = _streamObject;
        controller.currentRow = _currentRow;
    }
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
    toolBar.hidden = YES;
    lineView.hidden = YES;
    cell.shareImageView.frame = CGRectMake(0, 0, width, height);
    cell.usernameLabel.frame = CGRectMake(0, height-5.0/2.0*TOOLBAR_HEIGHT, width, TOOLBAR_HEIGHT/2+1);
    cell.captionTextView.frame = CGRectMake(0,height-2*TOOLBAR_HEIGHT, width, TOOLBAR_HEIGHT);
    cell.createdLabel.frame = CGRectMake(0, height-5.0/2.0*TOOLBAR_HEIGHT, width, TOOLBAR_HEIGHT/2+1);
    
    cell.createdLabel.backgroundColor = [UIColor clearColor];
    cell.captionTextView.backgroundColor = [UIColor blackColor];
    cell.usernameLabel.backgroundColor = [UIColor blackColor];
    cell.shareImageView.contentMode = UIViewContentModeScaleAspectFill;
    [cell bringSubviewToFront:cell.createdLabel];
    
    //we are in the beginning loading row
    if(indexPath.row < streamShares.count)
    {
        
        if(!_navigationHidden)
        {
            cell.captionTextView.hidden = NO;
            cell.usernameLabel.hidden = NO;
            cell.createdLabel.hidden = NO;
            toolBar.hidden = NO;
            lineView.hidden = NO;
        }
        PFObject* streamShare = ((StreamShare*)streamShares[indexPath.row]).streamShare;
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
                if(cell.tag == END_LOADING_SHARE_TAG && showCommentsViewController)
                {
                    NSLog(@"showing comments fired");
                    ((ShowCommentsViewController*)showCommentsViewController).comments = ((StreamShare*)streamShares[_currentRow]).comments;
                    [[NSNotificationCenter defaultCenter] postNotificationName:@"changeComments" object:self];
                }
                cell.tag = COLLECTION_VIEW_TAG;
                //CGRect screenRect = [[UIScreen mainScreen] bounds];
                //cell.shareImageView.image = [self imageWithImage:image scaledToWidth:screenRect.size.width];
                
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
        
        NSLog(@"created label is %@", cell.createdLabel.text);
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
    
    NSLog(@"visible cell count is %d", (int) [streamCollectionView visibleCells].count);
    for (ViewStreamCollectionViewCell *cell in [streamCollectionView visibleCells]) {
        
        //NSLog(@"current row RIGHT NOW IS %d", (int) _currentRow);
        
        
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
    }
    
    double delayInSeconds = 0.3;
    dispatch_time_t popTime = dispatch_time(DISPATCH_TIME_NOW, delayInSeconds * NSEC_PER_SEC);
    dispatch_after(popTime, dispatch_get_main_queue(), ^(void){
        //code to be executed on the main queue after delay
        [self getCurrentRow];
    });
}

-(void) getCurrentRow
{
    NSInteger originalRow = _currentRow;
    NSLog(@"visible cell count is %d", (int) [streamCollectionView visibleCells].count);
    for (ViewStreamCollectionViewCell *cell in [streamCollectionView visibleCells]) {
        
        NSIndexPath *indexPath = [streamCollectionView indexPathForCell:cell];
        NSLog(@"cell index is %d",(int) indexPath.row);
        if([streamCollectionView visibleCells].count>1)
        {
            if(indexPath.row != originalRow)
            {
                _currentRow = indexPath.row;
                if(cell.tag != END_LOADING_SHARE_TAG)
                {
                    NSLog(@"showing comments fired");
                    ((ShowCommentsViewController*)showCommentsViewController).comments = ((StreamShare*)streamShares[_currentRow]).comments;
                    [[NSNotificationCenter defaultCenter] postNotificationName:@"changeComments" object:self];
                }
            }
        }
        else
        {
            _currentRow = indexPath.row;
            if(cell.tag != END_LOADING_SHARE_TAG)
            {
                NSLog(@"showing comments fired");
                ((ShowCommentsViewController*)showCommentsViewController).comments = ((StreamShare*)streamShares[_currentRow]).comments;
                [[NSNotificationCenter defaultCenter] postNotificationName:@"changeComments" object:self];
            }
            
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
    
    NSMutableArray* streamShareIds = [[NSMutableArray alloc] init];
    for(StreamShare* streamShare in streamShares)
        [streamShareIds addObject:streamShare.streamShare.objectId];

    NSLog(@"about to get newest shares for stream");
    //load shares with a time greater than current share's
    [PFCloud callFunctionInBackground:@"getNewestSharesForStream" withParameters:@{@"streamId":_streamObject.stream.objectId, @"maxShares":[NSNumber numberWithInt:SHARES_PER_PAGE], @"streamShareIds":streamShareIds} block:^(id object, NSError *error) {
        if(error)
        {
            NSLog(@"error getting shares for stream");
            //change the boolean for downloading previous
            _streamObject.isDownloadingAfter = NO;
            return;
        }
        
        NSInteger originalCount = streamShares.count;
        
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
        if(originalCount < streamShares.count)
            [self reloadDataFunction:0];
    }];
}


@end
