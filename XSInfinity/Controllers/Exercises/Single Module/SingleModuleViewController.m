//
//  SingleModuleViewController.m
//  XSInfinity
//
//  Created by Joseph Marvin Magdadaro on 6/3/18.
//  Copyright © 2018 Joseph Marvin Magdadaro. All rights reserved.
//

#import "SingleModuleViewController.h"
#import <SDWebImage/UIImageView+WebCache.h>
#import "SingleModuleHeaderTableViewCell.h"
#import "SingleModuleTableViewCell.h"
#import "Helper.h"
#import "TranslationsModel.h"
#import "Animations.h"
#import "Colors.h"
#import "ExercisesObj.h"
#import "CustomAlertView.h"
#import "SingleExerciseViewController.h"
#import "CustomNavigation.h"
#import "ModulesServices.h"
#import "DejalActivityView.h"
#import "AppDelegate.h"
#import "ModulesModel.h"
#import "BookmarkedExercises.h"
#import "Exercises.h"
#import "TextViewOverlayViewController.h"
#import "NetworkManager.h"
#import "ToastView.h"

@interface SingleModuleViewController ()<NetworkManagerDelegate, ToastViewDelegate>{
    Helper *helper;
    Animations *animations;
    TranslationsModel *translationsModel;
    Colors *colors;
    AppDelegate *delegate;
    NSMutableArray *exercises;
    NSArray *bookmarkedExercises;
    BOOL didLayoutReloaded;
    int lastIndex;
    NSString *moduleName;
    
    ModuleServiceApi lastAPiCall;
    UIButton *lastButtonAction;
}

@property (weak, nonatomic) IBOutlet UITableView *tableView;

@property (nonatomic, assign) CGFloat lastContentOffset;

@end

@implementation SingleModuleViewController

-(void)viewWillAppear:(BOOL)animated{
    [super viewWillAppear:YES];
    [[CustomNavigation sharedInstance] addOrRemoveBlurEffectAndLineForNavigationInViewController:self];
    
    [self setExercises];
}

- (void)viewDidLoad {
    [super viewDidLoad];
    self.navigationController.navigationBar.hidden = NO;
    self.navigationItem.largeTitleDisplayMode = UINavigationItemLargeTitleDisplayModeNever;
    
    helper = [Helper sharedHelper];
    animations = [Animations sharedAnimations];
    colors = [Colors sharedColors];
    translationsModel = [TranslationsModel sharedInstance];
    delegate = (AppDelegate *)[[UIApplication sharedApplication] delegate];
    
    moduleName = [translationsModel getTranslationForKey:[NSString stringWithFormat:@"%@%@.name", Cf_domain_model_Module, self.module.identifier]];
    
    self.navigationItem.title = moduleName;
    
    [self setExercises];
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

- (void)retryConnection{
    if(!lastAPiCall){
        if([[NetworkManager sharedInstance] isConnectionOffline]){
            [[NetworkManager sharedInstance] showConnectionErrorInViewController:delegate.tabBarController];
        }
        return;
    }
    
    switch (lastAPiCall) {
        case ModuleServiceApi_CreateBookmark:
            [self addToBookmark:lastButtonAction];
            break;
        case ModuleServiceApi_RemoveBookmark:
            [self removeBookmarked:lastButtonAction];
            break;
        default:
            break;
    }
}

- (void)cancelToast{
    lastAPiCall = 0;
    lastButtonAction = nil;
}

-(void)viewDidLayoutSubviews{
    [super viewDidLayoutSubviews];
    [_tableView layoutIfNeeded];
    
    if( !didLayoutReloaded ){
        [self setupUserInterface];
        lastIndex = 0;
        [_tableView reloadData];
        
        didLayoutReloaded = YES;
    }
}

- (void)setupUserInterface{
    [[Animations sharedAnimations] setTabBar:delegate.tabBarController.tabBar fromViewController:self visible:YES animated:NO];
    
    [[CustomNavigation sharedInstance] addOrRemoveBlurEffectAndLineForNavigationInViewController:self];
}

#pragma mark - UIScrollView Delegate
- (void)scrollViewDidScroll:(UIScrollView *)scrollView{
    [self.view layoutIfNeeded];
    
    float scrollOffset = _tableView.contentOffset.y;
    float maxOffSet = _tableView.contentSize.height - CGRectGetHeight(_tableView.frame);
    
    if (scrollOffset > 0 && (scrollOffset >= _lastContentOffset || maxOffSet <= scrollOffset)){//scroll down
        [animations setTabBar:delegate.tabBarController.tabBar fromViewController:self visible:NO animated:YES];
    }
    else{//scroll up
        [animations setTabBar:delegate.tabBarController.tabBar fromViewController:self visible:YES animated:YES];
    }
    _lastContentOffset = scrollOffset;
    
    [[CustomNavigation sharedInstance] addOrRemoveBlurEffectAndLineForNavigationInViewController:self];
    
}

- (void)setExercises{
    exercises = [NSMutableArray new];
    
    NSArray *exercisesArr = [[ModulesModel sharedInstance] getExercisesByModuleId:self.module.identifier];
    
    bookmarkedExercises = [[ModulesModel sharedInstance] getAllBookmarkedExercises];
    
    NSArray *unlockedExercises = [[exercisesArr filteredArrayUsingPredicate:[NSPredicate predicateWithFormat:@"disabled == 0"]] mutableCopy];
    NSArray *lockedExercises = [[exercisesArr filteredArrayUsingPredicate:[NSPredicate predicateWithFormat:@"disabled == 1"]] mutableCopy];
    
    NSArray *easyExercises = [[unlockedExercises filteredArrayUsingPredicate:[NSPredicate predicateWithFormat:@"difficulty = %@",@"easy"]] mutableCopy];
    NSArray *mediumExercises = [[unlockedExercises filteredArrayUsingPredicate:[NSPredicate predicateWithFormat:@"difficulty = %@",@"medium"]] mutableCopy];
    NSArray *hardExercises = [[unlockedExercises filteredArrayUsingPredicate:[NSPredicate predicateWithFormat:@"difficulty = %@",@"hard"]] mutableCopy];

    [exercises addObjectsFromArray:[easyExercises mutableCopy]];
    [exercises addObjectsFromArray:[mediumExercises mutableCopy]];
    [exercises addObjectsFromArray:[hardExercises mutableCopy]];
    [exercises addObjectsFromArray:[lockedExercises mutableCopy]];
    [_tableView reloadData];
}

- (CGFloat)tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath{
    if (indexPath.row == 0) {
        return 280;
    }else{
        return 170;
    }
}

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section{
    return [exercises count]+1;
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath{
    
    if (indexPath.row == 0) {
        static NSString *simpleTableIdentifier = @"singleModuleHeaderTableViewCell";
        
        SingleModuleHeaderTableViewCell *cell = (SingleModuleHeaderTableViewCell *)[tableView dequeueReusableCellWithIdentifier:simpleTableIdentifier];
        
        if (cell == nil) {
            NSArray *nib = [[NSBundle mainBundle] loadNibNamed:@"SingleModuleHeaderTableViewCell" owner:self options:nil];
            cell = [nib objectAtIndex:0];
        }
        cell.selectionStyle = UITableViewCellSelectionStyleNone;
        
        [cell layoutSubviews];
        [helper addDropShadowIn:cell.shadowView withColor:[UIColor darkGrayColor] andSetCornerRadiusTo:5.0];
        
        if (lastIndex <= indexPath.row){
            [animations fadeInBottomToTopAnimationOnCell:cell withDelay:0.f];
        }
        
        cell.moduleNameLbl.text = moduleName;
        [cell.imgView sd_setImageWithURL:[NSURL URLWithString:self.module.image]];
        
        [cell.howToBtn addTarget:self action:@selector(howToUse:) forControlEvents:UIControlEventTouchUpInside];
        
        cell.easyValueLbl.text = [NSString stringWithFormat:@"%d of %d %@",self.module.passedEasy ,self.module.totalExerciseEasy ,[translationsModel getTranslationForKey:@"exmodule.unlocked"]];
        cell.medValueLbl.text = [NSString stringWithFormat:@"%d of %d %@",self.module.passedMedium ,self.module.totalExerciseMedium ,[translationsModel getTranslationForKey:@"exmodule.unlocked"]];
        cell.hardValueLbl.text = [NSString stringWithFormat:@"%d of %d %@",self.module.passedHard ,self.module.totalExerciseHard ,[translationsModel getTranslationForKey:@"exmodule.unlocked"]];
        
        // NOTE: * 80, cause the max width of difficulty color view is 80
        int  easyColorViewWidth = ((float)self.module.passedEasy/(float)self.module.totalExerciseEasy) * 80;
        int  mediumColorViewWidth = ((float)self.module.passedMedium/(float)self.module.totalExerciseMedium) * 80;
        int  hardColorViewWidth = ((float)self.module.passedHard/(float)self.module.totalExerciseHard) * 80;
        
        if (easyColorViewWidth <= 0)
            easyColorViewWidth = 5;
        if (mediumColorViewWidth <= 0)
            mediumColorViewWidth = 5;
        if (hardColorViewWidth <= 0)
            hardColorViewWidth = 5;
        
        cell.easyValueViewWidthConstraint.constant = easyColorViewWidth>80?80:easyColorViewWidth;
        cell.medValueViewWidthConstraint.constant = mediumColorViewWidth>80?80:mediumColorViewWidth;
        cell.hardValueViewWidthConstraint.constant =  hardColorViewWidth>80?80:hardColorViewWidth;
        
        lastIndex = (int)indexPath.row;
        
        return cell;
    }else{
        static NSString *simpleTableIdentifier = @"singleModuleTableViewCell";
        
        SingleModuleTableViewCell *cell = (SingleModuleTableViewCell *)[tableView dequeueReusableCellWithIdentifier:simpleTableIdentifier];
        
        if (cell == nil) {
            NSArray *nib = [[NSBundle mainBundle] loadNibNamed:@"SingleModuleTableViewCell" owner:self options:nil];
            cell = [nib objectAtIndex:0];
        }
        cell.selectionStyle = UITableViewCellSelectionStyleNone;
        
        [cell layoutSubviews];
        [helper addDropShadowIn:cell.imgShadowView withColor:[UIColor darkGrayColor] andSetCornerRadiusTo:5.0];
        
        if (lastIndex < indexPath.row){
            float delay = indexPath.row * 0.1;
            [animations fadeInBottomToTopAnimationOnCell:cell withDelay:delay];
        }
        
        ExercisesObj *exercise = exercises[indexPath.row - 1];
        
        NSString *exerciseName = [translationsModel getTranslationForKey:[NSString stringWithFormat:@"%@%@.name", Cf_domain_model_Exercise, exercise.identifier]];
        cell.exerciseNameLbl.text = exerciseName;
        
        if ([exercise.difficulty isEqualToString:@"easy"]) {
            cell.difficultyColorView.backgroundColor = [colors easyColor];
        }else if ([exercise.difficulty isEqualToString:@"medium"]) {
            cell.difficultyColorView.backgroundColor = [colors mediumColor];
        }else if ([exercise.difficulty isEqualToString:@"hard"]) {
            cell.difficultyColorView.backgroundColor = [colors hardColor];
        }
        
        cell.setsValueLbl.text = @(exercise.sets).stringValue;
        
        if ([exercise.type isEqualToString:@"repetition"]) {
            cell.repsOrTimesLbl.text = [[TranslationsModel sharedInstance] getTranslationForKey:@"global.reps"];
            cell.repsOrTimesValueLbl.text = @(exercise.repetitions).stringValue;
        }else if ([exercise.type isEqualToString:@"duration"]){
            cell.repsOrTimesLbl.text = [[TranslationsModel sharedInstance] getTranslationForKey:@"global.minutes"];
            int minutes = exercise.duration / 60;
            int seconds = exercise.duration % 60;
            float duration = minutes + (seconds * 0.01);
            cell.repsOrTimesValueLbl.text = [NSString stringWithFormat:@"%.2f",duration];
        }
        
        // NOTE: Replace it with number of times exercise finished - to be added in api return
        cell.timesValueLbl.text = @"5";
        
        [cell.imgView sd_setImageWithURL:[NSURL URLWithString:exercise.previewImage] placeholderImage:nil];
        
        if (!exercise.unlocked) {
            [cell.lockBtn setImage:[UIImage imageNamed:@"locked"] forState:UIControlStateNormal];
            cell.lockBtn.backgroundColor = [UIColor grayColor];
        }else{
            cell.lockBtn.backgroundColor = [colors greenColor];
            if(exercise.finished){
                [cell.lockBtn setImage:[UIImage imageNamed:@"check"] forState:UIControlStateNormal];
            }else{
                [cell.lockBtn setImage:[UIImage imageNamed:@"unlocked"] forState:UIControlStateNormal];
            }
        }
        
        cell.heartBtn.tag = indexPath.row;
        [cell.heartBtn.layer setValue:@"" forKey:@"bookmarkId"];
        [cell.heartBtn setImage:[UIImage imageNamed:@"heart_unselected"] forState:UIControlStateNormal];
        [cell.heartBtn addTarget:self action:@selector(bookmark:) forControlEvents:UIControlEventTouchUpInside];
        
        for (BookmarkedExercises *bookmarked in bookmarkedExercises){
            if ([exercise.identifier isEqual:bookmarked.exerciseId]) {
                [cell.heartBtn.layer setValue:bookmarked.bookmarkId forKey:@"bookmarkId"];
                [cell.heartBtn setImage:[UIImage imageNamed:@"heart_selected"] forState:UIControlStateNormal];
            }
        }
        
        lastIndex = (int)indexPath.row;
        
        return cell;
    }
   
}

- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath{
    [self.view endEditing:YES];
    
    if (indexPath.row > 0){
        Exercises *exercise = exercises[indexPath.row - 1];
        
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
            vc.module = self.module;
            vc.exercise = exercise;
            [self.navigationController pushViewController:vc animated: YES];
        }
    }
}

- (IBAction)bookmark:(id)sender{
    UIButton *btn = (UIButton *)sender;
    NSString *bookmarkId = [btn.layer valueForKey:@"bookmarkId"];
    if ([bookmarkId length] > 0){
        [self removeBookmarked:btn];
    }else{
        [self addToBookmark:btn];
    }
    
}

- (void)removeBookmarked:(UIButton *)btn{
    NSString *bookmarkId = [btn.layer valueForKey:@"bookmarkId"];
    
    [DejalBezelActivityView activityViewForView:delegate.tabBarController.view];
    [[ModulesServices sharedInstance] removeBookMark:bookmarkId withCompletion:^(NSError *error, int statusCode) {
        [DejalBezelActivityView removeViewAnimated:YES];
        
        if(statusCode == NoInternetErrorStatusCode || statusCode == SlowInternetErrorStatusCode) {
            [[NetworkManager sharedInstance] showConnectionErrorInViewController:self->delegate.tabBarController statusCode:statusCode];
            self->lastAPiCall = ModuleServiceApi_RemoveBookmark;
            self->lastButtonAction = btn;
            return;
        }
        
        self->lastAPiCall = 0;
        self->lastButtonAction = nil;
        
        //successfull
        if (!error && statusCode == 204) {
            [[ModulesModel sharedInstance] removeBookmarked:bookmarkId];
            [btn.layer setValue:@"" forKey:@"bookmarkId"];
            [btn setImage:[UIImage imageNamed:@"heart_unselected"] forState:UIControlStateNormal];
            return;
        }
        
        if(error){
            //there is error on the api side
            [[NetworkManager sharedInstance] showApiErrorInViewController:self->delegate.tabBarController error:error];
            self->lastAPiCall = ModuleServiceApi_RemoveBookmark;
            self->lastButtonAction = btn;
        }
    }];
}

- (void)addToBookmark:(UIButton *)btn{
    ExercisesObj *exercise = exercises[btn.tag - 1];
    
    [DejalBezelActivityView activityViewForView:delegate.tabBarController.view];
    [[ModulesServices sharedInstance] createBookMarkForExercise:exercise.identifier withCompletion:^(NSError *error, int statusCode) {
        [DejalBezelActivityView removeViewAnimated:YES];
        
        if(statusCode == NoInternetErrorStatusCode || statusCode == SlowInternetErrorStatusCode) {
            [[NetworkManager sharedInstance] showConnectionErrorInViewController:self->delegate.tabBarController statusCode:statusCode];
            self->lastAPiCall = ModuleServiceApi_CreateBookmark;
            self->lastButtonAction = btn;
            return;
        }
        
        self->lastAPiCall = 0;
        self->lastButtonAction = nil;
        
        if (!error && (statusCode == 201 || statusCode == 200)) {
            [btn setImage:[UIImage imageNamed:@"heart_selected"] forState:UIControlStateNormal];
            [[Animations sharedAnimations] zoomSpringAnimationForView:btn];
            
            [[ModulesServices sharedInstance] getBookmarkedExercisesWithCompletion:^(NSError *error, BOOL successful) {
                NSLog(@"Done updating bookmark list");
                self->bookmarkedExercises = [[ModulesModel sharedInstance] getAllBookmarkedExercises];
                for (BookmarkedExercises *bookmarked in self->bookmarkedExercises){
                    if ([exercise.identifier isEqual:bookmarked.exerciseId]) {
                        [btn.layer setValue:bookmarked.bookmarkId forKey:@"bookmarkId"];
                    }
                }
            }];
            return;
        }
        
        if(error){
            //there is error on the api side
            [[NetworkManager sharedInstance] showApiErrorInViewController:self->delegate.tabBarController error:error];
            self->lastAPiCall = ModuleServiceApi_CreateBookmark;
            self->lastButtonAction = btn;
        }
    }];
}

- (IBAction)howToUse:(id)sender{
    TextViewOverlayViewController *vc = [[TextViewOverlayViewController alloc] initWithNibName:@"TextViewOverlayViewController" bundle:nil];
    
    moduleName = [translationsModel getTranslationForKey:[NSString stringWithFormat:@"%@%@.name", Cf_domain_model_Module, self.module.identifier]];
    NSString *desc = [translationsModel getTranslationForKey:[NSString stringWithFormat:@"%@%@.howToUseDescription", Cf_domain_model_Module, self.module.identifier]];
    
    vc.titleStr = moduleName;
    vc.desc = desc;
    
    vc.view.backgroundColor = [UIColor clearColor];
    vc.modalPresentationStyle = UIModalPresentationOverCurrentContext;
    
    [delegate.tabBarController presentViewController:vc animated: NO completion:nil];
}

- (IBAction)back:(id)sender {
    [self.navigationController popViewControllerAnimated:YES];
}


@end
