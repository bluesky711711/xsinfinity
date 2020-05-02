//
//  CustomNavigation.m
//  XSInfinity
//
//  Created by Joseph Marvin Magdadaro on 6/28/18.
//  Copyright © 2018 Joseph Marvin Magdadaro. All rights reserved.
//

#import "CustomNavigation.h"

@implementation CustomNavigation

+ (CustomNavigation *)sharedInstance {
    __strong static CustomNavigation *sharedInstance = nil;
    static dispatch_once_t onceToken;
    dispatch_once(&onceToken, ^{
        sharedInstance = [[CustomNavigation alloc] init];
    });
    return sharedInstance;
}

- (id)init {
    self = [super init];
    return self;
}

- (void)addOrRemoveBlurEffectAndLineForNavigationInViewController:(UIViewController *)vc{
    
    float navBarHeight = CGRectGetHeight(vc.navigationController.navigationBar.frame);
    if (navBarHeight >= 44 && navBarHeight < 45){//scroll down
        [self addBlurEffectIn:vc];
    }else{//scroll up
        [self removeBlurEffectIn:vc];
    }
    
    if ((IS_IPHONE_5 && (navBarHeight >= 93 && navBarHeight < 94)) || (!IS_IPHONE_5 && (navBarHeight >= 96 && navBarHeight < 97)) || (navBarHeight >= 44 && navBarHeight < 45)) {
        [self addNavBarCustomBottomLineIn:vc];
    }else{
        [self removeNavBarCustomBottomLineIn:vc];
    }
    
}

- (void) addBlurEffectIn:(UIViewController *)vc {
    [self removeBlurEffectIn:vc];
    
    // Add blur view
    CGRect bounds = CGRectMake(0, 0-[UIApplication sharedApplication].statusBarFrame.size.height, [UIScreen mainScreen].bounds.size.width, vc.navigationController.navigationBar.frame.size.height + [UIApplication sharedApplication].statusBarFrame.size.height);
    UIVisualEffectView *visualEffectView = [[UIVisualEffectView alloc] initWithEffect:[UIBlurEffect effectWithStyle:UIBlurEffectStyleLight]];
    visualEffectView.frame = bounds;
    visualEffectView.autoresizingMask = UIViewAutoresizingFlexibleWidth | UIViewAutoresizingFlexibleHeight;
    
    UIView *bgView = [[UIView alloc] initWithFrame:CGRectMake(0, 0, CGRectGetWidth(visualEffectView.frame), 200)];
    bgView.autoresizingMask = UIViewAutoresizingFlexibleWidth | UIViewAutoresizingFlexibleHeight;
    bgView.backgroundColor = RGBUIColorWithAlpha(255, 64, 113, 0.5);
    [visualEffectView.contentView addSubview:bgView];
    
    [vc.navigationController.navigationBar addSubview:visualEffectView];
    vc.navigationController.navigationBar.backgroundColor = [UIColor clearColor];
    [vc.navigationController.navigationBar sendSubviewToBack:visualEffectView];
    
}

- (void)removeBlurEffectIn:(UIViewController *)vc {
    for (UIView *view in vc.navigationController.navigationBar.subviews){
        if ([view isKindOfClass:[UIVisualEffectView class]]){
            [view removeFromSuperview];
        }
    }
    
}

- (void)addNavBarCustomBottomLineIn:(UIViewController *)vc {
    [self removeNavBarCustomBottomLineIn:vc];
    
    float y = CGRectGetHeight(vc.navigationController.navigationBar.frame);
//    if (vc.navigationItem.searchController.searchBar.isHidden) {
        y += CGRectGetHeight(vc.navigationItem.searchController.searchBar.frame);
//    }
    
    UIView *bottomLineView = [[UIView alloc] initWithFrame:CGRectMake(0, y, CGRectGetWidth(vc.navigationController.navigationBar.frame), 0.3)];
    bottomLineView.backgroundColor = [UIColor whiteColor];
    bottomLineView.tag = 99;
    [vc.navigationController.navigationBar addSubview:bottomLineView];
}

- (void)removeNavBarCustomBottomLineIn:(UIViewController *)vc{
    for (UIView *view in vc.navigationController.navigationBar.subviews){
        if (view.tag == 99) {
            [view removeFromSuperview];
        }
    }
}

@end
