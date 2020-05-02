//
//  CommunityModel.h
//  XSInfinity
//
//  Created by Joseph Marvin Magdadaro on 7/17/18.
//  Copyright © 2018 Jerk Magz. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "OtherProfileObj.h"

@interface CommunityModel : NSObject

+ (CommunityModel *)sharedInstance;

/**
 * This method will get ranking list
 *
 * param: json - array of users
 *
 * return: NSArray of RankingListObj
 */
- (NSArray *)getRankingListFromJson:(NSArray *)json;

/**
 * This method will get other user's profile info
 *
 * param: json - other profile info
 *
 * return: OtherProfileObj
 */
- (OtherProfileObj *)getOtherProfileInfoFromJson:(NSDictionary *)json;

/**
 * This method will user's activity history
 *
 * param: json - user's activities
 *
 * return: NSDictionary of Array of ExerciseActivityObj, HabitActivityObj and AppUsageObj
 */
- (NSDictionary *)getUserActivitiesFromJson:(NSDictionary *)json;

@end
