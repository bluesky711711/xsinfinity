//
//  OnBoardingContentViewController.h
//  XSInfinity
//
//  Created by Joseph Marvin Magdadaro on 16/12/2018.
//  Copyright © 2018 Jerk Magz. All rights reserved.
//

#import <UIKit/UIKit.h>

@protocol OnBoardingContentViewControllerDelegate;

@interface OnBoardingContentViewController : UIViewController
@property (weak) id <OnBoardingContentViewControllerDelegate> delegate;
@property (assign, nonatomic) NSInteger index;
@end

@protocol OnBoardingContentViewControllerDelegate <NSObject>
@optional
-(void)navigateToNextSlideWithCurrentIndex: (NSInteger)index;
-(void)finishedOnBoarding;
@end
