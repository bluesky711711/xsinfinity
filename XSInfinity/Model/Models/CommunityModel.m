//
//  CommunityModel.m
//  XSInfinity
//
//  Created by Joseph Marvin Magdadaro on 7/17/18.
//  Copyright © 2018 Jerk Magz. All rights reserved.
//

#import "CommunityModel.h"
#import "Helper.h"
#import "RankingListObj.h"
#import "OtherProfileObj.h"
#import "GalleryObj.h"
#import "ExerciseActivityObj.h"
#import "HabitActivityObj.h"
#import "AppUsageObj.h"

@implementation CommunityModel

+ (instancetype)sharedInstance
{
    static dispatch_once_t onceToken;
    static CommunityModel *sharedInstance;
    
    dispatch_once(&onceToken, ^{
        sharedInstance = [[self alloc] init];
    });
    
    return sharedInstance;
}

- (NSArray *)getRankingListFromJson:(NSArray *)json{
    NSMutableArray *ranking = [NSMutableArray new];
    for(NSDictionary *info in json){
        RankingListObj *obj = [RankingListObj new];
        obj.identifier = [[Helper sharedHelper] cleanValue:info[@"identifier"]];
        obj.name = [[Helper sharedHelper] cleanValue:info[@"name"]];
        obj.country = [[Helper sharedHelper] cleanValue:info[@"country"]];
        obj.rankNumber = [[[Helper sharedHelper] cleanValue:info[@"ranking"]] intValue];
        
        if (info[@"profilePicture"] != nil && info[@"profilePicture"] != [NSNull null]) {
            obj.profilePicture = [[Helper sharedHelper] cleanValue:info[@"profilePicture"][@"url"]];
        }
        
        [ranking addObject:obj];
    }
    
    return [ranking mutableCopy];
}
- (OtherProfileObj *)getOtherProfileInfoFromJson:(NSDictionary *)json{
    OtherProfileObj *obj = [OtherProfileObj new];
    obj.name = [[Helper sharedHelper] cleanValue:json[@"name"]];
    obj.country = [[Helper sharedHelper] cleanValue:json[@"country"]];
    obj.exercisePoints = [[[Helper sharedHelper] cleanValue:json[@"exercisePoints"]] intValue];
    obj.habitPoints = [[[Helper sharedHelper] cleanValue:json[@"habitPoints"]] intValue];
    obj.communityRank = [[[Helper sharedHelper] cleanValue:json[@"communityRank"]] intValue];
    
    if(json[@"profilePicture"] != [NSNull null]){
        obj.profilePictureIdentifier = [[Helper sharedHelper] cleanValue:json[@"profilePicture"][@"identifier"]];
        obj.profilePictureUrl = [[Helper sharedHelper] cleanValue:json[@"profilePicture"][@"url"]];
        obj.profilePictureVisible = [[[Helper sharedHelper] cleanValue:json[@"profilePicture"][@"visibility"]] boolValue];
    }

    if(json[@"profileHeader"] != [NSNull null]){
        obj.profileHeaderIdentifier = [[Helper sharedHelper] cleanValue:json[@"profileHeader"][@"identifier"]];
        obj.profileHeaderUrl = [[Helper sharedHelper] cleanValue:json[@"profileHeader"][@"url"]];
        obj.profileHeaderVisible = [[[Helper sharedHelper] cleanValue:json[@"profileHeader"][@"visibility"]] boolValue];
    }

    obj.gallery = [self getGalleryFromJson:json[@"galleryImages"]];
    
    return obj;
}

- (NSArray *)getGalleryFromJson:(NSArray *)json{
    NSMutableArray *gallery = [NSMutableArray new];
    for (NSDictionary *info in json){
        GalleryObj *obj = [GalleryObj new];
        obj.identifier = [[Helper sharedHelper] cleanValue:info[@"identifier"]];
        obj.url = [[Helper sharedHelper] cleanValue:info[@"url"]];
        obj.creationDate = [[Helper sharedHelper] cleanValue:info[@"creationDate"]];
        obj.type = [[Helper sharedHelper] cleanValue:info[@"type"]];
        obj.isPrivate = [[[Helper sharedHelper] cleanValue:info[@"privacyStatus"]] intValue];
        
        [gallery addObject:obj];
    }
    
    return [gallery mutableCopy];
}

- (NSDictionary *)getUserActivitiesFromJson:(NSDictionary *)json{
    NSMutableDictionary *activities = [NSMutableDictionary new];
    
    NSDateFormatter *dateFormatter = [[NSDateFormatter alloc]init];
    [dateFormatter setDateFormat:@"yyyy-MM-dd'T'HH:mm:ss+0000"];
    
    //Exercises history
    NSMutableArray *exercisesActivitiesArray = [NSMutableArray new];
    NSArray *exercisesActivities = json[@"historyExercises"];
    for (NSDictionary *info in exercisesActivities){
        if(info[@"exercise"] != [NSNull null]){
            ExerciseActivityObj *obj = [ExerciseActivityObj new];
            obj.name = [[Helper sharedHelper] cleanValue:info[@"exercise"][@"name"]];
            obj.points = [[[Helper sharedHelper] cleanValue:info[@"exercise"][@"points"]] intValue];
            
            NSArray *dateArr = [[[Helper sharedHelper] cleanValue:info[@"passDate"]] componentsSeparatedByString:@"T"];
            NSString *passDate = dateArr[0];
            obj.passDate = passDate;
            
            [exercisesActivitiesArray addObject:obj];
        }
    }
    
    //Habits history
    NSMutableArray *habitsActivitiesArray = [NSMutableArray new];
    NSArray *habitsActivities = json[@"historyHabitPeriods"];
    for (NSDictionary *info in habitsActivities){
        for (NSDictionary *habit in info[@"historyHabits"]){
            HabitActivityObj *obj = [HabitActivityObj new];
            
            if(habit[@"habit"] != [NSNull null]){
                obj.name = [[Helper sharedHelper] cleanValue:habit[@"habit"][@"name"]];
                obj.points = [[[Helper sharedHelper] cleanValue:habit[@"habit"][@"points"]] intValue];
            }
            
            NSArray *dateArr = [[[Helper sharedHelper] cleanValue:info[@"passDate"]] componentsSeparatedByString:@"T"];
            NSString *passDate = dateArr[0];
            obj.passDate = passDate;
            
            [habitsActivitiesArray addObject:obj];
        }
    }
    
    //App usage history
    NSMutableArray *appUsageActivitiesArray = [NSMutableArray new];
    NSArray *appUsageActivities = json[@"historyUsages"];
    for (NSDictionary *info in appUsageActivities){
        AppUsageObj *obj = [AppUsageObj new];
        obj.duration = [[[Helper sharedHelper] cleanValue:info[@"duration"]] intValue];
        
        NSArray *dateArr = [[[Helper sharedHelper] cleanValue:info[@"creationDate"]] componentsSeparatedByString:@"T"];
        NSString *creationDate = dateArr[0];
        obj.creationDate = creationDate;
        
        [appUsageActivitiesArray addObject:obj];
    }
    
    [activities setValue:exercisesActivitiesArray forKey:@"historyExercises"];
    [activities setValue:habitsActivitiesArray forKey:@"historyHabitPeriods"];
    [activities setValue:appUsageActivitiesArray forKey:@"historyUsages"];
    
    return [activities mutableCopy];
}

@end
