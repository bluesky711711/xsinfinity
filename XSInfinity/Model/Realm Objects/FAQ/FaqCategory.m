//
//  FaqCategory.m
//  XSInfinity
//
//  Created by Jerk Nino Magdadaro on 26/08/2018.
//  Copyright © 2018 Jerk Magz. All rights reserved.
//

#import "FaqCategory.h"

@implementation FaqCategory

+ (NSString *)primaryKey {
    return @"identifier";
}

+ (NSArray *)indexedProperties {
    return @[@"identifier"];
}

@end
