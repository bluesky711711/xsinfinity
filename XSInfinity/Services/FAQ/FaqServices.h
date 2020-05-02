//
//  FaqServices.h
//  XSInfinity
//
//  Created by Joseph Marvin Magdadaro on 8/9/18.
//  Copyright © 2018 Jerk Magz. All rights reserved.
//

#import <Foundation/Foundation.h>

@interface FaqServices : NSObject

+ (FaqServices *) sharedInstance;

/**
 * Get all categories with faqs
 *
 * Completion: Int statusCode
 */
- (void) getFaqCategoriesWithFaqsWithCompletion: (void(^)(NSError *error,  int statusCode))completion;

@end
