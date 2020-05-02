//
//  Tags.m
//  XSInfinity
//
//  Created by Joseph Marvin Magdadaro on 21/01/2019.
//  Copyright © 2019 Jerk Magz. All rights reserved.
//

#import "Tags.h"

@implementation Tags

+ (NSString *)primaryKey {
    return @"identifier";
}

+ (NSArray *)indexedProperties {
    return @[@"identifier"];
}
@end
