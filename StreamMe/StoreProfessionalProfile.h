//
//  StoreProfessionalProfile.h
//  Proximity
//
//  Created by Chase Midler on 1/7/15.
//  Copyright (c) 2015 midler. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "ProfessionalProfile.h"
@interface StoreProfessionalProfile : NSObject
{
    ProfessionalProfile* profile;
}

@property ProfessionalProfile* profile;
+ (StoreProfessionalProfile *) shared;

@end
