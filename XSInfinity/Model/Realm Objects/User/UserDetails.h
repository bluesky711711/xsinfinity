//
//  UserDetails.h
//  XSInfinity
//
//  Created by Joseph Marvin Magdadaro on 07/04/2019.
//  Copyright © 2019 Jerk Magz. All rights reserved.
//

#import "RLMObject.h"

@interface UserDetails : RLMObject
@property (nonatomic,assign) int rowId;
@property (nonatomic,strong) NSString *access_token;
@property (nonatomic,strong) NSString *userId;
@property (nonatomic,strong) NSString *name;
@property (nonatomic,strong) NSString *email;
@property (nonatomic,strong) NSString *gender;
@property (nonatomic,strong) NSString *address;
@property (nonatomic,strong) NSString *postal_code;
@property (nonatomic,strong) NSString *last_login;
@property (nonatomic,strong) NSString *avatarURL;
@property (nonatomic,strong) NSString *creationDate;
@property (nonatomic,assign) BOOL habitStatus;
@property (nonatomic,assign) BOOL is_active;
@property (nonatomic,assign) BOOL is_trashed;
@end
