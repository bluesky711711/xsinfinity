//
//  Helper.h
//  XSInfinity
//
//  Created by Joseph Marvin Magdadaro on 5/31/18.
//  Copyright © 2018 Joseph Marvin Magdadaro. All rights reserved.
//

#import <Foundation/Foundation.h>

@interface Helper : NSObject

/**
 * Creates and returns `Helpers` object.
 */
+ (Helper *)sharedHelper;

#pragma mark: Clean Value

/**
 * This method will change null value to ""
 */
- (NSString *) cleanValue: (NSString *) value;

#pragma mark: Dropdown Icon

/**
 * This method will add search icon on textfield
 */
- (UIImageView *) searchIcon;

#pragma mark: Add Shadow And Corner Radius

/**
 * Add drop shadow
 */
- (void)addDropShadowIn:(id )obj withColor:(UIColor *)shadowColor andSetCornerRadiusTo:(float)cornerRadius;

/**
 * Add normal shadow
 */
- (void)addShadowIn:(id )obj withColor:(UIColor *)shadowColor andSetCornerRadiusTo:(float)cornerRadius;

#pragma mark: Add Borders And Corner Radius

/**
 * Flexible border
 */
- (void)setFlexibleBorderIn:(id )obj withColor:(UIColor *)borderColor topBorderWidth:(float)topBorderWidth leftBorderWidth:(float)leftBorderWidth rightBorderWidth:(float)rightBorderWidth bottomBorderWidth:(float)bottomBorderWidth;

/**
 * Create an image with color
 */
- (UIImage *)imageWithColor:(UIColor *)color andBounds:(CGRect)imgBounds;

- (void)withnotactivehabit;
/**
 * Set up tab bar controller from view
 */
- (void)setUpTabBarControllerFrom:(UIViewController *)vc initialIndex:(int)index;

/**
 * Save loggedin user
 */
- (void)saveToKeychainUsername:(NSString *)username andPassword:(NSString *)password;

/**
 * Get saved username
 */
- (NSString *)getSavedUsername;

/**
 * Get saved password
 */
- (NSString *)getSavedUserPassword;

/**
 * generate authentication token from username and password
 */
- (NSString *)authenticationToken;

/**
 * Remove saved user
 */
- (void)removeSavedUser;

/**
 * Remove all saved data for user
 */
- (void)emptySavedData;

/**
 * Get current year
 */
- (int)currentYear;

/**
 * Get current month index
 */
- (int)currentMonthIndex;

/**
 * Check wether the heads up is to be shown or not
 */
-(BOOL)isHeadsUpHidden;

-(BOOL)isForceRefresh;

-(NSString *)userTimeZone;

-(void)playSoundName:(NSString *)soundName extension:(NSString *)extension;

-(NSAttributedString *)formatText:(NSString *)text;

- (NSURLSessionConfiguration *)sessionConfiguration;
- (NSError *)noInternetError;
@end
