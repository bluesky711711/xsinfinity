//
//  CommunityRankingViewController.m
//  XSInfinity
//
//  Created by Joseph Marvin Magdadaro on 7/4/18.
//  Copyright © 2018 Jerk Magz. All rights reserved.
//

#import "CommunityRankingViewController.h"
#import <SDWebImage/UIImageView+WebCache.h>
#import "DejalActivityView.h"
#import "CommunityRankingTableViewCell.h"
#import "Helper.h"
#import "CustomNavigation.h"
#import "Animations.h"
#import "AppDelegate.h"
#import "OtherProfileViewController.h"
#import "CommunityServices.h"
#import "RankingListObj.h"
#import "CustomAlertView.h"
#import "TranslationsModel.h"
#import "SkeletonView.h"
#import "TranslationsModel.h"
#import "NetworkManager.h"
#import "ToastView.h"

@interface CommunityRankingViewController ()<NetworkManagerDelegate, ToastViewDelegate>{
    Helper *helper;
    Animations *animations;
    CustomNavigation *customNavigation;
    AppDelegate *delegate;
    SkeletonView *skeletonView;
    BOOL didLayoutReloaded;
    NSArray *rankingList;
}

@property (weak, nonatomic) IBOutlet UITableView *tableView;

@property (nonatomic, assign) CGFloat lastContentOffset;

@end

@implementation CommunityRankingViewController

-(void)viewWillAppear:(BOOL)animated{
    [super viewWillAppear:YES];
    self.navigationController.navigationBar.hidden = NO;
}

- (void)viewDidLoad {
    [super viewDidLoad];
    self.navigationController.navigationBar.hidden = NO;
    self.navigationItem.title = [[TranslationsModel sharedInstance] getTranslationForKey:@"community.title"];
    self.navigationItem.largeTitleDisplayMode = UINavigationItemLargeTitleDisplayModeNever;
    
    UIButton *helpBtn = [[UIButton alloc] initWithFrame:CGRectMake(0, 0, 15, 13)];
    [helpBtn setBackgroundImage:[UIImage imageNamed:@"question_mark"] forState:UIControlStateNormal];
    [helpBtn addTarget:self action:@selector(info:)
        forControlEvents:UIControlEventTouchUpInside];
    //[helpBtn setShowsTouchWhenHighlighted:YES];
    
    UIBarButtonItem *rightBtn =[[UIBarButtonItem alloc] initWithCustomView:helpBtn];
    self.navigationItem.rightBarButtonItem = rightBtn;
    
    helper = [Helper sharedHelper];
    animations = [Animations sharedAnimations];
    customNavigation = [CustomNavigation sharedInstance];
    delegate = (AppDelegate *)[[UIApplication sharedApplication] delegate];
    
    skeletonView = [[SkeletonView alloc] initWithFrame:_tableView.frame];
    skeletonView.backgroundColor = [UIColor clearColor];
    
}

- (void)viewDidAppear:(BOOL)animated{
    [super viewDidAppear:YES];
    
    [[ToastView sharedInstance] setDelegate:self];
    [[NetworkManager sharedInstance] setDelegate:self];
    [[NetworkManager sharedInstance] connectivityMonitoring];
    
    [self getRankingList];
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
    [self getRankingList];
}

-(void)viewDidLayoutSubviews{
    [super viewDidLayoutSubviews];
    [_tableView layoutIfNeeded];
    
    if( !didLayoutReloaded ){
        [self setupUserInterface];
        
        didLayoutReloaded = YES;
    }
}

- (void)setupUserInterface{
    [animations setTabBar:delegate.tabBarController.tabBar fromViewController:self visible:YES animated:NO];
    
    [customNavigation addOrRemoveBlurEffectAndLineForNavigationInViewController:self];
}

- (void)getRankingList{
    [skeletonView addSkeletonOnRankingTableViewWithBounds:_tableView.frame withCellHeight:90];
    rankingList = @[];
    [_tableView addSubview:skeletonView];
    [_tableView reloadData];
    
    [[CommunityServices sharedInstance] getRankingListWithCompletion:^(NSError *error, int statusCode, NSArray *rankingList) {
        if(statusCode == NoInternetErrorStatusCode || statusCode == SlowInternetErrorStatusCode) {
            [[NetworkManager sharedInstance] showConnectionErrorInViewController:self->delegate.tabBarController statusCode:statusCode];
            return;
        }
        
        [self->skeletonView remove];
        
        if (!error && [rankingList count] > 0) {
            NSLog(@"Modules Count: %d", (int)[rankingList count]);
            NSLog(@"Modules: %@", rankingList);
            
            NSSortDescriptor *sortDescriptor;
            sortDescriptor = [[NSSortDescriptor alloc] initWithKey:@"rankNumber"
                                                         ascending:YES];
            self->rankingList = [rankingList sortedArrayUsingDescriptors:@[sortDescriptor]];
            [self.tableView reloadData];
            return;
        }
        
        if(error){
            //there is error on the api side
            [[NetworkManager sharedInstance] showApiErrorInViewController:self->delegate.tabBarController error:error];
        }
    }];
}

#pragma UITableViewDelegate and UITableViewDataSource

- (CGFloat)tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath{
    return 90;
}

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section{
    return [rankingList count];
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath{
    static NSString *simpleTableIdentifier = @"communityRankingTableViewCell";
    
    CommunityRankingTableViewCell *cell = (CommunityRankingTableViewCell *)[tableView dequeueReusableCellWithIdentifier:simpleTableIdentifier];
    
    if (cell == nil) {
        NSArray *nib = [[NSBundle mainBundle] loadNibNamed:@"CommunityRankingTableViewCell" owner:self options:nil];
        cell = [nib objectAtIndex:0];
    }
    cell.selectionStyle = UITableViewCellSelectionStyleNone;
    
    [cell layoutSubviews];
    [helper addDropShadowIn:cell.infoView withColor:[UIColor darkGrayColor] andSetCornerRadiusTo:5.0];
    
    RankingListObj *rank = rankingList[indexPath.row];
    
    cell.imgView.layer.cornerRadius = CGRectGetWidth(cell.imgView.frame)/2;
    cell.imgView.clipsToBounds = YES;
    [cell.imgView sd_setImageWithURL:[NSURL URLWithString:rank.profilePicture] placeholderImage:[UIImage imageNamed:@"default-avatar"]];
    
    cell.nameLbl.text = rank.name;
    cell.countryLbl.text = rank.country;
    cell.rankLbl.text = [NSString stringWithFormat:@"#%i", rank.rankNumber];
    
    return cell;
    
}

- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath{
    [self.view endEditing:YES];
    
    RankingListObj *rank = rankingList[indexPath.row];
    
    OtherProfileViewController *vc = [[OtherProfileViewController alloc] initWithNibName:@"OtherProfileViewController" bundle:nil];
    vc.identifier = rank.identifier;
    [self.navigationController pushViewController:vc animated:YES];
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

- (IBAction)info:(id)sender{
    [[CustomAlertView sharedInstance] showAlertInViewController:delegate.tabBarController
                                     withTitle:[[TranslationsModel sharedInstance] getTranslationForKey:@"community.popuptitle"]
                                       message:[[TranslationsModel sharedInstance] getTranslationForKey:@"community.text"]
                             cancelButtonTitle:[[TranslationsModel sharedInstance] getTranslationForKey:@"community.button"]
                               doneButtonTitle:nil];
    [[CustomAlertView sharedInstance] setCancelBlock:^(id result) {
        NSLog(@"Cancel");
    }];
}

- (IBAction)back:(id)sender {
    [self.navigationController popViewControllerAnimated:YES];
}

@end
