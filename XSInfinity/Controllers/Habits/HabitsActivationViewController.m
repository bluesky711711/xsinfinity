//
//  HabitsActivationViewController.m
//  XSInfinity
//
//  Created by Joseph Marvin Magdadaro on 6/22/18.
//  Copyright © 2018 Joseph Marvin Magdadaro. All rights reserved.
//

#import "HabitsActivationViewController.h"
#import "AppDelegate.h"
#import "Fonts.h"
#import "Colors.h"
#import "Helper.h"
#import "TranslationsModel.h"
#import "HabitsViewController.h"
#import "CustomNavigation.h"
#import "HabitsServices.h"
#import "HabitsModel.h"
#import "DejalActivityView.h"
#import "CustomAlertView.h"
#import "NetworkManager.h"
#import "ToastView.h"

@interface HabitsActivationViewController ()<NetworkManagerDelegate, ToastViewDelegate>{
    AppDelegate *delegate;
    Fonts *fonts;
    Colors *colors;
    Helper *helper;
    TranslationsModel *translationsModel;
    BOOL didLayoutReloaded;
    HabitsServicesApi lastApiCall;
}
@property (weak, nonatomic) IBOutlet UIView *contentView;
@property (weak, nonatomic) IBOutlet UIView *headerView;
@property (weak, nonatomic) IBOutlet UILabel *headerLbl;
@property (weak, nonatomic) IBOutlet UILabel *titleLbl;
@property (weak, nonatomic) IBOutlet UITextView *explanationTxtView;
@property (weak, nonatomic) IBOutlet UIButton *activateBtn;
@property (weak, nonatomic) IBOutlet UIImageView *unlockImgView;

@end

@implementation HabitsActivationViewController

- (void)viewWillAppear:(BOOL)animated{
    [super viewWillAppear:YES];

    if (IS_HABITS_ACTIVATED) {
        HabitsViewController *vc = [[HabitsViewController alloc] initWithNibName:@"HabitsViewController" bundle:nil];
        [self.navigationController pushViewController:vc animated:NO];
    }/*else{
        [self checkActivation];
    }*/
    
    [self setTranslationsAndFonts];
}

- (void)viewDidLoad {
    [super viewDidLoad];
    self.navigationController.navigationBar.hidden = NO;
    [self.navigationController.navigationBar setBackgroundImage:[UIImage new]
                                              forBarMetrics:UIBarMetricsDefault];
    self.navigationController.navigationBar.shadowImage = [UIImage new];
    self.navigationController.navigationBar.prefersLargeTitles = TRUE;
    self.navigationItem.largeTitleDisplayMode = UINavigationItemLargeTitleDisplayModeAutomatic;
    self.navigationItem.title = [[TranslationsModel sharedInstance] getTranslationForKey:@"perf.habit"];
    
    fonts = [Fonts sharedFonts];
    colors = [Colors sharedColors];
    helper = [Helper sharedHelper];
    translationsModel = [TranslationsModel sharedInstance];
    delegate = (AppDelegate *)[[UIApplication sharedApplication] delegate];
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
        [[NetworkManager sharedInstance] showConnectionErrorInViewController:delegate.tabBarController];
    }
}

#pragma mark - ToastViewDelegate
-(void)retryConnection{
    if(!lastApiCall){
        if([[NetworkManager sharedInstance] isConnectionOffline]){
            [[NetworkManager sharedInstance] showConnectionErrorInViewController:delegate.tabBarController];
        }
        [self checkActivation];
        return;
    }
    
    switch (lastApiCall) {
        case HabitsServicesApi_StartHabit:
            [self activate:nil];
            break;
            
        default:
            break;
    }
}

-(void)cancelToast{
    lastApiCall = 0;
}

-(void)viewDidLayoutSubviews{
    [super viewDidLayoutSubviews];
    
    if( !didLayoutReloaded ){
        [self setupUserInterface];
        
        didLayoutReloaded = YES;
    }
}

- (void)setupUserInterface{
    [helper setFlexibleBorderIn:_headerView withColor:[UIColor whiteColor] topBorderWidth:0.0 leftBorderWidth:0.0 rightBorderWidth:0.0 bottomBorderWidth:0.5];
    
    [_contentView layoutIfNeeded];
    [helper addDropShadowIn:_contentView withColor:[UIColor darkGrayColor] andSetCornerRadiusTo:5.0];
    
    _activateBtn.backgroundColor = [colors blueColor];
    
    UIImage *unlockImg = [[UIImage imageNamed:@"unlocked"] imageWithRenderingMode:UIImageRenderingModeAlwaysTemplate];
    _unlockImgView.image = unlockImg;
    _unlockImgView.tintColor = [UIColor blackColor];
    
    [self setTranslationsAndFonts];
    
    [[CustomNavigation sharedInstance] addOrRemoveBlurEffectAndLineForNavigationInViewController:self];
    
}

- (void)setTranslationsAndFonts{
    _headerLbl.font = [fonts headerFont];
    _titleLbl.font = [fonts headerFont];
    _explanationTxtView.font = [fonts normalFont];
    _activateBtn.titleLabel.font = [fonts normalFontBold];
    
    self.navigationItem.title = [[TranslationsModel sharedInstance] getTranslationForKey:@"perf.habit"];
    
    _headerLbl.text = [translationsModel getTranslationForKey:@"habactive.title"];
    _titleLbl.text = [translationsModel getTranslationForKey:@"habactive.headline"];
    _explanationTxtView.text = [translationsModel getTranslationForKey:@"habactive.description"];
    [_activateBtn setTitle:[translationsModel getTranslationForKey:@"habactive.button"] forState:UIControlStateNormal];
}

- (void)checkActivation{
    [DejalBezelActivityView activityViewForView:delegate.tabBarController.view];

    [[HabitsServices sharedInstance] getUnlockedHabitsWithCompletion:^(NSError *error, int statusCode, NSArray *habits) {
        [DejalBezelActivityView removeViewAnimated:YES];
        
        if(statusCode == NoInternetErrorStatusCode || statusCode == SlowInternetErrorStatusCode) {
            [[NetworkManager sharedInstance] showConnectionErrorInViewController:self->delegate.tabBarController statusCode:statusCode];
            return;
        }
        
        if (habits && habits.count > 0) {
            HABITS_ACTIVATED(TRUE)
            
            //reload tab bar and set habit as default
            [[Helper sharedHelper] setUpTabBarControllerFrom:self initialIndex:1];
            
            HabitsViewController *vc = [[HabitsViewController alloc] initWithNibName:@"HabitsViewController" bundle:nil];
            [self.navigationController pushViewController:vc animated:YES];
        }
    }];
}

- (IBAction)activate:(id)sender{
    [DejalBezelActivityView activityViewForView:delegate.tabBarController.view];
    [[HabitsServices sharedInstance] startHabitsWithCompletion:^(NSError *error, int statusCode) {
        [DejalBezelActivityView removeViewAnimated:YES];
        
        if(statusCode == NoInternetErrorStatusCode || statusCode == SlowInternetErrorStatusCode) {
            [[NetworkManager sharedInstance] showConnectionErrorInViewController:self->delegate.tabBarController statusCode:statusCode];
            self->lastApiCall = HabitsServicesApi_StartHabit;
            return;
        }
        
        self->lastApiCall = 0;
        
        if (statusCode == 201 || statusCode == 409) {
            HABITS_ACTIVATED(TRUE)
            
            //reload tab bar and set habit as default
            [[Helper sharedHelper] setUpTabBarControllerFrom:self initialIndex:1];
            
            HabitsViewController *vc = [[HabitsViewController alloc] initWithNibName:@"HabitsViewController" bundle:nil];
            [self.navigationController pushViewController:vc animated:YES];
            return;
        }
        
        if(error){
            //there is error on the api side
            [[NetworkManager sharedInstance] showApiErrorInViewController:self->delegate.tabBarController error:error];
            self->lastApiCall = HabitsServicesApi_StartHabit;
        }
    }];
}


@end
