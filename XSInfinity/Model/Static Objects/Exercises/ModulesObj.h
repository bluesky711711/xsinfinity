//
//  ModulesObj.h
//  XSInfinity
//
//  Created by Joseph Marvin Magdadaro on 6/14/18.
//  Copyright © 2018 Joseph Marvin Magdadaro. All rights reserved.
//

#import <Foundation/Foundation.h>

@interface ModulesObj : NSObject
@property (nonatomic,strong) NSString *identifier;
@property (nonatomic,strong) NSString *name;
@property (nonatomic,strong) NSString *desc;
@property int numberOfExercises;
@property int unlockedExercises;
@property int passedEasy;
@property int passedMedium;
@property int passedHard;
@property int totalExerciseEasy;
@property int totalExerciseMedium;
@property int totalExerciseHard;
@property float price;
@property BOOL disabled;
@property BOOL isModuleUnlocked;
@property (nonatomic,strong) NSArray *exercises;

@end
