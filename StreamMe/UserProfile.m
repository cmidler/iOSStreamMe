//
//  UserProfile.m
//  genesis
//
//  Created by Chase Midler on 9/4/14.
//  Copyright (c) 2014 midler. All rights reserved.
//

#import "UserProfile.h"

@implementation UserProfile
- (UserProfile *) init {
    self = [super init];
    if (self) {
        _user_id = [[NSString alloc] init];
        _first_name = [[NSString alloc] init];
        _sex = [[NSString alloc] init];
        _relationship_status = [[NSString alloc] init];
        _picture_data = [[NSData alloc] init];
        //_age = [[NSString alloc] init];
        _birthday = [[NSString alloc] init];
        _interested_in = [[NSString alloc] init];
        _about = [[NSString alloc]init];
        _facebookID = [[NSString alloc]init];
        _is_open = [[NSString alloc]init];
        _picture_data_length = [[NSString alloc]init];
        _imageFile = [[PFFile alloc] init];
        /*
        _user_id_eom_received = NO;
        _first_name_eom_received = NO;
        _sex_eom_received = NO;
        _relationship_status_eom_received = NO;
        _picture_data_eom_received = NO;
        //_age_eom_received = NO;
        _birthday_eom_received = NO;
        _interested_in_eom_received = NO;
        _about_eom_received = NO;
        _facebookID_eom_received = NO;
        _is_open_eom_received = NO;
        _picture_data_length_eom_received = NO;
        _is_showing_professional_eom_received = NO;*/
        
        
        _isComplete = 0;
        //_isUpdated = 0;
        _isShowingProfessional = NO;
       // _facebookFriends = [[NSArray alloc] init];
    }
    return self;

}

/*
- (void)encodeWithCoder:(NSCoder *)coder {
    [coder encodeObject:_first_name forKey:@"user_id"];
    [coder encodeObject:_first_name forKey:@"first_name"];
    [coder encodeObject:_sex forKey:@"sex"];
    [coder encodeObject:_relationship_status forKey:@"relationship_status"];
    [coder encodeObject:_picture_data forKey:@"picture_data"];
    [coder encodeObject:_birthday forKey:@"birthday"];
    [coder encodeObject:_interested_in forKey:@"interested_in"];
    [coder encodeObject:_about forKey:@"about"];
    [coder encodeObject:_facebookID forKey:@"facebookID"];
    [coder encodeObject:_is_open forKey:@"is_open"];
    [coder encodeObject:_picture_data_length forKey:@"picture_data_length"];
    [coder encodeInt:_isComplete forKey:@"isComplete"];
}

- (id)initWithCoder:(NSCoder *)coder {
    self = [self init];
    self.first_name = [coder decodeObjectForKey:@"user_id"];
    self.first_name = [coder decodeObjectForKey:@"first_name"];
    self.sex = [coder decodeObjectForKey:@"sex"];
    self.relationship_status = [coder decodeObjectForKey:@"relationship_status"];
    self.picture_data = [coder decodeObjectForKey:@"picture_data"];
    self.birthday = [coder decodeObjectForKey:@"birthday"];
    self.interested_in = [coder decodeObjectForKey:@"interested_in"];
    self.about = [coder decodeObjectForKey:@"about"];
    self.facebookID = [coder decodeObjectForKey:@"facebookID"];
    self.is_open = [coder decodeObjectForKey:@"is_open"];
    self.picture_data_length = [coder decodeObjectForKey:@"picture_data_length"];
    self.isComplete = [coder decodeIntForKey:@"isComplete"];
    return self;
}*/
@end
