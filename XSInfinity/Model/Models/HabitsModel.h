//
//  HabitsModel.h
//  XSInfinity
//
//  Created by Joseph Marvin Magdadaro on 6/29/18.
//  Copyright © 2018 Joseph Marvin Magdadaro. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "HabitsOverview.h"
#import "Habits.h"

@interface HabitsModel : NSObject

+ (HabitsModel *)sharedInstance;

/**
 * This method will get habits overview from json
 *
 * param: json - dictionary of habits overview
 *
 * return: HeadUpObj
 */
- (void)saveHabitsOverview:(NSDictionary *)json;
- (HabitsOverview *)getHabitsOverview;

/**
 * This method will get list of habits
 *
 * param: json - array of habits
 *
 * return: NSArray of HabitsObj
 */
- (void)saveHabits:(NSArray *)json;
- (NSArray *)getAllHabits;
- (NSArray *)getUnlockedHabits;
- (NSArray *)getFinishedHabits;
- (NSArray *)getUnlockedAndUnFinishedHabits;

- (void)unlockHabit:(Habits *)habit;
- (void)finishHabit:(Habits *)habit;
- (void)unFinishHabit:(Habits *)habit;

@end
