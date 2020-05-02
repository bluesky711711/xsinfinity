//
//  UserPerformance.h
//  XSInfinity
//
//  Created by Jerk Nino Magdadaro on 29/08/2018.
//  Copyright © 2018 Jerk Magz. All rights reserved.
//

#import "RLMObject.h"

@interface UserPerformance : RLMObject
@property (nonatomic,strong) NSString *performanceDate;
@property (nonatomic,strong) NSString *performanceType;
@property (nonatomic,strong) NSString *performanceDateType;
@property int points;

@end
