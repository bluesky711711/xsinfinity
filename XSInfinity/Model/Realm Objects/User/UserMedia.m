//
//  UserMedia.m
//  XSInfinity
//
//  Created by Jerk Nino Magdadaro on 30/08/2018.
//  Copyright © 2018 Jerk Magz. All rights reserved.
//

#import "UserMedia.h"

@implementation UserMedia

+ (NSString *)primaryKey {
    return @"media";
}

+ (NSArray *)indexedProperties {
    return @[@"media"];
}

@end
