//
//  ActivityLogViewController.m
//  XSInfinity
//
//  Created by Joseph Marvin Magdadaro on 7/10/18.
//  Copyright © 2018 Jerk Magz. All rights reserved.
//

#import "ActivityLogViewController.h"
#import <Social/Social.h>
#import "WXApi.h"
#import "DejalActivityView.h"
#import "Animations.h"
#import "Colors.h"
#import "Fonts.h"
#import "TranslationsModel.h"
#import "CustomAlertView.h"
#import "CommunityServices.h"
#import "ExerciseActivityObj.h"
#import "HabitActivityObj.h"
#import "AppUsageObj.h"
#import "SkeletonView.h"
#import "NetworkManager.h"
#import "ToastView.h"
#import "AppDelegate.h"

static int const cellHeight = 30;

@interface ActivityLogViewController ()<NetworkManagerDelegate, ToastViewDelegate>{
    Animations *animations;
    Colors *colors;
    Fonts *fonts;
    TranslationsModel *translationsModel;
    SkeletonView *skeletonView;
    AppDelegate *delegate;
    BOOL didLayoutReloaded;
    NSArray *exercises, *habits, *appUsage;
}

@property (weak, nonatomic) IBOutlet UIView *mainView;

@property (weak, nonatomic) IBOutlet NSLayoutConstraint *contentViewTopConstraint;
@property (weak, nonatomic) IBOutlet UIView *contentView;
@property (weak, nonatomic) IBOutlet UIView *scrollContentView;
@property (weak, nonatomic) IBOutlet UILabel *titleLbl;
@property (weak, nonatomic) IBOutlet UILabel *dateLbl;
@property (weak, nonatomic) IBOutlet UILabel *exercisesFinishedLbl;
@property (weak, nonatomic) IBOutlet UILabel *habitsCompletedLbl;
@property (weak, nonatomic) IBOutlet UILabel *appUsedLbl;
@property (weak, nonatomic) IBOutlet UILabel *timeUsageLbl;
@property (weak, nonatomic) IBOutlet UILabel *shareLbl;

@property (weak, nonatomic) IBOutlet UITableView *exercisesTableView;
@property (weak, nonatomic) IBOutlet NSLayoutConstraint *exercisesTableViewHeightConstraint;

@property (weak, nonatomic) IBOutlet UITableView *habitsTableView;
@property (weak, nonatomic) IBOutlet NSLayoutConstraint *habitsTableViewHeightConstraint;

@property (weak, nonatomic) IBOutlet NSLayoutConstraint *lineViewHeightConstraint;

@property (weak, nonatomic) IBOutlet NSLayoutConstraint *scrollViewContentHeightConstraint;
@property (weak, nonatomic) IBOutlet UIButton *appUsedInfoSign;
@property (weak, nonatomic) IBOutlet NSLayoutConstraint *appUsedInfoSignConstraintHeight;
@property (weak, nonatomic) IBOutlet NSLayoutConstraint *appUsageLblConstraintHeight;
@property (weak, nonatomic) IBOutlet NSLayoutConstraint *totalUsageInfoSignConstraintHeight;
@property (weak, nonatomic) IBOutlet NSLayoutConstraint *totalUsageLblConstraintHeight;
@property (weak, nonatomic) IBOutlet NSLayoutConstraint *habitInfoSignConstraintHeight;
@property (weak, nonatomic) IBOutlet NSLayoutConstraint *habitLblConstraintHeight;

@end

@implementation ActivityLogViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    self.navigationController.navigationBar.hidden = YES;
    
    animations = [Animations sharedAnimations];
    colors = [Colors sharedColors];
    fonts = [Fonts sharedFonts];
    translationsModel = [TranslationsModel sharedInstance];
    delegate = (AppDelegate *)[[UIApplication sharedApplication] delegate];
    
    skeletonView = [[SkeletonView alloc] initWithFrame:_scrollContentView.frame];
    skeletonView.layer.cornerRadius = 15;
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
-(void)retryConnection{
    if([[NetworkManager sharedInstance] isConnectionOffline]){
        [[NetworkManager sharedInstance] showConnectionErrorInViewController:self];
        return;
    }
    [self getData];
}


-(void)viewDidLayoutSubviews{
    [super viewDidLayoutSubviews];
    [_mainView layoutIfNeeded];
    
    if( !didLayoutReloaded ){
        [self getData];
        [self setupUserInterface];
        
        didLayoutReloaded = YES;
    }
}

- (void)setupUserInterface{
    _contentViewTopConstraint.constant = 645;
    [_mainView layoutIfNeeded];
    [animations animateOverlayViewIn:_mainView byTopConstraint:_contentViewTopConstraint];
    
    _titleLbl.font = [fonts headerFontLight];
    _dateLbl.font = [fonts headerFontLight];
    _exercisesFinishedLbl.font = [fonts normalFont];
    _habitsCompletedLbl.font = [fonts normalFont];
    _appUsedLbl.font = [fonts normalFont];
    _timeUsageLbl.font = [fonts normalFont];
    _shareLbl.font = [fonts headerFontLight];
    
    _titleLbl.text = [translationsModel getTranslationForKey:@"dailylog.title"];
    _shareLbl.text = [translationsModel getTranslationForKey:@"global.shareon"];
    
    _exercisesFinishedLbl.text = [NSString stringWithFormat:@"%d %@",0, [self->translationsModel getTranslationForKey:@"dailylog.exercisesfinished"]];
    _habitsCompletedLbl.text = [NSString stringWithFormat:@"%@: %d %@ %d",[self->translationsModel getTranslationForKey:@"dailylog.habitscompleted"], 0, [self->translationsModel getTranslationForKey:@"headsup.of"], 0];
    _appUsedLbl.text = [NSString stringWithFormat:@"%@: %d %@",[translationsModel getTranslationForKey:@"dailylog.appusedtoday"], 0, [translationsModel getTranslationForKey:@"dailylog.times"]];
    _timeUsageLbl.text = [NSString stringWithFormat:@"%@: 0 %@",[translationsModel getTranslationForKey:@"dailylog.totalusage"], [translationsModel getTranslationForKey:@"dailylog.minutes"]];
    
    NSDateFormatter *dateFormatter = [[NSDateFormatter alloc]init];
    [dateFormatter setDateFormat:@"yyyy-MM-dd"];
    NSDate *date = [dateFormatter dateFromString:self.selectedDate];
    
    _dateLbl.text = [self dayWithSuffixMonthAndYearForDate:date];
    
    [self adjustHeightOfTableview];
}

//NOTE: transfer to helper
- (NSString *)dayWithSuffixMonthAndYearForDate:(NSDate *)date {
    
    NSDateFormatter *dateFormatter = [[NSDateFormatter alloc] init];
    [dateFormatter setDateFormat:@"MMM. yyyy"];
    NSString *monthYear = [dateFormatter stringFromDate:date];
    
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
    
    return [NSString stringWithFormat:@"%@ %@",day, monthYear];
}

- (void)adjustHeightOfTableview{
    CGFloat exercisesTableViewHeight = [exercises count] * cellHeight;
    _exercisesTableViewHeightConstraint.constant = exercisesTableViewHeight;
    
    CGFloat habitsTableViewHeight = [habits count] * cellHeight;
    _habitsTableViewHeightConstraint.constant = habitsTableViewHeight;
    
    CGFloat exercisesTableViewHeightDiff = exercisesTableViewHeight - CGRectGetHeight(_exercisesTableView.frame);
    CGFloat habitsTableViewHeightDiff = habitsTableViewHeight - CGRectGetHeight(_habitsTableView.frame);
    _lineViewHeightConstraint.constant += exercisesTableViewHeightDiff + habitsTableViewHeightDiff;
    
    _scrollViewContentHeightConstraint.constant += exercisesTableViewHeightDiff + habitsTableViewHeightDiff;
    
    [self.view layoutIfNeeded];
    
}

- (void)getData{
    [skeletonView addSkeletonOnOverlayViewWithBounds:_scrollContentView.frame];
    [_scrollContentView addSubview:skeletonView];
    
    [[CommunityServices sharedInstance] getActivitiesForUserWithCompletion:^(NSError *error, int statusCode, NSDictionary *userActivities) {
        if(statusCode == NoInternetErrorStatusCode || statusCode == SlowInternetErrorStatusCode) {
            [[NetworkManager sharedInstance] showConnectionErrorInViewController:self statusCode:statusCode];
            return;
        }
        
        [self->skeletonView remove];
        
        if (!error && userActivities != nil) {
            NSArray *historyExercises = [[userActivities[@"historyExercises"] filteredArrayUsingPredicate:[NSPredicate predicateWithFormat:@"passDate == %@", self->_selectedDate]] mutableCopy];
            self->exercises = historyExercises;
            self->_exercisesFinishedLbl.text = [NSString stringWithFormat:@"%d %@",(int)[self->exercises count], [self->translationsModel getTranslationForKey:@"dailylog.exercisesfinished"]];
            [self->_exercisesTableView reloadData];
            
            self->habits = userActivities[@"historyHabitPeriods"];
            if(self->habits.count == 0){
                self->_habitInfoSignConstraintHeight.constant = 0;
                self->_habitLblConstraintHeight.constant = 0;
            }
            self->_habitsCompletedLbl.text = [NSString stringWithFormat:@"%@: %d %@ %d",[self->translationsModel getTranslationForKey:@"dailylog.habitscompleted"], (int)[self->habits count], [self->translationsModel getTranslationForKey:@"headsup.of"], 7];
            [self->_habitsTableView reloadData];
            
            self->appUsage = userActivities[@"historyUsages"];
            [self calculateAppUsage];
            
            [self adjustHeightOfTableview];
            return;
        }
        
        if(error){
            //there is error on the api side
            [[NetworkManager sharedInstance] showApiErrorInViewController:self error:error];
        }
    }];
    
}

- (void)calculateAppUsage{
    
    NSDateFormatter *dateFormatter = [[NSDateFormatter alloc]init];
    [dateFormatter setDateFormat:@"yyyy-MM-dd'T'HH:mm:ssZ"];
    NSDate *date = [dateFormatter dateFromString:self.selectedDate];
    
    [dateFormatter setDateFormat:@"yyyy-MM-dd"];
    NSString *selectedDate = [dateFormatter stringFromDate:date];
    
    int appUsedCounter = 0;
    int numOfTimesAppUsed = 0;
    for (AppUsageObj *obj in appUsage){
        
        NSDateFormatter *dateFormatter = [[NSDateFormatter alloc]init];
        [dateFormatter setDateFormat:@"yyyy-MM-dd'T'HH:mm:ssZ"];
        NSDate *date = [dateFormatter dateFromString:obj.creationDate];
        
        [dateFormatter setDateFormat:@"yyyy-MM-dd"];
        NSString *creationDate = [dateFormatter stringFromDate:date];
        
        if ([selectedDate isEqualToString:creationDate]) {
            appUsedCounter += 1;
            numOfTimesAppUsed += obj.duration;
        }
    }
    
    _appUsedLbl.text = [NSString stringWithFormat:@"%@: %d %@",[translationsModel getTranslationForKey:@"dailylog.appusedtoday"], appUsedCounter, [translationsModel getTranslationForKey:@"dailylog.times"]];
    
    int minutes = numOfTimesAppUsed / 60;
    int seconds = numOfTimesAppUsed % 60;
    float duration = minutes + (seconds * 0.01);
    _timeUsageLbl.text = [NSString stringWithFormat:@"%@: %.2f %@",[translationsModel getTranslationForKey:@"dailylog.totalusage"], duration, [translationsModel getTranslationForKey:@"dailylog.minutes"]];//dailylog.hours
    
    if(appUsedCounter == 0){
        _appUsedInfoSignConstraintHeight.constant = 0;
        _appUsageLblConstraintHeight.constant = 0;
    }
    
    if(numOfTimesAppUsed == 0){
        _totalUsageInfoSignConstraintHeight.constant = 0;
        _totalUsageLblConstraintHeight.constant = 0;
    }
}

#pragma UITableViewDelegate and UITableViewDataSource

- (CGFloat)tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath{
    return cellHeight;
}

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section{
    if (tableView == _exercisesTableView) {
        return [exercises count];
    }else{
        return [habits count];
    }
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath{
    
    static NSString *simpleTableIdentifier = @"SimpleTableItem";
    
    UITableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:simpleTableIdentifier];
    
    if (cell == nil) {
        cell = [[UITableViewCell alloc] initWithStyle:UITableViewCellStyleDefault reuseIdentifier:simpleTableIdentifier];
    }
    
    if (indexPath.row > 0) {
        UIView *line1 = [[UIView alloc] initWithFrame:CGRectMake(6.5, 0, 2, 15)];
        line1.backgroundColor = [UIColor blackColor];
        [cell addSubview:line1];
    }
    
    if (indexPath.row < ([tableView numberOfRowsInSection:0]-1)) {
        UIView *line2 = [[UIView alloc] initWithFrame:CGRectMake(6.5, 15, 2, 15)];
        line2.backgroundColor = [UIColor blackColor];
        [cell addSubview:line2];
    }
    
    int dotWH = 15;
    UIView *dot = [[UIView alloc] initWithFrame:CGRectMake(0, 7.5, dotWH, dotWH)];
    dot.backgroundColor = [UIColor blackColor];
    dot.layer.cornerRadius = 7.5;
    dot.clipsToBounds = YES;
    [cell addSubview:dot];
    
    UILabel *txtLbl = [[UILabel alloc] initWithFrame:CGRectMake(25, 0, CGRectGetWidth(cell.frame)-25, 30)];
    txtLbl.font = [fonts normalFont];
    
    if (tableView == _exercisesTableView) {
        ExerciseActivityObj *exercise = exercises[indexPath.row];
        if(exercise.name.length > 0){
            txtLbl.text = [NSString stringWithFormat:@"%@, %d %@",exercise.name, exercise.points, [translationsModel getTranslationForKey:@"global.points"]];
        }else{
            txtLbl.text = [NSString stringWithFormat:@"%d %@",exercise.points, [translationsModel getTranslationForKey:@"global.points"]];
        }
    }else{
        HabitActivityObj *habit = habits[indexPath.row];
        if(habit.name.length > 0){
            txtLbl.text = [NSString stringWithFormat:@"%@, %d %@",habit.name, habit.points, [translationsModel getTranslationForKey:@"global.points"]];
        }else{
            txtLbl.text = [NSString stringWithFormat:@"%d %@",habit.points, [translationsModel getTranslationForKey:@"global.points"]];
        }
        
    }
    
    [cell addSubview:txtLbl];
    
    return cell;
    
}

- (IBAction)back:(id)sender{
    [self dismissViewControllerAnimated:YES completion:nil];
}

- (IBAction)shareWeChat:(id)sender{
    SendMessageToWXReq *req = [[SendMessageToWXReq alloc] init];
    req.text = @"The quick brown fox jumped over the lazy dogs.";
    req.bText = YES;
    req.scene = WXSceneTimeline;
    
    [WXApi sendReq:req];
}

- (IBAction)shareFB:(id)sender{
    BOOL isInstalled = [[UIApplication sharedApplication] canOpenURL:[NSURL URLWithString:@"fb://"]];
    
    if (isInstalled) {
        SLComposeViewController *mySLComposerSheet = [SLComposeViewController composeViewControllerForServiceType:SLServiceTypeFacebook];
        
        [mySLComposerSheet setInitialText:@"Post from my app"];
        [mySLComposerSheet addURL:[NSURL URLWithString:@"http://www.google.com"]];
        
        [mySLComposerSheet setCompletionHandler:^(SLComposeViewControllerResult result) {
            
            switch (result) {
                case SLComposeViewControllerResultCancelled:
                    NSLog(@"Post Canceled");
                    break;
                case SLComposeViewControllerResultDone:
                    NSLog(@"Post Sucessful");
                    break;
                    
                default:
                    break;
            }
        }];
        
        [self presentViewController:mySLComposerSheet animated:YES completion:nil];
    } else {
        NSLog(@"The twitter service is not available");
        
        [[CustomAlertView sharedInstance] showAlertInViewController:self
                                                          withTitle:[translationsModel getTranslationForKey:@"info.share"]
                                                            message:[translationsModel getTranslationForKey:@"info.facebooknotavail"]
                                                  cancelButtonTitle:[[TranslationsModel sharedInstance] getTranslationForKey:@"global.rateokay"]
                                                    doneButtonTitle:nil];
        [[CustomAlertView sharedInstance] setCancelBlock:^(id result) {
            NSLog(@"Okay");
        }];
    }
}

- (IBAction)shareTwitter:(id)sender{
    
    BOOL isInstalled = [[UIApplication sharedApplication] canOpenURL:[NSURL URLWithString:@"twitter://"]];
    
    if (isInstalled) {
        SLComposeViewController *mySLComposerSheet = [SLComposeViewController composeViewControllerForServiceType:SLServiceTypeTwitter];
        
        [mySLComposerSheet setInitialText:@"Tweet from my app"];
        [mySLComposerSheet addURL:[NSURL URLWithString:@"http://www.google.com"]];
        
        [mySLComposerSheet setCompletionHandler:^(SLComposeViewControllerResult result) {
            
            switch (result) {
                case SLComposeViewControllerResultCancelled:
                    NSLog(@"Post Canceled");
                    break;
                case SLComposeViewControllerResultDone:
                    NSLog(@"Post Sucessful");
                    break;
                    
                default:
                    break;
            }
        }];
        
        [self presentViewController:mySLComposerSheet animated:YES completion:nil];
    } else {
        NSLog(@"The twitter service is not available");
        
        [[CustomAlertView sharedInstance] showAlertInViewController:self
                                                          withTitle:[translationsModel getTranslationForKey:@"info.share"]
                                                            message:[translationsModel getTranslationForKey:@"info.twitternotavail"]
                                                  cancelButtonTitle:[[TranslationsModel sharedInstance] getTranslationForKey:@"global.rateokay"]
                                                    doneButtonTitle:nil];
        [[CustomAlertView sharedInstance] setCancelBlock:^(id result) {
            NSLog(@"Okay");
        }];
    }
}

@end
