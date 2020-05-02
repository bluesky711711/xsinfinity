//
//  HabitsOverview.h
//  XSInfinity
//
//  Created by Jerk Nino Magdadaro on 26/08/2018.
//  Copyright © 2018 Jerk Magz. All rights reserved.
//

#import "RLMObject.h"

@interface HabitsOverview : RLMObject
@property int overviewId;
@property int unlocked;
@property int maximumHabits;
@property int habitPoints;
@property int successiveDays;
@property int completedCycles;
@property (nonatomic,strong) NSString *lastReset;

@end
