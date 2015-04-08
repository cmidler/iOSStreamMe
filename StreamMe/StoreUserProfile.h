//
//  StoreUserProfile.h
//  genesis
//
//  Created by Chase Midler on 9/4/14.
//  Copyright (c) 2014 midler. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "UserProfile.h"
@interface StoreUserProfile : NSObject
{
    UserProfile* profile;
}

@property UserProfile* profile;
+ (StoreUserProfile *) shared;
@end
