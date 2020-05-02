//
//  HeadUpObj.h
//  XSInfinity
//
//  Created by Joseph Marvin Magdadaro on 7/26/18.
//  Copyright © 2018 Jerk Magz. All rights reserved.
//

#import <Foundation/Foundation.h>

@interface HeadUpObj : NSObject
@property int personalExerciseGoal;
@property int passedExercises;
@property int possibleHabits;
@property int passedHabits;
@property BOOL resetHabitTracker;
@property (nonatomic,strong) NSArray *unlockedExercises;

@end
