//
//  FaqViewController.m
//  XSInfinity
//
//  Created by Joseph Marvin Magdadaro on 8/9/18.
//  Copyright © 2018 Jerk Magz. All rights reserved.
//

#import "FaqViewController.h"
#import "DejalActivityView.h"
#import "NetworkManager.h"
#import "Helper.h"
#import "Fonts.h"
#import "Colors.h"
#import "TranslationsModel.h"
#import "Animations.h"
#import "AppDelegate.h"
#import "CustomNavigation.h"
#import "FaqServices.h"
#import "FaqDetailsViewController.h"
#import "SkeletonView.h"
#import "FaqModel.h"
#import "FaqCategory.h"
#import "Faq.h"
#import "ToastView.h"

@interface FaqViewController ()<UITableViewDelegate, UITableViewDataSource, NetworkManagerDelegate, ToastViewDelegate>{
    Helper *helper;
    Fonts *fonts;
    Colors *colors;
    TranslationsModel *translationsModel;
    AppDelegate *delegate;
    SkeletonView *skeletonView;
    BOOL didLayoutReloaded;
    NSArray *faqCategories;
    NSMutableArray *allFaqsArr;
    NSArray *filteredAllFaqsArr;
    
    BOOL didRequestFromRemote;
}

@property (weak, nonatomic) IBOutlet UITextField *searchTxtFld;
@property (weak, nonatomic) IBOutlet UICollectionView *collectionView;
@property (retain, nonatomic) UITableView *tableView;

@end

@implementation FaqViewController

- (void)viewWillAppear:(BOOL)animated{
    [super viewWillAppear:YES];
    self.navigationController.navigationBar.hidden = NO;
}

- (void)viewWillDisappear:(BOOL)animated{
    [super viewWillDisappear:YES];
    self.navigationController.navigationBar.hidden = YES;
}

- (void)viewDidLoad {
    [super viewDidLoad];
    self.navigationController.navigationBar.hidden = NO;
    [self.navigationController.navigationBar setBackgroundImage:[UIImage new]
                                                  forBarMetrics:UIBarMetricsDefault];
    self.navigationController.navigationBar.shadowImage = [UIImage new];
    self.navigationItem.title = [[TranslationsModel sharedInstance] getTranslationForKey:@"faq.title"];
    self.navigationItem.largeTitleDisplayMode = UINavigationItemLargeTitleDisplayModeNever;
    
    fonts = [Fonts sharedFonts];
    colors = [Colors sharedColors];
    helper = [Helper sharedHelper];
    translationsModel = [TranslationsModel sharedInstance];
    delegate = (AppDelegate *)[[UIApplication sharedApplication] delegate];
    
    allFaqsArr = [NSMutableArray new];
    
    //Register Collection
    [_collectionView registerClass:[UICollectionViewCell class] forCellWithReuseIdentifier:@"CollectionViewCellIdentifier"];
    
    skeletonView = [[SkeletonView alloc] initWithFrame:self.view.frame];
    skeletonView.layer.cornerRadius = 15;
    
    UITapGestureRecognizer *tap = [[UITapGestureRecognizer alloc] initWithTarget:self action:@selector(dismissKeyboard)];
    tap.cancelsTouchesInView = NO;
    [self.view addGestureRecognizer:tap];
}

- (void)viewDidAppear:(BOOL)animated{
    [super viewDidAppear:YES];
    
    [[ToastView sharedInstance] setDelegate:self];
    [[NetworkManager sharedInstance] setDelegate:self];
    [[NetworkManager sharedInstance] connectivityMonitoring];
    
    if([[NetworkManager sharedInstance] isConnectionOffline]){
        faqCategories = [[FaqModel sharedInstance] getAllFaqCategories];
        [_collectionView reloadData];
        return;
    }
    
    if(!didRequestFromRemote){
        [skeletonView addSkeletonOnFaqCollectionViewWithBounds:_collectionView.frame withCellSize:[self cellSize]];
        [self.view addSubview:skeletonView];
        [self getFaqs];
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
    if([[NetworkManager sharedInstance] isConnectionOffline]){
        [[NetworkManager sharedInstance] showConnectionErrorInViewController:delegate.tabBarController];
        return;
    }
    [skeletonView addSkeletonOnFaqCollectionViewWithBounds:_collectionView.frame withCellSize:[self cellSize]];
    [self.view addSubview:skeletonView];
    [self getFaqs];
}

-(void)viewDidLayoutSubviews{
    [super viewDidLayoutSubviews];
    [_collectionView layoutIfNeeded];
    
    if( !didLayoutReloaded ){
        [self setupUserInterface];
        
        didLayoutReloaded = YES;
    }
}

- (void)setupUserInterface{
    [[CustomNavigation sharedInstance] removeBlurEffectIn:self];
    [[CustomNavigation sharedInstance] addNavBarCustomBottomLineIn:self];
    
    [[Animations sharedAnimations] setTabBar:delegate.tabBarController.tabBar fromViewController:self visible:NO animated:NO];
    
    _searchTxtFld.font = [fonts normalFont];
    _searchTxtFld.placeholder = [translationsModel getTranslationForKey:@"faq.searchbar_title"];
    
    UIImageView *imageView = [[UIImageView alloc] initWithFrame:CGRectMake(30, 5, 30.0, 30.0)];
    imageView.image = [UIImage imageNamed:@"search_icon"];
    imageView.contentMode = UIViewContentModeScaleAspectFit;
    
    _searchTxtFld.leftView = imageView;
    _searchTxtFld.leftViewMode = UITextFieldViewModeUnlessEditing;
}

- (void)getFaqs{
    [[FaqServices sharedInstance] getFaqCategoriesWithFaqsWithCompletion:^(NSError *error, int statusCode) {
        if(statusCode == NoInternetErrorStatusCode || statusCode == SlowInternetErrorStatusCode) {
            [[NetworkManager sharedInstance] showConnectionErrorInViewController:self->delegate.tabBarController statusCode:statusCode];
            return;
        }
        
        [self->skeletonView remove];
        self->didRequestFromRemote = YES;
        
        if (!error && statusCode == 200) {
            self->faqCategories = [[FaqModel sharedInstance] getAllFaqCategories];
            [self->_collectionView reloadData];
            return;
        }
        
        if(error){
            //there is error on the api side
            [[NetworkManager sharedInstance] showApiErrorInViewController:self->delegate.tabBarController error:error];
        }
    }];
    
}

#pragma mark - Dismiss Keyboard
-(void)dismissKeyboard{
    [self.view endEditing:YES];
}

#pragma mark - UITextFieldDelegate

-(BOOL) textFieldShouldReturn: (UITextField *) textField {
    [textField resignFirstResponder];
    return YES;
}

- (IBAction)textFieldDidChange:(UITextField *)textField {
    NSLog(@"text changed: %@", textField.text);
    
    filteredAllFaqsArr = [[FaqModel sharedInstance] searchFaqsByTitle:textField.text];
    
    [_collectionView reloadData];
}

#pragma mark - UICollectionview DataSource & Delegate
-(NSInteger)numberOfSectionsInCollectionView:(UICollectionView *)collectionView {
    return 1;
}

-(NSInteger)collectionView:(UICollectionView *)collectionView numberOfItemsInSection:(NSInteger)section{
    /*
     * If searching... Use filtered all faqs list
     */
    if ([_searchTxtFld.text length] > 0){
        return 1;
    }else{
        return [faqCategories count];
    }
}

-(UICollectionViewCell *)collectionView:(UICollectionView *)collectionView cellForItemAtIndexPath:(NSIndexPath *)indexPath {
    
    UICollectionViewCell *cell = [_collectionView dequeueReusableCellWithReuseIdentifier:@"CollectionViewCellIdentifier" forIndexPath:indexPath];
    
    cell.backgroundColor=[UIColor clearColor];
    cell.contentView.backgroundColor = [UIColor clearColor];
    
    for (id child in [cell.contentView subviews]){
        [child removeFromSuperview];
    }
    
    [cell.contentView layoutIfNeeded];
    [helper addDropShadowIn:cell.contentView withColor:[UIColor darkGrayColor] andSetCornerRadiusTo:5.0f];
    
    UIView *view = [[UIView alloc] initWithFrame:cell.contentView.bounds];
    view.clipsToBounds = YES;
    view.layer.cornerRadius = 5.0f;
    [cell.contentView addSubview:view];
    
    int titleViewH = 66;
    
    UIImageView *titleBgView = [[UIImageView alloc] initWithFrame:CGRectMake(0, 0, CGRectGetWidth(cell.contentView.frame), titleViewH)];
//    titleBgView.image = [UIImage imageNamed:@""];
    titleBgView.backgroundColor = [colors orangeColor];
    [view addSubview:titleBgView];
    
    UILabel *titleLbl = [[UILabel alloc] initWithFrame:CGRectMake(16, 0, CGRectGetWidth(cell.contentView.frame)-16, titleViewH)];
    titleLbl.font = [fonts headerFont];
    titleLbl.textColor = [UIColor whiteColor];
    
    /*
     * If searching... Use Search as category title
     */
    if ([_searchTxtFld.text length] > 0){
        titleLbl.text = @"";
    }else{
        FaqCategory *faqCategory = faqCategories[indexPath.row];
        NSString *faqCategoryTitle = [translationsModel getTranslationForKey:[NSString stringWithFormat:@"%@%@.title", Cf_domain_model_FaqCategory, faqCategory.identifier]];
        titleLbl.text = faqCategoryTitle;
    }
    [view addSubview:titleLbl];
    
    _tableView = [[UITableView alloc] initWithFrame:CGRectMake(0, titleViewH, CGRectGetWidth(cell.contentView.frame), CGRectGetHeight(cell.contentView.frame)-titleViewH)];
    _tableView.delegate = self;
    _tableView.dataSource = self;
    _tableView.contentInset = UIEdgeInsetsMake(10, 0, 30, 0);
    _tableView.separatorColor = [UIColor clearColor];
    _tableView.tag = indexPath.row;
    [view addSubview:_tableView];
    
    int gradientH = 40;
    UIView *gradientView = [[UIView alloc] initWithFrame:CGRectMake(0, CGRectGetHeight(view.frame)-gradientH, CGRectGetWidth(view.frame), gradientH)];
    gradientView.backgroundColor = [UIColor clearColor];
    
    CAGradientLayer *gradient = [CAGradientLayer layer];
    gradient.frame = gradientView.bounds;
    gradient.colors = @[(id)[[UIColor lightGrayColor] colorWithAlphaComponent:0.1f].CGColor, (id)[[UIColor lightGrayColor] colorWithAlphaComponent:0.3f].CGColor, (id)[[UIColor lightGrayColor] colorWithAlphaComponent:0.5f].CGColor];
    
    [gradientView.layer insertSublayer:gradient atIndex:0];
    [view addSubview:gradientView];
    
    return cell;
}

- (CGSize)collectionView:(UICollectionView *)collectionView layout:(UICollectionViewLayout*)collectionViewLayout sizeForItemAtIndexPath:(NSIndexPath *)indexPath{
    
    return [self cellSize];
}

- (CGSize)cellSize{
    CGSize cellSize = CGSizeMake(CGRectGetWidth(_collectionView.frame)-60, CGRectGetHeight(_collectionView.frame)-50);
    return cellSize;
}

-(void)collectionView:(UICollectionView *)collectionView didSelectItemAtIndexPath:(NSIndexPath *)indexPath{
    [self.view endEditing:YES];
}

- (BOOL)collectionView:(UICollectionView *)collectionView shouldHighlightItemAtIndexPath:(NSIndexPath *)indexPath{
    return NO;
}

#pragma UITableViewDelegate and UITableViewDataSource

- (CGFloat)tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath{
    return 60;
}

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section{
    
    /*
     * If searching... Use filtered all faqs list
     */
    if ([_searchTxtFld.text length] > 0){
        return [filteredAllFaqsArr count];
    }else{
        FaqCategory *category = faqCategories[tableView.tag];
        NSArray *faqs = [[FaqModel sharedInstance] getAllFaqsByCategory:category.identifier];
        
        return [faqs count];
    }
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath{
    
    static NSString *simpleTableIdentifier = @"SimpleTableItem";
    
    UITableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:simpleTableIdentifier];
    
    if (cell == nil) {
        cell = [[UITableViewCell alloc] initWithStyle:UITableViewCellStyleDefault reuseIdentifier:simpleTableIdentifier];
    }
    cell.backgroundColor = [UIColor clearColor];
    cell.contentView.backgroundColor = [UIColor clearColor];
    
    for (id child in [cell.contentView subviews]){
        [child removeFromSuperview];
    }
    
    Faq *faq = [Faq new];
    
    /*
     * If searching... Use filtered all faqs list
     */
    if ([_searchTxtFld.text length] > 0){
        faq = filteredAllFaqsArr[indexPath.row];
    }else{
        
        FaqCategory *category = faqCategories[tableView.tag];
        NSArray *faqs = [[FaqModel sharedInstance] getAllFaqsByCategory:category.identifier];
        
        faq = faqs[indexPath.row];
    }
    
    int h = 60;
    
    NSString *faqTitle = [translationsModel getTranslationForKey:[NSString stringWithFormat:@"%@%@.title", Cf_domain_model_Faq, faq.identifier]];
    
    UILabel *questionLbl = [[UILabel alloc] initWithFrame:CGRectMake(30, (CGRectGetHeight(cell.contentView.frame)/2)-(h/2), CGRectGetWidth(_tableView.frame)-60, h)];
    questionLbl.numberOfLines = 0;
    questionLbl.adjustsFontSizeToFitWidth = YES;
    questionLbl.attributedText = [helper formatText:faqTitle];
    [cell.contentView addSubview:questionLbl];
    
    cell.selectionStyle = UITableViewCellSelectionStyleNone;
    
    return cell;
    
}

- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath{
    [self.view endEditing:YES];
    
    Faq *faq = [Faq new];
    
    /*
     * If searching... Use filtered all faqs list
     */
    if ([_searchTxtFld.text length] > 0){
        faq = filteredAllFaqsArr[indexPath.row];
    }else{
        
        FaqCategory *category = faqCategories[tableView.tag];
        NSArray *faqs = [[FaqModel sharedInstance] getAllFaqsByCategory:category.identifier];
        
        faq = faqs[indexPath.row];
    }
    
    FaqDetailsViewController *vc = [[FaqDetailsViewController alloc] initWithNibName:@"FaqDetailsViewController" bundle:nil];
    vc.faq = faq;
    [self.navigationController pushViewController:vc animated:YES];
}

- (IBAction)back:(id)sender {
    [self.navigationController popViewControllerAnimated:YES];
}

@end
