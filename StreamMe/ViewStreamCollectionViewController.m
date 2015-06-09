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
@synthesize composeComment;
@synthesize toolBar;
@synthesize lineView;
@synthesize commentTextField;
@synthesize commentView;
@synthesize cancelCommentButton;
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
}

- (void)keyboardWillShow:(NSNotification *)notification
{
    commentView.hidden = NO;
    [self.view layoutIfNeeded];
    // Get the size of the keyboard.
    CGRect keyboard = [[[notification userInfo] objectForKey:UIKeyboardFrameBeginUserInfoKey] CGRectValue];
    NSTimeInterval duration = [[[notification userInfo] objectForKey:UIKeyboardAnimationDurationUserInfoKey] doubleValue];
    UIViewAnimationCurve curve = [[[notification userInfo] objectForKey:UIKeyboardAnimationCurveUserInfoKey] intValue];
    CGRect screenRect = [[UIScreen mainScreen] bounds];
    
    NSLog(@"keyboard height is %f", keyboard.size.height);
    
    [UIView animateWithDuration:duration
                     animations:^{
                         [UIView setAnimationCurve:curve];
                         //hack because it isn't giving the proper notification
                         if(_didShowKeyboard)
                         {
                             if(keyboard.size.height == 224)
                                 commentView.frame = CGRectMake(0, screenRect.size.height-keyboard.size.height-29-40, screenRect.size.width, 40);
                             else
                                 commentView.frame = CGRectMake(0, screenRect.size.height-keyboard.size.height+29-40, screenRect.size.width, 40);
                         }
                         else
                             commentView.frame = CGRectMake(0, screenRect.size.height-keyboard.size.height-40, screenRect.size.width, 40);
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
    [self.navigationController.navigationBar setBackgroundColor:[[UIColor blackColor] colorWithAlphaComponent:0.2]];
    [self.navigationController.navigationBar setTranslucent:YES];

    [self.navigationController.navigationBar setBarTintColor:[[UIColor blackColor] colorWithAlphaComponent:0.2]];
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
    composeComment = [[UIBarButtonItem alloc] initWithImage:[UIImage imageNamed:@"compose.png"] style:UIBarButtonItemStyleDone target:self action:@selector(compose:)];
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
    [toolBar setBackgroundColor:[[UIColor blackColor] colorWithAlphaComponent:0.2]];
    [toolBar setTranslucent:YES];
    
    
    [self.view addSubview:lineView];
    [self.view addSubview:toolBar];
    [self.view bringSubviewToFront:lineView];
    [self.view bringSubviewToFront:toolBar];
    
}

-(void) compose:(id)sender
{
    NSLog(@"current row is %d", (int) _currentRow);
    CGRect screenRect = [[UIScreen mainScreen] bounds];
    
    //create a text box and bring it up as the main view
    commentTextField = [[UITextField alloc] initWithFrame:CGRectMake(0, 5, screenRect.size.width*3.0/4.0, 30)];
    commentTextField.textColor = [UIColor whiteColor];
    commentTextField.font = [UIFont fontWithName:@"Helvetica-Bold" size:14];
    commentTextField.layer.cornerRadius = 5;
    commentTextField.clipsToBounds = YES;
    commentTextField.backgroundColor=[[UIColor grayColor] colorWithAlphaComponent:0.5];
    commentTextField.text=@"Write a comment...";
    commentTextField.delegate = self;
    commentTextField.returnKeyType = UIReturnKeySend;
    
    //second one
    cancelCommentButton = [UIButton buttonWithType:UIButtonTypeSystem];
    [cancelCommentButton addTarget:self
                            action:@selector(cancelComment:)
                  forControlEvents:UIControlEventTouchUpInside];
    [cancelCommentButton setTitle:@"Cancel" forState:UIControlStateNormal];
    [cancelCommentButton setTitleColor:[UIColor whiteColor] forState:UIControlStateNormal];
    cancelCommentButton.titleLabel.font = [UIFont fontWithName:@"Helvetica-Bold" size:14];
    cancelCommentButton.backgroundColor = [UIColor clearColor];
    cancelCommentButton.frame = CGRectMake(screenRect.size.width*3.0/4.0, 5, screenRect.size.width*1.0/4.0, 30.0);
    cancelCommentButton.titleLabel.textAlignment = NSTextAlignmentRight;
    commentView = [[UIView alloc] initWithFrame:CGRectMake(0, screenRect.size.height*3.0/4.0, screenRect.size.width, 40)];
    commentView.backgroundColor = [UIColor blackColor];
    [commentView addSubview:cancelCommentButton];
    [commentView addSubview:commentTextField];
    //[view addSubview:tf1];
    commentView.hidden = YES;
    [self.view addSubview:commentView];
    _didShowKeyboard = NO;
    [commentTextField becomeFirstResponder];
    
    
}

-(void) cancelComment:(id)sender
{
    [self dismissComment];
}

-(void) dismissComment
{
    [commentTextField resignFirstResponder];
    commentTextField = nil;
    cancelCommentButton = nil;
    if(commentView && commentView.superview)
       [commentView removeFromSuperview];
    commentView = nil;
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
    [self performSegueWithIdentifier:@"popSegue" sender:self];
}

-(void) galleryButton:(id) sender
{
    UITapGestureRecognizer *gesture = (UITapGestureRecognizer *) sender;
    _currentRow = (int)gesture.view.tag;
    
    [self performSegueWithIdentifier:@"gallerySegue" sender:self];
}

-(void) pictureTapped:(id) sender
{
    NSLog(@"picture is tapped");
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
    toolBar.hidden = YES;
    lineView.hidden = YES;
    cell.shareImageView.frame = CGRectMake(0, 0, width, height);
    cell.usernameLabel.frame = CGRectMake(0, height-5.0/2.0*TOOLBAR_HEIGHT, width, TOOLBAR_HEIGHT/2+1);
    cell.captionTextView.frame = CGRectMake(0,height-2*TOOLBAR_HEIGHT, width, TOOLBAR_HEIGHT);
    cell.createdLabel.frame = CGRectMake(0, height-5.0/2.0*TOOLBAR_HEIGHT, width, TOOLBAR_HEIGHT/2+1);
    
    //[cell.shareImageView setContentMode:UIViewContentModeScaleToFill];
    cell.shareImageView.translatesAutoresizingMaskIntoConstraints = YES;
    cell.usernameLabel.translatesAutoresizingMaskIntoConstraints = YES;
    cell.createdLabel.translatesAutoresizingMaskIntoConstraints = YES;
    cell.captionTextView.translatesAutoresizingMaskIntoConstraints = YES;
    cell.createdLabel.backgroundColor = [UIColor clearColor];
    cell.captionTextView.backgroundColor = [[UIColor blackColor] colorWithAlphaComponent:0.2];
    cell.usernameLabel.backgroundColor = [[UIColor blackColor] colorWithAlphaComponent:0.2];
    cell.shareImageView.contentMode = UIViewContentModeScaleAspectFill;
    
    
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
        
        NSIndexPath *indexPath = [streamCollectionView indexPathForCell:cell];
        _currentRow = indexPath.row;
        
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

//Delegates for helping textview have placeholder text
- (void)textFieldDidBeginEditing:(UITextField *)textField
{
    /*if ([textField.text isEqualToString:@""] || [textField.text isEqualToString:@"Write a comment..."])
    {
        textField.text = @"";
    }*/
    [textField becomeFirstResponder];
}

//Continuation delegate for placeholder text
- (void)textFieldDidEndEditing:(UITextField *)textField
{
    if ([textField.text isEqualToString:@""] || [textField.text isEqualToString:@"Write a comment..."])
    {
        textField.text = @"Write a comment...";
    }
    [textField resignFirstResponder];
    [self dismissComment];
}


//used for updating status
- (BOOL)textField:(UITextField *)textField
shouldChangeCharactersInRange:(NSRange)range
replacementString:(NSString *)text
{
    
    //check if they user is trying to enter too many characters
    if([[textField text] length] - range.length + text.length > MAX_COMMENT_CHARS && ![text isEqualToString:@"\n"])
    {
        return NO;
    }
    
    if([textField.text isEqualToString:@"Write a comment..."])
    {
        textField.text = @"";
    }
    
    //Make return key try to save the new status
    if([text isEqualToString:@"\n"])
    {
        //save the new posting name
        if(textField.text && !([textField.text isEqualToString:@""] || [textField.text isEqualToString:@"Write a comment..."]))
        {
            //save the comment
            PFObject* comment = [PFObject objectWithClassName:@"Comment"];
            PFUser* user = [PFUser currentUser];
            comment[@"user"] = user;
            NSString* postingName = [user objectForKey:@"posting_name"];
            if(postingName)
                comment[@"username"] = postingName;
            else
                comment[@"username"] = @"anon";
            
            //get the streamshare
            PFObject* streamShare = [PFObject objectWithoutDataWithClassName:@"StreamShares" objectId: ((PFObject*)streamShares[_currentRow]).objectId];
            NSLog(@"streamshare id is %@", streamShare.objectId);
            comment[@"stream_share"] = streamShare;
            comment[@"text"] = textField.text;
            //Create the default acl
            PFACL *defaultACL = [PFACL ACL];
            [defaultACL setReadAccess:true forUser:user];
            [defaultACL setWriteAccess:true forUser:user];
            [defaultACL setPublicReadAccess:false];
            [defaultACL setPublicWriteAccess:false];
            [comment setACL:defaultACL];
            
            NSLog(@"comment is %@", comment);
            
            [comment saveInBackgroundWithBlock:^(BOOL succeeded, NSError *error) {
                if(error)
                {
                    NSLog(@"error is %@", error.localizedDescription);
                }
            }];
        }
        [textField resignFirstResponder];
        [self dismissComment];
    }
    return YES;
}


@end
