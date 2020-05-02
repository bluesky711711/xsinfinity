//
//  TranslationsModel.h
//  XSInfinity
//
//  Created by Joseph Marvin Magdadaro on 5/27/18.
//  Copyright © 2018 Joseph Marvin Magdadaro. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "Translations.h"

@interface TranslationsModel : NSObject

+ (TranslationsModel *)sharedInstance;

/**
 * This method will save the translations
 *
 * @param translations - translation key and value
 */
-(void)saveTranslations:(NSArray *)translations;

/**
 * This method will get a translation
 *
 * @param key - translation key ex. (global.exercise)
 *
 * Return - translated string ex. (Exercise)
 */
- (NSString *) getTranslationForKey: (NSString *) key;

/**
 * This method will get the latest translation
 *
 * Return - latest translation
 */
- (Translations *) getLatestTranslation;

@end
