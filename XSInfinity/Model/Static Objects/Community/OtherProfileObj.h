//
//  OtherProfileObj.h
//  XSInfinity
//
//  Created by Joseph Marvin Magdadaro on 7/17/18.
//  Copyright © 2018 Jerk Magz. All rights reserved.
//

#import <Foundation/Foundation.h>

@interface OtherProfileObj : NSObject
@property (nonatomic,strong) NSString *name;
@property (nonatomic,strong) NSString *country;
@property int exercisePoints;
@property int habitPoints;
@property int communityRank;
@property (nonatomic,strong) NSString *profilePictureIdentifier;
@property (nonatomic,strong) NSString *profilePictureUrl;
@property BOOL profilePictureVisible;
@property (nonatomic,strong) NSString *profileHeaderIdentifier;
@property (nonatomic,strong) NSString *profileHeaderUrl;
@property BOOL profileHeaderVisible;
@property (nonatomic,strong) NSArray *gallery;

@end
