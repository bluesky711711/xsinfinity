//
//  PerformanceViewController.m
//  XSInfinity
//
//  Created by Joseph Marvin Magdadaro on 7/9/18.
//  Copyright © 2018 Jerk Magz. All rights reserved.
//

#import "PerformanceViewController.h"
#import <SDWebImage/UIImageView+WebCache.h>
#import "NetworkManager.h"
#import "DejalActivityView.h"
#import "AppDelegate.h"
#import "Helper.h"
#import "Fonts.h"
#import "Colors.h"
#import "TranslationsModel.h"
#import "Animations.h"
#import "CustomNavigation.h"
#import "UserMediaServices.h"
#import "UserServices.h"
#import "CommunityRankingViewController.h"
#import "SkeletonView.h"
#import "UserSummary.h"
#import "UserModel.h"
#import "UserPerformance.h"
#import "ActivityLogViewController.h"
#import "ToastView.h"
@import Charts;

static int const legendCount = 7;

@interface CalendarObj : NSObject
@property int month;
@property int year;
@end
@implementation CalendarObj

@end

@interface PerformanceViewController ()<ChartViewDelegate, IChartAxisValueFormatter, NetworkManagerDelegate, ToastViewDelegate>{
    Helper *helper;
    Fonts *fonts;
    Colors *colors;
    TranslationsModel *translationsModel;
    Animations *animations;
    AppDelegate *delegate;
    CustomNavigation *customNavigation;
    SkeletonView *skeletonView;
    NSString *activity;
    NSString *calendarSetting;
    NSArray *legend;
    NSArray *months;
    NSArray *days;
    NSArray *dayNums;
    NSArray *monthsAndYears;
    
    int apiCounter;
    UserSummary *summary;
    UserInfo *userInfo;
    int currentCellIndex;
    int legendStart;
    NSArray *weekDates;
    int weekOffSet;
    
    BOOL didLayoutReloaded;
    BOOL didShowConnectionError;
    BOOL didRequestFromServer;
}
@property (weak, nonatomic) IBOutlet UIScrollView *scrollView;
@property (weak, nonatomic) IBOutlet UIView *contentView;

@property (weak, nonatomic) IBOutlet UIView *pointsView;
@property (weak, nonatomic) IBOutlet UIView *communityView;
@property (weak, nonatomic) IBOutlet UILabel *communityLbl;
@property (weak, nonatomic) IBOutlet UILabel *communityRankLbl;
@property (weak, nonatomic) IBOutlet UILabel *exercisesPointsLbl;
@property (weak, nonatomic) IBOutlet UILabel *exercisesPointsValueLbl;
@property (weak, nonatomic) IBOutlet UILabel *habitPointsLbl;
@property (weak, nonatomic) IBOutlet UILabel *habitPointsValueLbl;

@property (weak, nonatomic) IBOutlet UILabel *communityCompetitionLbl;
@property (weak, nonatomic) IBOutlet UIView *competitionView;
@property (weak, nonatomic) IBOutlet UIImageView *profileImageView;
@property (weak, nonatomic) IBOutlet UILabel *nameLbl;
@property (weak, nonatomic) IBOutlet UIImageView *rankingChangeStatusImgView;
@property (weak, nonatomic) IBOutlet UILabel *rankingChangeLbl;
@property (weak, nonatomic) IBOutlet UIImageView *lastWeekStatusImgView;
@property (weak, nonatomic) IBOutlet UILabel *lastWeekLbl;

@property (weak, nonatomic) IBOutlet UILabel *performanceLbl;
@property (weak, nonatomic) IBOutlet UIView *performanceView;

@property (weak, nonatomic) IBOutlet UIView *performanceChartView;
@property (weak, nonatomic) IBOutlet LineChartView *chartView;
@property (weak, nonatomic) IBOutlet UILabel *pointsLbl;
@property (weak, nonatomic) IBOutlet UILabel *dateLbl;

@property (weak, nonatomic) IBOutlet UIView *chartSettingsView;
@property (weak, nonatomic) IBOutlet UILabel *showMeLbl;
@property (weak, nonatomic) IBOutlet UILabel *inViewOfLbl;
@property (weak, nonatomic) IBOutlet UIButton *exerciseBtn;
@property (weak, nonatomic) IBOutlet UIButton *habitBtn;
@property (weak, nonatomic) IBOutlet UIButton *dayBtn;
@property (weak, nonatomic) IBOutlet UIButton *weekBtn;
@property (weak, nonatomic) IBOutlet UIButton *monthBtn;
@property (weak, nonatomic) IBOutlet UIButton *prevImgBtn;
@property (weak, nonatomic) IBOutlet UIButton *prevBtn;
@property (weak, nonatomic) IBOutlet UIButton *nextImgBtn;
@property (weak, nonatomic) IBOutlet UIButton *nextBtn;

@property (strong, nonatomic) IBOutletCollection(UIButton) NSArray *activityButtons;
@property (strong, nonatomic) IBOutletCollection(UIButton) NSArray *calendarButtons;

@property (weak, nonatomic) IBOutlet UILabel *activityLogLbl;
@property (weak, nonatomic) IBOutlet UICollectionView *calendarCollectionView;

@property (nonatomic, assign) CGFloat lastContentOffset;

@property (nonatomic, assign) int minimumMonth;
@property (nonatomic, assign) int minimumYr;

//@property (nonatomic, weak) IBOutlet LineChartView *lineChartView;

@end


/* Todo:
 *  - get the signup date
 *  - Weeks
 *      - show weeks from the signup date upto current week
 *  - Monthly
 *      - show months from the signup date upto current month
 */

@implementation PerformanceViewController

-(void)viewWillAppear:(BOOL)animated{
    [super viewWillAppear:YES];
    self.navigationController.navigationBar.hidden = NO;
    float scrollOffset = _scrollView.contentOffset.y;
    
    if (scrollOffset < 0)
        [[Animations sharedAnimations] setTabBar:delegate.tabBarController.tabBar fromViewController:self visible:YES animated:NO];
    
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
    self.navigationItem.title = [[TranslationsModel sharedInstance] getTranslationForKey:@"perf.title"];
    
    helper = [Helper sharedHelper];
    fonts = [Fonts sharedFonts];
    colors = [Colors sharedColors];
    translationsModel = [TranslationsModel sharedInstance];
    animations = [Animations sharedAnimations];
    customNavigation = [CustomNavigation sharedInstance];
    delegate = (AppDelegate *)[[UIApplication sharedApplication] delegate];
    
    //Register Collection
    [_calendarCollectionView registerClass:[UICollectionViewCell class] forCellWithReuseIdentifier:@"CalendarCollectionViewCellIdentifier"];
    
    skeletonView = [[SkeletonView alloc] initWithFrame:_contentView.frame];
    skeletonView.backgroundColor = [UIColor clearColor];
    
    NSLog(@"Date user is registered = %@", DATE_USER_REGISTERED);
    NSArray *dateRegistered = [DATE_USER_REGISTERED componentsSeparatedByString:@"-"];
    
    //the month and year the user registered
    self.minimumMonth = dateRegistered.count > 0 ?[dateRegistered[1] intValue] : 1;
    self.minimumYr = dateRegistered.count > 0 ?[dateRegistered[0] intValue] : 2018;
    
    monthsAndYears = [self getTotalMonthsAndYearsForCalendar];
    
    weekOffSet = 0;
    weekDates = [self daysInWeek:weekOffSet fromDate:[NSDate date]];
}

- (void)viewDidAppear:(BOOL)animated{
    [super viewDidAppear:YES];
    
    [[ToastView sharedInstance] setDelegate:self];
    [[NetworkManager sharedInstance] setDelegate:self];
    [[NetworkManager sharedInstance] connectivityMonitoring];
    
    _pointsView.hidden = NO;
    _communityView.hidden = NO;
    _competitionView.hidden = NO;
    _profileImageView.hidden = NO;
    _performanceView.hidden = NO;
    
    /*
     *NOTE: Do this to scroll the calendar to current month of the current year
     */
    // Calling collectionViewContentSize forces the UICollectionViewLayout to actually render the layout
    [_calendarCollectionView.collectionViewLayout collectionViewContentSize];
    [_calendarCollectionView scrollToItemAtIndexPath:[NSIndexPath indexPathForRow:(monthsAndYears.count-1) inSection:0] atScrollPosition:UICollectionViewScrollPositionCenteredHorizontally animated:NO];
    
    if([[NetworkManager sharedInstance] isConnectionOffline]){
        if(!didShowConnectionError){
            [[NetworkManager sharedInstance] showConnectionErrorInViewController:delegate.tabBarController];
            didShowConnectionError = YES;
        }
        
        /**
         * show offline data
         */
        summary = [[UserModel sharedInstance] getUserCommunitySummary];
        if (summary) {
            [self setSummary];
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
    
    if(!didRequestFromServer){
        [self getUpdates];
    }
}

#pragma mark - Graphs

- (NSArray *) weeks{
    NSMutableArray *weeks = [NSMutableArray new];

    NSDate *dateRegistered = [self dateRegistered];
    NSDateComponents *dateRegisteredComponent = [self componentsWithDate:dateRegistered];
    NSDateComponents *currentDateComponent = [self currentDateComponents];
    
    int startYr = (int) dateRegisteredComponent.year;
    int endYr = (int) currentDateComponent.year;
    
    int startWeek, endWeek;
    
    //user was registered on the current year
    if(startYr == endYr){
        //start date = dateRegistered
        //end date = current date
        //get the weeknumber from the start date
        //loop start weeknumber until end weeknumber
        
        startWeek = (int) dateRegisteredComponent.weekOfYear;
        endWeek = (int) currentDateComponent.weekOfYear;
        
        for (int w = startWeek; w <= endWeek; w++) {
            NSDictionary *value = @{
                                    @"number": @(w),
                                    @"year": @(startYr)
                                    };
            [weeks addObject:value];
        }
        
        //hack: for some reason if value for chart is only one, the chart render the value from -1. which is weird
        if(weeks.count == 1){
            NSDictionary *value = @{
                                    @"number": @(99),
                                    @"year": @(startYr)
                                    };
            [weeks addObject:value];
        }
        
        return weeks;
    }
    
    //user was registered year(s) ago
    for(int i = startYr; i <= endYr; i++ ){
        NSDateFormatter *dateFormatter = [[NSDateFormatter alloc] init];
        [dateFormatter setDateFormat:@"yyyy-MM-dd"];
        
        if(i == startYr){
            //start date = dateRegistered
            //end date = end of december
            startWeek = (int) dateRegisteredComponent.weekOfYear;
            endWeek = 52;
            
        }else if(i == endYr){
            //start date = January [current yr]
            //end date = current date
            startWeek = 1;
            endWeek = (int) currentDateComponent.weekOfYear;
            
        }else{
            //start date = January [current yr]
            //end date = end of december
            startWeek = 1;
            endWeek = 52;
        }
        
        for (int w = startWeek; w <= endWeek; w++) {
            NSDictionary *value = @{
                                    @"number": @(w),
                                    @"year": @(i)
                                    };
            [weeks addObject:value];
        }
    }
    
    return weeks;
}

- (NSArray *) months{
    NSMutableArray *monthsArr = [NSMutableArray new];

    NSDate *dateRegistered = [self dateRegistered];
    NSDateComponents *dateRegisteredComponent = [self componentsWithDate:dateRegistered];
    NSDateComponents *currentDateComponent = [self currentDateComponents];
    
    int startYr = (int) dateRegisteredComponent.year;
    int endYr = (int) currentDateComponent.year;
    
    int startMonth, endMonth;
    
    //user was registered on the current year
    if(startYr == endYr){
        //start date = dateRegistered
        //end date = current date
        //get the weeknumber from the start date
        //loop start weeknumber until end weeknumber
        
        startMonth = (int) dateRegisteredComponent.month;
        endMonth = (int) currentDateComponent.month;
        
        for (int w = startMonth; w <= endMonth; w++) {
            NSDictionary *value = @{
                                    @"number": @(w),
                                    @"year": @(startYr)
                                    };
            [monthsArr addObject:value];
        }
        
        //hack: for some reason if value for chart is only one, the chart render the value from -1. which is weird
        if(monthsArr.count == 1){
            NSDictionary *value = @{
                                    @"number": @(99),
                                    @"year": @(startYr)
                                    };
            [monthsArr addObject:value];
        }
        return monthsArr;
    }
    
    //user was registered year(s) ago
    for(int i = startYr; i <= endYr; i++ ){
        NSDateFormatter *dateFormatter = [[NSDateFormatter alloc] init];
        [dateFormatter setDateFormat:@"yyyy-MM-dd"];
        
        if(i == startYr){
            //start date = dateRegistered
            //end date = end of december
            startMonth = (int) dateRegisteredComponent.month;
            endMonth = 12;
            
        }else if(i == endYr){
            //start date = January [current yr]
            //end date = current date
            startMonth = 1;
            endMonth = (int) currentDateComponent.month;
            
        }else{
            //start date = January [current yr]
            //end date = end of december
            startMonth = 1;
            endMonth = 12;
        }
        
        for (int w = startMonth; w <= endMonth; w++) {
            NSDictionary *value = @{
                                    @"number": @(w),
                                    @"year": @(i)
                                    };
            [monthsArr addObject:value];
        }
    }
    return monthsArr;
}

- (NSDate *) dateRegistered{
    NSDateFormatter *dateFormatter = [[NSDateFormatter alloc] init];
    [dateFormatter setDateFormat:@"yyyy-MM-dd'T'HH:mm:ss+0000"];
    return [dateFormatter dateFromString:DATE_USER_REGISTERED];
}

- (NSDateComponents *)currentDateComponents{
    NSCalendar* calendar = [NSCalendar currentCalendar];
    calendar.firstWeekday = 2;//set first day of a week to monday
    NSDateComponents* components = [calendar components:NSCalendarUnitWeekOfYear|NSCalendarUnitYear|NSCalendarUnitMonth|NSCalendarUnitDay fromDate:[NSDate date]];
    return components;
}

- (NSDateComponents *)componentsWithDate: (NSDate *)date{
    NSCalendar* calendar = [NSCalendar currentCalendar];
    calendar.firstWeekday = 2;//set first day of a week to monday
    NSDateComponents *components = [calendar components:NSCalendarUnitWeekOfYear|NSCalendarUnitYear|NSCalendarUnitMonth|NSCalendarUnitDay fromDate:date];
    
    return components;
}

- (NSArray *)getTotalMonthsAndYearsForCalendar{
    //int totalNumOfMonths = (((([helper currentYear] - self.minimumYr) + 1) * 12) - self.minimumMonth) + 1;
    
    NSDateComponents *dateRegisteredComponent = [self componentsWithDate:[self dateRegistered]];
    NSDateComponents *currDateComponent = [self currentDateComponents];
    
    NSInteger totalNumOfMonths = ((currDateComponent.year - dateRegisteredComponent.year) * 12) + (currDateComponent.month - dateRegisteredComponent.month);
    NSLog(@"Numofmonth = %ld", (long)totalNumOfMonths);
    
    NSMutableArray *monthsYearsArr = [NSMutableArray new];
    
    int month = self.minimumMonth;
    int year = self.minimumYr;
    for (int i=0; i<=totalNumOfMonths; i++) {
        
        CalendarObj *calendarObj = [CalendarObj new];
        calendarObj.month = month;
        calendarObj.year = year;
        
        [monthsYearsArr addObject:calendarObj];
        
        if(month == 12){
            month = 1;
            year += 1;
        }else{
            month += 1;
        }
    }
    
    return [monthsYearsArr mutableCopy];
}

- (void)getUpdates{
    [self addSkeletonView];
    [self getInfo];
    [self getProfileImage];
    [self getSummary];
    [self getUserPerformance];
    [self setUpChart];
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
    if([[NetworkManager sharedInstance] isConnectionOffline]){
        [[NetworkManager sharedInstance] showConnectionErrorInViewController:delegate.tabBarController];
        return;
    }
    [self getUpdates];
}

-(void)viewDidLayoutSubviews{
    [super viewDidLayoutSubviews];
    
    if( !didLayoutReloaded ){
        [self setupUserInterface];
        
        didLayoutReloaded = YES;
        
    }
}
- (void)setupUserInterface{
    [_pointsView layoutIfNeeded];
    [_competitionView layoutIfNeeded];
    [_performanceView layoutIfNeeded];
    
    [helper addDropShadowIn:_pointsView withColor:[UIColor darkGrayColor] andSetCornerRadiusTo:5.0];
    [helper addDropShadowIn:_competitionView withColor:[UIColor darkGrayColor] andSetCornerRadiusTo:5.0];
    [helper addShadowIn:_performanceView withColor:[UIColor darkGrayColor] andSetCornerRadiusTo:5.0];

    _communityView.backgroundColor = [colors purpleColor];
    _communityView.layer.cornerRadius = 5.0;
    _communityView.clipsToBounds = YES;
    
    _profileImageView.layer.cornerRadius = CGRectGetWidth(_profileImageView.frame)/2;
    _profileImageView.clipsToBounds = YES;
    [_profileImageView.layer setBorderColor: [[UIColor whiteColor] CGColor]];
    [_profileImageView.layer setBorderWidth: 3.0];
    
    _pointsLbl.textColor = [colors purpleColor];
    
    [self setTranslationsAndFonts];
    
    activity = @"exercise";
    calendarSetting = @"days";
    
    [self chooseActivity:_exerciseBtn];
    [self chooseCalendarSetting:_dayBtn];
    
    _chartSettingsView.hidden = YES;
    
    //for Skeleton
    _pointsView.hidden = YES;
    _communityView.hidden = YES;
    _competitionView.hidden = YES;
    _profileImageView.hidden = YES;
    _performanceView.hidden = YES;
    
    //show user's name
    userInfo = [[UserModel sharedInstance] getUserInfo];
    _nameLbl.text = userInfo.userName;
}

- (void)setTranslationsAndFonts{
    
    //initialize months & days values and set translations too
    months = @[
               @{ @"simplified": [translationsModel getTranslationForKey:@"perf.monthjan"], @"complete": [translationsModel getTranslationForKey:@"perf.monthjan"] },
               @{ @"simplified": [translationsModel getTranslationForKey:@"perf.monthfeb"], @"complete": [translationsModel getTranslationForKey:@"perf.monthfeb"] },
               @{ @"simplified": [translationsModel getTranslationForKey:@"perf.monthmar"], @"complete": [translationsModel getTranslationForKey:@"perf.monthmar"] },
               @{ @"simplified": [translationsModel getTranslationForKey:@"perf.monthapr"], @"complete": [translationsModel getTranslationForKey:@"perf.monthapr"] },
               @{ @"simplified": [translationsModel getTranslationForKey:@"perf.monthmay"], @"complete": [translationsModel getTranslationForKey:@"perf.monthmay"] },
               @{ @"simplified": [translationsModel getTranslationForKey:@"perf.monthjun"], @"complete": [translationsModel getTranslationForKey:@"perf.monthjun"] },
               @{ @"simplified": [translationsModel getTranslationForKey:@"perf.monthjul"], @"complete": [translationsModel getTranslationForKey:@"perf.monthjul"] },
               @{ @"simplified": [translationsModel getTranslationForKey:@"perf.monthaug"], @"complete": [translationsModel getTranslationForKey:@"perf.monthaug"] },
               @{ @"simplified": [translationsModel getTranslationForKey:@"perf.monthsep"], @"complete": [translationsModel getTranslationForKey:@"perf.monthsep"] },
               @{ @"simplified": [translationsModel getTranslationForKey:@"perf.monthoct"], @"complete": [translationsModel getTranslationForKey:@"perf.monthoct"] },
               @{ @"simplified": [translationsModel getTranslationForKey:@"perf.monthnov"], @"complete": [translationsModel getTranslationForKey:@"perf.monthnov"] },
               @{ @"simplified": [translationsModel getTranslationForKey:@"perf.monthdec"], @"complete": [translationsModel getTranslationForKey:@"perf.monthdec"] },
               ];
    
    days = @[
             @{ @"simplified": [translationsModel getTranslationForKey:@"perf.daymon"], @"complete": [translationsModel getTranslationForKey:@"perf.daymon"] },
             @{ @"simplified": [translationsModel getTranslationForKey:@"perf.daytue"], @"complete": [translationsModel getTranslationForKey:@"perf.daytue"] },
             @{ @"simplified": [translationsModel getTranslationForKey:@"perf.daywed"], @"complete": [translationsModel getTranslationForKey:@"perf.daywed"] },
             @{ @"simplified": [translationsModel getTranslationForKey:@"perf.daythu"], @"complete": [translationsModel getTranslationForKey:@"perf.daythu"] },
             @{ @"simplified": [translationsModel getTranslationForKey:@"perf.dayfri"], @"complete": [translationsModel getTranslationForKey:@"perf.dayfri"] },
             @{ @"simplified": [translationsModel getTranslationForKey:@"perf.daysat"], @"complete": [translationsModel getTranslationForKey:@"perf.daysat"] },
             @{ @"simplified": [translationsModel getTranslationForKey:@"perf.daysun"], @"complete": [translationsModel getTranslationForKey:@"perf.daysun"] },
             ];
    
    _communityLbl.font = [fonts normalFont];
    _communityRankLbl.font = [fonts headerFont];
    _exercisesPointsLbl.font = [fonts normalFont];
    _exercisesPointsValueLbl.font = [fonts headerFont];
    _habitPointsLbl.font = [fonts normalFont];
    _habitPointsValueLbl.font = [fonts headerFont];
    _communityCompetitionLbl.font = [fonts titleFont];
    _nameLbl.font = [fonts normalFont];
    _rankingChangeLbl.font = [fonts normalFontBold];
    _lastWeekLbl.font = [fonts normalFontBold];
    _performanceLbl.font = [fonts titleFont];
    _pointsLbl.font = [fonts bigFontBold];
    _dateLbl.font = [fonts normalFont];
    _showMeLbl.font = [fonts normalFont];
    _inViewOfLbl.font = [fonts normalFont];
    _exerciseBtn.titleLabel.font = [fonts normalFont];
    _habitBtn.titleLabel.font = [fonts normalFont];
    _dayBtn.titleLabel.font = [fonts normalFont];
    _weekBtn.titleLabel.font = [fonts normalFont];
    _monthBtn.titleLabel.font = [fonts normalFont];
    _activityLogLbl.font = [fonts titleFont];
    
    self.navigationItem.title = [[TranslationsModel sharedInstance] getTranslationForKey:@"perf.title"];
    
    _communityLbl.text = [translationsModel getTranslationForKey:@"global.infinitycommunity"];
    _exercisesPointsLbl.text = [translationsModel getTranslationForKey:@"global.exercisepoints"];
    _habitPointsLbl.text = [translationsModel getTranslationForKey:@"global.habitpoints"];
    _communityCompetitionLbl.text = [translationsModel getTranslationForKey:@"perf.communitycompetition_title"];
    _rankingChangeLbl.text = [translationsModel getTranslationForKey:@"perf.total"];
    _lastWeekLbl.text = [translationsModel getTranslationForKey:@"perf.lastweek"];
    _performanceLbl.text = [translationsModel getTranslationForKey:@"perf.performance_title"];
    _activityLogLbl.text = [translationsModel getTranslationForKey:@"perf.activitylog_title"];
//    _dateLbl.text = [translationsModel getTranslationForKey:@"perf.exercisepointsondate"];
    _showMeLbl.text = [translationsModel getTranslationForKey:@"perf.showme"];
    _inViewOfLbl.text = [translationsModel getTranslationForKey:@"perf.viewof"];
    [_exerciseBtn setTitle:[translationsModel getTranslationForKey:@"perf.ex"] forState:UIControlStateNormal];
    [_habitBtn setTitle:[translationsModel getTranslationForKey:@"perf.habit"] forState:UIControlStateNormal];
    [_dayBtn setTitle:[translationsModel getTranslationForKey:@"perf.day"] forState:UIControlStateNormal];
    [_weekBtn setTitle:[translationsModel getTranslationForKey:@"perf.week"] forState:UIControlStateNormal];
    [_monthBtn setTitle:[translationsModel getTranslationForKey:@"perf.month"] forState:UIControlStateNormal];
}

- (NSArray *) getSimplifiedWithType: (NSString *)type {
    NSMutableArray *simplified = [NSMutableArray new];
    
    if([type isEqualToString:@"months"]){
        for (NSDictionary *day in months) {
            [simplified addObject:day[@"simplified"]];
        }
    }
    
    if([type isEqualToString:@"days"]) {
        for (NSDictionary *day in days) {
            [simplified addObject:day[@"simplified"]];
        }
    }
    
    return simplified.mutableCopy;
}

- (NSArray *) getCompleteWithType: (NSString *)type {
    NSMutableArray *simplified = [NSMutableArray new];
    
    if([type isEqualToString:@"months"]){
        for (NSDictionary *day in months) {
            [simplified addObject:day[@"complete"]];
        }
    }
    
    if([type isEqualToString:@"days"]) {
        for (NSDictionary *day in days) {
            [simplified addObject:day[@"complete"]];
        }
    }
    
    return simplified.mutableCopy;
}

- (void)getInfo{
    
    //only fetch user info if no user info saved
    if(userInfo){
        self->apiCounter += 1;
        [self removeSkeletonView];
        return;
    }
    
    [[UserServices sharedInstance] getUserInfoWithCompletion:^(NSError *error, int statusCode) {
        if(statusCode == NoInternetErrorStatusCode || statusCode == SlowInternetErrorStatusCode) {
            [[NetworkManager sharedInstance] showConnectionErrorInViewController:self->delegate.tabBarController statusCode:statusCode];
            return;
        }
        
        self->apiCounter += 1;
        [self removeSkeletonView];
        
        if (statusCode == 200) {
            self->userInfo = [[UserModel sharedInstance] getUserInfo];
            self->_nameLbl.text = self->userInfo.userName;
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
        
        NSString *imgUrl = [[UserModel sharedInstance] getImageUrlOfMedia:@"profileImage"];
        [self->_profileImageView sd_setImageWithURL:[NSURL URLWithString:imgUrl] placeholderImage:[UIImage imageNamed:@"default-avatar"]];
    }];
}

- (void)getSummary{
    [[UserServices sharedInstance] getUserCommunitySummaryWithCompletion:^(NSError *error, int statusCode) {
        if(statusCode == NoInternetErrorStatusCode || statusCode == SlowInternetErrorStatusCode) {
            [[NetworkManager sharedInstance] showConnectionErrorInViewController:self->delegate.tabBarController statusCode:statusCode];
            return;
        }
        
        self->apiCounter += 1;
        [self removeSkeletonView];
        
        if (statusCode == 200) {
            self->summary = [[UserModel sharedInstance] getUserCommunitySummary];
            [self setSummary];
            return;
        }
        
        if(error){
            //there is error on the api side
            [[NetworkManager sharedInstance] showApiErrorInViewController:self->delegate.tabBarController error:error];
        }
    }];
}

- (void)setSummary{
    
    _communityRankLbl.text = [NSString stringWithFormat:@"#%d",summary.communityRank];
    _exercisesPointsValueLbl.text = @(summary.exercisePoints).stringValue;
    _habitPointsValueLbl.text = @(summary.habitPoints).stringValue;
    _rankingChangeLbl.text = [NSString stringWithFormat:@"%d %@",summary.communityRankChangePreviousWeek, [translationsModel getTranslationForKey:@"perf.total"]];
    _lastWeekLbl.text = [NSString stringWithFormat:@"%d%% %@",summary.communityRankChangePreviousWeekPercent, [translationsModel getTranslationForKey:@"perf.lastweek"]];
    
    if (summary.communityRankChangePreviousWeek < 0) {
        _rankingChangeStatusImgView.image = [UIImage imageNamed:@"down"];
    }else{
        _rankingChangeStatusImgView.image = [UIImage imageNamed:@"up"];
    }
    
    if (summary.communityRankChangePreviousWeekPercent < 0) {
        _lastWeekStatusImgView.image = [UIImage imageNamed:@"down"];
    }else{
        _lastWeekStatusImgView.image = [UIImage imageNamed:@"up"];
    }
}

- (void)getUserPerformance{
    NSDate *dateRegistered = [self dateRegistered];
    NSDate *currDate = [NSDate date];
    [[UserServices sharedInstance] getUserPerformanceWithStartDate:dateRegistered endDate:(NSDate *)currDate completion:^(NSError *error, int statusCode) {
        if(statusCode == NoInternetErrorStatusCode || statusCode == SlowInternetErrorStatusCode) {
            [[NetworkManager sharedInstance] showConnectionErrorInViewController:self->delegate.tabBarController statusCode:statusCode];
            return;
        }
        
        self->apiCounter += 1;
        [self removeSkeletonView];
        
        if (statusCode == 200) {
            [self setUpChart];
            [self->_calendarCollectionView reloadData];
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
    return [monthsAndYears count];
}

-(UICollectionViewCell *)collectionView:(UICollectionView *)collectionView cellForItemAtIndexPath:(NSIndexPath *)indexPath {
    
    UICollectionViewCell *cell = [_calendarCollectionView dequeueReusableCellWithReuseIdentifier:@"CalendarCollectionViewCellIdentifier" forIndexPath:indexPath];
    
    cell.backgroundColor=[UIColor clearColor];
    cell.contentView.backgroundColor = [UIColor clearColor];
    
    for (id child in [cell.contentView subviews]){
        [child removeFromSuperview];
    }
    
    cell.backgroundColor = [UIColor clearColor];
    cell.contentView.backgroundColor = [UIColor clearColor];
    
    UIView *calendarView = [[UIView alloc] initWithFrame:CGRectMake(0, 0, CGRectGetWidth(cell.contentView.frame), CGRectGetHeight(cell.contentView.frame))];
    calendarView.backgroundColor = [UIColor whiteColor];
    calendarView.layer.cornerRadius = 5.0;
    calendarView.clipsToBounds = YES;
    [cell.contentView addSubview:calendarView];
    
    CalendarObj *calendarObj = monthsAndYears[indexPath.row];
    
    NSDate *date = [[self returnDateFormatter] dateFromString:[NSString stringWithFormat:@"1/%d/%d", calendarObj.month, calendarObj.year]
                    ];
    NSLog(@"Date: %@", date);
    int numberOfDays = [self numberOfdaysinMonth:calendarObj.month WithDate:date];
    int index =  (int)[self weekDayForDate:date]-1;
    if(index == 0){
        index = 7;//starts at sunday
    }
    NSLog(@"Month = %d; index = %i", calendarObj.month, index);
    
    [self createCalendarIn:calendarView
                     month:calendarObj.month
                      year:calendarObj.year
          withNumberOfDays:numberOfDays
             startingAtDay:index];
    
    NSArray *performances = [[UserModel sharedInstance] getUserPerformanceThatContains:[NSString stringWithFormat:@"%d-%02.f", calendarObj.year, (float)calendarObj.month]];

    [self highlightDaysWithPerformances:performances inCalendar:calendarView];
    
    return cell;
}

- (CGSize)collectionView:(UICollectionView *)collectionView layout:(UICollectionViewLayout*)collectionViewLayout sizeForItemAtIndexPath:(NSIndexPath *)indexPath{
    
    CGSize cellSize = CGSizeMake(320, 300);
    return cellSize;
}

-(void)collectionView:(UICollectionView *)collectionView didSelectItemAtIndexPath:(NSIndexPath *)indexPath{
    [self.view endEditing:YES];
}

- (NSDateFormatter *)returnDateFormatter {
    NSDateFormatter *dateFormatter = [[NSDateFormatter alloc]init];
    [dateFormatter setDateFormat:@"dd/MM/yyyy"];
    return dateFormatter;
    
}

-(int)numberOfdaysinMonth:(int)selectedMonthNumber WithDate:(NSDate *)selectedDate
{
    NSCalendar* cal = [NSCalendar currentCalendar];
    NSDateComponents* comps = [[NSDateComponents alloc] init];
    // Set your month here
    [comps setMonth:selectedMonthNumber];
    
    NSRange range = [cal rangeOfUnit:NSCalendarUnitDay
                              inUnit:NSCalendarUnitMonth
                             forDate:selectedDate];
    NSLog(@"Range length: %lu", (unsigned long)range.length);
    return (int)range.length;
}

-(long)weekDayForDate:(NSDate *)date
{
    NSCalendar* cal = [NSCalendar currentCalendar];
    cal.firstWeekday = 2;
    NSDateComponents* comp = [cal components:NSCalendarUnitWeekday fromDate:date];
    return [comp weekday];
    
}

-(void)createCalendarIn:(UIView *)view month:(int)month year:(int)year withNumberOfDays:(int)numOfdays startingAtDay:(int)startIndex
{
    for (UIView *v  in [view subviews])
    {
        [v removeFromSuperview];
    }
    
    NSString *monthStr = [self getCompleteWithType:@"months"][month-1];
    
    UILabel *monthLbl = [[UILabel alloc]initWithFrame:CGRectMake(10, 20, CGRectGetWidth(view.frame)-20, 40)];
    monthLbl.text = [NSString stringWithFormat:@"%@ %i",monthStr, year];
    monthLbl.font = [fonts titleFont];
    monthLbl.textColor = [UIColor blackColor];
    [view addSubview:monthLbl];
    
    float weekDayX = 5;
    float weekDayY = 60;
    float weekDayW = (CGRectGetWidth(view.frame)-10) / 7;
    float weekDayH = 28;
    
    NSArray *weekDays = [self getCompleteWithType:@"days"];
    for (int i = 0; i<[weekDays count]; i++)
    {
        UILabel *label = [[UILabel alloc]initWithFrame:CGRectMake(weekDayX, weekDayY, weekDayW, weekDayH)];
        label.text = [NSString stringWithFormat:@"%@",weekDays[i]];
        label.font = [fonts smallFont];
        label.textColor = [UIColor blackColor];
        label.textAlignment = NSTextAlignmentCenter;
        [view addSubview:label];
        
        weekDayX += weekDayW;
    }
    
    float dateX = 5;
    float dateY = weekDayY + (weekDayH*2);
    float dateW = weekDayW;
    float dateH = weekDayH;
    
    for (int xcount =1; xcount<=7; xcount++)
    {
        if (xcount==startIndex)
        {
            break;
        }
        dateX += dateW;
    }
    
    for (int i = 1; i<=numOfdays; i++)
    {
        UILabel *label = [[UILabel alloc]initWithFrame:CGRectMake(dateX, dateY, dateW, dateH)];
        label.text = [NSString stringWithFormat:@"%d",i];
        label.font = [fonts smallFont];
        label.textColor = [UIColor blackColor];
        label.backgroundColor = [UIColor clearColor];
        label.textAlignment = NSTextAlignmentCenter;
        label.tag = i;
        [view addSubview:label];
        
        UIButton *dateButton = [UIButton buttonWithType:UIButtonTypeCustom];
        dateButton.frame = CGRectMake(dateX, dateY, dateW, dateH);
        dateButton.tag = i;
        dateButton.backgroundColor = [UIColor clearColor];
        [dateButton addTarget:self action:@selector(dateSelected:) forControlEvents:UIControlEventTouchUpInside];
        [view addSubview:dateButton];
        
        dateX += dateW;
        startIndex = startIndex+1;
        
        if (startIndex == 8)
        {
            dateX = 5;
            dateY += dateH+2;
            startIndex = 1;
        }
        
    }
    
}

- (void)highlightDaysWithPerformances:(NSArray *)performances inCalendar:(UIView *)calendarView{
    
    NSMutableArray *daysWithActivities = [NSMutableArray arrayWithCapacity:performances.count];
    for (UserPerformance *performance in performances) {
        NSArray *dateArr = [performance.performanceDate componentsSeparatedByString:@"-"];
        [daysWithActivities addObject:dateArr[2]];
    }
    
    for (UIView *v  in [calendarView subviews])
    {
        if ([v isKindOfClass:[UILabel class]]) {
            UILabel *lbl = (UILabel*)v;
            if ([daysWithActivities containsObject:@(lbl.tag).stringValue]){
                lbl.textColor = [UIColor whiteColor];
            }
        }
        
        if ([v isKindOfClass:[UIButton class]]) {
            UIButton *btn = (UIButton*)v;
            
            [daysWithActivities enumerateObjectsUsingBlock:^(NSString *day, NSUInteger idx, BOOL * _Nonnull stop) {
                if (day.intValue == btn.tag){
                    UIImageView *highlight = [[UIImageView alloc]
                                              initWithFrame:CGRectMake((CGRectGetMinX(btn.frame) + (CGRectGetWidth(btn.frame)/2)-(CGRectGetHeight(btn.frame)/2)), CGRectGetMinY(btn.frame), CGRectGetHeight(btn.frame), CGRectGetHeight(btn.frame))];
                    highlight.backgroundColor = [self->colors pinkColor];
                    highlight.layer.cornerRadius = CGRectGetHeight(btn.frame)/2;
                    [calendarView insertSubview:highlight atIndex:0];
                    
                    //To Do: add the date with activity here
                    [btn.layer setValue:performances[idx][@"performanceDate"] forKey:@"date"];
                }
            }];
            
            /*
             float r = CGRectGetHeight(btn.frame)/2;
             UIBezierPath *maskPath = [UIBezierPath
             bezierPathWithRoundedRect:highlight.bounds
             byRoundingCorners:(UIRectCornerBottomLeft | UIRectCornerTopLeft)
             cornerRadii:CGSizeMake(r, r)
             ];
             
             CAShapeLayer *maskLayer = [CAShapeLayer layer];
             maskLayer.frame = highlight.bounds;
             maskLayer.path = maskPath.CGPath;
             highlight.layer.mask = maskLayer;
             
             [view insertSubview:highlight atIndex:0];
             */
        }
    }
}

- (IBAction)dateSelected:(id)sender{
    NSLog(@"Date: %d",(int)[sender tag]);
    UIButton *btn = (UIButton *)sender;
    NSString *dateStr = [btn.layer valueForKey:@"date"];
    
    if ([dateStr length] > 0) {
        ActivityLogViewController *vc = [[ActivityLogViewController alloc] initWithNibName:@"ActivityLogViewController" bundle:nil];
        
        vc.view.backgroundColor = [UIColor clearColor];
        vc.modalPresentationStyle = UIModalPresentationOverCurrentContext;
        
        vc.selectedDate = dateStr;
        
        [delegate.tabBarController presentViewController:vc animated:NO completion:nil];
    }
}

- (IBAction)showSettings:(id)sender {
    self->_performanceChartView.hidden = YES;
    self->_chartSettingsView.hidden = YES;
    
    _chartSettingsView.transform = CGAffineTransformMakeScale(-1, 1);
    [UIView animateWithDuration:0.5 delay:0.0 options:UIViewAnimationOptionCurveEaseInOut
                     animations:^(void) {
                         self->_performanceView.transform = CGAffineTransformMakeScale(-1, 1);
                     }
                     completion:^(BOOL finished) {
                         self->_chartSettingsView.hidden = NO;
                     }];
}

- (IBAction)closeSettings:(id)sender {
    self->_performanceChartView.hidden = YES;
    self->_chartSettingsView.hidden = YES;
    
    [UIView animateWithDuration:0.5 delay:0.0 options:UIViewAnimationOptionCurveEaseInOut
                     animations:^(void) {
                         self->_performanceView.transform = CGAffineTransformMakeScale(1, 1);
                     }
                     completion:^(BOOL finished) {
                         self->_performanceChartView.hidden = NO;
                     }];
}

- (IBAction)chooseActivity:(id)sender {
    UIButton *selectedBtn = (UIButton *)sender;
    for(UIButton *btn in _activityButtons){
        btn.layer.cornerRadius = 5;
        btn.clipsToBounds = YES;
        
        if (btn == selectedBtn) {
            if (selectedBtn == _exerciseBtn) {
                activity = @"exercise";
            }else if (selectedBtn == _habitBtn){
                activity = @"habits";
            }
            
            [btn setTitleColor:[UIColor whiteColor] forState:UIControlStateNormal];
            btn.backgroundColor = [colors orangeColor];
            [btn.layer setBorderWidth:0];
        }else{
            [btn setTitleColor:[UIColor blackColor] forState:UIControlStateNormal];
            [btn.layer setBorderColor:[[UIColor grayColor] CGColor]];
            btn.backgroundColor = [UIColor clearColor];
            [btn.layer setBorderWidth:1.0];
        }
    }
    
    //Remove line mark as selected and points info on chart when choosing another setting
    _chartView.layer.sublayers = nil;
    
    self->_pointsLbl.text = @"";
    self->_dateLbl.text = @"";
    
    //Reload chart
    [self setUpChart];
}

- (IBAction)chooseCalendarSetting:(id)sender {
    UIButton *selectedBtn = (UIButton *)sender;
    for(UIButton *btn in _calendarButtons){
        btn.layer.cornerRadius = 5;
        btn.clipsToBounds = YES;
        
        if (btn == selectedBtn) {
            if (selectedBtn == _dayBtn) {
                calendarSetting = @"days";
                
                weekOffSet = 0;
                weekDates = [self daysInWeek:weekOffSet fromDate:[NSDate date]];
            }else if (selectedBtn == _weekBtn){
                calendarSetting = @"weeks";
            }else if (selectedBtn == _monthBtn){
                calendarSetting = @"month";
            }
            
            [btn setTitleColor:[UIColor whiteColor] forState:UIControlStateNormal];
            btn.backgroundColor = [colors orangeColor];
            [btn.layer setBorderWidth:0];
        }else{
            [btn setTitleColor:[UIColor blackColor] forState:UIControlStateNormal];
            [btn.layer setBorderColor:[[UIColor grayColor] CGColor]];
            btn.backgroundColor = [UIColor clearColor];
            [btn.layer setBorderWidth:1.0];
        }
    }
    
    //Remove line mark as selected and points info on chart when choosing another setting
    _chartView.layer.sublayers = nil;
    
    self->_pointsLbl.text = @"";
    self->_dateLbl.text = @"";
    
    //Reload chart
    [self setUpChart];
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

- (IBAction)communityRankList:(id)sender {
    CommunityRankingViewController *vc = [[CommunityRankingViewController alloc] initWithNibName:@"CommunityRankingViewController" bundle:nil];
    
    [self.navigationController pushViewController:vc animated:YES];
}

- (void)setUpChart{
    if ([calendarSetting isEqualToString:@"days"]) {
        _prevImgBtn.hidden = YES;
        _prevBtn.hidden = YES;
        _nextImgBtn.hidden = YES;
        _nextBtn.hidden = YES;
        
        legend = [self getSimplifiedWithType:@"days"];
        
    }else if ([calendarSetting isEqualToString:@"weeks"]){
        legend = [self weeks];

    }else if ([calendarSetting isEqualToString:@"month"]){
        legend = [self months];
    }
    
    if(legend.count <= legendCount){
        _nextBtn.hidden = YES;
        _nextImgBtn.hidden = YES;
        _prevBtn.hidden = YES;
        _prevImgBtn.hidden = YES;
    }else{
        _prevImgBtn.hidden = NO;
        _prevBtn.hidden = NO;
        _nextImgBtn.hidden = YES;
        _nextBtn.hidden = YES;
    }
    
    if(legend.count > legendCount){
        legendStart = (int) legend.count - legendCount;
    }else{
        legendStart = 0;
    }
    
    _chartView.delegate = self;
    
    _chartView.chartDescription.enabled = NO;
    
    _chartView.dragEnabled = NO;
    [_chartView setScaleEnabled:NO];
    _chartView.pinchZoomEnabled = NO;
    _chartView.drawGridBackgroundEnabled = NO;
    _chartView.xAxis.drawGridLinesEnabled = NO;
    _chartView.leftAxis.enabled = NO;
    _chartView.rightAxis.enabled = NO;

    _chartView.legend.verticalAlignment = ChartLegendVerticalAlignmentBottom;
    
    ChartXAxis *xAxis = _chartView.xAxis;
    xAxis.labelPosition = XAxisLabelPositionBottom;
    xAxis.granularityEnabled = true;
    xAxis.axisMinimum = 0.0;
    xAxis.granularity = 1.0;
    xAxis.valueFormatter = self;
    
    ChartYAxis *leftAxis = _chartView.leftAxis;
    leftAxis.axisMinimum = 0;
    ChartYAxis *rightAxis = _chartView.rightAxis;
    rightAxis.axisMinimum = 0;
    
    [self updateChartData];
    
    //set default selected
    [_chartView highlightValue:[[ChartHighlight alloc] initWithX:0 dataSetIndex:0 stackIndex:0] callDelegate:YES];
}

- (void)updateChartData{
    NSMutableArray *values = [[NSMutableArray alloc] init];
    
    int year = (int)[[self currentDateComponents] year];
    
    for (int i = 0; i < legendCount; i++){
        NSString *dateStr = @"";
        
        if ([calendarSetting isEqualToString:@"days"]) {
            NSDateFormatter *dateFormatter = [[NSDateFormatter alloc]init];
            [dateFormatter setDateFormat:@"yyyy-MM-dd"];
            
            dateStr = [dateFormatter stringFromDate:weekDates[i]];
        }else if ([calendarSetting isEqualToString:@"weeks"]){
            if(i>=legend.count){
                break;
            }
            
            int legendIndex = legendStart + i;
            NSDictionary *weekDict = legend[legendIndex];
            dateStr = [NSString stringWithFormat:@"%@-%@", weekDict[@"year"], weekDict[@"number"]];
        }else if ([calendarSetting isEqualToString:@"month"]){
            NSLog(@"Month Legend = %@", legend);
            if(i>=legend.count){
                break;
            }
            
            int legendIndex = legendStart + i;
            NSDictionary *monthDict = legend[legendIndex];
            dateStr = [NSString stringWithFormat:@"%@-%@", monthDict[@"year"], monthDict[@"number"]];
        }
        
        UserPerformance *performance = [[UserModel sharedInstance] getUserPerformanceFor:self->activity
                                                                            withDateType:self->calendarSetting
                                                                                 andDate:dateStr];
        
        double val = 0;
        if (performance != nil) {
            val = performance.points;
        }
        
        [values addObject:[[ChartDataEntry alloc] initWithX:i y:val icon: [UIImage imageNamed:@"icon"]]];
    }
    
    NSLog(@"Chart Values = %@", values);
    
    LineChartDataSet *set1 = nil;
    if (_chartView.data.dataSetCount > 0)
    {
        set1 = (LineChartDataSet *)_chartView.data.dataSets[0];
        set1.values = values;
        [_chartView.data notifyDataChanged];
        [_chartView notifyDataSetChanged];
    }
    else
    {
        set1 = [[LineChartDataSet alloc] initWithValues:values label:@"adsasd"];
        set1.lineDashLengths = @[@15.f, @0.f];
        [set1 setColor:UIColor.blackColor];
        set1.lineWidth = 1.0;
        set1.mode = LineChartModeHorizontalBezier;
        
        set1.drawIconsEnabled = NO;
        [set1 setCircleColor:UIColor.whiteColor];
        [set1 setCircleHoleColor:[UIColor redColor]];
        set1.circleRadius = 7.0;
        set1.drawCircleHoleEnabled = YES;
        
        set1.drawValuesEnabled = NO;
//        set1.valueFont = [UIFont systemFontOfSize:9.f];
        set1.formLineDashLengths = @[@5.f, @0.f];
        set1.formLineWidth = 1.0;
        set1.formSize = 15.0;
        
        set1.highlightLineDashLengths = @[@5.f, @0.f];
        set1.highlightColor = [UIColor clearColor];
        set1.drawHorizontalHighlightIndicatorEnabled = NO;
        set1.highlightLineWidth = 5.0f;
        
        NSArray *gradientColors = @[
                                    (id)[ChartColorTemplates colorFromString:@"#00ff0000"].CGColor,
                                    (id)[ChartColorTemplates colorFromString:@"#ffff0000"].CGColor
                                    ];
        CGGradientRef gradient = CGGradientCreateWithColors(nil, (CFArrayRef)gradientColors, nil);
        
        set1.fillAlpha = 1.f;
        set1.fill = [ChartFill fillWithLinearGradient:gradient angle:90.f];
        set1.drawFilledEnabled = NO;
        
        CGGradientRelease(gradient);
        
        NSMutableArray *dataSets = [[NSMutableArray alloc] init];
        [dataSets addObject:set1];
        
        LineChartData *data = [[LineChartData alloc] initWithDataSets:dataSets];
        
        _chartView.data = data;
    }
}

#pragma mark - ChartViewDelegate

- (void)chartValueSelected:(ChartViewBase * __nonnull)chartView entry:(ChartDataEntry * __nonnull)entry highlight:(ChartHighlight * __nonnull)highlight
{
    NSLog(@"chartValueSelected");
    int entryIndex = (int)entry.x;
    if ([calendarSetting isEqualToString:@"month"]){
        int legendIndex = legendStart + entryIndex;
        NSDictionary *valueDict = legend[legendIndex];
        if([valueDict[@"number"] intValue] == 99){
            return;
        }
    }
    
    CAGradientLayer *theViewGradient = [CAGradientLayer layer];
    [chartView.layer.sublayers.firstObject removeFromSuperlayer];
    
    NSArray *gradientColors = @[
                                (id)[ChartColorTemplates colorFromString:@"#00ff0000"].CGColor,
                                (id)[ChartColorTemplates colorFromString:@"#ffff0000"].CGColor
                                ];
    theViewGradient.colors = gradientColors;
    
    float xMargin;
    if (isnan(highlight.xPx)) {// For automatic selection
        if (highlight.x == 0) {// for automatic selection on first point
            xMargin = 10;
        }else{
            xMargin = (CGRectGetWidth(_chartView.frame)/6) * highlight.x;
        }
    }else{
        xMargin = highlight.xPx;
    }
    theViewGradient.frame = CGRectMake(xMargin, highlight.drawY, 2.0, CGRectGetHeight(chartView.frame)-50);
    
    //Add gradient to view
    [chartView.layer insertSublayer:theViewGradient atIndex:0];
    
    _pointsLbl.hidden = NO;
    _dateLbl.hidden = NO;
    
    _pointsLbl.text = @(entry.y).stringValue;
    
    int year = (int)[[self currentDateComponents] year];
    NSString *exercisePointsTranslationStr = @"";
    NSString *habitPointsTranslationStr = @"";
    NSString *dateStr = @"";
    
    
    if ([calendarSetting isEqualToString:@"days"]) {
        NSDateFormatter *dateFormatter = [[NSDateFormatter alloc]init];
        [dateFormatter setDateFormat:@"yyyy.MM.dd"];
        
        dateStr = [dateFormatter stringFromDate:weekDates[entryIndex]];
        
        exercisePointsTranslationStr = [NSString stringWithFormat:@"%@ \n %@",[translationsModel getTranslationForKey:@"perf.exercisepointsondate"], [translationsModel getTranslationForKey:@"perf.ondate"]];
        habitPointsTranslationStr = [NSString stringWithFormat:@"%@ \n %@",[translationsModel getTranslationForKey:@"global.habitpoints"], [translationsModel getTranslationForKey:@"perf.ondate"]];
        
    }else if ([calendarSetting isEqualToString:@"weeks"]){
        exercisePointsTranslationStr = [NSString stringWithFormat:@"%@ \n %@",[translationsModel getTranslationForKey:@"perf.exercisepointsondate"], [translationsModel getTranslationForKey:@"perf.weeknumber"]];
        habitPointsTranslationStr = [NSString stringWithFormat:@"%@ \n %@",[translationsModel getTranslationForKey:@"global.habitpoints"], [translationsModel getTranslationForKey:@"perf.weeknumber"]];
        
        int legendIndex = legendStart + entryIndex;
        NSDictionary *weekDist = legend[legendIndex];
        dateStr = [NSString stringWithFormat:@"%@, %@", weekDist[@"number"], weekDist[@"year"]];
        
    }else if ([calendarSetting isEqualToString:@"month"]){
        exercisePointsTranslationStr = [NSString stringWithFormat:@"%@ \n %@",[translationsModel getTranslationForKey:@"perf.exercisepointsondate"], [translationsModel getTranslationForKey:@"perf.monthdescr"]];
        habitPointsTranslationStr = [NSString stringWithFormat:@"%@ \n %@",[translationsModel getTranslationForKey:@"global.habitpoints"], [translationsModel getTranslationForKey:@"perf.monthdescr"]];
        
        int legendIndex = legendStart + entryIndex;
        NSDictionary *monthDict = legend[legendIndex];
        dateStr = [NSString stringWithFormat:@"%@, %@", monthDict[@"number"], monthDict[@"year"]];
    }
    
    if ([activity isEqualToString:@"exercise"]) {
        _dateLbl.text = [NSString stringWithFormat:@"%@ %@",exercisePointsTranslationStr, dateStr];
    }else{
        _dateLbl.text = [NSString stringWithFormat:@"%@ %@",habitPointsTranslationStr, dateStr];
    }
    
}

- (void)chartValueNothingSelected:(ChartViewBase * __nonnull)chartView
{
    NSLog(@"chartValueNothingSelected");
}


#pragma mark - IAxisValueFormatter

- (NSString *)stringForValue:(double)value
                        axis:(ChartAxisBase *)axis{
    int legendIndex = legendStart + (int)value;
    
    if([calendarSetting isEqualToString:@"weeks"]){
        NSString *weekNumber = [NSString stringWithFormat:@"%@",legend[legendIndex][@"number"]];
        if([weekNumber integerValue] == 99){
            return @"";
        }
        return [NSString stringWithFormat:@"%@",legend[legendIndex][@"number"]];
    }
    if([calendarSetting isEqualToString:@"month"]){
        NSString *monthInNumber = [NSString stringWithFormat:@"%@",legend[legendIndex][@"number"]];
        if([monthInNumber integerValue] == 99){
            return @"";
        }
        NSString *monthStr = [self getSimplifiedWithType:@"months"][[monthInNumber intValue]-1];
        return monthStr;
    }
    return legend[legendIndex];
}

- (IBAction)nextChart:(id)sender{
    if ([calendarSetting isEqualToString:@"days"]) {
        weekOffSet += 1;
        weekDates = [self daysInWeek:weekOffSet fromDate:[NSDate date]];
        [self updateChartData];
    
        [_chartView highlightValue:[[ChartHighlight alloc] initWithX:0 dataSetIndex:0 stackIndex:0] callDelegate:YES];
    }else{
        
        _prevBtn.hidden = NO;
        _prevImgBtn.hidden = NO;
        
        if (legend.count > legendCount){
            int dif = (int)legend.count - (legendStart + legendCount);
            if (dif < legendCount){
                legendStart = ((int)legend.count - legendCount);
            }else{
                legendStart += legendCount;
            }
            
            if (dif <= legendCount){
                _nextBtn.hidden = YES;
                _nextImgBtn.hidden = YES;
            }
            
            [self updateChartData];
            
            [_chartView highlightValue:[[ChartHighlight alloc] initWithX:0 dataSetIndex:0 stackIndex:0] callDelegate:YES];
        }
    }
    
}

- (IBAction)prevChart:(id)sender{
    if ([calendarSetting isEqualToString:@"days"]) {
        weekOffSet -= 1;
        weekDates = [self daysInWeek:weekOffSet fromDate:[NSDate date]];
        [self updateChartData];
        
        [_chartView highlightValue:[[ChartHighlight alloc] initWithX:0 dataSetIndex:0 stackIndex:0] callDelegate:YES];
    }else{
        _nextBtn.hidden = NO;
        _nextImgBtn.hidden = NO;
        
        if (legendStart < legendCount && legendStart >= 0){
            legendStart = 0;
        }else{
            legendStart -= legendCount;
        }
        
        if (legendStart == 0){
            _prevBtn.hidden = YES;
            _prevImgBtn.hidden = YES;
        }
        
        [self updateChartData];
        
        [_chartView highlightValue:[[ChartHighlight alloc] initWithX:0 dataSetIndex:0 stackIndex:0] callDelegate:YES];
    }
}

- (NSArray*)daysInWeek:(int)weekOffset fromDate:(NSDate*)date{
    NSDate *today = [NSDate date];
    NSLog(@"Today date is %@",today);
    NSDateFormatter *dateFormat = [[NSDateFormatter alloc] init];
    [dateFormat setDateFormat:@"yyyy-MM-dd"];// you can use your format.
    
    NSCalendar* cal = [[NSCalendar currentCalendar] copy];
    [cal setFirstWeekday:2]; //Override locale to make week start on Monday
    NSDate* startOfTheWeek;
    NSTimeInterval interval;
    [cal rangeOfUnit:NSCalendarUnitWeekOfYear startDate:&startOfTheWeek interval:&interval forDate:today];
    
    //add 7 days
    NSMutableArray *daysInWeek = [NSMutableArray arrayWithCapacity:7];
    for (int i=0; i<7; i++) {
        NSDateComponents *compsToAdd = [[NSDateComponents alloc] init];
        compsToAdd.day=i;
        NSDate *nextDate = [cal dateByAddingComponents:compsToAdd toDate:startOfTheWeek options:0];
        [daysInWeek addObject:nextDate];
    }
    NSLog(@"Days in Week = %@", daysInWeek.mutableCopy);
    return daysInWeek.mutableCopy;
}

#pragma mark - Skeleton View

- (void)addSkeletonView{
    apiCounter = 0;
    [skeletonView addSkeletonOn:_pointsView for:_exercisesPointsLbl isText:YES];
    [skeletonView addSkeletonOn:_pointsView for:_exercisesPointsValueLbl isText:YES];
    [skeletonView addSkeletonOn:_pointsView for:_habitPointsLbl isText:YES];
    [skeletonView addSkeletonOn:_pointsView for:_habitPointsValueLbl isText:YES];
    [skeletonView addSkeletonFor:_communityView isText:NO];
    [skeletonView addSkeletonFor:_profileImageView isText:NO];
    [skeletonView addSkeletonOn:_competitionView for:_rankingChangeLbl isText:YES];
    [skeletonView addSkeletonOn:_competitionView for:_rankingChangeStatusImgView isText:NO];
    [skeletonView addSkeletonOn:_competitionView for:_lastWeekLbl isText:YES];
    [skeletonView addSkeletonOn:_competitionView for:_lastWeekStatusImgView isText:NO];
    [skeletonView addSkeletonOn:_competitionView for:_nameLbl isText:YES];
    [skeletonView addSkeletonOnChartViewWithBounds:_performanceView.frame];
    [skeletonView addSkeletonOnCalendarCollectionViewWithBounds:_calendarCollectionView.frame withCellSize:CGSizeMake(320, 300)];
    [_contentView addSubview:skeletonView];
    
}

- (void)removeSkeletonView{
    if (apiCounter == 4) {
        [skeletonView remove];
        didRequestFromServer = YES;
        apiCounter = 0;
    }
}

@end
