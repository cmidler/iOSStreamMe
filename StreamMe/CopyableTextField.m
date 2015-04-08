//
//  CopyableTextField.m
//  Proximity
//
//  Created by Chase Midler on 1/4/15.
//  Copyright (c) 2015 midler. All rights reserved.
//

#import "CopyableTextField.h"

@implementation CopyableTextField

- (BOOL)canPerformAction:(SEL)action withSender:(id)sender {
    if(action == @selector(copy:)) {
        return YES;
    }
    else {
        return [super canPerformAction:action withSender:sender];
    }
}


- (BOOL)canBecomeFirstResponder {
    return YES;
}


- (BOOL)becomeFirstResponder {
    if([super becomeFirstResponder]) {
        self.highlighted = YES;
        return YES;
    }
    return NO;
}


- (void)copy:(id)sender {
    UIPasteboard *board = [UIPasteboard generalPasteboard];
    [board setString:self.text];
    self.highlighted = NO;
    [self resignFirstResponder];
}


- (void)touchesEnded:(NSSet *)touches withEvent:(UIEvent *)event {
    if([self isFirstResponder]) {
        self.highlighted = NO;
        UIMenuController *menu = [UIMenuController sharedMenuController];
        [menu setMenuVisible:NO animated:YES];
        [menu update];
        [self resignFirstResponder];
    }
    else if([self becomeFirstResponder]) {
        UIMenuController *menu = [UIMenuController sharedMenuController];
        [menu setTargetRect:self.bounds inView:self];
        [menu setMenuVisible:YES animated:YES];
    }
}

@end
