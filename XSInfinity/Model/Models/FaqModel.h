//
//  FaqModel.h
//  XSInfinity
//
//  Created by Joseph Marvin Magdadaro on 8/9/18.
//  Copyright © 2018 Jerk Magz. All rights reserved.
//

#import <Foundation/Foundation.h>

@interface FaqModel : NSObject

+ (FaqModel *)sharedInstance;

/**
 * This method will get faq categories with faqs from json
 *
 * param: json - array of faq categories w/ faqs
 *
 * return: NSArray of FaqCategoryObj with NSArray of FaqObj(FaqCategoryObj.faqs)
 */

- (void)saveFaqCategories:(NSArray *)json;
- (NSArray *)getAllFaqCategories;
- (NSArray *)getAllFaqsByCategory:(NSString *)categoryId;
- (NSArray *)searchFaqsByTitle:(NSString *)faqTitle;

@end
