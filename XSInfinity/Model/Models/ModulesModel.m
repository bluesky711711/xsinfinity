//
//  ModulesModel.m
//  XSInfinity
//
//  Created by Joseph Marvin Magdadaro on 6/14/18.
//  Copyright © 2018 Joseph Marvin Magdadaro. All rights reserved.
//

#import "ModulesModel.h"
#import <Realm/Realm.h>
#import "Helper.h"
#import "ModulesObj.h"
#import "ExercisesObj.h"
#import "ExerciseSummaryObj.h"
#import "BookmarkedExercises.h"
#import "Modules.h"
#import "Exercises.h"
#import "FocusArea.h"
#import "Tags.h"

@implementation ModulesModel

+ (instancetype)sharedInstance
{
    static dispatch_once_t onceToken;
    static ModulesModel *sharedInstance;
    
    dispatch_once(&onceToken, ^{
        sharedInstance = [[self alloc] init];
    });
    
    return sharedInstance;
}

- (ExerciseSummaryObj *)getExercisesSummaryFromJson:(NSDictionary *)json{
    ExerciseSummaryObj *obj = [ExerciseSummaryObj new];
    obj.exercisePoints = [[[Helper sharedHelper] cleanValue:json[@"exercisePoints"]] intValue];
    obj.exercisesUnlocked = [[[Helper sharedHelper] cleanValue:json[@"exercisesUnlocked"]] intValue];
    obj.personalExerciseGoal = [[[Helper sharedHelper] cleanValue:json[@"personalExerciseGoal"]] intValue];
    obj.continuousDays = [[[Helper sharedHelper] cleanValue:json[@"continuousDays"]] intValue];
    
    return obj;
}

- (void)saveExercisesSummary:(NSDictionary *)json{
    RLMRealm *realm = [RLMRealm defaultRealm];
    ExercisesSummary *obj = [ExercisesSummary new];
    obj.summaryId = 1;
    obj.exercisePoints = [[[Helper sharedHelper] cleanValue:json[@"exercisePoints"]] intValue];
    obj.exercisesUnlocked = [[[Helper sharedHelper] cleanValue:json[@"exercisesUnlocked"]] intValue];
    obj.passedExercisesToday = [[[Helper sharedHelper] cleanValue:json[@"passedExercisesToday"]] intValue];
    obj.personalExerciseGoal = [[[Helper sharedHelper] cleanValue:json[@"personalExerciseGoal"]] intValue];
    obj.continuousDays = [[[Helper sharedHelper] cleanValue:json[@"continuousDays"]] intValue];
    
    [realm beginWriteTransaction];
    [realm addOrUpdateObject:obj];
    [realm commitWriteTransaction];
    
}

- (ExercisesSummary *)getExercisesSummary{
    RLMResults *res = [ExercisesSummary allObjects];
    
    ExercisesSummary *obj = [res firstObject];
    
    return obj;
}
- (void)saveModules:(NSArray *)json{
    RLMRealm *realm = [RLMRealm defaultRealm];
    
    for(NSDictionary *info in json){
        Modules *obj = [Modules new];
        
        obj.unlockedExercises = (int)[[info[@"unlockedExercises"] mutableCopy] count];
        obj.passedEasy = [[[Helper sharedHelper] cleanValue:info[@"passedEasy"]] intValue];
        obj.passedMedium = [[[Helper sharedHelper] cleanValue:info[@"passedMedium"]] intValue];
        obj.passedHard = [[[Helper sharedHelper] cleanValue:info[@"passedHard"]] intValue];
        obj.isModuleUnlocked = [[[Helper sharedHelper] cleanValue:info[@"unlockedModule"]] boolValue];
        
        if(info[@"module"] != [NSNull null]){
            obj.identifier = [[Helper sharedHelper] cleanValue:info[@"module"][@"identifier"]];
            obj.name = [[Helper sharedHelper] cleanValue:info[@"module"][@"name"]];
            obj.desc = [[Helper sharedHelper] cleanValue:info[@"module"][@"description"]];
            obj.howToUseDescription = [[Helper sharedHelper] cleanValue:info[@"module"][@"howToUseDescription"]];
            obj.image = [[Helper sharedHelper] cleanValue:info[@"module"][@"image"]];
            obj.numberOfExercises = [[[Helper sharedHelper] cleanValue:info[@"module"][@"numberOfExercises"]] intValue];
            obj.price = [[[Helper sharedHelper] cleanValue:info[@"module"][@"price"]] floatValue];
            obj.disabled = [[[Helper sharedHelper] cleanValue:info[@"module"][@"disabled"]] boolValue];
            obj.orderId = [[[Helper sharedHelper] cleanValue:info[@"module"][@"orderId"]] intValue];
            
            NSDictionary *exercisesDict = [self totalExercisesForEachDifficulties:info[@"module"][@"exercises"]];
            
            obj.totalExerciseEasy = [exercisesDict[@"totalExerciseEasy"] intValue];
            obj.totalExerciseMedium = [exercisesDict[@"totalExerciseMedium"] intValue];
            obj.totalExerciseHard = [exercisesDict[@"totalExerciseHard"] intValue];
            
            [self saveExercises:info[@"module"][@"exercises"]
        andSetExercisesFinished:info[@"passedExercises"]
             unlockedExercises:info[@"unlockedExercises"]
                     withModule:obj];
        }
        
        [realm beginWriteTransaction];
        [realm addOrUpdateObject:obj];
        [realm commitWriteTransaction];
        
    }
}

- (NSArray *)getAllModules{
    RLMResults *res = [[Modules allObjects] sortedResultsUsingDescriptors:@[
                                                       [RLMSortDescriptor sortDescriptorWithKeyPath:@"isModuleUnlocked" ascending:NO],
                                                       [RLMSortDescriptor sortDescriptorWithKeyPath:@"orderId" ascending:YES]
                                                       ]];
    
    NSMutableArray *result = [NSMutableArray array];
    for (RLMObject *object in res) {
        [result addObject:object];
    }
    
    return [result mutableCopy];
}

- (void)saveExercises:(NSArray *)json
andSetExercisesFinished:(NSArray *)finishedExercises
    unlockedExercises: (NSArray *)unlockedExercises
           withModule:(Modules *)module{
    
    RLMRealm *realm = [RLMRealm defaultRealm];
    
    for(NSDictionary *exercise in json){
        Exercises *obj = [Exercises new];
        obj.identifier = [[Helper sharedHelper] cleanValue:exercise[@"identifier"]];
        obj.name = [[Helper sharedHelper] cleanValue:exercise[@"name"]];
        obj.desc = [[Helper sharedHelper] cleanValue:exercise[@"description"]];
        obj.type = [[Helper sharedHelper] cleanValue:exercise[@"type"]];
        obj.difficulty = [[Helper sharedHelper] cleanValue:exercise[@"difficulty"]];
        
        if(exercise[@"focusArea"] != [NSNull null]){
            obj.focusAreaId = [[Helper sharedHelper] cleanValue:exercise[@"focusArea"][@"identifier"]];
        }
        
        if(exercise[@"video"] != [NSNull null]){
            obj.videoId = [[Helper sharedHelper] cleanValue:exercise[@"video"][@"identifier"]];
            obj.videoTitle = [[Helper sharedHelper] cleanValue:exercise[@"video"][@"title"]];
            obj.videoUrl = [[Helper sharedHelper] cleanValue:exercise[@"video"][@"url"]];
            obj.previewImage = [[Helper sharedHelper] cleanValue:exercise[@"video"][@"previewImage"]];
            obj.isVideoVisible = [[[Helper sharedHelper] cleanValue:exercise[@"video"][@"visibility"]] boolValue];
        }
        
        obj.disabled = [[[Helper sharedHelper] cleanValue:exercise[@"disabled"]] boolValue];
        obj.orderId = [[[Helper sharedHelper] cleanValue:exercise[@"orderId"]] intValue];
        obj.sets = [[[Helper sharedHelper] cleanValue:exercise[@"sets"]] intValue];
        obj.repetitions = [[[Helper sharedHelper] cleanValue:exercise[@"repetitions"]] intValue];
        obj.points = [[[Helper sharedHelper] cleanValue:exercise[@"points"]] intValue];
        obj.duration = [[[Helper sharedHelper] cleanValue:exercise[@"duration"]] intValue];
        
        if(finishedExercises){
            NSString *predString = [NSString stringWithFormat:@"SELF == '%@'", obj.identifier];
            NSPredicate *pred = [NSPredicate predicateWithFormat:predString];
            
            NSArray *filtered = [finishedExercises filteredArrayUsingPredicate:pred];
            if(filtered.count > 0){
                obj.finished = true;
            }
        }
        
        if(unlockedExercises){
            NSString *predString = [NSString stringWithFormat:@"SELF == '%@'", obj.identifier];
            NSPredicate *pred = [NSPredicate predicateWithFormat:predString];
            
            NSArray *filtered = [unlockedExercises filteredArrayUsingPredicate:pred];
            if(filtered.count > 0){
                obj.unlocked = true;
            }
        }
        
        NSMutableArray *tagsIdArr = [NSMutableArray new];
        NSMutableArray *tagsNameArr = [NSMutableArray new];
        for(NSDictionary *tag in exercise[@"tags"]){
            [tagsIdArr addObject:tag[@"identifier"]];
            [tagsNameArr addObject:tag[@"name"]];
        }
        
        obj.tagsIds = [tagsIdArr componentsJoinedByString:@", "];
        obj.tagsNames = [tagsNameArr componentsJoinedByString:@", "];
        
        obj.moduleIdentifier = module.identifier;
        obj.moduleName = module.name;
        
        [realm beginWriteTransaction];
        [realm addOrUpdateObject:obj];
        [realm commitWriteTransaction];
    }
}

- (void)unlockedExercise:(Exercises *)exercise{
    RLMRealm *realm = [RLMRealm defaultRealm];
    
    [realm beginWriteTransaction];
    exercise.unlocked = true;
    [realm commitWriteTransaction];
}

- (NSDictionary *)totalExercisesForEachDifficulties:(NSArray *)json{
    int totalEasy = 0;
    int totalMedium = 0;
    int totalHard = 0;
    for(NSDictionary *exercise in json){
        if ([[[Helper sharedHelper] cleanValue:exercise[@"difficulty"]] isEqualToString:@"easy"]) {
            totalEasy += 1;
        }else if ([[[Helper sharedHelper] cleanValue:exercise[@"difficulty"]] isEqualToString:@"medium"]){
            totalMedium +=1;
        }else if ([[[Helper sharedHelper] cleanValue:exercise[@"difficulty"]] isEqualToString:@"hard"]){
            totalHard += 1;
        }
    }
    
    NSDictionary *exercisesDict = @{
                                    @"totalExerciseEasy": @(totalEasy),
                                    @"totalExerciseMedium": @(totalMedium),
                                    @"totalExerciseHard": @(totalHard)
                                    };
    
    return exercisesDict;
}

- (NSArray *)getAllExercises{
    RLMResults *res = [Exercises allObjects];
    
    NSMutableArray *result = [NSMutableArray array];
    for (RLMObject *object in res) {
        [result addObject:object];
    }
    
    return [result mutableCopy];
}

- (NSArray *)getExercisesByModuleId:(NSString *)moduleId{
    NSPredicate *predicate = [NSPredicate predicateWithFormat:@"moduleIdentifier = %@", moduleId];
    RLMResults *res = [[Exercises objectsWithPredicate:predicate] sortedResultsUsingKeyPath:@"orderId" ascending:YES];
    
    NSMutableArray *result = [NSMutableArray array];
    for (RLMObject *object in res) {
        [result addObject:object];
    }
    
    return [result mutableCopy];
    
}


- (NSArray *)getExercisesByModuleId:(NSString *)moduleId andDifficulty:(Difficulties)difficulty{
    NSString *difficultyStr = @"";
    switch (difficulty) {
        case Easy:
            difficultyStr = @"easy";
            break;
        case Medium:
            difficultyStr = @"medium";
            break;
        case Hard:
            difficultyStr = @"hard";
            break;
    }
    
    NSPredicate *predicate = [NSPredicate predicateWithFormat:@"moduleIdentifier = %@ AND difficulty = %@", moduleId, difficultyStr];
    RLMResults *res = [[Exercises objectsWithPredicate:predicate] sortedResultsUsingKeyPath:@"orderId" ascending:YES];
    
    NSMutableArray *result = [NSMutableArray array];
    for (RLMObject *object in res) {
        [result addObject:object];
    }
    
    return [result mutableCopy];
    
}

- (NSArray *)getModulesWithExercisesFromJson:(NSArray *)json{
    NSMutableArray *modules = [NSMutableArray new];
    for(NSDictionary *info in json){
        ModulesObj *obj = [ModulesObj new];
        
        obj.unlockedExercises = [[[Helper sharedHelper] cleanValue:info[@"unlockedExercises"]] intValue];
        obj.passedEasy = [[[Helper sharedHelper] cleanValue:info[@"passedEasy"]] intValue];
        obj.passedMedium = [[[Helper sharedHelper] cleanValue:info[@"passedMedium"]] intValue];
        obj.passedHard = [[[Helper sharedHelper] cleanValue:info[@"passedHard"]] intValue];
        obj.isModuleUnlocked = [[[Helper sharedHelper] cleanValue:info[@"unlockedModule"]] boolValue];
        
        if(info[@"module"] != [NSNull null]){
            obj.identifier = [[Helper sharedHelper] cleanValue:info[@"module"][@"identifier"]];
            obj.name = [[Helper sharedHelper] cleanValue:info[@"module"][@"name"]];
            obj.desc = [[Helper sharedHelper] cleanValue:info[@"module"][@"description"]];
            obj.numberOfExercises = [[[Helper sharedHelper] cleanValue:info[@"module"][@"numberOfExercises"]] intValue];
            obj.price = [[[Helper sharedHelper] cleanValue:info[@"module"][@"price"]] floatValue];
            obj.disabled = [[[Helper sharedHelper] cleanValue:info[@"module"][@"disabled"]] boolValue];
            
            NSDictionary *exercisesDict = [self exercisesFromJson:info[@"module"][@"exercises"] andSetExerciseFinishedBy:info[@"passedExercises"]];
            
            obj.exercises = exercisesDict[@"exercises"];
            obj.totalExerciseEasy = [exercisesDict[@"totalExerciseEasy"] intValue];
            obj.totalExerciseMedium = [exercisesDict[@"totalExerciseMedium"] intValue];
            obj.totalExerciseHard = [exercisesDict[@"totalExerciseHard"] intValue];
        }
        
        [modules addObject:obj];
    }
    
    return [modules mutableCopy];
}

- (NSDictionary *)exercisesFromJson:(NSArray *)json andSetExerciseFinishedBy:(NSArray *)finishedExercises{
    NSMutableArray *exercises = [NSMutableArray new];
    int totalEasy = 0;
    int totalMedium = 0;
    int totalHard = 0;
    for(NSDictionary *exercise in json){
        ExercisesObj *obj = [ExercisesObj new];
        obj.identifier = [[Helper sharedHelper] cleanValue:exercise[@"identifier"]];
        obj.name = [[Helper sharedHelper] cleanValue:exercise[@"name"]];
        obj.desc = [[Helper sharedHelper] cleanValue:exercise[@"description"]];
        obj.type = [[Helper sharedHelper] cleanValue:exercise[@"type"]];
        obj.difficulty = [[Helper sharedHelper] cleanValue:exercise[@"difficulty"]];
        
        if(exercise[@"focusArea"] != [NSNull null]){
            obj.focusAreaId = [[Helper sharedHelper] cleanValue:exercise[@"focusArea"][@"identifier"]];
        }
        
        if(exercise[@"video"] != [NSNull null]){
            obj.videoId = [[Helper sharedHelper] cleanValue:exercise[@"video"][@"identifier"]];
            obj.videoTitle = [[Helper sharedHelper] cleanValue:exercise[@"video"][@"title"]];
            obj.videoUrl = [[Helper sharedHelper] cleanValue:exercise[@"video"][@"url"]];
            obj.previewImage = [[Helper sharedHelper] cleanValue:exercise[@"video"][@"previewImage"]];
            obj.isVideoVisible = [[[Helper sharedHelper] cleanValue:exercise[@"video"][@"visibility"]] boolValue];
        }
        
        obj.disabled = [[[Helper sharedHelper] cleanValue:exercise[@"disabled"]] boolValue];
        obj.orderId = [[[Helper sharedHelper] cleanValue:exercise[@"orderId"]] intValue];
        obj.sets = [[[Helper sharedHelper] cleanValue:exercise[@"sets"]] intValue];
        obj.repetitions = [[[Helper sharedHelper] cleanValue:exercise[@"repetitions"]] intValue];
        obj.points = [[[Helper sharedHelper] cleanValue:exercise[@"points"]] intValue];
        obj.duration = [[[Helper sharedHelper] cleanValue:exercise[@"duration"]] intValue];
        
        for(NSString *finished in finishedExercises){
            NSString *identifier = [[Helper sharedHelper] cleanValue:finished];
            if ([identifier length]>0 && [identifier isEqual:[[Helper sharedHelper] cleanValue:exercise[@"identifier"]]]) {
                obj.finished = TRUE;
                
                break;
            }else{
                obj.finished = FALSE;
            }
        }
        
        NSMutableArray *tagsIdArr = [NSMutableArray new];
        NSMutableArray *tagsNameArr = [NSMutableArray new];
        for(NSDictionary *tag in exercise[@"tags"]){
            [tagsIdArr addObject:tag[@"identifier"]];
            [tagsNameArr addObject:tag[@"name"]];
        }
        
        obj.tagsIds = [tagsIdArr componentsJoinedByString:@", "];
        obj.tagsNames = [tagsNameArr componentsJoinedByString:@", "];
        
        [exercises addObject:obj];
        
        if ([[[Helper sharedHelper] cleanValue:exercise[@"difficulty"]] isEqualToString:@"easy"]) {
            totalEasy += 1;
        }else if ([[[Helper sharedHelper] cleanValue:exercise[@"difficulty"]] isEqualToString:@"medium"]){
            totalMedium +=1;
        }else if ([[[Helper sharedHelper] cleanValue:exercise[@"difficulty"]] isEqualToString:@"hard"]){
            totalHard += 1;
        }
    }
    
    NSDictionary *exercisesDict = @{
                                    @"exercises": [exercises mutableCopy],
                                    @"totalExerciseEasy": @(totalEasy),
                                    @"totalExerciseMedium": @(totalMedium),
                                    @"totalExerciseHard": @(totalHard)
                                    };
    
    return exercisesDict;
}

- (NSArray *)getExercisesFromJson:(NSArray *)json{
    NSMutableArray *exercises = [NSMutableArray new];

    for(NSDictionary *exercise in json){
        ExercisesObj *obj = [ExercisesObj new];
        obj.identifier = [[Helper sharedHelper] cleanValue:exercise[@"identifier"]];
        obj.name = [[Helper sharedHelper] cleanValue:exercise[@"name"]];
        obj.desc = [[Helper sharedHelper] cleanValue:exercise[@"description"]];
        obj.type = [[Helper sharedHelper] cleanValue:exercise[@"type"]];
        obj.difficulty = [[Helper sharedHelper] cleanValue:exercise[@"difficulty"]];
        
        if(exercise[@"module"] != [NSNull null]){
            obj.moduleIdentifier = [[Helper sharedHelper] cleanValue:exercise[@"module"][@"identifier"]];
            obj.moduleName = [[Helper sharedHelper] cleanValue:exercise[@"module"][@"name"]];
        }
        
        if(exercise[@"focusArea"] != [NSNull null]){
            obj.focusAreaId = [[Helper sharedHelper] cleanValue:exercise[@"focusArea"][@"identifier"]];
        }
        if(exercise[@"focusAreas"] != [NSNull null]){
            obj.focusAreas = [[[Helper sharedHelper] cleanValue:exercise[@"focusAreas"]] mutableCopy];
        }
        if(exercise[@"tags"] != [NSNull null]){
            obj.tags = [[[Helper sharedHelper] cleanValue:exercise[@"tags"]] mutableCopy];
        }
        
        if(exercise[@"video"] != [NSNull null]){
            obj.videoId = [[Helper sharedHelper] cleanValue:exercise[@"video"][@"identifier"]];
            obj.videoTitle = [[Helper sharedHelper] cleanValue:exercise[@"video"][@"title"]];
            obj.videoUrl = [[Helper sharedHelper] cleanValue:exercise[@"video"][@"url"]];
            obj.previewImage = [[Helper sharedHelper] cleanValue:exercise[@"video"][@"previewImage"]];
            obj.isVideoVisible = [[[Helper sharedHelper] cleanValue:exercise[@"video"][@"visibility"]] boolValue];
        }
        
        obj.disabled = [[[Helper sharedHelper] cleanValue:exercise[@"disabled"]] boolValue];
        obj.orderId = [[[Helper sharedHelper] cleanValue:exercise[@"orderId"]] intValue];
        obj.sets = [[[Helper sharedHelper] cleanValue:exercise[@"sets"]] intValue];
        obj.repetitions = [[[Helper sharedHelper] cleanValue:exercise[@"repetitions"]] intValue];
        obj.points = [[[Helper sharedHelper] cleanValue:exercise[@"points"]] intValue];
        obj.duration = [[[Helper sharedHelper] cleanValue:exercise[@"duration"]] intValue];
        
        NSMutableArray *tagsIdArr = [NSMutableArray new];
        NSMutableArray *tagsNameArr = [NSMutableArray new];
        for(NSDictionary *tag in exercise[@"tags"]){
            [tagsIdArr addObject:tag[@"identifier"]];
            [tagsNameArr addObject:tag[@"name"]];
        }
        
        obj.tagsIds = [tagsIdArr componentsJoinedByString:@", "];
        obj.tagsNames = [tagsNameArr componentsJoinedByString:@", "];
        obj.unlocked = true;
        
        [exercises addObject:obj];
    }
    
    return [exercises mutableCopy];
}

- (ExercisesObj *)getSurpriseExerciseFromJson:(NSDictionary *)json{
    ExercisesObj *obj = [ExercisesObj new];
    obj.identifier = [[Helper sharedHelper] cleanValue:json[@"identifier"]];
    obj.name = [[Helper sharedHelper] cleanValue:json[@"name"]];
    obj.desc = [[Helper sharedHelper] cleanValue:json[@"description"]];
    obj.type = [[Helper sharedHelper] cleanValue:json[@"type"]];
    obj.difficulty = [[Helper sharedHelper] cleanValue:json[@"difficulty"]];
    
    if(json[@"module"] != [NSNull null]){
        obj.moduleIdentifier = [[Helper sharedHelper] cleanValue:json[@"module"][@"identifier"]];
    }
    
    if(json[@"focusArea"] != [NSNull null]){
        obj.focusAreaId = [[Helper sharedHelper] cleanValue:json[@"focusArea"][@"identifier"]];
    }
    
    if(json[@"video"] != [NSNull null]){
        obj.videoId = [[Helper sharedHelper] cleanValue:json[@"video"][@"identifier"]];
        obj.videoTitle = [[Helper sharedHelper] cleanValue:json[@"video"][@"title"]];
        obj.videoUrl = [[Helper sharedHelper] cleanValue:json[@"video"][@"url"]];
        obj.previewImage = [[Helper sharedHelper] cleanValue:json[@"video"][@"previewImage"]];
        obj.isVideoVisible = [[[Helper sharedHelper] cleanValue:json[@"video"][@"visibility"]] boolValue];
    }
    
    obj.disabled = [[[Helper sharedHelper] cleanValue:json[@"disabled"]] boolValue];
    obj.orderId = [[[Helper sharedHelper] cleanValue:json[@"orderId"]] intValue];
    obj.sets = [[[Helper sharedHelper] cleanValue:json[@"sets"]] intValue];
    obj.repetitions = [[[Helper sharedHelper] cleanValue:json[@"repetitions"]] intValue];
    obj.points = [[[Helper sharedHelper] cleanValue:json[@"points"]] intValue];
    obj.duration = [[[Helper sharedHelper] cleanValue:json[@"duration"]] intValue];
    
    NSMutableArray *tagsIdArr = [NSMutableArray new];
    NSMutableArray *tagsNameArr = [NSMutableArray new];
    for(NSDictionary *tag in json[@"tags"]){
        [tagsIdArr addObject:tag[@"identifier"]];
        [tagsNameArr addObject:tag[@"name"]];
    }
    
    obj.tagsIds = [tagsIdArr componentsJoinedByString:@", "];
    obj.tagsNames = [tagsNameArr componentsJoinedByString:@", "];
    
    return obj;
}

- (void)saveBookmarkedExercises:(NSArray *)exercises{
    RLMRealm *realm = [RLMRealm defaultRealm];
    
    //clean bookmark list first
    [realm beginWriteTransaction];
    [realm deleteObjects:[BookmarkedExercises allObjects]];
    [realm commitWriteTransaction];
    
    for (NSDictionary *exercise in exercises) {
        
        BookmarkedExercises *bookmarked = [[BookmarkedExercises alloc] init];
        bookmarked.bookmarkId = [[Helper sharedHelper] cleanValue:exercise[@"identifier"]];
        bookmarked.exerciseId = [[Helper sharedHelper] cleanValue:exercise[@"exercise"][@"identifier"]];
        
        [realm beginWriteTransaction];
        [realm addOrUpdateObject:bookmarked];
        [realm commitWriteTransaction];
        
    }
}

- (NSArray *) getAllBookmarkedExercises{
    RLMResults *bookmarkedRes = [BookmarkedExercises allObjects];
    
    NSMutableArray *result = [NSMutableArray array];
    for (BookmarkedExercises *bookmarkExercises in bookmarkedRes) {
        [result addObject:bookmarkExercises];
    }
    
    return [result mutableCopy];
}

- (void)removeBookmarked:(NSString *)bookmarkId{
    RLMRealm *realm = [RLMRealm defaultRealm];
    
    RLMResults *bookmarked = [BookmarkedExercises objectsWhere:@"bookmarkId == %@", bookmarkId];
    for (BookmarkedExercises *bookmarkExercises in bookmarked) {
        NSLog(@"Bookmarked = %@", bookmarkExercises.bookmarkId);
    }
    
    [realm beginWriteTransaction];
    [realm deleteObjects:[BookmarkedExercises objectsWhere:@"bookmarkId == %@", bookmarkId]];
    [realm commitWriteTransaction];
}


- (NSArray *)getExercisesHistoryFromJson:(NSArray *)json{
    NSMutableArray *exercises = [NSMutableArray new];
    
    for(NSDictionary *exercise in json){
        ExercisesObj *obj = [ExercisesObj new];
        obj.identifier = [[Helper sharedHelper] cleanValue:exercise[@"exercise"][@"identifier"]];
        
        [exercises addObject:obj];
    }
    
    return [exercises mutableCopy];
}

- (void)saveFocusArea:(NSArray *)json{
    if(json.count == 0){
        return;
    }
    
    RLMRealm *realm = [RLMRealm defaultRealm];
    
    [realm beginWriteTransaction];
    [realm deleteObjects:[FocusArea allObjects]];
    [realm commitWriteTransaction];
    
    for (NSDictionary *focusArea in json) {
        
        FocusArea *obj = [[FocusArea alloc] init];
        obj.identifier = [[Helper sharedHelper] cleanValue:focusArea[@"identifier"]];
        obj.name = [[Helper sharedHelper] cleanValue:focusArea[@"name"]];
        
        [realm beginWriteTransaction];
        [realm addOrUpdateObject:obj];
        [realm commitWriteTransaction];
        
    }
}

- (NSArray *) getFocusArea{
    RLMResults *focusAreaRes = [FocusArea allObjects];
    
    NSMutableArray *result = [NSMutableArray array];
    for (RLMObject *object in focusAreaRes) {
        [result addObject:object];
    }
    
    return [result mutableCopy];
}

- (void)saveTags:(NSArray *)json{
    if(json.count == 0){
        return;
    }
    
    RLMRealm *realm = [RLMRealm defaultRealm];
    
    [realm beginWriteTransaction];
    [realm deleteObjects:[Tags allObjects]];
    [realm commitWriteTransaction];
    
    for (NSDictionary *focusArea in json) {
        
        Tags *obj = [[Tags alloc] init];
        obj.identifier = [[Helper sharedHelper] cleanValue:focusArea[@"identifier"]];
        obj.name = [[Helper sharedHelper] cleanValue:focusArea[@"name"]];
        
        [realm beginWriteTransaction];
        [realm addOrUpdateObject:obj];
        [realm commitWriteTransaction];
        
    }
}

- (NSArray *) getTags{
    RLMResults *focusAreaRes = [Tags allObjects];
    
    NSMutableArray *result = [NSMutableArray array];
    for (RLMObject *object in focusAreaRes) {
        [result addObject:object];
    }
    
    return [result mutableCopy];
}

@end
