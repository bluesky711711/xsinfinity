//
//  UserInfoObj.h
//  XSInfinity
//
//  Created by Joseph Marvin Magdadaro on 7/30/18.
//  Copyright © 2018 Jerk Magz. All rights reserved.
//

#import <Foundation/Foundation.h>

@interface UserInfoObj : NSObject
@property (nonatomic,strong) NSString *userNameId;
@property (nonatomic,strong) NSString *userName;
@property (nonatomic,strong) NSString *emailId;
@property (nonatomic,strong) NSString *email;
@property (nonatomic,strong) NSString *passwordId;
@property (nonatomic,strong) NSString *password;
@property (nonatomic,strong) NSString *streetId;
@property (nonatomic,strong) NSString *street;
@property (nonatomic,strong) NSString *cityId;
@property (nonatomic,strong) NSString *city;
@property (nonatomic,strong) NSString *zipCodeId;
@property (nonatomic,strong) NSString *zipCode;
@property (nonatomic,strong) NSString *countryId;
@property (nonatomic,strong) NSString *country;
@property (nonatomic,strong) NSString *exerciseGoalId;
@property int exerciseGoal;
@property (nonatomic,strong) NSString *motivationReminderId;
@property BOOL isMotivationReminderEnabled;
@property (nonatomic,strong) NSString *habitsReminderId;
@property BOOL isHabitsReminderEnabled;
@property (nonatomic,strong) NSString *personalGoalReminderId;
@property BOOL isPersonalGoalReminderEnabled;
@property (nonatomic,strong) NSString *habitsEnableId;
@property BOOL isHabitsEnabled;
@property (nonatomic,strong) NSString *headsUpActivatedId;
@property BOOL isHeadsUpActivated;

@end
