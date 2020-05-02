//
//  AppReviewHelper.m
//  XSInfinity
//
//  Created by Joseph Marvin Magdadaro on 17/01/2019.
//  Copyright © 2019 Jerk Magz. All rights reserved.
//

#import "AppReviewHelper.h"
#import <StoreKit/StoreKit.h>

@implementation AppReviewHelper

+ (AppReviewHelper *)sharedHelper {
    __strong static AppReviewHelper *sharedHelper = nil;
    static dispatch_once_t onceToken;
    dispatch_once(&onceToken, ^{
        sharedHelper = [[AppReviewHelper alloc] init];
    });
    return sharedHelper;
}

- (void)saveLastTimeAppReviewAppeared{
    NSDate *currDate = [NSDate date];
    //NSDate *currDate = [[NSDate date] dateByAddingTimeInterval:-7*24*60*60];
    SET_LAST_TIME_APPREVIEW_APPEARED(currDate)
}

- (void)checkAndFireAppRating{
    NSDate *currDate = [NSDate date];
    NSDate *lastTimeAppReviewAppear = LAST_TIME_APPREVIEW_APPEARED;
    NSTimeInterval secondsBetween = [currDate timeIntervalSinceDate:lastTimeAppReviewAppear];
    int numberOfDays = secondsBetween / 86400;
    
    if(numberOfDays >= 7){
        [SKStoreReviewController requestReview];
        [self saveLastTimeAppReviewAppeared];
    }
}
@end
