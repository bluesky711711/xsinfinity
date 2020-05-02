//
//  Fonts.h
//  XSInfinity
//
//  Created by Joseph Marvin Magdadaro on 5/24/18.
//  Copyright © 2018 Joseph Marvin Magdadaro. All rights reserved.
//

#import <Foundation/Foundation.h>

@interface Fonts : NSObject

/**
 * Creates and returns `Fonts` object.
 */
+ (Fonts *)sharedFonts;

/**
 * Set default font size for Headline Title
 *
 * return: UIFont
 */
- (UIFont *)headerFont;
- (UIFont *)headerFontLight;

/**
 * Set default font size for Titles
 *
 * return: UIFont
 */
- (UIFont *)titleFont;

/**
 * Set bold font size for Titles
 *
 * return: UIFont
 */
- (UIFont *)titleFontBold;

/**
 * Set font size for normal texts
 *
 * return: UIFont
 */
- (UIFont *)normalFont;

/**
 * Set bold font size for normal texts
 *
 * return: UIFont
 */
- (UIFont *)normalFontBold;
/**
 * Set font size for small texts
 *
 * return: UIFont
 */
- (UIFont *)smallFont;
- (UIFont *)smallFontBold;
/**
 * Set font size for big texts
 *
 * return: UIFont
 */
- (UIFont *)bigFontBold;

- (NSString *)normalFontName;
- (int)normalFontSize;
@end
