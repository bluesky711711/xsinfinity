//
//  ExercisesSummary.h
//  XSInfinity
//
//  Created by Jerk Nino Magdadaro on 26/08/2018.
//  Copyright © 2018 Jerk Magz. All rights reserved.
//

#import "RLMObject.h"

@interface ExercisesSummary : RLMObject
@property int summaryId;
@property int exercisePoints;
@property int exercisesUnlocked;
@property int personalExerciseGoal;
@property int passedExercisesToday;
@property int continuousDays;

@end
