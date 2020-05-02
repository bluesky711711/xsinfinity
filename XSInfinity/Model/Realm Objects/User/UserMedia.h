//
//  UserMedia.h
//  XSInfinity
//
//  Created by Jerk Nino Magdadaro on 30/08/2018.
//  Copyright © 2018 Jerk Magz. All rights reserved.
//

#import "RLMObject.h"

@interface UserMedia : RLMObject
@property (nonatomic,strong) NSString *media;
@property (nonatomic,strong) NSString *url;

@end
