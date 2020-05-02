//
//  StartExerciseViewController.m
//  XSInfinity
//
//  Created by Joseph Marvin Magdadaro on 6/16/18.
//  Copyright © 2018 Joseph Marvin Magdadaro. All rights reserved.
//

#import "StartExerciseViewController.h"
#import <AVFoundation/AVFoundation.h>
#import "AppDelegate.h"
#import "Helper.h"
#import "Colors.h"
#import "Fonts.h"
#import "TranslationsModel.h"
#import "CustomAlertView.h"
#import "RateExerciseViewController.h"
#import "SingleExerciseSetTableViewCell.h"
#import "NetworkManager.h"
#import "ToastView.h"

@interface StartExerciseViewController ()<UINavigationControllerDelegate, UINavigationBarDelegate, NetworkManagerDelegate, ToastViewDelegate>{
    AppDelegate *delegate;
    Helper *helper;
    Colors *colors;
    Fonts *fonts;
    TranslationsModel *translationsModel;
    SingleExerciseSetTableViewCell *selectedSetCell;
    BOOL didLayoutReloaded;
    NSTimer *timer;
    int duration;
    BOOL popViewController;
    int numOfSetsDone;
}

@property (weak, nonatomic) IBOutlet UITableView *tableView;

@property (nonatomic, assign) CGFloat lastContentOffset;
@property(strong) AVAudioPlayer *audioPlayer;

@end

@implementation StartExerciseViewController

-(void)viewWillAppear:(BOOL)animated{
    [super viewWillAppear:YES];
    self.navigationController.navigationBar.hidden = NO;
    
}

- (void)viewDidLoad {
    [super viewDidLoad];
//    self.navigationController.navigationBar.hidden = NO;
//    self.navigationItem.title = @"Kick routine kick";
    self.navigationController.navigationBar.hidden = NO;
    [self.navigationController.navigationBar setBackgroundImage:[UIImage new]
                                                  forBarMetrics:UIBarMetricsDefault];
    self.navigationController.navigationBar.shadowImage = [UIImage new];
    self.navigationItem.title = self.exercise.name;
    self.navigationItem.largeTitleDisplayMode = UINavigationItemLargeTitleDisplayModeNever;
    self.navigationItem.hidesBackButton = true;
    
    
    UIBarButtonItem *backButton = [[UIBarButtonItem alloc] initWithImage:[UIImage imageNamed:@"arrow-back"]
                                                                   style:UIBarButtonItemStylePlain
                                                                  target:self
                                                                  action:@selector(back:)];
    backButton.imageInsets = UIEdgeInsetsMake(0, -7, 0, 0);
    self.navigationItem.leftBarButtonItem = backButton;
    
    helper = [Helper sharedHelper];
    colors = [Colors sharedColors];
    fonts = [Fonts sharedFonts];
    translationsModel = [TranslationsModel sharedInstance];
    delegate = (AppDelegate *)[[UIApplication sharedApplication] delegate];
    delegate.tabBarController.tabBar.hidden = YES;
    
    duration = self.exercise.duration;
}

- (void)viewDidAppear:(BOOL)animated{
    [super viewDidAppear:YES];
    
    [[ToastView sharedInstance] setDelegate:self];
    [[NetworkManager sharedInstance] setDelegate:self];
    [[NetworkManager sharedInstance] connectivityMonitoring];
}

-(void) viewWillDisappear:(BOOL)animated{
    [super viewWillDisappear:YES];
    delegate.tabBarController.tabBar.hidden = NO;
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
    }
}

- (IBAction)back:(id)sender {
    [[CustomAlertView sharedInstance] showAlertInViewController:delegate.tabBarController
                                                      withTitle:[[TranslationsModel sharedInstance] getTranslationForKey:@"excan.titel"]
                                                        message:[[TranslationsModel sharedInstance] getTranslationForKey:@"excan.descr"]
                                              cancelButtonTitle:[[TranslationsModel sharedInstance] getTranslationForKey:@"excan.continue"]
                                                doneButtonTitle:[[TranslationsModel sharedInstance] getTranslationForKey:@"excan.stop"]];
    [[CustomAlertView sharedInstance] setDoneBlock:^(id result) {
        [self->timer invalidate];
        [self.navigationController popViewControllerAnimated:YES];
    }];
    [[CustomAlertView sharedInstance] setCancelBlock:^(id result) {
        NSLog(@"Cancel");
    }];
}

-(void)viewDidLayoutSubviews{
    [super viewDidLayoutSubviews];
    
    if( !didLayoutReloaded ){
        [self setupUserInterface];
        
        didLayoutReloaded = YES;
    }
}

- (void)setupUserInterface{
    
}

- (CGFloat)tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath{
    return 175;
}

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section{
    return self.exercise.sets;
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath{
    
    static NSString *simpleTableIdentifier = @"singleExerciseSetTableViewCell";
    
    SingleExerciseSetTableViewCell *cell = (SingleExerciseSetTableViewCell *)[tableView dequeueReusableCellWithIdentifier:simpleTableIdentifier];
    
    if (cell == nil) {
        NSArray *nib = [[NSBundle mainBundle] loadNibNamed:@"SingleExerciseSetTableViewCell" owner:self options:nil];
        cell = [nib objectAtIndex:0];
    }
    cell.selectionStyle = UITableViewCellSelectionStyleNone;
    
    [cell layoutSubviews];
    [helper addDropShadowIn:cell.shadowView withColor:[UIColor darkGrayColor] andSetCornerRadiusTo:5.0];
    
    cell.setLbl.font = [fonts normalFont];
    cell.setValueLbl.font = [fonts bigFontBold];
    cell.setRepsOrTimesLbl.font = [fonts normalFont];
    cell.setRepsOrTimesValueLbl.font = [fonts bigFontBold];
    
    cell.setLbl.text = [[translationsModel getTranslationForKey:@"extype.set"] uppercaseString];
    cell.setValueLbl.text = [NSString stringWithFormat:@"%d.",(int)(indexPath.row + 1)];
    
    cell.setBtn.layer.cornerRadius = CGRectGetWidth(cell.setBtn.frame)/2;
    cell.setBtn.clipsToBounds = YES;
    cell.setBtn.tag = indexPath.row;
    
    if ([self.exercise.type isEqualToString:@"repetition"]) {
        [cell.setBtn setImage:[UIImage imageNamed:@"check"] forState:UIControlStateNormal];
        
        cell.setRepsOrTimesLbl.text = [[translationsModel getTranslationForKey:@"extype.reps"] uppercaseString];
        cell.setRepsOrTimesValueLbl.text = @(self.exercise.repetitions).stringValue;
        
        if (indexPath.row < numOfSetsDone){
            cell.setBtn.backgroundColor = [colors greenColor];
            cell.setBtn.userInteractionEnabled = NO;
        }else if (indexPath.row == numOfSetsDone){
            cell.setBtn.backgroundColor = [UIColor lightGrayColor];
            cell.setBtn.userInteractionEnabled = YES;
        }else{
            cell.setBtn.backgroundColor = [UIColor lightGrayColor];
            cell.setBtn.userInteractionEnabled = NO;
        }
        
    }else {//duration
        [cell.setBtn setImage:[UIImage imageNamed:@"clock"] forState:UIControlStateNormal];
        
        cell.setRepsOrTimesLbl.text = [[translationsModel getTranslationForKey:@"extype.seconds"] uppercaseString];
        
        NSLog(@"indexPath.row: %li numOfSetsDone %i", (long)indexPath.row, numOfSetsDone);
        
        if (indexPath.row < numOfSetsDone){
            [cell.setBtn setImage:[UIImage imageNamed:@"check"] forState:UIControlStateNormal];
            cell.setBtn.backgroundColor = [colors greenColor];
            cell.setBtn.userInteractionEnabled = NO;
            
            cell.setRepsOrTimesValueLbl.text = @"0";
        }else if (indexPath.row == numOfSetsDone){
            //[cell.setBtn setImage:[UIImage imageNamed:@"check"] forState:UIControlStateNormal];
            cell.setBtn.backgroundColor = [colors greenColor];
            cell.setBtn.userInteractionEnabled = YES;
            
            cell.setRepsOrTimesValueLbl.text = @(self.exercise.duration).stringValue;
        }else{
            cell.setBtn.backgroundColor = [UIColor lightGrayColor];
            cell.setBtn.userInteractionEnabled = NO;
            
            cell.setRepsOrTimesValueLbl.text = @(self.exercise.duration).stringValue;
        }
    }
    
    [cell.setBtn addTarget:self action:@selector(startSet:) forControlEvents:UIControlEventTouchUpInside];
    
    return cell;
    
}

- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath{
    [self.view endEditing:YES];
    
}

- (IBAction)startSet:(id)sender{
    UIButton *btn = (UIButton *)sender;
    
    if ([self.exercise.type isEqualToString:@"repetition"]) {
        
        numOfSetsDone += 1;
        [_tableView reloadData];
        
        if (self.exercise.sets == numOfSetsDone){
            [self rateThisExercise];
        }
    }else{
        NSIndexPath *iPath = [NSIndexPath indexPathForRow:btn.tag inSection:0];
        selectedSetCell = (SingleExerciseSetTableViewCell *)[_tableView cellForRowAtIndexPath:iPath];
        btn.userInteractionEnabled = false;
        [self startTimer];
    }
}

- (void)startTimer{
    
    [[CustomAlertView sharedInstance] showTimerAlertInViewController:delegate.tabBarController
                                                           withTitle:[translationsModel getTranslationForKey:@"excount.getready"]];
    [[CustomAlertView sharedInstance] setCancelBlock:^(id result) {
       self->timer = [NSTimer scheduledTimerWithTimeInterval:1 repeats:YES block:^(NSTimer * _Nonnull timer) {
            if(self->duration > 0){
                self->duration -= 1;
                
                if(self->duration == 0){
                    //fire a sound
                    [self->helper playSoundName:@"timer_end" extension:@"wav"];
                    self->numOfSetsDone++;
                }
                
                if(self->duration > -1){
                    [self->selectedSetCell.setRepsOrTimesValueLbl setText:@(self->duration).stringValue];
                }
                
            }else{
                [timer invalidate];
                self->duration = self.exercise.duration;
                [self->_tableView reloadData];
                
                if (self.exercise.sets == self->numOfSetsDone){
                    [self rateThisExercise];
                }
            }
        }];
    }];
}

- (void)rateThisExercise{
    RateExerciseViewController *vc = [[RateExerciseViewController alloc] initWithNibName:@"RateExerciseViewController" bundle:nil];
    vc.exerciseId = self.exercise.identifier;
    vc.exerciseName = self.exercise.name;
    [self.navigationController pushViewController:vc animated: YES];
    delegate.tabBarController.tabBar.hidden = YES;
}

@end
