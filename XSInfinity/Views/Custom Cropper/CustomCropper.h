//
//  CustomCropper.h
//  XSInfinity
//
//  Created by Joseph Marvin Magdadaro on 7/2/18.
//  Copyright © 2018 Joseph Marvin Magdadaro. All rights reserved.
//

#import <UIKit/UIKit.h>

@protocol CustomCropperDelegate;

@interface CustomCropper : UIViewController
@property (assign, nonatomic) id <CustomCropperDelegate>dismissDelegate;

@property (nonatomic, retain) UIImage *image;

@end

@protocol CustomCropperDelegate<NSObject>
@optional
- (void)croppingImageDone:(UIImage *)croppedImg;
@end
