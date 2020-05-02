//
//  Translations.m
//  XSInfinity
//
//  Created by Joseph Marvin Magdadaro on 5/26/18.
//  Copyright © 2018 Joseph Marvin Magdadaro. All rights reserved.
//

#import "Translations.h"

@implementation Translations

+ (NSString *)primaryKey {
    return @"translationId";
}

+ (NSArray *)indexedProperties {
    return @[@"translationId"];
}
@end
