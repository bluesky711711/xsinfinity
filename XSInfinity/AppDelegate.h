//
//  AppDelegate.h
//  XSInfinity
//
//  Created by Joseph Marvin Magdadaro on 5/24/18.
//  Copyright © 2018 Joseph Marvin Magdadaro. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "SplashViewController.h"
#import "WXApi.h"

@interface AppDelegate : UIResponder <UIApplicationDelegate>

@property (strong, nonatomic) UIWindow *window;
@property (nonatomic, strong) UINavigationController *navController;
@property (strong, nonatomic) SplashViewController *viewController;
@property (strong, nonatomic) UITabBarController *tabBarController;
@property (retain, nonatomic) UIView *tabBarAnimationView;
@property (retain, nonatomic) UIView *selectedTabBarItemBackgroundView;

@end

