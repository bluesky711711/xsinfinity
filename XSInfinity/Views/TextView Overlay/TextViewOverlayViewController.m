//
//  TextViewOverlayViewController.m
//  XSInfinity
//
//  Created by Joseph Marvin Magdadaro on 7/30/18.
//  Copyright © 2018 Jerk Magz. All rights reserved.
//

#import "TextViewOverlayViewController.h"
#import <WebKit/WebKit.h>
#import "Fonts.h"
#import "Animations.h"
#import "Helper.h"
#import "NetworkManager.h"
#import "ToastView.h"
#import "TranslationsModel.h"
#import "AppDelegate.h"

@interface TextViewOverlayViewController ()<NetworkManagerDelegate, ToastViewDelegate>{
    Animations *animations;
    Fonts *fonts;
    AppDelegate *delegate;
    BOOL didLayoutReloaded;
}

@property (weak, nonatomic) IBOutlet UIView *mainView;
@property (weak, nonatomic) IBOutlet NSLayoutConstraint *contentViewTopConstraint;

@property (weak, nonatomic) IBOutlet UIView *contentView;
@property (weak, nonatomic) IBOutlet UILabel *titleLbl;
@property (weak, nonatomic) IBOutlet UITextView *txtView;

@end

@implementation TextViewOverlayViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    self.navigationController.navigationBar.hidden = YES;
    
    animations = [Animations sharedAnimations];
    fonts = [Fonts sharedFonts];
    delegate = (AppDelegate *)[[UIApplication sharedApplication] delegate];
    
    _titleLbl.text = self.titleStr;
    _titleLbl.font = [fonts headerFontLight];
    
    _txtView.attributedText = [[Helper sharedHelper] formatText:self.desc];
}

- (void)viewDidAppear:(BOOL)animated{
    [super viewDidAppear:YES];
    
    [[ToastView sharedInstance] setDelegate:self];
    [[NetworkManager sharedInstance] setDelegate:self];
    [[NetworkManager sharedInstance] connectivityMonitoring];
}

- (void)viewDidDisappear:(BOOL)animated{
    [super viewDidDisappear:YES];
    [[NetworkManager sharedInstance] stopMonitoring];
}

#pragma mark - NetworkManagerDelegate
-(void) finishedConnectivityMonitoring:(AFNetworkReachabilityStatus)status{
    //0 - Offline
    if((long)status == 0){
        [[NetworkManager sharedInstance] showConnectionErrorInViewController:self];
    }
}

#pragma mark - ToastViewDelegate
-(void)retryConnection{
    if([[NetworkManager sharedInstance] isConnectionOffline]){
        [[NetworkManager sharedInstance] showConnectionErrorInViewController:self];
    }
}

-(void)viewDidLayoutSubviews{
    [super viewDidLayoutSubviews];
    [_mainView layoutIfNeeded];
    
    if( !didLayoutReloaded ){
        [self setupUserInterface];
        
        didLayoutReloaded = YES;
    }
}

- (void)setupUserInterface{
    _contentViewTopConstraint.constant = 645;
    [_mainView layoutIfNeeded];
    [animations animateOverlayViewIn:_mainView byTopConstraint:_contentViewTopConstraint];
}

- (IBAction)close:(id)sender{
    [self dismissViewControllerAnimated:YES completion:nil];
}

@end
