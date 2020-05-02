//
//  Gallery.m
//  XSInfinity
//
//  Created by Jerk Nino Magdadaro on 26/08/2018.
//  Copyright © 2018 Jerk Magz. All rights reserved.
//

#import "Gallery.h"

@implementation Gallery

+ (NSString *)primaryKey {
    return @"identifier";
}

+ (NSArray *)indexedProperties {
    return @[@"identifier"];
}

@end
