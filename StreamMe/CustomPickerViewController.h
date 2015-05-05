//
//  CustomPickerViewController.h
//  WhoYu
//
//  Created by Chase Midler on 3/26/15.
//  Copyright (c) 2015 midler. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "PopoverViewController.h"
@interface CustomPickerViewController : UIImagePickerController<UIPopoverPresentationControllerDelegate>
@property (nonatomic, readwrite) bool canTakePicture;
@end
