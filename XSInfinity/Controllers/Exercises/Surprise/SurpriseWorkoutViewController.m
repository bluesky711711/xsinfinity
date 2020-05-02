//
//  SurpriseWorkoutViewController.m
//  XSInfinity
//
//  Created by Joseph Marvin Magdadaro on 6/1/18.
//  Copyright © 2018 Joseph Marvin Magdadaro. All rights reserved.
//

#import "SurpriseWorkoutViewController.h"
#import "Fonts.h"
#import "Colors.h"
#import "Helper.h"
#import "TranslationsModel.h"
#import "ModulesServices.h"
#import "SingleExerciseViewController.h"
#import "CustomAlertView.h"
#import "DejalActivityView.h"
#import "CustomNavigation.h"
#import "AppDelegate.h"
#import "Animations.h"
#import "ModulesModel.h"
#import "FocusArea.h"
#import "NetworkManager.h"
#import "ToastView.h"

@interface SurpriseWorkoutViewController ()<NetworkManagerDelegate, ToastViewDelegate>{
    Helper *helper;
    Fonts *fonts;
    Colors *colors;
    TranslationsModel *translationsModel;
    AppDelegate *delegate;
    BOOL didLayoutReloaded;
    int selectedKindIndex;
    NSString *focusArea;
    NSString *difficulty;
    int rating;
    NSMutableArray *selectedKindsIndexArr;
    NSArray *focusAreaArr;
    ModuleServiceApi lastApiCall;
}
@property (weak, nonatomic) IBOutlet UIButton *findBtn;
@property (weak, nonatomic) IBOutlet UIView *contentView;

@property (weak, nonatomic) IBOutlet UILabel *difficultyLbl;
@property (weak, nonatomic) IBOutlet UILabel *focusLbl;
@property (weak, nonatomic) IBOutlet UILabel *exerciseLbl;
@property (weak, nonatomic) IBOutlet UILabel *rateLbl;

@property (weak, nonatomic) IBOutlet UIButton *easyBtn;
@property (weak, nonatomic) IBOutlet UIButton *mediumBtn;
@property (weak, nonatomic) IBOutlet UIButton *hardBtn;
@property (weak, nonatomic) IBOutlet UIButton *tooEasyBtn;
@property (weak, nonatomic) IBOutlet UIButton *okayBtn;
@property (weak, nonatomic) IBOutlet UIButton *challengingBtn;
@property (weak, nonatomic) IBOutlet UIButton *tooHardBtn;

@property (weak, nonatomic) IBOutlet UICollectionView *kindsCollectionView;

@property (strong, nonatomic) IBOutletCollection(UIButton) NSArray *difficultyButtons;
@property (strong, nonatomic) IBOutletCollection(UIButton) NSArray *rateButtons;

@end

@implementation SurpriseWorkoutViewController

-(UIStatusBarStyle)preferredStatusBarStyle
{
    return UIStatusBarStyleLightContent;
}

- (void)viewDidLoad {
    [super viewDidLoad];
    self.navigationController.navigationBar.hidden = NO;
    self.navigationItem.largeTitleDisplayMode = UINavigationItemLargeTitleDisplayModeNever;
    self.navigationItem.title = [translationsModel getTranslationForKey:@"surprise.getasurprise_title"];
    
    helper = [Helper sharedHelper];
    fonts = [Fonts sharedFonts];
    colors = [Colors sharedColors];
    translationsModel = [TranslationsModel sharedInstance];
    delegate = (AppDelegate *)[[UIApplication sharedApplication] delegate];
    
    selectedKindsIndexArr = [NSMutableArray new];
    
    //Register Collection
    [_kindsCollectionView registerClass:[UICollectionViewCell class] forCellWithReuseIdentifier:@"KindsCollectionViewCellIdentifier"];
    
    focusAreaArr = [[ModulesModel sharedInstance] getFocusArea];
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
    if(!lastApiCall){
        if([[NetworkManager sharedInstance] isConnectionOffline]){
            [[NetworkManager sharedInstance] showConnectionErrorInViewController:delegate.tabBarController];
        }
        return;
    }
    
    switch (lastApiCall) {
        case ModuleServiceApi_SurpriseWorkout:
            [self searchExercise:nil];
            break;
            
        default:
            break;
    }
}

-(void)cancelToast{
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
    //[[Animations sharedAnimations] setTabBar:delegate.tabBarController.tabBar fromViewController:self visible:YES animated:NO];
    
    [_contentView layoutIfNeeded];
    [helper addDropShadowIn:_contentView withColor:[UIColor darkGrayColor] andSetCornerRadiusTo:5.0f];
    
    _difficultyLbl.font = [fonts normalFont];
    _focusLbl.font = [fonts normalFont];
    _exerciseLbl.font = [fonts normalFont];
    _rateLbl.font = [fonts normalFont];
    _easyBtn.titleLabel.font= [fonts normalFont];
    _mediumBtn.titleLabel.font= [fonts normalFont];
    _hardBtn.titleLabel.font= [fonts normalFont];
    _findBtn.titleLabel.font= [fonts normalFontBold];
    
    _difficultyLbl.text = [translationsModel getTranslationForKey:@"surprise.chosediff"];
    _focusLbl.text = [translationsModel getTranslationForKey:@"surprise.chosefocusarea"];
    _exerciseLbl.text = [translationsModel getTranslationForKey:@"surprise.exerciserated"];
    [_easyBtn setTitle:[translationsModel getTranslationForKey:@"global.difficultyeasy"] forState:UIControlStateNormal];
    [_mediumBtn setTitle:[translationsModel getTranslationForKey:@"global.difficultymedium"] forState:UIControlStateNormal];
    [_hardBtn setTitle:[translationsModel getTranslationForKey:@"global.difficultyhard"] forState:UIControlStateNormal];
    [_findBtn setTitle:[translationsModel getTranslationForKey:@"surprise.button"] forState:UIControlStateNormal];
    [_findBtn setBackgroundColor:[colors blueColor]];
    
    for(UIButton *btn in _difficultyButtons){
        if (btn == _easyBtn) {
            [btn.layer setBorderColor:[[colors easyColor] CGColor]];
        }else if (btn == _mediumBtn){
            [btn.layer setBorderColor:[[colors mediumColor] CGColor]];
        }else if (btn == _hardBtn){
            [btn.layer setBorderColor:[[colors hardColor] CGColor]];
        }
        btn.backgroundColor = [UIColor clearColor];
        [btn.layer setBorderWidth:1.0];
        btn.layer.cornerRadius = 5;
        btn.clipsToBounds = YES;
    }
    
    [[CustomNavigation sharedInstance] removeBlurEffectIn:self];
    [[CustomNavigation sharedInstance] addNavBarCustomBottomLineIn:self];
    
}

#pragma mark - UICollectionview DataSource & Delegate
-(NSInteger)numberOfSectionsInCollectionView:(UICollectionView *)collectionView {
    return 1;
}

-(NSInteger)collectionView:(UICollectionView *)collectionView numberOfItemsInSection:(NSInteger)section{
    return [focusAreaArr count];
}

-(UICollectionViewCell *)collectionView:(UICollectionView *)collectionView cellForItemAtIndexPath:(NSIndexPath *)indexPath {
    
    UICollectionViewCell *cell = [_kindsCollectionView dequeueReusableCellWithReuseIdentifier:@"KindsCollectionViewCellIdentifier" forIndexPath:indexPath];
    
    cell.backgroundColor=[UIColor clearColor];
    cell.contentView.backgroundColor = [UIColor clearColor];
    
    for (id child in [cell.contentView subviews]){
        [child removeFromSuperview];
    }
    
    FocusArea *obj = focusAreaArr[indexPath.row];
    
    NSString *focusName = [translationsModel getTranslationForKey:[NSString stringWithFormat:@"%@%@.name", Cf_domain_model_FocusArea, obj.identifier]];
    
    UIButton *btn = [[UIButton alloc] initWithFrame:CGRectMake(0, 10, CGRectGetWidth(cell.frame), 35)];
    [btn setTitle:focusName forState:UIControlStateNormal];
    [btn addTarget:self action:@selector(selectKind:) forControlEvents:UIControlEventTouchUpInside];
    btn.titleLabel.font = [fonts normalFont];
    btn.layer.cornerRadius = 5;
    btn.clipsToBounds = YES;
    btn.tag = indexPath.row;
    [btn setTitleColor:[UIColor blackColor] forState:UIControlStateNormal];
    [btn.layer setBorderColor:[[UIColor grayColor] CGColor]];
    btn.backgroundColor = [UIColor clearColor];
    [btn.layer setBorderWidth:1.0];
    
    for (int i=0; i<[selectedKindsIndexArr count]; i++) {
        
        if (indexPath.row == [selectedKindsIndexArr[i] intValue]) {
            [btn setTitleColor:[UIColor whiteColor] forState:UIControlStateNormal];
            btn.backgroundColor = [colors orangeColor];
            [btn.layer setBorderWidth:0];
            
            break;
        }
    }
    
    [cell.contentView addSubview:btn];
    
    return cell;
}

- (CGSize)collectionView:(UICollectionView *)collectionView layout:(UICollectionViewLayout*)collectionViewLayout sizeForItemAtIndexPath:(NSIndexPath *)indexPath{
    
    CGSize cellSize = CGSizeMake(100, 55);
    return cellSize;
}

-(void)collectionView:(UICollectionView *)collectionView didSelectItemAtIndexPath:(NSIndexPath *)indexPath{
    [self.view endEditing:YES];
}

- (IBAction)selectKind:(id)sender {
    int btnTag = (int)[sender tag];
    
    for (int i=0; i<[selectedKindsIndexArr count]; i++) {
        if (btnTag == [selectedKindsIndexArr[i] intValue]) {
            [selectedKindsIndexArr removeObjectAtIndex:i];
            
            [_kindsCollectionView reloadData];
            return;
        }
    }
    
    for (int i=0; i<[focusAreaArr count]; i++) {
        if (btnTag == i) {
            [selectedKindsIndexArr addObject:@(btnTag)];
            
            [_kindsCollectionView reloadData];
            return;
        }
    }
}

- (IBAction)chooseDifficulty:(id)sender {
    UIButton *selectedBtn = (UIButton *)sender;
    for(UIButton *btn in _difficultyButtons){
        if (btn == selectedBtn) {
            if (selectedBtn == _easyBtn) {
                btn.backgroundColor = [colors easyColor];
                difficulty = @"easy";
            }else if (selectedBtn == _mediumBtn){
                btn.backgroundColor = [colors mediumColor];
                difficulty = @"medium";
            }else if (selectedBtn == _hardBtn){
                btn.backgroundColor = [colors hardColor];
                difficulty = @"hard";
            }
            
            [btn setTitleColor:[UIColor whiteColor] forState:UIControlStateNormal];
        }else{
            btn.backgroundColor = [UIColor clearColor];
            [btn setTitleColor:[UIColor blackColor] forState:UIControlStateNormal];
        }
    }
}

- (IBAction)chooseRate:(id)sender {
    UIButton *selectedBtn = (UIButton *)sender;
    rating = (int)selectedBtn.tag;
    
    [selectedBtn.layer setShadowOffset:CGSizeMake(0, 0)];
    [selectedBtn.layer setShadowColor:[[UIColor redColor] CGColor]];
    
    for(UIButton *btn in _rateButtons){
        if (btn == selectedBtn) {
            if (selectedBtn == _tooEasyBtn) {
                _rateLbl.text = [translationsModel getTranslationForKey:@"global.ratetooeasy"];
            }else if (selectedBtn == _okayBtn){
                _rateLbl.text = [translationsModel getTranslationForKey:@"global.rateokay"];
            }else if (selectedBtn == _challengingBtn){
                _rateLbl.text = [translationsModel getTranslationForKey:@"global.ratechallenging"];
            }else if (selectedBtn == _tooHardBtn){
                _rateLbl.text = [translationsModel getTranslationForKey:@"global.ratetoohard"];
            }
            
            [btn.layer setShadowOpacity:0.5];
        }else{
            [btn.layer setShadowOpacity:0];
        }
    }
    
}

- (IBAction)searchExercise:(id)sender{
    NSDictionary *params = @{
                             @"difficulty": [helper cleanValue:difficulty],
                             @"focusarea": [helper cleanValue:focusArea],
                             @"rating": @(rating)
                             };
    
    [DejalBezelActivityView activityViewForView:delegate.tabBarController.view];
    
    [[ModulesServices sharedInstance] getSurpriseWorkoutWithParameters:params withCompletion:^(NSError *error, int statusCode, ExercisesObj *exercise) {
        [DejalBezelActivityView removeViewAnimated:YES];
        
        if(statusCode == NoInternetErrorStatusCode || statusCode == SlowInternetErrorStatusCode) {
            [[NetworkManager sharedInstance] showConnectionErrorInViewController:self->delegate.tabBarController statusCode:statusCode];
            self->lastApiCall = ModuleServiceApi_SurpriseWorkout;
            return;
        }
        
        if (!error && exercise != nil) {
            self->lastApiCall = 0;
            
            SingleExerciseViewController *vc = [[SingleExerciseViewController alloc] initWithNibName:@"SingleExerciseViewController" bundle:nil];
            vc.exercise = exercise;
            [self.navigationController pushViewController:vc animated: YES];
            return;
        }
        
        if(error){
            //there is error on the api side
            [[NetworkManager sharedInstance] showApiErrorInViewController:self->delegate.tabBarController error:error];
            self->lastApiCall = ModuleServiceApi_SurpriseWorkout;
        }
    }];
}

- (void)getFocusArea{
    
}

- (IBAction)back:(id)sender {
    [self.navigationController popViewControllerAnimated:YES];
}

@end
