//
//  TranslationsServices.h
//  XSInfinity
//
//  Created by Joseph Marvin Magdadaro on 5/26/18.
//  Copyright © 2018 Joseph Marvin Magdadaro. All rights reserved.
//

#import <Foundation/Foundation.h>

@interface TranslationsServices : NSObject

+ (TranslationsServices *) sharedInstance;

/**
 * Get translations
 *
 * Completion: NSDictionary of translations
 */
- (void) getTranslationsWithCompletion: (void(^)(NSError *error,  BOOL successful))completion;
@end
