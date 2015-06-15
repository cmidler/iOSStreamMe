//
//  ShowCommentsViewController.m
//  StreamMe
//
//  Created by Chase Midler on 6/9/15.
//  Copyright (c) 2015 StreamMe. All rights reserved.
//

#import "ShowCommentsViewController.h"

@interface ShowCommentsViewController ()

@end

@implementation ShowCommentsViewController
@synthesize streamShare;
@synthesize commentsTableView;
@synthesize commentTextField;
@synthesize commentView;
@synthesize cancelCommentButton;
@synthesize comments;

- (void)viewDidLoad {
    [super viewDidLoad];
    // Do any additional setup after loading the view.
    commentsTableView.tableFooterView = [[UIView alloc] initWithFrame:CGRectZero];
    if ([self respondsToSelector:@selector(edgesForExtendedLayout)])
        self.edgesForExtendedLayout = UIRectEdgeNone;
    
    [[NSNotificationCenter defaultCenter] addObserver:self
                                             selector:@selector(reloadComments:)
                                                 name:@"changeComments"
                                               object:nil];
    
    [self setupTextFieldView];
    if(!comments || !comments.count)
        [self getComments];
    
    NSLog(@"show comments loaded");
}

-(void) getMoreComments:(id) sender
{
    [self getComments];
}

-(void) getComments
{
    NSLog(@"get comments");
    
    NSMutableArray* commentIds = [[NSMutableArray alloc] init];
    //get array of commentIds
    for(Comment* comment in comments)
        [commentIds addObject:comment.commentId];
    ViewStreamCollectionViewController* pvc = (ViewStreamCollectionViewController*)[self parentViewController];
    
    
    PFObject* streamShareObj = [PFObject objectWithoutDataWithClassName:@"StreamShares" objectId: ((StreamShare*)pvc.streamShares[pvc.currentRow]).streamShare.objectId];
    [PFCloud callFunctionInBackground:@"getNewestCommentsForStreamShare" withParameters:@{@"streamShareId":streamShareObj.objectId, @"commentIds":commentIds} block:^(id object, NSError *error) {
        if(error)
        {
            NSLog(@"error getting streamshares");
            return;
        }
        
        NSArray* newComments = object;
        PFObject* newStreamShare = [PFObject objectWithoutDataWithClassName:@"StreamShares" objectId: ((StreamShare*)pvc.streamShares[pvc.currentRow]).streamShare.objectId];
        if([newStreamShare.objectId isEqualToString:streamShareObj.objectId])
        {
            for(NSDictionary* commentDict in newComments)
            {
                Comment* comment = [[Comment alloc] init];
                comment.text = commentDict[@"text"];
                comment.postingName = commentDict[@"username"];
                comment.createdAt = commentDict[@"createdAt"];
                comment.commentId = commentDict[@"commentId"];
                [comments addObject:comment];
            }
            [self reloadComments:nil];
        }
        
    }];
}

- (void) reloadComments:(NSNotification *) notification
{
    NSLog(@"comments are %@", comments);
    
    comments = [NSMutableArray arrayWithArray:[comments sortedArrayUsingComparator: ^(Comment* obj1, Comment* obj2) {
        
        //compare on created at
        return [obj1.createdAt compare:obj2.createdAt];
    }]];
    
    [commentsTableView reloadData];
}


-(void) setupTextFieldView
{
    NSLog(@"setting up textfieldview");
    CGRect screenRect = [[UIScreen mainScreen] bounds];
    //create a text box and bring it up as the main view
    commentTextField.frame = CGRectMake(0, 5, screenRect.size.width*3.0/4.0, 30);
    commentTextField.textColor = [UIColor whiteColor];
    commentTextField.font = [UIFont fontWithName:@"Helvetica-Bold" size:14];
    commentTextField.layer.cornerRadius = 5;
    commentTextField.clipsToBounds = YES;
    commentTextField.backgroundColor=[[UIColor grayColor] colorWithAlphaComponent:0.5];
    commentTextField.text=@"Write a comment...";
    //commentTextField.delegate = self;
    commentTextField.returnKeyType = UIReturnKeySend;
    
    //second one
    cancelCommentButton.titleLabel.font = [UIFont fontWithName:@"Helvetica-Bold" size:14];
    cancelCommentButton.backgroundColor = [UIColor clearColor];
    cancelCommentButton.frame = CGRectMake(screenRect.size.width*3.0/4.0, 5, screenRect.size.width*1.0/4.0-5, 30.0);
    cancelCommentButton.titleLabel.textAlignment = NSTextAlignmentRight;
    commentView.backgroundColor = [UIColor blackColor];
    
    [self setCommentPosition];
}

-(void) setCommentPosition
{
    CGRect screenRect = [[UIScreen mainScreen] bounds];
    commentView.frame = CGRectMake(0, self.view.frame.size.height-40, screenRect.size.width, 40);
}

- (IBAction)cancelComment:(id)sender
{
    NSLog(@"cancel comment clicked");
    [commentTextField resignFirstResponder];
    [[NSNotificationCenter defaultCenter] postNotificationName:@"dismissComments" object:self];
}


-(void) viewWillAppear:(BOOL)animated
{
    [super viewWillAppear:animated];
    NSLog(@"on view will appear view height is %f", self.view.frame.size.height);
    [self.commentsTableView addObserver:self forKeyPath:@"contentSize" options:0 context:NULL];
}

-(void) viewWillDisappear:(BOOL)animated
{
    [super viewWillDisappear:animated];
    [self.commentsTableView removeObserver:self forKeyPath:@"contentSize" context:NULL];
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView {
    // Return the number of sections.
    return 1;
}

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section {

    // Return the number of rows in the section.
    commentsTableView.backgroundColor = [UIColor blackColor];
    if(comments.count)
    {
        
        commentsTableView.backgroundView = nil;
        ViewStreamCollectionViewController* pvc = (ViewStreamCollectionViewController*)[self parentViewController];
        PFObject* streamShareObj = ((StreamShare*)pvc.streamShares[pvc.currentRow]).streamShare;
        if(((NSNumber*)[streamShareObj objectForKey:@"commentTotal"]).intValue > comments.count)
            return comments.count + 1;
        else return comments.count;
    }
    CGRect screenRect = [[UIScreen mainScreen] bounds];
    commentsTableView.backgroundView = [[UIView alloc] initWithFrame:CGRectMake(0, 0, screenRect.size.width, 100)];
    UILabel *messageLabel = [[UILabel alloc] initWithFrame:CGRectMake(0, 25, screenRect.size.width, 50)];
    messageLabel.text = @"No Comments...";
    
    /*else
     messageLabel.text = @"You are currently undiscoverable and cannot see other profiles.  Toggle discoverable in settings to see other people!";*/
    messageLabel.textColor = [UIColor whiteColor];
    messageLabel.numberOfLines = 1;
    messageLabel.textAlignment = NSTextAlignmentCenter;
    messageLabel.font = [UIFont fontWithName:@"HelveticaNeue-Italic" size:24];
    [messageLabel sizeToFit];

    [commentsTableView.backgroundView addSubview: messageLabel];
    
    return 0;
}


 - (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath
{
     ShowCommentsTableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:@"commentCell" forIndexPath:indexPath];
    cell.moreButton.hidden = YES;
    cell.commentLabel.hidden = YES;
    cell.usernameLabel.hidden = YES;
    cell.timeLabel.hidden = YES;
    [cell setUserInteractionEnabled:NO];
    cell.selectionStyle = UITableViewCellSelectionStyleNone;
    if(indexPath.row < comments.count)
    {
        cell.commentLabel.hidden = NO;
        cell.usernameLabel.hidden = NO;
        cell.timeLabel.hidden = NO;
        Comment* comment = comments[indexPath.row];
        cell.usernameLabel.text = [NSString stringWithFormat:@"From: %@",comment.postingName ];
        cell.commentLabel.text = comment.text;
        NSTimeInterval interval = [[NSDate date] timeIntervalSinceDate:comment.createdAt];
        NSLog(@"created at is %@", comment.createdAt);
        interval = interval/60;//let's get minutes accuracy
        //if more 30 minutes left then say less than the rounded up hour
        if(interval > 1440)
            cell.timeLabel.text = [NSString stringWithFormat:@"%dd ago",(int) floor(interval/1440)];
        else if(interval>60)
            cell.timeLabel.text = [NSString stringWithFormat:@"%dh ago",(int) floor(interval/60)];
        else
            cell.timeLabel.text = [NSString stringWithFormat:@"%dm ago",(int) ceil(interval)];
    }
    else
    {
        cell.moreButton.hidden = NO;
        [cell setUserInteractionEnabled:YES];
        [cell.moreButton addTarget:self
                            action:@selector(getMoreComments:)
                    forControlEvents:UIControlEventTouchUpInside];
        [self drawDashedBorderAroundView:cell.moreButton];
    }
    return cell;
 }


-(void)tableView:(UITableView *)tableView willDisplayCell:(UITableViewCell *)cell forRowAtIndexPath:(NSIndexPath *)indexPath
{
    
    // Remove seperator inset
    if ([cell respondsToSelector:@selector(setSeparatorInset:)]) {
        [cell setSeparatorInset:UIEdgeInsetsZero];
    }
    
    // Prevent the cell from inheriting the Table View's margin settings
    if ([cell respondsToSelector:@selector(setPreservesSuperviewLayoutMargins:)]) {
        [cell setPreservesSuperviewLayoutMargins:NO];
    }
    
    // Explictly set your cell's layout margins
    if ([cell respondsToSelector:@selector(setLayoutMargins:)]) {
        [cell setLayoutMargins:UIEdgeInsetsZero];
    }
    
}

-(UIView*)tableView:(UITableView *)tableView viewForHeaderInSection:(NSInteger)section
{
    if(!comments.count)
        return nil;
    UILabel *label = [[UILabel alloc] init];
    label.text=@"Comments";
    label.textColor = [UIColor whiteColor];
    label.font = [UIFont boldSystemFontOfSize:20.0];
    label.backgroundColor=[UIColor clearColor];
    label.textAlignment=NSTextAlignmentCenter;
    return label;
}

-(CGFloat)tableView:(UITableView *)tableView heightForHeaderInSection:(NSInteger)section
{
    return TABLE_VIEW_BAR_HEIGHT;
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
    //[textField resignFirstResponder];
    //[self cancelComment:self];
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
            if(!postingName)
                postingName = @"anon";
            comment[@"username"] = postingName;
            
            
            //get the streamshare
            ViewStreamCollectionViewController* pvc = (ViewStreamCollectionViewController*)[self parentViewController];
            
            
            streamShare = [PFObject objectWithoutDataWithClassName:@"StreamShares" objectId: ((StreamShare*)pvc.streamShares[pvc.currentRow]).streamShare.objectId];
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
            //creating comment object to add to comments
            Comment* commentObj = [[Comment alloc] init];
            commentObj.text = textField.text;
            commentObj.postingName = postingName;
            if(comment.createdAt)
                commentObj.createdAt = comment.createdAt;
            else
                commentObj.createdAt = [NSDate date];
            if(comment.objectId)
                commentObj.commentId = comment.objectId;
            
            [comment saveInBackgroundWithBlock:^(BOOL succeeded, NSError *error) {
                if(error)
                {
                    NSLog(@"error is %@", error.localizedDescription);
                    return;
                }
                
                //refresh to get the object id and created at properly
                [comment fetchIfNeededInBackgroundWithBlock:^(PFObject *object, NSError *error)
                 {
                     commentObj.createdAt = object.createdAt;
                     commentObj.commentId = object.objectId;
                 }];
            }];
            
            [comments addObject:commentObj];
            [self reloadComments:nil];
            pvc.didShowKeyboard = NO;
            int countComment = ((NSNumber*)[((StreamShare*)pvc.streamShares[pvc.currentRow]).streamShare objectForKey:@"commentTotal"]).intValue +1;
            NSLog(@"count comment is %d", countComment);
            [((StreamShare*)pvc.streamShares[pvc.currentRow]).streamShare setObject:[NSNumber numberWithInt:countComment ] forKey:@"commentTotal"];
            textField.text = @"Write a comment...";
            [textField resignFirstResponder];
            [[NSNotificationCenter defaultCenter] postNotificationName:@"addedComment" object:self];
            
        }
        //[self cancelComment:self];
        //[self dismissComment];
    }
    return YES;
}

//observer to make sure we adjust the height of the tableview properly
- (void)observeValueForKeyPath:(NSString *)keyPath ofObject:(id)object change:(NSDictionary *)change context:(void *)context
{
    [self redoHeight];
}




-(void) redoHeight
{
    //NSLog(@"key path is %@", keyPath);
    NSLog(@"tableview height constraint is %f", _tableViewHeightConstraint.constant);
    //NSLog(@"view height constraint is %f",  _heightConstraint.constant);
    CGRect frame = self.commentsTableView.frame;
    frame.size = self.commentsTableView.contentSize;
    CGRect screenRect = [[UIScreen mainScreen] bounds];
    CGFloat screenHeight = screenRect.size.height;
    NSLog(@"keyboard height is %f", _keyboardHeight);
    ViewStreamCollectionViewController* pvc = (ViewStreamCollectionViewController*)[self parentViewController];
    CGFloat MAX_HEIGHT = screenHeight-TOOLBAR_HEIGHT-40-_keyboardHeight-pvc.navigationController.navigationBar.frame.size.height;
    CGFloat MIN_HEIGHT = 100;
    
    if(MAX_HEIGHT < frame.size.height)
    {
        [_tableViewHeightConstraint setConstant:MAX_HEIGHT];
        frame.size.height = MAX_HEIGHT;
    }
    else if(MIN_HEIGHT> frame.size.height)
    {
        [_tableViewHeightConstraint setConstant:MIN_HEIGHT];
        frame.size.height = MIN_HEIGHT;
    }
    else
        [_tableViewHeightConstraint setConstant:frame.size.height];
    //[_heightConstraint setConstant:(frame.size.height + _pictureImageView.frame.size.height) + mutualFriendsCollectionView.frame.size.height];
    
    
    /*NSLayoutConstraint* newHeightCon = [NSLayoutConstraint ]
     
     [self.dynamicView addConstraints:[NSLayoutConstraint constraintsWithVisualFormat:[NSString stringWithFormat: @"V:[dynamicView(==%f)]", self.profileTableView.frame.size.height + _pictureImageView.image.size.height]
     options:0
     metrics:nil
     views:NSDictionaryOfVariableBindings(self.dynamicView)]];*/
    NSLog(@"height is %f", frame.size.height);
    CGRect viewFrame = CGRectMake(0, screenHeight-frame.size.height-40-TOOLBAR_HEIGHT-_keyboardHeight, screenRect.size.width, frame.size.height+40);
    self.view.frame = viewFrame;
    [self setPreferredContentSize:viewFrame.size];
    [self setCommentPosition];
    [self.view layoutIfNeeded];
}

- (void)drawDashedBorderAroundView:(UIView *)v
{
    //border definitions
    CGFloat cornerRadius = 10;
    CGFloat borderWidth = 2;
    NSInteger dashPattern1 = 8;
    NSInteger dashPattern2 = 8;
    UIColor *lineColor = [UIColor whiteColor];
    
    //drawing
    CGRect frame = v.bounds;
    
    CAShapeLayer *_shapeLayer = [CAShapeLayer layer];
    
    //creating a path
    CGMutablePathRef path = CGPathCreateMutable();
    
    //drawing a border around a view
    CGPathMoveToPoint(path, NULL, 0, frame.size.height - cornerRadius);
    CGPathAddLineToPoint(path, NULL, 0, cornerRadius);
    CGPathAddArc(path, NULL, cornerRadius, cornerRadius, cornerRadius, M_PI, -M_PI_2, NO);
    CGPathAddLineToPoint(path, NULL, frame.size.width - cornerRadius, 0);
    CGPathAddArc(path, NULL, frame.size.width - cornerRadius, cornerRadius, cornerRadius, -M_PI_2, 0, NO);
    CGPathAddLineToPoint(path, NULL, frame.size.width, frame.size.height - cornerRadius);
    CGPathAddArc(path, NULL, frame.size.width - cornerRadius, frame.size.height - cornerRadius, cornerRadius, 0, M_PI_2, NO);
    CGPathAddLineToPoint(path, NULL, cornerRadius, frame.size.height);
    CGPathAddArc(path, NULL, cornerRadius, frame.size.height - cornerRadius, cornerRadius, M_PI_2, M_PI, NO);
    
    //path is set as the _shapeLayer object's path
    _shapeLayer.path = path;
    CGPathRelease(path);
    
    _shapeLayer.backgroundColor = [[UIColor clearColor] CGColor];
    _shapeLayer.frame = frame;
    _shapeLayer.masksToBounds = NO;
    [_shapeLayer setValue:[NSNumber numberWithBool:NO] forKey:@"isCircle"];
    _shapeLayer.fillColor = [[UIColor clearColor] CGColor];
    _shapeLayer.strokeColor = [lineColor CGColor];
    _shapeLayer.lineWidth = borderWidth;
    _shapeLayer.lineDashPattern = [NSArray arrayWithObjects:[NSNumber numberWithInteger:dashPattern1], [NSNumber numberWithInteger:dashPattern2], nil];
    _shapeLayer.lineCap = kCALineCapRound;
    
    //_shapeLayer is added as a sublayer of the view, the border is visible
    [_shapeLayer removeFromSuperlayer];
    [v.layer addSublayer:_shapeLayer];
    v.layer.cornerRadius = cornerRadius;
}


@end
