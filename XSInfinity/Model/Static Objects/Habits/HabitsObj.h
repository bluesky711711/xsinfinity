//
//  HabitsObj.h
//  XSInfinity
//
//  Created by Joseph Marvin Magdadaro on 6/29/18.
//  Copyright © 2018 Joseph Marvin Magdadaro. All rights reserved.
//

#import <Foundation/Foundation.h>

@interface HabitsObj : NSObject
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
