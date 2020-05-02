//
//  HabitsOverviewObj.h
//  XSInfinity
//
//  Created by Joseph Marvin Magdadaro on 7/27/18.
//  Copyright © 2018 Jerk Magz. All rights reserved.
//

#import <Foundation/Foundation.h>

@interface HabitsOverviewObj : NSObject
@property int unlocked;
@property int maximumHabits;
@property int habitPoints;
@property int successiveDays;
@property int completedCycles;
@property (nonatomic,strong) NSString *lastReset;

@end
