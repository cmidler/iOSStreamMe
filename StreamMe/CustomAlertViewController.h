//
//  CustomAlertViewController.h
//  StreamMe
//
//  Created by Chase Midler on 5/4/15.
//  Copyright (c) 2015 StreamMe. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface CustomAlertViewController : UIAlertController<UIPopoverPresentationControllerDelegate>
@property (readwrite, nonatomic) enum modalPresentationStyle ;
@end
