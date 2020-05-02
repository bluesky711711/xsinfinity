//
//  GalleryObj.h
//  XSInfinity
//
//  Created by Joseph Marvin Magdadaro on 7/17/18.
//  Copyright © 2018 Jerk Magz. All rights reserved.
//

#import <Foundation/Foundation.h>

@interface GalleryObj : NSObject
@property (nonatomic,strong) NSString *identifier;
@property (nonatomic,strong) NSString *url;
@property (nonatomic,strong) NSString *creationDate;
@property (nonatomic,strong) NSString *type;
@property int isPrivate;

@end
