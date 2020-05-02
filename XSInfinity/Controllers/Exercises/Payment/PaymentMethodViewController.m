//
//  PaymentMethodViewController.m
//  XSInfinity
//
//  Created by Joseph Marvin Magdadaro on 17/03/2019.
//  Copyright © 2019 Jerk Magz. All rights reserved.
//

#import "PaymentMethodViewController.h"
#import "TPKeyboardAvoidingScrollView.h"
#import "DejalActivityView.h"
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
#import "WXApi.h"

#define WECHAT @"wechat"
#define ALIPAY @"alipay"

@interface PaymentMethodViewController ()<NetworkManagerDelegate, ToastViewDelegate>{
    Helper *helper;
    Fonts *fonts;
    Animations *animations;
    TranslationsModel *translationsModel;
    Colors *colors;
    AppDelegate *delegate;
    BOOL didLayoutReloaded;
}

@property (weak, nonatomic) IBOutlet TPKeyboardAvoidingScrollView *scrollView;
@property (weak, nonatomic) IBOutlet UIView *scrollViewContent;
@property (weak, nonatomic) IBOutlet UIView *contentView;
@property (weak, nonatomic) IBOutlet UILabel *titleLbl;
@property (weak, nonatomic) IBOutlet UIButton *alipayBtn;
@property (weak, nonatomic) IBOutlet UIButton *weChatBtn;
@property (weak, nonatomic) IBOutlet UILabel *alipayLbl;
@property (weak, nonatomic) IBOutlet UILabel *weChatLbl;
@property (weak, nonatomic) IBOutlet UILabel *instructionLbl;
@property (weak, nonatomic) IBOutlet UIView *voucherView;
@property (weak, nonatomic) IBOutlet UITextField *voucherTF;
@property (weak, nonatomic) IBOutlet UILabel *discountLbl;
@property (weak, nonatomic) IBOutlet UILabel *youpayLbl;
@property (weak, nonatomic) IBOutlet UILabel *priceLbl;
@property (weak, nonatomic) IBOutlet UIButton *purchaseBtn;

@property (strong, nonatomic) NSString *paymentMethod;
@end

@implementation PaymentMethodViewController


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
        didLayoutReloaded = YES;
    }
}

- (void)setupUserInterface{
    self.view.backgroundColor = [UIColor colorWithPatternImage:[UIImage imageNamed:@"bg"]];
    UIImageView *imgView = [[UIImageView alloc] initWithFrame:CGRectMake(0, 0, CGRectGetWidth(_scrollViewContent.frame), CGRectGetHeight(_scrollViewContent.frame) + 150)];
    imgView.image = [UIImage imageNamed:@"bg"];
    imgView.tag = 999;
    [_scrollView insertSubview:imgView atIndex:0];
    
    [[Animations sharedAnimations] setTabBar:delegate.tabBarController.tabBar fromViewController:self visible:YES animated:NO];
    [[CustomNavigation sharedInstance] addOrRemoveBlurEffectAndLineForNavigationInViewController:self];
    
    _purchaseBtn.backgroundColor = [colors greenColor];
    _purchaseBtn.titleLabel.font = [fonts normalFontBold];
    
    _titleLbl.font = [fonts titleFontBold];
    _alipayLbl.font = [fonts normalFont];
    _weChatLbl.font = [fonts normalFont];
    _instructionLbl.font = [fonts normalFont];
    _discountLbl.font = [fonts normalFont];
    _discountLbl.textColor = [colors greenColor];
    _youpayLbl.font = [fonts titleFont];
    _priceLbl.font = [fonts titleFont];
    
    [_purchaseBtn setTitle:[translationsModel getTranslationForKey:@"purchmodule.purchasenow"] forState:UIControlStateNormal];
    _purchaseBtn.backgroundColor = [colors greenColor];
    _purchaseBtn.titleLabel.font = [fonts normalFontBold];
    
    [self setBtn:_alipayBtn selected:false];
    [self setBtn:_weChatBtn selected:false];
    
    _voucherView.layer.borderWidth = 0.5;
    _voucherView.layer.borderColor = [colors lightGray].CGColor;
    _voucherView.layer.cornerRadius = 3.0;
    _voucherView.clipsToBounds = YES;
}

- (void)setBtn:(UIButton *)btn selected:(BOOL)isSelected{
    if (isSelected){
        btn.layer.borderWidth = 0;
        btn.backgroundColor = [colors orangeColor];
        btn.layer.cornerRadius = 5.0;
        btn.clipsToBounds = YES;
    }else{
        btn.layer.borderWidth = 0.5;
        btn.layer.borderColor = [UIColor blackColor].CGColor;
        btn.backgroundColor = [UIColor clearColor];
        btn.layer.cornerRadius = 5.0;
        btn.clipsToBounds = YES;
    }
}

- (IBAction)selectMethod:(id)sender{
    UIButton *btn = (UIButton *) sender;
    if(btn.tag == 1){
        _paymentMethod = WECHAT;
        [self setBtn:_alipayBtn selected:true];
        [self setBtn:_weChatBtn selected:false];
    }else{
        _paymentMethod = ALIPAY;
        [self setBtn:_alipayBtn selected:false];
        [self setBtn:_weChatBtn selected:true];
    }
}

- (IBAction)purchaseModule:(id)sender{
    [self purchase];
}

- (void)purchase{
    NSDictionary *param = @{
                            @"payment_method": @"wechat",
                            @"amount": @(10),
                            @"module_id": self.module.identifier
                            };
    
    [DejalBezelActivityView activityViewForView:self.view];
    [[ModulesServices sharedInstance] initiatePaymentWithParam:param completion:^(NSError *error, NSDictionary *result) {
        [DejalBezelActivityView removeViewAnimated:YES];
        
        NSLog(@"Error = %@", error);
        NSLog(@"Result = %@", result);
        
        if(!error){
            NSDictionary *payJson = result[@"payJson"];
            
            PayReq *req   = [[PayReq alloc] init];
            req.partnerId = payJson[@"partnerid"];
            req.prepayId  = payJson[@"prepay_id"];
            req.nonceStr  = payJson[@"noncestr"];
            req.timeStamp = [payJson[@"timestamp"] intValue];
            req.package   = payJson[@"package"];
            req.sign      = payJson[@"sign"];
            [WXApi sendReq:req];
        }
        
    }];
}

@end
