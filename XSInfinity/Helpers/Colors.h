//
//  Colors.h
//  XSInfinity
//
//  Created by Joseph Marvin Magdadaro on 5/24/18.
//  Copyright © 2018 Joseph Marvin Magdadaro. All rights reserved.
//

#import <Foundation/Foundation.h>

@interface Colors : NSObject

/**
 * Creates and returns `Colors` object.
 */
+ (Colors *)sharedColors;

/**
 * This method will get the color for backgound, border, font etc. for easy module
 *
 * return: easy color
 */
- (UIColor *)easyColor;

/**
* This method will get the color for backgound, border, font etc. for medium module
*
* return: medium color
*/
- (UIColor *)mediumColor;

/**
 * This method will get the color for backgound, border, font etc. for hard module
 *
 * return: hard color
 */
- (UIColor *)hardColor;

/**
 * This method will get blue color
 *
 * return: blue color
 */
- (UIColor *)blueColor;
- (UIColor *)lightBlueColor;

/**
 * This method will get green color
 *
 * return: green color
 */
- (UIColor *)greenColor;

/**
 * This method will get orange color
 *
 * return: orange color
 */
- (UIColor *)orangeColor;

/**
 * This method will get purple color
 *
 * return: purple color
 */
- (UIColor *)purpleColor;

- (UIColor *)darkColor;

- (UIColor *)pinkColor;

- (UIColor *)warning;

- (UIColor *)lightGray;

@end
