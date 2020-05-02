//
//  HeadsUpViewController.m
//  XSInfinity
//
//  Created by Joseph Marvin Magdadaro on 8/8/18.
//  Copyright © 2018 Jerk Magz. All rights reserved.
//

#import "HeadsUpViewController.h"
#import <Social/Social.h>
#import "AppDelegate.h"
#import "WXApi.h"
#import "DejalActivityView.h"
#import "Helper.h"
#import "Animations.h"
#import "Colors.h"
#import "Fonts.h"
#import "TranslationsModel.h"
#import "CustomAlertView.h"
#import "UserServices.h"
#import "ExercisesObj.h"
#import "SkeletonView.h"
#import "HeadsUpInfoTableViewCell.h"
#import "NetworkManager.h"
#import "ToastView.h"

static int const cellHeight = 60;

@interface HeadsUpViewController ()<NetworkManagerDelegate, ToastViewDelegate>{
    Helper *helper;
    Animations *animations;
    Colors *colors;
    Fonts *fonts;
    TranslationsModel *translationsModel;
    SkeletonView *skeletonView;
    AppDelegate *delegate;
    BOOL didLayoutReloaded;
    BOOL isHabitResetedToday;
    NSArray *unlockedExercises;
}

@property (weak, nonatomic) IBOutlet UIView *mainView;

@property (weak, nonatomic) IBOutlet NSLayoutConstraint *contentViewTopConstraint;
@property (weak, nonatomic) IBOutlet UIView *contentView;
@property (weak, nonatomic) IBOutlet UIView *scrollContentView;
@property (weak, nonatomic) IBOutlet UIView *scrollSubContentView;
@property (weak, nonatomic) IBOutlet UILabel *titleLbl;

@property (weak, nonatomic) IBOutlet UIView *achievementsView;
@property (weak, nonatomic) IBOutlet UILabel *achievementsLbl;
@property (weak, nonatomic) IBOutlet UILabel *exercisesCountLbl;
@property (weak, nonatomic) IBOutlet UILabel *habitsCountLbl;
@property (weak, nonatomic) IBOutlet UIImageView *exercisesThumb;
@property (weak, nonatomic) IBOutlet UIImageView *habitsThumb;
@property (weak, nonatomic) IBOutlet UIImageView *exerciseXIcon;
@property (weak, nonatomic) IBOutlet UIImageView *habitsXIcon;
@property (weak, nonatomic) IBOutlet UIImageView *exerciseIcon;
@property (weak, nonatomic) IBOutlet UIImageView *habitIcon;

@property (weak, nonatomic) IBOutlet UITableView *tableView;
@property (weak, nonatomic) IBOutlet NSLayoutConstraint *tableViewHeightConstraint;

@property (weak, nonatomic) IBOutlet UIView *shareView;
@property (weak, nonatomic) IBOutlet UIButton *hideBtn;
@property (weak, nonatomic) IBOutlet UILabel *hideLbl;
@property (weak, nonatomic) IBOutlet UILabel *shareLbl;

@property (weak, nonatomic) IBOutlet UIButton *weChatBtn;
@property (weak, nonatomic) IBOutlet UIButton *fbBtn;
@property (weak, nonatomic) IBOutlet UIButton *twitterBtn;

@property (weak, nonatomic) IBOutlet NSLayoutConstraint *scrollViewContentHeightConstraint;

@end

@implementation HeadsUpViewController

- (void)viewWillAppear:(BOOL)animated{
    [super viewWillAppear:YES];
    
}

- (void)viewDidLoad {
    [super viewDidLoad];
    self.navigationController.navigationBar.hidden = YES;
    
    helper = [Helper sharedHelper];
    animations = [Animations sharedAnimations];
    colors = [Colors sharedColors];
    fonts = [Fonts sharedFonts];
    translationsModel = [TranslationsModel sharedInstance];
    delegate = (AppDelegate *)[[UIApplication sharedApplication] delegate];
    
    skeletonView = [[SkeletonView alloc] initWithFrame:_scrollContentView.frame];
    skeletonView.layer.cornerRadius = 15;
    
    [_tableView addObserver:self forKeyPath:@"contentSize" options:0 context:NULL];
}

- (void)observeValueForKeyPath:(NSString *)keyPath ofObject:(id)object change:(NSDictionary *)change context:(void *)context
{
    _tableViewHeightConstraint.constant = self.tableView.contentSize.height;
    
    CGFloat tableViewHeightDiff = self.tableView.contentSize.height - CGRectGetHeight(_tableView.frame);
    _scrollViewContentHeightConstraint.constant += tableViewHeightDiff;
    [self.view layoutIfNeeded];
}

- (void)viewDidAppear:(BOOL)animated{
    [super viewDidAppear:YES];
    _scrollSubContentView.hidden = YES;
    
    //[[ToastView sharedInstance] setDelegate:self];
    [[NetworkManager sharedInstance] setDelegate:self];
    [[NetworkManager sharedInstance] connectivityMonitoring];
    
    [self addSkeletonView];
    [self getHeadsUp];
    
}

- (void)viewDidDisappear:(BOOL)animated{
    [super viewDidDisappear:YES];
    //[[NetworkManager sharedInstance] stopMonitoring];
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
    
    [self setupUserInterface];
    [self addSkeletonView];
    [self getHeadsUp];
}

-(void)viewDidLayoutSubviews{
    [super viewDidLayoutSubviews];
    [_mainView layoutIfNeeded];
    
    if( !didLayoutReloaded ){
        [self setupUserInterface];
        
        didLayoutReloaded = YES;
    }
}

- (void)setupUserInterface{
    _contentViewTopConstraint.constant = 645;
    [_mainView layoutIfNeeded];
    [animations animateOverlayViewIn:_mainView byTopConstraint:_contentViewTopConstraint];
    
    _titleLbl.font = [fonts headerFontLight];
    _achievementsLbl.font = [fonts normalFont];
    _exercisesCountLbl.font = [fonts titleFontBold];
    _habitsCountLbl.font = [fonts titleFontBold];
    _hideLbl.font = [fonts normalFont];
    _shareLbl.font = [fonts normalFont];
    
    _achievementsLbl.font = [fonts normalFont];
    _achievementsLbl.adjustsFontSizeToFitWidth = YES;
    
    _titleLbl.text = [translationsModel getTranslationForKey:@"headsup.title"];
    _achievementsLbl.text = [translationsModel getTranslationForKey:@"headsup.description"];
    _exercisesCountLbl.text = [NSString stringWithFormat:@"0 %@ 0",[translationsModel getTranslationForKey:@"headsup.of"]];
    _habitsCountLbl.text = [NSString stringWithFormat:@"0 %@ 0",[translationsModel getTranslationForKey:@"headsup.of"]];
    _hideLbl.text = [translationsModel getTranslationForKey:@"headsup.hideswitch"];
    _shareLbl.text = [translationsModel getTranslationForKey:@"global.shareon"];
    
    _exercisesThumb.tintColor = [UIColor blackColor];
    _habitsThumb.tintColor = [UIColor blackColor];
    [self setUpHideButton];
    
    UIImage *exerciseIconImg = [[UIImage imageNamed:@"exercise"] imageWithRenderingMode:UIImageRenderingModeAlwaysTemplate];
    UIImage *habitIconImg = [[UIImage imageNamed:@"infinity"] imageWithRenderingMode:UIImageRenderingModeAlwaysTemplate];
    UIImage *xIconImg = [[UIImage imageNamed:@"x"] imageWithRenderingMode:UIImageRenderingModeAlwaysTemplate];
    
    _habitIcon.image = habitIconImg;
    _habitIcon.tintColor = [UIColor blackColor];
    _exerciseIcon.image = exerciseIconImg;
    _exerciseIcon.tintColor = [UIColor blackColor];
    _habitsXIcon.image = xIconImg;
    _habitsXIcon.tintColor = [UIColor blackColor];
    _exerciseXIcon.image = xIconImg;
    _exerciseXIcon.tintColor = [UIColor blackColor];
}

- (void)getHeadsUp{
    
    [[UserServices sharedInstance] getTodaysHeadUpWithCompletion:^(NSError *error, int statusCode, HeadUpObj *headUp) {
        if(statusCode == NoInternetErrorStatusCode || statusCode == SlowInternetErrorStatusCode) {
            [[NetworkManager sharedInstance] showConnectionErrorInViewController:self statusCode:statusCode];
            return;
        }
        
        [self removeSkeletonView];
        
        if (headUp != nil) {
            self->_exercisesThumb.hidden = NO;
            self->_habitsThumb.hidden = NO;
            
            UIImage *thumbupImg = [[UIImage imageNamed:@"thumbup"] imageWithRenderingMode:UIImageRenderingModeAlwaysTemplate];
            UIImage *thumbdownImg = [[UIImage imageNamed:@"thumbdown"] imageWithRenderingMode:UIImageRenderingModeAlwaysTemplate];
            
            self->_exercisesCountLbl.text = [NSString stringWithFormat:@"%d %@ %d",headUp.passedExercises, [self->translationsModel getTranslationForKey:@"headsup.of"], headUp.personalExerciseGoal];
            self->_habitsCountLbl.text = [NSString stringWithFormat:@"%d %@ %d",headUp.passedHabits ,[self->translationsModel getTranslationForKey:@"headsup.of"], headUp.possibleHabits];
            
            if (headUp.passedExercises > 0) {
                self->_exercisesThumb.image = thumbupImg;
                self->_exercisesCountLbl.textColor = [self->colors greenColor];
            }else {
                self->_exercisesThumb.image = thumbdownImg;
                self->_exercisesCountLbl.textColor = [UIColor redColor];
            }
            
            if (headUp.passedHabits >= headUp.possibleHabits && headUp.possibleHabits > 0) {
                self->_habitsThumb.image = thumbupImg;
                self->_habitsCountLbl.textColor = [self->colors greenColor];
            }else {
                self->_habitsThumb.image = thumbdownImg;
                self->_habitsCountLbl.textColor = [UIColor redColor];
            }
            
            self->isHabitResetedToday = headUp.resetHabitTracker;
            
            self->unlockedExercises = headUp.unlockedExercises;
            [self->_tableView reloadData];
        }
        
        if(self->unlockedExercises.count == 0){
            self->_tableView.hidden = YES;
            [self->helper setFlexibleBorderIn:self->_achievementsView withColor:[UIColor grayColor] topBorderWidth:0 leftBorderWidth:0 rightBorderWidth:0 bottomBorderWidth:0.0f];
            [self->helper setFlexibleBorderIn:self->_shareView withColor:[UIColor grayColor] topBorderWidth:0.0f leftBorderWidth:0 rightBorderWidth:0 bottomBorderWidth:0];
        }else{
            self->_tableView.hidden = NO;
            [self->helper setFlexibleBorderIn:self->_achievementsView withColor:[UIColor grayColor] topBorderWidth:0 leftBorderWidth:0 rightBorderWidth:0 bottomBorderWidth:0.5f];
            [self->helper setFlexibleBorderIn:self->_shareView withColor:[UIColor grayColor] topBorderWidth:0.5f leftBorderWidth:0 rightBorderWidth:0 bottomBorderWidth:0];
        }
        
    }];

}

#pragma UITableViewDelegate and UITableViewDataSource

-(CGFloat)tableView:(UITableView *)tableView estimatedHeightForRowAtIndexPath:(NSIndexPath *)indexPath {
    return 44;
}

- (CGFloat)tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath
{
    return UITableViewAutomaticDimension;
}

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section{
    /*if (isHabitResetedToday) {
        return [unlockedExercises count]+1;
    }else{*/
        return [unlockedExercises count];
    //}
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath{
    static NSString *headsUpInfoTableViewCell = @"headsUpInfoTableViewCell";
    
    HeadsUpInfoTableViewCell *cell = (HeadsUpInfoTableViewCell *)[tableView dequeueReusableCellWithIdentifier:headsUpInfoTableViewCell];
    
    if (cell == nil) {
        NSArray *nib = [[NSBundle mainBundle] loadNibNamed:@"HeadsUpInfoTableViewCell" owner:self options:nil];
        cell = [nib objectAtIndex:0];
    }
    cell.backgroundColor = [UIColor clearColor];
    cell.contentView.backgroundColor = [UIColor clearColor];
    
    ExercisesObj *exercise = unlockedExercises[indexPath.row];
    NSString *msg = [[[translationsModel getTranslationForKey:@"headsup.msg6"] componentsSeparatedByString:@"{"][0] stringByTrimmingCharactersInSet:[NSCharacterSet whitespaceAndNewlineCharacterSet]];
    NSString *difficulty = [exercise.difficulty stringByTrimmingCharactersInSet:[NSCharacterSet whitespaceAndNewlineCharacterSet]];
    NSString *moduleName = [exercise.moduleName stringByTrimmingCharactersInSet:[NSCharacterSet whitespaceAndNewlineCharacterSet]];
    
    cell.titleLbl.text = [NSString stringWithFormat:@"%@ %@ %@ %@",msg, difficulty, [translationsModel getTranslationForKey:@"headsup.of"], moduleName];
    cell.titleLbl.font = [fonts normalFont];
    cell.titleLbl.numberOfLines = 0;
    [cell.titleLbl setLineHeight];
    
    /*if (TRUE){
        
        if (indexPath.row == 0) {
            cell.titleLbl.text = [translationsModel getTranslationForKey:@"headsup.msg4"];
            cell.titleLbl.font = [fonts normalFont];
            cell.titleLbl.numberOfLines = 0;
            [cell.titleLbl setLineHeight];
        }else{
            ExercisesObj *exercise = unlockedExercises[indexPath.row - 1];
            NSString *msg = [[translationsModel getTranslationForKey:@"headsup.msg6"] componentsSeparatedByString:@"{"][0];
            
            cell.titleLbl.text = [NSString stringWithFormat:@"%@ %@ %@ %@",msg, exercise.difficulty, [translationsModel getTranslationForKey:@"headsup.of"], @"moduleName"];
            cell.titleLbl.font = [fonts normalFont];
            cell.titleLbl.numberOfLines = 0;
            [cell.titleLbl setLineHeight];
        }
        
    }*/
    
    NSLog(@"Tableview height = %f", _tableView.contentSize.height);
    
    return cell;
    
}

- (IBAction)selectHideHeadsUp:(id)sender{
    //hide for the day
    if (![helper isHeadsUpHidden]){
        NSDate *currDate = [NSDate date];
        HIDE_HEADS_UP_TODAY(currDate)
    
    //unhide
    }else{
        HIDE_HEADS_UP_TODAY(nil)
    }
    
    [self setUpHideButton];
}

- (BOOL) isHeadsUpHidden{
    return false;
}

- (void)setUpHideButton{
    if ([helper isHeadsUpHidden]){
        _hideBtn.layer.borderWidth = 0;
        _hideBtn.backgroundColor = [colors orangeColor];
        _hideBtn.layer.cornerRadius = 5.0;
        _hideBtn.clipsToBounds = YES;
    }else{
        _hideBtn.layer.borderWidth = 1.0;
        _hideBtn.layer.borderColor = [UIColor blackColor].CGColor;
        _hideBtn.backgroundColor = [UIColor clearColor];
        _hideBtn.layer.cornerRadius = 5.0;
        _hideBtn.clipsToBounds = YES;
    }
}

- (IBAction)back:(id)sender{
    [self dismissViewControllerAnimated:YES completion:nil];
}

- (void)addSkeletonView{
    [skeletonView addSkeletonFor:_titleLbl isText:YES];
    
    [skeletonView addSkeletonOn:_achievementsView for:_achievementsLbl isText:YES];
    [skeletonView addSkeletonOn:_achievementsView for:_exercisesCountLbl isText:YES];
    [skeletonView addSkeletonOn:_achievementsView for:_habitsCountLbl isText:YES];
    
    [skeletonView addSkeletonOn:_shareView for:_hideLbl isText:YES];
    [skeletonView addSkeletonOn:_shareView for:_hideBtn isText:NO];
    [skeletonView addSkeletonOn:_shareView for:_shareLbl isText:YES];
    [skeletonView addSkeletonOn:_shareView for:_weChatBtn isText:NO];
    [skeletonView addSkeletonOn:_shareView for:_fbBtn isText:NO];
    [skeletonView addSkeletonOn:_shareView for:_twitterBtn isText:NO];
    
    _tableView.hidden = YES;
    [skeletonView addSkeletonHeadsUpTableViewWithBounds:_tableView.frame];
    [_scrollContentView addSubview:skeletonView];
}

- (void)removeSkeletonView{
    [skeletonView remove];
    _scrollSubContentView.hidden = NO;
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
