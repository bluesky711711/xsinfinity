//
//  ExercisesSummary.m
//  XSInfinity
//
//  Created by Jerk Nino Magdadaro on 26/08/2018.
//  Copyright © 2018 Jerk Magz. All rights reserved.
//

#import "ExercisesSummary.h"

@implementation ExercisesSummary

+ (NSString *)primaryKey {
    return @"summaryId";
}

+ (NSArray *)indexedProperties {
    return @[@"summaryId"];
}

@end
