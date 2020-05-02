//
//  Habits.h
//  XSInfinity
//
//  Created by Jerk Nino Magdadaro on 26/08/2018.
//  Copyright © 2018 Jerk Magz. All rights reserved.
//

#import "RLMObject.h"

@interface Habits : RLMObject
@property (nonatomic,strong) NSString *identifier;
@property (nonatomic,strong) NSString *name;
@property (nonatomic,strong) NSString *desc;
@property (nonatomic,strong) NSString *excerpt;
@property (nonatomic,strong) NSString *img;
@property BOOL disabled;
@property BOOL unlocked;
@property BOOL finished;
@property int orderId;
@property int points;

@end
