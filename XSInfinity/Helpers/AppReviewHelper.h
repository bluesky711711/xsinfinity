//
//  AppReviewHelper.h
//  XSInfinity
//
//  Created by Joseph Marvin Magdadaro on 17/01/2019.
//  Copyright © 2019 Jerk Magz. All rights reserved.
//

#import <Foundation/Foundation.h>

@interface AppReviewHelper : NSObject
+ (AppReviewHelper *)sharedHelper;
- (void)saveLastTimeAppReviewAppeared;
- (void)checkAndFireAppRating;
@end
