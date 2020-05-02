//
//  UserMediaServices.h
//  XSInfinity
//
//  Created by Joseph Marvin Magdadaro on 7/28/18.
//  Copyright © 2018 Jerk Magz. All rights reserved.
//

#import <Foundation/Foundation.h>

typedef NS_ENUM(NSUInteger, UserMediaServicesApi)
{
    UserMediaServices_ProfileImage = 1,
    UserMediaServices_ProfileHeaderImage,
    UserMediaServices_SaveProfileImage,
    UserMediaServices_SaveImage,
    UserMediaServices_UpdateImage,
    UserMediaServices_DeleteImage
};

@interface UserMediaServices : NSObject

+ (UserMediaServices *) sharedInstance;

/**
 * Get user's profile image url
 *
 * Completion: profile image url
 */
- (void) getProfileImageWithCompletion: (void(^)(NSError *error, int statusCode))completion;

/**
 * Get user's profile header image url
 *
 * Completion: profile header image url
 */
- (void) getProfileHeaderImageWithCompletion: (void(^)(NSError *error, int statusCode))completion;

/**
 * Save profile image
 *
 * Completion: Int statusCode
 */
- (void) saveProfileImage:(UIImage *)img withCompletion: (void(^)(NSError *error,  int statusCode))completion;

/**
 * Save image in gallery
 *
 * Completion: Int statusCode
 */
- (void) saveImage:(UIImage *)img withPrivacy:(int)isPrivate withCompletion: (void(^)(NSError *error,  int statusCode))completion;

/**
 * Update image privacy
 *
 * Completion: Int statusCode
 */
- (void) updateImagePrivacy:(int)isPrivate forImage:(NSString *)identifier withCompletion: (void(^)(NSError *error,  int statusCode))completion;

/**
 * Delete image in gallery
 *
 * Completion: Int statusCode
 */
- (void) deleteImage:(NSString *)identifier withCompletion: (void(^)(NSError *error,  int statusCode))completion;

@end
