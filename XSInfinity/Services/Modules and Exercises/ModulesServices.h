//
//  ModulesServices.h
//  XSInfinity
//
//  Created by Joseph Marvin Magdadaro on 6/14/18.
//  Copyright © 2018 Joseph Marvin Magdadaro. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "ExerciseSummaryObj.h"
#import "ExercisesObj.h"

typedef NS_ENUM(NSUInteger, ModuleServiceApi)
{
    ModuleServiceApi_ExercisesSummary = 1,
    ModuleServiceApi_AllModuleWithExercises,
    ModuleServiceApi_UnlockedExercises,
    ModuleServiceApi_SurpriseWorkout,
    ModuleServiceApi_Exercises,
    ModuleServiceApi_AddRating,
    ModuleServiceApi_BookmarkedExercisesList,
    ModuleServiceApi_CreateBookmark,
    ModuleServiceApi_RemoveBookmark,
    ModuleServiceApi_ExercisesHistory,
    ModuleServiceApi_FocusArea
};

@interface ModulesServices : NSObject

+ (ModulesServices *) sharedInstance;

/**
 * Get summary of all exercises
 *
 * Completion: Exercise summary
 */
- (void) getExercisesSummaryWithCompletion: (void(^)(NSError *error, int statusCode))completion;

/**
 * Get all modules with corresponding exercises
 *
 * Completion: Array of modules with exercises
 */
- (void) getAllModulesWithExercisesWithCompletion: (void(^)(NSError *error, int statusCode))completion;

- (void) getUnlockedExercisesWithCompletion: (void(^)(NSError *error, int statusCode, NSArray *exercises))completion;

/**
 * Get surprise workout/exercise
 *
 * Params: params - focusarea, difficulty and/or rating
 *
 * Completion: random exercise info
 */
- (void) getSurpriseWorkoutWithParameters:(NSDictionary *)params
                           withCompletion: (void(^)(NSError *error, int statusCode, ExercisesObj *exercise))completion;

/**
 * Get exercises list
 *
 * Params: params - filters
 *
 * Completion: array of exercises
 */
- (void) getAvailableExercisesWithCompletion: (void(^)(NSError *error, int statusCode, NSArray *exercises))completion;

/**
 * Get available exercises
 *
 * Completion: array of exercises
 */
- (void) getExercisesWithParameters:(NSDictionary *)params
                     withCompletion: (void(^)(NSError *error, int statusCode, NSArray *exercises))completion;

/**
 * Add rating on exercise
 *
 *Params: rating - rating from 0 - 4, exerciseId - exercise's identifier
 *
 * Completion: Int statusCode
 */
- (void) addRating:(int)rating forExercise:(NSString *)exerciseId withCompletion: (void(^)(NSError *error, int statusCode))completion;

/**
 * Get bookmarked exercises
 *
 * Completion: Array of exercises
 */
- (void) getBookmarkedExercisesWithCompletion: (void(^)(NSError *error,  BOOL successful))completion;

/**
 * Add exercise on Bookmark
 *
 *Params: exerciseId - exercise's identifier
 *
 * Completion: Int statusCode
 */
- (void) createBookMarkForExercise:(NSString *)exerciseId withCompletion: (void(^)(NSError *error,  int statusCode))completion;

/**
 * Remove exercise on Bookmark
 *
 *Params: exerciseId - exercise's identifier
 *
 * Completion: Int statusCode
 */
- (void) removeBookMark:(NSString *)bookmarkId withCompletion: (void(^)(NSError *error,  int statusCode))completion;

/**
 * Get exercises history
 *
 * Completion: array of exercises
 */
- (void) getExercisesHistoryWithCompletion: (void(^)(NSError *error, int statusCode, NSArray *exercises))completion;

/**
 * Get focus area
 *
 * Completion: Array of focusArea
 */
- (void) getFocusAreaWithCompletion: (void(^)(NSError *error, int statusCode))completion;

/**
 * Get tags
 *
 * Completion: Array of focusArea
 */
- (void) getTagsWithCompletion: (void(^)(NSError *error, int statusCode))completion;

/**
 * Payment
 *
 * Completion: NSDictionary
 */
- (void) initiatePaymentWithParam: (NSDictionary *)param completion: (void(^)(NSError *error, NSDictionary *result))completion;
@end
