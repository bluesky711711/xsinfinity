//
//  SignInViewController.m
//  XSInfinity
//
//  Created by Joseph Marvin Magdadaro on 6/8/15.
//  Copyright © 2015 Joseph Marvin Magdadaro. All rights reserved.
//

#import "SignInViewController.h"
#import "Animations.h"
#import "Helper.h"
#import "Colors.h"
#import "Fonts.h"
#import "TranslationsModel.h"
#import "ModulesServices.h"
#import "UserServices.h"
#import "ActivationViewController.h"
#import "ForgotPasswordViewController.h"
#import "CustomAlertView.h"
#import "TextFieldValidator.h"
#import "DejalActivityView.h"
#import "AppDelegate.h"
#import "ToastView.h"
#import "NetworkManager.h"

@interface SignInViewController ()<NetworkManagerDelegate, ToastViewDelegate>{
    AppDelegate *delegate;
    Animations *animations;
    Helper *helper;
    Colors *colors;
    Fonts *fonts;
    TranslationsModel *translationsModel;
    BOOL didLayoutReloaded;
    
    UserServicesApi lastApiCall;
}

@property (weak, nonatomic) IBOutlet UIButton *signInBtn;
@property (weak, nonatomic) IBOutlet UIView *signInView;
@property (weak, nonatomic) IBOutlet UIButton *tryForFreeBtn;
@property (weak, nonatomic) IBOutlet UIView *tryForFreeView;

@property (weak, nonatomic) IBOutlet UILabel *signInLbl;
@property (weak, nonatomic) IBOutlet UILabel *emailLbl;
@property (weak, nonatomic) IBOutlet UILabel *passwordLbl;
@property (weak, nonatomic) IBOutlet TextFieldValidator *emailTxtFld;
@property (weak, nonatomic) IBOutlet TextFieldValidator *passwordTxtFld;
@property (weak, nonatomic) IBOutlet UIButton *signInSubmitBtn;
@property (weak, nonatomic) IBOutlet UIButton *forgotPasswordBtn;

@property (weak, nonatomic) IBOutlet UILabel *tryForFreeLbl;
@property (weak, nonatomic) IBOutlet UILabel *tryForFreeGuideLbl;
@property (weak, nonatomic) IBOutlet UILabel *nameLbl;
@property (weak, nonatomic) IBOutlet UILabel *tryForFreeEmailLbl;
@property (weak, nonatomic) IBOutlet UILabel *tryForFreePasswordLbl;
@property (weak, nonatomic) IBOutlet TextFieldValidator *nameTxtFld;
@property (weak, nonatomic) IBOutlet TextFieldValidator *tryForFreeEmailTxtFld;
@property (weak, nonatomic) IBOutlet TextFieldValidator *tryForFreePasswordTxtFld;
@property (weak, nonatomic) IBOutlet UIButton *prevBtn;

@end

@implementation SignInViewController

-(void)viewWillAppear:(BOOL)animated{
    [super viewWillAppear:YES];
    self.navigationController.navigationBar.hidden = YES;
    
    //always show sign in by default. this is useful when logging out
    [self showSignIn:nil];
}

- (void)viewDidLoad {
    [super viewDidLoad];
    self.navigationController.navigationBar.hidden = YES;
    
    animations = [Animations sharedAnimations];
    helper = [Helper sharedHelper];
    colors = [Colors sharedColors];
    fonts = [Fonts sharedFonts];
    translationsModel = [TranslationsModel sharedInstance];
    
    [_tryForFreeEmailTxtFld addRegx:@"[A-Z0-9a-z._%+-]{3,}+@[A-Za-z0-9.-]+\\.[A-Za-z]{2,4}"
                            withMsg:[translationsModel getTranslationForKey:@"info.invalidemail"]];
    
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
        [[NetworkManager sharedInstance] showConnectionErrorInViewController:self];
    }
}

#pragma mark - ToastViewDelegate

- (void)retryConnection{
    if(!lastApiCall){
        if([[NetworkManager sharedInstance] isConnectionOffline]){
            [[NetworkManager sharedInstance] showConnectionErrorInViewController:self];
            return;
        }
    }
    
    switch (lastApiCall) {
        case UserServicesApi_CreateUser:
            [self tryForFreeNext:nil];
            break;
        case UserServicesApi_SignIn:
            [self signIn:nil];
            break;
            
        default:
            break;
    }
}

-(void)viewDidLayoutSubviews{
    [super viewDidLayoutSubviews];
    
    if( !didLayoutReloaded ){
        [self setupUserInterface];
        
        didLayoutReloaded = YES;
    }
}

- (void)viewWillDisappear:(BOOL)animated {
    [super viewWillDisappear:YES];
    [self.view endEditing:YES];
}

- (void)setupUserInterface{
    [_signInView layoutIfNeeded];
    [_tryForFreeView layoutIfNeeded];
    
    [helper addShadowIn:_signInView withColor:[UIColor darkGrayColor] andSetCornerRadiusTo:5.0];
    [helper addShadowIn:_tryForFreeView withColor:[UIColor darkGrayColor] andSetCornerRadiusTo:5.0];
    
    [self initInputStyle];
    
    _signInLbl.font = [fonts headerFont];
    _emailLbl.font = [fonts normalFontBold];
    _passwordLbl.font = [fonts normalFontBold];
    _emailTxtFld.font = [fonts normalFont];
    _passwordTxtFld.font = [fonts normalFont];
    _signInBtn.titleLabel.font = [fonts normalFontBold];
    _signInSubmitBtn.titleLabel.font = [fonts normalFontBold];
    _forgotPasswordBtn.titleLabel.font = [fonts normalFont];
    
    //_emailTxtFld.text = @"m_ruediger@freenet.de";
    //_passwordTxtFld.text = @"max";
    
    _tryForFreeLbl.font = [fonts headerFont];
    _tryForFreeGuideLbl.font = [fonts normalFont];
    /*if(IS_IPHONE_5){
        _tryForFreeGuideLbl.font = [fonts smallFont];
        _tryForFreeGuideLbl.numberOfLines = 0;
    }*/
    _nameLbl.font = [fonts normalFontBold];
    _tryForFreeEmailLbl.font = [fonts normalFontBold];
    _tryForFreePasswordLbl.font = [fonts normalFontBold];
    _nameTxtFld.font = [fonts normalFont];
    _tryForFreeEmailTxtFld.font = [fonts normalFont];
    _tryForFreePasswordTxtFld.font = [fonts normalFont];
    _tryForFreeBtn.titleLabel.font = [fonts normalFontBold];
    
    //set font colors
    _signInLbl.textColor = [colors darkColor];
    _tryForFreeLbl.textColor = [colors darkColor];
    _tryForFreeBtn.titleLabel.textColor = [colors darkColor];
    
    _signInLbl.text = [[translationsModel getTranslationForKey:@"global.signintitle"] uppercaseString];
    _emailLbl.text = [[translationsModel getTranslationForKey:@"global.email"] uppercaseString];
    _passwordLbl.text = [[translationsModel getTranslationForKey:@"global.password"] uppercaseString];
    [_signInBtn setTitle:[[translationsModel getTranslationForKey:@"signin.signin_button"] uppercaseString] forState:UIControlStateNormal];
    [_signInSubmitBtn setTitle:[[translationsModel getTranslationForKey:@"signin.signin_button"] uppercaseString] forState:UIControlStateNormal];
    [_forgotPasswordBtn setTitle:[translationsModel getTranslationForKey:@"signin.forgotpassword_text"] forState:UIControlStateNormal];
    
    _tryForFreeLbl.text = [[translationsModel getTranslationForKey:@"global.tryfreetitle"] uppercaseString];
    _tryForFreeGuideLbl.text = [translationsModel getTranslationForKey:@"tryforfree.description_text"];
    _nameLbl.text = [[translationsModel getTranslationForKey:@"tryforfree.name_field"] uppercaseString];
    _tryForFreeEmailLbl.text = [[translationsModel getTranslationForKey:@"global.email"] uppercaseString];
    _tryForFreePasswordLbl.text = [[translationsModel getTranslationForKey:@"global.password"] uppercaseString];
    [_tryForFreeBtn setTitle:[[translationsModel getTranslationForKey:@"global.tryfreetitle"] uppercaseString] forState:UIControlStateNormal];
    
    [_tryForFreeGuideLbl setLineHeight];
    
    [_signInSubmitBtn setTitleColor:[colors blueColor] forState:UIControlStateNormal];
    
    _signInBtn.hidden = YES;
    _signInView.hidden = NO;
    _tryForFreeBtn.hidden = NO;
    _tryForFreeView.hidden = YES;
    
    _prevBtn.hidden = YES;
    _tryForFreePasswordLbl.hidden = YES;
    _tryForFreePasswordTxtFld.hidden = YES;
    
}

#pragma UITextField Delegate
-(BOOL) textFieldShouldReturn: (UITextField *) textField {
    [textField resignFirstResponder];
    return YES;
}

- (IBAction)showSignIn:(id)sender{
    [self.view endEditing:YES];
    
    _signInBtn.hidden = YES;
    _signInView.hidden = NO;
    _tryForFreeBtn.hidden = NO;
    _tryForFreeView.hidden = YES;
    
    [animations zoomOutAnimationForView:_signInView];
}

- (IBAction)showTryForFree:(id)sender{
    [self.view endEditing:YES];
    
    _signInBtn.hidden = NO;
    _signInView.hidden = YES;
    _tryForFreeBtn.hidden = YES;
    _tryForFreeView.hidden = NO;
    
    [animations zoomOutAnimationForView:_tryForFreeView];
}

- (IBAction)tryForFreeNext:(id)sender{
    [self.view endEditing:YES];
    
    //make sure to set back the style
    [self initInputStyle];
    
    //make sure toast is dismissed before firing it back
    [[ToastView sharedInstance] dismiss];
    
    if ([_prevBtn isHidden]) {
        if ([_nameTxtFld validate]&[_tryForFreeEmailTxtFld validate]) {
            
            _nameLbl.hidden = YES;
            _nameTxtFld.hidden = YES;
            _tryForFreeEmailLbl.hidden = YES;
            _tryForFreeEmailTxtFld.hidden = YES;
            _tryForFreePasswordLbl.hidden = NO;
            _tryForFreePasswordTxtFld.hidden = NO;
            _prevBtn.hidden = NO;
            
            _tryForFreeGuideLbl.text = [translationsModel getTranslationForKey:@"tryforfreepw.description_text"];
            
            return;
        }
        
        /**
         * show error message and style
         */
        [self showErrors];
    }else{
        if ([_tryForFreePasswordTxtFld validate]) {
            
            [DejalBezelActivityView activityViewForView:self.view];
            [[UserServices sharedInstance] createUser:[self parameters] withCompletion:^(NSError *error, int statusCode) {
                [DejalBezelActivityView removeViewAnimated:YES];
                
                if(statusCode == NoInternetErrorStatusCode || statusCode == SlowInternetErrorStatusCode) {
                    [[NetworkManager sharedInstance] showConnectionErrorInViewController:self statusCode:statusCode];
                    self->lastApiCall = UserServicesApi_CreateUser;
                    return;
                }
                
                self->lastApiCall = 0;
                
                //account created
                if (statusCode == 201 || statusCode == 200) {
                    
                    //do not show onboarding anymore
                    FINISH_ONBOARDING(true);
                    
                    [self->helper saveToKeychainUsername:self->_tryForFreeEmailTxtFld.text
                                             andPassword:self->_tryForFreePasswordTxtFld.text];
                    
                    //add user's name preference
                    //NSDictionary *params = @{ @"newPreferences": @[@{@"name":@"user.name", @"value": self->_nameTxtFld.text}] };
                    //[[UserServices sharedInstance] createUserPreferences:params withCompletion:^(NSError *error, int statusCode) {
                        //NSLog(@"Finished updating preferences = %i", statusCode);
                    //}];
                    //end
                    
                    ActivationViewController *vc = [[ActivationViewController alloc] initWithNibName:@"ActivationViewController" bundle:nil];
                    vc.userName = self->_tryForFreeEmailTxtFld.text;
                    vc.userPassword = self->_tryForFreePasswordTxtFld.text;
                    [self.navigationController pushViewController:vc animated:YES];
                    
                    return;
                }
                
                //email exist already
                if(statusCode == 409 || statusCode == 422){
                    /*NSMutableArray *errmsgs = [NSMutableArray new];
                    
                    NSError *err;
                    NSDictionary*errorJson = [NSJSONSerialization JSONObjectWithData:error.userInfo[@"com.alamofire.serialization.response.error.data"]
                                                                         options:kNilOptions
                                                                           error:&err];
                    if(errorJson && errorJson[@"errors"]){
                        if(errorJson[@"errors"][@"email"]){
                            [errmsgs addObject:[self->translationsModel getTranslationForKey:@"info.emailexist"]];
                        }
                        if(errorJson[@"errors"][@"password"]){
                            [errmsgs addObjectsFromArray:[errorJson[@"errors"][@"password"] mutableCopy]];
                        }
                    }*/
                    //
                    
                    NSString *title = [self->translationsModel getTranslationForKey:@"info.error"];
                    NSString *msg = [self->translationsModel getTranslationForKey:@"info.emailexist"];
                    //NSString *msg = [errmsgs componentsJoinedByString:@"\n"];//
                    
                    CustomAlertView *alert = [CustomAlertView sharedInstance];
                    [alert showAlertInViewController:self
                                           withTitle:title
                                             message:msg
                                   cancelButtonTitle:[[TranslationsModel sharedInstance] getTranslationForKey:@"global.rateokay"]
                                     doneButtonTitle:nil];
                    [alert setCancelBlock:^(id result) {
                        NSLog(@"Cancel");
                    }];
                    return;
                }
                
                //there is error on the api side
                [[NetworkManager sharedInstance] showApiErrorInViewController:self error:error];
                
            }];
            return;
        }
        
        /**
         * show error message and style
         */
        [self showErrors];
    }
    
}

- (IBAction)tryForFreePrev:(id)sender{
    _nameLbl.hidden = NO;
    _nameTxtFld.hidden = NO;
    _tryForFreeEmailLbl.hidden = NO;
    _tryForFreeEmailTxtFld.hidden = NO;
    _tryForFreePasswordLbl.hidden = YES;
    _tryForFreePasswordTxtFld.hidden = YES;
    _prevBtn.hidden = YES;
    
    _tryForFreeGuideLbl.text = [translationsModel getTranslationForKey:@"tryforfree.description_text"];
    
}

- (IBAction)signIn:(id)sender{
    [self.view endEditing:YES];
    
    //make sure to set back the style
    [self initInputStyle];
    
    //make sure toast is dismissed before firing it back
    [[ToastView sharedInstance] dismiss];
    
    if ([_emailTxtFld validate]&[_passwordTxtFld validate]) {
        [DejalBezelActivityView activityViewForView:self.view];
        [[UserServices sharedInstance] signInWithUsername:_emailTxtFld.text andPassword:_passwordTxtFld.text withCompletion:^(NSError *error, int statusCode, NSDictionary *overview) {
            [DejalBezelActivityView removeViewAnimated:YES];
            
            if(statusCode == NoInternetErrorStatusCode || statusCode == SlowInternetErrorStatusCode) {
                [[NetworkManager sharedInstance] showConnectionErrorInViewController:self statusCode:statusCode];
                self->lastApiCall = UserServicesApi_SignIn;
                return;
            }
            
            self->lastApiCall = 0;
            
            //user logged in
            if (statusCode == 201 || statusCode == 200) {
                NSDictionary *userAccountOverview = overview;
                BOOL userBlocked = [overview[@"blocked"] boolValue];
                BOOL userActivated = [overview[@"activated"] boolValue];
                
                //if user is blocked by admin
                if(userAccountOverview && userBlocked && userActivated){
                    //show custom alert and then logout
                    CustomAlertView *alert = [CustomAlertView sharedInstance];
                    [alert showAlertInViewController:self
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
                    for (UIViewController *vc in self->delegate.tabBarController.navigationController.viewControllers){
                        if ([vc isKindOfClass:[SignInViewController class]]){
                            [self->delegate.tabBarController.navigationController popToViewController:vc animated:YES];
                            return;
                        }
                    }
                    return;
                }
                
                
                [self->helper setUpTabBarControllerFrom:self initialIndex:0];
                [self->helper saveToKeychainUsername:self->_emailTxtFld.text andPassword:self->_passwordTxtFld.text];
                self->_emailTxtFld.text = @"";
                self->_passwordTxtFld.text = @"";
                
                //user is not activated after 24hours registration
                if(userAccountOverview && userBlocked && !userActivated){
                    ActivationViewController *vc = [[ActivationViewController alloc] initWithNibName:@"ActivationViewController" bundle:nil];
                    vc.isForResendActivation = true;
                    [self->delegate.tabBarController presentViewController:vc animated:NO completion:nil];
                    return;
                }
                
                [[ModulesServices sharedInstance] getFocusAreaWithCompletion:nil];
                [[ModulesServices sharedInstance] getTagsWithCompletion:nil];
                [[UserServices sharedInstance] getUserInfoWithCompletion:nil];
                
                return;
            }
            
            //let user know that his account is blocked or not exist yet
            if(statusCode == 401 || statusCode == 403){
                NSString *title = [self->translationsModel getTranslationForKey:@"info.error"];
                NSString *msg = @"";
                
                switch (statusCode) {
                    case 401:
                        msg = [self->translationsModel getTranslationForKey:@"info.usernotexist"];
                        break;
                    case 403:
                        msg = [self->translationsModel getTranslationForKey:@"info.userblocked"];
                        break;
                    default:
                        break;
                }
                
                CustomAlertView *alert = [CustomAlertView sharedInstance];
                [alert showAlertInViewController:self
                                       withTitle:title
                                         message:msg
                               cancelButtonTitle:[[TranslationsModel sharedInstance] getTranslationForKey:@"global.rateokay"]
                                 doneButtonTitle:nil];
                [alert setCancelBlock:^(id result) {
                    NSLog(@"Error");
                }];
                return;
            }
            
            if(error){
                //there is error on the api side
                [[NetworkManager sharedInstance] showApiErrorInViewController:self error:error];
            }
        }];
        return;
    }
    
    /**
     * show error message and style
     */
    [self showErrors];
}

- (void)initInputStyle{
    [helper setFlexibleBorderIn:_emailTxtFld
                      withColor:[UIColor grayColor]
                 topBorderWidth:0.0f
                leftBorderWidth:0.0
               rightBorderWidth:0.0
              bottomBorderWidth:0.5f];
    [helper setFlexibleBorderIn:_passwordTxtFld
                      withColor:[UIColor grayColor]
                 topBorderWidth:0.0f
                leftBorderWidth:0.0
               rightBorderWidth:0.0
              bottomBorderWidth:0.5f];
    
    [helper setFlexibleBorderIn:_nameTxtFld
                      withColor:[UIColor grayColor]
                 topBorderWidth:0.0f
                leftBorderWidth:0.0
               rightBorderWidth:0.0
              bottomBorderWidth:0.5f];
    [helper setFlexibleBorderIn:_tryForFreeEmailTxtFld
                      withColor:[UIColor grayColor]
                 topBorderWidth:0.0f
                leftBorderWidth:0.0
               rightBorderWidth:0.0
              bottomBorderWidth:0.5f];
    [helper setFlexibleBorderIn:_tryForFreePasswordTxtFld
                      withColor:[UIColor grayColor]
                 topBorderWidth:0.0f
                leftBorderWidth:0.0
               rightBorderWidth:0.0
              bottomBorderWidth:0.5f];
    
    _emailLbl.textColor = [UIColor lightGrayColor];
    _passwordLbl.textColor = [UIColor lightGrayColor];
    _nameLbl.textColor = [UIColor lightGrayColor];
    _tryForFreeEmailLbl.textColor = [UIColor lightGrayColor];
    _tryForFreePasswordLbl.textColor = [UIColor lightGrayColor];
}

- (void)showErrors{
    NSString *message = [translationsModel getTranslationForKey:@"info.someinputdatamissing"];
    if(_signInView.hidden == NO){
        if(![_emailTxtFld validate]){
            [helper setFlexibleBorderIn:_emailTxtFld
                              withColor:[colors warning]
                         topBorderWidth:0.0f
                        leftBorderWidth:0.0
                       rightBorderWidth:0.0
                      bottomBorderWidth:0.5f];
            _emailLbl.textColor = [colors warning];
        }
        if(![_passwordTxtFld validate]){
            [helper setFlexibleBorderIn:_passwordTxtFld
                              withColor:[colors warning]
                         topBorderWidth:0.0f
                        leftBorderWidth:0.0
                       rightBorderWidth:0.0
                      bottomBorderWidth:0.5f];
            _passwordLbl.textColor = [colors warning];
        }
    }
    
    if(_tryForFreeView.hidden == NO){
        if(![_nameTxtFld validate]){
            [helper setFlexibleBorderIn:_nameTxtFld
                              withColor:[colors warning]
                         topBorderWidth:0.0f
                        leftBorderWidth:0.0
                       rightBorderWidth:0.0
                      bottomBorderWidth:0.5f];
            _nameLbl.textColor = [colors warning];
        }
        
        if(![_tryForFreeEmailTxtFld validate]){
            [helper setFlexibleBorderIn:_tryForFreeEmailTxtFld
                              withColor:[colors warning]
                         topBorderWidth:0.0f
                        leftBorderWidth:0.0
                       rightBorderWidth:0.0
                      bottomBorderWidth:0.5f];
            _tryForFreeEmailLbl.textColor = [colors warning];
        }
    }
    
    if(_tryForFreePasswordTxtFld.hidden == NO){
        if(![_tryForFreePasswordTxtFld validate]){
            [helper setFlexibleBorderIn:_tryForFreePasswordTxtFld
                              withColor:[colors warning]
                         topBorderWidth:0.0f
                        leftBorderWidth:0.0
                       rightBorderWidth:0.0
                      bottomBorderWidth:0.5f];
            _tryForFreePasswordLbl.textColor = [colors warning];
        }
    }
    
    [[ToastView sharedInstance] showInViewController:self
                                             message:message
                                        includeError:nil
                                   enableAutoDismiss:true
                                           showRetry:false];
}

-(NSDictionary *)parameters{
    return @{
                 @"name": _nameTxtFld.text,
                 @"email": _tryForFreeEmailTxtFld.text,
                 @"password": _tryForFreePasswordTxtFld.text,
                 @"password_confirmation": _tryForFreePasswordTxtFld.text
             };
}

- (IBAction)forgotPassword:(id)sender{
    ForgotPasswordViewController *vc = [[ForgotPasswordViewController alloc] initWithNibName:@"ForgotPasswordViewController" bundle:nil];
    [self.navigationController pushViewController:vc animated:NO];
}

@end
