//
//  CustomAlertView.h
//  Habits
//
//  Created by Joseph Marvin Magdadaro on 2/27/18.
//  Copyright © 2018 Joseph Marvin Magdadaro. All rights reserved.
//

#import <Foundation/Foundation.h>
#import <UIKit/UIKit.h>

@interface CustomAlertView : NSObject

@property (nonatomic, retain) UIScrollView *scrollView;

typedef void(^CancelBlock)(id result);
typedef void(^DoneBlock)(id result);
+ (CustomAlertView *) sharedInstance;

- (void)setCancelBlock:(CancelBlock)aCancelBlock;
- (void)setDoneBlock:(DoneBlock)aDoneBlock;

/*
 * Show simple alert view with cancel and done button
 */
- (void)showAlertInViewController:(UIViewController *)vc
                                        withTitle:(NSString *)title
                                          message:(NSString *)message
                                cancelButtonTitle:(NSString *)cancelTitle
                                  doneButtonTitle:(NSString *)doneTitle;

/*
 * Show timer alert view
 */
- (void)showTimerAlertInViewController:(UIViewController *)vc
                             withTitle:(NSString *)title;

/*
 * Show crop alert view with cancel and done button
 */
- (void)showCropAlertViewInViewController:(UIViewController *)vc
                        withTitle:(NSString *)title
                            image:(UIImage *)image
                cancelButtonTitle:(NSString *)cancelTitle
                  doneButtonTitle:(NSString *)doneTitle;
@end
