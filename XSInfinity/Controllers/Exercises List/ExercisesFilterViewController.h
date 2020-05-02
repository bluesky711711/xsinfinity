//
//  ExercisesFilterViewController.h
//  XSInfinity
//
//  Created by Joseph Marvin Magdadaro on 6/4/18.
//  Copyright © 2018 Joseph Marvin Magdadaro. All rights reserved.
//

#import <UIKit/UIKit.h>

@protocol ExercisesFilterViewControllerDelegate;

@interface ExercisesFilterViewController : UIViewController
@property (assign, nonatomic) id <ExercisesFilterViewControllerDelegate>dismissDelegate;
@property (strong, nonatomic) NSMutableDictionary *params;
@end

@protocol ExercisesFilterViewControllerDelegate<NSObject>
@optional
- (void)filterExercisesWithFilters:(NSDictionary *)filters;
@end
