//
//  HabitsServices.h
//  XSInfinity
//
//  Created by Joseph Marvin Magdadaro on 6/29/18.
//  Copyright © 2018 Joseph Marvin Magdadaro. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "HabitsOverviewObj.h"

typedef NS_ENUM(NSUInteger, HabitsServicesApi)
{
    HabitsServicesApi_HabitsOverview = 1,
    HabitsServicesApi_AllHabits,
    HabitsServicesApi_UnlockedHabits,
    HabitsServicesApi_AvailableHabits,
    HabitsServicesApi_StartHabit,
    HabitsServicesApi_StopHabit,
    HabitsServicesApi_FinishHabit,
    HabitsServicesApi_FinishAllHabits,
    HabitsServicesApi_UndoHabit,
};

@interface HabitsServices : NSObject

+ (HabitsServices *) sharedInstance;

/**
 * Get habits overview
 *
 * Completion: Int statusCode
 */
- (void) getHabitsOverviewWithCompletion: (void(^)(NSError *error, int statusCode, NSArray *notPassedHabits, NSArray *unlockedHabits))completion;

/**
 * Get all habits
 *
 * Completion: Int statusCode
 */
- (void) getAllHabitsWithCompletion: (void(^)(NSError *error, int statusCode))completion;

/**
 * Get unlocked habits and returns passed or not passed habits
 *
 * Completion: Array of habits
 */
- (void) getUnlockedHabitsWithCompletion: (void(^)(NSError *error, int statusCode, NSArray *habits))completion;

/**
 * Get unlocked habits but return only Not Passed habits
 *
 * Completion: Array of habits
 */
- (void) getAvailableHabitsWithCompletion: (void(^)(NSError *error, int statusCode, NSArray *habits))completion;

/**
 * Start habits
 *
 * Completion: Int statusCode
 */
- (void) startHabitsWithCompletion: (void(^)(NSError *error, int statusCode))completion;

/**
 * Stop habits
 *
 * Completion: Int statusCode
 */
- (void) stopHabitsWithCompletion: (void(^)(NSError *error, int statusCode))completion;

/**
 * Finish specific habit
 *
 * Completion: Int statusCode
 */
- (void) finishHabitWithId:(NSString *)habitId withCompletion: (void(^)(NSError *error,  int statusCode))completion;

/**
 * Finish all todays habits
 *
 * Completion: Int statusCode
 */
- (void) finishAllHabitsWithCompletion: (void(^)(NSError *error,  int statusCode))completion;

- (void) undoHabitWithId:(NSString *)habitId withCompletion: (void(^)(NSError *error,  int statusCode))completion;

@end
