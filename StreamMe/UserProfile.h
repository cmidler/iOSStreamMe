//
//  UserProfile.h
//  genesis
//
//  Created by Chase Midler on 9/4/14.
//  Copyright (c) 2014 midler. All rights reserved.
//

#import <Foundation/Foundation.h>
#import <Parse/Parse.h>

@interface UserProfile : NSObject //<NSCoding>
@property (strong, nonatomic) NSString *user_id;
@property (strong, nonatomic) NSString *first_name;
@property (strong, nonatomic) NSString *relationship_status;
@property (strong, nonatomic) NSString *sex;
@property (strong, nonatomic) NSString *interested_in;
//@property (strong, nonatomic) NSString *age;
@property (strong, nonatomic) NSString *birthday;
@property (strong, nonatomic) NSString *facebookID;
@property (strong, nonatomic) NSData *picture_data;
@property (strong, nonatomic) NSString *about;
@property (strong, nonatomic) NSString *is_open;
@property (strong, nonatomic) NSString *picture_data_length;
@property (strong, nonatomic) PFFile* imageFile;
//@property (strong, nonatomic) NSArray *facebookFriends;
/*
@property (nonatomic, readwrite) BOOL user_id_eom_received;
@property (nonatomic, readwrite) BOOL first_name_eom_received;
@property (nonatomic, readwrite) BOOL relationship_status_eom_received;
@property (nonatomic, readwrite) BOOL sex_eom_received;
@property (nonatomic, readwrite) BOOL interested_in_eom_received;
//@property (nonatomic, readwrite) BOOL age_eom_received;
@property (nonatomic, readwrite) BOOL birthday_eom_received;
@property (nonatomic, readwrite) BOOL facebookID_eom_received;
@property (nonatomic, readwrite) BOOL picture_data_eom_received;
@property (nonatomic, readwrite) BOOL about_eom_received;
@property (nonatomic, readwrite) BOOL is_open_eom_received;
@property (nonatomic, readwrite) BOOL picture_data_length_eom_received;
@property (nonatomic, readwrite) BOOL is_showing_professional_eom_received;
*/
@property (nonatomic, readwrite) int isComplete;
//@property (nonatomic, readwrite) int isUpdated;
@property (nonatomic, readwrite) bool isShowingProfessional;
@end
