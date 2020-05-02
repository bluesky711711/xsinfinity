//
//  PurchaseHistoryViewController.m
//  XSInfinity
//
//  Created by Joseph Marvin Magdadaro on 7/31/18.
//  Copyright © 2018 Jerk Magz. All rights reserved.
//

#import "PurchaseHistoryViewController.h"
#import "DejalActivityView.h"
#import "Animations.h"
#import "Colors.h"
#import "Fonts.h"
#import "TranslationsModel.h"
#import "CustomAlertView.h"
#import "UserServices.h"
#import "PurchaseHistoryObj.h"
#import "SkeletonView.h"
#import "NetworkManager.h"
#import "ToastView.h"
#import "AppDelegate.h"

static int const cellHeight = 60;

@interface PurchaseHistoryViewController ()<NetworkManagerDelegate, ToastViewDelegate>{
    Animations *animations;
    Colors *colors;
    Fonts *fonts;
    TranslationsModel *translationsModel;
    SkeletonView *skeletonView;
    AppDelegate *delegate;
    BOOL didLayoutReloaded;
    NSArray *purchaseHistory;
}

@property (weak, nonatomic) IBOutlet UIView *mainView;

@property (weak, nonatomic) IBOutlet NSLayoutConstraint *contentViewTopConstraint;
@property (weak, nonatomic) IBOutlet UIView *contentView;
@property (weak, nonatomic) IBOutlet UIView *scrollContentView;
@property (weak, nonatomic) IBOutlet UILabel *titleLbl;
@property (weak, nonatomic) IBOutlet UILabel *modulesBoughtLbl;
@property (weak, nonatomic) IBOutlet UILabel *noPurchaseLbl;

@property (weak, nonatomic) IBOutlet UITableView *tableView;
@property (weak, nonatomic) IBOutlet NSLayoutConstraint *tableViewHeightConstraint;

@property (weak, nonatomic) IBOutlet NSLayoutConstraint *lineViewHeightConstraint;

@property (weak, nonatomic) IBOutlet NSLayoutConstraint *scrollViewContentHeightConstraint;

@end

@implementation PurchaseHistoryViewController

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
    
    [self getHistory];
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
    [self getHistory];
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
    _modulesBoughtLbl.font = [fonts headerFontLight];
    _noPurchaseLbl.font = [fonts normalFont];
    
    _titleLbl.text = [translationsModel getTranslationForKey:@"purchase.title"];
    _modulesBoughtLbl.text = [translationsModel getTranslationForKey:@"purchase.modulesbought"];
    _noPurchaseLbl.text = [translationsModel getTranslationForKey:@"info.nomodulesbought"];
    
    [self adjustHeightOfTableview];
}

- (void)adjustHeightOfTableview{
    
    CGFloat tableViewHeight = [purchaseHistory count] * cellHeight;
    _tableViewHeightConstraint.constant = tableViewHeight;
    
    CGFloat tableViewHeightDiff = tableViewHeight - CGRectGetHeight(_tableView.frame);
    _lineViewHeightConstraint.constant += tableViewHeightDiff;
    
    _scrollViewContentHeightConstraint.constant += tableViewHeightDiff;
    
    [self.view layoutIfNeeded];
    
}

- (void)getHistory{
    [skeletonView addSkeletonOnOverlayViewWithBounds:_scrollContentView.frame];
    [_scrollContentView addSubview:skeletonView];
    
    [[UserServices sharedInstance] getpurchasedModuleHistoryWithCompletion:^(NSError *error, int statusCode, NSArray *purchasedModules) {
        if(statusCode == NoInternetErrorStatusCode || statusCode == SlowInternetErrorStatusCode) {
            [[NetworkManager sharedInstance] showConnectionErrorInViewController:self statusCode:statusCode];
            return;
        }
        
        [self->skeletonView remove];
        
        self->purchaseHistory = purchasedModules;
        
        if ([self->purchaseHistory count] > 0) {
            self->_noPurchaseLbl.hidden = YES;
        }else {
            self->_noPurchaseLbl.hidden = NO;
        }
        
        [self->_tableView reloadData];
        [self adjustHeightOfTableview];
    }];
}

#pragma UITableViewDelegate and UITableViewDataSource

- (CGFloat)tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath{
    return cellHeight;
}

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section{
    return [purchaseHistory count];
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath{
    
    static NSString *simpleTableIdentifier = @"SimpleTableItem";
    
    UITableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:simpleTableIdentifier];
    
    if (cell == nil) {
        cell = [[UITableViewCell alloc] initWithStyle:UITableViewCellStyleDefault reuseIdentifier:simpleTableIdentifier];
    }
    cell.backgroundColor = [UIColor clearColor];
    cell.contentView.backgroundColor = [UIColor clearColor];
    
    int dotWH = 30;
    UIImageView *icon = [[UIImageView alloc] initWithFrame:CGRectMake(0, (CGRectGetHeight(cell.frame)/2) - (dotWH/2) , dotWH, dotWH)];
    icon.backgroundColor = [UIColor whiteColor];
    icon.image = [UIImage imageNamed:@"dollar_circle"];
    icon.contentMode = UIViewContentModeScaleAspectFit;
    [cell addSubview:icon];
    
    PurchaseHistoryObj *history = purchaseHistory[indexPath.row];
    
    NSDateFormatter *dateFormatter = [[NSDateFormatter alloc]init];
    [dateFormatter setDateFormat:@"yyyy-MM-dd'T'HH:mm:ssZ"];
    NSDate *date = [dateFormatter dateFromString:history.purchaseDate];
    
    [dateFormatter setDateFormat:@"dd. MM yyyy"];
    NSString *formattedDate = [dateFormatter stringFromDate:date];
    
    UILabel *dateLbl = [[UILabel alloc] initWithFrame:CGRectMake(45, 12, CGRectGetWidth(cell.frame)-45, 18)];
    dateLbl.font = [fonts normalFont];
    dateLbl.text = formattedDate;
    [cell addSubview:dateLbl];
    
    UILabel *moduleNameLbl = [[UILabel alloc] initWithFrame:CGRectMake(45, CGRectGetMaxY(dateLbl.frame), CGRectGetWidth(cell.frame)-45, 18)];
    moduleNameLbl.font = [fonts normalFont];
    moduleNameLbl.text = [NSString stringWithFormat:@"%@ (%.2f)",history.moduleName, history.price];
    [cell addSubview:moduleNameLbl];
    
    return cell;
    
}

- (IBAction)back:(id)sender{
    [self dismissViewControllerAnimated:YES completion:nil];
}

@end
