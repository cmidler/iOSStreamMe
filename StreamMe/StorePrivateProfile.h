//
//  StorePrivateProfile.h
//  WhoYu
//
//  Created by Chase Midler on 1/26/15.
//  Copyright (c) 2015 midler. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "PrivateProfile.h"

@interface StorePrivateProfile : NSObject
{
    PrivateProfile* profile;
}

@property PrivateProfile* profile;
+ (StorePrivateProfile *) shared;
@end
