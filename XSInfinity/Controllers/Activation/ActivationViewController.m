//
//  ActivationViewController.m
//  XSInfinity
//
//  Created by Joseph Marvin Magdadaro on 6/11/18.
//  Copyright © 2018 Joseph Marvin Magdadaro. All rights reserved.
//

#import "ActivationViewController.h"
#import <MessageUI/MessageUI.h>
#import "AppDelegate.h"
#import "DejalActivityView.h"
#import "ModulesServices.h"
#import "CustomAlertView.h"
#import "Helper.h"
#import "Fonts.h"
#import "Colors.h"
#import "TranslationsModel.h"
#import "UserServices.h"
#import "NetworkManager.h"
#import "ToastView.h"
#import "UserModel.h"

@interface ActivationViewController ()<MFMailComposeViewControllerDelegate, NetworkManagerDelegate, ToastViewDelegate>{
    Helper *helper;
    Fonts *fonts;
    Colors *colors;
    TranslationsModel *translationsModel;
    BOOL didLayoutReloaded;
    BOOL isForceActivation;
    UserInfo *user;
    AppDelegate *delegate;
    
    UserServicesApi lastApiCall;
}
@property (weak, nonatomic) IBOutlet UIView *contentView;
@property (weak, nonatomic) IBOutlet UILabel *titleLbl;
@property (weak, nonatomic) IBOutlet UILabel *guideLbl;
@property (weak, nonatomic) IBOutlet UIButton *startBtn;
@property (weak, nonatomic) IBOutlet UIButton *reSendBtn;

@property (weak, nonatomic) IBOutlet UIView *activationView;
@property (weak, nonatomic) IBOutlet UILabel *activationLbl;
@property (weak, nonatomic) IBOutlet UILabel *activatedMsgLbl;

@property (weak, nonatomic) IBOutlet UIButton *contactBtn;

@end

@implementation ActivationViewController

-(void)viewWillAppear:(BOOL)animated{
    [super viewWillAppear:YES];
    self.navigationController.navigationBar.hidden = YES;
    
}

- (void)viewDidLoad {
    [super viewDidLoad];
    self.navigationController.navigationBar.hidden = YES;
    
    delegate = (AppDelegate *)[[UIApplication sharedApplication] delegate];
    helper = [Helper sharedHelper];
    fonts = [Fonts sharedFonts];
    colors = [Colors sharedColors];
    translationsModel = [TranslationsModel sharedInstance];
    
    if (self.isFromDeepLink) {
        [self activateUser];
    }
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

- (void)retryConnection{
    if(!lastApiCall){
        if([[NetworkManager sharedInstance] isConnectionOffline]){
            [[NetworkManager sharedInstance] showConnectionErrorInViewController:self];
        }
        return;
    }
    
    switch (lastApiCall) {
        case UserServicesApi_SendActivation:
            [self sendActivation:nil];
            break;
        case UserServicesApi_ActivateUser:
            [self activateUser];
            break;
            
        default:
            break;
    }
}

- (void)cancelToast{
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
    [_activationView layoutIfNeeded];
    
    [helper addShadowIn:_contentView withColor:[UIColor darkGrayColor] andSetCornerRadiusTo:5.0];
    [helper addShadowIn:_activationView withColor:[UIColor darkGrayColor] andSetCornerRadiusTo:5.0];
    
    _titleLbl.font = [fonts headerFont];
    _activationLbl.font = [fonts headerFont];
    _guideLbl.font = [fonts normalFont];
    _activatedMsgLbl.font = [fonts normalFont];
    _startBtn.titleLabel.font = [fonts normalFontBold];
    _reSendBtn.titleLabel.font = [fonts normalFontBold];
    
    _titleLbl.textColor = [colors darkColor];
    _activationLbl.textColor = [colors darkColor];
    
    [_startBtn setTitleColor:[UIColor whiteColor] forState:UIControlStateNormal];
    [_reSendBtn setTitleColor:[UIColor whiteColor] forState:UIControlStateNormal];
    
    
    //[_contactBtn setTitle:[translationsModel getTranslationForKey:@"activationsuccess.support"] forState:UIControlStateNormal];
    NSMutableParagraphStyle *style = [[NSParagraphStyle defaultParagraphStyle] mutableCopy];
    [style setAlignment:NSTextAlignmentCenter];
    [style setLineBreakMode:NSLineBreakByWordWrapping];
    
    NSDictionary *dict1 = @{NSUnderlineStyleAttributeName:@(NSUnderlineStyleSingle),
                            NSFontAttributeName:[fonts normalFont],
                            NSForegroundColorAttributeName:[UIColor whiteColor],
                            NSParagraphStyleAttributeName:style};
    
    NSMutableAttributedString *resetAttr = [[NSMutableAttributedString alloc] init];
    [resetAttr appendAttributedString:[[NSAttributedString alloc] initWithString:[translationsModel getTranslationForKey:@"activationsuccess.support"] attributes:dict1]];
    [_contactBtn setAttributedTitle:resetAttr forState:UIControlStateNormal];
    
    if(self.isForResendActivation){
        _activationView.hidden = YES;
        _startBtn.hidden = YES;
        
        user = [[UserModel sharedInstance] getUserInfo];
        
        NSString *userStr = user.userName ?user.userName :self.userName;
        
        _titleLbl.text = [[translationsModel getTranslationForKey:@"activationsuccess.tryforfree_title"] uppercaseString];
        _guideLbl.text = [translationsModel getTranslationForKey:@"activationsuccess.text"];
        _guideLbl.text = [_guideLbl.text stringByReplacingOccurrencesOfString:@"{0}," withString:[NSString stringWithFormat:@"%@,\n",userStr]];
        
        if (isForceActivation) {
            _reSendBtn.backgroundColor = [UIColor lightGrayColor];
            _reSendBtn.userInteractionEnabled = NO;
            
            [_reSendBtn setTitle:[translationsModel getTranslationForKey:@"Send again in... 120s /NT"] forState:UIControlStateNormal];
        }else{
            _reSendBtn.backgroundColor = [colors blueColor];
            
            [_reSendBtn setTitle:[translationsModel getTranslationForKey:@"activationsuccess.button"] forState:UIControlStateNormal];
        }
    }else{
        _activationView.hidden = YES;
        _reSendBtn.hidden = YES;
        _contactBtn.hidden = YES;
        
        _startBtn.backgroundColor = [colors blueColor];
        
        _titleLbl.text = [[translationsModel getTranslationForKey:@"global.tryfreetitle"] uppercaseString];
        _guideLbl.text = [translationsModel getTranslationForKey:@"activation.description_text"];
        [_startBtn setTitle:[translationsModel getTranslationForKey:@"activation.resendemail"] forState:UIControlStateNormal];
    }
    
    [_activationLbl setLineHeight];
    [_activatedMsgLbl setLineHeight];
    [_titleLbl setLineHeight];
    [_guideLbl setLineHeight];
}

- (IBAction)startNow:(id)sender {
    [helper saveToKeychainUsername:self.userName andPassword:self.userPassword];
    [helper setUpTabBarControllerFrom:self initialIndex:0];
    
    [[ModulesServices sharedInstance] getFocusAreaWithCompletion:nil];
}

- (IBAction)sendActivation:(id)sender {
    [DejalBezelActivityView activityViewForView:self.view];
    [[UserServices sharedInstance] sendActivationMailToUser:self.userName withCompletion:^(NSError *error, int statusCode) {
        [DejalBezelActivityView removeViewAnimated:YES];
        
        if(statusCode == NoInternetErrorStatusCode || statusCode == SlowInternetErrorStatusCode) {
            [[NetworkManager sharedInstance] showConnectionErrorInViewController:self statusCode:statusCode];
            self->lastApiCall = UserServicesApi_SendActivation;
            return;
        }
        
        if(error){
            //there is error on the api side
            [[NetworkManager sharedInstance] showApiErrorInViewController:self error:error];
        }
        
        self->lastApiCall = 0;
        
    }];
}

- (void)activateUser{
    [DejalBezelActivityView activityViewForView:self.view];
    [[UserServices sharedInstance] activateUser:self.userName withCode:self.code withCompletion:^(NSError *error, int statusCode) {
        [DejalBezelActivityView removeViewAnimated:YES];
        
        if(statusCode == NoInternetErrorStatusCode || statusCode == SlowInternetErrorStatusCode) {
            [[NetworkManager sharedInstance] showConnectionErrorInViewController:self statusCode:statusCode];
            self->lastApiCall = UserServicesApi_ActivateUser;
            return;
        }
        
        self->lastApiCall = 0;
        
        //user activated
        if(statusCode == 200 || statusCode == 201){
            self->_activationView.hidden = NO;
            self->_contentView.hidden = YES;
            self->_startBtn.hidden = YES;
            self->_reSendBtn.hidden = YES;
            self->_contactBtn.hidden = YES;
            
            self->_activationLbl.text = [[self->translationsModel getTranslationForKey:@"activationsuccess.tryforfree_title"] uppercaseString];
            self->_activatedMsgLbl.text = [self->translationsModel getTranslationForKey:@"activationsuccess.description_text"];
            return;
        }
        
        if(error){
            //there is error on the api side
            [[NetworkManager sharedInstance] showApiErrorInViewController:self error:error];
        }
    }];
}

- (IBAction)doneActivation:(id)sender {
    if(delegate.tabBarController.viewControllers.count == 0 || delegate.tabBarController.viewControllers == nil){
        [helper setUpTabBarControllerFrom:self initialIndex:0];
    }else{
        delegate.tabBarController = nil;
        [helper setUpTabBarControllerFrom:self initialIndex:0];
        [self.navigationController popViewControllerAnimated:YES];
    }
}

- (IBAction)contactSupport:(id)sender {
    MFMailComposeViewController *mc = [[MFMailComposeViewController alloc] init];
    
    if ([MFMailComposeViewController canSendMail]) {
        mc.mailComposeDelegate = self;
        [mc setSubject:[translationsModel getTranslationForKey:@"faq.needhelplink"]];
        [mc setToRecipients:@[@"oliver@chinafitter.com"]];
        [mc setMessageBody:@"" isHTML:NO];
        
        mc.navigationBar.barTintColor = [UIColor blackColor];
        mc.navigationBar.tintColor = [UIColor blackColor];
        [[mc navigationBar] setTitleTextAttributes:[NSDictionary dictionaryWithObject:[UIColor blackColor] forKey:NSForegroundColorAttributeName]];
        
        [self.navigationController presentViewController:mc animated:YES completion:NULL];
    }
}

- (void) mailComposeController:(MFMailComposeViewController *)controller didFinishWithResult:(MFMailComposeResult)result error:(NSError *)error
{
    switch (result)
    {
        case MFMailComposeResultCancelled:
            NSLog(@"Mail cancelled");
            break;
        case MFMailComposeResultSaved:
            NSLog(@"Mail saved");
            break;
        case MFMailComposeResultSent:
        {
            NSLog(@"Mail sent");
        }
            break;
        case MFMailComposeResultFailed:
        {
            NSLog(@"Mail sent failure: %@", [error localizedDescription]);
        }
            break;
        default:
            break;
    }
    
    [self dismissViewControllerAnimated:YES completion:NULL];
    
}

@end
