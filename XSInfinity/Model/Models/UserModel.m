//
//  UserModel.m
//  XSInfinity
//
//  Created by Joseph Marvin Magdadaro on 6/6/18.
//  Copyright © 2018 Joseph Marvin Magdadaro. All rights reserved.
//

#import "UserModel.h"
#import <Realm/Realm.h>
#import "Helper.h"
#import "GalleryObj.h"
#import "PurchaseHistoryObj.h"
#import "ModulesModel.h"
#import "Gallery.h"
#import "UserMedia.h"
#import "UserPerformance.h"

@implementation UserModel

+ (instancetype)sharedInstance
{
    static dispatch_once_t onceToken;
    static UserModel *sharedInstance;
    
    dispatch_once(&onceToken, ^{
        sharedInstance = [[self alloc] init];
    });
    
    return sharedInstance;
}

- (void)saveUserToken:(NSString *)token{
    RLMRealm *realm = [RLMRealm defaultRealm];
    UserDetails *obj = [[UserDetails alloc] init];
    
    obj.rowId = 1;
    obj.access_token = token;
    
    [realm beginWriteTransaction];
    [realm addOrUpdateObject:obj];
    [realm commitWriteTransaction];
}

- (NSString *)accessToken{
    RLMResults *res = [UserDetails allObjects];
    if(res.count == 0){
        return nil;
    }
    
    UserDetails *obj = [res firstObject];
    return obj.access_token;
}

- (HeadUpObj *)getTodaysHeadUpFromJson:(NSDictionary *)json{
    HeadUpObj *obj = [HeadUpObj new];
    obj.personalExerciseGoal = [[[Helper sharedHelper] cleanValue:json[@"personalExerciseGoal"]] intValue];
    obj.passedExercises = [[[Helper sharedHelper] cleanValue:json[@"passedExercises"]] intValue];
    obj.possibleHabits = [[[Helper sharedHelper] cleanValue:json[@"possibleHabits"]] intValue];
    obj.passedHabits = [[[Helper sharedHelper] cleanValue:json[@"passedHabits"]] intValue];
    obj.resetHabitTracker = [[[Helper sharedHelper] cleanValue:json[@"resetHabitTracker"]] boolValue];
    
    obj.unlockedExercises = [[ModulesModel sharedInstance] getExercisesFromJson:json[@"unlockedExercises"]];
    
    return obj;
}

- (void)saveUserCommunitySummary:(NSDictionary *)json{
    RLMRealm *realm = [RLMRealm defaultRealm];
    UserSummary *obj = [[UserSummary alloc] init];
    
    obj.summaryId = 1;
    obj.communityRank = [[[Helper sharedHelper] cleanValue:json[@"communityRank"]] intValue];
    obj.exercisePoints = [[[Helper sharedHelper] cleanValue:json[@"exercisePoints"]] intValue];
    obj.habitPoints = [[[Helper sharedHelper] cleanValue:json[@"habitPoints"]] intValue];
    obj.communityRankChangePreviousWeek = [[[Helper sharedHelper] cleanValue:json[@"communityRankChangePreviousWeek"]] intValue];
    obj.communityRankChangePreviousWeekPercent = [[[Helper sharedHelper] cleanValue:json[@"communityRankChangePreviousWeekPercent"]] intValue];
    
    [realm beginWriteTransaction];
    [realm addOrUpdateObject:obj];
    [realm commitWriteTransaction];
    
}

- (UserSummary *)getUserCommunitySummary{
    RLMResults *res = [UserSummary allObjects];
    
    UserSummary *obj = [res firstObject];
    
    return obj;
}

- (void)saveUserPerformance:(NSDictionary *)json{
    RLMRealm *realm = [RLMRealm defaultRealm];
    
    [realm beginWriteTransaction];
    [realm deleteObjects:[UserPerformance allObjects]];
    [realm commitWriteTransaction];
    
    NSArray *types = [json allKeys];
    for (int i=0; i<[types count]; i++) {
        NSString *type = types[i];
        
        NSArray *dateTypes = [json[type] allKeys];
        for (int h=0; h<[dateTypes count]; h++) {
            NSString *dateType = dateTypes[h];
            
            for (NSDictionary *performance in json[type][dateType]) {
                
                UserPerformance *obj = [[UserPerformance alloc] init];
                obj.performanceType = type;
                obj.performanceDateType = dateType;
                obj.performanceDate = [[Helper sharedHelper] cleanValue:performance[@"date"]];
                obj.points = [[[Helper sharedHelper] cleanValue:performance[@"points"]] intValue];
                
                [realm beginWriteTransaction];
                [realm addObject:obj];
                [realm commitWriteTransaction];
            }
        }
    }
}

- (NSArray *)getUserPerformanceFor:(NSString *)type withDateType:(NSString *)dateType{
    NSPredicate *predicate = [NSPredicate predicateWithFormat:@"performanceType == %@ AND performanceDateType == %@", type, dateType];
    RLMResults *res = [UserPerformance objectsWithPredicate:predicate];
    
    NSMutableArray *result = [NSMutableArray array];
    for (RLMObject *object in res) {
        [result addObject:object];
    }
    
    return [result mutableCopy];
}

- (UserPerformance *)getUserPerformanceFor:(NSString *)type withDateType:(NSString *)dateType andDate:(NSString *)dateStr{
    NSString *paddedDateStr = dateStr;
    NSArray *dateArr = [dateStr componentsSeparatedByString:@"-"];
    
    //date (YYYY-mm-dd)
    if(dateArr.count > 2){
        paddedDateStr = [NSString stringWithFormat:@"%@-%02d-%02d",dateArr[0], [dateArr[1] intValue], [dateArr[2] intValue]];
    }else{
        paddedDateStr = [NSString stringWithFormat:@"%@-%02d",dateArr[0], [dateArr[1] intValue]];
    }
    
    NSPredicate *predicate = [NSPredicate predicateWithFormat:@"performanceType == %@ AND performanceDateType == %@ AND (performanceDate == %@ OR performanceDate == %@)", type, dateType, dateStr, paddedDateStr];
    RLMResults *res = [UserPerformance objectsWithPredicate:predicate];

    return res.count > 0 ?[res firstObject] :nil;
}

- (NSArray *)getUserPerformanceThatContains:(NSString *)yearAndMonth{
    NSArray *dateArr = [yearAndMonth componentsSeparatedByString:@"-"];
    NSString *paddedDateStr = [NSString stringWithFormat:@"%@-%02d",dateArr[0], [dateArr[1] intValue]];
    
    NSPredicate *predicate = [NSPredicate predicateWithFormat:@"performanceDateType == %@ AND (performanceDate CONTAINS[cd] %@ OR performanceDate CONTAINS[cd] %@)", @"days", yearAndMonth, paddedDateStr];
    RLMResults *res = [[UserPerformance objectsWithPredicate:predicate] sortedResultsUsingKeyPath:@"performanceDate" ascending:YES];
    
    NSMutableArray *result = [NSMutableArray array];
    for (RLMObject *object in res) {
        [result addObject:object];
    }
    
    return [result mutableCopy];
}

- (void)saveUserInfo:(NSDictionary *)json{
    RLMRealm *realm = [RLMRealm defaultRealm];
    UserInfo *obj = [[UserInfo alloc] init];
    
    obj.infoId = 1;
    
    if(json[@"user_name"] != nil) {
        obj.userNameId = [[Helper sharedHelper] cleanValue:json[@"user_name"][@"name"]];
        obj.userName = [[Helper sharedHelper] cleanValue:json[@"user_name"][@"value"]];
    }
    
    if(json[@"email"] != nil) {
        obj.emailId = [[Helper sharedHelper] cleanValue:json[@"email"][@"name"]];
        obj.email = [[Helper sharedHelper] cleanValue:json[@"email"][@"value"]];
    }

    if(json[@"password"] != nil) {
        obj.passwordId = [[Helper sharedHelper] cleanValue:json[@"password"][@"name"]];
        obj.password = [[Helper sharedHelper] cleanValue:json[@"password"][@"value"]];
    }

    if(json[@"user_street"] != nil) {
        obj.streetId = [[Helper sharedHelper] cleanValue:json[@"user_street"][@"name"]];
        obj.street = [[Helper sharedHelper] cleanValue:json[@"user_street"][@"value"]];
    }

    if(json[@"user_city"] != nil) {
        obj.cityId = [[Helper sharedHelper] cleanValue:json[@"user_city"][@"name"]];
        obj.city = [[Helper sharedHelper] cleanValue:json[@"user_city"][@"value"]];
    }

    if(json[@"user_areaCode"] != nil) {
        obj.zipCodeId = [[Helper sharedHelper] cleanValue:json[@"user_areaCode"][@"name"]];
        obj.zipCode = [[Helper sharedHelper] cleanValue:json[@"user_areaCode"][@"value"]];
    }

    if(json[@"user_country"] != nil) {
        obj.countryId = [[Helper sharedHelper] cleanValue:json[@"user_country"][@"name"]];
        obj.country = [[Helper sharedHelper] cleanValue:json[@"user_country"][@"value"]];
    }

    if(json[@"exercises_dailyMinimum"] != nil) {
        obj.exerciseGoalId = [[Helper sharedHelper] cleanValue:json[@"exercises_dailyMinimum"][@"name"]];
        obj.exerciseGoal = [[[Helper sharedHelper] cleanValue:json[@"exercises_dailyMinimum"][@"value"]] intValue];
    }

    if(json[@"notification_dailyMotivation"] != nil) {
        obj.motivationReminderId = [[Helper sharedHelper] cleanValue:json[@"notification_dailyMotivation"][@"name"]];
        obj.isMotivationReminderEnabled = [[[Helper sharedHelper] cleanValue:json[@"notification_dailyMotivation"][@"value"]] boolValue];
    }

    if(json[@"notification_habitReminder"] != nil) {
        obj.habitsReminderId = [[Helper sharedHelper] cleanValue:json[@"notification_habitReminder"][@"name"]];
        obj.isHabitsReminderEnabled = [[[Helper sharedHelper] cleanValue:json[@"notification_habitReminder"][@"value"]] boolValue];
    }

    if(json[@"notification_dailyPersonalGoal"] != nil) {
        obj.personalGoalReminderId = [[Helper sharedHelper] cleanValue:json[@"notification_dailyPersonalGoal"][@"name"]];
        obj.isPersonalGoalReminderEnabled = [[[Helper sharedHelper] cleanValue:json[@"notification_dailyPersonalGoal"][@"value"]] boolValue];
    }

    if(json[@"notification_dailyHeadUp"] != nil) {
        obj.headsUpActivatedId = [[Helper sharedHelper] cleanValue:json[@"notification_dailyHeadUp"][@"name"]];
        obj.isHeadsUpActivated = [[[Helper sharedHelper] cleanValue:json[@"notification_dailyHeadUp"][@"value"]] boolValue];
        
        //set global variable for head's up settings
        HIDE_HEADS_UP_PERMANENT(obj.isHeadsUpActivated?false:true);
    }
    
    //    obj.habitsEnableId = [[Helper sharedHelper] cleanValue:json[@""][@"name"]];
    //    obj.isHabitsEnabled = [[[Helper sharedHelper] cleanValue:json[@""][@"value"]] boolValue];
    
    [realm beginWriteTransaction];
    [realm addOrUpdateObject:obj];
    [realm commitWriteTransaction];
}

- (UserInfo *)getUserInfo{
    RLMResults *res = [UserInfo allObjects];
    UserInfo *obj = [res firstObject];
    return obj;
}

- (void)saveGallery:(NSArray *)json{
    RLMRealm *realm = [RLMRealm defaultRealm];
    
    //clean bookmark list first
    [realm beginWriteTransaction];
    [realm deleteObjects:[Gallery allObjects]];
    [realm commitWriteTransaction];
    
    for (NSDictionary *info in json) {
        if ([[[Helper sharedHelper] cleanValue:info[@"type"]] isEqualToString:@"galleryImage" ]) {
            
            Gallery *obj = [[Gallery alloc] init];
            obj.identifier = [[Helper sharedHelper] cleanValue:info[@"identifier"]];
            obj.url = [[Helper sharedHelper] cleanValue:info[@"url"]];
            obj.creationDate = [[Helper sharedHelper] cleanValue:info[@"creationDate"]];
            obj.isPrivate = [[[Helper sharedHelper] cleanValue:info[@"privacyStatus"]] intValue];
            
            [realm beginWriteTransaction];
            [realm addOrUpdateObject:obj];
            [realm commitWriteTransaction];
        }
    }
    
}

- (NSArray *)getAllGallery{
    RLMResults *res = [[Gallery allObjects] sortedResultsUsingKeyPath:@"creationDate" ascending:NO];
    
    NSMutableArray *result = [NSMutableArray array];
    for (RLMObject *object in res) {
        [result addObject:object];
    }
    
    return [result mutableCopy];
}

- (void)saveImageUrl:(NSString *)url ofMedia:(NSString *)media{
    RLMRealm *realm = [RLMRealm defaultRealm];
    UserMedia *obj = [[UserMedia alloc] init];
    
    obj.media = media;
    obj.url = url;
    
    [realm beginWriteTransaction];
    [realm addOrUpdateObject:obj];
    [realm commitWriteTransaction];
}

- (NSString *)getImageUrlOfMedia:(NSString *)media{
    NSPredicate *predicate = [NSPredicate predicateWithFormat:@"media = %@", media];
    RLMResults *res = [UserMedia objectsWithPredicate:predicate];
    
    UserMedia *obj = [res firstObject];
    
    return obj.url;
}

- (NSArray *)getUserPurchaseHistoryFromJson:(NSArray *)json{
    NSMutableArray *purchaseModules = [NSMutableArray new];
    for (NSDictionary *info in json){
        PurchaseHistoryObj *obj = [PurchaseHistoryObj new];
        if (info[@"module"] != nil) {
            obj.moduleName = [[Helper sharedHelper] cleanValue:info[@"module"][@"name"]];
            obj.price = [[[Helper sharedHelper] cleanValue:info[@"module"][@"price"]] floatValue];
            
        }
        obj.purchaseDate = [[Helper sharedHelper] cleanValue:info[@"purchaseDate"]];
        
        [purchaseModules addObject:obj];
    }
    
    return [purchaseModules mutableCopy];
}

@end
