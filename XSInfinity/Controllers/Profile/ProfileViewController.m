//
//  ProfileViewController.m
//  XSInfinity
//
//  Created by Joseph Marvin Magdadaro on 7/19/18.
//  Copyright © 2018 Jerk Magz. All rights reserved.
//

#import "ProfileViewController.h"
#import <SDWebImage/UIImageView+WebCache.h>
#import <MobileCoreServices/UTCoreTypes.h>
#import "NetworkManager.h"
#import "DejalActivityView.h"
#import "AppDelegate.h"
#import "Helper.h"
#import "Fonts.h"
#import "Colors.h"
#import "TranslationsModel.h"
#import "Animations.h"
#import "CustomAlertView.h"
#import "CustomCropper.h"
#import "GalleryCropper.h"
#import "GalleryCollectionViewCell.h"
#import "NoGalleryCollectionViewCell.h"
#import "UserServices.h"
#import "HeadUpObj.h"
#import "UserMediaServices.h"
#import "SettingsViewController.h"
#import "FaqViewController.h"
#import "SignInViewController.h"
#import "ExercisesListViewController.h"
#import "SkeletonView.h"
#import "UserInfo.h"
#import "UserModel.h"
#import "Gallery.h"
#import "ToastView.h"

@interface ProfileViewController ()<UIImagePickerControllerDelegate, UINavigationControllerDelegate, GalleryCropperDelegate, SettingsViewControllerDelegate, CustomCropperDelegate, NetworkManagerDelegate, ToastViewDelegate>{
    Helper *helper;
    Fonts *fonts;
    Colors *colors;
    TranslationsModel *translationsModel;
    Animations *animations;
    AppDelegate *delegate;
    SkeletonView *skeletonView;
    UserInfo *userInfo;
    NSArray *galleryList;
    int apiCounter;
    float lastCoverImageMaxY;
    
    BOOL didLayoutReloaded;
    BOOL isListView;
    BOOL isProfilePic;
    BOOL didShowConnectionError;
    BOOL didRequestFromRemote;
    
    UserMediaServicesApi lastApiCall;
    NSDictionary *lastApiParams;
}
@property (weak, nonatomic) IBOutlet UIImageView *coverImageView;
@property (weak, nonatomic) IBOutlet NSLayoutConstraint *coverImageViewTopConstraint;
@property (weak, nonatomic) IBOutlet NSLayoutConstraint *coverImageViewWidthConstraint;

@property (weak, nonatomic) IBOutlet UIScrollView *scrollView;
@property (weak, nonatomic) IBOutlet UIView *contentView;

@property (nonatomic, assign) CGFloat lastContentOffset;

@property (weak, nonatomic) IBOutlet UIImageView *profileImageView;
@property (weak, nonatomic) IBOutlet UILabel *nameLbl;
@property (weak, nonatomic) IBOutlet UILabel *countryLbl;
@property (weak, nonatomic) IBOutlet UIButton *settingsBtn;
@property (weak, nonatomic) IBOutlet UIButton *pinBtn;

@property (weak, nonatomic) IBOutlet UIView *performanceView;
@property (weak, nonatomic) IBOutlet UILabel *performanceLbl;
@property (weak, nonatomic) IBOutlet UILabel *minimumExerciseLbl;
@property (weak, nonatomic) IBOutlet UILabel *minimumHabitsLbl;
@property (weak, nonatomic) IBOutlet UIButton *minimumExerciseThumbBtn;
@property (weak, nonatomic) IBOutlet UIButton *minimumHabitsThumbBtn;

@property (weak, nonatomic) IBOutlet UIView *bookmarkedView;
@property (weak, nonatomic) IBOutlet UILabel *bookmarkedLbl;
@property (weak, nonatomic) IBOutlet UILabel *faqsLbl;
@property (weak, nonatomic) IBOutlet UIButton *heartBtn;
@property (weak, nonatomic) IBOutlet UIButton *questionMarkBtn;

@property (weak, nonatomic) IBOutlet UILabel *galleryLbl;
@property (weak, nonatomic) IBOutlet UIButton *addBtn;

@property (weak, nonatomic) IBOutlet UICollectionView *collectionView;

@end

@implementation ProfileViewController

-(void)viewWillAppear:(BOOL)animated{
    [super viewWillAppear:YES];
    self.navigationController.navigationBar.hidden = YES;
    float scrollOffset = _scrollView.contentOffset.y;
    
    if (scrollOffset <= 0)
        [[Animations sharedAnimations] setTabBar:delegate.tabBarController.tabBar fromViewController:self visible:YES animated:NO];
    
    [self setTranslationsAndFonts];
    
}

- (void)viewDidLoad {
    [super viewDidLoad];
    self.navigationController.navigationBar.hidden = YES;
    
    helper = [Helper sharedHelper];
    fonts = [Fonts sharedFonts];
    colors = [Colors sharedColors];
    translationsModel = [TranslationsModel sharedInstance];
    animations = [Animations sharedAnimations];
    delegate = (AppDelegate *)[[UIApplication sharedApplication] delegate];
    
    //Register Collection
    [_collectionView registerNib:[UINib nibWithNibName:@"GalleryCollectionViewCell" bundle:nil] forCellWithReuseIdentifier:@"GalleryCollectionViewCell"];
    [_collectionView registerNib:[UINib nibWithNibName:@"NoGalleryCollectionViewCell" bundle:nil] forCellWithReuseIdentifier:@"NoGalleryCollectionViewCell"];
    
    skeletonView = [[SkeletonView alloc] initWithFrame:_contentView.frame];
    skeletonView.backgroundColor = [UIColor clearColor];
}

- (void)viewDidAppear:(BOOL)animated{
    [super viewDidAppear:YES];
    
    [[ToastView sharedInstance] setDelegate:self];
    [[NetworkManager sharedInstance] setDelegate:self];
    [[NetworkManager sharedInstance] connectivityMonitoring];
    
    _performanceView.hidden = NO;
    _bookmarkedView.hidden = NO;
    
    if([[NetworkManager sharedInstance] isConnectionOffline]){
        if(!didShowConnectionError){
            [[NetworkManager sharedInstance] showConnectionErrorInViewController:delegate.tabBarController];
            didShowConnectionError = YES;
        }
        
        /**
         * show offline data
         */
        userInfo = [[UserModel sharedInstance] getUserInfo];
        if (userInfo) {
            [self setInfo];
        }
        
        galleryList = [[UserModel sharedInstance] getAllGallery];
        if ([galleryList count] > 0) {
            [_collectionView reloadData];
        }
        
        NSString *profileImgUrl = [[UserModel sharedInstance] getImageUrlOfMedia:@"profileImage"];
        if ([profileImgUrl length] > 0) {
            [_profileImageView sd_setImageWithURL:[NSURL URLWithString:profileImgUrl] placeholderImage:[UIImage imageNamed:@"default-avatar"]];
        }
        
        NSString *headerImgUrl = [[UserModel sharedInstance] getImageUrlOfMedia:@"headerImage"];
        if ([headerImgUrl length] > 0) {
            [_coverImageView sd_setImageWithURL:[NSURL URLWithString:headerImgUrl] placeholderImage:nil];
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
    apiCounter = 0;
    [self addSkeletonView];
    [self getInfo];
    [self getProfileImage];
    [self getProfileHeaderImage];
    [self getTodaysPerformance];
    [self getGallery];
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
            return;
        }
        
        [self getUpdates];
        return;
    }
    
    switch (lastApiCall) {
        case UserMediaServices_SaveImage:
            [self saveImage:lastApiParams[@"croppedImage"] withPrivacy:(int)lastApiParams[@"isPrivate"]];
            break;
        case UserMediaServices_UpdateImage:
            [self updateImagePrivacy:(int)lastApiParams[@"isPrivate"] forImage:lastApiParams[@"identifier"]];
            break;
        case UserMediaServices_DeleteImage:
            [self deleteGalleryImage:lastApiParams[@"identifier"]];
            break;
        case UserMediaServices_SaveProfileImage:
            [self croppingImageDone:lastApiParams[@"croppedImage"]];
            break;
            
        default:
            break;
    }
}

-(void)cancelToast{
    lastApiCall = 0;
    lastApiParams = nil;
}

-(void)viewDidLayoutSubviews{
    [super viewDidLayoutSubviews];
    
    if( !didLayoutReloaded ){
        [self setupUserInterface];
        
        didLayoutReloaded = YES;
    }
}

- (void)setupUserInterface{
    [animations setTabBar:delegate.tabBarController.tabBar fromViewController:self visible:YES animated:NO];
    
    [_performanceView layoutIfNeeded];
    [_bookmarkedView layoutIfNeeded];
    [helper addDropShadowIn:_performanceView withColor:[UIColor darkGrayColor] andSetCornerRadiusTo:5.0];
    [helper addDropShadowIn:_bookmarkedView withColor:[UIColor darkGrayColor] andSetCornerRadiusTo:5.0];
    
    _profileImageView.layer.cornerRadius = CGRectGetWidth(_profileImageView.frame)/2;
    _profileImageView.clipsToBounds = YES;
    [_profileImageView.layer setBorderColor: [[colors orangeColor] CGColor]];
    [_profileImageView.layer setBorderWidth: 3.0];
    
    [self setTranslationsAndFonts];
    
    _profileImageView.hidden = YES;
    _performanceView.hidden = YES;
    _bookmarkedView.hidden = YES;
    
    _settingsBtn.hidden = YES;
    _nameLbl.hidden = YES;
    _countryLbl.hidden = YES;
    _pinBtn.hidden = YES;
    _addBtn.hidden = YES;
    _collectionView.hidden = YES;
}

- (void)setTranslationsAndFonts{
    _nameLbl.font = [fonts headerFontLight];
    _countryLbl.font = [fonts normalFont];
    _performanceLbl.font = [fonts normalFont];
    _minimumExerciseLbl.font = [fonts normalFont];
    _minimumHabitsLbl.font = [fonts normalFont];
    _bookmarkedLbl.font = [fonts normalFont];
    _faqsLbl.font = [fonts normalFont];
    _galleryLbl.font = [fonts titleFont];
    
    _performanceLbl.text = [translationsModel getTranslationForKey:@"user.todaysperformance"];
    _minimumExerciseLbl.text = [translationsModel getTranslationForKey:@"user.minimumex"];
    _minimumHabitsLbl.text = [translationsModel getTranslationForKey:@"user.minimumhabits"];
    _bookmarkedLbl.text = [translationsModel getTranslationForKey:@"user.bookmarked"];
    _faqsLbl.text = [translationsModel getTranslationForKey:@"user.faqs"];
    _galleryLbl.text = [translationsModel getTranslationForKey:@"user.progressgallery_title"];
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
    _nameLbl.text = userInfo.userName;
    _countryLbl.text = userInfo.country;
}

- (void)getTodaysPerformance{
    [[UserServices sharedInstance] getTodaysHeadUpWithCompletion:^(NSError *error, int statusCode, HeadUpObj *headUp) {
        if(statusCode == NoInternetErrorStatusCode || statusCode == SlowInternetErrorStatusCode) {
            [[NetworkManager sharedInstance] showConnectionErrorInViewController:self->delegate.tabBarController statusCode:statusCode];
            return;
        }
        
        self->apiCounter += 1;
        [self removeSkeletonView];
        
        if (!error && headUp != nil) {
            
            if (headUp.passedExercises > 0) {
                [self->_minimumExerciseThumbBtn setImage:[UIImage imageNamed:@"thumbup"] forState:UIControlStateNormal];
                self->_minimumExerciseLbl.textColor = [self->colors greenColor];
            }else {
                [self->_minimumExerciseThumbBtn setImage:[UIImage imageNamed:@"thumbdown"] forState:UIControlStateNormal];
                self->_minimumExerciseLbl.textColor = [UIColor redColor];
            }
            
            if (headUp.passedHabits >= headUp.possibleHabits && headUp.possibleHabits > 0) {
                [self->_minimumHabitsThumbBtn setImage:[UIImage imageNamed:@"thumbup"] forState:UIControlStateNormal];
                self->_minimumHabitsLbl.textColor = [self->colors greenColor];
            }else {
                [self->_minimumHabitsThumbBtn setImage:[UIImage imageNamed:@"thumbdown"] forState:UIControlStateNormal];
                self->_minimumHabitsLbl.textColor = [UIColor redColor];
            }
            
            return;
        }
        
        if(error){
            //there is error on the api side
            [[NetworkManager sharedInstance] showApiErrorInViewController:self->delegate.tabBarController error:error];
        }
    }];
}

- (void)getProfileImage{
    [[UserMediaServices sharedInstance] getProfileImageWithCompletion:^(NSError *error, int statusCode)  {
        if(statusCode == NoInternetErrorStatusCode || statusCode == SlowInternetErrorStatusCode) {
            [[NetworkManager sharedInstance] showConnectionErrorInViewController:self->delegate.tabBarController statusCode:statusCode];
            return;
        }
        
        self->apiCounter += 1;
        [self removeSkeletonView];
        
        NSString *profileImgUrl = [[UserModel sharedInstance] getImageUrlOfMedia:@"profileImage"];
        [self->_profileImageView sd_setImageWithURL:[NSURL URLWithString:profileImgUrl] placeholderImage:[UIImage imageNamed:@"default-avatar"]];
    }];
}

- (void)getProfileHeaderImage{
    [[UserMediaServices sharedInstance] getProfileHeaderImageWithCompletion:^(NSError *error, int statusCode)  {
        if(statusCode == NoInternetErrorStatusCode || statusCode == SlowInternetErrorStatusCode) {
            [[NetworkManager sharedInstance] showConnectionErrorInViewController:self->delegate.tabBarController statusCode:statusCode];
            return;
        }
        
        self->apiCounter += 1;
        [self removeSkeletonView];
        
        //NSString *headerImgUrl = [[UserModel sharedInstance] getImageUrlOfMedia:@"headerImage"];
        //[self->_coverImageView sd_setImageWithURL:[NSURL URLWithString:headerImgUrl] placeholderImage:[UIImage imageNamed:@"sample_exercise_image"]];
    }];
}

- (void)getGallery{
    [[UserServices sharedInstance] getUsersGalleryWithCompletion:^(NSError *error, int statusCode) {
        if(statusCode == NoInternetErrorStatusCode || statusCode == SlowInternetErrorStatusCode) {
            [[NetworkManager sharedInstance] showConnectionErrorInViewController:self->delegate.tabBarController statusCode:statusCode];
            return;
        }
        
        self->apiCounter += 1;
        [self removeSkeletonView];
        
        self->galleryList = [[UserModel sharedInstance] getAllGallery];
        
        NSURL *coverUrl = nil;
        if(self->galleryList.count > 0){
            Gallery *gallery = self->galleryList[0];
            coverUrl = [NSURL URLWithString:gallery.url];
        }
        [self->_coverImageView sd_setImageWithURL:coverUrl placeholderImage:[UIImage imageNamed:@"placeholder-background-profile-user"]];
        
        [self->_collectionView reloadData];
    }];
}

#pragma mark - UICollectionview DataSource & Delegate
-(NSInteger)numberOfSectionsInCollectionView:(UICollectionView *)collectionView {
    return 1;
}

-(NSInteger)collectionView:(UICollectionView *)collectionView numberOfItemsInSection:(NSInteger)section{
    return [galleryList count] == 0? 1: [galleryList count];
}

-(UICollectionViewCell *)collectionView:(UICollectionView *)collectionView cellForItemAtIndexPath:(NSIndexPath *)indexPath {
    
    if([galleryList count] > 0){
        static NSString *identifier = @"GalleryCollectionViewCell";
        GalleryCollectionViewCell *cell = (GalleryCollectionViewCell *)[_collectionView dequeueReusableCellWithReuseIdentifier:identifier forIndexPath:indexPath];
        
        Gallery *gallery = galleryList[indexPath.row];
        
        [cell.imgView sd_setImageWithURL:[NSURL URLWithString:gallery.url] placeholderImage:nil];
        
        NSDateFormatter *dateFormatter = [[NSDateFormatter alloc]init];
        [dateFormatter setDateFormat:@"yyyy-MM-dd'T'HH:mm:ssZ"];
        NSDate *date = [dateFormatter dateFromString:gallery.creationDate];
        
        cell.dateLbl.text = [self dayWithSuffixAndMonthForDate:date];
        
        cell.optionBtn.hidden = NO;
        if (gallery.isPrivate) {
            [cell.optionBtn setImage:[UIImage imageNamed:@"locked"] forState:UIControlStateNormal];
        }else {
            [cell.optionBtn setImage:[UIImage imageNamed:@"globe"] forState:UIControlStateNormal];
        }
        return cell;
    }
    
    static NSString *identifier = @"NoGalleryCollectionViewCell";
    NoGalleryCollectionViewCell *cell = (NoGalleryCollectionViewCell *)[_collectionView dequeueReusableCellWithReuseIdentifier:identifier forIndexPath:indexPath];
    return cell;
}

- (CGSize)collectionView:(UICollectionView *)collectionView layout:(UICollectionViewLayout*)collectionViewLayout sizeForItemAtIndexPath:(NSIndexPath *)indexPath{
    
    return [self cellSize];
}

- (CGSize)cellSize{
    int cellW = CGRectGetWidth(_collectionView.frame) / 2.34;
    int cellH = cellW * 0.95;
    
    CGSize cellSize = CGSizeMake(cellW, cellH);
    return cellSize;
}

-(void)collectionView:(UICollectionView *)collectionView didSelectItemAtIndexPath:(NSIndexPath *)indexPath{
    [self.view endEditing:YES];
    
    if([galleryList count] > 0){
        GalleryCollectionViewCell *cell = (GalleryCollectionViewCell *)[collectionView cellForItemAtIndexPath:indexPath];
        GalleryObj *gallery = galleryList[indexPath.row];
        GalleryCropper *vc = [[GalleryCropper alloc] init];
        
        vc.view.backgroundColor = [UIColor clearColor];
        vc.modalPresentationStyle = UIModalPresentationOverCurrentContext;
        
        vc.image = cell.imgView.image;
        vc.dateStr = gallery.creationDate;
        vc.gallery = gallery;
        vc.dismissDelegate = self;
        
        [delegate.tabBarController presentViewController:vc animated:NO completion:nil];
        
        return;
    }
    
    //add first image
    [self addImage:nil];
}

//NOTE: transfer to helper
- (NSString *)dayWithSuffixAndMonthForDate:(NSDate *)date {
    
    NSDateFormatter *dateFormatter = [[NSDateFormatter alloc] init];
    [dateFormatter setDateFormat:@"MMM"];
    NSString *month = [dateFormatter stringFromDate:date];
    
    NSCalendar *calendar = [NSCalendar currentCalendar];
    NSInteger dayOfMonth = [calendar component:NSCalendarUnitDay fromDate:date];
    
    NSString *day = @"";
    switch (dayOfMonth) {
        case 1:
        case 21:
        case 31: day = [NSString stringWithFormat:@"%ldst", (long)dayOfMonth];
        case 2:
        case 22: day = [NSString stringWithFormat:@"%ldnd", (long)dayOfMonth];
        case 3:
        case 23: day = [NSString stringWithFormat:@"%ldrd", (long)dayOfMonth];
        default: day = [NSString stringWithFormat:@"%ldth", (long)dayOfMonth];
    }
    
    return [NSString stringWithFormat:@"%@ %@",day, month];
}

- (IBAction)addImage:(id)sender {
    isProfilePic = FALSE;
    __unsafe_unretained typeof(self) weakSelf = self;
    [[CustomAlertView sharedInstance] showAlertInViewController:delegate.tabBarController
                                     withTitle:[translationsModel getTranslationForKey:@"info.addphoto"]
                                       message:[translationsModel getTranslationForKey:@"info.addphotofrom"]
                             cancelButtonTitle:[translationsModel getTranslationForKey:@"info.camera"]
                               doneButtonTitle:[translationsModel getTranslationForKey:@"info.photolibrary"]];
    [[CustomAlertView sharedInstance] setCancelBlock:^(id result) {
        [weakSelf takePhoto];
    }];
    [[CustomAlertView sharedInstance] setDoneBlock:^(id result) {
        [weakSelf chooseImageFromLib];
    }];
}

- (void)showGalleryCropperWithImage:(UIImage *)image {
    NSDate *date = [NSDate date];
    NSDateFormatter *dateFormat = [[NSDateFormatter alloc]init];
    [dateFormat setDateFormat:@"yyyy-MM-dd'T'HH:mm:ssZ"];
    NSString *dateString = [dateFormat stringFromDate:date];
    
    GalleryCropper *vc = [[GalleryCropper alloc] init];
    
    vc.view.backgroundColor = [UIColor clearColor];
    vc.modalPresentationStyle = UIModalPresentationOverCurrentContext;
    
    vc.image = image;
    vc.dateStr = dateString;
    vc.gallery = nil;
    vc.dismissDelegate = self;
    
    [delegate.tabBarController presentViewController:vc animated:NO completion:nil];
}

#pragma GalleryCropperDelegate

- (void)saveImage:(UIImage *)croppedImg withPrivacy:(int)isPrivate{
    [DejalBezelActivityView activityViewForView:delegate.tabBarController.view];
    [[UserMediaServices sharedInstance] saveImage:croppedImg withPrivacy:isPrivate withCompletion:^(NSError *error, int statusCode) {
        [DejalBezelActivityView removeViewAnimated:YES];
        
        if(statusCode == NoInternetErrorStatusCode || statusCode == SlowInternetErrorStatusCode) {
            [[NetworkManager sharedInstance] showConnectionErrorInViewController:self->delegate.tabBarController statusCode:statusCode];
            self->lastApiCall = UserMediaServices_SaveImage;
            self->lastApiParams = @{@"croppedImage":croppedImg, @"isPrivate": @(isPrivate)};
            return;
        }
        
        self->lastApiCall = 0;
        self->lastApiParams = nil;
        
        if(!error){
            [self getGallery];
            
            NSString *title = [self->translationsModel getTranslationForKey:@"popup.successtitle"];
            NSString *msg = [self->translationsModel getTranslationForKey:@"popup.successtext"];
            
            CustomAlertView *alert = [CustomAlertView sharedInstance];
            [alert showAlertInViewController:self->delegate.tabBarController
                                   withTitle:title
                                     message:msg
                           cancelButtonTitle:[[TranslationsModel sharedInstance] getTranslationForKey:@"global.rateokay"]
                             doneButtonTitle:nil];
            [alert setCancelBlock:^(id result) {
                NSLog(@"Cancel");
            }];
            return;
        }
        
        if(error){
            //there is error on the api side
            [[NetworkManager sharedInstance] showApiErrorInViewController:self->delegate.tabBarController error:error];
            self->lastApiCall = UserMediaServices_SaveImage;
            self->lastApiParams = @{@"croppedImage":croppedImg, @"isPrivate": @(isPrivate)};
        }
    }];
}

- (void)updateImagePrivacy:(int)isPrivate forImage:(NSString *)identifier{
    [DejalBezelActivityView activityViewForView:delegate.tabBarController.view];
    [[UserMediaServices sharedInstance] updateImagePrivacy:isPrivate forImage:identifier withCompletion:^(NSError *error, int statusCode) {
        [DejalBezelActivityView removeViewAnimated:YES];
        
        if(statusCode == NoInternetErrorStatusCode || statusCode == SlowInternetErrorStatusCode) {
            [[NetworkManager sharedInstance] showConnectionErrorInViewController:self->delegate.tabBarController statusCode:statusCode];
            self->lastApiCall = UserMediaServices_UpdateImage;
            self->lastApiParams = @{@"identifier":identifier, @"isPrivate": @(isPrivate)};
            return;
        }
        
        self->lastApiCall = 0;
        self->lastApiParams = nil;
        
        if(!error){
            [self getGallery];
            
            NSString *title = [self->translationsModel getTranslationForKey:@"popup.successtitle"];
            NSString *msg =[self->translationsModel getTranslationForKey:@"info.privacyadded"];
            CustomAlertView *alert = [CustomAlertView sharedInstance];
            [alert showAlertInViewController:self->delegate.tabBarController
                                   withTitle:title
                                     message:msg
                           cancelButtonTitle:[[TranslationsModel sharedInstance] getTranslationForKey:@"global.rateokay"]
                             doneButtonTitle:nil];
            [alert setCancelBlock:^(id result) {
                NSLog(@"Cancel");
            }];
            return;
        }
        
        if(error){
            //there is error on the api side
            [[NetworkManager sharedInstance] showApiErrorInViewController:self->delegate.tabBarController error:error];
            self->lastApiCall = UserMediaServices_UpdateImage;
            self->lastApiParams = @{@"identifier":identifier, @"isPrivate": @(isPrivate)};
        }
    }];
}

- (void)deleteImage:(NSString *)identifier{
    
    [[CustomAlertView sharedInstance] showAlertInViewController:delegate.tabBarController
                                                      withTitle:@""
                                                        message:[translationsModel getTranslationForKey:@"info.deleteimage"]
                                              cancelButtonTitle:[translationsModel getTranslationForKey:@"global.cancelbutton"]
                                                doneButtonTitle:[translationsModel getTranslationForKey:@"global.delete"]];
    [[CustomAlertView sharedInstance] setCancelBlock:^(id result) {
        NSLog(@"Cancel");
    }];
    [[CustomAlertView sharedInstance] setDoneBlock:^(id result) {
        [self deleteGalleryImage:identifier];
    }];
}

- (void)deleteGalleryImage:(NSString *)identifier{
    [DejalBezelActivityView activityViewForView:delegate.tabBarController.view];
    [[UserMediaServices sharedInstance] deleteImage:identifier withCompletion:^(NSError *error, int statusCode) {
        [DejalBezelActivityView removeViewAnimated:YES];
        
        if(statusCode == NoInternetErrorStatusCode || statusCode == SlowInternetErrorStatusCode) {
            [[NetworkManager sharedInstance] showConnectionErrorInViewController:self->delegate.tabBarController statusCode:statusCode];
            self->lastApiCall = UserMediaServices_DeleteImage;
            self->lastApiParams = @{@"identifier":identifier};
            return;
        }
        
        self->lastApiCall = 0;
        self->lastApiParams = nil;
        
        if(!error){
            [self getGallery];
            
            NSString *title = [self->translationsModel getTranslationForKey:@"popup.successtitle"];
            NSString *msg = [self->translationsModel getTranslationForKey:@"info.removeimage"];
            
            CustomAlertView *alert = [CustomAlertView sharedInstance];
            [alert showAlertInViewController:self->delegate.tabBarController
                                   withTitle:title
                                     message:msg
                           cancelButtonTitle:[[TranslationsModel sharedInstance] getTranslationForKey:@"global.rateokay"]
                             doneButtonTitle:nil];
            [alert setCancelBlock:^(id result) {
                NSLog(@"Cancel");
            }];
            return;
        }
        
        if(error){
            //there is error on the api side
            [[NetworkManager sharedInstance] showApiErrorInViewController:self->delegate.tabBarController error:error];
            self->lastApiCall = UserMediaServices_DeleteImage;
            self->lastApiParams = @{@"identifier":identifier};
        }
    }];
}

- (IBAction)settings:(id)sender{
    SettingsViewController *vc = [[SettingsViewController alloc] initWithNibName:@"SettingsViewController" bundle:nil];
    
    vc.view.backgroundColor = [UIColor clearColor];
    vc.modalPresentationStyle = UIModalPresentationOverCurrentContext;
    
    vc.dismissDelegate = self;
    
    [delegate.tabBarController presentViewController:vc animated:NO completion:nil];
}

#pragma mark - UIScrollView Delegate
- (void)scrollViewDidScroll:(UIScrollView *)scrollView{
    [self.view layoutIfNeeded];
    
    float scrollOffset = _scrollView.contentOffset.y;
    float maxOffSet = CGRectGetHeight(_contentView.frame) - CGRectGetHeight(_scrollView.frame);
    
    if (scrollOffset > 0 && (scrollOffset >= _lastContentOffset || maxOffSet <= scrollOffset)){//scroll down
        [animations setTabBar:delegate.tabBarController.tabBar fromViewController:self visible:NO animated:YES];
    }
    else{//scroll up
        [animations setTabBar:delegate.tabBarController.tabBar fromViewController:self visible:YES animated:YES];
    }
    
    NSLog(@"scrollOffset: %f",scrollOffset);
    
    if (scrollOffset > 0){//scrolling up
        
        int maxOffSetParallax = 0;
        if(IS_IPHONE_5){
            maxOffSetParallax = 245;
        }else if(IS_STANDARD_IPHONE_6_PLUS){
            maxOffSetParallax = 110;
        }else if(IS_STANDARD_IPHONE_6){
            maxOffSetParallax = 170;
        }else{
            maxOffSetParallax = 165;
        }
        
        if (scrollOffset >= maxOffSetParallax) {//6 plus = 110, x = 165
            NSLog(@"SAME");
            lastCoverImageMaxY += ((scrollOffset - _lastContentOffset) * -1);
            self->_coverImageViewTopConstraint.constant = lastCoverImageMaxY;
            
        }else {
            float pos = (scrollOffset / 3) * -1;
            self->_coverImageViewTopConstraint.constant = pos;
            lastCoverImageMaxY = pos;
        }
        
        [UIView animateWithDuration:0 animations:^{
            [self->_coverImageView layoutIfNeeded];
            [self.view layoutIfNeeded];
        } completion:nil];
        
    }else if (scrollOffset <= 0){
        NSLog(@"scrolling down");
        _coverImageViewWidthConstraint.constant = (scrollOffset * -1.5);
        
    }
    
    _lastContentOffset = scrollOffset;
}

#pragma SettingsViewControllerDelegate
- (void)signOut{
    NSLog(@"Tabbar viewcontrollers = %@", delegate.tabBarController.navigationController.viewControllers);
    NSLog(@"Navbar viewcontrollers = %@", self.navigationController.viewControllers);
    
    for (UIViewController *vc in delegate.tabBarController.navigationController.viewControllers){
        if ([vc isKindOfClass:[SignInViewController class]]){
            [delegate.tabBarController.navigationController popToViewController:vc animated:YES];
            return;
        }
    }
    
    [delegate.tabBarController.navigationController popViewControllerAnimated:NO];
}

- (void)changeProfilePic{
    isProfilePic = TRUE;
    __unsafe_unretained typeof(self) weakSelf = self;
    [[CustomAlertView sharedInstance] showAlertInViewController:delegate.tabBarController
                                                      withTitle:[translationsModel getTranslationForKey:@"info.addphoto"]
                                                        message:[translationsModel getTranslationForKey:@"info.addphotofrom"]
                                              cancelButtonTitle:[translationsModel getTranslationForKey:@"info.camera"]
                                                doneButtonTitle:[translationsModel getTranslationForKey:@"info.photolibrary"]];
    [[CustomAlertView sharedInstance] setCancelBlock:^(id result) {
        [weakSelf takePhoto];
    }];
    [[CustomAlertView sharedInstance] setDoneBlock:^(id result) {
        [weakSelf chooseImageFromLib];
    }];
}

- (void)chooseImageFromLib {
    
    UIImagePickerControllerSourceType source = [UIImagePickerController isSourceTypeAvailable:UIImagePickerControllerSourceTypePhotoLibrary] ? UIImagePickerControllerSourceTypePhotoLibrary: UIImagePickerControllerSourceTypeSavedPhotosAlbum;
    
    UIImagePickerController *mediaUI = [[UIImagePickerController alloc] init];
    mediaUI.sourceType = source;
    mediaUI.mediaTypes = [UIImagePickerController availableMediaTypesForSourceType:source];
    mediaUI.mediaTypes = [[NSArray alloc] initWithObjects: (NSString *) kUTTypeImage, nil];
    mediaUI.allowsEditing = NO;
    mediaUI.delegate = self;
    mediaUI.modalPresentationStyle = UIModalPresentationFullScreen;
    
    mediaUI.navigationBar.tintColor = [UIColor blackColor];
    [[mediaUI navigationBar] setTitleTextAttributes:[NSDictionary dictionaryWithObject:[UIColor blackColor] forKey:NSForegroundColorAttributeName]];
    
    [self presentViewController: mediaUI animated: YES completion:nil];
}

- (void)takePhoto {
    
    UIImagePickerControllerSourceType source = [UIImagePickerController isSourceTypeAvailable:UIImagePickerControllerSourceTypeCamera] ? UIImagePickerControllerSourceTypeCamera : UIImagePickerControllerSourceTypeSavedPhotosAlbum;
    UIImagePickerController *photoPickerController = [[UIImagePickerController alloc] init];
    photoPickerController.sourceType = source;
    photoPickerController.mediaTypes = [[NSArray alloc] initWithObjects: (NSString *) kUTTypeImage, nil];
    photoPickerController.allowsEditing = NO;
    photoPickerController.delegate = self;
    photoPickerController.modalPresentationStyle = UIModalPresentationFullScreen;
    
    photoPickerController.navigationBar.tintColor = [UIColor blackColor];
    [[photoPickerController navigationBar] setTitleTextAttributes:[NSDictionary dictionaryWithObject:[UIColor blackColor] forKey:NSForegroundColorAttributeName]];
    
    [self presentViewController:photoPickerController animated:YES completion:nil];
    
}

#pragma mark - Image Picker Delegate -
- (void)imagePickerController:(UIImagePickerController *)picker didFinishPickingMediaWithInfo:(NSDictionary<NSString *,id> *)info{
    
    [[UINavigationBar appearance] setTitleTextAttributes:[NSDictionary dictionaryWithObjectsAndKeys:
                                                          [UIColor whiteColor], NSForegroundColorAttributeName,
                                                          [[Fonts sharedFonts] normalFontBold], NSFontAttributeName, nil]];
    [[UIBarButtonItem appearanceWhenContainedInInstancesOfClasses:@[[UINavigationBar class]]]
     setTitleTextAttributes:[NSDictionary dictionaryWithObjectsAndKeys:
                             [UIColor whiteColor], NSForegroundColorAttributeName,
                             [[Fonts sharedFonts] normalFontBold], NSFontAttributeName, nil]
     forState:UIControlStateNormal];
    
    NSString *mediaType = info[UIImagePickerControllerMediaType];
    UIImage *image = info[UIImagePickerControllerOriginalImage];
    
    [self dismissViewControllerAnimated:YES completion:^{
        if (self->isProfilePic) {
            [self showCropperWithImage:image];
        }else
            [self showGalleryCropperWithImage:image];
    }];
}

- (void)imagePickerControllerDidCancel:(UIImagePickerController *)picker
{
    
    [[UINavigationBar appearance] setTitleTextAttributes:[NSDictionary dictionaryWithObjectsAndKeys:
                                                                 [UIColor whiteColor], NSForegroundColorAttributeName,
                                                                 [[Fonts sharedFonts] normalFontBold], NSFontAttributeName, nil]];
    [[UIBarButtonItem appearanceWhenContainedInInstancesOfClasses:@[[UINavigationBar class]]]
     setTitleTextAttributes:[NSDictionary dictionaryWithObjectsAndKeys:
                             [UIColor whiteColor], NSForegroundColorAttributeName,
                             [[Fonts sharedFonts] normalFontBold], NSFontAttributeName, nil]
     forState:UIControlStateNormal];
    
    [self dismissViewControllerAnimated:YES completion:nil];
}

- (void)showCropperWithImage:(UIImage *)image {
    
    CustomCropper *vc = [[CustomCropper alloc] init];
    
    vc.view.backgroundColor = [UIColor clearColor];
    vc.modalPresentationStyle = UIModalPresentationOverCurrentContext;
    
    vc.image = image;
    vc.dismissDelegate = self;
    
    [delegate.tabBarController presentViewController:vc animated: NO completion:nil];
}

#pragma CustomCropperDelegate
- (void)croppingImageDone:(UIImage *)croppedImg{
    [DejalBezelActivityView activityViewForView:delegate.tabBarController.view];
    [[UserMediaServices sharedInstance] saveProfileImage:croppedImg withCompletion:^(NSError *error, int statusCode) {
        [DejalBezelActivityView removeViewAnimated:YES];
        
        if(statusCode == NoInternetErrorStatusCode || statusCode == SlowInternetErrorStatusCode) {
            [[NetworkManager sharedInstance] showConnectionErrorInViewController:self->delegate.tabBarController statusCode:statusCode];
            self->lastApiCall = UserMediaServices_SaveProfileImage;
            self->lastApiParams = @{@"croppedImage":croppedImg};
            return;
        }
        
        self->lastApiCall = 0;
        self->lastApiParams = nil;
        
        if(statusCode == 201){
            self->_profileImageView.image = croppedImg;
            
            NSString *title = [self->translationsModel getTranslationForKey:@"popup.successtitle"];
            NSString *msg = [self->translationsModel getTranslationForKey:@"info.profileimagenew"];
            CustomAlertView *alert = [CustomAlertView sharedInstance];
            [alert showAlertInViewController:self->delegate.tabBarController
                                   withTitle:title
                                     message:msg
                           cancelButtonTitle:[[TranslationsModel sharedInstance] getTranslationForKey:@"global.rateokay"]
                             doneButtonTitle:nil];
            [alert setCancelBlock:^(id result) {
                NSLog(@"Cancel");
            }];
            return;
        }
        
        if(error){
            //there is error on the api side
            [[NetworkManager sharedInstance] showApiErrorInViewController:self->delegate.tabBarController error:error];
            self->lastApiCall = UserMediaServices_SaveProfileImage;
            self->lastApiParams = @{@"croppedImage":croppedImg};
        }
    }];
}

- (IBAction)bookmarkedList:(id)sender {
    for ( UINavigationController *controller in delegate.tabBarController.viewControllers ) {
        if ( [[controller.childViewControllers objectAtIndex:0] isKindOfClass:[ExercisesListViewController class]]) {
            ExercisesListViewController *vc = [controller.childViewControllers objectAtIndex:0];
            vc.lastFilter = @{
                              @"liked":@"true",
                              @"status":@"available"
                              };
            [self.tabBarController setSelectedViewController:controller];
            break;
        }
    }
}

- (IBAction)faqs:(id)sender{
    FaqViewController *vc = [[FaqViewController alloc] initWithNibName:@"FaqViewController" bundle:nil];
    
    [self.navigationController pushViewController:vc animated:YES];
}

- (void)addSkeletonView{
    _profileImageView.hidden = YES;
    _settingsBtn.hidden = YES;
    _nameLbl.hidden = YES;
    _countryLbl.hidden = YES;
    _addBtn.hidden = YES;
    _collectionView.hidden = YES;
    
    [skeletonView addSkeletonFor:_profileImageView isText:NO];
    [skeletonView addSkeletonFor:_nameLbl isText:YES];
    [skeletonView addSkeletonFor:_countryLbl isText:YES];
    
    [skeletonView addSkeletonOn:_performanceView for:_performanceLbl isText:YES];
    [skeletonView addSkeletonOn:_performanceView for:_minimumExerciseLbl isText:YES];
    [skeletonView addSkeletonOn:_performanceView for:_minimumHabitsLbl isText:YES];
    [skeletonView addSkeletonOn:_performanceView for:_minimumExerciseThumbBtn isText:NO];
    [skeletonView addSkeletonOn:_performanceView for:_minimumHabitsThumbBtn isText:NO];
    [skeletonView addSkeletonOn:_bookmarkedView for:_bookmarkedLbl isText:YES];
    [skeletonView addSkeletonOn:_bookmarkedView for:_faqsLbl isText:YES];
    [skeletonView addSkeletonOn:_bookmarkedView for:_heartBtn isText:NO];
    [skeletonView addSkeletonOn:_bookmarkedView for:_questionMarkBtn isText:NO];
    
    [skeletonView addSkeletonOnProfileGalleryCollectionView:_collectionView withCellSize:[self cellSize]];
    [_contentView addSubview:skeletonView];
    
}

- (void)removeSkeletonView{
    if (apiCounter == 5) {
        apiCounter = 0;
        [skeletonView remove];
        didRequestFromRemote = YES;
        
        _profileImageView.hidden = NO;
        _settingsBtn.hidden = NO;
        _nameLbl.hidden = NO;
        _countryLbl.hidden = NO;
        _addBtn.hidden = NO;
        _collectionView.hidden = NO;
        
        if(userInfo.country == nil || userInfo.country.length == 0)
            _pinBtn.hidden = YES;
        else
            _pinBtn.hidden = NO;
    }
}

@end
