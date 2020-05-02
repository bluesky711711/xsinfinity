//
//  UserModel.h
//  XSInfinity
//
//  Created by Joseph Marvin Magdadaro on 6/6/18.
//  Copyright © 2018 Joseph Marvin Magdadaro. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "HeadUpObj.h"
#import "UserInfoObj.h"
#import "UserSummary.h"
#import "UserInfo.h"
#import "UserDetails.h"
#import "UserPerformance.h"

@interface UserModel : NSObject

+ (UserModel *)sharedInstance;

- (void)saveUserToken:(NSString *)token;
- (NSString *)accessToken;

/**
 * This method will get today's head up from json
 *
 * param: json - dictionary of head up w/ array of unlocked exercises
 *
 * return: HeadUpObj
 */
- (void)saveUserCommunitySummary:(NSDictionary *)json;
- (UserSummary *)getUserCommunitySummary;

- (void)saveUserPerformance:(NSDictionary *)json;
- (NSArray *)getUserPerformanceFor:(NSString *)type withDateType:(NSString *)dateType;
- (UserPerformance *)getUserPerformanceFor:(NSString *)type withDateType:(NSString *)dateType andDate:(NSString *)dateStr;
- (NSArray *)getUserPerformanceThatContains:(NSString *)yearAndMonth;

/**
 * This method will get today's head up from json
 *
 * param: json - dictionary of head up w/ array of unlocked exercises
 *
 * return: HeadUpObj
 */
- (HeadUpObj *)getTodaysHeadUpFromJson:(NSDictionary *)json;

/**
 * This method will get user's info from json
 *
 * param: json - dictionary of user's info
 *
 * return: UserInfoObj
 */
- (void)saveUserInfo:(NSDictionary *)json;
- (UserInfo *)getUserInfo;

/**
 * This method will get user's gallery from json
 *
 * param: json - array of gallery image
 *
 * return: NSArray of GalleryObj
 */
- (void)saveGallery:(NSArray *)json;
- (NSArray *)getAllGallery;

- (void)saveImageUrl:(NSString *)url ofMedia:(NSString *)media;
- (NSString *)getImageUrlOfMedia:(NSString *)media;

/**
 * This method will get user's purchase history from json
 *
 * param: json - array of purchased modules
 *
 * return: NSArray of PurchaseHistoryObj
 */
- (NSArray *)getUserPurchaseHistoryFromJson:(NSArray *)json;
@end
