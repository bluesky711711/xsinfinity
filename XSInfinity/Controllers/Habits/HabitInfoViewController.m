//
//  HabitInfoViewController.m
//  Habits
//
//  Created by Joseph Marvin Magdadaro on 2/26/18.
//  Copyright © 2018 Joseph Marvin Magdadaro. All rights reserved.
//

#import "HabitInfoViewController.h"
#import <SDWebImage/UIImageView+WebCache.h>
#import "Fonts.h"
#import "Colors.h"
#import "Helper.h"
#import "TranslationsModel.h"
#import "CustomNavigation.h"
#import "AppDelegate.h"
#import "Animations.h"
#import "TextViewOverlayViewController.h"
#import "NetworkManager.h"
#import "ToastView.h"

@interface HabitInfoViewController ()<NetworkManagerDelegate, ToastViewDelegate>{
    Fonts *fonts;
    Colors *colors;
    Helper *helper;
    TranslationsModel *translationsModel;
    AppDelegate *delegate;
    BOOL didLayoutReloaded;
}

@property (strong, nonatomic) IBOutlet UIView *habitView;
@property (weak, nonatomic) IBOutlet UIView *pointsView;
@property (weak, nonatomic) IBOutlet UIView *progressView;
@property (weak, nonatomic) IBOutlet UIView *iconView;
@property (weak, nonatomic) IBOutlet UIImageView *imgView;
@property (weak, nonatomic) IBOutlet UILabel *pointsLbl;
@property (weak, nonatomic) IBOutlet UILabel *pointsValueLbl;
@property (weak, nonatomic) IBOutlet UILabel *progressLbl;
@property (weak, nonatomic) IBOutlet UILabel *habitNameLbl;
@property (weak, nonatomic) IBOutlet UITextView *explanationTxtView;
@property (weak, nonatomic) IBOutlet UIButton *howToDoBtn;

@end

@implementation HabitInfoViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    self.navigationController.navigationBar.hidden = NO;
    self.navigationItem.title = self.habit.name;
    self.navigationItem.largeTitleDisplayMode = UINavigationItemLargeTitleDisplayModeNever;
    
    fonts = [Fonts sharedFonts];
    colors = [Colors sharedColors];
    helper = [Helper sharedHelper];
    translationsModel = [TranslationsModel sharedInstance];
    delegate = (AppDelegate *)[[UIApplication sharedApplication] delegate];
    
    [self setInfo];
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
    if([[NetworkManager sharedInstance] isConnectionOffline]){
        [[NetworkManager sharedInstance] showConnectionErrorInViewController:delegate.tabBarController];
    }
}

-(void)viewDidLayoutSubviews{
    [super viewDidLayoutSubviews];
    
    if( !didLayoutReloaded ){
        [self setupUserInterface];
        
        didLayoutReloaded = YES;
    }
}

- (void)setupUserInterface{
    [[Animations sharedAnimations] setTabBar:delegate.tabBarController.tabBar fromViewController:self visible:YES animated:NO];
    
    [_habitView layoutIfNeeded];
    [_iconView layoutIfNeeded];
    [helper addDropShadowIn:_habitView withColor:[UIColor darkGrayColor] andSetCornerRadiusTo:5.0];
    //[helper addDropShadowIn:_iconView withColor:[UIColor darkGrayColor] andSetCornerRadiusTo:5.0];
    
    _pointsView.backgroundColor = [colors purpleColor];
    _progressView.backgroundColor = [colors greenColor];
    
    _pointsLbl.font = [fonts normalFont];
    _pointsValueLbl.font = [fonts bigFontBold];
    _progressLbl.font = [fonts normalFont];
    _habitNameLbl.font = [fonts headerFont];
    //_explanationTxtView.font = [fonts normalFont];
    _explanationTxtView.textContainer.lineFragmentPadding = 0;
    _explanationTxtView.textContainerInset = UIEdgeInsetsZero;
    [_explanationTxtView setContentOffset:CGPointZero animated:NO];
    
    _pointsLbl.text = [translationsModel getTranslationForKey:@"global.points"];
    _progressLbl.text = [translationsModel getTranslationForKey:@"hadetail.inprogress"];
    
    NSMutableParagraphStyle *style = [[NSParagraphStyle defaultParagraphStyle] mutableCopy];
    [style setAlignment:NSTextAlignmentCenter];
    [style setLineBreakMode:NSLineBreakByWordWrapping];
    
    NSDictionary *dict1 = @{NSUnderlineStyleAttributeName:@(NSUnderlineStyleSingle),
                            NSFontAttributeName:[fonts normalFont],
                            NSParagraphStyleAttributeName:style};
    
    NSMutableAttributedString *howToDoString = [[NSMutableAttributedString alloc] init];
    [howToDoString appendAttributedString:[[NSAttributedString alloc] initWithString:[translationsModel getTranslationForKey:@"hadetail.linktext"] attributes:dict1]];
    [_howToDoBtn setAttributedTitle:howToDoString forState:UIControlStateNormal];
    
    [[CustomNavigation sharedInstance] removeBlurEffectIn:self];
    [[CustomNavigation sharedInstance] addNavBarCustomBottomLineIn:self];
    
}

- (void)setInfo{
    NSString *habitName = [translationsModel getTranslationForKey:[NSString stringWithFormat:@"%@%@.name", Cf_domain_model_Habit, self.habit.identifier]];
    NSString *habitExcerpt = [translationsModel getTranslationForKey:[NSString stringWithFormat:@"%@%@.excerpt", Cf_domain_model_Habit, self.habit.identifier]];
    
    _pointsValueLbl.text = @(self.habit.points).stringValue;
    _habitNameLbl.text = habitName;
    _explanationTxtView.attributedText = [[Helper sharedHelper] formatText:habitExcerpt];
    
    [_imgView sd_setImageWithURL:[NSURL URLWithString:self.habit.img] placeholderImage:nil];
}

- (IBAction)howToDo:(id)sender{
    TextViewOverlayViewController *vc = [[TextViewOverlayViewController alloc] initWithNibName:@"TextViewOverlayViewController" bundle:nil];
    
    NSString *habitDesc = [translationsModel getTranslationForKey:[NSString stringWithFormat:@"%@%@.description", Cf_domain_model_Habit, self.habit.identifier]];
    NSString *habitExcerpt = [translationsModel getTranslationForKey:[NSString stringWithFormat:@"%@%@.excerpt", Cf_domain_model_Habit, self.habit.identifier]];
    
    vc.titleStr = habitDesc;
    vc.desc = habitExcerpt;
    
    vc.view.backgroundColor = [UIColor clearColor];
    vc.modalPresentationStyle = UIModalPresentationOverCurrentContext;
    
    [delegate.tabBarController presentViewController:vc animated: NO completion:nil];
}

- (IBAction)back:(id)sender{
    [self.navigationController popViewControllerAnimated:NO];
}

@end
