//
//  CommunityServices.h
//  XSInfinity
//
//  Created by Joseph Marvin Magdadaro on 7/17/18.
//  Copyright © 2018 Jerk Magz. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "OtherProfileObj.h"

@interface CommunityServices : NSObject

+ (CommunityServices *) sharedInstance;

/**
 * Get ranking list
 *
 * Completion: Ranking list
 */
- (void) getRankingListWithCompletion: (void(^)(NSError *error, int statusCode, NSArray *rankingList))completion;

/**
 * Get other user's profile info
 *
 * Completion: Other Profile Info
 */
- (void) getOtherUserProfile:(NSString *)identifier withCompletion: (void(^)(NSError *error, int statusCode, OtherProfileObj *otherProfile))completion;

/**
 * Get user's activities
 *
 * Completion: NSDictionary of activities
 */
- (void) getActivitiesForUserWithCompletion: (void(^)(NSError *error, int statusCode, NSDictionary *userActivities))completion;

@end
