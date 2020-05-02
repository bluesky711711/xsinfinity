//
//  HabitsOverview.m
//  XSInfinity
//
//  Created by Jerk Nino Magdadaro on 26/08/2018.
//  Copyright © 2018 Jerk Magz. All rights reserved.
//

#import "HabitsOverview.h"

@implementation HabitsOverview

+ (NSString *)primaryKey {
    return @"overviewId";
}

+ (NSArray *)indexedProperties {
    return @[@"overviewId"];
}

@end
