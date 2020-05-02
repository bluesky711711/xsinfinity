//
//  UserSummary.h
//  XSInfinity
//
//  Created by Jerk Nino Magdadaro on 29/08/2018.
//  Copyright © 2018 Jerk Magz. All rights reserved.
//

#import "RLMObject.h"

@interface UserSummary : RLMObject
@property int summaryId;
@property int communityRank;
@property int exercisePoints;
@property int habitPoints;
@property int communityRankChangePreviousWeek;
@property int communityRankChangePreviousWeekPercent;

@end
