//
//  OtherProfileViewController.m
//  XSInfinity
//
//  Created by Joseph Marvin Magdadaro on 7/5/18.
//  Copyright © 2018 Jerk Magz. All rights reserved.
//

#import "OtherProfileViewController.h"
#import <SDWebImage/UIImageView+WebCache.h>
#import "DejalActivityView.h"
#import "AppDelegate.h"
#import "Helper.h"
#import "Fonts.h"
#import "Colors.h"
#import "TranslationsModel.h"
#import "Animations.h"
#import "GalleryCollectionViewCell.h"
#import "ActivityLogViewController.h"
#import "CommunityServices.h"
#import "GalleryObj.h"
#import "SkeletonView.h"
#import "NetworkManager.h"
#import "ToastView.h"

@interface OtherProfileViewController ()<NetworkManagerDelegate, ToastViewDelegate>{
    Helper *helper;
    Fonts *fonts;
    Colors *colors;
    TranslationsModel *translationsModel;
    Animations *animations;
    AppDelegate *delegate;
    SkeletonView *skeletonView;
    BOOL didLayoutReloaded;
    BOOL isListView;
    NSArray *galleryList;
    float selectLblMinY;
    float coverImageMaxY;
    float lastCoverImageMaxY;
    BOOL isParallaxEnabled;
}
@property (weak, nonatomic) IBOutlet UIView *coverView;
@property (weak, nonatomic) IBOutlet UIImageView *coverImageView;
@property (weak, nonatomic) IBOutlet NSLayoutConstraint *coverViewTopConstraint;
@property (weak, nonatomic) IBOutlet NSLayoutConstraint *coverImageViewWidthConstraint;

@property (weak, nonatomic) IBOutlet UIScrollView *scrollView;
@property (weak, nonatomic) IBOutlet UIView *contentView;

@property (nonatomic, assign) CGFloat lastContentOffset;

@property (weak, nonatomic) IBOutlet UIImageView *profileImageView;
@property (weak, nonatomic) IBOutlet UILabel *nameLbl;
@property (weak, nonatomic) IBOutlet UILabel *countryLbl;
@property (weak, nonatomic) IBOutlet UIButton *pinBtn;

@property (weak, nonatomic) IBOutlet UIView *pointsView;
@property (weak, nonatomic) IBOutlet UIView *communityView;
@property (weak, nonatomic) IBOutlet UILabel *communityLbl;
@property (weak, nonatomic) IBOutlet UILabel *communityRankLbl;
@property (weak, nonatomic) IBOutlet UILabel *exercisesPointsLbl;
@property (weak, nonatomic) IBOutlet UILabel *exercisesPointsValueLbl;
@property (weak, nonatomic) IBOutlet UILabel *habitPointsLbl;
@property (weak, nonatomic) IBOutlet UILabel *habitPointsValueLbl;

@property (weak, nonatomic) IBOutlet UILabel *selectLbl;
@property (weak, nonatomic) IBOutlet UIButton *gridBtn;
@property (weak, nonatomic) IBOutlet UIButton *listBtn;

@property (weak, nonatomic) IBOutlet UICollectionView *collectionView;

@property (weak, nonatomic) IBOutlet NSLayoutConstraint *collectionViewHeightConstraint;
@property (weak, nonatomic) IBOutlet NSLayoutConstraint *scrollViewContentHeightConstraint;

@end

@implementation OtherProfileViewController

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
    
    skeletonView = [[SkeletonView alloc] initWithFrame:_contentView.frame];
    skeletonView.backgroundColor = [UIColor clearColor];
    
}

- (void)viewDidAppear:(BOOL)animated{
    [super viewDidAppear:YES];
    
    _pointsView.hidden = NO;
    _communityView.hidden = NO;
    
    [[NetworkManager sharedInstance] setDelegate:self];
    [[NetworkManager sharedInstance] setDelegate:self];
    [[NetworkManager sharedInstance] connectivityMonitoring];
    
    [self addSkeletonView];
    [self getProfileInfo];
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
    [self addSkeletonView];
    [self getProfileInfo];
}

-(void)viewDidLayoutSubviews{
    [super viewDidLayoutSubviews];
    
    if( !didLayoutReloaded ){
        [self setupUserInterface];
        
        coverImageMaxY = CGRectGetMaxY(_coverView.frame);
        
        didLayoutReloaded = YES;
    }
}

- (void)setupUserInterface{
    [animations setTabBar:delegate.tabBarController.tabBar fromViewController:self visible:YES animated:NO];
    
    [_pointsView layoutIfNeeded];
    [helper addDropShadowIn:_pointsView withColor:[UIColor darkGrayColor] andSetCornerRadiusTo:5.0];
    
    _communityView.backgroundColor = [colors purpleColor];
    _communityView.layer.cornerRadius = 5.0;
    _communityView.clipsToBounds = YES;
    
    _profileImageView.layer.cornerRadius = CGRectGetWidth(_profileImageView.frame)/2;
    _profileImageView.clipsToBounds = YES;
    [_profileImageView.layer setBorderColor: [[colors orangeColor] CGColor]];
    [_profileImageView.layer setBorderWidth: 3.0];
    
    _communityLbl.font = [fonts normalFont];
    _communityRankLbl.font = [fonts headerFont];
    _exercisesPointsLbl.font = [fonts normalFont];
    _exercisesPointsValueLbl.font = [fonts headerFont];
    _habitPointsLbl.font = [fonts normalFont];
    _habitPointsValueLbl.font = [fonts headerFont];
    _nameLbl.font = [fonts headerFontLight];
    _countryLbl.font = [fonts normalFont];
    _selectLbl.font = [fonts titleFont];
    
    _communityLbl.text = [translationsModel getTranslationForKey:@"global.infinitycommunity"];
    _exercisesPointsLbl.text = [translationsModel getTranslationForKey:@"global.exercisepoints"];
    _habitPointsLbl.text = [translationsModel getTranslationForKey:@"global.habitpoints"];
    _selectLbl.text = [translationsModel getTranslationForKey:@"otheruser.gallery_title"];
    
    _selectLbl.adjustsFontSizeToFitWidth = YES;
    
    _profileImageView.hidden = YES;
    _nameLbl.hidden = YES;
    _countryLbl.hidden = YES;
    _pointsView.hidden = YES;
    _communityView.hidden = YES;
    
    _pinBtn.hidden = YES;
    _gridBtn.hidden = YES;
    _listBtn.hidden = YES;
    
    isParallaxEnabled = YES;
}

- (void)getProfileInfo{
    [[CommunityServices sharedInstance] getOtherUserProfile:self.identifier withCompletion:^(NSError *error, int statusCode, OtherProfileObj *otherProfile) {
        
        if(statusCode == NoInternetErrorStatusCode || statusCode == SlowInternetErrorStatusCode) {
            [[NetworkManager sharedInstance] showConnectionErrorInViewController:self->delegate.tabBarController statusCode:statusCode];
            return;
        }
        
        [self removeSkeletonView];
        
        if (!error && otherProfile != nil) {
            self->_communityRankLbl.text = [NSString stringWithFormat:@"#%d",otherProfile.communityRank];
            self->_exercisesPointsValueLbl.text = @(otherProfile.exercisePoints).stringValue;
            self->_habitPointsValueLbl.text = @(otherProfile.habitPoints).stringValue;
            self->_nameLbl.text = otherProfile.name;
            self->_countryLbl.text = otherProfile.country;
            self->_selectLbl.text = [NSString stringWithFormat:@"- %@'s %@",otherProfile.name, [self->translationsModel getTranslationForKey:@"otheruser.gallery_title"]];
            
            [self->_profileImageView sd_setImageWithURL:[NSURL URLWithString:otherProfile.profilePictureUrl] placeholderImage:[UIImage imageNamed:@"default-avatar"]];
            
            NSString *predString = [NSString stringWithFormat:@"isPrivate == 0 AND type == 'galleryImage'"];
            NSPredicate *pred = [NSPredicate predicateWithFormat:predString];
            
            NSArray *gallery = [otherProfile.gallery filteredArrayUsingPredicate:pred];
            self->galleryList = gallery;
            
            NSURL *coverUrl = nil;
            if(self->galleryList.count > 0){
                GalleryObj *gallery = self->galleryList[0];
                coverUrl = [NSURL URLWithString:gallery.url];
            }
            [self->_coverImageView sd_setImageWithURL:coverUrl placeholderImage:[UIImage imageNamed:@"placeholder-background-profile-user"]];
            
            [self.collectionView reloadData];
            
            [self adjustHeightOfTableview];
            
            NSString *country = [_countryLbl.text stringByTrimmingCharactersInSet:[NSCharacterSet whitespaceAndNewlineCharacterSet]];
            if(country.length == 0)
                self->_pinBtn.hidden = YES;
            else
                self->_pinBtn.hidden = NO;
            
        }
        
        if(error){
            //there is error on the api side
            [[NetworkManager sharedInstance] showApiErrorInViewController:self->delegate.tabBarController error:error];
        }
    }];
}

- (void)adjustHeightOfTableview{
    float cellHeight = [self cellSize].height;
    
    int lineCount = (int)[galleryList count];
    
    if (!isListView) {
        lineCount = (int)[galleryList count]/2;
        float tempCount = (float)[galleryList count]/2;
        if (tempCount > lineCount){
            lineCount += 1;
        }
    }
    
    CGFloat collectionViewHeight = lineCount * (cellHeight + 15);
    _collectionViewHeightConstraint.constant = collectionViewHeight;
    
    CGFloat collectionViewHeightDiff = collectionViewHeight - CGRectGetHeight(_collectionView.frame);
    _scrollViewContentHeightConstraint.constant += collectionViewHeightDiff;
    
    [self.view layoutIfNeeded];
    
}

#pragma mark - UICollectionview DataSource & Delegate
-(NSInteger)numberOfSectionsInCollectionView:(UICollectionView *)collectionView {
    return 1;
}

-(NSInteger)collectionView:(UICollectionView *)collectionView numberOfItemsInSection:(NSInteger)section{
    return [galleryList count];
}

-(UICollectionViewCell *)collectionView:(UICollectionView *)collectionView cellForItemAtIndexPath:(NSIndexPath *)indexPath {
    
    static NSString *identifier = @"GalleryCollectionViewCell";
    GalleryCollectionViewCell *cell = (GalleryCollectionViewCell *)[_collectionView dequeueReusableCellWithReuseIdentifier:identifier forIndexPath:indexPath];
    
    GalleryObj *gallery = galleryList[indexPath.row];
    
    [cell.imgView sd_setImageWithURL:[NSURL URLWithString:gallery.url] placeholderImage:nil];
    
    NSDateFormatter *dateFormatter = [[NSDateFormatter alloc]init];
    [dateFormatter setDateFormat:@"yyyy-MM-dd'T'HH:mm:ssZ"];
    NSDate *date = [dateFormatter dateFromString:gallery.creationDate];
    
    cell.dateLbl.text = [self dayWithSuffixAndMonthForDate:date];
    cell.optionBtn.hidden = YES;
    
    return cell;
}

- (CGSize)collectionView:(UICollectionView *)collectionView layout:(UICollectionViewLayout*)collectionViewLayout sizeForItemAtIndexPath:(NSIndexPath *)indexPath{
    
    return [self cellSize];
}

- (CGSize)cellSize{
    int cellW = 0.0;
    int cellH = 0.0;
    
    if (isListView) {
        cellW = CGRectGetWidth(_collectionView.frame) - 40;
        cellH = cellW * 0.9;
    }else{
        cellW = CGRectGetWidth(_collectionView.frame) / 2.36;
        cellH = cellW * 0.95;
    }
    
    CGSize cellSize = CGSizeMake(cellW, cellH);
    return cellSize;
}

-(void)collectionView:(UICollectionView *)collectionView didSelectItemAtIndexPath:(NSIndexPath *)indexPath{
    [self.view endEditing:YES];
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
    NSLog(@"Scroll offset: 176 %f",scrollOffset);
    
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
            self->_coverViewTopConstraint.constant = lastCoverImageMaxY;
            
        }else {
            float pos = (scrollOffset / 3) * -1;
            self->_coverViewTopConstraint.constant = pos;
            lastCoverImageMaxY = pos;
        }

        [UIView animateWithDuration:0 animations:^{
            [self->_coverView layoutIfNeeded];
            [self.view layoutIfNeeded];
        } completion:nil];
        
    }else if (scrollOffset <= 0){
        NSLog(@"scrolling down");
        _coverImageViewWidthConstraint.constant = (scrollOffset * -1.5);
        
    }
    
    _lastContentOffset = scrollOffset;
}

- (IBAction)gridView:(id)sender {
    [_gridBtn setImage:[UIImage imageNamed:@"grid_active"] forState:UIControlStateNormal];
    [_listBtn setImage:[UIImage imageNamed:@"list_inactive"] forState:UIControlStateNormal];
    
    isListView = FALSE;
    [_collectionView reloadData];
    [self adjustHeightOfTableview];
}

- (IBAction)listView:(id)sender {
    [_listBtn setImage:[UIImage imageNamed:@"list_active"] forState:UIControlStateNormal];
    [_gridBtn setImage:[UIImage imageNamed:@"grid_inactive"] forState:UIControlStateNormal];
    
    isListView = TRUE;
    [_collectionView reloadData];
    [self adjustHeightOfTableview];
}

- (IBAction)back:(id)sender{
    [self.navigationController popViewControllerAnimated:YES];
}

- (void)addSkeletonView{
    
    [skeletonView addSkeletonFor:_profileImageView isText:NO];
    [skeletonView addSkeletonFor:_nameLbl isText:YES];
    [skeletonView addSkeletonFor:_countryLbl isText:YES];
    
    [skeletonView addSkeletonOn:_pointsView for:_exercisesPointsLbl isText:YES];
    [skeletonView addSkeletonOn:_pointsView for:_exercisesPointsValueLbl isText:YES];
    [skeletonView addSkeletonOn:_pointsView for:_habitPointsLbl isText:YES];
    [skeletonView addSkeletonOn:_pointsView for:_habitPointsValueLbl isText:YES];
    [skeletonView addSkeletonFor:_communityView isText:NO];
    
    [skeletonView addSkeletonOnExerciseListCollectionView:_collectionView withCellSize:[self cellSize]];
    [_contentView addSubview:skeletonView];
    
}

- (void)removeSkeletonView{
    [skeletonView remove];
    
    _profileImageView.hidden = NO;
    _nameLbl.hidden = NO;
    _countryLbl.hidden = NO;
    _gridBtn.hidden = NO;
    _listBtn.hidden = NO;
    
    NSString *country = [_countryLbl.text stringByTrimmingCharactersInSet:[NSCharacterSet whitespaceAndNewlineCharacterSet]];
    if(country.length == 0)
        _pinBtn.hidden = YES;
    else
        _pinBtn.hidden = NO;
}

@end
