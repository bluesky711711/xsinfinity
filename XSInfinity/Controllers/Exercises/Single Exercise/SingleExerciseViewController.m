//
//  SingleExerciseViewController.m
//  XSInfinity
//
//  Created by Joseph Marvin Magdadaro on 6/16/18.
//  Copyright © 2018 Joseph Marvin Magdadaro. All rights reserved.
//

#import "SingleExerciseViewController.h"
#import <SDWebImage/UIImageView+WebCache.h>
#import <AVFoundation/AVFoundation.h>
#import <AVKit/AVKit.h>
#import "Helper.h"
#import "Fonts.h"
#import "Colors.h"
#import "TranslationsModel.h"
#import "StartExerciseViewController.h"
#import "ExercisesListViewController.h"
#import "VideoPlayerViewController.h"
#import "DownloadServices.h"
#import "CustomNavigation.h"
#import "ModulesServices.h"
#import "DejalActivityView.h"
#import "CustomAlertView.h"
#import "Animations.h"
#import "AppDelegate.h"
#import "ModulesModel.h"
#import "BookmarkedExercises.h"
#import "NetworkManager.h"
#import "ToastView.h"

@interface SingleExerciseViewController ()<NetworkManagerDelegate, ToastViewDelegate>{
    Helper *helper;
    Fonts *fonts;
    Colors *colors;
    TranslationsModel *translationsModel;
    AppDelegate *delegate;
    BOOL didLayoutReloaded;
    NSArray *tagsIds, *tagsNames;
    NSString *videoFileName;
    NSString *bookmarkId;
    BOOL isVideoDownloaded;
    BOOL isBookmarked;
    ModuleServiceApi lastAPiCall;
}
@property (weak, nonatomic) IBOutlet UIView *contentView;
@property (weak, nonatomic) IBOutlet UIView *pointsView;
@property (weak, nonatomic) IBOutlet UILabel *pointsLbl;
@property (weak, nonatomic) IBOutlet UILabel *pointsValueLbl;
@property (weak, nonatomic) IBOutlet UILabel *setsLbl;
@property (weak, nonatomic) IBOutlet UILabel *setsValueLbl;
@property (weak, nonatomic) IBOutlet UILabel *repsOrTimesLbl;
@property (weak, nonatomic) IBOutlet UILabel *repsOrTimesValueLbl;
@property (weak, nonatomic) IBOutlet UILabel *moduleNameLbl;
@property (weak, nonatomic) IBOutlet UIView *difficultyColorView;
@property (weak, nonatomic) IBOutlet UITextView *exerciseNameTxtView;

@property (weak, nonatomic) IBOutlet UIView *videoShadowView;
@property (weak, nonatomic) IBOutlet UIView *videoView;
@property (weak, nonatomic) IBOutlet UIImageView *imgView;
@property (weak, nonatomic) IBOutlet UIButton *heartBtn;

@property (weak, nonatomic) IBOutlet UIButton *startBtn;
@property (weak, nonatomic) IBOutlet UILabel *timesFinishedLbl;
@property (weak, nonatomic) IBOutlet UICollectionView *tagsCollectionView;

@property (weak, nonatomic) IBOutlet UIScrollView *scrollView;
@property (weak, nonatomic) IBOutlet UIView *scrollContentView;
@property (nonatomic, assign) CGFloat lastContentOffset;
@property (weak, nonatomic) IBOutlet NSLayoutConstraint *contentViewConstraintHeight;

@end

@implementation SingleExerciseViewController

-(void)viewWillAppear:(BOOL)animated{
    [super viewWillAppear:YES];
    self.navigationController.navigationBar.hidden = NO;
    [[CustomNavigation sharedInstance] addOrRemoveBlurEffectAndLineForNavigationInViewController:self];
}

- (void)viewDidLoad {
    [super viewDidLoad];
    self.navigationController.navigationBar.hidden = NO;
    self.navigationItem.largeTitleDisplayMode = UINavigationItemLargeTitleDisplayModeNever;
    
    helper = [Helper sharedHelper];
    fonts = [Fonts sharedFonts];
    colors = [Colors sharedColors];
    translationsModel = [TranslationsModel sharedInstance];
    delegate = (AppDelegate *)[[UIApplication sharedApplication] delegate];
    
    NSString *exerciseName = [translationsModel getTranslationForKey:[NSString stringWithFormat:@"%@%@.name", Cf_domain_model_Exercise, self.exercise.identifier]];

    self.navigationItem.title = exerciseName;
    
    //Register Collection
    [_tagsCollectionView registerClass:[UICollectionViewCell class] forCellWithReuseIdentifier:@"TagsCollectionViewCellIdentifier"];
    
    tagsIds = [self.exercise.tagsIds componentsSeparatedByString:@", "];
    tagsNames = [self.exercise.tagsNames componentsSeparatedByString:@", "];
    
    [self setInfo];
    [self checkBookmark];
    [self checkExercisesHistory];
    [self downloadExerciseVideo];
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
    if(!lastAPiCall){
        if([[NetworkManager sharedInstance] isConnectionOffline]){
            [[NetworkManager sharedInstance] showConnectionErrorInViewController:delegate.tabBarController];
            return;
        }
        
        [self checkBookmark];
        [self checkExercisesHistory];
        [self downloadExerciseVideo];
        return;
    }
    
    switch (lastAPiCall) {
        case ModuleServiceApi_CreateBookmark:
            [self addToBookmark];
            break;
        case ModuleServiceApi_RemoveBookmark:
            [self removeBookmarked];
            break;
        default:
            break;
    }
}

- (void)cancelToast{
    lastAPiCall = 0;
}

-(void)viewDidLayoutSubviews{
    [super viewDidLayoutSubviews];
    
    if( !didLayoutReloaded ){
        [self setupUserInterface];
        
        didLayoutReloaded = YES;
    }
}

- (void)setupUserInterface{
    self.view.backgroundColor = [UIColor colorWithPatternImage:[UIImage imageNamed:@"bg"]];
    UIImageView *imgView = [[UIImageView alloc] initWithFrame:CGRectMake(0, 0, CGRectGetWidth(_scrollView.frame), CGRectGetHeight(_scrollView.frame) + 150)];
    imgView.image = [UIImage imageNamed:@"bg"];
    imgView.tag = 999;
    [_scrollView insertSubview:imgView atIndex:0];
    
    _contentViewConstraintHeight.constant = 900;
    
    /*//scroll if iphone5 to show the bottom elements
    if(IS_IPHONE_5){
        //set contentview height for proper scrolling
        _contentViewConstraintHeight.constant = 500;
    }else{
        //disabled scrolling for other ios devices since the view is fit
        _scrollView.scrollEnabled = false;
    }*/
    
    [[Animations sharedAnimations] setTabBar:delegate.tabBarController.tabBar fromViewController:self visible:YES animated:NO];
    [[CustomNavigation sharedInstance] addOrRemoveBlurEffectAndLineForNavigationInViewController:self];
    
    [_contentView layoutIfNeeded];
    [_videoShadowView layoutIfNeeded];
    [helper addDropShadowIn:_contentView withColor:[UIColor darkGrayColor] andSetCornerRadiusTo:5.0];
    [helper addDropShadowIn:_videoShadowView withColor:[UIColor darkGrayColor] andSetCornerRadiusTo:5.0];
    
    _pointsLbl.font = [fonts normalFont];
    _pointsValueLbl.font = [fonts bigFontBold];
    _setsLbl.font = [fonts normalFont];
    _setsValueLbl.font = [fonts headerFont];
    _repsOrTimesLbl.font = [fonts normalFont];
    _repsOrTimesValueLbl.font = [fonts headerFont];
    _moduleNameLbl.font = [fonts normalFont];
    _exerciseNameTxtView.font = [fonts headerFont];
    _timesFinishedLbl.font = [fonts normalFontBold];
    _startBtn.titleLabel.font = [fonts normalFontBold];
    
    _exerciseNameTxtView.textContainer.lineFragmentPadding = 0;
    _exerciseNameTxtView.textContainerInset = UIEdgeInsetsZero;
    [_exerciseNameTxtView setContentOffset:CGPointZero animated:NO];
    
    if ([self.exercise.type isEqualToString:@"repetition"]) {
        _repsOrTimesLbl.text = [translationsModel getTranslationForKey:@"global.reps"];
    }else{
        _repsOrTimesLbl.text = [translationsModel getTranslationForKey:@"global.minutes"];
    }
    
    _pointsLbl.text = [translationsModel getTranslationForKey:@"global.points"];
    _setsLbl.text = [translationsModel getTranslationForKey:@"global.sets"];
    _timesFinishedLbl.text = [NSString stringWithFormat:@"%@: %@",[translationsModel getTranslationForKey:@"exsingle.finished"], @"0"];
    [_startBtn setTitle:[translationsModel getTranslationForKey:@"exsingle.startbutton"] forState:UIControlStateNormal];
    
    _pointsView.backgroundColor = [colors purpleColor];
    _startBtn.backgroundColor = [colors blueColor];
    
}

- (void)setInfo{
    NSString *moduleId = @"";
    if(self.module){
        moduleId = self.module.identifier;
    }else{
        moduleId = self.exercise.moduleIdentifier;
    }
    
    NSString *moduleName = [translationsModel getTranslationForKey:[NSString stringWithFormat:@"%@%@.name", Cf_domain_model_Module, moduleId]];
    NSString *exerciseName = [translationsModel getTranslationForKey:[NSString stringWithFormat:@"%@%@.name", Cf_domain_model_Exercise, self.exercise.identifier]];
    NSString *exerciseDesc = [translationsModel getTranslationForKey:[NSString stringWithFormat:@"%@%@.description", Cf_domain_model_Exercise, self.exercise.identifier]];
    
    _moduleNameLbl.text = moduleName;
    _exerciseNameTxtView.text = @"This is a quick brown fox Kickout routine kick Kickout routine kick Kickout routine kick Kickout routine kick Kickout routine kick Kickout routine kick Kickout routine kick Kickout routine kick Kickout routine kick Kickout routine kick Kickout routine kick Kickout routine kick";
    _pointsValueLbl.text = @(self.exercise.points).stringValue;
    _setsValueLbl.text = @(self.exercise.sets).stringValue;
    
    if ([self.exercise.type isEqualToString:@"repetition"]) {
        _repsOrTimesValueLbl.text =@(self.exercise.repetitions).stringValue;
    }else{
        int minutes = self.exercise.duration / 60;
        int seconds = self.exercise.duration % 60;
        float duration = minutes + (seconds * 0.01);
        _repsOrTimesValueLbl.text = [NSString stringWithFormat:@"%.2f",duration];
    }
    
    [_imgView sd_setImageWithURL:[NSURL URLWithString:self.exercise.previewImage] placeholderImage:nil];
}

- (void)checkBookmark{
    
    NSArray *bookmarkedExercises = [[ModulesModel sharedInstance] getAllBookmarkedExercises];
    for (BookmarkedExercises *bookmarked in bookmarkedExercises){
        if ([self.exercise.identifier isEqual:bookmarked.exerciseId]) {
            bookmarkId = bookmarked.bookmarkId;
            [_heartBtn setImage:[UIImage imageNamed:@"heart_selected"] forState:UIControlStateNormal];
            
            isBookmarked = YES;
        }
    }
}

- (void)checkExercisesHistory{
    [[ModulesServices sharedInstance] getExercisesHistoryWithCompletion:^(NSError *error, int statusCode, NSArray *exercises) {
        if(statusCode == NoInternetErrorStatusCode || statusCode == SlowInternetErrorStatusCode) {
            [[NetworkManager sharedInstance] showConnectionErrorInViewController:self->delegate.tabBarController statusCode:statusCode];
            return;
        }
        
        if (!error && [exercises count] > 0){
            NSArray *doneExercise = [[exercises filteredArrayUsingPredicate:[NSPredicate predicateWithFormat:@"identifier = %@",self.exercise.identifier]] mutableCopy];
            
            self->_timesFinishedLbl.text = [NSString stringWithFormat:@"%@: %d",[self->translationsModel getTranslationForKey:@"exsingle.finished"], (int)[doneExercise count]];
            return;
        }
        
        if(error){
            //there is error on the api side
            [[NetworkManager sharedInstance] showApiErrorInViewController:self->delegate.tabBarController error:error];
            self->lastAPiCall = 0;
        }
    }];
}

#pragma mark - UICollectionview DataSource & Delegate
-(NSInteger)numberOfSectionsInCollectionView:(UICollectionView *)collectionView {
    return 1;
}

-(NSInteger)collectionView:(UICollectionView *)collectionView numberOfItemsInSection:(NSInteger)section{
    return [tagsNames count];
}

-(UICollectionViewCell *)collectionView:(UICollectionView *)collectionView cellForItemAtIndexPath:(NSIndexPath *)indexPath {
    
    UICollectionViewCell *cell = [_tagsCollectionView dequeueReusableCellWithReuseIdentifier:@"TagsCollectionViewCellIdentifier" forIndexPath:indexPath];
    
    cell.backgroundColor=[UIColor clearColor];
    cell.contentView.backgroundColor = [UIColor clearColor];
    
    for (id child in [cell.contentView subviews]){
        [child removeFromSuperview];
    }
    
    NSString *tagName = [translationsModel getTranslationForKey:[NSString stringWithFormat:@"%@%@.name", Cf_domain_model_Tag, tagsIds[indexPath.row]]];
    
    UIButton *btn = [[UIButton alloc] initWithFrame:CGRectMake(0, 10, CGRectGetWidth(cell.frame), 35)];
    [btn setTitle:[tagName uppercaseString] forState:UIControlStateNormal];
    [btn addTarget:self action:@selector(selectTag:) forControlEvents:UIControlEventTouchUpInside];
    btn.titleLabel.font = [fonts normalFontBold];
    btn.layer.cornerRadius = 35/2;
    btn.clipsToBounds = YES;
    btn.tag = indexPath.row;
    [btn setTitleColor:[UIColor blackColor] forState:UIControlStateNormal];
    btn.backgroundColor = [UIColor whiteColor];
    
    [cell.contentView addSubview:btn];
    
    return cell;
}

- (CGSize)collectionView:(UICollectionView *)collectionView layout:(UICollectionViewLayout*)collectionViewLayout sizeForItemAtIndexPath:(NSIndexPath *)indexPath{
    
    NSString *tagName = [translationsModel getTranslationForKey:[NSString stringWithFormat:@"%@%@.name", Cf_domain_model_Tag, tagsIds[indexPath.row]]];
    float w = tagName.length * 20;
    
    if([LANGUAGE_KEY isEqualToString:@"cn"]){
        w *= 2;
    }
    
    CGSize cellSize = CGSizeMake(w, 55);
    return cellSize;
}

-(void)collectionView:(UICollectionView *)collectionView didSelectItemAtIndexPath:(NSIndexPath *)indexPath{
    [self.view endEditing:YES];
}

- (IBAction)selectTag:(id)sender{
    NSString *tagId = tagsIds[[sender tag]];
    
    NSLog(@"Selected tag:%@", tagId);
    
    ExercisesListViewController *vc = [[ExercisesListViewController alloc] initWithNibName:@"ExercisesListViewController" bundle:nil];
    vc.lastFilter = @{
                      //@"status": @"available",
                      @"tags": tagId
                      };
    [self.navigationController pushViewController:vc animated: YES];
}

- (IBAction)startExercise:(id)sender {
    self.navigationItem.backBarButtonItem = [[UIBarButtonItem alloc] initWithTitle:@""
                                                                             style:UIBarButtonItemStylePlain
                                                                            target:nil
                                                                            action:nil];
    
    StartExerciseViewController *vc = [[StartExerciseViewController alloc] initWithNibName:@"StartExerciseViewController" bundle:nil];
    vc.exercise = self.exercise;
    [self.navigationController pushViewController:vc animated: YES];
}

- (void)downloadExerciseVideo{
    videoFileName = [NSString stringWithFormat:@"video_%@.mp4",self.exercise.identifier];
    
    NSString *documentsPath = NSSearchPathForDirectoriesInDomains(NSDocumentDirectory, NSUserDomainMask, YES)[0];
    NSString *filePath = [documentsPath stringByAppendingPathComponent:videoFileName];
    isVideoDownloaded = [[NSFileManager defaultManager] fileExistsAtPath:filePath];
    
    if (isVideoDownloaded) {
        return;
    }
    
    [[DownloadServices sharedInstance] downloadVideoFromURL:self.exercise.videoUrl
                                                setFileName:videoFileName
                                             withCompletion:^(NSError *error, BOOL downloaded) {
        NSLog(@"Error %@", error);
        self->isVideoDownloaded = downloaded;
    }];
}

- (IBAction)clickedPlay:(id)sender {
    
    NSURL *videoUrl;
    
    if (isVideoDownloaded) {
        NSString *documentsPath = NSSearchPathForDirectoriesInDomains(NSDocumentDirectory, NSUserDomainMask, YES)[0];
        NSString *filePath = [documentsPath stringByAppendingPathComponent:videoFileName];
        videoUrl = [NSURL fileURLWithPath:filePath];
    }else{
        videoUrl = [NSURL URLWithString:self.exercise.videoUrl];
    }
    
    AVPlayer *player = [AVPlayer playerWithURL:videoUrl];
    AVPlayerViewController *playerController = [AVPlayerViewController new];
    playerController.player = player;
    
    [self.navigationController presentViewController:playerController animated:YES completion:^{
        [player play];
    }];
}

- (IBAction)bookmark:(id)sender{
    if (isBookmarked){
        [self removeBookmarked];
    }else{
        [self addToBookmark];
    }
    
}

- (void)removeBookmarked{
    [DejalBezelActivityView activityViewForView:delegate.tabBarController.view];
    
    [[ModulesServices sharedInstance] removeBookMark:bookmarkId withCompletion:^(NSError *error, int statusCode) {
        [DejalBezelActivityView removeViewAnimated:YES];
        
        if(statusCode == NoInternetErrorStatusCode || statusCode == SlowInternetErrorStatusCode) {
            [[NetworkManager sharedInstance] showConnectionErrorInViewController:self->delegate.tabBarController statusCode:statusCode];
            self->lastAPiCall = ModuleServiceApi_RemoveBookmark;
            return;
        }
        
        self->lastAPiCall = 0;
        
        if (!error && statusCode == 204) {
            [[ModulesModel sharedInstance] removeBookmarked:self->bookmarkId];
            [self->_heartBtn setImage:[UIImage imageNamed:@"heart_unselected"] forState:UIControlStateNormal];
            self->isBookmarked = NO;
            
            [[ModulesServices sharedInstance] getBookmarkedExercisesWithCompletion:^(NSError *error, BOOL successful) {
                NSLog(@"Done updating bookmark list");
            }];
            return;
        }
        
        
        if(error){
            //there is error on the api side
            [[NetworkManager sharedInstance] showApiErrorInViewController:self->delegate.tabBarController error:error];
            self->lastAPiCall = ModuleServiceApi_RemoveBookmark;
        }
    }];
}

- (void)addToBookmark{
    [DejalBezelActivityView activityViewForView:delegate.tabBarController.view];
    
    [[ModulesServices sharedInstance] createBookMarkForExercise:self.exercise.identifier withCompletion:^(NSError *error, int statusCode) {
        [DejalBezelActivityView removeViewAnimated:YES];
        
        if(statusCode == NoInternetErrorStatusCode || statusCode == SlowInternetErrorStatusCode) {
            [[NetworkManager sharedInstance] showConnectionErrorInViewController:self->delegate.tabBarController statusCode:statusCode];
            self->lastAPiCall = ModuleServiceApi_RemoveBookmark;
            return;
        }
        
        self->lastAPiCall = 0;
        
        NSLog(@"Done bookmarking");
        if (statusCode == 201) {
            self->isBookmarked = YES;
            [self->_heartBtn setImage:[UIImage imageNamed:@"heart_selected"] forState:UIControlStateNormal];
            [[Animations sharedAnimations] zoomSpringAnimationForView:self->_heartBtn];
            
            [[ModulesServices sharedInstance] getBookmarkedExercisesWithCompletion:^(NSError *error, BOOL successful) {
                NSLog(@"Done updating bookmark list");
                NSArray *bookmarkedExercises = [[ModulesModel sharedInstance] getAllBookmarkedExercises];
                for (BookmarkedExercises *bookmarked in bookmarkedExercises){
                    if ([self.exercise.identifier isEqual:bookmarked.exerciseId]) {
                        self->bookmarkId = bookmarked.bookmarkId;
                    }
                }
            }];
            return;
        }
        
        if(error){
            //there is error on the api side
            [[NetworkManager sharedInstance] showApiErrorInViewController:self->delegate.tabBarController error:error];
            self->lastAPiCall = ModuleServiceApi_CreateBookmark;
        }
    }];
}

#pragma mark - UIScrollView Delegate
- (void)scrollViewDidScroll:(UIScrollView *)scrollView{
    [self.view layoutIfNeeded];
    
    float scrollOffset = _scrollView.contentOffset.y;
    float maxOffSet = _scrollView.contentSize.height - CGRectGetHeight(_scrollView.frame);
    
    if (scrollOffset > 0 && (scrollOffset >= _lastContentOffset || maxOffSet <= scrollOffset)){//scroll down
        [[Animations sharedAnimations] setTabBar:delegate.tabBarController.tabBar fromViewController:self visible:NO animated:YES];
    }
    else{//scroll up
        [[Animations sharedAnimations] setTabBar:delegate.tabBarController.tabBar fromViewController:self visible:YES animated:YES];
    }
    _lastContentOffset = scrollOffset;
    
    [[CustomNavigation sharedInstance] addOrRemoveBlurEffectAndLineForNavigationInViewController:self];
    
}

- (IBAction)back:(id)sender {
    [self.navigationController popViewControllerAnimated:YES];
}

@end
