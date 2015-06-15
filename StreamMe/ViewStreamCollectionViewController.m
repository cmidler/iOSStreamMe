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
@synthesize upvote;
@synthesize downvote;
@synthesize commentCount;
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
    [[NSNotificationCenter defaultCenter] addObserver:self
                                             selector:@selector(setCommentAndLikeCountTotal:)
                                                 name:@"addedComment"
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
                         //means we are dismissing keyboard
                         else if(((ShowCommentsViewController*)showCommentsViewController).keyboardHeight)
                         {
                             ((ShowCommentsViewController*)showCommentsViewController).keyboardHeight = 0;
                             [((ShowCommentsViewController*)showCommentsViewController) redoHeight];
                             [self.view layoutIfNeeded];
                             return;
                         }
                         else
                         {
                             ((ShowCommentsViewController*)showCommentsViewController).keyboardHeight = keyboard.size.height-TOOLBAR_HEIGHT;
                             [((ShowCommentsViewController*)showCommentsViewController) redoHeight];
                             //commentView.frame = CGRectMake(0, screenRect.size.height-keyboard.size.height-40, screenRect.size.width, 40);
                         }
                         _didShowKeyboard = YES;
                         [self.view layoutIfNeeded];
                     }];
    
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
    [self setCommentAndLikeCountTotal:nil];
    
}

-(void) setupToolbar
{
    CGRect screenRect = [[UIScreen mainScreen] bounds];
    toolBar = [[UIToolbar alloc] initWithFrame:CGRectMake(0, screenRect.size.height-TOOLBAR_HEIGHT, screenRect.size.width, TOOLBAR_HEIGHT)];
    lineView = [[UIView alloc] initWithFrame:CGRectMake(0, screenRect.size.height-TOOLBAR_HEIGHT, screenRect.size.width, 1)];
    lineView.backgroundColor = [UIColor whiteColor];
    composeComment = [[UIBarButtonItem alloc] initWithImage:[UIImage imageNamed:@"comment.png"] style:UIBarButtonItemStyleDone target:self action:@selector(showComments:)];
    [composeComment setTintColor:[UIColor whiteColor]];
    
    
    StreamShare* ss = streamShares[_currentRow];
    int countComment = ((NSNumber*)[ss.streamShare objectForKey:@"commentTotal"]).intValue;
    int countLike = ((NSNumber*)[ss.streamShare objectForKey:@"likeTotal"]).intValue;
    NSLog(@"count total is %d", countLike);
    
    NSString* comment = [NSString stringWithFormat:@"%d Comments", countComment];
    if(countComment == 1)
        comment = @"1 Comment";
    else if (!countComment)
        comment = @"No Comments";
    
    if(countLike > 1 || countLike < 0)
        comment = [NSString stringWithFormat:@"%@\n%d Likes", comment, countLike ];
    else if (countLike == 1 )
        comment = [NSString stringWithFormat:@"%@\n1 Like", comment];
    else
        comment = [NSString stringWithFormat:@"%@\nNo Likes", comment];
    

    
    UIButton* rightButton = [UIButton buttonWithType:UIButtonTypeSystem];
    
    [rightButton setTitle:comment forState:UIControlStateNormal];
    [rightButton.titleLabel setNumberOfLines:2];
    [rightButton.titleLabel setLineBreakMode:NSLineBreakByWordWrapping];
    [rightButton.titleLabel setTextAlignment:NSTextAlignmentRight];
    [rightButton.titleLabel setFont:[UIFont boldSystemFontOfSize:12]];
    rightButton.bounds = CGRectMake(0, 0, 100, TOOLBAR_HEIGHT);
    [rightButton setTintColor:composeComment.tintColor];
    [rightButton addTarget:self
                    action:@selector(showComments:)
          forControlEvents:UIControlEventTouchUpInside];
    commentCount = [[UIBarButtonItem alloc] initWithCustomView:rightButton];
    [commentCount setTintColor:[UIColor whiteColor]];
    
    //voting arrows
    upvote = [[UIBarButtonItem alloc] initWithImage:[UIImage imageNamed:@"upvote_arrow.png"] style:UIBarButtonItemStyleDone target:self action:@selector(upvote:)];
    downvote = [[UIBarButtonItem alloc] initWithImage:[UIImage imageNamed:@"downvote_arrow.png"] style:UIBarButtonItemStyleDone target:self action:@selector(downvote:)];
    
    if(ss.likeValue>0)
    {
        [upvote setTintColor:[UIColor greenColor]];
        [downvote setTintColor:[UIColor whiteColor]];
    }
    else if (!ss.likeValue)
    {
        [upvote setTintColor:[UIColor whiteColor]];
        [downvote setTintColor:[UIColor whiteColor]];
    }
    else
    {
        [upvote setTintColor:[UIColor whiteColor]];
        [downvote setTintColor:[UIColor redColor]];
    }
    
    
    //add the uibarbuttonitems to the toolbar
    [toolBar setItems:[NSArray arrayWithObjects:composeComment, upvote, downvote,[[UIBarButtonItem alloc] initWithBarButtonSystemItem:UIBarButtonSystemItemFlexibleSpace target:nil action:nil], commentCount, nil]];
    
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
    [self.view bringSubviewToFront:toolBar];
    [self.view bringSubviewToFront:lineView];
    
}

//set the comment for the current row
-(void) setCommentAndLikeCountTotal:(NSNotification *) notification
{
    //make sure it is within bounds
    if(_currentRow >= streamShares.count)
        return;
    
    __block PFObject* streamShare = ((StreamShare*)streamShares[_currentRow]).streamShare;
    int countComment = ((NSNumber*)[streamShare objectForKey:@"commentTotal"]).intValue;
    int countLike = ((NSNumber*)[streamShare objectForKey:@"likeTotal"]).intValue;
    NSLog(@"setting comment count is %d", countComment);
    
    NSString* comment = [NSString stringWithFormat:@"%d Comments", countComment ];
    if(countComment == 1)
        comment = @"1 Comment";
    else if (!countComment)
        comment = @"No Comments";
    
    if(countLike > 1 || countLike < 0)
        comment = [NSString stringWithFormat:@"%@\n%d Likes", comment, countLike ];
    else if (countLike == 1 )
        comment = [NSString stringWithFormat:@"%@\n1 Like", comment];
    else
        comment = [NSString stringWithFormat:@"%@\nNo Likes", comment];
    
    UIButton *view = (UIButton*)[commentCount valueForKey:@"view"];
    [view setTitle:comment forState:UIControlStateNormal];
    //[commentCount setTitle:comment];
    [PFCloud callFunctionInBackground:@"getCommentAndLikeTotal" withParameters:@{@"streamShareId":streamShare.objectId} block:^(id object, NSError *error) {
        if(error)
        {
            return;
        }
        
        NSArray* counts = object;
        NSNumber* commentCounts = counts[0];
        NSNumber* likeCounts = counts[1];
        int countComment = ((NSNumber*)[streamShare objectForKey:@"commentTotal"]).intValue;
        int countLike = ((NSNumber*)[streamShare objectForKey:@"likeTotal"]).intValue;

        [streamShare setObject:commentCounts forKey:@"commentTotal"];
        [streamShare setObject:likeCounts forKey:@"likeTotal"];
        
         NSLog(@"current row is %d", (int)_currentRow);
         //make sure it is within bounds
         if(_currentRow >= streamShares.count)
             return;
         
         PFObject* currentStreamShare = ((StreamShare*)streamShares[_currentRow]).streamShare;
         if([streamShare.objectId isEqualToString:currentStreamShare.objectId])
         {
             
             if(countComment == commentCounts.intValue && countLike ==likeCounts.intValue)
                 return;
             countComment = commentCounts.intValue;
             countLike = likeCounts.intValue;
             
             
             NSString* comment = [NSString stringWithFormat:@"%d Comments", countComment ];
             if(countComment == 1)
                 comment = @"1 Comment";
             else if (!countComment)
                 comment = @"No Comments";
             
             if(countLike > 1 || countLike < 0)
                 comment = [NSString stringWithFormat:@"%@\n%d Likes", comment, countLike ];
             else if (countLike == 1 )
                 comment = [NSString stringWithFormat:@"%@\n1 Like", comment];
             else
                 comment = [NSString stringWithFormat:@"%@\nNo Likes", comment];
             
             UIButton *view = (UIButton*)[commentCount valueForKey:@"view"];
             [view setTitle:comment forState:UIControlStateNormal];
         }
        
    }];
    /*[PFCloud callFunctionInBackground:@"countCommentsForStreamShare" withParameters:@{@"streamShareId":streamShare.objectId} block:^(id object, NSError *error) {
        if(error)
        {
            return;
        }
        [streamShare setObject:object forKey:@"commentTotal"];
        
        [[NSNotificationCenter defaultCenter] postNotificationName:@"changeComments" object:self];
        
        
    }];*/
    
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
    UIButton *rightButton = (UIButton*)[commentCount valueForKey:@"view"];
    [rightButton setTintColor:composeComment.tintColor];
    //[commentCount setTintColor:[UIColor colorWithRed:0.0 green:122.0/255.0 blue:1.0 alpha:1.0]];
    
}

-(void) setVoteTint
{
    if(_currentRow >= streamShares.count)
        return;
    StreamShare* ss = streamShares[_currentRow];
    
    if(ss.likeValue>0)
    {
        [upvote setTintColor:[UIColor greenColor]];
        [downvote setTintColor:[UIColor whiteColor]];
    }
    else if (!ss.likeValue)
    {
        [upvote setTintColor:[UIColor whiteColor]];
        [downvote setTintColor:[UIColor whiteColor]];
    }
    else
    {
        [upvote setTintColor:[UIColor whiteColor]];
        [downvote setTintColor:[UIColor redColor]];
    }
}

-(void) upvote:(id)sender
{
    //see if I need to change the current total or not
    if(_currentRow >= streamShares.count)
        return;
    NSLog(@"upvote");
    [downvote setTintColor:[UIColor whiteColor]];
    
    
    StreamShare* ss = streamShares[_currentRow];
    //no need to change the like total
    if(ss.likeValue < 1)
    {
        [upvote setTintColor:[UIColor greenColor]];
        int oldValue = ss.likeValue;
        int newLikeTotal = ((NSNumber*)[ss.streamShare objectForKey:@"likeTotal"]).intValue+ 1 - ss.likeValue;
        [ss.streamShare setObject:[NSNumber numberWithInt:newLikeTotal] forKey:@"likeTotal"];
        ss.likeValue = 1;
        [self voted:1 fromOldValue:oldValue forStreamShare:ss];
        
    }
    else
    {
        [upvote setTintColor:[UIColor whiteColor]];
        int oldValue = 1;
        int newLikeTotal = ((NSNumber*)[ss.streamShare objectForKey:@"likeTotal"]).intValue-1;
        [ss.streamShare setObject:[NSNumber numberWithInt:newLikeTotal] forKey:@"likeTotal"];
        ss.likeValue = 0;
        [self voted:0 fromOldValue:oldValue forStreamShare:ss];
    }
    
    UIImage* upvoteImage = [UIImage imageNamed:@"big_upvote.png"];
    
    UIImageView* upvoteImageView = [[UIImageView alloc] initWithImage:upvoteImage];
    upvoteImageView.center = CGPointMake(self.view.center.x, self.view.bounds.size.height);
    [self.view addSubview:upvoteImageView];
    [self.view bringSubviewToFront:upvoteImageView];
    [UIView animateWithDuration:.3f
                     animations:^{
                         
                         upvoteImageView.center = CGPointMake(self.view.center.x, 0);
                     }completion:^(BOOL finished){
                         [upvoteImageView removeFromSuperview];
                     }];
    
    
    
}

-(void) voted: (int) newLikeValue fromOldValue:(int) oldValue forStreamShare:(StreamShare*) currentStreamShare
{
    //need to create or update the like value in the database
    PFQuery* likeQuery = [PFQuery queryWithClassName:@"StreamSharesLike"];
    [likeQuery whereKey:@"user" equalTo:[PFUser currentUser]];
    PFObject* streamSharePointer = [PFObject objectWithoutDataWithClassName:@"StreamShares" objectId:currentStreamShare.streamShare.objectId];
    [likeQuery whereKey:@"stream_share" equalTo:streamSharePointer];
    
    int increment = newLikeValue-oldValue;
    
    
    NSNumber* incrementAmount = [NSNumber numberWithInt:(increment)];
    [PFCloud callFunctionInBackground:@"incrementStreamLikeTotal" withParameters:@{@"streamShareId":streamSharePointer.objectId, @"incValue":incrementAmount} block:^(id object, NSError *error) {
    
        if(error)
        {
            NSLog(@"error is %@", error.localizedDescription);
            currentStreamShare.likeValue = oldValue;
            [self setVoteTint];
            return;

        }
        
        [self setCommentAndLikeCountTotal: nil];
        
        [likeQuery findObjectsInBackgroundWithBlock:^(NSArray *objects, NSError *error)
        {
            if(error)
            {
                currentStreamShare.likeValue = oldValue;
                [self setVoteTint];
                return;
            }
            
            //like exists
            if(objects && objects.count)
            {
                PFObject* streamShareLike = objects[0];
                [streamShareLike setObject:[NSNumber numberWithInt:newLikeValue ] forKey:@"likeValue"];
                
                [streamShareLike saveInBackgroundWithBlock:^(BOOL succeeded, NSError *error) {
                    //on an error, essentially undo what happened
                    if(error)
                    {
                        NSLog(@"error saving streamsharelike");
                        //set the vote back to what it was
                        currentStreamShare.likeValue = oldValue;
                        [self setVoteTint];
                        return;
                    }
                 }];
            }
            else
            {
                PFObject* streamSharesLike = [PFObject objectWithClassName:@"StreamSharesLike"];
                [streamSharesLike setObject:streamSharePointer forKey:@"stream_share"];
                [streamSharesLike setObject:[PFUser currentUser] forKey:@"user"];
                [streamSharesLike setObject:[NSNumber numberWithInt:newLikeValue ] forKey:@"likeValue"];
                [streamSharesLike saveInBackgroundWithBlock:^(BOOL succeeded, NSError *error) {
                    
                    //on an error, essentially undo what happened
                    if(error)
                    {
                        NSLog(@"error saving streamsharelike");
                        //set the vote back to what it was
                        currentStreamShare.likeValue = oldValue;
                        [self setVoteTint];
                        return;
                    }
                }];
            }
        }];
    }];
    
}

-(void) downvote:(id)sender
{
    //see if I need to change the current total or not
    if(_currentRow >= streamShares.count)
        return;
    NSLog(@"downvote");
    [upvote setTintColor:[UIColor whiteColor]];
    
    
    StreamShare* ss = streamShares[_currentRow];
    //no need to change the like total
    if(ss.likeValue > -1)
    {
        [downvote setTintColor:[UIColor redColor]];
        int oldValue = ss.likeValue;
        int newLikeTotal = ((NSNumber*)[ss.streamShare objectForKey:@"likeTotal"]).intValue- 1 - ss.likeValue;
        NSLog(@"new like total is %d", newLikeTotal);
        [ss.streamShare setObject:[NSNumber numberWithInt:newLikeTotal] forKey:@"likeTotal"];
        ss.likeValue = -1;
        [self voted:-1 fromOldValue:oldValue forStreamShare:ss];
    }
    else
    {
        [downvote setTintColor:[UIColor whiteColor]];
        int oldValue = -1;
        int newLikeTotal = ((NSNumber*)[ss.streamShare objectForKey:@"likeTotal"]).intValue+1;
        [ss.streamShare setObject:[NSNumber numberWithInt:newLikeTotal] forKey:@"likeTotal"];
        ss.likeValue = 0;
        [self voted:0 fromOldValue:oldValue forStreamShare:ss];
    }
    
    UIImage* downvoteImage = [UIImage imageNamed:@"big_downvote.png"];
    
    UIImageView* downvoteImageView = [[UIImageView alloc] initWithImage:downvoteImage];
    downvoteImageView.center = CGPointMake(self.view.center.x, 0);
    [self.view addSubview:downvoteImageView];
    [self.view bringSubviewToFront:downvoteImageView];
    [UIView animateWithDuration:.3f
                     animations:^{
                         
                         downvoteImageView.center = CGPointMake(self.view.center.x, self.view.bounds.size.height);
                         
                     }completion:^(BOOL finished){
                         [downvoteImageView removeFromSuperview];
                     }];
}


-(void) cancelComment:(id)sender
{
    [self dismissComment];
}

-(void) dismissComment
{
    [composeComment setTintColor:[UIColor whiteColor]];
    UIButton *rightButton = (UIButton*)[commentCount valueForKey:@"view"];
    [rightButton setTintColor:composeComment.tintColor];
    //[commentCount setTintColor:[UIColor whiteColor]];
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

-(void) upvoteSwipe:(id)sender
{
    UITapGestureRecognizer *gesture = (UITapGestureRecognizer *) sender;
    _currentRow = (int)gesture.view.tag;
    
    [self upvote:self];
}

-(void) downvoteSwipe:(id)sender
{
    UITapGestureRecognizer *gesture = (UITapGestureRecognizer *) sender;
    _currentRow = (int)gesture.view.tag;
    [self downvote:self];
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
    //PFObject* lastShare = ((StreamShare*)[streamShares lastObject]).streamShare;
    
    NSDate* newestTime = _streamObject.stream.createdAt;
    for(StreamShare* ss in streamShares)
    {
        if(NSOrderedAscending == ([newestTime compare:ss.streamShare.createdAt]))
            newestTime = ss.streamShare.createdAt;
    }
    NSDate* newestShareTime = _streamObject.newestShareCreationTime;
    bool hasNewestShare = NO;
    NSComparisonResult comp = [newestShareTime compare:newestTime];
    if(NSOrderedSame == comp || NSOrderedAscending == comp)
        hasNewestShare = YES;
    
    return streamShares.count+!hasNewestShare;
    
}

- (UICollectionViewCell *)collectionView:(UICollectionView *)collectionView cellForItemAtIndexPath:(NSIndexPath *)indexPath {
    ViewStreamCollectionViewCell *cell = [collectionView dequeueReusableCellWithReuseIdentifier:@"shareCell" forIndexPath:indexPath];
    
    
    //setting up swipes
    UISwipeGestureRecognizer * upRecognizer = [[UISwipeGestureRecognizer alloc] initWithTarget:self action:@selector(upvoteSwipe:)];
    [upRecognizer setDirection:(UISwipeGestureRecognizerDirectionUp)];
    [cell addGestureRecognizer:upRecognizer];
    
    //setting up swipes
    UISwipeGestureRecognizer * downRecognizer = [[UISwipeGestureRecognizer alloc] initWithTarget:self action:@selector(downvoteSwipe:)];
    [downRecognizer setDirection:(UISwipeGestureRecognizerDirectionDown)];
    [cell addGestureRecognizer:downRecognizer];
    
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
    cell.createdLabel.frame = CGRectMake(0, height-5.0/2.0*TOOLBAR_HEIGHT, width-5, TOOLBAR_HEIGHT/2+1);
    
    cell.createdLabel.backgroundColor = [UIColor clearColor];
    cell.captionTextView.backgroundColor = [UIColor blackColor];
    cell.usernameLabel.backgroundColor = [UIColor blackColor];
    
    
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
        StreamShare* ss = streamShares[indexPath.row];
        PFObject* streamShare = ss.streamShare;
        PFObject* share = [streamShare objectForKey:@"share"];
        NSLog(@"caption is %@", [share objectForKey:@"caption"]);
        //cell.shareImageView.image = [UIImage imageNamed:@"pictures-512.png"];
        cell.shareImageView.contentMode = ss.contentMode;
        if(ss.fixedImage)
        {
            UITapGestureRecognizer *pictureTap =  [[UITapGestureRecognizer alloc] initWithTarget:self action:@selector(pictureTapped:)];
            pictureTap.numberOfTapsRequired = 1;
            [cell.shareImageView setUserInteractionEnabled:YES];
            [cell.shareImageView addGestureRecognizer:pictureTap];
            cell.shareImageView.tag = indexPath.row;
            for(UIView* view in [cell.shareImageView subviews])
                if([view isKindOfClass:[UIActivityIndicatorView class]])
                    [view removeFromSuperview];
            cell.shareImageView.image = ss.fixedImage;
            cell.tag = indexPath.row;

        }
        else
        {
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
                NSLog(@"height in view stream is %f with width %f", cell.shareImageView.image.size.height, cell.shareImageView.image.size.width);
                
                
                CGFloat imageHeight = cell.shareImageView.image.size.height;
                CGFloat imageWidth = cell.shareImageView.image.size.width;
                NSLog(@"image orientation is %d", (int) image.imageOrientation);
                //width is bigger than height
                if(imageWidth>imageHeight)
                {
                    CGRect screenRect = [[UIScreen mainScreen] bounds];
                    //want to give the ratio of the cell bounds for the size
                    CGFloat screenRatio = screenRect.size.height/screenRect.size.width;
                    CGFloat imageRatio= image.size.width/image.size.height;
                    
                    //CGFloat imageRatio2 = image.size.height/image.size.width;
                    
                    //NSLog(@"screen, img1, img2: %f,%f,%f", screenRatio, imageRatio, imageRatio2);
                    
                    //if image ratio is bigger then that means height should be bigger than width than the current image and vice versa
                    if(screenRatio>imageRatio)
                    {
                        CGFloat adjustedRatio = screenRatio/imageRatio;
                        NSLog(@"adjusted Ratio is %f", adjustedRatio);
                        CGFloat adjustedX = (imageWidth*adjustedRatio -imageWidth)/(2.0f);
                        
                        NSLog(@"adjustedX is %f", adjustedX);
                        
                        
                        //need to make the correct rect
                        CGRect rect = CGRectMake(adjustedX, 0 ,imageWidth-adjustedX, imageHeight);
                        
                        
                        CGImageRef imageRef = CGImageCreateWithImageInRect([image CGImage], rect);
                        UIImage *img = [UIImage imageWithCGImage:imageRef];
                        NSLog(@"img orientation is %d", (int)img.imageOrientation);
                        //smaller image
                        //CGSize newImageSize = CGSizeMake(imageWidth*screenRatio, imageHeight*screenRatio);
                        UIImage* result = [self imageWithImage:img scaledToFillSize:img.size];
                        
                        if(image.imageOrientation)
                            result = [self fixOrientation:result withOrientation:image.imageOrientation];
                        
                        cell.shareImageView.image =result;
                    }
                    else if (screenRatio < imageRatio)
                    {
                        CGFloat adjustedRatio = imageRatio/screenRatio;
                        NSLog(@"adjusted ratio is %f", adjustedRatio);
                        CGFloat adjustedY = (imageHeight*adjustedRatio- imageHeight)/(2.0f);
                        NSLog(@"adjustedX is %f", adjustedY);
                        //need to make the correct rect
                        CGRect rect = CGRectMake(0, adjustedY ,imageWidth, imageHeight-adjustedY);
                        
                        CGImageRef imageRef = CGImageCreateWithImageInRect([image CGImage], rect);
                        UIImage *img = [UIImage imageWithCGImage:imageRef];
                        NSLog(@"img orientation is %d", (int)img.imageOrientation);
                        //smaller image
                        //CGSize newImageSize = CGSizeMake(imageWidth*screenRatio, imageHeight*screenRatio);
                        UIImage* result = [self imageWithImage:img scaledToFillSize:img.size];
                        
                        if(image.imageOrientation)
                            result = [self fixOrientation:result withOrientation:image.imageOrientation];
                        
                        cell.shareImageView.image =result;
                    }
                    
                    ss.contentMode = UIViewContentModeScaleToFill;
                }
                
                ss.fixedImage = cell.shareImageView.image;
                cell.shareImageView.contentMode = ss.contentMode;
                
                if(cell.tag == END_LOADING_SHARE_TAG)
                {
                    //reset comment count
                    if(_currentRow<streamShares.count)
                    {
                        [self setVoteTint];
                        [self setCommentAndLikeCountTotal:nil];
                    }
                    if(showCommentsViewController)
                    {
                        NSLog(@"showing comments fired");
                        ((ShowCommentsViewController*)showCommentsViewController).comments = ((StreamShare*)streamShares[_currentRow]).comments;
                        [[NSNotificationCenter defaultCenter] postNotificationName:@"changeComments" object:self];
                    }
                }
                cell.tag = indexPath.row;
                //CGRect screenRect = [[UIScreen mainScreen] bounds];
                //cell.shareImageView.image = [self imageWithImage:image scaledToWidth:screenRect.size.width];
                    
            }];
        }
        cell.usernameLabel.text = [NSString stringWithFormat:@"  From: %@",[share objectForKey:@"username"] ];
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
        if(!_navigationHidden)
        {
            toolBar.hidden = NO;
            lineView.hidden = NO;
        }
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
                    [self setVoteTint];
                    //reset comment count
                    [self setCommentAndLikeCountTotal:nil];
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
                [self setVoteTint];
                //reset comment count
                [self setCommentAndLikeCountTotal:nil];
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
        _streamObject.streamShares = streamShares = [[NSMutableArray alloc] initWithArray: [streamShares sortedArrayUsingComparator: ^(StreamShare* obj1, StreamShare* obj2) {
            
            //compare on created at
            return [obj1.streamShare.createdAt compare:obj2.streamShare.createdAt];
        }]];
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
    [PFCloud callFunctionInBackground:@"getNewestSharesForStream" withParameters:@{@"streamId":_streamObject.stream.objectId, @"maxShares":[NSNumber numberWithInt:SHARES_PER_PAGE], @"orderBy":@"old", @"streamShareIds":streamShareIds} block:^(id object, NSError *error) {
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
            int likeValue = ((NSNumber*)[dict objectForKey:@"likeValue"]).intValue;
            StreamShare* ss = [[StreamShare alloc] init];
            ss.streamShare = newStreamShare;
            ss.likeValue = likeValue;
            NSLog(@"like value is %d", likeValue);
            for(NSDictionary* commentDict in comments)
            {
                Comment* comment = [[Comment alloc] init];
                comment.text = commentDict[@"text"];
                comment.postingName = commentDict[@"username"];
                comment.createdAt = commentDict[@"createdAt"];
                comment.commentId = commentDict[@"commentId"];
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

- (UIImage *)imageWithImage:(UIImage *)value scaledToFillSize:(CGSize)size
{
    NSLog(@"image with size called");
    float hfactor = value.size.width / size.width;
    float vfactor = value.size.height / size.height;
    
    float factor = fmax(hfactor, vfactor);
    
    // Divide the size by the greater of the vertical or horizontal shrinkage factor
    float newWidth = value.size.width / factor;
    float newHeight = value.size.height / factor;
    
    // Then figure out if you need to offset it to center vertically or horizontally
    float leftOffset = (size.width - newWidth) / 2;
    float topOffset = (size.height - newHeight) / 2;
    
    CGRect newRect = CGRectMake(leftOffset, topOffset, newWidth, newHeight);
    
    /*CGFloat scale = MAX(size.width/image.size.width, size.height/image.size.height);
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
                                  height);*/
    
    UIGraphicsBeginImageContextWithOptions(size, NO, 0);
    [value drawInRect:newRect];
    UIImage *newImage = UIGraphicsGetImageFromCurrentImageContext();
    UIGraphicsEndImageContext();
    return newImage;
}

- (UIImage *)fixOrientation:(UIImage*)image withOrientation:(int)orientation {
    
    //NSLog(@"image orientation is %d", orientation);
    //NSLog(@"up = %d, down = %d, right = %d, left = %d", (int)UIImageOrientationUp, (int)UIImageOrientationDown, (int)UIImageOrientationRight, (int)UIImageOrientationLeft);
    
    // No-op if the orientation is already correct
    if (orientation == UIImageOrientationUp) return image;
    
    // We need to calculate the proper transformation to make the image upright.
    // We do it in 2 steps: Rotate if Left/Right/Down, and then flip if Mirrored.
    CGAffineTransform transform = CGAffineTransformIdentity;
    
    switch (orientation) {
        case UIImageOrientationDown:
        case UIImageOrientationDownMirrored:
            transform = CGAffineTransformTranslate(transform, image.size.width, image.size.height);
            transform = CGAffineTransformRotate(transform, M_PI);
            break;
            
        case UIImageOrientationLeft:
        case UIImageOrientationLeftMirrored:
            transform = CGAffineTransformTranslate(transform, image.size.width, 0);
            transform = CGAffineTransformRotate(transform, M_PI_2);
            break;
            
        case UIImageOrientationRight:
        case UIImageOrientationRightMirrored:
            transform = CGAffineTransformTranslate(transform, 0, image.size.height);
            transform = CGAffineTransformRotate(transform, -M_PI_2);
            break;
        case UIImageOrientationUp:
        case UIImageOrientationUpMirrored:
            break;
    }
    
    switch (orientation) {
        case UIImageOrientationUpMirrored:
        case UIImageOrientationDownMirrored:
            transform = CGAffineTransformTranslate(transform, image.size.width, 0);
            transform = CGAffineTransformScale(transform, -1, 1);
            break;
            
        case UIImageOrientationLeftMirrored:
        case UIImageOrientationRightMirrored:
            transform = CGAffineTransformTranslate(transform, image.size.height, 0);
            transform = CGAffineTransformScale(transform, -1, 1);
            break;
        case UIImageOrientationUp:
        case UIImageOrientationDown:
        case UIImageOrientationLeft:
        case UIImageOrientationRight:
            break;
    }
    
    // Now we draw the underlying CGImage into a new context, applying the transform
    // calculated above.
    CGContextRef ctx = CGBitmapContextCreate(NULL, image.size.width, image.size.height,
                                             CGImageGetBitsPerComponent(image.CGImage), 0,
                                             CGImageGetColorSpace(image.CGImage),
                                             CGImageGetBitmapInfo(image.CGImage));
    CGContextConcatCTM(ctx, transform);
    switch (orientation) {
        case UIImageOrientationLeft:
        case UIImageOrientationLeftMirrored:
        case UIImageOrientationRight:
        case UIImageOrientationRightMirrored:
            // Grr...
            CGContextDrawImage(ctx, CGRectMake(0,0,image.size.height,image.size.width), image.CGImage);
            break;
            
        default:
            CGContextDrawImage(ctx, CGRectMake(0,0,image.size.width,image.size.height), image.CGImage);
            break;
    }
    
    // And now we just create a new UIImage from the drawing context
    CGImageRef cgimg = CGBitmapContextCreateImage(ctx);
    UIImage *img = [UIImage imageWithCGImage:cgimg];
    CGContextRelease(ctx);
    CGImageRelease(cgimg);
    return img;
}


@end
