//
//  Animations.m
//  XSInfinity
//
//  Created by Joseph Marvin Magdadaro on 5/25/18.
//  Copyright © 2018 Joseph Marvin Magdadaro. All rights reserved.
//

#import "Animations.h"

@implementation Animations

+ (Animations *)sharedAnimations {
    __strong static Animations *sharedAnimations = nil;
    static dispatch_once_t onceToken;
    dispatch_once(&onceToken, ^{
        sharedAnimations = [[Animations alloc] init];
    });
    return sharedAnimations;
}

- (id)init {
    self = [super init];
    return self;
}

- (BOOL)setStatusBarFromViewControler:(UIViewController *)vc visible:(BOOL)show{
    //no action if Status Bar's current state is not equal to show
    if ([UIApplication sharedApplication].isStatusBarHidden != show) return !show;
    
    [UIView animateWithDuration:UINavigationControllerHideShowBarDuration animations:^{
        [vc setNeedsStatusBarAppearanceUpdate];
    }];
    
    return !show;
}

- (void)setTabBar:(UITabBar *)tabBar fromViewController:(UIViewController *)vc visible:(BOOL)visible animated:(BOOL)animated {
    
    double offsetY = (visible)?CGRectGetMaxY(vc.view.frame)-CGRectGetHeight(tabBar.frame) : CGRectGetMaxY(vc.view.frame)+3;
    
    //no action if tabBar's current Y offset == offsetY
    if (offsetY == CGRectGetMinY(tabBar.frame)) return;
    
    // set duration to 0 if animated == NO
    CGFloat duration = (animated)? 0.3 : 0.0;
    
    [UIView animateWithDuration:duration animations:^{
        tabBar.frame = CGRectMake(0, offsetY, CGRectGetWidth(tabBar.frame), CGRectGetHeight(tabBar.frame));
    } completion:nil];
}

- (void)animateOverlayViewIn:(UIView *)view byTopConstraint:(NSLayoutConstraint *)topConstraint{
    
    topConstraint.constant = -50;
    [UIView animateWithDuration:0.1 animations:^{
        
        [view layoutIfNeeded];
        
    } completion:^(BOOL finished) {
        
        topConstraint.constant = 50;
        [UIView animateWithDuration:0.2 animations:^{
            
            [view layoutIfNeeded];
            
        } completion:^(BOOL finished) {
            topConstraint.constant = 37;
            [UIView animateWithDuration:0.2 animations:^{
                
                [view layoutIfNeeded];
                
            } completion:^(BOOL finished) {
                
                topConstraint.constant = 40;
                [UIView animateWithDuration:0.2 animations:^{
                    
                    [view layoutIfNeeded];
                    
                } completion:nil];
            }];
        }];
        
    }];
    
}

- (void)zoomOutAnimationForView:(UIView *)view{
    view.transform = CGAffineTransformMakeScale(0.94,0.94);
    [UIView animateWithDuration:0.1 animations:^{
        view.transform = CGAffineTransformMakeScale(1.0,1.0);
        
    }completion:nil];
}

- (void)zoomSpringAnimationForView:(UIView *)view{
    view.transform = CGAffineTransformMakeScale(0.8,0.8);
    [UIView animateWithDuration:0.2 animations:^{
        view.transform = CGAffineTransformMakeScale(1.03,1.03);
        
    }completion:^(BOOL finished){
        [UIView animateWithDuration:0.2 animations:^{
            view.transform = CGAffineTransformMakeScale(0.98,0.98);
            
        }completion:^(BOOL finished){
            [UIView animateWithDuration:0.2 animations:^{
                view.transform = CGAffineTransformMakeScale(1.0,1.0);
                
            }completion:^(BOOL finished){
            }];
        }];
    }];
}

- (void)fadeInBottomToTopAnimationOnCell:(UITableViewCell *)cell withDelay:(float)delay{
    
    [cell setAlpha:0.f];
    [UIView animateWithDuration:0.3f
                          delay:delay
                        options:UIViewAnimationOptionCurveEaseIn
                     animations:^{
                         [cell setAlpha:1.0f];
                     } completion:nil];
    
    CGRect frame = cell.frame;
    cell.frame = CGRectMake(CGRectGetMinX(frame), CGRectGetMinY(frame)+20, CGRectGetWidth(frame), CGRectGetHeight(frame));
    [UIView animateWithDuration:0.2f
                          delay:delay
                        options:UIViewAnimationOptionCurveEaseIn
                     animations:^{
                         [cell setFrame:frame];
                     } completion:nil];
    
}

@end
