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

-(void) getComments
{
    NSLog(@"get comments");
}

- (void) reloadComments:(NSNotification *) notification
{
    NSLog(@"comments are %@", comments);
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
    cancelCommentButton.frame = CGRectMake(screenRect.size.width*3.0/4.0, 5, screenRect.size.width*1.0/4.0, 30.0);
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
        return comments.count;
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
/*
 // Override to support conditional editing of the table view.
 - (BOOL)tableView:(UITableView *)tableView canEditRowAtIndexPath:(NSIndexPath *)indexPath {
 // Return NO if you do not want the specified item to be editable.
 return YES;
 }
 */

/*
 // Override to support editing the table view.
 - (void)tableView:(UITableView *)tableView commitEditingStyle:(UITableViewCellEditingStyle)editingStyle forRowAtIndexPath:(NSIndexPath *)indexPath {
 if (editingStyle == UITableViewCellEditingStyleDelete) {
 // Delete the row from the data source
 [tableView deleteRowsAtIndexPaths:@[indexPath] withRowAnimation:UITableViewRowAnimationFade];
 } else if (editingStyle == UITableViewCellEditingStyleInsert) {
 // Create a new instance of the appropriate class, insert it into the array, and add a new row to the table view
 }
 }
 */

/*
 // Override to support rearranging the table view.
 - (void)tableView:(UITableView *)tableView moveRowAtIndexPath:(NSIndexPath *)fromIndexPath toIndexPath:(NSIndexPath *)toIndexPath {
 }
 */

/*
 // Override to support conditional rearranging of the table view.
 - (BOOL)tableView:(UITableView *)tableView canMoveRowAtIndexPath:(NSIndexPath *)indexPath {
 // Return NO if you do not want the item to be re-orderable.
 return YES;
 }
 */

/*
 #pragma mark - Navigation
 
 // In a storyboard-based application, you will often want to do a little preparation before navigation
 - (void)prepareForSegue:(UIStoryboardSegue *)segue sender:(id)sender {
 // Get the new view controller using [segue destinationViewController].
 // Pass the selected object to the new view controller.
 }
 */

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
    [self cancelComment:self];
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
            
            [comment saveInBackgroundWithBlock:^(BOOL succeeded, NSError *error) {
                if(error)
                {
                    NSLog(@"error is %@", error.localizedDescription);
                }
            }];
        }
        //[textField resignFirstResponder];
        [self cancelComment:self];
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



@end
