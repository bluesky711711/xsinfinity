//
//  HabitsModel.m
//  XSInfinity
//
//  Created by Joseph Marvin Magdadaro on 6/29/18.
//  Copyright © 2018 Joseph Marvin Magdadaro. All rights reserved.
//

#import "HabitsModel.h"
#import <Realm/Realm.h>
#import "Helper.h"

@implementation HabitsModel

+ (instancetype)sharedInstance
{
    static dispatch_once_t onceToken;
    static HabitsModel *sharedInstance;
    
    dispatch_once(&onceToken, ^{
        sharedInstance = [[self alloc] init];
    });
    
    return sharedInstance;
}

- (void)saveHabitsOverview:(NSDictionary *)json{
    RLMRealm *realm = [RLMRealm defaultRealm];
    
    HabitsOverview *obj = [[HabitsOverview alloc] init];
    obj.overviewId = 1;
    obj.unlocked = [[[Helper sharedHelper] cleanValue:json[@"unlocked"]] intValue];
    obj.maximumHabits = [[[Helper sharedHelper] cleanValue:json[@"maximumHabits"]] intValue];
    obj.habitPoints = [[[Helper sharedHelper] cleanValue:json[@"habitPoints"]] intValue];
    obj.successiveDays = [[[Helper sharedHelper] cleanValue:json[@"successiveDays"]] intValue];
    obj.completedCycles = [[[Helper sharedHelper] cleanValue:json[@"completedCycles"]] intValue];
    obj.lastReset = [[Helper sharedHelper] cleanValue:json[@"lastReset"]];
    
    [realm beginWriteTransaction];
    [realm addOrUpdateObject:obj];
    [realm commitWriteTransaction];
    
}

- (HabitsOverview *)getHabitsOverview{
    RLMResults *res = [HabitsOverview allObjects];
    
    HabitsOverview *obj = [res firstObject];
    
    return obj;
}

- (void)saveHabits:(NSArray *)json{
    RLMRealm *realm = [RLMRealm defaultRealm];
    
    [realm beginWriteTransaction];
    [realm deleteObjects:[Habits allObjects]];
    [realm commitWriteTransaction];
    
    for(NSDictionary *info in json){
        Habits *obj = [Habits new];
        obj.identifier = [[Helper sharedHelper] cleanValue:info[@"identifier"]];
        obj.name = [[Helper sharedHelper] cleanValue:info[@"name"]];
        obj.desc = [[Helper sharedHelper] cleanValue:info[@"description"]];
        obj.excerpt = [[Helper sharedHelper] cleanValue:info[@"excerpt"]];
        obj.img = [[Helper sharedHelper] cleanValue:info[@"image"]];
        obj.disabled = [[[Helper sharedHelper] cleanValue:info[@"disabled"]] boolValue];
        obj.orderId = [[[Helper sharedHelper] cleanValue:info[@"orderId"]] intValue];
        obj.points = [[[Helper sharedHelper] cleanValue:info[@"points"]] intValue];
        
        [realm beginWriteTransaction];
        [realm addOrUpdateObject:obj];
        [realm commitWriteTransaction];
    }
    
}

- (void)unlockHabit:(Habits *)habit{
    RLMRealm *realm = [RLMRealm defaultRealm];
    
    [realm beginWriteTransaction];
    habit.unlocked = true;
    [realm commitWriteTransaction];
}

- (void)finishHabit:(Habits *)habit{
    RLMRealm *realm = [RLMRealm defaultRealm];
    
    [realm beginWriteTransaction];
    habit.finished = true;
    [realm commitWriteTransaction];
}

- (void)unFinishHabit:(Habits *)habit{
    RLMRealm *realm = [RLMRealm defaultRealm];
    
    [realm beginWriteTransaction];
    habit.finished = false;
    [realm commitWriteTransaction];
}

- (NSArray *)getAllHabits{
    RLMResults *res = [[Habits allObjects] sortedResultsUsingKeyPath:@"orderId" ascending:YES];
    
    NSMutableArray *result = [NSMutableArray array];
    for (RLMObject *object in res) {
        [result addObject:object];
    }
    
    return [result mutableCopy];
}

- (NSArray *)getUnlockedHabits{
    NSPredicate *predicate = [NSPredicate predicateWithFormat:@"unlocked = true"];
    RLMResults *res = [[Habits objectsWithPredicate:predicate] sortedResultsUsingKeyPath:@"orderId" ascending:YES];
    
    NSMutableArray *result = [NSMutableArray array];
    for (RLMObject *object in res) {
        [result addObject:object];
    }
    
    return [result mutableCopy];
}

- (NSArray *)getFinishedHabits{
    NSPredicate *predicate = [NSPredicate predicateWithFormat:@"finished = true"];
    RLMResults *res = [[Habits objectsWithPredicate:predicate] sortedResultsUsingKeyPath:@"orderId" ascending:YES];
    
    NSMutableArray *result = [NSMutableArray array];
    for (RLMObject *object in res) {
        [result addObject:object];
    }
    
    return [result mutableCopy];
}

- (NSArray *)getUnlockedAndUnFinishedHabits{
    NSPredicate *predicate = [NSPredicate predicateWithFormat:@"unlocked = true AND finished = false"];
    RLMResults *res = [[Habits objectsWithPredicate:predicate] sortedResultsUsingKeyPath:@"orderId" ascending:YES];
    
    NSMutableArray *result = [NSMutableArray array];
    for (RLMObject *object in res) {
        [result addObject:object];
    }
    
    return [result mutableCopy];
}

@end
