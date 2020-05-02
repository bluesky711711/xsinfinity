//
//  UserSummary.m
//  XSInfinity
//
//  Created by Jerk Nino Magdadaro on 29/08/2018.
//  Copyright © 2018 Jerk Magz. All rights reserved.
//

#import "UserSummary.h"

@implementation UserSummary

+ (NSString *)primaryKey {
    return @"summaryId";
}

+ (NSArray *)indexedProperties {
    return @[@"summaryId"];
}

@end
