//
//  ExercisesListViewController.m
//  XSInfinity
//
//  Created by Joseph Marvin Magdadaro on 6/4/18.
//  Copyright © 2018 Joseph Marvin Magdadaro. All rights reserved.
//

#import "ExercisesListViewController.h"
#import <SDWebImage/UIImageView+WebCache.h>
#import "NetworkManager.h"
#import "DejalActivityView.h"
#import "CustomAlertView.h"
#import "Helper.h"
#import "Fonts.h"
#import "Colors.h"
#import "TranslationsModel.h"
#import "ExercisesListCollectionViewCell.h"
#import "ExercisesFilterViewController.h"
#import "Animations.h"
#import "AppDelegate.h"
#import "CustomNavigation.h"
#import "ModulesServices.h"
#import "ModulesModel.h"
#import "ExercisesObj.h"
#import "SingleExerciseViewController.h"
#import "BookmarkedExercises.h"
#import "SkeletonView.h"
#import "ExercisesObj.h"
#import "ToastView.h"
#import "NetworkManager.h"


@interface ExercisesListViewController ()<UISearchBarDelegate, UISearchControllerDelegate, UISearchResultsUpdating, ExercisesFilterViewControllerDelegate, NetworkManagerDelegate, ToastViewDelegate>{
    Helper *helper;
    Fonts *fonts;
    Colors *colors;
    TranslationsModel *translationsModel;
    Animations *animations;
    AppDelegate *delegate;
    CustomNavigation *customNavigation;
    SkeletonView *skeletonView;
    BOOL didLayoutReloaded;
    NSArray *availableExercises, *exercisesArr;
    NSArray *bookmarkedExercises;
}

@property (weak, nonatomic) IBOutlet UILabel *headerLbl;
@property (weak, nonatomic) IBOutlet UITextField *searchTxtFld;
@property (weak, nonatomic) IBOutlet UICollectionView *collectionView;
@property (retain, nonatomic) UISearchController *searchController;

@property (nonatomic, assign) CGFloat lastContentOffset;

@end

@implementation ExercisesListViewController

/*
 *  TO DO
 *      √ multiple tags/focus areas
 *      √ use ids for focus ares
 *      √ pass filter params from other page
 *      √ auto set filter params to the filter page
 *      √ should show locked icon for locked exercises
 *      - show all focus areas (included tags) - api issue
 *      √ fix locked / unlocked in single module
 *      √ show ranking tips / info
 *      - search bar hides when exercises are fiew
 */

-(void)viewWillAppear:(BOOL)animated{
    [super viewWillAppear:YES];
    float scrollOffset = _collectionView.contentOffset.y;
    
    if (scrollOffset < 0)
        [[Animations sharedAnimations] setTabBar:delegate.tabBarController.tabBar fromViewController:self visible:YES animated:NO];
    
//    [[CustomNavigation sharedInstance] addOrRemoveBlurEffectAndLineForNavigationInViewController:self];
    self.navigationItem.hidesSearchBarWhenScrolling = false;
    
    [self setTranslationsAndFonts];
    [self checkBookmarks];
    
}

- (void)viewDidLoad {
    [super viewDidLoad];
    self.navigationController.navigationBar.hidden = NO;
    [self.navigationController.navigationBar setBackgroundImage:[UIImage new] forBarMetrics:UIBarMetricsDefault];
    self.navigationController.navigationBar.shadowImage = [UIImage new];
    self.navigationController.navigationBar.prefersLargeTitles = TRUE;
    self.navigationItem.largeTitleDisplayMode = UINavigationItemLargeTitleDisplayModeAlways;
    self.navigationItem.title = [[TranslationsModel sharedInstance] getTranslationForKey:@"exlist.title"];
    
    //[[UIBarButtonItem appearanceWhenContainedInInstancesOfClasses:@[[UISearchBar class]]] setTintColor:[UIColor redColor]];
    
    _searchController = [[UISearchController alloc] initWithSearchResultsController:nil];
    _searchController.delegate = self;
    _searchController.searchBar.tintColor = [UIColor whiteColor];
    //_searchController.searchResultsUpdater = self;//
    /*_searchController.searchBar.translucent = false;
    _searchController.searchBar.backgroundImage = nil;
    _searchController.searchBar.barTintColor = [UIColor greenColor];
    _searchController.searchBar.tintColor = [UIColor orangeColor];*/
    _searchController.dimsBackgroundDuringPresentation = NO;
    _searchController.searchBar.delegate = self;
    _searchController.searchBar.placeholder = [[TranslationsModel sharedInstance] getTranslationForKey:@"exlist.searchbar_title"];
    //_searchController.searchBar.searchBarStyle = UISearchBarStyleMinimal;
    //_searchController.searchBar.layer.borderWidth = 0;
    //_searchController.searchBar.layer.borderColor = [[UIColor redColor] CGColor];
    
    self.navigationItem.searchController = _searchController;
    /*self.navigationItem.searchController.searchBar.translucent = false;
    self.navigationItem.searchController.searchBar.layer.borderWidth = 0;
    self.navigationItem.searchController.searchBar.layer.borderColor = [[UIColor redColor] CGColor];
    self.navigationItem.searchController.searchBar.searchBarStyle = UISearchBarStyleMinimal;*/
    
    for (UIView *view in _searchController.searchBar.subviews[0].subviews){
        if ([view isKindOfClass:[UITextField class]]){
            UITextField *searchField = (UITextField *)view;
            [searchField setBackgroundColor:[UIColor whiteColor]];
            [searchField setBorderStyle:UITextBorderStyleNone];
            searchField.layer.cornerRadius = 5.0;
            searchField.clipsToBounds = YES;
        }
    }
    
    int w = 15;
    int h = 13;
    
    UIButton *filterBtn = [[UIButton alloc] initWithFrame:CGRectMake(0, 0, w, h)];
    [filterBtn setBackgroundImage:[UIImage imageNamed:@"filter"] forState:UIControlStateNormal];
    [filterBtn addTarget:self action:@selector(filter:)
         forControlEvents:UIControlEventTouchUpInside];
    //[filterBtn setShowsTouchWhenHighlighted:YES];
    
    UIBarButtonItem *rightBtn =[[UIBarButtonItem alloc] initWithCustomView:filterBtn];
    self.navigationItem.rightBarButtonItem = rightBtn;
    
    helper = [Helper sharedHelper];
    fonts = [Fonts sharedFonts];
    colors = [Colors sharedColors];
    translationsModel = [TranslationsModel sharedInstance];
    animations = [Animations sharedAnimations];
    customNavigation = [CustomNavigation sharedInstance];
    delegate = (AppDelegate *)[[UIApplication sharedApplication] delegate];
    
    skeletonView = [[SkeletonView alloc] initWithFrame:_collectionView.frame];
    skeletonView.backgroundColor = [UIColor clearColor];
    
    //Register Collection
    [_collectionView registerNib:[UINib nibWithNibName:@"ExercisesListCollectionViewCell" bundle:nil] forCellWithReuseIdentifier:@"ExercisesListCollectionViewCell"];
    
}

-(void)viewDidLayoutSubviews{
    [super viewDidLayoutSubviews];
    
    if( !didLayoutReloaded ){
        [self setupUserInterface];
        
        didLayoutReloaded = YES;
    }
}

- (void)viewDidAppear:(BOOL)animated{
    [super viewDidAppear:YES];
    self.navigationItem.hidesSearchBarWhenScrolling = true;
    
    [[CustomNavigation sharedInstance] addOrRemoveBlurEffectAndLineForNavigationInViewController:self];
    [[ToastView sharedInstance] setDelegate:self];
    [[NetworkManager sharedInstance] setDelegate:self];
    [[NetworkManager sharedInstance] connectivityMonitoring];
    [self getAllExercisesWithParams:self.lastFilter];
    
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
    [self getAllExercisesWithParams:self.lastFilter];
}

- (void)setupUserInterface{
//    UIImageView *imgView = [[UIImageView alloc] initWithFrame:CGRectMake(0, 0, CGRectGetWidth(_collectionView.frame), CGRectGetHeight(_collectionView.frame) + 80)];
//    imgView.image = [UIImage imageNamed:@"bg"];
//    [_collectionView insertSubview:imgView atIndex:0];
    
    [self setTranslationsAndFonts];
}

- (void)setTranslationsAndFonts{
    _headerLbl.font = [fonts headerFont];
    _searchTxtFld.font = [fonts normalFont];
    
    self.navigationItem.title = [[TranslationsModel sharedInstance] getTranslationForKey:@"exlist.title"];
    
    _searchController.searchBar.placeholder = [[TranslationsModel sharedInstance] getTranslationForKey:@"exlist.searchbar_title"];
    
    _headerLbl.text = [translationsModel getTranslationForKey:@"exlist.title"];
    _searchTxtFld.placeholder = [translationsModel getTranslationForKey:@"exlist.searchbar_title"];
}

- (void)getAllExercisesWithParams:(NSDictionary *)params{
    [skeletonView addSkeletonOnExerciseListCollectionView:_collectionView withCellSize:[self cellSize]];
    [_collectionView addSubview:skeletonView];
    
    [[ModulesServices sharedInstance] getAvailableExercisesWithCompletion:^(NSError *error, int statusCode, NSArray *exercises) {
        NSLog(@"Available Exercises = %@", exercises);
        if(statusCode == NoInternetErrorStatusCode || statusCode == SlowInternetErrorStatusCode) {
            [[NetworkManager sharedInstance] showConnectionErrorInViewController:self->delegate.tabBarController statusCode:statusCode];
            return;
        }
        
        if(exercises.count == 0){
            self->exercisesArr = nil;
        }
        
        if(error){
            //there is error on the api side
            [[NetworkManager sharedInstance] showApiErrorInViewController:self->delegate.tabBarController error:error];
            return;
        }
        
        /**
         * TO DO:
         *  - filter by focus areas
         *  - filter by tag
         *  - filter by module
         *  - filter by difficulty
         */
        NSMutableArray *availableExercises = [NSMutableArray new];
        for (ExercisesObj *exercise in exercises) {
            NSLog(@"Exercise name = %@",exercise.name);
            BOOL filteredModule = true;
            BOOL filteredTag = true;
            BOOL filteredFocusarea = true;
            BOOL filteredDifficulty = true;
            
            if([params[@"modules"] length] > 0){
                NSArray *modules = [[params[@"modules"] componentsSeparatedByString: @","] mutableCopy];
                if(![modules containsObject:exercise.moduleIdentifier]){
                    filteredModule = false;
                }
            }
            
            if([params[@"difficulty"] length] > 0 && ![params[@"difficulty"] isEqualToString:[exercise.difficulty lowercaseString]]){
                filteredDifficulty = false;
            }
            
            if([params[@"tags"] length] > 0){
                NSArray *tags = [[params[@"tags"] componentsSeparatedByString: @","] mutableCopy];
                for (NSDictionary *tag in exercise.tags) {
                    if([tags containsObject:tag[@"identifier"]]){
                        filteredTag = true;
                        break;
                    }else{
                        filteredTag = false;
                    }
                }
            }
            
            if([params[@"focusareas"] length] > 0){
                NSArray *focusareas = [[params[@"focusareas"] componentsSeparatedByString: @","] mutableCopy];
                for (NSDictionary *focusarea in exercise.focusAreas) {
                    if([focusareas containsObject:focusarea[@"identifier"]]){
                        filteredFocusarea = true;
                        break;
                    }else{
                        filteredFocusarea = false;
                    }
                }
            }
            
            if(filteredModule && filteredDifficulty && filteredTag && filteredFocusarea){
                [availableExercises addObject:exercise];
            }
        }
        
        self->availableExercises = availableExercises;
        [self getExercisesWithParams:params];
    }];
}

- (void)getExercisesWithParams:(NSDictionary *)params{
    /*if(!params[@"status"] || ![params[@"status"] isEqualToString:@"all"]){
        [skeletonView addSkeletonOnExerciseListCollectionView:_collectionView withCellSize:[self cellSize]];
        [_collectionView addSubview:skeletonView];
    }*/
    
    [[ModulesServices sharedInstance] getExercisesWithParameters:params withCompletion:^(NSError *error, int statusCode, NSArray *exercises) {
        
        if(statusCode == NoInternetErrorStatusCode || statusCode == SlowInternetErrorStatusCode) {
            [[NetworkManager sharedInstance] showConnectionErrorInViewController:self->delegate.tabBarController statusCode:statusCode];
            self.lastFilter = params;
            return;
        }
        
        [self->skeletonView remove];
        if (!error && exercises != nil) {
            NSMutableArray *allExercises = [NSMutableArray new];
            for (ExercisesObj *exercise in exercises) {
                
                //check if the exercise is included on the availableExercises. if so, it means unlocked
                NSPredicate *pred = [NSPredicate predicateWithFormat:@"identifier == %@", exercise.identifier];
                NSArray *unlockedExercises = [self->availableExercises filteredArrayUsingPredicate:pred];
                if(unlockedExercises.count > 0){
                    exercise.unlocked = 1;
                }else{
                    exercise.unlocked = 0;
                }
                [allExercises addObject:exercise];
            }
            
            self->exercisesArr = allExercises;
            [self checkBookmarks];
            return;
        }
        
        if(error){
            //there is error on the api side
            [[NetworkManager sharedInstance] showApiErrorInViewController:self->delegate.tabBarController error:error];
        }
    }];
}

- (void)checkBookmarks{
    bookmarkedExercises = [[ModulesModel sharedInstance] getAllBookmarkedExercises];
    [_collectionView reloadData];
}

#pragma mark - UISearchBarDelegate

- (void)searchBarSearchButtonClicked:(UISearchBar *)searchBar {
    [searchBar resignFirstResponder];
    
    NSString *searchStr = searchBar.text;
    self.lastFilter = @{
                        @"searchString": searchStr
                        };
    
    [self getAllExercisesWithParams:self.lastFilter];
    
    [_searchController dismissViewControllerAnimated:YES completion:nil];
    
}
- (void)presentSearchController:(UISearchController *)searchController{
    [[CustomNavigation sharedInstance] removeNavBarCustomBottomLineIn:self];
}

- (void)didPresentSearchController:(UISearchController *)searchController{
    //[[CustomNavigation sharedInstance] addOrRemoveBlurEffectAndLineForNavigationInViewController:self];
    [[CustomNavigation sharedInstance] removeNavBarCustomBottomLineIn:self];
}

- (void)willPresentSearchController:(UISearchController *)searchController{
    [[CustomNavigation sharedInstance] removeNavBarCustomBottomLineIn:self];
}

- (void)willDismissSearchController:(UISearchController *)searchController{
    [[CustomNavigation sharedInstance] addOrRemoveBlurEffectAndLineForNavigationInViewController:self];
}

- (void)didDismissSearchController:(UISearchController *)searchController{
    [[CustomNavigation sharedInstance] addOrRemoveBlurEffectAndLineForNavigationInViewController:self];
}

#pragma mark - UITextFieldDelegate

-(BOOL) textFieldShouldReturn: (UITextField *) textField {
    [textField resignFirstResponder];
    return YES;
}

#pragma mark - UICollectionview DataSource & Delegate
-(NSInteger)numberOfSectionsInCollectionView:(UICollectionView *)collectionView {
    return 1;
}

-(NSInteger)collectionView:(UICollectionView *)collectionView numberOfItemsInSection:(NSInteger)section{
    return [exercisesArr count];
}

-(UICollectionViewCell *)collectionView:(UICollectionView *)collectionView cellForItemAtIndexPath:(NSIndexPath *)indexPath {
    static NSString *identifier = @"ExercisesListCollectionViewCell";
    ExercisesListCollectionViewCell *cell = (ExercisesListCollectionViewCell *)[_collectionView dequeueReusableCellWithReuseIdentifier:identifier forIndexPath:indexPath];
    
    int index = 0;
    if(indexPath.row){
        index = (int)indexPath.row;
    }
    
    ExercisesObj *exercise = exercisesArr[index];
    
    NSString *exerciseName = [translationsModel getTranslationForKey:[NSString stringWithFormat:@"%@%@.name", Cf_domain_model_Exercise, exercise.identifier]];
    cell.exerciseNameLbl.text = exerciseName;
    
    if ([exercise.difficulty isEqualToString:@"easy"]) {
        cell.difficultyColorView.backgroundColor = [colors easyColor];
    }else if ([exercise.difficulty isEqualToString:@"medium"]) {
        cell.difficultyColorView.backgroundColor = [colors mediumColor];
    }else if ([exercise.difficulty isEqualToString:@"hard"]) {
        cell.difficultyColorView.backgroundColor = [colors hardColor];
    }
    
    [cell.imgView sd_setImageWithURL:[NSURL URLWithString:exercise.previewImage] placeholderImage:nil];
    
    if(!exercise.unlocked){
        [cell.heartBtn setImage:[UIImage imageNamed:@"locked"] forState:UIControlStateNormal];
        [cell.heartBtn removeTarget:self action:@selector(bookmark:) forControlEvents:UIControlEventTouchUpInside];
    }else{
        [cell.heartBtn.layer setValue:@"" forKey:@"bookmarkId"];
        [cell.heartBtn setImage:[UIImage imageNamed:@"heart_unselected"] forState:UIControlStateNormal];
        [cell.heartBtn addTarget:self action:@selector(bookmark:) forControlEvents:UIControlEventTouchUpInside];
        
        for (BookmarkedExercises *bookmarked in bookmarkedExercises){
            if ([exercise.identifier isEqual:bookmarked.exerciseId]) {
                [cell.heartBtn.layer setValue:bookmarked.bookmarkId forKey:@"bookmarkId"];
                [cell.heartBtn setImage:[UIImage imageNamed:@"heart_selected"] forState:UIControlStateNormal];
            }
        }
    }
    
    cell.heartBtn.tag = index;
    return cell;
}

- (CGSize)collectionView:(UICollectionView *)collectionView layout:(UICollectionViewLayout*)collectionViewLayout sizeForItemAtIndexPath:(NSIndexPath *)indexPath{
    return [self cellSize];
}

- (CGSize)cellSize{
    int cellW = CGRectGetWidth(_collectionView.frame) / 2.4;
    int cellH = cellW * 0.95;
    
    CGSize cellSize = CGSizeMake(cellW, cellH);
    return cellSize;
}

-(void)collectionView:(UICollectionView *)collectionView didSelectItemAtIndexPath:(NSIndexPath *)indexPath{
    [self.view endEditing:YES];
    
    ExercisesObj *exercise = exercisesArr[indexPath.row];
    
    if (!exercise.unlocked) {
        [[CustomAlertView sharedInstance] showAlertInViewController:delegate.tabBarController
                                                          withTitle:@"XS Infinity"
                                                            message:[translationsModel getTranslationForKey:@"info.finishpreviousexercise"]
                                                  cancelButtonTitle:[translationsModel getTranslationForKey:@"global.rateokay"]
                                                    doneButtonTitle:nil];
        [[CustomAlertView sharedInstance] setCancelBlock:^(id result) {
            NSLog(@"okay");
        }];
    }else{
        SingleExerciseViewController *vc = [[SingleExerciseViewController alloc] initWithNibName:@"SingleExerciseViewController" bundle:nil];
        vc.exercise = exercise;
        [self.navigationController pushViewController:vc animated: YES];
    }
}

#pragma mark - UIScrollView Delegate
- (void)scrollViewDidScroll:(UIScrollView *)scrollView{
    [self.view layoutIfNeeded];
    
    float scrollOffset = _collectionView.contentOffset.y;
    float maxOffSet = _collectionView.contentSize.height - CGRectGetHeight(_collectionView.frame);
    
    if (scrollOffset > 0 && (scrollOffset >= _lastContentOffset || maxOffSet <= scrollOffset)){//scroll down
        [animations setTabBar:delegate.tabBarController.tabBar fromViewController:self visible:NO animated:YES];
    }
    else{//scroll up
        [animations setTabBar:delegate.tabBarController.tabBar fromViewController:self visible:YES animated:YES];
    }
    _lastContentOffset = scrollOffset;
    
    [[CustomNavigation sharedInstance] addOrRemoveBlurEffectAndLineForNavigationInViewController:self];
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
        
        if (statusCode == 204) {
            [[ModulesModel sharedInstance] removeBookmarked:bookmarkId];
            [btn.layer setValue:@"" forKey:@"bookmarkId"];
            [btn setImage:[UIImage imageNamed:@"heart_unselected"] forState:UIControlStateNormal];
            return;
        }
        
        if(error){
            //there is error on the api side
            [[NetworkManager sharedInstance] showApiErrorInViewController:self->delegate.tabBarController error:error];
        }
    }];
}

- (void)addToBookmark:(UIButton *)btn{
    ExercisesObj *exercise = exercisesArr[btn.tag];
    
    [DejalBezelActivityView activityViewForView:delegate.tabBarController.view];
    [[ModulesServices sharedInstance] createBookMarkForExercise:exercise.identifier withCompletion:^(NSError *error, int statusCode) {
        
        
        if (statusCode == 201) {
            
            [[ModulesServices sharedInstance] getBookmarkedExercisesWithCompletion:^(NSError *error, BOOL successful) {
                NSLog(@"Done updating bookmark list");
                [DejalBezelActivityView removeViewAnimated:YES];
                
                [btn setImage:[UIImage imageNamed:@"heart_selected"] forState:UIControlStateNormal];
                [[Animations sharedAnimations] zoomSpringAnimationForView:btn];
                
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
            [DejalBezelActivityView removeViewAnimated:YES];
            //there is error on the api side
            [[NetworkManager sharedInstance] showApiErrorInViewController:self->delegate.tabBarController error:error];
        }
    }];
}

- (IBAction)filter:(id)sender{
    [self.view endEditing:YES];
    
    ExercisesFilterViewController *vc = [[ExercisesFilterViewController alloc] initWithNibName:@"ExercisesFilterViewController" bundle:nil];
    vc.params = self.lastFilter.mutableCopy;
    vc.view.backgroundColor = [UIColor clearColor];
    vc.modalPresentationStyle = UIModalPresentationOverCurrentContext;
    vc.dismissDelegate = self;
    [delegate.tabBarController presentViewController:vc animated:NO completion:nil];
}

#pragma ExercisesFilterViewControllerDelegate

- (void)filterExercisesWithFilters:(NSDictionary *)filters{
    if ([filters count] > 0){
        self.lastFilter = filters;
        _searchController.searchBar.text = @"";
        
        //if(filters[@"status"] && [filters[@"status"] isEqualToString:@"all"]){
            [self getAllExercisesWithParams:self.lastFilter];
        //}else{
            //[self getExercisesWithParams:self.lastFilter];
        //}
    }
}

@end
