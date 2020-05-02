//
//  ExercisesMainViewController.m
//  XSInfinity
//
//  Created by Joseph Marvin Magdadaro on 6/1/18.
//  Copyright © 2018 Joseph Marvin Magdadaro. All rights reserved.
//

#import "ExercisesMainViewController.h"
#import <SDWebImage/UIImageView+WebCache.h>
#import <StoreKit/StoreKit.h>
#import "NetworkManager.h"
#import "DejalActivityView.h"
#import "AppDelegate.h"
#import "Helper.h"
#import "Fonts.h"
#import "Colors.h"
#import "TranslationsModel.h"
#import "Animations.h"
#import "CustomNavigation.h"
#import "SurpriseWorkoutViewController.h"
#import "SingleModuleViewController.h"
#import "ModulesCollectionViewCell.h"
#import "ExercisesCollectionViewCell.h"
#import "ModulesServices.h"
#import "CustomAlertView.h"
#import "SingleExerciseViewController.h"
#import "SkeletonView.h"
#import "ModulesModel.h"
#import "ExercisesSummary.h"
#import "Modules.h"
#import "Exercises.h"
#import "LockedModuleViewController.h"
#import "ToastView.h"
#import "AppReviewHelper.h"
#import "PaymentMethodViewController.h"

@interface ExercisesMainViewController ()<ToastViewDelegate, NetworkManagerDelegate>{
    Helper *helper;
    Fonts *fonts;
    Colors *colors;
    TranslationsModel *translationsModel;
    Animations *animations;
    Difficulties difficulty;
    AppDelegate *delegate;
    CustomNavigation *customNavigation;
    SkeletonView *skeletonView;
    Modules *selectedModule;
    NSArray *modules;
    NSArray *exercisess;
    int selectedModuleIndex;
    int apiCounter;
    BOOL didShowConnectionError;
    BOOL didRequestFromRemote;
    BOOL didLayoutReloaded;
}
@property (weak, nonatomic) IBOutlet UIScrollView *scrollView;
@property (weak, nonatomic) IBOutlet UIView *contentView;

@property (weak, nonatomic) IBOutlet UIView *headerView;
@property (weak, nonatomic) IBOutlet UILabel *headerLbl;

@property (weak, nonatomic) IBOutlet UIView *summaryView;
@property (weak, nonatomic) IBOutlet UILabel *exerciseUnlockedLbl;
@property (weak, nonatomic) IBOutlet UILabel *unlockedValueLbl;
@property (weak, nonatomic) IBOutlet UILabel *dailyminimumLbl;
@property (weak, nonatomic) IBOutlet UIButton *minimumBtn;
@property (weak, nonatomic) IBOutlet UILabel *continousDaysLbl;
@property (weak, nonatomic) IBOutlet UILabel *daysValueLbl;

@property (weak, nonatomic) IBOutlet UIView *pointsView;
@property (weak, nonatomic) IBOutlet UILabel *pointsLbl;
@property (weak, nonatomic) IBOutlet UILabel *exercisePointsLbl;

@property (weak, nonatomic) IBOutlet UILabel *selectModuleLbl;
@property (weak, nonatomic) IBOutlet UICollectionView *modulesCollectionView;

@property (weak, nonatomic) IBOutlet UILabel *selectExerciseLbl;
@property (weak, nonatomic) IBOutlet UICollectionView *exercisesCollectionView;

@property (weak, nonatomic) IBOutlet UIView *surpriseView;
@property (weak, nonatomic) IBOutlet UILabel *surpriseLbl;
@property (weak, nonatomic) IBOutlet UILabel *surpriseMsgLbl;

@property (weak, nonatomic) IBOutlet UISegmentedControl *segmentedControl;

@property (nonatomic, assign) CGFloat lastContentOffset;

@end

@implementation ExercisesMainViewController

-(void)viewWillAppear:(BOOL)animated{
    [super viewWillAppear:YES];
    float scrollOffset = _scrollView.contentOffset.y;
    if (scrollOffset < 0){
        [[Animations sharedAnimations] setTabBar:delegate.tabBarController.tabBar fromViewController:self visible:YES animated:NO];
    }
    [[CustomNavigation sharedInstance] addOrRemoveBlurEffectAndLineForNavigationInViewController:self];
    [self setTranslationsAndFonts];
}

- (void)viewDidLoad {
    [super viewDidLoad];
    self.navigationController.navigationBar.hidden = NO;
    [self.navigationController.navigationBar setBackgroundImage:[UIImage new]
                                                  forBarMetrics:UIBarMetricsDefault];
    self.navigationController.navigationBar.shadowImage = [UIImage new];
    self.navigationController.navigationBar.prefersLargeTitles = TRUE;
    self.navigationItem.largeTitleDisplayMode = UINavigationItemLargeTitleDisplayModeAutomatic;
    self.navigationItem.title = [[TranslationsModel sharedInstance] getTranslationForKey:@"global.exercise"];
    
    helper = [Helper sharedHelper];
    fonts = [Fonts sharedFonts];
    colors = [Colors sharedColors];
    translationsModel = [TranslationsModel sharedInstance];
    animations = [Animations sharedAnimations];
    customNavigation = [CustomNavigation sharedInstance];
    delegate = (AppDelegate *)[[UIApplication sharedApplication] delegate];
    
    //Register Collection
    [_modulesCollectionView registerNib:[UINib nibWithNibName:@"ModulesCollectionViewCell" bundle:nil]
             forCellWithReuseIdentifier:@"ModulesCollectionViewCell"];
    [_exercisesCollectionView registerNib:[UINib nibWithNibName:@"ExercisesCollectionViewCell" bundle:nil]
             forCellWithReuseIdentifier:@"ExercisesCollectionViewCell"];
    
    skeletonView = [[SkeletonView alloc] initWithFrame:_contentView.frame];
    skeletonView.backgroundColor = [UIColor clearColor];

    //if app is first open, set the current date as the starting point for checking the first app rating appearance
    if(LAST_TIME_APPREVIEW_APPEARED == nil){
        [[AppReviewHelper sharedHelper] saveLastTimeAppReviewAppeared];
    }
}

/**
 *  TO DO:
 *      - checker if toast already shown, do nothing if shown already
 *      - find a way to remember the last function being called
 */

- (void)viewDidAppear:(BOOL)animated{
    [super viewDidAppear:YES];
    
    [[_scrollView viewWithTag:999] removeFromSuperview];
    self.view.backgroundColor = [UIColor clearColor];
    
    [ToastView sharedInstance].delegate = self;
    [NetworkManager sharedInstance].delegate = self;
    [[NetworkManager sharedInstance] connectivityMonitoring];
    
    //check if connected to internet connection. show popup if not
    if([[NetworkManager sharedInstance] isConnectionOffline]){
        if(!didShowConnectionError){
            UIViewController *vc = ((UINavigationController*)self->delegate.window.rootViewController).visibleViewController.presentedViewController;
            [[NetworkManager sharedInstance] showConnectionErrorInViewController:vc];
            didShowConnectionError = YES;
        }
        
        /*
         * show offline data
         */
        ExercisesSummary *exercisesSummary = [[ModulesModel sharedInstance] getExercisesSummary];
        if (exercisesSummary) {
            [self setExerciseSummary:exercisesSummary];
        }
        
        modules = [[ModulesModel sharedInstance] getAllModules];
        if ([modules count] > 0) {
            [_modulesCollectionView reloadData];
            
            selectedModule = selectedModule ?selectedModule :modules[0];
            difficulty = difficulty ?difficulty :Easy;
            exercisess = [[ModulesModel sharedInstance] getExercisesByModuleId:selectedModule.identifier andDifficulty:difficulty];
            [_exercisesCollectionView reloadData];
        }
        /*
         * end
         */
        return;
    }
    
    //request data from server
    if(!didRequestFromRemote){
        [self getNewUpdate];
    }
    
    //listener. force to reload for an update when an exercise is rated easy or too easy
    [[NSNotificationCenter defaultCenter] addObserver:self
                                             selector:@selector(getNewUpdate)
                                                 name:@"RatedAnExercise"
                                               object:nil];
}

- (void)viewDidDisappear:(BOOL)animated{
    [super viewDidDisappear:YES];
    [[NetworkManager sharedInstance] stopMonitoring];
    //[[NSNotificationCenter defaultCenter] removeObserver:self name:@"RatedAnExercise" object:nil];
}

#pragma mark - NetworkManagerDelegate

- (void)finishedConnectivityMonitoring:(AFNetworkReachabilityStatus)status{
    //0 - Offline
    if((long)status == 0){
        UIViewController *vc = ((UINavigationController*)self->delegate.window.rootViewController).visibleViewController.presentedViewController;
        [[NetworkManager sharedInstance] showConnectionErrorInViewController:vc];
    }
}

#pragma mark - ToastViewDelegate

- (void)retryConnection{
    if([[NetworkManager sharedInstance] isConnectionOffline]){
        UIViewController *vc = ((UINavigationController*)self->delegate.window.rootViewController).visibleViewController.presentedViewController;
        [[NetworkManager sharedInstance] showConnectionErrorInViewController:vc];
        return;
    }
    
    [self getNewUpdate];
}

- (void)viewDidLayoutSubviews{
    [super viewDidLayoutSubviews];
    
    if( !didLayoutReloaded ){
        [self setupUserInterface];
        didLayoutReloaded = YES;
    }
}

- (void)setupUserInterface{
    self.view.backgroundColor = [UIColor colorWithPatternImage:[UIImage imageNamed:@"bg"]];
    UIImageView *imgView = [[UIImageView alloc] initWithFrame:CGRectMake(0, 0, CGRectGetWidth(_contentView.frame), CGRectGetHeight(_contentView.frame) + 150)];
    imgView.image = [UIImage imageNamed:@"bg"];
    imgView.tag = 999;
    [_scrollView insertSubview:imgView atIndex:0];
    
    [_summaryView layoutIfNeeded];
    [_surpriseView layoutIfNeeded];
    [helper addDropShadowIn:_summaryView withColor:[UIColor darkGrayColor] andSetCornerRadiusTo:5.0];
    [helper addDropShadowIn:_surpriseView withColor:[UIColor darkGrayColor] andSetCornerRadiusTo:5.0];
    
    _pointsView.layer.cornerRadius = 5.0;
    _pointsView.clipsToBounds = YES;
    
    [_minimumBtn setImage:[UIImage imageNamed:@"thumbup"] forState:UIControlStateNormal];
    
    [self setTranslationsAndFonts];
    
    _summaryView.hidden = YES;
    _pointsView.hidden = YES;
}

- (void)setTranslationsAndFonts{
    
    _pointsLbl.font = [fonts bigFontBold];
    _exercisePointsLbl.font = [fonts normalFont];
    _exerciseUnlockedLbl.font = [fonts normalFont];
    _dailyminimumLbl.font = [fonts normalFont];
    _continousDaysLbl.font = [fonts normalFont];
    _unlockedValueLbl.font = [fonts headerFont];
    _daysValueLbl.font = [fonts headerFont];
    _selectModuleLbl.font = [fonts titleFont];
    _selectExerciseLbl.font = [fonts titleFont];
    _surpriseLbl.font = [fonts titleFont];
    _surpriseMsgLbl.font = [fonts normalFont];
    
    _exercisePointsLbl.text = [translationsModel getTranslationForKey:@"global.exercisepoints"];
    _exerciseUnlockedLbl.text = [translationsModel getTranslationForKey:@"ex.exercisesunlocked"];
    _dailyminimumLbl.text = [translationsModel getTranslationForKey:@"ex.dailyminimum"];
    _continousDaysLbl.text = [translationsModel getTranslationForKey:@"ex.continousdays"];
    _selectModuleLbl.text = [translationsModel getTranslationForKey:@"ex.selectdiff_title"];
    _selectExerciseLbl.text = [translationsModel getTranslationForKey:@"ex.selectex_title"];
    _surpriseLbl.text = [translationsModel getTranslationForKey:@"ex.suprise_title"];
    _surpriseMsgLbl.text = [translationsModel getTranslationForKey:@"ex.surprisedescription"];
    [_surpriseMsgLbl setLineHeight];
}

- (void)getNewUpdate{
    //show skeleton loading
    [self addSkeletonView];
    [self getExercisesSummary];
    [self getAllModulesWithExercises];
}

- (void)getExercisesSummary{
    [[ModulesServices sharedInstance] getExercisesSummaryWithCompletion:^(NSError *error,  int statusCode) {
        if(statusCode == NoInternetErrorStatusCode || statusCode == SlowInternetErrorStatusCode) {
            UIViewController *vc = ((UINavigationController*)self->delegate.window.rootViewController).visibleViewController.presentedViewController;
            [[NetworkManager sharedInstance] showConnectionErrorInViewController:vc statusCode:statusCode];
            return;
        }
        
        self->apiCounter += 1;
        [self removeSkeletonView];
        
        if (statusCode == 200) {
            ExercisesSummary *exercisesSummary = [[ModulesModel sharedInstance] getExercisesSummary];
            [self setExerciseSummary:exercisesSummary];
        }
    }];
}

- (void)setExerciseSummary:(ExercisesSummary *)summary{
    _pointsLbl.text = @(summary.exercisePoints).stringValue;
    _unlockedValueLbl.text = @(summary.exercisesUnlocked).stringValue;
    _daysValueLbl.text = @(summary.continuousDays).stringValue;
    
    UIImage *thumbupImg = [[UIImage imageNamed:@"thumbup"] imageWithRenderingMode:UIImageRenderingModeAlwaysTemplate];
    UIImage *thumbdownImg = [[UIImage imageNamed:@"thumbdown"] imageWithRenderingMode:UIImageRenderingModeAlwaysTemplate];
    
    if(summary.passedExercisesToday >= summary.personalExerciseGoal){
        [_minimumBtn setImage:thumbupImg forState:UIControlStateNormal];
        _minimumBtn.tintColor = [colors greenColor];
    }else{
        [_minimumBtn setImage:thumbdownImg forState:UIControlStateNormal];
        _minimumBtn.tintColor = [UIColor redColor];
    }
}

- (void)getAllModulesWithExercises{
    [[ModulesServices sharedInstance] getAllModulesWithExercisesWithCompletion:^(NSError *error, int statusCode) {
        if(statusCode == NoInternetErrorStatusCode || statusCode == SlowInternetErrorStatusCode) {
            UIViewController *vc = ((UINavigationController*)self->delegate.window.rootViewController).visibleViewController.presentedViewController;
            [[NetworkManager sharedInstance] showConnectionErrorInViewController:vc statusCode:statusCode];
            return;
        }
        
        self->apiCounter += 1;
        [self removeSkeletonView];
        
        if (statusCode == 200) {
            self->modules = [[ModulesModel sharedInstance] getAllModules];
            if ([self->modules count] > 0) {
                [self->_modulesCollectionView reloadData];
                
                if (!self->selectedModule) {
                    self->selectedModule = self->modules[0];
                }
                self->exercisess = [[ModulesModel sharedInstance] getExercisesByModuleId:self->selectedModule.identifier andDifficulty:(self->difficulty ?self->difficulty :Easy)];
                [self->_exercisesCollectionView reloadData];
            }
            
            return;
        }
        
        if(error){
            //there is error on the api side
            [[NetworkManager sharedInstance] showApiErrorInViewController:self->delegate.tabBarController error:error];
        }
    }];
}

#pragma mark - UICollectionview DataSource & Delegate
-(NSInteger)numberOfSectionsInCollectionView:(UICollectionView *)collectionView {
    return 1;
}

-(NSInteger)collectionView:(UICollectionView *)collectionView numberOfItemsInSection:(NSInteger)section{
    if (collectionView == _modulesCollectionView) {
        return [modules count];
    }else{
        return [exercisess count];
    }
}

- (UICollectionViewCell *)collectionView:(UICollectionView *)collectionView cellForItemAtIndexPath:(NSIndexPath *)indexPath {
    
    if (collectionView == _modulesCollectionView) {
        static NSString *identifier = @"ModulesCollectionViewCell";
        ModulesCollectionViewCell *cell = (ModulesCollectionViewCell *)[_modulesCollectionView dequeueReusableCellWithReuseIdentifier:identifier forIndexPath:indexPath];
        
        [cell layoutSubviews];
        [helper addDropShadowIn:cell.shadowView withColor:[UIColor darkGrayColor] andSetCornerRadiusTo:5.0];
        
        Modules *module = modules[indexPath.row];
        
        NSString *moduleName = [translationsModel getTranslationForKey:[NSString stringWithFormat:@"%@%@.name", Cf_domain_model_Module, module.identifier]];
        NSString *moduleDesc = [translationsModel getTranslationForKey:[NSString stringWithFormat:@"%@%@.description", Cf_domain_model_Module, module.identifier]];
        
        if (module.isModuleUnlocked == FALSE) {
            cell.lockedView.hidden = NO;
            
            cell.lockedNameLbl.text = moduleName;
            cell.activateLbl.text = [translationsModel getTranslationForKey:@"ex.activatenow"];
            
            [cell.imgView sd_setImageWithURL:[NSURL URLWithString:module.image] placeholderImage:nil];
            
            cell.lockedBtn.tag = indexPath.row;
            [cell.lockedBtn addTarget:self action:@selector(purchaseModule:) forControlEvents:UIControlEventTouchUpInside];
            
        }else{
            cell.lockedView.hidden = YES;
            
            cell.easyLbl.text = [[translationsModel getTranslationForKey:@"global.difficultyeasy"] uppercaseString];
            cell.mediumLbl.text = [[translationsModel getTranslationForKey:@"global.difficultymedium"] uppercaseString];
            cell.hardLbl.text = [[translationsModel getTranslationForKey:@"global.difficultyhard"] uppercaseString];
            
            cell.nameLbl.text = moduleName;
            cell.definitionLbl.text = moduleDesc;
            
            int easyPercentage = 0;
            if (module.totalExerciseEasy > 0) {
                easyPercentage = ((float)module.passedEasy/(float)module.totalExerciseEasy) * 100;
            }
            cell.easyValueLbl.text = [NSString stringWithFormat:@"%d%%",easyPercentage];
            
            int mediumPercentage = 0;
            if (module.totalExerciseMedium > 0) {
                mediumPercentage = ((float)module.passedMedium/(float)module.totalExerciseMedium) * 100;
            }
            cell.mediumValueLbl.text = [NSString stringWithFormat:@"%d%%",mediumPercentage];
            
            int hardPercentage = 0;
            if (module.totalExerciseHard > 0) {
                hardPercentage = ((float)module.passedHard/(float)module.totalExerciseHard) * 100;
            }
            cell.hardValueLbl.text = [NSString stringWithFormat:@"%d%%",hardPercentage];
            
            cell.completedLbl.text = [NSString stringWithFormat:@"%d %@ %d %@",module.unlockedExercises, [translationsModel getTranslationForKey:@"headsup.of"], module.numberOfExercises, [translationsModel getTranslationForKey:@"exmodule.unlocked"]];
            
            cell.easyBtn.tag = indexPath.row;
            cell.mediumBtn.tag = indexPath.row;
            cell.hardBtn.tag = indexPath.row;
            cell.moduleBtn.tag = indexPath.row;
            
            [cell.easyBtn.layer setValue:@"easy" forKey:@"difficulty"];
            [cell.mediumBtn.layer setValue:@"medium" forKey:@"difficulty"];
            [cell.hardBtn.layer setValue:@"hard" forKey:@"difficulty"];
            
            [cell.easyBtn addTarget:self action:@selector(getExercises:) forControlEvents:UIControlEventTouchUpInside];
            [cell.mediumBtn addTarget:self action:@selector(getExercises:) forControlEvents:UIControlEventTouchUpInside];
            [cell.hardBtn addTarget:self action:@selector(getExercises:) forControlEvents:UIControlEventTouchUpInside];
            [cell.moduleBtn addTarget:self action:@selector(viewModule:) forControlEvents:UIControlEventTouchUpInside];
            
            cell.easyView.backgroundColor = [UIColor clearColor];
            cell.easyLbl.textColor = [UIColor blackColor];
            cell.easyValueLbl.textColor = [UIColor blackColor];
            
            cell.mediumView.backgroundColor = [UIColor clearColor];
            cell.mediumLbl.textColor = [UIColor blackColor];
            cell.mediumValueLbl.textColor = [UIColor blackColor];
            
            cell.hardView.backgroundColor = [UIColor clearColor];
            cell.hardLbl.textColor = [UIColor blackColor];
            cell.hardValueLbl.textColor = [UIColor blackColor];
            
            if (selectedModuleIndex == indexPath.row) {// change this condition later w/ module.identifier
                if (difficulty == Easy) {
                    cell.easyView.backgroundColor = [colors easyColor];
                    cell.easyLbl.textColor = [UIColor whiteColor];
                    cell.easyValueLbl.textColor = [UIColor whiteColor];
                    
                }else if (difficulty == Medium) {
                    cell.mediumView.backgroundColor = [colors mediumColor];
                    cell.mediumLbl.textColor = [UIColor whiteColor];
                    cell.mediumValueLbl.textColor = [UIColor whiteColor];
                    
                }else if (difficulty == Hard) {
                    cell.hardView.backgroundColor = [colors hardColor];
                    cell.hardLbl.textColor = [UIColor whiteColor];
                    cell.hardValueLbl.textColor = [UIColor whiteColor];
                    
                }
            }

        }
        
        return cell;
    }else{
        Exercises *exercise = exercisess[indexPath.row];
        
        static NSString *identifier = @"ExercisesCollectionViewCell";
        ExercisesCollectionViewCell *cell = (ExercisesCollectionViewCell *)[_exercisesCollectionView dequeueReusableCellWithReuseIdentifier:identifier forIndexPath:indexPath];
        
        [cell layoutSubviews];
        [helper addDropShadowIn:cell.shadowView withColor:[UIColor darkGrayColor] andSetCornerRadiusTo:8.0];
        
        cell.exerciseNameLbl.text = [translationsModel getTranslationForKey:[NSString stringWithFormat:@"%@%@.name", Cf_domain_model_Exercise, exercise.identifier]];
        cell.pointsLbl.text = [translationsModel getTranslationForKey:@"global.points"];
        cell.setsLbl.text = [translationsModel getTranslationForKey:@"global.sets"];
        
        if (!exercise.unlocked) {
            cell.screenView.hidden = NO;
            
            [cell.statesBtn setImage:[UIImage imageNamed:@"locked"] forState:UIControlStateNormal];
            cell.statesBtn.backgroundColor = [UIColor lightGrayColor];
            
        }else{
            cell.screenView.hidden = YES;
            
            if(exercise.finished){
                [cell.statesBtn setImage:[UIImage imageNamed:@"check"] forState:UIControlStateNormal];
            }else{
                [cell.statesBtn setImage:[UIImage imageNamed:@"unlocked"] forState:UIControlStateNormal];
            }
            
            cell.statesBtn.backgroundColor = [colors greenColor];
        }
        
        [cell.imgView sd_setImageWithURL:[NSURL URLWithString:exercise.previewImage] placeholderImage:nil];
        
        /*
         * add gradient layer
         */
        for(id sublayer in cell.imgView.layer.sublayers){
            if([sublayer isKindOfClass:[CAGradientLayer class]]){
                [sublayer removeFromSuperlayer];
            }
        }
        
        CAGradientLayer *gradient = [CAGradientLayer layer];
        gradient.frame = cell.imgView.bounds;
        gradient.colors = @[(id)[[UIColor colorWithRed:0 green:0 blue:0 alpha:0.6] CGColor],
                            (id)[[UIColor clearColor] CGColor],
                            (id)[[UIColor clearColor] CGColor]];
        [cell.imgView.layer insertSublayer:gradient atIndex:0];
        /*
         * end
         */
        
        if ([exercise.type isEqualToString:@"repetition"]) {
            cell.repsOrTimesLbl.text = [translationsModel getTranslationForKey:@"global.reps"];
            cell.repsOrTimesValueLbl.text = @(exercise.repetitions).stringValue;
        }else if ([exercise.type isEqualToString:@"duration"]){
            cell.repsOrTimesLbl.text = [translationsModel getTranslationForKey:@"dailylog.times"];
            cell.repsOrTimesValueLbl.text = [NSString stringWithFormat:@"%ds",exercise.duration];
        }
        
        cell.setsValueLbl.text = @(exercise.sets).stringValue;
        cell.pointsValueLbl.text = @(exercise.points).stringValue;
        
        return cell;
        
    }
}

- (CGSize)collectionView:(UICollectionView *)collectionView layout:(UICollectionViewLayout*)collectionViewLayout sizeForItemAtIndexPath:(NSIndexPath *)indexPath{
    if (collectionView == _modulesCollectionView) {
        return CGSizeMake(324, 240);
    }else{
        return CGSizeMake(240, 280);
    }
}

-(void)collectionView:(UICollectionView *)collectionView didSelectItemAtIndexPath:(NSIndexPath *)indexPath{
    [self.view endEditing:YES];
    
    if (collectionView == _exercisesCollectionView) {
        Exercises *exercise = exercisess[indexPath.row];
        
        if (!exercise.unlocked) {
            [[CustomAlertView sharedInstance] showAlertInViewController:delegate.tabBarController
                                                              withTitle:@"XS Infinity"
                                                                message:[self->translationsModel getTranslationForKey:@"info.finishpreviousexercise"]
                                                      cancelButtonTitle:[translationsModel getTranslationForKey:@"global.rateokay"]
                                                        doneButtonTitle:nil];
            [[CustomAlertView sharedInstance] setCancelBlock:^(id result) {
                NSLog(@"okay");
            }];
        }else{
            
            SingleExerciseViewController *vc = [[SingleExerciseViewController alloc] initWithNibName:@"SingleExerciseViewController" bundle:nil];
            vc.exercise = exercise;
            vc.module = selectedModule;
            [self.navigationController pushViewController:vc animated: YES];
        }
    }
}

- (IBAction)getExercises:(id)sender{
    UIButton *btn = (UIButton *)sender;
    NSString *difficultyStr = [btn.layer valueForKey:@"difficulty"];
    
    if ([difficultyStr isEqualToString:@"easy"]) {
        difficulty = Easy;
    }else if ([difficultyStr isEqualToString:@"medium"]) {
        difficulty = Medium;
    }else if ([difficultyStr isEqualToString:@"hard"]) {
        difficulty = Hard;
    }
    
    //Reload modules collection when selecting difficulty for module
    selectedModuleIndex = (int)btn.tag;
    [_modulesCollectionView reloadData];
    
    selectedModule = modules[btn.tag];
    
    exercisess = [[ModulesModel sharedInstance] getExercisesByModuleId:selectedModule.identifier andDifficulty: difficulty];
    [_exercisesCollectionView reloadData];
    
    [DejalBezelActivityView removeViewAnimated:YES];
    
}

- (IBAction)viewModule:(id)sender{
    Modules *module = modules[[sender tag]];
    
    PaymentMethodViewController *vc = [[PaymentMethodViewController alloc] initWithNibName:@"PaymentMethodViewController" bundle:nil];
    vc.module = module;
    [self.navigationController pushViewController:vc animated:YES];
    
    /*SingleModuleViewController *vc = [[SingleModuleViewController alloc] initWithNibName:@"SingleModuleViewController" bundle:nil];
    vc.module = module;
    [self.navigationController pushViewController:vc animated: YES];*/
}

- (IBAction)purchaseModule:(id)sender{
    Modules *module = modules[[sender tag]];
    
    LockedModuleViewController *vc = [[LockedModuleViewController alloc] initWithNibName:@"LockedModuleViewController" bundle:nil];
    vc.module = module;
    [self.navigationController pushViewController:vc animated: YES];
}

- (IBAction)surpriseWorkout:(id)sender {
    SurpriseWorkoutViewController *vc = [[SurpriseWorkoutViewController alloc] initWithNibName:@"SurpriseWorkoutViewController" bundle:nil];
    [self.navigationController pushViewController:vc animated: YES];
}

- (IBAction)changeLanguage:(id)sender{
    if (_segmentedControl.selectedSegmentIndex == 0) {
        SET_LANGUAGE_KEY(@"en");
    } else if(_segmentedControl.selectedSegmentIndex == 1) {
        SET_LANGUAGE_KEY(@"cn");
    }
    self.navigationItem.title = [[TranslationsModel sharedInstance] getTranslationForKey:@"global.exercise"];
    [self setTranslationsAndFonts];
    [_exercisesCollectionView reloadData];
    [_modulesCollectionView reloadData];
}

#pragma mark - Skeleton Views

- (void)addSkeletonView{
    apiCounter = 0;
    [[_scrollView viewWithTag:999] removeFromSuperview];
    [_modulesCollectionView layoutIfNeeded];
    [_exercisesCollectionView layoutIfNeeded];
    [_pointsView layoutIfNeeded];
    [_summaryView layoutIfNeeded];
    
    _summaryView.hidden = NO;
    _pointsView.hidden = YES;
    _modulesCollectionView.hidden = YES;
    _exercisesCollectionView.hidden = YES;
    
    [skeletonView addSkeletonOnExercisesModulesCollectionViewWithBounds:_modulesCollectionView.frame withCellSize:CGSizeMake(316, 230)];
    [skeletonView addSkeletonOnExercisesCollectionViewWithBounds:_exercisesCollectionView.frame withCellSize:CGSizeMake(240, 280)];
    [skeletonView addSkeletonFor:_pointsView isText:NO];
    [skeletonView addSkeletonOn:_summaryView for:_exerciseUnlockedLbl isText:YES];
    [skeletonView addSkeletonOn:_summaryView for:_dailyminimumLbl isText:YES];
    [skeletonView addSkeletonOn:_summaryView for:_continousDaysLbl isText:YES];
    [skeletonView addSkeletonOn:_summaryView for:_unlockedValueLbl isText:YES];
    [skeletonView addSkeletonOn:_summaryView for:_minimumBtn isText:NO];
    [skeletonView addSkeletonOn:_summaryView for:_daysValueLbl isText:YES];
    [_contentView addSubview:skeletonView];
}

- (void)removeSkeletonView{
    if (apiCounter == 2) {
        _summaryView.hidden = NO;
        _pointsView.hidden = NO;
        _modulesCollectionView.hidden = NO;
        _exercisesCollectionView.hidden = NO;
        
        [skeletonView remove];
        didRequestFromRemote = YES;
        apiCounter = 0;
    }
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
    _lastContentOffset = scrollOffset;
    
    [customNavigation addOrRemoveBlurEffectAndLineForNavigationInViewController:self];
}

@end
