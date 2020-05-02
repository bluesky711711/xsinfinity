//
//  ModulesModel.h
//  XSInfinity
//
//  Created by Joseph Marvin Magdadaro on 6/14/18.
//  Copyright © 2018 Joseph Marvin Magdadaro. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "ExerciseSummaryObj.h"
#import "Exercises.h"
#import "ExercisesObj.h"
#import "ExercisesSummary.h"

@interface ModulesModel : NSObject

+ (ModulesModel *)sharedInstance;

/**
 * This method will get the summary of all exercises from json
 *
 * param: json - dictionary of modules, exercises and exercises summary
 *
 * return: ExerciseSummaryObj
 */
- (ExerciseSummaryObj *)getExercisesSummaryFromJson:(NSDictionary *)json;
- (void)saveExercisesSummary:(NSDictionary *)json;
- (ExercisesSummary *)getExercisesSummary;

- (void)unlockedExercise:(Exercises *)exercise;

/**
 * This method will get modules list and correspomdimg exercises from json
 *
 * param: json - array of modules w/ exercises
 *
 * return: NSArray of ModulesObj with NSArray of ExercisesObj(ModulesObj.exercises)
 */
- (NSArray *)getModulesWithExercisesFromJson:(NSArray *)json;
- (void)saveModules:(NSArray *)json;
- (NSArray *)getAllModules;
- (NSArray *)getAllExercises;
- (NSArray *)getExercisesByModuleId:(NSString *)moduleId;
- (NSArray *)getExercisesByModuleId:(NSString *)moduleId andDifficulty:(Difficulties)difficulty;

/**
 * This method will get the surprice exercise info
 *
 * param: json - dictionary of exercise
 *
 * return: ExercisesObj
 */
- (ExercisesObj *)getSurpriseExerciseFromJson:(NSDictionary *)json;

/**
 * This method will get the list of exercises
 *
 * param: json - array of exercises
 *
 * return: NSArray of ExercisesObj
 */
- (NSArray *)getExercisesFromJson:(NSArray *)json;

/**
 * This method will save bookmarked exercises
 *
 * @param exercises - exercise info
 */
- (void)saveBookmarkedExercises:(NSArray *)exercises;

/**
 * This method will get all bookmarked exercises
 *
 * return: NSArray of exercises id
 */
- (NSArray *) getAllBookmarkedExercises;

/**
 * This method will removed bookmarked exercises
 *
 * @param bookmarkId - bookmark id
 */
- (void)removeBookmarked:(NSString *)bookmarkId;

/**
 * This method will get all exercises history
 *
 * param: json - array of exercises
 *
 * return: NSArray of ExercisesObj
 */
- (NSArray *)getExercisesHistoryFromJson:(NSArray *)json;

- (void)saveFocusArea:(NSArray *)json;

- (NSArray *) getFocusArea;

- (void)saveTags:(NSArray *)json;

- (NSArray *) getTags;

@end
