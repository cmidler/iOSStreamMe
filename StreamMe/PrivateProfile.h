//
//  PrivateProfile.h
//  WhoYu
//
//  Created by Chase Midler on 1/26/15.
//  Copyright (c) 2015 midler. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "Email.h"
#import "Phone.h"
@interface PrivateProfile : NSObject

@property (strong, nonatomic) NSMutableArray* phoneNumbers;
@property (strong, nonatomic) NSMutableArray* emailAddresses;

@end
