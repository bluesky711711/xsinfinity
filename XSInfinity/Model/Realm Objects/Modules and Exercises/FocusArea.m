//
//  FocusArea.m
//  XSInfinity
//
//  Created by Jerk Nino Magdadaro on 03/11/2018.
//  Copyright © 2018 Jerk Magz. All rights reserved.
//

#import "FocusArea.h"

@implementation FocusArea

+ (NSString *)primaryKey {
    return @"identifier";
}

+ (NSArray *)indexedProperties {
    return @[@"identifier"];
}

@end
