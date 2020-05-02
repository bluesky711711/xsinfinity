//
//  Exercises.h
//  XSInfinity
//
//  Created by Jerk Nino Magdadaro on 26/08/2018.
//  Copyright © 2018 Jerk Magz. All rights reserved.
//

#import "RLMObject.h"

@interface Exercises : RLMObject
@property (nonatomic,strong) NSString *identifier;
@property (nonatomic,strong) NSString *name;
@property (nonatomic,strong) NSString *desc;
@property (nonatomic,strong) NSString *type;
@property (nonatomic,strong) NSString *difficulty;
@property (nonatomic,strong) NSString *focusAreaId;
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
