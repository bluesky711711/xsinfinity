//
//  SingleExerciseViewController.h
//  XSInfinity
//
//  Created by Joseph Marvin Magdadaro on 6/16/18.
//  Copyright © 2018 Joseph Marvin Magdadaro. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "Exercises.h"
#import "Modules.h"

@interface SingleExerciseViewController : UIViewController

@property (nonatomic, retain) Exercises *exercise;
@property (nonatomic, retain) Modules *module;

@end
