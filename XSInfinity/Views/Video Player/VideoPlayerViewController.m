//
//  VideoPlayerViewController.m
//  XSInfinity
//
//  Created by Joseph Marvin Magdadaro on 6/18/18.
//  Copyright © 2018 Joseph Marvin Magdadaro. All rights reserved.
//

#import "VideoPlayerViewController.h"
#import "JPVideoPlayerKit.h"
#import "UINavigationController+FulllScreenPopPush.h"
#import "Animations.h"
#import "AppDelegate.h"

@interface VideoPlayerViewController()<JPVideoPlayerDelegate>{
    JPVideoPlayerDownloader *downloader;
    AppDelegate *delegate;
}

@property (nonatomic, strong) UIView *videoView;

@end

@implementation VideoPlayerViewController

- (void)dealloc {
    [_videoView jp_stopPlay];
}

- (void)viewWillAppear:(BOOL)animated{
    [super viewWillAppear:YES];
    delegate = (AppDelegate *)[[UIApplication sharedApplication] delegate];
    
    [[Animations sharedAnimations] setTabBar:delegate.tabBarController.tabBar fromViewController:self visible:NO animated:NO];
}

- (void)viewDidLoad {
    [super viewDidLoad];
    
    self.view.backgroundColor = [UIColor blackColor];
    
    float h = 300;
    
    _videoView = [[UIView alloc] initWithFrame:CGRectMake(0,([UIScreen mainScreen].bounds.size.height / 2)-(h/2), [UIScreen mainScreen].bounds.size.width, h)];
    _videoView.backgroundColor = [UIColor blackColor];
    _videoView.jp_videoPlayerDelegate = self;
    
    [self.view addSubview:_videoView];
    
}

- (void)viewDidAppear:(BOOL)animated {
    [super viewDidAppear:animated];
    
    [_videoView jp_playVideoWithURL:self.url
                      bufferingIndicator:nil
                             controlView:nil
                            progressView:nil
                 configurationCompletion:nil];
}

- (void)viewDidDisappear:(BOOL)animated {
    [super viewDidDisappear:animated];
    [_videoView jp_stopPlay];
}

#pragma mark - JPVideoPlayerDelegate

- (BOOL)shouldAutoReplayForURL:(nonnull NSURL *)videoURL{
    return NO;
}

//- (BOOL)shouldResumePlaybackFromPlaybackRecordForURL:(NSURL *)videoURL
//                                      elapsedSeconds:(NSTimeInterval)elapsedSeconds {
//    return YES;
//}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

/*
#pragma mark - Navigation

// In a storyboard-based application, you will often want to do a little preparation before navigation
- (void)prepareForSegue:(UIStoryboardSegue *)segue sender:(id)sender {
    // Get the new view controller using [segue destinationViewController].
    // Pass the selected object to the new view controller.
}
*/

@end
