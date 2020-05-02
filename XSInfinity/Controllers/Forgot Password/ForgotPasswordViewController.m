//
//  ForgotPasswordViewController.m
//  XSInfinity
//
//  Created by Joseph Marvin Magdadaro on 6/11/18.
//  Copyright © 2018 Joseph Marvin Magdadaro. All rights reserved.
//

#import "ForgotPasswordViewController.h"
#import "Animations.h"
#import "Helper.h"
#import "Fonts.h"
#import "Colors.h"
#import "TranslationsModel.h"
#import "CustomAlertView.h"
#import "UserServices.h"
#import "SignInViewController.h"
#import "TextFieldValidator.h"
#import "DejalActivityView.h"
#import "NetworkManager.h"
#import "ToastView.h"

@interface ForgotPasswordViewController ()<NetworkManagerDelegate, ToastViewDelegate>{
    Helper *helper;
    Fonts *fonts;
    Colors *colors;
    TranslationsModel *translationsModel;
    BOOL didLayoutReloaded;
    
    UserServicesApi lastApiCall;
}
@property (weak, nonatomic) IBOutlet UIView *contentView;
@property (weak, nonatomic) IBOutlet UILabel *titleLbl;
@property (weak, nonatomic) IBOutlet UILabel *guideLbl;
@property (weak, nonatomic) IBOutlet TextFieldValidator *userNameTxtFld;
@property (weak, nonatomic) IBOutlet UILabel *userNameLbl;
@property (weak, nonatomic) IBOutlet TextFieldValidator *passwordTxtFld;
@property (weak, nonatomic) IBOutlet UILabel *passwordLbl;
@property (weak, nonatomic) IBOutlet UIButton *submitBtn;
@property (weak, nonatomic) IBOutlet UIButton *cancelBtn;
@property (weak, nonatomic) IBOutlet UIButton *nextBtn;

@end

@implementation ForgotPasswordViewController

-(void)viewWillAppear:(BOOL)animated{
    [super viewWillAppear:YES];
    self.navigationController.navigationBar.hidden = YES;
    
    [[Animations sharedAnimations] zoomOutAnimationForView:_contentView];
}

- (void)viewDidLoad {
    [super viewDidLoad];
    self.navigationController.navigationBar.hidden = YES;
    
    helper = [Helper sharedHelper];
    fonts = [Fonts sharedFonts];
    colors = [Colors sharedColors];
    translationsModel = [TranslationsModel sharedInstance];
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
        case UserServicesApi_SendForgotPassword:
            [self submit:nil];
            break;
        case UserServicesApi_SetNewPassword:
            [self next:nil];
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

- (void)setupUserInterface{
    [_contentView layoutIfNeeded];
    
    [helper addShadowIn:_contentView withColor:[UIColor darkGrayColor] andSetCornerRadiusTo:5.0];
    
    [self initInputStyle];
    
    _titleLbl.font = [fonts headerFont];
    _titleLbl.textColor = [colors darkColor];
    _guideLbl.font = [fonts normalFont];
    _userNameLbl.font = [fonts normalFontBold];
    _passwordLbl.font = [fonts normalFont];
    _userNameTxtFld.font = [fonts normalFont];
    _passwordTxtFld.font = [fonts normalFont];
    _submitBtn.titleLabel.font = [fonts normalFontBold];
    _cancelBtn.titleLabel.font = [fonts normalFont];
    
    _titleLbl.text = [[translationsModel getTranslationForKey:@"forgotpw.password_title"] uppercaseString];
    _userNameLbl.text = [[translationsModel getTranslationForKey:@"global.email"] uppercaseString];
    _passwordLbl.text = [[translationsModel getTranslationForKey:@"newpassword.newpassword_field"] uppercaseString];
    [_submitBtn setTitle:[[translationsModel getTranslationForKey:@"global.submitbutton"] uppercaseString] forState:UIControlStateNormal];
    [_cancelBtn setTitle:[translationsModel getTranslationForKey:@"global.cancelbutton"] forState:UIControlStateNormal];
    
    [_submitBtn setTitleColor:[colors blueColor] forState:UIControlStateNormal];
    
    if (self.isFromDeepLink) {
        _guideLbl.text = [translationsModel getTranslationForKey:@"newpassword.description_text"];
        
        _userNameTxtFld.hidden = YES;
        _userNameLbl.hidden = YES;
        _submitBtn.hidden = YES;
        _cancelBtn.hidden = YES;
    }else{
        _guideLbl.text = [translationsModel getTranslationForKey:@"forgotpw.description_text"];
        
        _passwordTxtFld.hidden = YES;
        _passwordLbl.hidden = YES;
        _nextBtn.hidden = YES;
    }
    
    [_guideLbl setLineHeight];
    
}

#pragma UITextField Delegate
-(BOOL) textFieldShouldReturn: (UITextField *) textField {
    [textField resignFirstResponder];
    return YES;
}

- (IBAction)cancel:(id)sender{
    [self.navigationController popViewControllerAnimated:NO];
}

- (IBAction)submit:(id)sender{
    [self.view endEditing:YES];
    
    //make sure to set back the style
    [self initInputStyle];
    
    //make sure toast is dismissed before firing it back
    [[ToastView sharedInstance] dismiss];
    
    if ([_userNameTxtFld validate]) {
        [DejalBezelActivityView activityViewForView:self.view];
        [[UserServices sharedInstance] sendForgotMailToUser:_userNameTxtFld.text withCompletion:^(NSError *error, int statusCode) {
            [DejalBezelActivityView removeViewAnimated:YES];
            
            if(statusCode == NoInternetErrorStatusCode || statusCode == SlowInternetErrorStatusCode) {
                [[NetworkManager sharedInstance] showConnectionErrorInViewController:self statusCode:statusCode];
                self->lastApiCall = UserServicesApi_SendForgotPassword;
                return;
            }
            
            self->lastApiCall = 0;
            
            //Todo: implement new error popup
            //Todo: open login after successul reset
            
            NSString *title = @"Error";
            NSString *msg = @"Something went wrong";
            
            switch (statusCode) {
                case 201:
                    title = @"Success";
                    msg = @"Email Sent";
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
                NSLog(@"Cancel");
            }];    
        }];
        
        return;
    }
    
    /**
     * show error message and style
     */
    [self showErrors];
}

- (IBAction)next:(id)sender{
    [self.view endEditing:YES];
    
    //make sure to set back the style
    [self initInputStyle];
    
    //make sure toast is dismissed before firing it back
    [[ToastView sharedInstance] dismiss];
    
    if ([_passwordTxtFld validate]) {
        [DejalBezelActivityView activityViewForView:self.view];
        [[UserServices sharedInstance] setNewPassword:_passwordTxtFld.text forUser:self.userName withCode:self.code withCompletion:^(NSError *error, int statusCode) {
            [DejalBezelActivityView removeViewAnimated:YES];
            
            if(statusCode == NoInternetErrorStatusCode || statusCode == SlowInternetErrorStatusCode) {
                [[NetworkManager sharedInstance] showConnectionErrorInViewController:self statusCode:statusCode];
                self->lastApiCall = UserServicesApi_SetNewPassword;
                return;
            }
            
            self->lastApiCall = 0;
            
            //sent successfully
            if(statusCode == 201){
                NSString *title = [self->translationsModel getTranslationForKey:@"popup.successtitle"];
                NSString *msg = [self->translationsModel getTranslationForKey:@"info.pwreset"];
                
                CustomAlertView *alert = [CustomAlertView sharedInstance];
                [alert showAlertInViewController:self
                                       withTitle:title
                                         message:msg
                               cancelButtonTitle:[[TranslationsModel sharedInstance] getTranslationForKey:@"global.rateokay"]
                                 doneButtonTitle:nil];
                [alert setCancelBlock:^(id result) {
                    SignInViewController *vc = [[SignInViewController alloc] initWithNibName:@"SignInViewController" bundle:nil];
                    [self.navigationController pushViewController:vc animated:YES];
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
    [helper setFlexibleBorderIn:_userNameTxtFld
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
    
    _userNameLbl.textColor = [UIColor lightGrayColor];
    _passwordLbl.textColor = [UIColor lightGrayColor];
}

- (void)showErrors{
    NSString *message = [translationsModel getTranslationForKey:@"info.someinputdatamissing"];
    if(self.isFromDeepLink){
        if(![_passwordTxtFld validate]){
            [helper setFlexibleBorderIn:_passwordTxtFld
                              withColor:[colors warning]
                         topBorderWidth:0.0f
                        leftBorderWidth:0.0
                       rightBorderWidth:0.0
                      bottomBorderWidth:0.5f];
            _passwordLbl.textColor = [colors warning];
        }
    }else{
        if(![_userNameTxtFld validate]){
            [helper setFlexibleBorderIn:_userNameTxtFld
                              withColor:[colors warning]
                         topBorderWidth:0.0f
                        leftBorderWidth:0.0
                       rightBorderWidth:0.0
                      bottomBorderWidth:0.5f];
            _userNameLbl.textColor = [colors warning];
        }
    }
    
    [[ToastView sharedInstance] showInViewController:self
                                             message:message
                                        includeError:nil
                                   enableAutoDismiss:true
                                           showRetry:false];
}

@end
