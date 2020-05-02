//
//  UserServices.h
//  XSInfinity
//
//  Created by Joseph Marvin Magdadaro on 6/6/18.
//  Copyright © 2018 Joseph Marvin Magdadaro. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "HeadUpObj.h"
#import "UserInfoObj.h"
#import "UserSummaryObj.h"

typedef NS_ENUM(NSUInteger, UserServicesApi)
{
    UserServicesApi_CreateUserPreferences = 1,
    UserServicesApi_CreateUser,
    UserServicesApi_UpdateUserTimezone,
    UserServicesApi_SignIn,
    UserServicesApi_SendActivation,
    UserServicesApi_ActivateUser,
    UserServicesApi_SendForgotPassword,
    UserServicesApi_SetNewPassword,
    UserServicesApi_UpdatePassword,
    UserServicesApi_UpdateEmail,
    UserServicesApi_TodaysHeadsUp,
    UserServicesApi_UserGallery,
    UserServicesApi_UserInfo,
    UserServicesApi_UserCommunity,
    UserServicesApi_UserPerformance,
    UserServicesApi_DeleteAccount,
    UserServicesApi_PurchasedModuleHistory
};

@interface UserServices : NSObject

+ (UserServices *) sharedInstance;

/**
 * Create user prefenrences
 *
 * Completion: Int statusCode
 */
- (void) createUserPreferences:(NSDictionary *)params withCompletion: (void(^)(NSError *error,  int statusCode))completion;

/**
 * Create user in Try For Free
 *
 * Completion: Int statusCode
 */
- (void) createUser:(NSDictionary *)param withCompletion: (void(^)(NSError *error,  int statusCode))completion;

/**
 * Update user timezone
 *
 * Completion: Int statusCode
 */
- (void) updateUserTimeZone:(NSString *)timezone withCompletion: (void(^)(NSError *error,  int statusCode))completion;

/**
 * Sign in
 *
 * Completion: Int statusCode
 */
- (void) signInWithUsername:(NSString *)username andPassword:(NSString *)password withCompletion: (void(^)(NSError *error,  int statusCode, NSDictionary *overview))completion;

/**
 * Send activation mail with deeplink to username's email
 *
 * Completion: Int statusCode
 */
- (void) sendActivationMailToUser:(NSString *)username withCompletion: (void(^)(NSError *error,  int statusCode))completion;

/**
 * Activate user
 *
 * Completion: Int statusCode
 */
- (void) activateUser:(NSString *)username withCode:(NSString *)code withCompletion: (void(^)(NSError *error,  int statusCode))completion;

/**
 * Send forgot password mail with deeplink to username's email
 *
 * Completion: Int statusCode
 */
- (void) sendForgotMailToUser:(NSString *)username withCompletion: (void(^)(NSError *error,  int statusCode))completion;

/**
 * Set new password
 *
 * Completion: Int statusCode
 */
- (void) setNewPassword:(NSString *)newPassword forUser:(NSString *)username withCode:(NSString *)code withCompletion: (void(^)(NSError *error,  int statusCode))completion;

/**
 * Update user's password
 *
 * Completion: Int statusCode
 */
- (void) updatePassword:(NSString *)password withCompletion: (void(^)(NSError *error,  int statusCode))completion;

/**
 * Update user's email
 *
 * Completion: Int statusCode
 */
- (void) updateEmail:(NSString *)email withCompletion: (void(^)(NSError *error,  int statusCode))completion;

/**
 * Get today's head up
 *
 * Completion: Users todays head up info
 */
- (void) getTodaysHeadUpWithCompletion: (void(^)(NSError *error, int statusCode, HeadUpObj *headUp))completion;

/**
 * Get user's gallery
 *
 * Completion: Int statusCode
 */
- (void) getUsersGalleryWithCompletion: (void(^)(NSError *error,  int statusCode))completion;

/**
 * Get user's overview
 *
 * Completion: Dictionary
 */
- (void) getUserOverviewWithCompletion: (void(^)(NSError *error,  NSDictionary *overview))completion;

/**
 * Get user's info
 *
 * Completion: Int statusCode
 */
- (void) getUserInfoWithCompletion: (void(^)(NSError *error,  int statusCode))completion;

/**
 * Get user's community info summary
 *
 * Completion: Int statusCode
 */
- (void) getUserCommunitySummaryWithCompletion: (void(^)(NSError *error,  int statusCode))completion;

/**
 * Get user's performance
 *
 * Completion: User's performance
 */
- (void) getUserPerformanceWithStartDate:(NSDate *)sDate endDate:(NSDate *)eDate completion: (void(^)(NSError *error,  int statusCode))completion;

/**
 * Delete account and data
 *
 * Completion: Int statusCode
 */
- (void) deleteAccountWithCompletion: (void(^)(NSError *error,  int statusCode))completion;

/**
 * Get user's purchase history
 *
 * Completion: Array of purchased modules
 */
- (void) getpurchasedModuleHistoryWithCompletion: (void(^)(NSError *error, int statusCode, NSArray *purchasedModules))completion;
@end
