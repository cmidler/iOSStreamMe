//
//  UserNotesViewController.m
//  WhoYu
//
//  Created by Chase Midler on 2/3/15.
//  Copyright (c) 2015 midler. All rights reserved.
//

#import "UserNotesViewController.h"

@interface UserNotesViewController ()

@end

@implementation UserNotesViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    
    UITapGestureRecognizer *tap = [[UITapGestureRecognizer alloc]
                                   initWithTarget:self
                                   action:@selector(dismissKeyboard)];
    tap.cancelsTouchesInView = NO;
    [self.view addGestureRecognizer:tap];
    
    _notes = @"";
    
    self.navigationItem.title = [NSString stringWithFormat:@"%@ Notes", _profile.first_name];
    
    //setup the views properly
    [self getNotes];
}

//TEXT VIEW DELEGATES
- (void) dismissKeyboard
{
    [_noteTextView resignFirstResponder];
}

//Delegates for helping textview have placeholder text
- (void)textViewDidBeginEditing:(UITextView *)textView
{
    textView.textColor = [UIColor blackColor];
    if( !textView.text.length || [textView.text isEqualToString:@"Add Notes"])
    {
        textView.text = @"Add Notes";
        textView.textColor = [UIColor grayColor];
    }
    
    [textView becomeFirstResponder];
}

//Continuation delegate for placeholder text
- (void)textViewDidEndEditing:(UITextView *)textView
{
    textView.textColor = [UIColor blackColor];
    //resign first responder
    if (!textView.text.length || [textView.text isEqualToString:@"Add Notes"])
    {
        textView.text = @"Add Notes";
        textView.textColor = [UIColor grayColor];
        _notes = textView.text;
    }
    [textView resignFirstResponder];
    
}


-(void)textViewDidChange:(UITextView *)textView
{
    _notes = textView.text;
    textView.textColor = [UIColor blackColor];
    if(!textView.text.length)
    {
        textView.textColor = [UIColor grayColor];
        textView.text = @"Add Notes";
    }
}

//used for updating status
- (BOOL)textView:(UITextView *)textView
shouldChangeTextInRange:(NSRange)range
 replacementText:(NSString *)text
{
    
    //check if they user is trying to enter too many characters
    if(([[textView text] length] - range.length + text.length > MAX_NOTES_CHARS) && ![text isEqualToString:@"\n"])
    {
        return NO;
    }
    
    //reset the text
    if([textView.text isEqualToString:@"Add Notes"])
    {
        //if backspace don't replace
        if(!text.length)
            return NO;
        textView.text = text;
        textView.textColor = [UIColor blackColor];
        return NO;
    }
    
    return YES;
}


//helper function to get notes from database
-(void) getNotes
{
    //get the main database
    MainDatabase* md = [MainDatabase shared];
    [md.queue inDatabase:^(FMDatabase *db) {
        //need to see if the user is saved or not
        NSString *userQuery = @"SELECT notes FROM user WHERE user_id = ?";
        NSArray* values = @[_profile.user_id];
        FMResultSet* s =[db executeQuery:userQuery withArgumentsInArray:values];
        
        ///check the notes
        if ([s next])
        {
            _notes = [s stringForColumnIndex:0];
        }
    
        _noteTextView.textColor = [UIColor blackColor];
        //setting up the text view
        if(_notes.length && ![_notes isEqualToString:@"Add Notes"])
        {
            _noteTextView.text = _notes;
        }
        else
        {
            _noteTextView.text = @"Add Notes";
            _noteTextView.textColor = [UIColor grayColor];
        }
        [_noteTextView becomeFirstResponder];
    }];
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}


- (IBAction)saveAction:(id)sender {
    
    _saveButton.enabled = NO;
    [_activityIndicator startAnimating];
    
    //making sure notes are not empty
    if(!_notes.length)
        _notes = @"Add Notes";
    
    //get the main database
    MainDatabase* md = [MainDatabase shared];
    [md.queue inDatabase:^(FMDatabase *db) {
        //need to see if the user is saved or not
        NSString *countQuery = @"SELECT user_id FROM user WHERE user_id = ?";
        NSArray* values = @[_profile.user_id];
        FMResultSet* s =[db executeQuery:countQuery withArgumentsInArray:values];
        
        bool hasUser = NO;
        
        //check for the user
        if ([s next])
        {
            hasUser = YES;
        }
        
        //update notes
        if(hasUser)
        {
            //Now getting users from database
            NSString *updateUserSQL = @"UPDATE user SET notes = ? WHERE user_id = ?";
            values = @[_notes, _profile.user_id];
            [db executeUpdate:updateUserSQL withArgumentsInArray:values];
            
        }
        //insert the user
        else
        {
            NSString *insertUserSQL = @"INSERT INTO user (user_id, is_me, created_at, notes) VALUES (?, ?, ?, ?)";
            values = @[_profile.user_id,[NSNumber numberWithInt:0], [NSNumber numberWithDouble:[[NSDate date] timeIntervalSince1970]], _notes];
            [db executeUpdate:insertUserSQL withArgumentsInArray:values];
        }
        _saveButton.enabled = YES;
        [_activityIndicator stopAnimating];
        [self performSegueWithIdentifier:@"viewProfileSegue" sender:self];
        
    }];
}
// In a storyboard-based application, you will often want to do a little preparation before navigation
- (void)prepareForSegue:(UIStoryboardSegue *)segue sender:(id)sender
{
    if([segue.identifier isEqualToString:@"viewProfileSegue"])
    {
        UINavigationController *navController = segue.destinationViewController;
        ViewProfileViewController* controller = [navController childViewControllers].firstObject;
        controller.profile = _profile;
    }
}

- (IBAction)cancelAction:(id)sender {
    [self performSegueWithIdentifier:@"viewProfileSegue" sender:self];
}
@end
