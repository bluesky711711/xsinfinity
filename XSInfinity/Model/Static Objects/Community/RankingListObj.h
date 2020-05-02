//
//  RankingListObj.h
//  XSInfinity
//
//  Created by Joseph Marvin Magdadaro on 7/17/18.
//  Copyright © 2018 Jerk Magz. All rights reserved.
//

#import <Foundation/Foundation.h>

@interface RankingListObj : NSObject
@property (nonatomic,strong) NSString *identifier;
@property (nonatomic,strong) NSString *name;
@property (nonatomic,strong) NSString *country;
@property (nonatomic,strong) NSString *profilePicture;
@property int rankNumber;

@end
