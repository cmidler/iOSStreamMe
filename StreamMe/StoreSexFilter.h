//
//  StoreSexFilter.h
//  genesis
//
//  Created by Chase Midler on 10/1/14.
//  Copyright (c) 2014 midler. All rights reserved.
//

#import <Foundation/Foundation.h>

@interface StoreSexFilter : NSObject
{
    NSString* sex_filter;
}

@property NSString* sex_filter;
+ (StoreSexFilter *) shared;
@end
