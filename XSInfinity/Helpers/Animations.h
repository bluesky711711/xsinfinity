//
//  Animations.h
//  XSInfinity
//
//  Created by Joseph Marvin Magdadaro on 5/25/18.
//  Copyright © 2018 Joseph Marvin Magdadaro. All rights reserved.
//

#import <Foundation/Foundation.h>

@interface Animations : NSObject

/**
 * Creates and returns `Animations` object.
 */
+ (Animations *)sharedAnimations;

/**
 * Show/Hide status bar
 */
- (BOOL)setStatusBarFromViewControler:(UIViewController *)vc
                              visible:(BOOL)show;

/**
 * Show/Hide tab bar with animations or not
 */
- (void)setTabBar:(UITabBar *)tabBar
fromViewController:(UIViewController *)vc
          visible:(BOOL)visible
         animated:(BOOL)animated;

/**
 * Overlay view spring animation
 */
- (void)animateOverlayViewIn:(UIView *)view byTopConstraint:(NSLayoutConstraint *)topConstraint;

/**
 * Zoom out animation
 */
- (void)zoomOutAnimationForView:(UIView *)view;

/**
 * Zoom in zoom out spring animation
 */
- (void)zoomSpringAnimationForView:(UIView *)view;

/**
 * Table view cell fade in from bottom to top animation
 */
- (void)fadeInBottomToTopAnimationOnCell:(UITableViewCell *)cell withDelay:(float)delay;
@end
