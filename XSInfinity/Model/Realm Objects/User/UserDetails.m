//
//  UserDetails.m
//  XSInfinity
//
//  Created by Joseph Marvin Magdadaro on 07/04/2019.
//  Copyright © 2019 Jerk Magz. All rights reserved.
//

#import "UserDetails.h"

@implementation UserDetails

+ (NSString *)primaryKey {
    return @"rowId";
}

+ (NSArray *)indexedProperties {
    return @[@"rowId"];
}
@end
