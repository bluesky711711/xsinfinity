//
//  SettingsViewController.m
//  XSInfinity
//
//  Created by Joseph Marvin Magdadaro on 7/30/13.
//  Copyright © 2013 Jerk Magz. All rights reserved.
//

#import "SettingsViewController.h"
#import <SDWebImage/UIImageView+WebCache.h>
#import "NetworkManager.h"
#import "TextFieldValidator.h"
#import "DejalActivityView.h"
#import "AppDelegate.h"
#import "Helper.h"
#import "Animations.h"
#import "Colors.h"
#import "Fonts.h"
#import "TranslationsModel.h"
#import "CustomAlertView.h"
#import "CustomCropper.h"
#import "TextViewOverlayViewController.h"
#import "UserMediaServices.h"
#import "UserServices.h"
#import "HabitsServices.h"
#import "SignInViewController.h"
#import "PurchaseHistoryViewController.h"
#import "FaqViewController.h"
#import "SkeletonView.h"
#import "UserModel.h"
#import "UserInfo.h"
#import "ToastView.h"

@interface SettingsViewController ()<NetworkManagerDelegate, ToastViewDelegate>{
    AppDelegate *delegate;
    Helper *helper;
    Animations *animations;
    Colors *colors;
    Fonts *fonts;
    TranslationsModel *translationsModel;
    SkeletonView *skeletonView;
    BOOL didLayoutReloaded;
    BOOL isMotivationReminderEnabled;
    BOOL isHabitsReminderEnabled;
    BOOL isPersonalGoalReminderEnabled;
    BOOL isHabitsEnabled;
    BOOL stoppingHabit;
    BOOL isHeadsUpActivated, disableHeadsUpPermanently;
    BOOL isUserFullyRegistered;
    BOOL didRequestFromRemote;
    int apiCounter;
    UserInfo *userInfo;
    
    dispatch_group_t group;
    
    UserServicesApi lastApiCall;
    HabitsServicesApi lastHabitApiCall;
}

@property (weak, nonatomic) IBOutlet UIView *mainView;
@property (weak, nonatomic) IBOutlet NSLayoutConstraint *contentViewTopConstraint;
@property (weak, nonatomic) IBOutlet NSLayoutConstraint *contentViewHeightConstraint;

@property (weak, nonatomic) IBOutlet UIView *contentView;
@property (weak, nonatomic) IBOutlet UIView *scrollContentView;
@property (weak, nonatomic) IBOutlet UIImageView *profileImageView;
@property (weak, nonatomic) IBOutlet UIButton *profileImageBtn;

@property (weak, nonatomic) IBOutlet UIView *accountView;
@property (weak, nonatomic) IBOutlet UILabel *accountLbl;
@property (weak, nonatomic) IBOutlet UILabel *usernameLbl;
@property (weak, nonatomic) IBOutlet UILabel *emailLbl;
@property (weak, nonatomic) IBOutlet UILabel *passwordLbl;
@property (weak, nonatomic) IBOutlet TextFieldValidator *userNameTxtFld;
@property (weak, nonatomic) IBOutlet TextFieldValidator *emailTxtFld;
@property (weak, nonatomic) IBOutlet TextFieldValidator *passwordTxtFld;

@property (weak, nonatomic) IBOutlet UIView *addressView;
@property (weak, nonatomic) IBOutlet UILabel *addressLbl;
@property (weak, nonatomic) IBOutlet UILabel *streetLbl;
@property (weak, nonatomic) IBOutlet UILabel *cityLbl;
@property (weak, nonatomic) IBOutlet UILabel *zipLbl;
@property (weak, nonatomic) IBOutlet UILabel *countryLbl;
@property (weak, nonatomic) IBOutlet TextFieldValidator *streetTxtFld;
@property (weak, nonatomic) IBOutlet TextFieldValidator *cityTxtFld;
@property (weak, nonatomic) IBOutlet TextFieldValidator *zipTxtFld;
@property (weak, nonatomic) IBOutlet TextFieldValidator *countryTxtFld;
@property (weak, nonatomic) IBOutlet NSLayoutConstraint *addressViewHeightConstraint;

@property (weak, nonatomic) IBOutlet UIView *notificationsView;
@property (weak, nonatomic) IBOutlet UILabel *notificationLbl;
@property (weak, nonatomic) IBOutlet UIButton *motivationReminderBtn;
@property (weak, nonatomic) IBOutlet UILabel *motivationReminderLbl;
@property (weak, nonatomic) IBOutlet UIButton *habitsReminderBtn;
@property (weak, nonatomic) IBOutlet UILabel *habitsReminderLbl;
@property (weak, nonatomic) IBOutlet UIButton *personalGoalReminderBtn;
@property (weak, nonatomic) IBOutlet UILabel *personalGoalReminderLbl;
@property (weak, nonatomic) IBOutlet UILabel *settingsLbl;
@property (weak, nonatomic) IBOutlet TextFieldValidator *exerciseGoalTxtFld;
@property (weak, nonatomic) IBOutlet UILabel *exerciseGoalLbl;
@property (weak, nonatomic) IBOutlet UIButton *disableHabitActionBtn;
@property (weak, nonatomic) IBOutlet UIButton *disableHabitsBtn;
@property (weak, nonatomic) IBOutlet UILabel *disableHabitsLbl;
@property (weak, nonatomic) IBOutlet UIButton *activateHeadsUpBtn;
@property (weak, nonatomic) IBOutlet UILabel *activateHeadsUpLbl;
@property (weak, nonatomic) IBOutlet UIButton *purchaseHistoryBtn;
@property (weak, nonatomic) IBOutlet UILabel *purchaseHistoryLbl;
@property (weak, nonatomic) IBOutlet UIButton *saveBtn;

@property (weak, nonatomic) IBOutlet UIView *faqImprintTermsView;
@property (weak, nonatomic) IBOutlet UIButton *faqBtn;
@property (weak, nonatomic) IBOutlet UIButton *imprintBtn;
@property (weak, nonatomic) IBOutlet UIButton *termsBtn;

@property (weak, nonatomic) IBOutlet UIButton *signOutBtn;
@property (weak, nonatomic) IBOutlet UIButton *deleteBtn;
@property (weak, nonatomic) IBOutlet NSLayoutConstraint *faqConstraintsLeading;
@property (weak, nonatomic) IBOutlet NSLayoutConstraint *faqConstraintsWidth;


@end

@implementation SettingsViewController

-(void)viewWillAppear:(BOOL)animated{
    [super viewWillAppear:YES];
    self.navigationController.navigationBar.hidden = YES;
    
}

- (void)viewDidLoad {
    [super viewDidLoad];
    self.navigationController.navigationBar.hidden = YES;
    
    delegate = (AppDelegate *)[[UIApplication sharedApplication] delegate];
    helper = [Helper sharedHelper];
    animations = [Animations sharedAnimations];
    colors = [Colors sharedColors];
    fonts = [Fonts sharedFonts];
    translationsModel = [TranslationsModel sharedInstance];
    
    skeletonView = [[SkeletonView alloc] initWithFrame:_scrollContentView.frame];
    skeletonView.layer.cornerRadius = 15;
    
    group = dispatch_group_create();
}

- (void)viewDidAppear:(BOOL)animated{
    [super viewDidAppear:YES];
    
    [[ToastView sharedInstance] setDelegate:self];
    [[NetworkManager sharedInstance] setDelegate:self];
    [[NetworkManager sharedInstance] connectivityMonitoring];
    
    if([[NetworkManager sharedInstance] isConnectionOffline]){
        /**
         * show offline data
         */
        userInfo = [[UserModel sharedInstance] getUserInfo];
        if (userInfo) {
            [self setInfo];
        }
        
        NSString *imgUrl = [[UserModel sharedInstance] getImageUrlOfMedia:@"profileImage"];
        if ([imgUrl length] > 0) {
            [_profileImageView sd_setImageWithURL:[NSURL URLWithString:imgUrl] placeholderImage:[UIImage imageNamed:@"default-avatar"]];
        }
        /**
         * end
         */
        
        return;
    }
    
    if(!didRequestFromRemote){
        [self getUpdates];
    }
}

- (void)getUpdates{
    _profileImageView.hidden = YES;
    _userNameTxtFld.hidden = YES;
    _emailTxtFld.hidden = YES;
    _passwordTxtFld.hidden = YES;
    _streetTxtFld.hidden = YES;
    _cityTxtFld.hidden = YES;
    _zipTxtFld.hidden = YES;
    _countryTxtFld.hidden = YES;
    
    [self addSkeletonView];
    [self getInfo];
    [self getProfileImage];
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
    if(!lastApiCall && !lastHabitApiCall){
        if([[NetworkManager sharedInstance] isConnectionOffline]){
            [[NetworkManager sharedInstance] showConnectionErrorInViewController:self];
            return;
        }
        
        [self getUpdates];
        return;
    }
    
    if(
       lastApiCall == UserServicesApi_CreateUserPreferences ||
       lastApiCall == UserServicesApi_UpdateEmail ||
       lastApiCall == UserServicesApi_UpdatePassword ||
       lastHabitApiCall == HabitsServicesApi_StopHabit
    ){
        [self saveChanges:nil];
        return;
    }
    
    if(lastApiCall == UserServicesApi_DeleteAccount){
         [self deleteAccount];
    }
}

-(void)cancelToast{
    lastApiCall = 0;
    lastHabitApiCall = 0;
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
    
    [helper setFlexibleBorderIn:_accountView withColor:[UIColor grayColor] topBorderWidth:0 leftBorderWidth:0 rightBorderWidth:0 bottomBorderWidth:0.5f];
    [helper setFlexibleBorderIn:_addressView withColor:[UIColor grayColor] topBorderWidth:0 leftBorderWidth:0 rightBorderWidth:0 bottomBorderWidth:0.5f];
    //[helper setFlexibleBorderIn:_notificationsView withColor:[UIColor grayColor] topBorderWidth:0 leftBorderWidth:0 rightBorderWidth:0 bottomBorderWidth:0.5f];
    
    [self initInputStyle];
    
    _profileImageView.layer.cornerRadius = CGRectGetWidth(_profileImageView.frame)/2;
    _profileImageView.clipsToBounds = YES;
    
    _profileImageBtn.layer.cornerRadius = CGRectGetWidth(_profileImageBtn.frame)/2;
    _profileImageBtn.clipsToBounds = YES;
    
    _accountLbl.font = [fonts titleFontBold];
    _usernameLbl.font = [fonts normalFontBold];
    _emailLbl.font = [fonts normalFontBold];
    _passwordLbl.font = [fonts normalFontBold];
    _userNameTxtFld.font = [fonts normalFont];
    _emailTxtFld.font = [fonts normalFont];
    _passwordTxtFld.font = [fonts normalFont];
    
    _addressLbl.font = [fonts titleFontBold];
    _streetLbl.font = [fonts normalFontBold];
    _cityLbl.font = [fonts normalFontBold];
    _zipLbl.font = [fonts normalFontBold];
    _countryLbl.font = [fonts normalFontBold];
    _streetTxtFld.font = [fonts normalFont];
    _cityTxtFld.font = [fonts normalFont];
    _zipTxtFld.font = [fonts normalFont];
    _countryTxtFld.font = [fonts normalFont];
    
    _notificationLbl.font = [fonts titleFontBold];
    _motivationReminderLbl.font = [fonts normalFont];
    _habitsReminderLbl.font = [fonts normalFont];
    _personalGoalReminderLbl.font = [fonts normalFont];
    
    _settingsLbl.font = [fonts titleFontBold];
    _exerciseGoalTxtFld.font = [fonts normalFont];
    _exerciseGoalLbl.font = [fonts normalFont];
    _disableHabitsLbl.font = [fonts normalFont];
    _activateHeadsUpLbl.font = [fonts normalFont];
    _purchaseHistoryLbl.font = [fonts normalFont];
    
    _saveBtn.titleLabel.font = [fonts normalFontBold];
    _faqBtn.titleLabel.font = [fonts normalFont];
    _imprintBtn.titleLabel.font = [fonts normalFont];
    _termsBtn.titleLabel.font = [fonts normalFont];
    
    _signOutBtn.titleLabel.font = [fonts normalFont];
    _deleteBtn.titleLabel.font = [fonts normalFontBold];
    _deleteBtn.titleLabel.adjustsFontSizeToFitWidth = YES;
    
    [_saveBtn setBackgroundColor:[colors blueColor]];
    
    _accountLbl.text = [[translationsModel getTranslationForKey:@"profile.account_title"] uppercaseString];
    _usernameLbl.text = [[translationsModel getTranslationForKey:@"global.username"] uppercaseString];
    _emailLbl.text = [[translationsModel getTranslationForKey:@"global.email"] uppercaseString];
    _passwordLbl.text = [[translationsModel getTranslationForKey:@"global.password"] uppercaseString];
    
    _addressLbl.text = [[translationsModel getTranslationForKey:@"profile.address_title"] uppercaseString];
    _streetLbl.text = [[translationsModel getTranslationForKey:@"profile.street"] uppercaseString];
    _cityLbl.text = [[translationsModel getTranslationForKey:@"profile.city"] uppercaseString];
    _zipLbl.text = [[translationsModel getTranslationForKey:@"profile.zip"] uppercaseString];
    _countryLbl.text = [[translationsModel getTranslationForKey:@"profile.country"] uppercaseString];
    
    _notificationLbl.text = [[translationsModel getTranslationForKey:@"profile.notifications_title"] uppercaseString];
    _motivationReminderLbl.text = [translationsModel getTranslationForKey:@"profile.dailyreminder"];
    _habitsReminderLbl.text = [translationsModel getTranslationForKey:@"profile.remindhabits"];
    _personalGoalReminderLbl.text = [translationsModel getTranslationForKey:@"profile.remindpersonalgoals"];
    _settingsLbl.text = [[translationsModel getTranslationForKey:@"profile.settings_title"] uppercaseString];
    _exerciseGoalLbl.text = [translationsModel getTranslationForKey:@"profile.setpersonalgoal"];
    _disableHabitsLbl.text = [translationsModel getTranslationForKey:@"profile.disablehabits"];
    _activateHeadsUpLbl.text = [translationsModel getTranslationForKey:@"profile.dailyheadsup"];
    _purchaseHistoryLbl.text = [translationsModel getTranslationForKey:@"profile.purchasehistory"];
    [_saveBtn setTitle:[translationsModel getTranslationForKey:@"profile.save_button"] forState:UIControlStateNormal];
    [_deleteBtn setTitle:[translationsModel getTranslationForKey:@"profile.buttondelete"] forState:UIControlStateNormal];
    
    [_notificationLbl setLineHeight];
    [_motivationReminderLbl setLineHeight];
    [_habitsReminderLbl setLineHeight];
    [_personalGoalReminderLbl setLineHeight];
    
    [_settingsLbl setLineHeight];
    [_exerciseGoalLbl setLineHeight];
    [_disableHabitsLbl setLineHeight];
    [_activateHeadsUpLbl setLineHeight];
    [_purchaseHistoryLbl setLineHeight];
    
    NSMutableParagraphStyle *style = [[NSParagraphStyle defaultParagraphStyle] mutableCopy];
    [style setAlignment:NSTextAlignmentCenter];
    [style setLineBreakMode:NSLineBreakByWordWrapping];
    
    NSDictionary *dict1 = @{NSUnderlineStyleAttributeName:@(NSUnderlineStyleSingle),
                            NSFontAttributeName:[fonts normalFont],
                            NSParagraphStyleAttributeName:style};
    
    NSMutableAttributedString *faqAttString = [[NSMutableAttributedString alloc] init];
    [faqAttString appendAttributedString:[[NSAttributedString alloc] initWithString:[translationsModel getTranslationForKey:@"profile.faqlink"] attributes:dict1]];
    [_faqBtn setAttributedTitle:faqAttString forState:UIControlStateNormal];
    
    NSMutableAttributedString *imprintAttString = [[NSMutableAttributedString alloc] init];
    [imprintAttString appendAttributedString:[[NSAttributedString alloc] initWithString:[translationsModel getTranslationForKey:@"profile.imprintlink"] attributes:dict1]];
    [_imprintBtn setAttributedTitle:imprintAttString forState:UIControlStateNormal];
    
    NSMutableAttributedString *termsAttString = [[NSMutableAttributedString alloc] init];
    [termsAttString appendAttributedString:[[NSAttributedString alloc] initWithString:[translationsModel getTranslationForKey:@"profile.termslink"] attributes:dict1]];
    [_termsBtn setAttributedTitle:termsAttString forState:UIControlStateNormal];
    
    NSMutableAttributedString *signOutAttString = [[NSMutableAttributedString alloc] init];
    [signOutAttString appendAttributedString:[[NSAttributedString alloc] initWithString:[translationsModel getTranslationForKey:@"profile.signoutlink"] attributes:dict1]];
    [_signOutBtn setAttributedTitle:signOutAttString forState:UIControlStateNormal];
    
    
    //adjust faq if chinese so the buttons will appear centered
    if([LANGUAGE_KEY isEqualToString:@"cn"]){
        _faqConstraintsLeading.constant = 15;
        _faqConstraintsWidth.constant = 80;
    }
}

- (void)getProfileImage{
    [[UserMediaServices sharedInstance] getProfileImageWithCompletion:^(NSError *error, int statusCode)  {
        if(statusCode == NoInternetErrorStatusCode || statusCode == SlowInternetErrorStatusCode) {
            [[NetworkManager sharedInstance] showConnectionErrorInViewController:self statusCode:statusCode];
            return;
        }
        
        self->apiCounter += 1;
        [self removeSkeletonView];
        
        NSString *url = [[UserModel sharedInstance] getImageUrlOfMedia:@"profileImage"];
        [self->_profileImageView sd_setImageWithURL:[NSURL URLWithString:url] placeholderImage:[UIImage imageNamed:@"default-avatar"]];
    }];
}

- (void)getInfo{
    [[UserServices sharedInstance] getUserInfoWithCompletion:^(NSError *error, int statusCode) {
        if(statusCode == NoInternetErrorStatusCode || statusCode == SlowInternetErrorStatusCode) {
            [[NetworkManager sharedInstance] showConnectionErrorInViewController:self->delegate.tabBarController statusCode:statusCode];
            return;
        }
        
        self->apiCounter += 1;
        [self removeSkeletonView];
        
        if (!error && statusCode == 200) {
            self->userInfo = [[UserModel sharedInstance] getUserInfo];
            [self setInfo];
            return;
        }
        
        if(error){
            //there is error on the api side
            [[NetworkManager sharedInstance] showApiErrorInViewController:self->delegate.tabBarController error:error];
        }
    }];
}

- (void)setInfo{
    
    if ([userInfo.street length] == 0 && [userInfo.city length] == 0 && [userInfo.zipCode length] == 0 && [userInfo.country length] == 0  ) {
        _addressViewHeightConstraint.constant = 0;
        _contentViewHeightConstraint.constant = CGRectGetHeight(_scrollContentView.frame)-CGRectGetHeight(_addressView.frame);
        [_mainView layoutIfNeeded];
        
        isUserFullyRegistered = NO;
    }else{
        isUserFullyRegistered = YES;
    }
    
    _userNameTxtFld.text = userInfo.userName;
    _emailTxtFld.text = [helper getSavedUsername];
    _passwordTxtFld.text = @"****";
    _streetTxtFld.text = userInfo.street;
    _cityTxtFld.text = userInfo.city;
    _zipTxtFld.text = userInfo.zipCode;
    _countryTxtFld.text = userInfo.country;
    _exerciseGoalTxtFld.text = @(userInfo.exerciseGoal).stringValue;
    
    isMotivationReminderEnabled = userInfo.isMotivationReminderEnabled;
    isHabitsReminderEnabled = userInfo.isHabitsReminderEnabled;
    isPersonalGoalReminderEnabled = userInfo.isPersonalGoalReminderEnabled;
    isHabitsEnabled = userInfo.isHabitsEnabled;
    isHeadsUpActivated = userInfo.isHeadsUpActivated;
    disableHeadsUpPermanently = userInfo.isHeadsUpActivated? false: true;
    
    [self setBtn:_motivationReminderBtn selected:isMotivationReminderEnabled];
    [self setBtn:_habitsReminderBtn selected:isHabitsReminderEnabled];
    [self setBtn:_personalGoalReminderBtn selected:isPersonalGoalReminderEnabled];
    [self setBtn:_disableHabitsBtn selected:false];//always show unselected. need user internaction to disable
    [self setBtn:_activateHeadsUpBtn selected:disableHeadsUpPermanently];
    
    [self updateDisableHabitUI];
}

- (void)updateDisableHabitUI{
    if(!IS_HABITS_ACTIVATED){
        _disableHabitsBtn.backgroundColor = [UIColor lightGrayColor];
        _disableHabitsBtn.userInteractionEnabled = false;
        _disableHabitActionBtn.userInteractionEnabled = false;
    }else{
        _disableHabitsBtn.backgroundColor = [UIColor whiteColor];
        _disableHabitsBtn.userInteractionEnabled = true;
        _disableHabitActionBtn.userInteractionEnabled = true;
    }
}

- (IBAction)selectMotivationReminder:(id)sender{
    if (isMotivationReminderEnabled) {
        isMotivationReminderEnabled = FALSE;
    }else {
        isMotivationReminderEnabled = TRUE;
    }
    
    [self setBtn:_motivationReminderBtn selected:isMotivationReminderEnabled];
}

- (IBAction)selectHabitsReminder:(id)sender{
    if (isHabitsReminderEnabled) {
        isHabitsReminderEnabled = FALSE;
    }else {
        isHabitsReminderEnabled = TRUE;
    }
    
    [self setBtn:_habitsReminderBtn selected:isHabitsReminderEnabled];
}

- (IBAction)selectPersonalGoalReminder:(id)sender{
    if (isPersonalGoalReminderEnabled) {
        isPersonalGoalReminderEnabled = FALSE;
    }else {
        isPersonalGoalReminderEnabled = TRUE;
    }
    
    [self setBtn:_personalGoalReminderBtn selected:isPersonalGoalReminderEnabled];
}

- (IBAction)selectDisableHabits:(id)sender{
    
    if (!stoppingHabit) {
        [[CustomAlertView sharedInstance] showAlertInViewController:self
                                                          withTitle:[translationsModel getTranslationForKey:@"habdis.title"]
                                                            message:[translationsModel getTranslationForKey:@"habdis.descr"]
                                                  cancelButtonTitle:[translationsModel getTranslationForKey:@"habdis.continue"]
                                                    doneButtonTitle:[translationsModel getTranslationForKey:@"habdis.stop"]];
        [[CustomAlertView sharedInstance] setCancelBlock:^(id result) {
            self->stoppingHabit = true;
            [self setBtn:self->_disableHabitsBtn selected:true];
        }];
        [[CustomAlertView sharedInstance] setDoneBlock:^(id result) {
        }];
    }else {
        stoppingHabit = false;
        [self setBtn:_disableHabitsBtn selected:false];
    }
    
}

- (IBAction)selectActivateHeadsUp:(id)sender{
    if (!disableHeadsUpPermanently) {
        disableHeadsUpPermanently = TRUE;
    }else {
        disableHeadsUpPermanently = FALSE;
    }
    
    [self setBtn:_activateHeadsUpBtn selected:disableHeadsUpPermanently];
}

- (void)setBtn:(UIButton *)btn selected:(BOOL)isSelected{
    if (isSelected){
        btn.layer.borderWidth = 0;
        btn.backgroundColor = [colors orangeColor];
        btn.layer.cornerRadius = 5.0;
        btn.clipsToBounds = YES;
    }else{
        btn.layer.borderWidth = 1.0;
        btn.layer.borderColor = [UIColor blackColor].CGColor;
        btn.backgroundColor = [UIColor clearColor];
        btn.layer.cornerRadius = 5.0;
        btn.clipsToBounds = YES;
    }
}

- (IBAction)purchaseHistory:(id)sender{
    PurchaseHistoryViewController *vc = [[PurchaseHistoryViewController alloc] initWithNibName:@"PurchaseHistoryViewController" bundle:nil];
    
    vc.view.backgroundColor = [UIColor clearColor];
    vc.modalPresentationStyle = UIModalPresentationOverCurrentContext;
    
    UIViewController *pvc = delegate.tabBarController.presentedViewController;
    [pvc presentViewController:vc animated: NO completion:nil];
}

- (IBAction)imprint:(id)sender{
    [self openOverlayViewWithTitle:[translationsModel getTranslationForKey:@"Imprint.title"]
                              desc:[translationsModel getTranslationForKey:@"imprint.text"]];
}

- (IBAction)openTermsOfUse:(id)sender{
    [self openOverlayViewWithTitle:[translationsModel getTranslationForKey:@"terms.title"]
                              desc:[translationsModel getTranslationForKey:@"terms.text"]];
}

- (void)openOverlayViewWithTitle:(NSString *)titleStr desc:(NSString *)desc{
    
    TextViewOverlayViewController *vc = [[TextViewOverlayViewController alloc] initWithNibName:@"TextViewOverlayViewController" bundle:nil];
    
    vc.titleStr = titleStr;
    vc.desc = desc;
    
    vc.view.backgroundColor = [UIColor clearColor];
    vc.modalPresentationStyle = UIModalPresentationOverCurrentContext;
    
    UIViewController *pvc = delegate.tabBarController.presentedViewController;
    [pvc presentViewController:vc animated:NO completion:nil];
}

- (IBAction)deletAccount:(id)sender{
    CustomAlertView *alert = [CustomAlertView sharedInstance];
    [alert showAlertInViewController:self
                           withTitle:[translationsModel getTranslationForKey:@"info.deleteaccountdata"]
                             message:[translationsModel getTranslationForKey:@"info.deleteaccountconfirm"]
                   cancelButtonTitle:[translationsModel getTranslationForKey:@"global.cancelbutton"]
                     doneButtonTitle:[translationsModel getTranslationForKey:@"global.delete"]];
    [alert setCancelBlock:^(id result) {
        NSLog(@"Cancel");
    }];
    [alert setDoneBlock:^(id result) {
        [self deleteAccount];
    }];
}

- (void)deleteAccount{
    [DejalBezelActivityView activityViewForView:self.view];
    [[UserServices sharedInstance] deleteAccountWithCompletion:^(NSError *error, int statusCode) {
        [DejalBezelActivityView removeViewAnimated:YES];
        
        if(statusCode == NoInternetErrorStatusCode || statusCode == SlowInternetErrorStatusCode) {
            [[NetworkManager sharedInstance] showConnectionErrorInViewController:self->delegate.tabBarController statusCode:statusCode];
            self->lastApiCall = UserServicesApi_DeleteAccount;
            return;
        }
        
        self->lastApiCall = 0;
        
        if (statusCode == 201 || statusCode == 204) {
            /*for (UIViewController *controller in self.navigationController.viewControllers){
                if ([controller isKindOfClass:[SignInViewController class]]){
                    [self.navigationController popToViewController:controller animated:YES]; 
                    break;
                }
            }*/
            [self signOut:nil];
            return;
        }
        
        if(error){
            //there is error on the api side
            [[NetworkManager sharedInstance] showApiErrorInViewController:self->delegate.tabBarController error:error];
            self->lastApiCall = UserServicesApi_DeleteAccount;
        }
    }];
}

- (IBAction)signOut:(id)sender{
    [helper removeSavedUser];
    [helper emptySavedData];
    [self dismissViewControllerAnimated:NO completion:^{
        if (self.dismissDelegate) {
            [self.dismissDelegate signOut];
        }
    }];
}

- (IBAction)saveChanges:(id)sender{
    [self.view endEditing:YES];
    
    //make sure to set back the style
    [self initInputStyle];
    
    //make sure toast is dismissed before firing it back
    [[ToastView sharedInstance] dismiss];
    
    //do not continue if no internet connection
    if([[NetworkManager sharedInstance] isConnectionOffline]){
        [[NetworkManager sharedInstance] showConnectionErrorInViewController:delegate.tabBarController];
        return;
    }
    
    if (![_userNameTxtFld validate]|![_emailTxtFld validate]|![_passwordTxtFld validate]) {
        //show error message and style
        [self showErrors];
        return;
    }
    if (isUserFullyRegistered && (![_streetTxtFld validate]|![_cityTxtFld validate]|![_zipTxtFld validate]|![_countryTxtFld validate])) {
        //show error message and style
        [self showErrors];
        return;
    }
    
    [DejalBezelActivityView activityViewForView:self.view];
    
    [self updatePreferences];
    
    [self stopHabit];
    
    if(_emailTxtFld.text.length > 0 && ![_emailTxtFld.text isEqualToString:userInfo.email]){
        [self updateEmailAddress];
    }
    
    dispatch_group_notify(group, dispatch_get_global_queue(DISPATCH_QUEUE_PRIORITY_HIGH, 0), ^{
        NSLog(@"Finished Saving");
        
        if(self->_passwordTxtFld.text.length > 0 && ![self->_passwordTxtFld.text isEqualToString:@"****"]){
            [[UserServices sharedInstance] updatePassword:self->_passwordTxtFld.text withCompletion:^(NSError *error, int statusCode) {
                NSLog(@"Finished updating password = %i", statusCode);
                dispatch_async(dispatch_get_main_queue(), ^{
                    [DejalBezelActivityView removeViewAnimated:YES];
                    [self dismissViewControllerAnimated:YES completion:nil];
                });
            }];
            return;
        }
        
        dispatch_async(dispatch_get_main_queue(), ^{
            [DejalBezelActivityView removeViewAnimated:YES];
            [self dismissViewControllerAnimated:YES completion:nil];
        });
        
    });
}

- (void) updatePreferences {
    dispatch_group_enter(group);
    [[UserServices sharedInstance] createUserPreferences:[self parameters] withCompletion:^(NSError *error, int statusCode) {
        NSLog(@"Finished updating preferences = %i", statusCode);
        
        if(statusCode == NoInternetErrorStatusCode || statusCode == SlowInternetErrorStatusCode) {
            [[NetworkManager sharedInstance] showConnectionErrorInViewController:self->delegate.tabBarController statusCode:statusCode];
            [DejalBezelActivityView removeViewAnimated:YES];
            self->lastApiCall = UserServicesApi_CreateUserPreferences;
            return;
        }
        
        self->lastApiCall = 0;
        
        if(!error){
            //update successful
            HIDE_HEADS_UP_PERMANENT(self->disableHeadsUpPermanently)
        }
        
        dispatch_group_leave(self->group);
    }];
}

- (void) stopHabit{
    if(!stoppingHabit){
        return;
    }
    
    dispatch_group_enter(group);
    [[HabitsServices sharedInstance] stopHabitsWithCompletion:^(NSError *error, int statusCode) {
        NSLog(@"Stopping habit status = %i", statusCode);
        
        if(statusCode == NoInternetErrorStatusCode || statusCode == SlowInternetErrorStatusCode) {
            [[NetworkManager sharedInstance] showConnectionErrorInViewController:self->delegate.tabBarController statusCode:statusCode];
            [DejalBezelActivityView removeViewAnimated:YES];
            self->lastHabitApiCall = HabitsServicesApi_StopHabit;
            return;
        }
        
        self->lastHabitApiCall = 0;
        self->stoppingHabit = false;
        HABITS_ACTIVATED(false);
        
        dispatch_async(dispatch_get_main_queue(), ^{
            [self updateDisableHabitUI];
            //reload tab bar and set habit as default
            [[Helper sharedHelper] setUpTabBarControllerFrom:self initialIndex:4];
            //[[Helper sharedHelper] withnotactivehabit];
        });
        
        dispatch_group_leave(self->group);
    }];
}

- (void) updateEmailAddress {
    dispatch_group_enter(group);
    [[UserServices sharedInstance] updateEmail:_emailTxtFld.text withCompletion:^(NSError *error, int statusCode) {
        NSLog(@"Finished updating email address = %i", statusCode);
        
        if(statusCode == NoInternetErrorStatusCode || statusCode == SlowInternetErrorStatusCode) {
            [[NetworkManager sharedInstance] showConnectionErrorInViewController:self->delegate.tabBarController statusCode:statusCode];
            [DejalBezelActivityView removeViewAnimated:YES];
            self->lastApiCall = UserServicesApi_UpdateEmail;
            return;
        }
        
        self->lastApiCall = 0;
        
        dispatch_group_leave(self->group);
    }];
}

- (void) updatePassword {
    dispatch_group_enter(group);
    [[UserServices sharedInstance] updatePassword:_passwordTxtFld.text withCompletion:^(NSError *error, int statusCode) {
        NSLog(@"Finished updating password = %i", statusCode);
        
        if(statusCode == NoInternetErrorStatusCode || statusCode == SlowInternetErrorStatusCode) {
            [[NetworkManager sharedInstance] showConnectionErrorInViewController:self->delegate.tabBarController statusCode:statusCode];
            [DejalBezelActivityView removeViewAnimated:YES];
            self->lastApiCall = UserServicesApi_UpdatePassword;
            return;
        }
        
        self->lastApiCall = 0;
        
        dispatch_group_leave(self->group);
    }];
}

- (NSDictionary *)parameters{
    NSLog(@"User Info = %@", userInfo);
    if(!userInfo){
        return @{};
    }
    
    NSMutableArray *newPreferences = [NSMutableArray new];
    
    if(userInfo.userNameId){
        [newPreferences addObject:@{ @"name": userInfo.userNameId, @"value": _userNameTxtFld.text }];
    }
    
    if(userInfo.streetId){
        [newPreferences addObject:@{ @"name": userInfo.streetId, @"value": _streetTxtFld.text }];
    }
    
    if(userInfo.cityId){
        [newPreferences addObject:@{ @"name": userInfo.cityId, @"value": _cityTxtFld.text }];
    }
    
    if(userInfo.zipCodeId){
        [newPreferences addObject:@{ @"name": userInfo.zipCodeId, @"value": _zipTxtFld.text }];
    }
    
    if(userInfo.countryId){
        [newPreferences addObject:@{ @"name": userInfo.countryId, @"value": _countryTxtFld.text }];
    }
    
    if(userInfo.motivationReminderId){
        [newPreferences addObject:@{ @"name": userInfo.motivationReminderId, @"value": @(isMotivationReminderEnabled) }];
    }
    
    if(userInfo.habitsReminderId){
        [newPreferences addObject:@{ @"name": userInfo.habitsReminderId, @"value": @(isHabitsReminderEnabled) }];
    }
    
    if(userInfo.personalGoalReminderId){
        [newPreferences addObject:@{ @"name": userInfo.personalGoalReminderId, @"value": @(isPersonalGoalReminderEnabled) }];
    }
    
    if(userInfo.headsUpActivatedId){
        [newPreferences addObject:@{ @"name": userInfo.headsUpActivatedId, @"value": @(disableHeadsUpPermanently?0:1) }];
    }
    
    /*if(userInfo.habitsEnableId){
        [newPreferences addObject:@{ @"name": userInfo.habitsEnableId, @"value": @(isHabitsEnabled) }];
    }*/
    
    if(newPreferences.count == 0)
        return @{};
    
    return @{ @"newPreferences": newPreferences };
}

- (void)initInputStyle{
    [helper setFlexibleBorderIn:_userNameTxtFld
                      withColor:[UIColor blackColor]
                 topBorderWidth:0.0f
                leftBorderWidth:0.0
               rightBorderWidth:0.0
              bottomBorderWidth:1.0f];
    [helper setFlexibleBorderIn:_emailTxtFld
                      withColor:[UIColor blackColor]
                 topBorderWidth:0.0f
                leftBorderWidth:0.0
               rightBorderWidth:0.0
              bottomBorderWidth:1.0f];
    [helper setFlexibleBorderIn:_passwordTxtFld
                      withColor:[UIColor blackColor]
                 topBorderWidth:0.0f
                leftBorderWidth:0.0
               rightBorderWidth:0.0
              bottomBorderWidth:1.0f];
    [helper setFlexibleBorderIn:_streetTxtFld
                      withColor:[UIColor blackColor]
                 topBorderWidth:0.0f
                leftBorderWidth:0.0
               rightBorderWidth:0.0
              bottomBorderWidth:1.0f];
    [helper setFlexibleBorderIn:_cityTxtFld
                      withColor:[UIColor blackColor]
                 topBorderWidth:0.0f
                leftBorderWidth:0.0
               rightBorderWidth:0.0
              bottomBorderWidth:1.0f];
    [helper setFlexibleBorderIn:_zipTxtFld
                      withColor:[UIColor blackColor]
                 topBorderWidth:0.0f
                leftBorderWidth:0.0
               rightBorderWidth:0.0
              bottomBorderWidth:1.0f];
    [helper setFlexibleBorderIn:_countryTxtFld
                      withColor:[UIColor blackColor]
                 topBorderWidth:0.0f
                leftBorderWidth:0.0
               rightBorderWidth:0.0
              bottomBorderWidth:1.0f];
    
    _usernameLbl.textColor = [UIColor blackColor];
    _emailLbl.textColor = [UIColor blackColor];
    _passwordLbl.textColor = [UIColor blackColor];
    _streetLbl.textColor = [UIColor blackColor];
    _cityLbl.textColor = [UIColor blackColor];
    _zipLbl.textColor = [UIColor blackColor];
    _countryLbl.textColor = [UIColor blackColor];
}

- (void)showErrors{
    NSString *message = [translationsModel getTranslationForKey:@"info.someinputdatamissing"];
    
    if(![_userNameTxtFld validate]){
        [helper setFlexibleBorderIn:_userNameTxtFld
                          withColor:[colors warning]
                     topBorderWidth:0.0f
                    leftBorderWidth:0.0
                   rightBorderWidth:0.0
                  bottomBorderWidth:1.0f];
        _usernameLbl.textColor = [colors warning];
    }
    
    if(![_emailTxtFld validate]){
        [helper setFlexibleBorderIn:_emailTxtFld
                          withColor:[colors warning]
                     topBorderWidth:0.0f
                    leftBorderWidth:0.0
                   rightBorderWidth:0.0
                  bottomBorderWidth:1.0f];
        _emailLbl.textColor = [colors warning];
    }
    
    if(![_passwordTxtFld validate]){
        [helper setFlexibleBorderIn:_passwordTxtFld
                          withColor:[colors warning]
                     topBorderWidth:0.0f
                    leftBorderWidth:0.0
                   rightBorderWidth:0.0
                  bottomBorderWidth:1.0f];
        _passwordLbl.textColor = [colors warning];
    }
    
    if(isUserFullyRegistered){
        if(![_streetTxtFld validate]){
            [helper setFlexibleBorderIn:_streetTxtFld
                              withColor:[colors warning]
                         topBorderWidth:0.0f
                        leftBorderWidth:0.0
                       rightBorderWidth:0.0
                      bottomBorderWidth:1.0f];
            _streetLbl.textColor = [colors warning];
        }
        
        if(![_cityTxtFld validate]){
            [helper setFlexibleBorderIn:_cityTxtFld
                              withColor:[colors warning]
                         topBorderWidth:0.0f
                        leftBorderWidth:0.0
                       rightBorderWidth:0.0
                      bottomBorderWidth:1.0f];
            _cityLbl.textColor = [colors warning];
        }
        
        if(![_zipTxtFld validate]){
            [helper setFlexibleBorderIn:_zipTxtFld
                              withColor:[colors warning]
                         topBorderWidth:0.0f
                        leftBorderWidth:0.0
                       rightBorderWidth:0.0
                      bottomBorderWidth:1.0f];
            _zipLbl.textColor = [colors warning];
        }
        
        if(![_countryTxtFld validate]){
            [helper setFlexibleBorderIn:_countryTxtFld
                              withColor:[colors warning]
                         topBorderWidth:0.0f
                        leftBorderWidth:0.0
                       rightBorderWidth:0.0
                      bottomBorderWidth:1.0f];
            _countryLbl.textColor = [colors warning];
        }
    }
    
    [[ToastView sharedInstance] showInViewController:self
                                             message:message
                                        includeError:nil
                                   enableAutoDismiss:true
                                           showRetry:false];
}

- (IBAction)changeProfilePic:(id)sender{
    [self dismissViewControllerAnimated:NO completion:^{
        if (self.dismissDelegate) {
            [self.dismissDelegate changeProfilePic];
        }
    }];
}

- (IBAction)faqs:(id)sender{
    FaqViewController *vc = [[FaqViewController alloc] initWithNibName:@"FaqViewController" bundle:nil];
    
    [delegate.tabBarController.navigationController pushViewController:vc animated:YES];
}

- (IBAction)close:(id)sender{
    [self dismissViewControllerAnimated:YES completion:nil];
}

- (void)addSkeletonView{
    [skeletonView addSkeletonFor:_profileImageView isText:NO];
    
    [skeletonView addSkeletonOn:_accountView for:_accountLbl isText:YES];
    [skeletonView addSkeletonOn:_accountView for:_usernameLbl isText:YES];
    [skeletonView addSkeletonOn:_accountView for:_emailLbl isText:YES];
    [skeletonView addSkeletonOn:_accountView for:_passwordLbl isText:YES];
    
    [skeletonView addSkeletonOn:_addressView for:_addressLbl isText:YES];
    [skeletonView addSkeletonOn:_addressView for:_streetLbl isText:YES];
    [skeletonView addSkeletonOn:_addressView for:_cityLbl isText:YES];
    [skeletonView addSkeletonOn:_addressView for:_zipLbl isText:YES];
    [skeletonView addSkeletonOn:_addressView for:_countryLbl isText:YES];
    
    [skeletonView addSkeletonOn:_notificationsView for:_notificationLbl isText:YES];
    [skeletonView addSkeletonOn:_notificationsView for:_motivationReminderBtn isText:NO];
    [skeletonView addSkeletonOn:_notificationsView for:_motivationReminderLbl isText:YES];
    [skeletonView addSkeletonOn:_notificationsView for:_habitsReminderBtn isText:NO];
    [skeletonView addSkeletonOn:_notificationsView for:_habitsReminderLbl isText:YES];
    [skeletonView addSkeletonOn:_notificationsView for:_personalGoalReminderBtn isText:NO];
    [skeletonView addSkeletonOn:_notificationsView for:_personalGoalReminderLbl isText:YES];
    
    
    [skeletonView addSkeletonOn:_notificationsView for:_settingsLbl isText:YES];
    [skeletonView addSkeletonOn:_notificationsView for:_exerciseGoalTxtFld isText:YES];
    [skeletonView addSkeletonOn:_notificationsView for:_exerciseGoalLbl isText:YES];
    [skeletonView addSkeletonOn:_notificationsView for:_disableHabitsBtn isText:NO];
    [skeletonView addSkeletonOn:_notificationsView for:_disableHabitsLbl isText:YES];
    [skeletonView addSkeletonOn:_notificationsView for:_activateHeadsUpBtn isText:NO];
    [skeletonView addSkeletonOn:_notificationsView for:_activateHeadsUpLbl isText:YES];
    [skeletonView addSkeletonOn:_notificationsView for:_purchaseHistoryBtn isText:NO];
    [skeletonView addSkeletonOn:_notificationsView for:_purchaseHistoryLbl isText:YES];
    [skeletonView addSkeletonOn:_notificationsView for:_saveBtn isText:NO];
    
    [skeletonView addSkeletonOn:_notificationsView for:_faqImprintTermsView isText:YES];
//    [skeletonView addSkeletonOn:_faqImprintTermsView for:_imprintBtn isText:YES];
//    [skeletonView addSkeletonOn:_faqImprintTermsView for:_termsBtn isText:YES];
    
    [skeletonView addSkeletonFor:_signOutBtn isText:YES];
    [skeletonView addSkeletonFor:_deleteBtn isText:NO];
    [_scrollContentView addSubview:skeletonView];
    
}

- (void)removeSkeletonView{
    if (apiCounter == 2) {
        apiCounter = 0;
        [skeletonView remove];
        didRequestFromRemote = YES;
        
        _profileImageView.hidden = NO;
        [_profileImageView.layer setBorderColor: [[colors orangeColor] CGColor]];
        [_profileImageView.layer setBorderWidth: 3.0];
        
        _userNameTxtFld.hidden = NO;
        _emailTxtFld.hidden = NO;
        _passwordTxtFld.hidden = NO;
        _streetTxtFld.hidden = NO;
        _cityTxtFld.hidden = NO;
        _zipTxtFld.hidden = NO;
        _countryTxtFld.hidden = NO;
    }
}

@end
