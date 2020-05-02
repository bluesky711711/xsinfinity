//
//  UserInfo.m
//  XSInfinity
//
//  Created by Jerk Nino Magdadaro on 26/08/2018.
//  Copyright © 2018 Jerk Magz. All rights reserved.
//

#import "UserInfo.h"

@implementation UserInfo

+ (NSString *)primaryKey {
    return @"infoId";
}

+ (NSArray *)indexedProperties {
    return @[@"infoId"];
}

@end
