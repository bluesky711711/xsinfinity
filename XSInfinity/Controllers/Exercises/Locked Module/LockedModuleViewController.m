//
//  LockedModuleViewController.m
//  XSInfinity
//
//  Created by Jerk Nino Magdadaro on 21/09/2018.
//  Copyright © 2018 Jerk Magz. All rights reserved.
//

#import "LockedModuleViewController.h"
#import "PaymentMethodViewController.h"
#import <SDWebImage/UIImageView+WebCache.h>
#import "Helper.h"
#import "Fonts.h"
#import "TranslationsModel.h"
#import "Animations.h"
#import "Colors.h"
#import "CustomNavigation.h"
#import "CustomAlertView.h"
#import "AppDelegate.h"
#import "NetworkManager.h"
#import "ToastView.h"
#import "ModulesServices.h"

@interface LockedModuleViewController ()<NetworkManagerDelegate, ToastViewDelegate>{
    Helper *helper;
    Fonts *fonts;
    Animations *animations;
    TranslationsModel *translationsModel;
    Colors *colors;
    AppDelegate *delegate;
    BOOL didLayoutReloaded;
    
}
@property (weak, nonatomic) IBOutlet UIScrollView *scrollView;
@property (weak, nonatomic) IBOutlet UIView *scrollContentView;
@property (weak, nonatomic) IBOutlet NSLayoutConstraint *scrollContentViewHeightConstraint;

@property (weak, nonatomic) IBOutlet UIView *contentView;
@property (weak, nonatomic) IBOutlet UILabel *moduleNameLbl;
@property (weak, nonatomic) IBOutlet UILabel *descLbl;
@property (weak, nonatomic) IBOutlet UIImageView *imgView;
@property (weak, nonatomic) IBOutlet UILabel *totalLbl;
@property (weak, nonatomic) IBOutlet UITextView *txtView;
@property (weak, nonatomic) IBOutlet UIView *easyColorView;
@property (weak, nonatomic) IBOutlet UILabel *easyLbl;
@property (weak, nonatomic) IBOutlet UIView *mediumColorView;
@property (weak, nonatomic) IBOutlet UILabel *mediumLbl;
@property (weak, nonatomic) IBOutlet UIView *hardColorView;
@property (weak, nonatomic) IBOutlet UILabel *hardLbl;
@property (weak, nonatomic) IBOutlet UILabel *sizeLbl;
@property (weak, nonatomic) IBOutlet UIButton *purchaseBtn;
@property (nonatomic, assign) CGFloat lastContentOffset;

@end

@implementation LockedModuleViewController

-(void)viewWillAppear:(BOOL)animated{
    [super viewWillAppear:YES];
    [[CustomNavigation sharedInstance] addOrRemoveBlurEffectAndLineForNavigationInViewController:self];
    
}

- (void)viewDidLoad {
    [super viewDidLoad];
    self.navigationController.navigationBar.hidden = NO;
    self.navigationItem.title = [[TranslationsModel sharedInstance] getTranslationForKey:@"purch.purchmodule"];
    self.navigationItem.largeTitleDisplayMode = UINavigationItemLargeTitleDisplayModeNever;
    
    NSLog(@"Selected Locked Module = %@", self.module);
    
    helper = [Helper sharedHelper];
    fonts = [Fonts sharedFonts];
    animations = [Animations sharedAnimations];
    colors = [Colors sharedColors];
    translationsModel = [TranslationsModel sharedInstance];
    delegate = (AppDelegate *)[[UIApplication sharedApplication] delegate];
}

- (void)viewDidAppear:(BOOL)animated{
    [super viewDidAppear:YES];
    [[_scrollView viewWithTag:999] removeFromSuperview];
    self.view.backgroundColor = [UIColor clearColor];
    
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

- (void)retryConnection{
    if([[NetworkManager sharedInstance] isConnectionOffline]){
        [[NetworkManager sharedInstance] showConnectionErrorInViewController:delegate.tabBarController];
    }
}

- (void)viewDidLayoutSubviews{
    [super viewDidLayoutSubviews];
    
    [_contentView layoutIfNeeded];
    [helper addDropShadowIn:_contentView withColor:[UIColor darkGrayColor] andSetCornerRadiusTo:5.0];
    
    if( !didLayoutReloaded ){
        [self setupUserInterface];
        
        [self setInfo];
        
        didLayoutReloaded = YES;
    }
}

- (void)setupUserInterface{
    self.view.backgroundColor = [UIColor colorWithPatternImage:[UIImage imageNamed:@"bg"]];
    UIImageView *imgView = [[UIImageView alloc] initWithFrame:CGRectMake(0, 0, CGRectGetWidth(_scrollContentView.frame), CGRectGetHeight(_scrollContentView.frame) + 150)];
    imgView.image = [UIImage imageNamed:@"bg"];
    imgView.tag = 999;
    [_scrollView insertSubview:imgView atIndex:0];
    
    [[Animations sharedAnimations] setTabBar:delegate.tabBarController.tabBar fromViewController:self visible:YES animated:NO];

    [[CustomNavigation sharedInstance] addOrRemoveBlurEffectAndLineForNavigationInViewController:self];
    
    _easyColorView.backgroundColor = [colors easyColor];
    _mediumColorView.backgroundColor = [colors mediumColor];
    _hardColorView.backgroundColor = [colors hardColor];
    
    _moduleNameLbl.font = [fonts headerFont];
    //_descLbl.font = [fonts normalFont];
    _totalLbl.font = [fonts normalFontBold];
    //_txtView.font = [fonts normalFont];
    _easyLbl.font = [fonts normalFont];
    _mediumLbl.font = [fonts normalFont];
    _hardLbl.font = [fonts normalFont];
    _sizeLbl.font = [fonts titleFont];
    _purchaseBtn.titleLabel.font = [fonts normalFontBold];
    //[_descLbl setLineHeight];
    
    [_purchaseBtn setTitle:[translationsModel getTranslationForKey:@"purchmodule.activatenow"] forState:UIControlStateNormal];
    
    _purchaseBtn.backgroundColor = [colors blueColor];
}

- (void)setInfo{
    NSString *moduleName = [translationsModel getTranslationForKey:[NSString stringWithFormat:@"%@%@.name", Cf_domain_model_Module, self.module.identifier]];
    NSString *moduleDesc = [translationsModel getTranslationForKey:[NSString stringWithFormat:@"%@%@.description", Cf_domain_model_Module, self.module.identifier]];
    NSString *howToUse = [translationsModel getTranslationForKey:[NSString stringWithFormat:@"%@%@.howToUseDescription", Cf_domain_model_Module, self.module.identifier]];
    
    _moduleNameLbl.text = moduleName;
    _descLbl.attributedText = [helper formatText:moduleDesc];
    //_txtView.attributedText = [helper formatText:howToUse];
    _totalLbl.text = [[NSString stringWithFormat:@"%@ %d %@",[translationsModel getTranslationForKey:@"purchmodule.totalof"], self.module.numberOfExercises, [translationsModel getTranslationForKey:@"purchmodule.exercises"]] uppercaseString];
    _easyLbl.text = [NSString stringWithFormat:@"%d %@ %@",self.module.totalExerciseEasy, [translationsModel getTranslationForKey:@"purchmodule.exercises"], [translationsModel getTranslationForKey:@"purchmodule.easy"]];
    _mediumLbl.text = [NSString stringWithFormat:@"%d %@ %@",self.module.totalExerciseMedium, [translationsModel getTranslationForKey:@"purchmodule.exercises"], [translationsModel getTranslationForKey:@"purchmodule.medium"]];
    _hardLbl.text = [NSString stringWithFormat:@"%d %@ %@",self.module.totalExerciseHard, [translationsModel getTranslationForKey:@"purchmodule.exercises"], [translationsModel getTranslationForKey:@"purchmodule.hard"]];

    [_imgView sd_setImageWithURL:[NSURL URLWithString:self.module.image] placeholderImage:nil];
    
    //set the proper scroll height
    _scrollContentViewHeightConstraint.constant = (_scrollContentViewHeightConstraint.constant+([helper formatText:moduleDesc].length/2));
}

- (IBAction)purchaseModule:(id)sender{
    
    [[CustomAlertView sharedInstance] showAlertInViewController:delegate.tabBarController
                                                      withTitle:[translationsModel getTranslationForKey:@"purchmodule.activatenow"]
                                                        message:[translationsModel getTranslationForKey:@"purchmodule.popuptext"]
                                              cancelButtonTitle:[[TranslationsModel sharedInstance] getTranslationForKey:@"purchmodule.popupbutton"]
                                                doneButtonTitle:nil];
    [[CustomAlertView sharedInstance] setCancelBlock:^(id result) {
        PaymentMethodViewController *vc = [[PaymentMethodViewController alloc] initWithNibName:@"PaymentMethodViewController" bundle:nil];
        vc.module = self.module;
        [self.navigationController pushViewController:vc animated:YES];
    }];
    [[CustomAlertView sharedInstance] setDoneBlock:^(id result) {
        PaymentMethodViewController *vc = [[PaymentMethodViewController alloc] initWithNibName:@"PaymentMethodViewController" bundle:nil];
        vc.module = self.module;
        [self.navigationController pushViewController:vc animated:YES];
    }];
}

#pragma mark - UIScrollView Delegate
- (void)scrollViewDidScroll:(UIScrollView *)scrollView{
    [self.view layoutIfNeeded];
    
    float scrollOffset = _scrollView.contentOffset.y;
    float maxOffSet = _scrollView.contentSize.height - CGRectGetHeight(_scrollView.frame);
    
    if (scrollOffset > 0 && (scrollOffset >= _lastContentOffset || maxOffSet <= scrollOffset)){//scroll down
        [animations setTabBar:delegate.tabBarController.tabBar fromViewController:self visible:NO animated:YES];
    }
    else{//scroll up
        [animations setTabBar:delegate.tabBarController.tabBar fromViewController:self visible:YES animated:YES];
    }
    _lastContentOffset = scrollOffset;
    
    [[CustomNavigation sharedInstance] addOrRemoveBlurEffectAndLineForNavigationInViewController:self];
    
}

- (IBAction)back:(id)sender {
    [self.navigationController popViewControllerAnimated:YES];
}


@end
