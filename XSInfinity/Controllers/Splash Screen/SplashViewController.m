//
//  SplashViewController.m
//  XSInfinity
//
//  Created by Joseph Marvin Magdadaro on 7/4/18.
//  Copyright © 2018 Jerk Magz. All rights reserved.
//

#import "SplashViewController.h"
#import <OneSignal/OneSignal.h>
#import "AppDelegate.h"
#import "NetworkManager.h"
#import "TranslationsServices.h"
#import "SignInViewController.h"
#import "OnBoardingViewController.h"
#import "ModulesServices.h"
#import "Helper.h"
#import "TranslationsModel.h"
#import "UserServices.h"
#import "ActivationViewController.h"
#import "HeadsUpViewController.h"
#import "CustomAlertView.h"

@interface SplashViewController () <NetworkManagerDelegate>{
    NSDictionary *userAccountOverview;
    BOOL userBlocked, userActivated;
    AppDelegate *delegate;
}

@end

@implementation SplashViewController

-(void)viewWillAppear:(BOOL)animated{
    [super viewWillAppear:YES];
    self.navigationController.navigationBar.hidden = YES;
    
    if (!self.isFromAppDelegate) {
        SignInViewController *vc = [[SignInViewController alloc] initWithNibName:@"SignInViewController" bundle:nil];
        [self.navigationController pushViewController:vc animated:NO];
    }else{
        self.isFromAppDelegate = NO;
    }
}

- (void)viewDidLoad {
    [super viewDidLoad];
    self.navigationController.navigationBar.hidden = YES;
    
    delegate = (AppDelegate *)[[UIApplication sharedApplication] delegate];
    
    //for testing
    NSArray *paths = NSSearchPathForDirectoriesInDomains(NSDocumentDirectory, NSUserDomainMask, YES);
    NSString *docDir = [paths objectAtIndex:0];
    NSLog(@"PATH = %@", docDir);
    //end
    
    [NetworkManager sharedInstance].delegate = self;
    [[NetworkManager sharedInstance] connectivityMonitoring];
    
    //get the translations from the payload
    [self getLocalTranslations];
    if ([self.navigationController respondsToSelector:@selector(interactivePopGestureRecognizer)]) {
        self.navigationController.interactivePopGestureRecognizer.enabled = NO;
    }
    
    /*for (NSString *name in [UIFont familyNames]) {
        //NSLog(@"Font Name = %@", name);
        NSLog(@"Font Name = %@", [UIFont fontNamesForFamilyName:name]);
    }*/
}

#pragma mark - NetworkManager Delegate
- (void)finishedConnectivityMonitoring:(AFNetworkReachabilityStatus)status{
    NSLog(@"Network Connection Status = %ld", (long)status);
    [[NetworkManager sharedInstance] stopMonitoring];
    
    //get account info
    [self checkUserAccountStatus];
    
    //get translations and bookmarked exercises from remote
    [self getRemoteTranslations];
    
    [self getRemoteBookedExcercises];
    [self getRemoteFocusArea];
    [self getRemoteTags];
}

- (void)checkUserAccountStatus{
    NSString *username = [[Helper sharedHelper] getSavedUsername];
    if(username.length == 0 || username == nil){
        return;
    }

    [[UserServices sharedInstance] getUserInfoWithCompletion:nil];
}

- (void)getRemoteBookedExcercises{
    [[ModulesServices sharedInstance] getBookmarkedExercisesWithCompletion:nil];
}

- (void)getRemoteFocusArea{
    [[ModulesServices sharedInstance] getFocusAreaWithCompletion:nil];
}

- (void)getRemoteTags{
    [[ModulesServices sharedInstance] getTagsWithCompletion:nil];
}

- (void)getLocalTranslations{
    NSBundle *thisBundle = [NSBundle bundleForClass:[self class]];
    NSString *path = [thisBundle pathForResource:@"Translations" ofType:@"txt"];
    if (path) {
        NSError *error;
        NSData *data = [[NSData alloc] initWithContentsOfFile:path];
        NSArray *translations = [NSJSONSerialization JSONObjectWithData:data
                                                             options:kNilOptions
                                                               error:&error];
        
        if([[TranslationsModel sharedInstance] getLatestTranslation] == nil)
            [[TranslationsModel sharedInstance] saveTranslations:translations];
    }
}

- (void)getRemoteTranslations{
    [[TranslationsServices sharedInstance] getTranslationsWithCompletion:^(NSError *error, BOOL successful) {
        NSLog(@"Done");
        
        //After successfully fetch new translations, get user overview and check if user is not activated or blocked
        
        NSString *username = [[Helper sharedHelper] getSavedUsername];
        if ([username length] > 0) {
            
            [[UserServices sharedInstance] getUserOverviewWithCompletion:^(NSError *error, NSDictionary *overview) {
                [OneSignal sendTag:@"user_id" value:USER_ID];
                //[[Helper sharedHelper] setUpTabBarControllerFrom:self initialIndex:0];
                
                self->userAccountOverview = overview;
                self->userBlocked = [overview[@"blocked"] boolValue];
                self->userActivated = [overview[@"activated"] boolValue];
                
                //user is not activated after 24hours registration
                if(self->userAccountOverview && self->userBlocked && !self->userActivated){
                    ActivationViewController *vc = [[ActivationViewController alloc] initWithNibName:@"ActivationViewController" bundle:nil];
                    vc.userName = username;
                    vc.isForResendActivation = true;
                    //[self->delegate.tabBarController presentViewController:vc animated:NO completion:nil];
                    [self.navigationController pushViewController:vc animated:NO];
                    return;
                }
                
                //user is blocked by admin
                else if(self->userAccountOverview && self->userBlocked && self->userActivated){
                    //show custom alert and then logout
                    CustomAlertView *alert = [CustomAlertView sharedInstance];
                    [alert showAlertInViewController:self.navigationController
                                           withTitle:[[TranslationsModel sharedInstance] getTranslationForKey:@"info.error"]
                                             message:[[TranslationsModel sharedInstance] getTranslationForKey:@"account.blocked"]
                                   cancelButtonTitle:[[TranslationsModel sharedInstance] getTranslationForKey:@"global.rateokay"]
                                     doneButtonTitle:nil];
                    [alert setCancelBlock:^(id result) {
                        NSLog(@"Error");
                    }];
                    
                    //force logout
                    [[Helper sharedHelper] removeSavedUser];
                    [[Helper sharedHelper] emptySavedData];
                    
                    [self showSignIn];
                    
                    return;
                }
                
                [[Helper sharedHelper] setUpTabBarControllerFrom:self initialIndex:0];
                
                //show headsup when app is open
                [self showHeadsUp];
            }];
            
        }else{
            
            //show onBoarding only if fresh install and not ever logged in and created new account
            if(!IS_FINISH_ONBOARDING){
                OnBoardingViewController *vc = [[OnBoardingViewController alloc] initWithNibName:@"OnBoardingViewController" bundle:nil];
                [self.navigationController pushViewController:vc animated:YES];
                return;
            }
            
            [self showSignIn];
        }
    }];
}

- (void)showSignIn{
    SignInViewController *vc = [[SignInViewController alloc] initWithNibName:@"SignInViewController" bundle:nil];
    [self.navigationController pushViewController:vc animated:NO];
}

//show heads up in first open
- (void)showHeadsUp{
    Helper *helper = [Helper sharedHelper];
    NSString *username = [helper getSavedUsername];
    
    dispatch_time_t delay = dispatch_time(DISPATCH_TIME_NOW, NSEC_PER_SEC * 1.5);
    dispatch_after(delay, dispatch_get_main_queue(), ^(void){
        //NSLog(@"show heads up");
        if (username.length > 0 && ![helper isHeadsUpHidden] && ![[NetworkManager sharedInstance] isConnectionOffline]) {
            HeadsUpViewController *vc = [[HeadsUpViewController alloc] initWithNibName:@"HeadsUpViewController" bundle:nil];
            vc.view.backgroundColor = [UIColor clearColor];
            vc.modalPresentationStyle = UIModalPresentationOverCurrentContext;
            
            [self->delegate.tabBarController presentViewController:vc animated:NO completion:nil];
        }
    });
}
@end
