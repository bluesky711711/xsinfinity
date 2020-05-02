//
//  CustomNavigation.h
//  XSInfinity
//
//  Created by Joseph Marvin Magdadaro on 6/28/18.
//  Copyright © 2018 Joseph Marvin Magdadaro. All rights reserved.
//

#import <Foundation/Foundation.h>

@interface CustomNavigation : NSObject

/**
 * Creates and returns `CustomNavigation` object.
 */
+ (CustomNavigation *)sharedInstance;

/**
 * Add/remove blur effect and white line in bottom of navigation
 */
- (void)addOrRemoveBlurEffectAndLineForNavigationInViewController:(UIViewController *)vc;

/**
 * Add white line in bottom of navigation
 */
- (void)addNavBarCustomBottomLineIn:(UIViewController *)vc;

/**
 * Remove blur effect of navigation
 */
- (void)removeBlurEffectIn:(UIViewController *)vc;

/**
 * Remove white line in bottom of navigation
 */
- (void)removeNavBarCustomBottomLineIn:(UIViewController *)vc;
@end
