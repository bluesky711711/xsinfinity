//
//  BookmarkedExercises.m
//  XSInfinity
//
//  Created by Joseph Marvin Magdadaro on 8/10/18.
//  Copyright © 2018 Jerk Magz. All rights reserved.
//

#import "BookmarkedExercises.h"

@implementation BookmarkedExercises

+ (NSString *)primaryKey {
    return @"exerciseId";
}

+ (NSArray *)indexedProperties {
    return @[@"exerciseId"];
}

@end
