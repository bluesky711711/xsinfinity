//
//  GalleryCropper.h
//  XSInfinity
//
//  Created by Joseph Marvin Magdadaro on 7/27/13.
//  Copyright © 2013 Jerk Magz. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "GalleryObj.h"

@protocol GalleryCropperDelegate;

@interface GalleryCropper : UIViewController
@property (assign, nonatomic) id <GalleryCropperDelegate>dismissDelegate;

@property (nonatomic, retain) GalleryObj *gallery;
@property (nonatomic, retain) UIImage *image;
@property (nonatomic, retain) NSString *dateStr;

@end

@protocol GalleryCropperDelegate<NSObject>
@optional
- (void)saveImage:(UIImage *)croppedImg withPrivacy:(int)isPrivate;
- (void)updateImagePrivacy:(int)isPrivate forImage:(NSString *)identifier;
- (void)deleteImage:(NSString *)identifier;

@end
