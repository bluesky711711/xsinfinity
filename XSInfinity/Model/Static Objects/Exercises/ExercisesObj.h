//
//  ExercisesObj.h
//  XSInfinity
//
//  Created by Joseph Marvin Magdadaro on 6/14/18.
//  Copyright © 2018 Joseph Marvin Magdadaro. All rights reserved.
//

#import <Foundation/Foundation.h>

@interface ExercisesObj : NSObject
@property (nonatomic,strong) NSString *identifier;
@property (nonatomic,strong) NSString *name;
@property (nonatomic,strong) NSString *desc;
@property (nonatomic,strong) NSString *type;
@property (nonatomic,strong) NSString *difficulty;
@property (nonatomic,strong) NSString *focusAreaId;
@property (nonatomic,strong) NSArray *focusAreas;
@property (nonatomic,strong) NSArray *tags;
@property (nonatomic,strong) NSString *videoId;
@property (nonatomic,strong) NSString *videoTitle;
@property (nonatomic,strong) NSString *videoUrl;
@property (nonatomic,strong) NSString *previewImage;
@property (nonatomic,strong) NSString *tagsIds;
@property (nonatomic,strong) NSString *tagsNames;
@property BOOL isVideoVisible;
@property BOOL disabled;
@property BOOL unlocked;
@property BOOL finished;
@property int orderId;
@property int sets;
@property int repetitions;
@property int points;
@property int duration;
@property (nonatomic,strong) NSString *moduleIdentifier;
@property (nonatomic,strong) NSString *moduleName;

@end
