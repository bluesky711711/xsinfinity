//
//  Modules.h
//  XSInfinity
//
//  Created by Jerk Nino Magdadaro on 26/08/2018.
//  Copyright © 2018 Jerk Magz. All rights reserved.
//

#import "RLMObject.h"

@interface Modules : RLMObject
@property (nonatomic,strong) NSString *identifier;
@property (nonatomic,strong) NSString *name;
@property (nonatomic,strong) NSString *desc;
@property (nonatomic,strong) NSString *howToUseDescription;
@property (nonatomic,strong) NSString *image;
@property int numberOfExercises;
@property int unlockedExercises;
@property int passedEasy;
@property int passedMedium;
@property int passedHard;
@property int totalExerciseEasy;
@property int totalExerciseMedium;
@property int totalExerciseHard;
@property int orderId;
@property float price;
@property BOOL disabled;
@property BOOL isModuleUnlocked;
//@property (nonatomic,strong) NSArray *exercises;

@end
