//
//  SettingsViewController.h
//  XSInfinity
//
//  Created by Joseph Marvin Magdadaro on 7/30/13.
//  Copyright © 2013 Jerk Magz. All rights reserved.
//

#import <UIKit/UIKit.h>

@protocol SettingsViewControllerDelegate;

@interface SettingsViewController : UIViewController
@property (assign, nonatomic) id <SettingsViewControllerDelegate>dismissDelegate;

@end

@protocol SettingsViewControllerDelegate<NSObject>
@optional
- (void)changeProfilePic;
- (void)signOut;
@end

