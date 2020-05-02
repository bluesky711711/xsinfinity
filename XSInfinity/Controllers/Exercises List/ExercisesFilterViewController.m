//
//  ExercisesFilterViewController.m
//  XSInfinity
//
//  Created by Joseph Marvin Magdadaro on 6/4/18.
//  Copyright © 2018 Joseph Marvin Magdadaro. All rights reserved.
//

#import "ExercisesFilterViewController.h"
#import "DejalActivityView.h"
#import "Animations.h"
#import "Colors.h"
#import "Fonts.h"
#import "TranslationsModel.h"
#import "CustomAlertView.h"
#import "ModulesObj.h"
#import "ModulesServices.h"
#import "SkeletonView.h"
#import "ModulesModel.h"
#import "Modules.h"
#import "FocusArea.h"
#import "Tags.h"
#import "NetworkManager.h"
#import "ToastView.h"
#import "AppDelegate.h"

#define MODULES [NSArray arrayWithObjects:@"Module 1", @"Module 2", @"Module 3", @"Module 4", @"Module 5", nil]

@interface ExercisesFilterViewController ()<NetworkManagerDelegate, ToastViewDelegate>{
    Animations *animations;
    Colors *colors;
    Fonts *fonts;
    TranslationsModel *translationsModel;
    SkeletonView *skeletonView;
    AppDelegate *delegate;
    BOOL didLayoutReloaded;
    NSArray *availableModules;
    NSString *status;
    NSMutableArray *selectedModulesArr;
    NSMutableArray *selectedFocusAreaArr, *selectedTagsArr;
    NSString *selectedDifficulty;
    NSMutableDictionary *selectedRatesDict;
    NSArray *focusAreaArr, *tagsArr;
}

@property (nonatomic, strong) IBOutletCollection(UIButton) NSArray *exercisesButtons;
@property (nonatomic, strong) IBOutletCollection(UIButton) NSArray *difficultyButtons;
@property (nonatomic, strong) IBOutletCollection(UIButton) NSArray *rateButtons;

@property (weak, nonatomic) IBOutlet UIView *mainView;
@property (weak, nonatomic) IBOutlet NSLayoutConstraint *contentViewTopConstraint;

@property (weak, nonatomic) IBOutlet UIView *contentView;
@property (weak, nonatomic) IBOutlet UIView *scrollContentView;
@property (weak, nonatomic) IBOutlet UILabel *titleLbl;
@property (weak, nonatomic) IBOutlet UIButton *xBtn;

@property (weak, nonatomic) IBOutlet UILabel *showExercisesLbl;
@property (weak, nonatomic) IBOutlet UILabel *activatedLbl;
@property (weak, nonatomic) IBOutlet UIButton *activatedBtn;
@property (weak, nonatomic) IBOutlet UILabel *allLbl;
@property (weak, nonatomic) IBOutlet UIButton *allBtn;

@property (weak, nonatomic) IBOutlet UILabel *showModulesLbl;
@property (weak, nonatomic) IBOutlet UICollectionView *modulesCollectionView;

@property (weak, nonatomic) IBOutlet UILabel *showKindsLbl;
@property (weak, nonatomic) IBOutlet UICollectionView *kindsCollectionView;

@property (weak, nonatomic) IBOutlet UILabel *showTagsLbl;
@property (weak, nonatomic) IBOutlet UICollectionView *tagsCollectionView;

@property (weak, nonatomic) IBOutlet UILabel *showDifficultyLbl;
@property (weak, nonatomic) IBOutlet UIButton *easyBtn;
@property (weak, nonatomic) IBOutlet UIButton *mediumBtn;
@property (weak, nonatomic) IBOutlet UIButton *hardBtn;

@property (weak, nonatomic) IBOutlet UILabel *showOnlyLbl;
@property (weak, nonatomic) IBOutlet UIButton *top10Btn;
@property (weak, nonatomic) IBOutlet UILabel *top10Lbl;
@property (weak, nonatomic) IBOutlet UIButton *neverTriedBtn;
@property (weak, nonatomic) IBOutlet UILabel *neveTriedLbl;
@property (weak, nonatomic) IBOutlet UIButton *likedBtn;
@property (weak, nonatomic) IBOutlet UILabel *likedLbl;

@property (weak, nonatomic) IBOutlet UIButton *filterBtn;
@property (weak, nonatomic) IBOutlet UIButton *resetBtn;

@end

@implementation ExercisesFilterViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    self.navigationController.navigationBar.hidden = YES;
    
    animations = [Animations sharedAnimations];
    colors = [Colors sharedColors];
    fonts = [Fonts sharedFonts];
    translationsModel = [TranslationsModel sharedInstance];
    delegate = (AppDelegate *)[[UIApplication sharedApplication] delegate];
    
    selectedModulesArr = [NSMutableArray new];
    selectedFocusAreaArr = [NSMutableArray new];
    selectedTagsArr = [NSMutableArray new];
    selectedRatesDict = [NSMutableDictionary new];
    
    //Register Collection
    [_kindsCollectionView registerClass:[UICollectionViewCell class] forCellWithReuseIdentifier:@"KindsCollectionViewCellIdentifier"];
    [_tagsCollectionView registerClass:[UICollectionViewCell class] forCellWithReuseIdentifier:@"TagsCollectionViewCellIdentifier"];
    [_modulesCollectionView registerClass:[UICollectionViewCell class] forCellWithReuseIdentifier:@"ModulesCollectionViewCellIdentifier"];
    
    skeletonView = [[SkeletonView alloc] initWithFrame:_scrollContentView.frame];
    skeletonView.backgroundColor = [UIColor whiteColor];
    skeletonView.layer.cornerRadius = 15;
    [_scrollContentView addSubview:skeletonView];
    
    focusAreaArr = [[ModulesModel sharedInstance] getFocusArea];
    tagsArr = [[ModulesModel sharedInstance] getTags];
}

- (void)viewDidAppear:(BOOL)animated{
    [super viewDidAppear:YES];
    
    [[ToastView sharedInstance] setDelegate:self];
    [[NetworkManager sharedInstance] setDelegate:self];
    [[NetworkManager sharedInstance] connectivityMonitoring];
    
    availableModules = [[ModulesModel sharedInstance] getAllModules];
    if ([availableModules count] > 0) {
        [self setModules];
    }
    
    if ([availableModules count] == 0) {
        [self addSkeletonView];
    }else {
        [skeletonView remove];
    }
    
    [self getAvailableModules];
    [self autofillFilters];
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
    [self getAvailableModules];
}

-(void)viewDidLayoutSubviews{
    [super viewDidLayoutSubviews];
    [_mainView layoutIfNeeded];
    
    if( !didLayoutReloaded ){
        [self setupUserInterface];
        
        [_kindsCollectionView reloadData];
        
        didLayoutReloaded = YES;
    }
}

- (void)setupUserInterface{
    _contentViewTopConstraint.constant = 1000;
    [_mainView layoutIfNeeded];
    [animations animateOverlayViewIn:_mainView byTopConstraint:_contentViewTopConstraint];
    
    _titleLbl.font = [fonts headerFontLight];
    _showExercisesLbl.font = [fonts normalFontBold];
    _activatedLbl.font = [fonts normalFont];
    _allLbl.font = [fonts normalFont];
    _showModulesLbl.font = [fonts normalFontBold];
    _showKindsLbl.font = [fonts normalFontBold];
    _showTagsLbl.font = [fonts normalFontBold];
    _showDifficultyLbl.font = [fonts normalFontBold];
    _showOnlyLbl.font = [fonts normalFontBold];
    _top10Lbl.font = [fonts normalFont];
    _neveTriedLbl.font = [fonts normalFont];
    _likedLbl.font = [fonts normalFont];
    _filterBtn.titleLabel.font = [fonts normalFontBold];
    [_filterBtn setBackgroundColor:[colors blueColor]];
    
    _titleLbl.text = [translationsModel getTranslationForKey:@"exfilter.title"];
    _showExercisesLbl.text = [translationsModel getTranslationForKey:@"exfilter.onlyshowexercise"];
    _activatedLbl.text = [translationsModel getTranslationForKey:@"exfilter.activated"];
    _allLbl.text = [translationsModel getTranslationForKey:@"exfilter.all"];
    _showModulesLbl.text = [translationsModel getTranslationForKey:@"exfilter.onlyshowmodules"];
    _showKindsLbl.text = [translationsModel getTranslationForKey:@"exfilter.onlyshowkind"];
    _showDifficultyLbl.text = [translationsModel getTranslationForKey:@"exfilter.onlyshowdiff"];
    _showOnlyLbl.text = [translationsModel getTranslationForKey:@"exfilter.onlyshowcheckboxes"];
    _showTagsLbl.text = [translationsModel getTranslationForKey:@"exfilter.onlyshowetag"];
    _top10Lbl.text = [translationsModel getTranslationForKey:@"exfilter.mytop10"];
    _neveTriedLbl.text = [translationsModel getTranslationForKey:@"exfilter.nevertried"];
    _likedLbl.text = [translationsModel getTranslationForKey:@"exfilter.liked"];
    [_easyBtn setTitle:[translationsModel getTranslationForKey:@"global.difficultyeasy"] forState:UIControlStateNormal];
    [_mediumBtn setTitle:[translationsModel getTranslationForKey:@"global.difficultymedium"] forState:UIControlStateNormal];
    [_hardBtn setTitle:[translationsModel getTranslationForKey:@"global.difficultyhard"] forState:UIControlStateNormal];
    [_filterBtn setTitle:[translationsModel getTranslationForKey:@"exfilter.applyfilterbutton"] forState:UIControlStateNormal];
    
    NSMutableParagraphStyle *style = [[NSParagraphStyle defaultParagraphStyle] mutableCopy];
    [style setAlignment:NSTextAlignmentCenter];
    [style setLineBreakMode:NSLineBreakByWordWrapping];
    
    NSDictionary *dict1 = @{NSUnderlineStyleAttributeName:@(NSUnderlineStyleSingle),
                            NSFontAttributeName:[fonts normalFont],
                            NSForegroundColorAttributeName:[UIColor blackColor],
                            NSParagraphStyleAttributeName:style};
    
    NSMutableAttributedString *resetAttr = [[NSMutableAttributedString alloc] init];
    [resetAttr appendAttributedString:[[NSAttributedString alloc] initWithString:[translationsModel getTranslationForKey:@"exfilter.reset_button"] attributes:dict1]];
    [_resetBtn setAttributedTitle:resetAttr forState:UIControlStateNormal];
    
    [self selectFilterExercises:_activatedBtn];
    
    for(UIButton *btn in _difficultyButtons){
        if (btn == _easyBtn) {
            [btn.layer setBorderColor:[[colors easyColor] CGColor]];
        }else if (btn == _mediumBtn){
            [btn.layer setBorderColor:[[colors mediumColor] CGColor]];
        }else if (btn == _hardBtn){
            [btn.layer setBorderColor:[[colors hardColor] CGColor]];
        }
        btn.backgroundColor = [UIColor clearColor];
        [btn setTitleColor:[UIColor blackColor] forState:UIControlStateNormal];
        [btn.layer setBorderWidth:1.0];
        btn.layer.cornerRadius = 5;
        btn.clipsToBounds = YES;
    }
    
    for(UIButton *btn in _rateButtons){
        float cornerRadius = CGRectGetWidth(btn.frame)/4;
        btn.layer.cornerRadius = cornerRadius;
        btn.backgroundColor = [UIColor clearColor];
        [btn.layer setBorderWidth:1.0];
        [btn.layer setBorderColor:[[UIColor grayColor] CGColor]];
        btn.clipsToBounds = YES;
    }
}

- (void)autofillFilters{
    if(self.params.count > 0){
        if(self.params[@"status"]){
            status = self.params[@"status"];
            
            int statTag = 0;
            if([status isEqualToString:@"available"]){
                statTag = 1;
            }else{
                statTag = 0;
            }
            
            for (UIButton *btn in _exercisesButtons){
                float cornerRadius = CGRectGetWidth(btn.frame)/4;
                if (btn.tag == statTag) {
                    btn.backgroundColor = [colors orangeColor];
                    [btn.layer setBorderWidth:0];
                    btn.layer.cornerRadius = cornerRadius;
                    btn.clipsToBounds = YES;
                }else{
                    btn.backgroundColor = [UIColor clearColor];
                    [btn.layer setBorderWidth:1.0];
                    [btn.layer setBorderColor:[[UIColor grayColor] CGColor]];
                    btn.layer.cornerRadius = cornerRadius;
                    btn.clipsToBounds = YES;
                }
            }
        }
        
        if(self.params[@"modules"]){
            selectedModulesArr = [[self.params[@"modules"] componentsSeparatedByString: @","] mutableCopy];
        }
        
        if(self.params[@"focusareas"]){
            selectedFocusAreaArr = [[self.params[@"focusareas"] componentsSeparatedByString: @","] mutableCopy];
        }
        
        if(self.params[@"tags"]){
            selectedTagsArr = [[self.params[@"tags"] componentsSeparatedByString:@","] mutableCopy];
        }
        
        if (self.params[@"difficulty"]){
            NSString *difficulty = self.params[@"difficulty"];
            selectedDifficulty = difficulty;
            
            for(UIButton *btn in _difficultyButtons){
                if([difficulty isEqualToString:@"easy"] && btn == _easyBtn){
                    btn.backgroundColor = [colors easyColor];
                    [btn setTitleColor:[UIColor whiteColor] forState:UIControlStateNormal];
                }else if([difficulty isEqualToString:@"medium"] && btn == _mediumBtn){
                    btn.backgroundColor = [colors mediumColor];
                    [btn setTitleColor:[UIColor whiteColor] forState:UIControlStateNormal];
                }else if([difficulty isEqualToString:@"hard"] && btn == _hardBtn){
                    btn.backgroundColor = [colors hardColor];
                    [btn setTitleColor:[UIColor whiteColor] forState:UIControlStateNormal];
                }else{
                    [btn setTitleColor:[UIColor blackColor] forState:UIControlStateNormal];
                }
                
            }
        }
        
        if (self.params[@"top10"]) {
            [selectedRatesDict setObject:self.params[@"top10"] forKey:@"top10"];
            
            for(UIButton *btn in _rateButtons){
                if (btn.tag == 0) {
                    float cornerRadius = CGRectGetWidth(btn.frame)/4;
                    btn.layer.cornerRadius = cornerRadius;
                    btn.clipsToBounds = YES;
                    btn.backgroundColor = [colors orangeColor];
                    [btn.layer setBorderWidth:0];
                    [btn.layer setBorderColor:[[UIColor grayColor] CGColor]];
                    break;
                }
            }
        }
        
        if (self.params[@"neverDoneBefore"]) {
            [selectedRatesDict setObject:self.params[@"neverDoneBefore"] forKey:@"neverDoneBefore"];
            
            for(UIButton *btn in _rateButtons){
                if (btn.tag == 1) {
                    float cornerRadius = CGRectGetWidth(btn.frame)/4;
                    btn.layer.cornerRadius = cornerRadius;
                    btn.clipsToBounds = YES;
                    btn.backgroundColor = [colors orangeColor];
                    [btn.layer setBorderWidth:0];
                    [btn.layer setBorderColor:[[UIColor grayColor] CGColor]];
                    break;
                }
            }
        }
        
        if (self.params[@"liked"]) {
            [selectedRatesDict setObject:self.params[@"liked"] forKey:@"liked"];
            
            for(UIButton *btn in _rateButtons){
                if (btn.tag == 2) {
                    float cornerRadius = CGRectGetWidth(btn.frame)/4;
                    btn.layer.cornerRadius = cornerRadius;
                    btn.clipsToBounds = YES;
                    btn.backgroundColor = [colors orangeColor];
                    [btn.layer setBorderWidth:0];
                    [btn.layer setBorderColor:[[UIColor grayColor] CGColor]];
                    break;
                }
            }
        }
        
        [_modulesCollectionView reloadData];
        [_kindsCollectionView reloadData];
        [_tagsCollectionView reloadData];
    }
}

- (void)getAvailableModules{
    [[ModulesServices sharedInstance] getAllModulesWithExercisesWithCompletion:^(NSError *error, int statusCode) {

        if(statusCode == NoInternetErrorStatusCode || statusCode == SlowInternetErrorStatusCode) {
            [[NetworkManager sharedInstance] showConnectionErrorInViewController:self statusCode:statusCode];
            return;
        }
        
        [self->skeletonView remove];
        
        if (statusCode == 200) {
            self->availableModules = [[ModulesModel sharedInstance] getAllModules];
            [self setModules];
            return;
        }
        
        if(error){
            //there is error on the api side
            [[NetworkManager sharedInstance] showApiErrorInViewController:self error:error];
        }
    }];
}

- (void)setModules{
    
    NSPredicate *pred = [NSPredicate predicateWithFormat:@"isModuleUnlocked == 1"];
    
    self->availableModules = [[self->availableModules filteredArrayUsingPredicate:pred] mutableCopy];
    
    if ([self->availableModules count] > 1) {
        [self.modulesCollectionView reloadData];
    }else{
        
        if ([self->availableModules count] == 1) {
            Modules *module = self->availableModules[0];
            [self->selectedModulesArr addObject:module.identifier];
        }
    }
}

#pragma mark - UICollectionview DataSource & Delegate
-(NSInteger)numberOfSectionsInCollectionView:(UICollectionView *)collectionView {
    return 1;
}

-(NSInteger)collectionView:(UICollectionView *)collectionView numberOfItemsInSection:(NSInteger)section{
    if (collectionView == _modulesCollectionView) {
        return [availableModules count];
    }else if(collectionView == _kindsCollectionView){
        return [focusAreaArr count];
    }else{
        return [tagsArr count];
    }
}

-(UICollectionViewCell *)collectionView:(UICollectionView *)collectionView cellForItemAtIndexPath:(NSIndexPath *)indexPath {
    
    if (collectionView == _modulesCollectionView) {
        UICollectionViewCell *cell = [_modulesCollectionView dequeueReusableCellWithReuseIdentifier:@"ModulesCollectionViewCellIdentifier" forIndexPath:indexPath];
        
        cell.backgroundColor = [UIColor clearColor];
        cell.contentView.backgroundColor = [UIColor clearColor];
        
        for (id child in [cell.contentView subviews]){
            [child removeFromSuperview];
        }
        
        Modules *module = availableModules[indexPath.row];
        
        NSString *moduleName = [translationsModel getTranslationForKey:[NSString stringWithFormat:@"%@%@.name", Cf_domain_model_Module, module.identifier]];
        
        UIButton *btn = [[UIButton alloc] initWithFrame:CGRectMake(0, 10, CGRectGetWidth(cell.frame), 35)];
        [btn setTitle:moduleName forState:UIControlStateNormal];
        [btn setTitleColor:[UIColor blackColor] forState:UIControlStateNormal];
        [btn.layer setBorderColor:[[UIColor grayColor] CGColor]];
        [btn.layer setBorderWidth:1.0];
        [btn addTarget:self action:@selector(selectModules:) forControlEvents:UIControlEventTouchUpInside];
        btn.backgroundColor = [UIColor clearColor];
        btn.titleLabel.font = [fonts normalFont];
        btn.titleLabel.adjustsFontSizeToFitWidth = TRUE;
        btn.layer.cornerRadius = 5;
        btn.clipsToBounds = YES;
        btn.tag = indexPath.row;
        [btn setTitleColor:[UIColor blackColor] forState:UIControlStateNormal];
        [btn.layer setBorderColor:[[UIColor grayColor] CGColor]];
        btn.backgroundColor = [UIColor clearColor];
        [btn.layer setBorderWidth:1.0];
        
        for (NSString *moduleId in selectedModulesArr) {
            
            if ([module.identifier isEqual:moduleId]) {
                [btn setTitleColor:[UIColor whiteColor] forState:UIControlStateNormal];
                btn.backgroundColor = [colors orangeColor];
                [btn.layer setBorderWidth:0];
                
                break;
            }
        }
        
        [cell.contentView addSubview:btn];
        
        return cell;
    }else if(collectionView == _kindsCollectionView){
        UICollectionViewCell *cell = [_kindsCollectionView dequeueReusableCellWithReuseIdentifier:@"KindsCollectionViewCellIdentifier" forIndexPath:indexPath];
        
        cell.backgroundColor=[UIColor clearColor];
        cell.contentView.backgroundColor = [UIColor clearColor];
        
        for (id child in [cell.contentView subviews]){
            [child removeFromSuperview];
        }
        
        FocusArea *obj = focusAreaArr[indexPath.row];
        
        NSString *focusName = [translationsModel getTranslationForKey:[NSString stringWithFormat:@"%@%@.name", Cf_domain_model_FocusArea, obj.identifier]];
        
        UIButton *btn = [[UIButton alloc] initWithFrame:CGRectMake(0, 10, CGRectGetWidth(cell.frame), 35)];
        [btn setTitle:focusName forState:UIControlStateNormal];
        [btn addTarget:self action:@selector(selectFocusArea:) forControlEvents:UIControlEventTouchUpInside];
        btn.titleLabel.font = [fonts normalFont];
        btn.layer.cornerRadius = 5;
        btn.clipsToBounds = YES;
        btn.tag = indexPath.row;
        [btn setTitleColor:[UIColor blackColor] forState:UIControlStateNormal];
        [btn.layer setBorderColor:[[UIColor grayColor] CGColor]];
        btn.backgroundColor = [UIColor clearColor];
        [btn.layer setBorderWidth:1.0];
        
        for (NSString *focusAreaId in selectedFocusAreaArr) {
            
            if ([obj.identifier isEqual:focusAreaId]) {
                [btn setTitleColor:[UIColor whiteColor] forState:UIControlStateNormal];
                btn.backgroundColor = [colors orangeColor];
                [btn.layer setBorderWidth:0];
                
                break;
            }
        }
        
        [cell.contentView addSubview:btn];
        
        return cell;
        
    }else{
        UICollectionViewCell *cell = [_tagsCollectionView dequeueReusableCellWithReuseIdentifier:@"TagsCollectionViewCellIdentifier" forIndexPath:indexPath];
        
        cell.backgroundColor=[UIColor clearColor];
        cell.contentView.backgroundColor = [UIColor clearColor];
        
        for (id child in [cell.contentView subviews]){
            [child removeFromSuperview];
        }
        
        Tags *tag = tagsArr[indexPath.row];
        
        NSString *tagName = [translationsModel getTranslationForKey:[NSString stringWithFormat:@"%@%@.name", Cf_domain_model_Tag, tag.identifier]];
        
        UIButton *btn = [[UIButton alloc] initWithFrame:CGRectMake(0, 10, CGRectGetWidth(cell.frame), 35)];
        [btn setTitle:[tagName uppercaseString] forState:UIControlStateNormal];
        [btn addTarget:self action:@selector(selectTag:) forControlEvents:UIControlEventTouchUpInside];
        btn.titleLabel.font = [fonts normalFontBold];
        btn.layer.cornerRadius = 35/2;
        btn.clipsToBounds = YES;
        btn.tag = indexPath.row;
        [btn setTitleColor:[UIColor blackColor] forState:UIControlStateNormal];
        btn.backgroundColor = [colors lightGray];
        
        for (NSString *tagId in selectedTagsArr) {
            if ([tag.identifier isEqual:tagId]) {
                [btn setTitleColor:[UIColor whiteColor] forState:UIControlStateNormal];
                btn.backgroundColor = [colors orangeColor];
                [btn.layer setBorderWidth:0];
                
                break;
            }
        }
        
        [cell.contentView addSubview:btn];
        
        return cell;
    }
}

- (CGSize)collectionView:(UICollectionView *)collectionView layout:(UICollectionViewLayout*)collectionViewLayout sizeForItemAtIndexPath:(NSIndexPath *)indexPath{
    
    if(collectionView == _tagsCollectionView){
        Tags *tag = tagsArr[indexPath.row];
        
        NSString *tagName = [translationsModel getTranslationForKey:[NSString stringWithFormat:@"%@%@.name", Cf_domain_model_Tag, tag.identifier]];
        float w = tagName.length * 20;
        
        if([LANGUAGE_KEY isEqualToString:@"cn"]){
            w *= 2;
        }
        
        CGSize cellSize = CGSizeMake(w, 55);
        return cellSize;
    }
    
    CGSize cellSize = CGSizeMake(100, 55);
    return cellSize;
}

-(void)collectionView:(UICollectionView *)collectionView didSelectItemAtIndexPath:(NSIndexPath *)indexPath{
    [self.view endEditing:YES];
}

- (IBAction)selectFilterExercises:(id)sender{
    UIButton *selectedBtn = (UIButton *)sender;
    
    if (selectedBtn.tag == 1) {
        status = @"available";
    }else{
        status = @"all";
    }
    
    for (UIButton *btn in _exercisesButtons){
        
        float cornerRadius = CGRectGetWidth(btn.frame)/4;
        if (btn.tag == selectedBtn.tag) {
            btn.backgroundColor = [colors orangeColor];
            [btn.layer setBorderWidth:0];
            btn.layer.cornerRadius = cornerRadius;
            btn.clipsToBounds = YES;
        }else{
            btn.backgroundColor = [UIColor clearColor];
            [btn.layer setBorderWidth:1.0];
            [btn.layer setBorderColor:[[UIColor grayColor] CGColor]];
            btn.layer.cornerRadius = cornerRadius;
            btn.clipsToBounds = YES;
        }
    }
}

- (IBAction)selectModules:(id)sender {
    int btnTag = (int)[sender tag];
    
    Modules *module = availableModules[btnTag];
    for (NSString *moduleId in selectedModulesArr) {
        
        if ([module.identifier isEqual:moduleId]) {
            [selectedModulesArr removeObject:moduleId];
            
            [_modulesCollectionView reloadData];
            return;
        }
    }
    
    [selectedModulesArr addObject:module.identifier];
    [_modulesCollectionView reloadData];
}

- (IBAction)selectFocusArea:(id)sender {
    int btnTag = (int)[sender tag];
    
    FocusArea *obj = focusAreaArr[btnTag];
    
    for (NSString *focusAreaId in selectedFocusAreaArr) {
        
        if ([obj.identifier isEqual:focusAreaId]) {
            [selectedFocusAreaArr removeObject:focusAreaId];
            
            [_kindsCollectionView reloadData];
            return;
        }
    }
    
    [selectedFocusAreaArr addObject:obj.identifier];
    [_kindsCollectionView reloadData];
}

- (IBAction)selectTag:(id)sender{
    int btnTag = (int)[sender tag];
    
    Tags *obj = tagsArr[btnTag];
    
    for (NSString *tagId in selectedTagsArr) {
        
        if ([obj.identifier isEqual:tagId]) {
            [selectedTagsArr removeObject:tagId];
            
            [_tagsCollectionView reloadData];
            return;
        }
    }
    
    [selectedTagsArr addObject:obj.identifier];
    [_tagsCollectionView reloadData];
}

- (IBAction)chooseDifficulty:(id)sender {
    UIButton *selectedBtn = (UIButton *)sender;
    for(UIButton *btn in _difficultyButtons){
        if (btn == selectedBtn) {
            if (selectedBtn == _easyBtn) {
                btn.backgroundColor = [colors easyColor];
                selectedDifficulty = @"easy";
            }else if (selectedBtn == _mediumBtn){
                btn.backgroundColor = [colors mediumColor];
                selectedDifficulty = @"medium";
            }else if (selectedBtn == _hardBtn){
                btn.backgroundColor = [colors hardColor];
                selectedDifficulty = @"hard";
            }
            
            [btn setTitleColor:[UIColor whiteColor] forState:UIControlStateNormal];
        }else{
            btn.backgroundColor = [UIColor clearColor];
            [btn setTitleColor:[UIColor blackColor] forState:UIControlStateNormal];
        }
    }
}

- (IBAction)selectFilterRate:(id)sender{
    UIButton *selectedBtn = _rateButtons[[sender tag]];
    
    NSString *selectedKey = @"";
    if (selectedBtn.tag == 0) {
        selectedKey = @"top10";
    }else if (selectedBtn.tag == 1) {
        selectedKey = @"neverDoneBefore";
    }else if (selectedBtn.tag == 2) {
        selectedKey = @"liked";
    }
    
    float cornerRadius = CGRectGetWidth(selectedBtn.frame)/4;
    selectedBtn.layer.cornerRadius = cornerRadius;
    selectedBtn.clipsToBounds = YES;
    
    for (NSString *key in [selectedRatesDict allKeys]){
        if ([key isEqual:selectedKey]) {
            [selectedRatesDict removeObjectForKey:selectedKey];
            
            selectedBtn.backgroundColor = [UIColor clearColor];
            [selectedBtn.layer setBorderWidth:1.0];
            [selectedBtn.layer setBorderColor:[[UIColor grayColor] CGColor]];
            return;
        }
    }
    
    [selectedRatesDict setObject:@"true" forKey:selectedKey];
    
    selectedBtn.backgroundColor = [colors orangeColor];
    [selectedBtn.layer setBorderWidth:0];
}

- (NSDictionary *)filters{
    self.params = [NSMutableDictionary new];

    if ([status length] > 0){
        [self.params setObject:status forKey:@"status"];
    }
    
    if ([selectedModulesArr count] > 0) {
        NSString *modules = [selectedModulesArr componentsJoinedByString:@","];
        [self.params setObject:modules forKey:@"modules"];
    }
    
    if ([selectedFocusAreaArr count] > 0) {
        NSString *focusAreas = [selectedFocusAreaArr componentsJoinedByString:@","];
        [self.params setObject:focusAreas forKey:@"focusareas"];
    }
    
    if ([selectedTagsArr count] > 0) {
        NSString *focusAreas = [selectedTagsArr componentsJoinedByString:@","];
        [self.params setObject:focusAreas forKey:@"tags"];
    }
    
    if ([selectedDifficulty length] > 0) {
        [self.params setObject:selectedDifficulty forKey:@"difficulty"];
    }
    
    if ([selectedRatesDict count] > 0) {
        [self.params addEntriesFromDictionary:selectedRatesDict];
    }
    
    NSLog(@"Params = %@", self.params);
    
    return [self.params mutableCopy];
}

-(IBAction)applyFilter:(id)sender{
    if (self.dismissDelegate) {
        [self.dismissDelegate filterExercisesWithFilters:[self filters]];
    }
    [self dismissViewControllerAnimated:YES completion:nil];
}

- (IBAction)resetFilter:(id)sender {
    //Reset Only show exercise
    [self selectFilterExercises:_activatedBtn];

    //Reset modules
    [selectedModulesArr removeAllObjects];
    [_modulesCollectionView reloadData];
    
    //Reset Only show kind
    [selectedFocusAreaArr removeAllObjects];
    [_kindsCollectionView reloadData];
    
    //reload tags
    [selectedTagsArr removeAllObjects];
    [_tagsCollectionView reloadData];

    //Reset Only show difficulty
    selectedDifficulty = @"";
    for(UIButton *btn in _difficultyButtons){
        if (btn == _easyBtn) {
            [btn.layer setBorderColor:[[colors easyColor] CGColor]];
        }else if (btn == _mediumBtn){
            [btn.layer setBorderColor:[[colors mediumColor] CGColor]];
        }else if (btn == _hardBtn){
            [btn.layer setBorderColor:[[colors hardColor] CGColor]];
        }
        btn.backgroundColor = [UIColor clearColor];
        [btn setTitleColor:[UIColor blackColor] forState:UIControlStateNormal];
        [btn.layer setBorderWidth:1.0];
        btn.layer.cornerRadius = 5;
        btn.clipsToBounds = YES;
    }

    //Reset Only show my
    [selectedRatesDict removeAllObjects];
    for(UIButton *btn in _rateButtons){
        btn.backgroundColor = [UIColor clearColor];
        [btn.layer setBorderWidth:1.0];
        [btn.layer setBorderColor:[[UIColor grayColor] CGColor]];
    }
}

- (IBAction)back:(id)sender{
    [self dismissViewControllerAnimated:YES completion:nil];
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

- (void)addSkeletonView{
    [skeletonView addSkeletonFor:_titleLbl isText:YES];
    [skeletonView addSkeletonFor:_showExercisesLbl isText:YES];
    [skeletonView addSkeletonFor:_allLbl isText:YES];
    [skeletonView addSkeletonFor:_activatedLbl isText:YES];
    [skeletonView addSkeletonFor:_showModulesLbl isText:YES];
    [skeletonView addSkeletonFor:_modulesCollectionView isText:YES];
    [skeletonView addSkeletonFor:_showKindsLbl isText:YES];
    [skeletonView addSkeletonFor:_kindsCollectionView isText:YES];
    [skeletonView addSkeletonFor:_showDifficultyLbl isText:YES];
    [skeletonView addSkeletonFor:_easyBtn isText:YES];
    [skeletonView addSkeletonFor:_mediumBtn isText:YES];
    [skeletonView addSkeletonFor:_hardBtn isText:YES];
    [skeletonView addSkeletonFor:_showOnlyLbl isText:YES];
    [skeletonView addSkeletonFor:_top10Lbl isText:YES];
    [skeletonView addSkeletonFor:_neveTriedLbl isText:YES];
    [skeletonView addSkeletonFor:_likedLbl isText:YES];
    
//    [self addSkeletonOnFrame:_xBtn.frame isText:NO];
    [skeletonView addSkeletonFor:_activatedBtn isText:NO];
    [skeletonView addSkeletonFor:_allBtn isText:NO];
    [skeletonView addSkeletonFor:_top10Btn isText:NO];
    [skeletonView addSkeletonFor:_neverTriedBtn isText:NO];
    [skeletonView addSkeletonFor:_likedBtn isText:NO];
    [skeletonView addSkeletonFor:_filterBtn isText:NO];
}

@end
