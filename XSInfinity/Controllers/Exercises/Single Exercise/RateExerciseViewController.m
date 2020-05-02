//
//  RateExerciseViewController.m
//  XSInfinity
//
//  Created by Joseph Marvin Magdadaro on 6/17/18.
//  Copyright © 2018 Joseph Marvin Magdadaro. All rights reserved.
//

#import "RateExerciseViewController.h"
#import <Social/Social.h>
#import "WXApi.h"
#import "Helper.h"
#import "Fonts.h"
#import "Colors.h"
#import "TranslationsModel.h"
#import "AppDelegate.h"
#import "ModulesServices.h"
#import "CustomAlertView.h"
#import "DejalActivityView.h"
#import "ExercisesMainViewController.h"
#import "ExercisesListViewController.h"
#import "NetworkManager.h"
#import "ToastView.h"
#import "AppReviewHelper.h"

@interface RateExerciseViewController ()<NetworkManagerDelegate, ToastViewDelegate>{
    Helper *helper;
    Fonts *fonts;
    Colors *colors;
    TranslationsModel *translationsModel;
    AppDelegate *delegate;
    BOOL didLayoutReloaded;
    int rating;
    
    ModuleServiceApi lastApiCall;
}
@property (weak, nonatomic) IBOutlet UIView *contentView;
@property (weak, nonatomic) IBOutlet UILabel *titleLbl;
@property (weak, nonatomic) IBOutlet UILabel *easyLbl;
@property (weak, nonatomic) IBOutlet UILabel *okayLbl;
@property (weak, nonatomic) IBOutlet UILabel *challengingLbl;
@property (weak, nonatomic) IBOutlet UILabel *hardLbl;
@property (weak, nonatomic) IBOutlet UIButton *easyBtn;
@property (weak, nonatomic) IBOutlet UIButton *okayBtn;
@property (weak, nonatomic) IBOutlet UIButton *challengingBtn;
@property (weak, nonatomic) IBOutlet UIButton *hardBtn;

@property (weak, nonatomic) IBOutlet UILabel *shareLbl;
@property (weak, nonatomic) IBOutlet UIButton *wechatBtn;
@property (weak, nonatomic) IBOutlet UIButton *fbBtn;
@property (weak, nonatomic) IBOutlet UIButton *twitterBtn;
@property (weak, nonatomic) IBOutlet UIButton *finishBtn;

@property (strong, nonatomic) IBOutletCollection(UIButton) NSArray *rateButtons;

@end

@implementation RateExerciseViewController

- (void)viewWillAppear:(BOOL)animated{
    [super viewWillAppear:YES];
    delegate.tabBarController.tabBar.hidden = YES;
}

- (void)viewDidLoad {
    [super viewDidLoad];
    self.navigationController.navigationBar.hidden = NO;
    self.navigationItem.title = self.exerciseName;
    
    [self.navigationItem setHidesBackButton:TRUE];
    
    helper = [Helper sharedHelper];
    fonts = [Fonts sharedFonts];
    colors = [Colors sharedColors];
    translationsModel = [TranslationsModel sharedInstance];
    delegate = (AppDelegate *)[[UIApplication sharedApplication] delegate];
}

- (void)viewDidAppear:(BOOL)animated{
    [super viewDidAppear:YES];
    
    [[ToastView sharedInstance] setDelegate:self];
    [[NetworkManager sharedInstance] setDelegate:self];
    [[NetworkManager sharedInstance] connectivityMonitoring];
}

- (void)viewWillDisappear:(BOOL)animated{
    [super viewWillDisappear:YES];
    delegate.tabBarController.tabBar.hidden = NO;
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
        return;
    }
    
    switch (lastApiCall) {
        case ModuleServiceApi_AddRating:
            [self finishExercise:nil];
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
    [_contentView layoutIfNeeded];
    [helper addDropShadowIn:_contentView withColor:[UIColor darkGrayColor] andSetCornerRadiusTo:5.0];
    
    _titleLbl.font = [fonts normalFont];
    _easyLbl.font = [fonts titleFont];
    _okayLbl.font = [fonts titleFont];
    _challengingLbl.font = [fonts titleFont];
    _hardLbl.font = [fonts titleFont];
    _shareLbl.font = [fonts headerFontLight];
    _finishBtn.titleLabel.font = [fonts normalFontBold];
    
    _titleLbl.text = [translationsModel getTranslationForKey:@"ratesmiley.title"];
    _easyLbl.text = [translationsModel getTranslationForKey:@"global.ratetooeasy"];
    _okayLbl.text = [translationsModel getTranslationForKey:@"global.rateokay"];
    _challengingLbl.text = [translationsModel getTranslationForKey:@"global.ratechallenging"];
    _hardLbl.text = [translationsModel getTranslationForKey:@"global.ratetoohard"];
    _shareLbl.text = [translationsModel getTranslationForKey:@"global.shareon"];
    [_finishBtn setTitle:[translationsModel getTranslationForKey:@"ratesmiley.button"] forState:UIControlStateNormal];
    
    _finishBtn.backgroundColor = [colors blueColor];
    
}

- (IBAction)chooseRate:(id)sender{
    UIButton *selectedBtn = (UIButton *)sender;
    rating = (int)selectedBtn.tag;
    
    for(UIButton *btn in _rateButtons){
        if (btn.tag == selectedBtn.tag) {
            [btn.layer setShadowOffset:CGSizeMake(0, 0)];
            [btn.layer setShadowColor:[[UIColor redColor] CGColor]];
            [btn.layer setShadowOpacity:0.5];
        }else{
            [btn.layer setShadowOpacity:0];
        }
    }
}

- (IBAction)finishExercise:(id)sender{
    if (rating > 0) {
        [DejalBezelActivityView activityViewForView:delegate.tabBarController.view];
        [[ModulesServices sharedInstance] addRating:rating forExercise:self.exerciseId withCompletion:^(NSError *error, int statusCode) {
            [DejalBezelActivityView removeViewAnimated:YES];
            
            if(statusCode == NoInternetErrorStatusCode || statusCode == SlowInternetErrorStatusCode) {
                [[NetworkManager sharedInstance] showConnectionErrorInViewController:self->delegate.tabBarController statusCode:statusCode];
                self->lastApiCall = ModuleServiceApi_AddRating;
                return;
            }
            
            //successull
            if(statusCode == 201){
                self->lastApiCall = 0;
                
                NSString *title = [self->translationsModel getTranslationForKey:@"popup.successtitle"];
                NSString *msg = [self->translationsModel getTranslationForKey:@"info.ratingsuccess"];
                
                CustomAlertView *alert = [CustomAlertView sharedInstance];
                [alert showAlertInViewController:self->delegate.tabBarController
                                       withTitle:title
                                         message:msg
                               cancelButtonTitle:[[TranslationsModel sharedInstance] getTranslationForKey:@"global.rateokay"]
                                 doneButtonTitle:nil];
                [alert setCancelBlock:^(id result) {
                    for (UIViewController *controller in self.navigationController.viewControllers){
                        if ([controller isKindOfClass:[ExercisesMainViewController class]] || [controller isKindOfClass:[ExercisesListViewController class]]){
                            [self.navigationController popToViewController:controller animated:YES];
                            
                            if(self->rating == 1 || self->rating == 2){
                                [[AppReviewHelper sharedHelper] checkAndFireAppRating];
                                [[NSNotificationCenter defaultCenter] postNotificationName:@"RatedAnExercise" object:self];
                            }
                            break;
                        }
                    }
                }];
                return;
            }
            
            if(error){
                //there is error on the api side
                [[NetworkManager sharedInstance] showApiErrorInViewController:self->delegate.tabBarController error:error];
                self->lastApiCall = ModuleServiceApi_AddRating;
            }
        }];
        
    }else {
        CustomAlertView *alert = [CustomAlertView sharedInstance];
        [alert showAlertInViewController:delegate.tabBarController
                               withTitle:[self->translationsModel getTranslationForKey:@"info.error"]
                                 message:[self->translationsModel getTranslationForKey:@"info.selectrating"]
                       cancelButtonTitle:[[TranslationsModel sharedInstance] getTranslationForKey:@"global.rateokay"]
                         doneButtonTitle:nil];
        [alert setCancelBlock:^(id result) {
            NSLog(@"Error");
        }];
        
    }
}

- (IBAction)shareWeChat:(id)sender{
    SendMessageToWXReq *req = [[SendMessageToWXReq alloc] init];
    req.text = @"The quick brown fox jumped over the lazy dogs.";
    req.bText = YES;
    req.scene = WXSceneTimeline;
    
    [WXApi sendReq:req];
}

- (IBAction)shareFB:(id)sender{
    BOOL isInstalled = [[UIApplication sharedApplication] canOpenURL:[NSURL URLWithString:@"fb://"]];
    
    if (isInstalled) {
        SLComposeViewController *mySLComposerSheet = [SLComposeViewController composeViewControllerForServiceType:SLServiceTypeFacebook];
        
        [mySLComposerSheet setInitialText:@"Post from my app"];
        [mySLComposerSheet addURL:[NSURL URLWithString:@"http://www.google.com"]];
        
        [mySLComposerSheet setCompletionHandler:^(SLComposeViewControllerResult result) {
            
            switch (result) {
                case SLComposeViewControllerResultCancelled:
                    NSLog(@"Post Canceled");
                    break;
                case SLComposeViewControllerResultDone:
                    NSLog(@"Post Sucessful");
                    break;
                    
                default:
                    break;
            }
        }];
        
        [self presentViewController:mySLComposerSheet animated:YES completion:nil];
    } else {
        NSLog(@"The twitter service is not available");
        
        [[CustomAlertView sharedInstance] showAlertInViewController:delegate.tabBarController
                                                          withTitle:[self->translationsModel getTranslationForKey:@"info.share"]
                                                            message:[self->translationsModel getTranslationForKey:@"info.facebooknotavail"]
                                                  cancelButtonTitle:[[TranslationsModel sharedInstance] getTranslationForKey:@"global.rateokay"]
                                                    doneButtonTitle:nil];
        [[CustomAlertView sharedInstance] setCancelBlock:^(id result) {
            NSLog(@"Okay");
        }];
    }
}

- (IBAction)shareTwitter:(id)sender{
    
    BOOL isInstalled = [[UIApplication sharedApplication] canOpenURL:[NSURL URLWithString:@"twitter://"]];
    
    if (isInstalled) {
        SLComposeViewController *mySLComposerSheet = [SLComposeViewController composeViewControllerForServiceType:SLServiceTypeTwitter];
        
        [mySLComposerSheet setInitialText:@"Tweet from my app"];
        [mySLComposerSheet addURL:[NSURL URLWithString:@"http://www.google.com"]];
        
        [mySLComposerSheet setCompletionHandler:^(SLComposeViewControllerResult result) {
            
            switch (result) {
                case SLComposeViewControllerResultCancelled:
                    NSLog(@"Post Canceled");
                    break;
                case SLComposeViewControllerResultDone:
                    NSLog(@"Post Sucessful");
                    break;
                    
                default:
                    break;
            }
        }];
        
        [self presentViewController:mySLComposerSheet animated:YES completion:nil];
    } else {
        NSLog(@"The twitter service is not available");
        
        [[CustomAlertView sharedInstance] showAlertInViewController:delegate.tabBarController
                                                          withTitle:[self->translationsModel getTranslationForKey:@"info.share"]
                                                            message:[self->translationsModel getTranslationForKey:@"info.twitternotavail"]
                                                  cancelButtonTitle:[[TranslationsModel sharedInstance] getTranslationForKey:@"global.rateokay"]
                                                    doneButtonTitle:nil];
        [[CustomAlertView sharedInstance] setCancelBlock:^(id result) {
            NSLog(@"Okay");
        }];
    }
}

@end
