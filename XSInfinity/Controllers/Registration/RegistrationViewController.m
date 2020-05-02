//
//  RegistrationViewController.m
//  XSInfinity
//
//  Created by Joseph Marvin Magdadaro on 5/29/18.
//  Copyright © 2018 Joseph Marvin Magdadaro. All rights reserved.
//

#import "RegistrationViewController.h"
#import <MobileCoreServices/UTCoreTypes.h>
#import "Helper.h"
#import "Fonts.h"
#import "Colors.h"
#import "TranslationsModel.h"
#import "CustomAlertView.h"
#import "TPKeyboardAvoidingScrollView.h"
#import "TextFieldValidator.h"
#import "DejalActivityView.h"
#import "UserServices.h"
#import "CustomCropper.h"
#import "NetworkManager.h"
#import "ToastView.h"

@interface RegistrationViewController ()<UIImagePickerControllerDelegate, UINavigationControllerDelegate, CustomCropperDelegate, NetworkManagerDelegate, ToastViewDelegate>{
    Helper *helper;
    Fonts *fonts;
    Colors *colors;
    TranslationsModel *translationsModel;
    CustomAlertView *customAlertView;
    BOOL didLayoutReloaded;
    BOOL isMale;
    int currentViewTag;
    
    UserServicesApi lastApiCall;
}

@property (nonatomic, strong) IBOutletCollection(UIView) NSArray *views;
@property (nonatomic, strong) IBOutletCollection(UILabel) NSArray *pageLabels;
@property (nonatomic, strong) IBOutletCollection(UIButton) NSArray *genderButtons;

@property (nonatomic, weak) IBOutlet UIView *contentView;
@property (weak, nonatomic) IBOutlet UILabel *titleLbl;
@property (weak, nonatomic) IBOutlet UIButton *leftBtn;
@property (weak, nonatomic) IBOutlet UIButton *rightBtn;

@property (weak, nonatomic) IBOutlet UIButton *uploadImageBtn;
@property (weak, nonatomic) IBOutlet UILabel *uploadImageLbl;

@property (weak, nonatomic) IBOutlet UILabel *nameLbl;
@property (weak, nonatomic) IBOutlet UILabel *streetLbl;
@property (weak, nonatomic) IBOutlet UILabel *cityLbl;
@property (weak, nonatomic) IBOutlet UILabel *zipLbl;
@property (weak, nonatomic) IBOutlet UILabel *countryLbl;
@property (weak, nonatomic) IBOutlet UILabel *wechatLbl;
@property (weak, nonatomic) IBOutlet UILabel *maleLbl;
@property (weak, nonatomic) IBOutlet UILabel *femaleLbl;
@property (weak, nonatomic) IBOutlet TextFieldValidator *nameTxtFld;
@property (weak, nonatomic) IBOutlet TextFieldValidator *streetTxtFld;
@property (weak, nonatomic) IBOutlet TextFieldValidator *cityTxtFld;
@property (weak, nonatomic) IBOutlet TextFieldValidator *zipTxtFld;
@property (weak, nonatomic) IBOutlet TextFieldValidator *countryTxtFld;
@property (weak, nonatomic) IBOutlet TextFieldValidator *wechatTxtFld;
@property (weak, nonatomic) IBOutlet UIButton *maleBtn;
@property (weak, nonatomic) IBOutlet UIButton *femaleBtn;

@property (weak, nonatomic) IBOutlet UIImageView *notifyImageView;
@property (weak, nonatomic) IBOutlet UITextView *notifyTxtView;

@property (weak, nonatomic) IBOutlet UILabel *completeLbl;

@end

@implementation RegistrationViewController

-(void)viewWillAppear:(BOOL)animated{
    [super viewWillAppear:YES];
    self.navigationController.navigationBar.hidden = YES;
    
}

- (void)viewDidLoad {
    [super viewDidLoad];
    self.navigationController.navigationBar.hidden = YES;
    
    helper = [Helper sharedHelper];
    fonts = [Fonts sharedFonts];
    colors = [Colors sharedColors];
    translationsModel = [TranslationsModel sharedInstance];
    customAlertView = [CustomAlertView sharedInstance];
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
        case UserServicesApi_CreateUserPreferences:
            [self savePreferences];
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
    
    //Content view
    [_contentView layoutIfNeeded];
    [helper addDropShadowIn:_contentView withColor:[UIColor darkGrayColor] andSetCornerRadiusTo:5.0f];
    
    [self initInputStyle];
    
    _titleLbl.font = [fonts headerFont];
    _nameLbl.font = [fonts normalFontBold];
    _streetLbl.font = [fonts normalFontBold];
    _cityLbl.font = [fonts normalFontBold];
    _zipLbl.font = [fonts normalFontBold];
    _countryLbl.font = [fonts normalFontBold];
    _wechatLbl.font = [fonts normalFontBold];
    _maleLbl.font = [fonts normalFontBold];
    _femaleLbl.font = [fonts normalFontBold];
    _completeLbl.font = [fonts normalFont];
    
    _uploadImageLbl.font = [fonts titleFont];
    
    _nameTxtFld.font = [fonts normalFont];
    _streetTxtFld.font = [fonts normalFont];
    _cityTxtFld.font = [fonts normalFont];
    _zipTxtFld.font = [fonts normalFont];
    _countryTxtFld.font = [fonts normalFont];
    _wechatTxtFld.font = [fonts normalFont];
    _notifyTxtView.font = [fonts normalFont];
    
    _titleLbl.text = [translationsModel getTranslationForKey:@"regstep1a.title"];
    _nameLbl.text = [[translationsModel getTranslationForKey:@"regstep2.firstlastname"] uppercaseString];
    _streetLbl.text = [[translationsModel getTranslationForKey:@"regstep2.street"] uppercaseString];
    _cityLbl.text = [[translationsModel getTranslationForKey:@"regstep2.city"] uppercaseString];
    _zipLbl.text = [[translationsModel getTranslationForKey:@"regstep2.zip"] uppercaseString];
    _countryLbl.text = [[translationsModel getTranslationForKey:@"regstep2.country"] uppercaseString];
    _wechatLbl.text = [[translationsModel getTranslationForKey:@"regstep2.wechatname"] uppercaseString];
    _maleLbl.text = [[translationsModel getTranslationForKey:@"regstep2.male"] uppercaseString];
    _femaleLbl.text = [[translationsModel getTranslationForKey:@"regstep2.female"] uppercaseString];
    _completeLbl.text = [translationsModel getTranslationForKey:@"regfinal.description"];
    _notifyTxtView.text = [translationsModel getTranslationForKey:@"regstep3.description"];
    
    _leftBtn.hidden = YES;
    
    currentViewTag = 0;
    for (UIView *view in _views) {
        if (view.tag == 0) {
            view.hidden = NO;
        }else{
            view.hidden = YES;
        }
    }
    
    UIButton *btn = _genderButtons[0];
    [self selectGender:btn];
}

- (IBAction)prev:(id)sender {
    [self.view endEditing:YES];
    
    if (currentViewTag == 0)
        return;
    
    UIView *currentView =_views[currentViewTag];
    currentView.hidden = YES;
    
    UIView *prevView = _views[currentViewTag-1];
    prevView.hidden = NO;
    
    currentViewTag = (int)prevView.tag;
    
    if (currentViewTag == 0){
        _leftBtn.hidden = YES;
    }else{
        _leftBtn.hidden = NO;
    }
    
    [self updatePageControl];
}

- (IBAction)next:(id)sender {
    if (currentViewTag == ([_views count]-1))
        return;
    
    if (currentViewTag == 1){
        [self savePreferences];
        
    }else{
        [self goToNextPage];
        
    }
    
}

- (void)goToNextPage{
    UIView *currentView =_views[currentViewTag];
    currentView.hidden = YES;
    
    UIView *nextView = _views[currentViewTag+1];
    nextView.hidden = NO;
    
    if (nextView.tag == 3){
        _leftBtn.hidden = YES;
    }else{
        _leftBtn.hidden = NO;
    }
    
    [self updatePageControl];
    
    currentViewTag = (int)nextView.tag;
}

- (void)updatePageControl{
    for (UILabel *lbl in _pageLabels) {
        if (lbl.tag == currentViewTag || (currentViewTag == ([_views count]-1) && lbl.tag == ([_pageLabels count]-1))) {
            lbl.textColor = [UIColor blackColor];
            lbl.backgroundColor = [UIColor whiteColor];
        }else{
            lbl.textColor = [UIColor whiteColor];
            lbl.backgroundColor = [UIColor colorWithRed:255.0f green:255.0f blue:255.0f alpha:0.4];
        }
    }
}

-(BOOL) textFieldShouldReturn: (UITextField *) textField {
    [textField resignFirstResponder];
    return YES;
}

- (IBAction)selectGender:(id)sender{
    isMale = [sender tag];
    
    for (UIButton *btn in _genderButtons){
        
        float cornerRadius = CGRectGetWidth(btn.frame)/4;
        if (btn.tag == [sender tag]) {
            btn.backgroundColor = [colors orangeColor];
            [btn.layer setBorderWidth:0];
            btn.layer.cornerRadius = cornerRadius;
            btn.clipsToBounds = YES;
        }else{
            btn.backgroundColor = [UIColor clearColor];
            [btn.layer setBorderWidth:1.0];
            [btn.layer setBorderColor:[[UIColor blackColor] CGColor]];
            btn.layer.cornerRadius = cornerRadius;
            btn.clipsToBounds = YES;
        }
    }
}

- (IBAction)selectImage:(id)sender {
    __unsafe_unretained typeof(self) weakSelf = self;
    [customAlertView showAlertInViewController:self
                                     withTitle:[translationsModel getTranslationForKey:@"info.addphoto"]
                                       message:[translationsModel getTranslationForKey:@"info.addphotofrom"]
                             cancelButtonTitle:[translationsModel getTranslationForKey:@"info.camera"]
                               doneButtonTitle:[translationsModel getTranslationForKey:@"info.photolibrary"]];
    [customAlertView setCancelBlock:^(id result) {
        [weakSelf takePhoto];
    }];
    [customAlertView setDoneBlock:^(id result) {
        [weakSelf chooseImageFromLib];
    }];
}

- (void)chooseImageFromLib {
    
    UIImagePickerControllerSourceType source = [UIImagePickerController isSourceTypeAvailable:UIImagePickerControllerSourceTypePhotoLibrary] ? UIImagePickerControllerSourceTypePhotoLibrary: UIImagePickerControllerSourceTypeSavedPhotosAlbum;
    
    UIImagePickerController *mediaUI = [[UIImagePickerController alloc] init];
    mediaUI.sourceType = source;
    //mediaUI.mediaTypes = [UIImagePickerController availableMediaTypesForSourceType:source];
    mediaUI.mediaTypes = [[NSArray alloc] initWithObjects: (NSString *) kUTTypeImage, nil];
    mediaUI.allowsEditing = NO;
    mediaUI.delegate = self;
    mediaUI.modalPresentationStyle = UIModalPresentationFullScreen;
    
    [self presentViewController: mediaUI animated: YES completion:nil];
}

- (void)takePhoto {
    
    UIImagePickerControllerSourceType source = [UIImagePickerController isSourceTypeAvailable:UIImagePickerControllerSourceTypeCamera] ? UIImagePickerControllerSourceTypeCamera : UIImagePickerControllerSourceTypeSavedPhotosAlbum;
    UIImagePickerController *photoPickerController = [[UIImagePickerController alloc] init];
    photoPickerController.sourceType = source;
    //photoPickerController.mediaTypes = [UIImagePickerController availableMediaTypesForSourceType:source];
    photoPickerController.mediaTypes = [[NSArray alloc] initWithObjects: (NSString *) kUTTypeImage, nil];
    photoPickerController.allowsEditing = NO;
    photoPickerController.delegate = self;
    photoPickerController.modalPresentationStyle = UIModalPresentationFullScreen;
    [self presentViewController:photoPickerController animated:YES completion:nil];
    
}

#pragma mark - Image Picker Delegate -
- (void)imagePickerController:(UIImagePickerController *)picker didFinishPickingMediaWithInfo:(NSDictionary<NSString *,id> *)info{
    NSString *mediaType = info[UIImagePickerControllerMediaType];
    UIImage *image = info[UIImagePickerControllerOriginalImage];
    
    [self dismissViewControllerAnimated:YES completion:^{
        [self showCropperWithImage:image];
    }];
}

- (void)imagePickerControllerDidCancel:(UIImagePickerController *)picker
{
    [self dismissViewControllerAnimated:YES completion:nil];
}

- (void)showCropperWithImage:(UIImage *)image {
    
    CustomCropper *vc = [[CustomCropper alloc] init];
    
    vc.view.backgroundColor = [UIColor clearColor];
    vc.modalPresentationStyle = UIModalPresentationOverCurrentContext;
    
    vc.image = image;
    vc.dismissDelegate = self;
    
    [self presentViewController:vc animated:NO completion:nil];
}

#pragma CustomCropperDelegate
- (void)croppingImageDone:(UIImage *)croppedImg{
    _uploadImageBtn.backgroundColor = [UIColor clearColor];
    _uploadImageBtn.layer.masksToBounds = YES;
    _uploadImageBtn.layer.cornerRadius = CGRectGetWidth(self.uploadImageBtn.frame) / 2;
    _uploadImageBtn.contentMode = UIViewContentModeScaleAspectFit;
    [_uploadImageBtn setImage:croppedImg forState:UIControlStateNormal];
}

- (void)savePreferences{
    [self.view endEditing:YES];
    
    //make sure to set back the style
    [self initInputStyle];
    
    //make sure toast is dismissed before firing it back
    [[ToastView sharedInstance] dismiss];
    
    if ([_nameTxtFld validate]&[_streetTxtFld validate]&[_cityTxtFld validate]&[_zipTxtFld validate]&[_countryTxtFld validate]) {

        [DejalBezelActivityView activityViewForView:self.view];
        [[UserServices sharedInstance] createUserPreferences:[self parameters] withCompletion:^(NSError *error, int statusCode) {
            [DejalBezelActivityView removeViewAnimated:YES];
            
            if(statusCode == NoInternetErrorStatusCode || statusCode == SlowInternetErrorStatusCode) {
                [[NetworkManager sharedInstance] showConnectionErrorInViewController:self statusCode:statusCode];
                self->lastApiCall = UserServicesApi_CreateUserPreferences;
                return;
            }
            
            self->lastApiCall = 0;
            
            if (statusCode == 201) {
                [self goToNextPage];
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
    [helper setFlexibleBorderIn:_nameTxtFld
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
    [helper setFlexibleBorderIn:_wechatTxtFld
                      withColor:[UIColor blackColor]
                 topBorderWidth:0.0f
                leftBorderWidth:0.0
               rightBorderWidth:0.0
              bottomBorderWidth:1.0f];
    
    _nameLbl.textColor = [UIColor blackColor];
    _streetLbl.textColor = [UIColor blackColor];
    _cityLbl.textColor = [UIColor blackColor];
    _zipLbl.textColor = [UIColor blackColor];
    _countryLbl.textColor = [UIColor blackColor];
    _wechatLbl.textColor = [UIColor blackColor];
}

- (void)showErrors{
    UIView *infoView = _views[1];
    NSString *message = [translationsModel getTranslationForKey:@"info.someinputdatamissing"];
    if(infoView.hidden == NO){
        if(![_nameTxtFld validate]){
            [helper setFlexibleBorderIn:_nameTxtFld
                              withColor:[colors warning]
                         topBorderWidth:0.0f
                        leftBorderWidth:0.0
                       rightBorderWidth:0.0
                      bottomBorderWidth:1.0f];
            _nameLbl.textColor = [colors warning];
        }
        
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
        
        if(![_wechatTxtFld validate]){
            [helper setFlexibleBorderIn:_wechatTxtFld
                              withColor:[colors warning]
                         topBorderWidth:0.0f
                        leftBorderWidth:0.0
                       rightBorderWidth:0.0
                      bottomBorderWidth:1.0f];
            _wechatLbl.textColor = [colors warning];
        }
    }
    
    [[ToastView sharedInstance] showInViewController:self
                                             message:message
                                        includeError:nil
                                   enableAutoDismiss:true
                                           showRetry:false];
}

- (NSDictionary *)parameters{
    NSDictionary *params = @{
                             @"newPreferences": @[
                                         @{
                                             @"name": @"user.name",
                                             @"value": _nameTxtFld.text
                                         },
                                         @{
                                             @"name": @"user.street",
                                             @"value": _streetTxtFld.text
                                             },
                                         @{
                                             @"name": @"user.city",
                                             @"value": _cityTxtFld.text
                                             },
                                         @{
                                             @"name": @"user.areaCode",
                                             @"value": _zipTxtFld.text
                                             },
                                         @{
                                             @"name": @"user.country",
                                             @"value": _countryTxtFld.text
                                             },
                                         @{
                                             @"name": @"user.wechatName",
                                             @"value": _wechatTxtFld.text
                                             }
                                     ]
                             };
    
    return params;
}

@end
