//
//  HabitsViewController.m
//  Habits
//
//  Created by Joseph Marvin Magdadaro on 2/25/18.
//  Copyright © 2018 Joseph Marvin Magdadaro. All rights reserved.
//

#import "HabitsViewController.h"
#import <SDWebImage/UIImageView+WebCache.h>
#import "NetworkManager.h"
#import "DejalActivityView.h"
#import "HabitsCollectionViewCell.h"
#import "HabitInfoViewController.h"
#import "RegistrationViewController.h"
#import "CustomAlertView.h"
#import "Animations.h"
#import "Colors.h"
#import "TranslationsModel.h"
#import "Helper.h"
#import "Fonts.h"
#import "AppDelegate.h"
#import "CustomNavigation.h"
#import "HabitsServices.h"
#import "SkeletonView.h"
#import "HabitsModel.h"
#import "HabitsOverview.h"
#import "Habits.h"
#import "ToastView.h"
#import "AppReviewHelper.h"

@interface HabitsViewController ()<UICollectionViewDelegate,UICollectionViewDataSource, UIScrollViewDelegate, UIScrollViewAccessibilityDelegate, NetworkManagerDelegate, ToastViewDelegate>{
    CustomAlertView *customAlertView;
    TranslationsModel *translationsModel;
    Animations *animations;
    Colors *colors;
    Helper *helper;
    Fonts *fonts;
    AppDelegate *delegate;
    CustomNavigation *customNavigation;
    SkeletonView *skeletonView;
    NSArray *habits, *unlockedHabits;
    int numOfHabitsUnlocked;
    int finishedhabitsCounter;
    int successiveDays;
    int apiCounter;
    BOOL markAsFinished;
    BOOL didLayoutReloaded;
    BOOL didShowConnectionError;
    BOOL didRequestFromRemote;
    
    HabitsServicesApi lastApiCall;
    id lastSender;
}

@property (weak, nonatomic) IBOutlet UIScrollView *scrollView;
@property (weak, nonatomic) IBOutlet UIView *contentView;

@property (weak, nonatomic) IBOutlet UIView *habitPointsView;
@property (weak, nonatomic) IBOutlet UIView *pointsView;
@property (weak, nonatomic) IBOutlet UILabel *pointsLbl;
@property (weak, nonatomic) IBOutlet UILabel *pointsValueLbl;
@property (weak, nonatomic) IBOutlet UILabel *habitsUnlockedLbl;
@property (weak, nonatomic) IBOutlet UILabel *habitsUnlockedValueLbl;
@property (weak, nonatomic) IBOutlet UILabel *successiveDaysLbl;
@property (weak, nonatomic) IBOutlet UILabel *successiveDaysValueLbl;

@property (weak, nonatomic) IBOutlet UILabel *dailyTrackerLbl;
@property (weak, nonatomic) IBOutlet UILabel *lastResetLbl;
@property (weak, nonatomic) IBOutlet UILabel *habitCyclesLbl;

@property (weak, nonatomic) IBOutlet UILabel *availableHabitsLbl;

@property (weak, nonatomic) IBOutlet UIButton *helpBtn;

@property (weak, nonatomic) IBOutlet UIButton *finishAllBtn;

@property (weak, nonatomic) IBOutlet UICollectionView *habitsCollectionView;

@property (nonatomic, assign) CGFloat lastContentOffset;

@property (weak, nonatomic) IBOutlet UIView *trackerButtonsView;
@property (weak, nonatomic) IBOutlet UIButton *giftBtn;
@property (strong, nonatomic) IBOutletCollection(UIButton) NSArray *successTrackerButtons;

@end

@implementation HabitsViewController

-(void)viewWillAppear:(BOOL)animated{
    [super viewWillAppear:YES];
    float scrollOffset = _scrollView.contentOffset.y;
    
    if (scrollOffset < 0)
        [[Animations sharedAnimations] setTabBar:delegate.tabBarController.tabBar fromViewController:self visible:YES animated:NO];
    
    [[CustomNavigation sharedInstance] addOrRemoveBlurEffectAndLineForNavigationInViewController:self];
}

- (void)viewDidLoad {
    [super viewDidLoad];
    self.navigationController.navigationBar.hidden = NO;
    self.navigationItem.hidesBackButton = YES;
    [self.navigationController.navigationBar setBackgroundImage:[UIImage new]
                                                  forBarMetrics:UIBarMetricsDefault];
    self.navigationController.navigationBar.shadowImage = [UIImage new];
    self.navigationController.navigationBar.prefersLargeTitles = TRUE;
    self.navigationItem.largeTitleDisplayMode = UINavigationItemLargeTitleDisplayModeAutomatic;
    self.navigationItem.title = [[TranslationsModel sharedInstance] getTranslationForKey:@"perf.habit"];
    
    customAlertView = [CustomAlertView sharedInstance];
    animations = [Animations sharedAnimations];
    translationsModel = [TranslationsModel sharedInstance];
    colors = [Colors sharedColors];
    helper = [Helper sharedHelper];
    fonts = [Fonts sharedFonts];
    customNavigation = [CustomNavigation sharedInstance];
    delegate = (AppDelegate *)[[UIApplication sharedApplication] delegate];
    
    //Register Collection
    [_habitsCollectionView registerNib:[UINib nibWithNibName:@"HabitsCollectionViewCell" bundle:nil] forCellWithReuseIdentifier:@"HabitsCollectionViewCell"];
    
    skeletonView = [[SkeletonView alloc] initWithFrame:_contentView.frame];
    skeletonView.backgroundColor = [UIColor clearColor];
}

- (void)viewDidAppear:(BOOL)animated{
    [super viewDidAppear:YES];
    [[_scrollView viewWithTag:999] removeFromSuperview];
    self.view.backgroundColor = [UIColor clearColor];
    
    [[ToastView sharedInstance] setDelegate:self];
    [[NetworkManager sharedInstance] setDelegate:self];
    [[NetworkManager sharedInstance] connectivityMonitoring];
    
    _habitPointsView.hidden = NO;
    _pointsView.hidden = NO;
    _lastResetLbl.hidden = NO;
    _habitCyclesLbl.hidden = NO;
    _trackerButtonsView.hidden = NO;
    _finishAllBtn.hidden = NO;
    
    
    [self setTranslationsAndFonts];
    
    if([[NetworkManager sharedInstance] isConnectionOffline]){
        if(!didShowConnectionError){
            [[NetworkManager sharedInstance] showConnectionErrorInViewController:delegate.tabBarController];
            didShowConnectionError = YES;
        }
        
        /*
         * show offline data
         */
        HabitsOverview *habitsOverview = [[HabitsModel sharedInstance] getHabitsOverview];
        if (habitsOverview) {
            [self setHabitsOverview:habitsOverview];
        }
        
        habits = [[HabitsModel sharedInstance] getAllHabits];
        if ([habits count] > 0) {
            [self toggleFinishedAllHabits];
            [_habitsCollectionView reloadData];
        }
        /*
         * end
         */
        return;
    }
    
    if(!didRequestFromRemote){
        [self addSkeletonView];
        
        //TO DO: call getHabitsOverview first
        [self getHabitsOverview];
    }
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
        [self addSkeletonView];
        [self getHabitsOverview];//TO DO: change to getHabitsOverview
    }
    
    switch (lastApiCall) {
        case HabitsServicesApi_FinishHabit:
            [self markAsFinished:lastSender];
            break;
        case HabitsServicesApi_UndoHabit:
            [self undoHabit:lastSender];
            break;
        case HabitsServicesApi_FinishAllHabits:
            [self finishAllHabits:nil];
            break;
            
        default:
            break;
    }
}
- (void)cancelToast{
    lastApiCall = 0;
    lastSender = nil;
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
    UIImageView *imgView = [[UIImageView alloc] initWithFrame:CGRectMake(0, 0, CGRectGetWidth(_contentView.frame), CGRectGetHeight(_contentView.frame) + 150)];
    imgView.image = [UIImage imageNamed:@"bg"];
    imgView.tag = 999;
    [_scrollView insertSubview:imgView atIndex:0];
    
    [_habitPointsView layoutIfNeeded];
    [helper addDropShadowIn:_habitPointsView withColor:[UIColor darkGrayColor] andSetCornerRadiusTo:5.0];
    
   // _finishAllBtn.backgroundColor = [colors blueColor];
    _finishAllBtn.titleLabel.font = [fonts normalFontBold];
    [_finishAllBtn setTitle:[translationsModel getTranslationForKey:@"habit.finishall_button"] forState:UIControlStateNormal];
    
    [self setTranslationsAndFonts];
    
    _habitPointsView.hidden = YES;
    _pointsView.hidden = YES;
    _lastResetLbl.hidden = YES;
    _habitCyclesLbl.hidden = YES;
    _trackerButtonsView.hidden = YES;
    _helpBtn.hidden = YES;
    _finishAllBtn.hidden = YES;
    
}

- (void)setTranslationsAndFonts{
    _pointsLbl.font = [fonts normalFont];
    _pointsValueLbl.font = [fonts bigFontBold];
    _habitsUnlockedLbl.font = [fonts normalFont];
    _habitsUnlockedValueLbl.font = [fonts headerFont];
    _successiveDaysLbl.font = [fonts normalFont];
    _successiveDaysValueLbl.font = [fonts headerFont];
    _dailyTrackerLbl.font = [fonts titleFont];
    _lastResetLbl.font = [fonts normalFont];
    _habitCyclesLbl.font = [fonts normalFont];
    _availableHabitsLbl.font = [fonts titleFont];
    
    self.navigationItem.title = [[TranslationsModel sharedInstance] getTranslationForKey:@"perf.habit"];
    
    _pointsLbl.text = [translationsModel getTranslationForKey:@"global.habitpoints"];
    _habitsUnlockedLbl.text = [translationsModel getTranslationForKey:@"habit.habitsunlocked"];
    _successiveDaysLbl.text = [translationsModel getTranslationForKey:@"habit.successivedays"];
    _dailyTrackerLbl.text = [translationsModel getTranslationForKey:@"habit.tracker_title"];
    _lastResetLbl.text = [NSString stringWithFormat:@"%@",[translationsModel getTranslationForKey:@"habit.lastreset"]];
    _habitCyclesLbl.text = [NSString stringWithFormat:@"%@",[translationsModel getTranslationForKey:@"habit.cyclescompleted"]];
    _availableHabitsLbl.text = [translationsModel getTranslationForKey:@"habit.availhabits"];
}

- (void)getHabitsOverviewUpdates{
    [[HabitsServices sharedInstance] getHabitsOverviewWithCompletion:^(NSError *error, int statusCode, NSArray *notPassedHabits, NSArray *unlockedHabits) {
        if (statusCode == 200) {
            NSLog(@"Unlocked Habits = %@", unlockedHabits);
            NSLog(@"Not Passed Habits = %@", notPassedHabits);
            //TO DO: call all habits api and identify the locked and finished habits
            HabitsOverview *habitsOverview = [[HabitsModel sharedInstance] getHabitsOverview];
            [self setHabitsOverview:habitsOverview];
        }
    }];
}

- (void)getHabitsOverview{
    //TO DO: return the unlocked and unfinish habits
    [[HabitsServices sharedInstance] getHabitsOverviewWithCompletion:^(NSError *error, int statusCode, NSArray *notPassedHabits, NSArray *unlockedHabits) {
        if(statusCode == NoInternetErrorStatusCode || statusCode == SlowInternetErrorStatusCode) {
            [[NetworkManager sharedInstance] showConnectionErrorInViewController:self->delegate.tabBarController statusCode:statusCode];
            return;
        }
        
        self->apiCounter += 1;
        [self removeSkeletonView];
        
        if (statusCode == 200) {
            NSLog(@"Unlocked Habits = %@", unlockedHabits);
            NSLog(@"Not Passed Habits = %@", notPassedHabits);
            //TO DO: call all habits api and identify the locked and finished habits
            HabitsOverview *habitsOverview = [[HabitsModel sharedInstance] getHabitsOverview];
            [self setHabitsOverview:habitsOverview];
            
            [self getAllHabitsWithUnlockedHabits:unlockedHabits andNotPassedHabits:notPassedHabits];
            return;
        }
        
        if(error){
            //there is error on the api side
            [[NetworkManager sharedInstance] showApiErrorInViewController:self->delegate.tabBarController error:error];
        }
    }];
}

-(void)toggleFinishedAllHabits{
    int unlockedHabitsCount = (int) [[HabitsModel sharedInstance] getUnlockedHabits].count;
    int finishedHabitsCount = (int) [[HabitsModel sharedInstance] getFinishedHabits].count;
    
    if(finishedHabitsCount == unlockedHabitsCount){
        _finishAllBtn.userInteractionEnabled = NO;
        _finishAllBtn.backgroundColor = [UIColor whiteColor];
        _finishAllBtn.titleLabel.textColor = [UIColor lightGrayColor];
        
        [self getHabitsOverviewUpdates];
    }else{
        _finishAllBtn.userInteractionEnabled = YES;
        _finishAllBtn.backgroundColor = [colors blueColor];
        _finishAllBtn.titleLabel.textColor = [UIColor whiteColor];
    }
}

- (void)setHabitsOverview:(HabitsOverview *)habitsOverview{
    self->_pointsValueLbl.text = @(habitsOverview.habitPoints).stringValue;
    self->_habitsUnlockedValueLbl.text = [NSString stringWithFormat:@"%d/%d",habitsOverview.unlocked, habitsOverview.maximumHabits];
    self->_successiveDaysValueLbl.text = [NSString stringWithFormat:@"%d/7",habitsOverview.successiveDays];
    self->_habitCyclesLbl.text = [NSString stringWithFormat:@"%@ %d",[self->translationsModel getTranslationForKey:@"habit.cyclescompleted"], habitsOverview.completedCycles];
    
    NSDateFormatter *dateFormatter = [[NSDateFormatter alloc]init];
    [dateFormatter setDateFormat:@"yyyy-MM-dd'T'HH:mm:ssZ"];
    NSDate *date = [dateFormatter dateFromString:habitsOverview.lastReset];
    
    NSString *lastReset = @"";
    if(date){
        [dateFormatter setDateFormat:@"dd.MM.yyyy"];
        lastReset = [dateFormatter stringFromDate:date];
    }
    
    self->_lastResetLbl.text = [NSString stringWithFormat:@"%@ %@",[self->translationsModel getTranslationForKey:@"habit.lastreset"], lastReset];
    
    self->numOfHabitsUnlocked = habitsOverview.unlocked;
    self->successiveDays = habitsOverview.successiveDays;
    
    [self updateSuccessTracker:habitsOverview.successiveDays];
    
}

- (void)getAllHabitsWithUnlockedHabits:(NSArray *)unlockedHabits andNotPassedHabits:(NSArray *)notPassedHabits{
    [[HabitsServices sharedInstance] getAllHabitsWithCompletion:^(NSError *error, int statusCode) {
        if(statusCode == NoInternetErrorStatusCode || statusCode == SlowInternetErrorStatusCode) {
            [[NetworkManager sharedInstance] showConnectionErrorInViewController:self->delegate.tabBarController statusCode:statusCode];
            return;
        }
        
        self->apiCounter += 1;
        [self removeSkeletonView];
        
        if (statusCode == 200) {
            self->habits = [[HabitsModel sharedInstance] getAllHabits];
            //[self getUnlockedHabits];
            
            for (NSDictionary *habit in unlockedHabits) {
                NSString *predString = [NSString stringWithFormat:@"identifier == '%@'", habit[@"identifier"]];
                NSPredicate *pred = [NSPredicate predicateWithFormat:predString];
                
                NSArray *filtered = [self->habits filteredArrayUsingPredicate:pred];
                if(filtered.count > 0){
                    [[HabitsModel sharedInstance] unlockHabit:filtered.firstObject];
                }
            }
            
            self->unlockedHabits = [[HabitsModel sharedInstance] getUnlockedHabits];
            
            for (Habits *habit in self->unlockedHabits) {
                NSString *predString = [NSString stringWithFormat:@"identifier == '%@'", habit.identifier];
                NSPredicate *pred = [NSPredicate predicateWithFormat:predString];
                
                NSArray *filtered = [notPassedHabits filteredArrayUsingPredicate:pred];
                
                //if not found meaning, it is finished already
                if(filtered.count == 0){
                    [[HabitsModel sharedInstance] finishHabit:habit];
                }else{
                    //make sure the habit is not finished in local db
                    [[HabitsModel sharedInstance] unFinishHabit:habit];
                }
            }
            
            //updated all habits
            self->habits = [[HabitsModel sharedInstance] getAllHabits];
            [self->_habitsCollectionView reloadData];
            
            [self toggleFinishedAllHabits];
        }
    }];
}

//TO DO: remove. not necessary anymore
//get all unlocked habits (finished or not finished)
- (void)getUnlockedHabits{
    [[HabitsServices sharedInstance] getUnlockedHabitsWithCompletion:^(NSError *error, int statusCode, NSArray *unlockhabits) {
        if(statusCode == NoInternetErrorStatusCode || statusCode == SlowInternetErrorStatusCode) {
            [[NetworkManager sharedInstance] showConnectionErrorInViewController:self->delegate.tabBarController statusCode:statusCode];
            return;
        }
        
        if(unlockhabits != nil){
            for (NSDictionary *habit in unlockhabits) {
                NSString *predString = [NSString stringWithFormat:@"identifier == '%@'", habit[@"identifier"]];
                NSPredicate *pred = [NSPredicate predicateWithFormat:predString];
                
                NSArray *filtered = [self->habits filteredArrayUsingPredicate:pred];
                if(filtered.count > 0){
                    [[HabitsModel sharedInstance] unlockHabit:filtered.firstObject];
                }
            }
            
            self->unlockedHabits = [[HabitsModel sharedInstance] getUnlockedHabits];
            [self getUnlockedButNotFinishedHabits];
        }
    }];
}

//TO DO: remove. not necessary anymore
- (void)getUnlockedButNotFinishedHabits{
    [[HabitsServices sharedInstance] getAvailableHabitsWithCompletion:^(NSError *error, int statusCode, NSArray *unlockbutnotfinishedHabits) {
        if(statusCode == NoInternetErrorStatusCode || statusCode == SlowInternetErrorStatusCode) {
            [[NetworkManager sharedInstance] showConnectionErrorInViewController:self->delegate.tabBarController statusCode:statusCode];
            return;
        }
        
        self->apiCounter += 1;
        [self removeSkeletonView];
        
        if(unlockbutnotfinishedHabits != nil){
            for (Habits *habit in self->unlockedHabits) {
                NSString *predString = [NSString stringWithFormat:@"identifier == '%@'", habit.identifier];
                NSPredicate *pred = [NSPredicate predicateWithFormat:predString];
            
                NSArray *filtered = [unlockbutnotfinishedHabits filteredArrayUsingPredicate:pred];
                
                //if not found meaning, it is finished already
                if(filtered.count == 0){
                    [[HabitsModel sharedInstance] finishHabit:habit];
                }else{
                    //make sure the habit is not finished in local db
                    [[HabitsModel sharedInstance] unFinishHabit:habit];
                }
            }
            
            [self toggleFinishedAllHabits];
            
            self->habits = [[HabitsModel sharedInstance] getAllHabits];
            [self->_habitsCollectionView reloadData];
        }
    }];
}

- (void)updateSuccessTracker:(int)successiveDays{
    
    for (UIButton *btn in _successTrackerButtons){
        btn.layer.cornerRadius = 5.0f;
        btn.clipsToBounds = YES;
        btn.titleLabel.font = [fonts titleFontBold];
        
        if ([btn tag] <= successiveDays) {
            btn.layer.borderWidth = 1.0;
            btn.layer.borderColor = [UIColor whiteColor].CGColor;
            btn.backgroundColor = [UIColor clearColor];
            [btn setImage:[UIImage imageNamed:@"check"] forState:UIControlStateNormal];
            [btn setTitle:@"" forState:UIControlStateNormal];
        }else{
            [btn setTitle:@(btn.tag).stringValue forState:UIControlStateNormal];
            btn.contentHorizontalAlignment = UIControlContentHorizontalAlignmentCenter;
            btn.contentVerticalAlignment = UIControlContentVerticalAlignmentCenter;
            btn.layer.borderWidth = 0.0;
            btn.backgroundColor = [UIColor whiteColor];
            [btn setImage:nil forState:UIControlStateNormal];
            
            if ([btn tag] == successiveDays+1){
                btn.titleLabel.textColor = [UIColor blackColor];
                //[btn addTarget:self action:@selector(finishAllHabits:) forControlEvents:UIControlEventTouchUpInside];
            }else {
                btn.titleLabel.textColor = [UIColor lightGrayColor];
                //[btn removeTarget:self action:@selector(finishAllHabits:) forControlEvents:UIControlEventTouchUpInside];
            }
        }
    }
    
    
}

#pragma mark - UICollectionview DataSource & Delegate
-(NSInteger)numberOfSectionsInCollectionView:(UICollectionView *)collectionView {
    return 1;
}

-(NSInteger)collectionView:(UICollectionView *)collectionView numberOfItemsInSection:(NSInteger)section{
    return [habits count];
}

-(UICollectionViewCell *)collectionView:(UICollectionView *)collectionView cellForItemAtIndexPath:(NSIndexPath *)indexPath {
    
    static NSString *identifier = @"HabitsCollectionViewCell";
    HabitsCollectionViewCell *cell = (HabitsCollectionViewCell *)[_habitsCollectionView dequeueReusableCellWithReuseIdentifier:identifier forIndexPath:indexPath];
    
    [cell.habitView layoutIfNeeded];
    [helper addDropShadowIn:cell.habitView withColor:[UIColor darkGrayColor] andSetCornerRadiusTo:5.0];
    
    HabitsObj *habit = habits[indexPath.row];
    
    NSString *habitName = [translationsModel getTranslationForKey:[NSString stringWithFormat:@"%@%@.name", Cf_domain_model_Habit, habit.identifier]];
    NSString *habitDesc = [translationsModel getTranslationForKey:[NSString stringWithFormat:@"%@%@.description", Cf_domain_model_Habit, habit.identifier]];
    
    cell.habitNum.text = habitName;
    cell.title.text = habitDesc;
    
    cell.lockBtn.tag = indexPath.row;
    [cell.lockBtn addTarget:self
                     action:@selector(showHelp:)
           forControlEvents:UIControlEventTouchUpInside];
    
    cell.iconBtn.tag = indexPath.row;
    [cell.iconBtn addTarget:self
                     action:@selector(showHabit:)
           forControlEvents:UIControlEventTouchUpInside];
    
    if (!habit.unlocked){
        cell.statusView.hidden = TRUE;
        cell.remarks.hidden = FALSE;
        cell.lockBtn.hidden = FALSE;
        cell.iconBtn.hidden = TRUE;
        
        cell.remarks.text = [translationsModel getTranslationForKey:@"habit.lockedexplanation"];
    }else{
        cell.statusView.hidden = FALSE;
        cell.remarks.hidden = TRUE;
        cell.lockBtn.hidden = TRUE;
        cell.iconBtn.hidden = FALSE;
        
        if(habit.finished){
            cell.statusLbl.text = [self->translationsModel getTranslationForKey:@"habit.finishedselector"];
            [cell.finishedBtn setImage:[UIImage imageNamed:@"check_circle"] forState:UIControlStateNormal];
            cell.finishedBtn.tag = indexPath.row;
            [cell.finishedBtn removeTarget:self
                                    action:@selector(markAsFinished:)
                          forControlEvents:UIControlEventTouchUpInside];
            [cell.finishedBtn addTarget:self
                                 action:@selector(undoHabit:)
                       forControlEvents:UIControlEventTouchUpInside];
        }else{
            cell.statusLbl.text = [translationsModel getTranslationForKey:@"habit.notfinishedselector"];
            [cell.finishedBtn setImage:[UIImage imageNamed:@"x_circle"] forState:UIControlStateNormal];
            cell.finishedBtn.tag = indexPath.row;
            [cell.finishedBtn removeTarget:self
                                    action:@selector(undoHabit:)
                          forControlEvents:UIControlEventTouchUpInside];
            [cell.finishedBtn addTarget:self
                                 action:@selector(markAsFinished:)
                       forControlEvents:UIControlEventTouchUpInside];
        }
        
        [cell.imgView sd_setImageWithURL:[NSURL URLWithString:habit.img] placeholderImage:nil];
    }
    
    return cell;
}

- (CGSize)collectionView:(UICollectionView *)collectionView layout:(UICollectionViewLayout*)collectionViewLayout sizeForItemAtIndexPath:(NSIndexPath *)indexPath{
    
    CGSize cellSize = CGSizeMake(325, 230);
    return cellSize;
}

-(void)collectionView:(UICollectionView *)collectionView didSelectItemAtIndexPath:(NSIndexPath *)indexPath{
    [self.view endEditing:YES];
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

- (void)toggleHabitStatusUIWithTag:(int)tag status:(NSString *)status{
    NSIndexPath *cellIndex = [NSIndexPath indexPathForRow:tag inSection:0];
    HabitsCollectionViewCell *cell = (HabitsCollectionViewCell *)[self->_habitsCollectionView cellForItemAtIndexPath:cellIndex];
    
    if([status isEqualToString:@"finished"]){
        cell.statusLbl.text = [self->translationsModel getTranslationForKey:@"habit.finishedselector"];
        [cell.finishedBtn setImage:[UIImage imageNamed:@"check_circle"] forState:UIControlStateNormal];
        [cell.finishedBtn removeTarget:self
                                action:@selector(markAsFinished:)
                      forControlEvents:UIControlEventTouchUpInside];
        [cell.finishedBtn addTarget:self
                             action:@selector(undoHabit:)
                   forControlEvents:UIControlEventTouchUpInside];
        return;
    }
    
    cell.statusLbl.text = [translationsModel getTranslationForKey:@"habit.notfinishedselector"];
    [cell.finishedBtn setImage:[UIImage imageNamed:@"x_circle"] forState:UIControlStateNormal];
    [cell.finishedBtn removeTarget:self
                            action:@selector(undoHabit:)
                  forControlEvents:UIControlEventTouchUpInside];
    [cell.finishedBtn addTarget:self
                         action:@selector(markAsFinished:)
               forControlEvents:UIControlEventTouchUpInside];
    
}

- (IBAction)markAsFinished:(id)sender{
    Habits *habit = habits[[sender tag]];
    
    [DejalBezelActivityView activityViewForView:delegate.tabBarController.view];
    [[HabitsServices sharedInstance] finishHabitWithId:habit.identifier withCompletion:^(NSError *error, int statusCode) {
        [DejalBezelActivityView removeViewAnimated:YES];
        
        if(statusCode == NoInternetErrorStatusCode || statusCode == SlowInternetErrorStatusCode) {
            [[NetworkManager sharedInstance] showConnectionErrorInViewController:self->delegate.tabBarController statusCode:statusCode];
            self->lastApiCall = HabitsServicesApi_FinishHabit;
            self->lastSender = sender;
            return;
        }
        
        self->lastApiCall = 0;
        self->lastSender = nil;
        
        //successfull
        if(statusCode == 200 || statusCode == 201){
            //update the ui
            [self toggleHabitStatusUIWithTag:(int)[sender tag] status:@"finished"];
            
            //finish the habit in local db
            [[HabitsModel sharedInstance] finishHabit:habit];
            
            //check if all habits are finished and then update ui if all finished
            [self toggleFinishedAllHabits];
            
            NSString *title = [self->translationsModel getTranslationForKey:@"popup.successtitle"];
            NSString *msg = [self->translationsModel getTranslationForKey:@"info.finishedhabit"];
            
            CustomAlertView *alert = [CustomAlertView sharedInstance];
            [alert showAlertInViewController:self->delegate.tabBarController
                                   withTitle:title
                                     message:msg
                           cancelButtonTitle:[[TranslationsModel sharedInstance] getTranslationForKey:@"global.rateokay"]
                             doneButtonTitle:nil];
            [alert setCancelBlock:^(id result) {
                if(statusCode == 200 || statusCode == 201){
                    //check and show App rating if condition met
                    [[AppReviewHelper sharedHelper] checkAndFireAppRating];
                }
            }];
            return;
        }
        
        //either habit already finished or cannot be finished yet
        if(statusCode == 403 || statusCode == 409){
            NSString *title = [self->translationsModel getTranslationForKey:@"info.error"];
            NSString *msg = @"";
            
            switch (statusCode) {
                case 409:
                    msg = [self->translationsModel getTranslationForKey:@"info.habitAlreadyFinished"];
                    break;
                case 403:
                    msg = [self->translationsModel getTranslationForKey:@"info.habitidtoohigh"];
                    break;
                default:
                    break;
            }
            
            CustomAlertView *alert = [CustomAlertView sharedInstance];
            [alert showAlertInViewController:self->delegate.tabBarController
                                   withTitle:title
                                     message:msg
                           cancelButtonTitle:[[TranslationsModel sharedInstance] getTranslationForKey:@"global.rateokay"]
                             doneButtonTitle:nil];
            [alert setCancelBlock:^(id result) {
                //cancel
            }];
            return;
        }
        
        if(error){
            //there is error on the api side
            [[NetworkManager sharedInstance] showApiErrorInViewController:self->delegate.tabBarController error:error];
            self->lastApiCall = HabitsServicesApi_FinishHabit;
            self->lastSender = sender;
        }
    }];
}

- (IBAction)undoHabit:(id)sender{
    Habits *habit = habits[[sender tag]];
    
    [DejalBezelActivityView activityViewForView:delegate.tabBarController.view];
    [[HabitsServices sharedInstance] undoHabitWithId:habit.identifier withCompletion:^(NSError *error, int statusCode) {
        [DejalBezelActivityView removeViewAnimated:YES];
        
        if(statusCode == NoInternetErrorStatusCode || statusCode == SlowInternetErrorStatusCode) {
            [[NetworkManager sharedInstance] showConnectionErrorInViewController:self->delegate.tabBarController statusCode:statusCode];
            self->lastApiCall = HabitsServicesApi_UndoHabit;
            self->lastSender = sender;
            return;
        }
        
        self->lastApiCall = 0;
        self->lastSender = nil;
        
        if(statusCode == 200 || statusCode == 201 || statusCode == 404){
            NSString *title = [self->translationsModel getTranslationForKey:@"info.error"];
            NSString *msg = @"";
            
            switch (statusCode) {
                case 200:
                case 201:{
                    title = [self->translationsModel getTranslationForKey:@"popup.successtitle"];
                    msg = @"Habit unfinished";
                    
                    //update ui
                    [self toggleHabitStatusUIWithTag:(int)[sender tag] status:@"unfinished"];
                    
                    //check if all habits are finished and then update ui if all finished
                    [self toggleFinishedAllHabits];
                    
                    int unlockedHabitsCount = (int) [[HabitsModel sharedInstance] getUnlockedHabits].count;
                    int finishedHabitsCount = (int) [[HabitsModel sharedInstance] getFinishedHabits].count;
                    
                    if(finishedHabitsCount == unlockedHabitsCount){
                        self->_finishAllBtn.userInteractionEnabled = YES;
                        self->_finishAllBtn.backgroundColor = [self->colors blueColor];
                        self->_finishAllBtn.titleLabel.textColor = [UIColor whiteColor];
                        
                        [self getHabitsOverviewUpdates];
                    }
                    
                    //undo the habit in local db
                    [[HabitsModel sharedInstance] unFinishHabit:habit];
                }
                    break;
                case 404:
                    msg = @"No habit in period to undo.";
                    break;
                default:
                    break;
            }
            
            CustomAlertView *alert = [CustomAlertView sharedInstance];
            [alert showAlertInViewController:self->delegate.tabBarController
                                   withTitle:title
                                     message:msg
                           cancelButtonTitle:[[TranslationsModel sharedInstance] getTranslationForKey:@"global.rateokay"]
                             doneButtonTitle:nil];
            [alert setCancelBlock:^(id result) {
                //
            }];
            return;
        }
        
        if(error){
            //there is error on the api side
            [[NetworkManager sharedInstance] showApiErrorInViewController:self->delegate.tabBarController error:error];
            self->lastApiCall = HabitsServicesApi_UndoHabit;
            self->lastSender = sender;
        }
    }];
    
}

- (IBAction)finishAllHabits:(id)sender{
    [DejalBezelActivityView activityViewForView:delegate.tabBarController.view];
    [[HabitsServices sharedInstance] finishAllHabitsWithCompletion:^(NSError *error, int statusCode) {
        [DejalBezelActivityView removeViewAnimated:YES];
        
        if(statusCode == NoInternetErrorStatusCode || statusCode == SlowInternetErrorStatusCode) {
            [[NetworkManager sharedInstance] showConnectionErrorInViewController:self->delegate.tabBarController statusCode:statusCode];
            self->lastApiCall = HabitsServicesApi_FinishAllHabits;
            return;
        }
        
        self->lastApiCall = 0;
        
        if(statusCode == 200 || statusCode == 201 || statusCode == 409){
            NSString *title = [self->translationsModel getTranslationForKey:@"info.error"];
            NSString *msg = @"";
            
            switch (statusCode) {
                case 200:
                case 201:
                {
                    title = [self->translationsModel getTranslationForKey:@"popup.successtitle"];
                    msg = [self->translationsModel getTranslationForKey:@"info.finishedallhabits"];
                    
                    //finish all unlocked habits in the local db
                    NSArray *unlockedButUnfinishedHabits = [[HabitsModel sharedInstance] getUnlockedAndUnFinishedHabits];
                    for (Habits *habit in unlockedButUnfinishedHabits) {
                        [[HabitsModel sharedInstance] finishHabit:habit];
                    }
                    
                    //check if all habits are finished and then update ui if all finished
                    [self toggleFinishedAllHabits];
                    
                    //refetch all updated habits and reload collection to update the view
                    self->habits = [[HabitsModel sharedInstance] getAllHabits];
                    [self->_habitsCollectionView reloadData];
                }
                    break;
                case 409:
                    msg = [self->translationsModel getTranslationForKey:@"info.nohabitperiodexist"];
                    break;
                default:
                    break;
            }
            
            CustomAlertView *alert = [CustomAlertView sharedInstance];
            [alert showAlertInViewController:self->delegate.tabBarController
                                   withTitle:title
                                     message:msg
                           cancelButtonTitle:[[TranslationsModel sharedInstance] getTranslationForKey:@"global.rateokay"]
                             doneButtonTitle:nil];
            [alert setCancelBlock:^(id result) {
                if(statusCode == 200 || statusCode == 201){
                    //check and show App rating if condition met
                    [[AppReviewHelper sharedHelper] checkAndFireAppRating];
                }
            }];
            return;
        }
        
        if(error){
            //there is error on the api side
            [[NetworkManager sharedInstance] showApiErrorInViewController:self->delegate.tabBarController error:error];
            self->lastApiCall = HabitsServicesApi_FinishAllHabits;
        }
    }];
}

- (IBAction)showHabit:(id)sender{
    int tag = (int)[sender tag];
    HabitsObj *habit = habits[tag];
    
    HabitInfoViewController *vc = [[HabitInfoViewController alloc] initWithNibName:@"HabitInfoViewController" bundle:nil];
    vc.habit = habit;
    [self.navigationController pushViewController:vc animated: YES];
}

- (IBAction)showHelp:(id)sender{
    [customAlertView showAlertInViewController:delegate.tabBarController
                                      withTitle:[[TranslationsModel sharedInstance] getTranslationForKey:@"habitchall.title"]
                                        message:[[TranslationsModel sharedInstance] getTranslationForKey:@"habitchall.description"]
                              cancelButtonTitle:[[TranslationsModel sharedInstance] getTranslationForKey:@"habitchall.gotitbutton"]
                                doneButtonTitle:nil];
    [customAlertView setCancelBlock:^(id result) {
        NSLog(@"Cancel");
    }];
}

#pragma mark - Skeleton Views

- (void)addSkeletonView{
    [skeletonView addSkeletonOnHabitsCollectionViewWithBounds:_habitsCollectionView.frame withCellSize:CGSizeMake(325, 230)];
    [skeletonView addSkeletonOn:_habitPointsView for:_habitsUnlockedLbl isText:YES];
    [skeletonView addSkeletonOn:_habitPointsView for:_habitsUnlockedValueLbl isText:YES];
    [skeletonView addSkeletonOn:_habitPointsView for:_successiveDaysLbl isText:YES];
    [skeletonView addSkeletonOn:_habitPointsView for:_successiveDaysValueLbl isText:YES];
    [skeletonView addSkeletonFor:_pointsView isText:NO];
    [skeletonView addSkeletonFor:_habitCyclesLbl isText:YES];
    [skeletonView addSkeletonFor:_lastResetLbl isText:YES];
    [skeletonView addSkeletonFor:_finishAllBtn isText:NO];
    [skeletonView addSkeletonOn:_trackerButtonsView for:_giftBtn isText:NO];
    for (UIButton *btn in _successTrackerButtons){
        [skeletonView addSkeletonOn:_trackerButtonsView for:btn isText:NO];
    }
    [_contentView addSubview:skeletonView];
}

- (void)removeSkeletonView{
    if (apiCounter == 2) {
        [skeletonView remove];
        didRequestFromRemote = YES;
        _helpBtn.hidden = NO;
        apiCounter = 0;
    }
}

@end
