//
//  CustomAlertView.m
//  Habits
//
//  Created by Joseph Marvin Magdadaro on 2/27/18.
//  Copyright © 2018 Joseph Marvin Magdadaro. All rights reserved.
//

#import "CustomAlertView.h"
#import <AVFoundation/AVFoundation.h>
#import "Colors.h"
#import "Animations.h"
#import "Fonts.h"
#import "Helper.h"

@implementation CustomAlertView{
    CancelBlock cancelBlock;
    DoneBlock doneBlock;
    UIView *vcView;

    //For Timer
    UILabel *timerLbl;
    NSTimer *timer;
    int duration;
    
    AVAudioPlayer *audioPlayer;
}

+ (instancetype)sharedInstance
{
    static dispatch_once_t onceToken;
    static CustomAlertView *sharedInstance;
    
    dispatch_once(&onceToken, ^{
        sharedInstance = [[self alloc] init];
    });
    
    return sharedInstance;
}

- (void)setCancelBlock:(CancelBlock)aCancelBlock {
    cancelBlock = [aCancelBlock copy];
}

- (void)tapCancel:(id)result {
    if (cancelBlock) {
        [vcView removeFromSuperview];
        cancelBlock(result);
    }
}

- (void)setDoneBlock:(DoneBlock)aDoneBlock {
    doneBlock = [aDoneBlock copy];
}

- (void)tapDone:(id)result {
    if (doneBlock) {
        [vcView removeFromSuperview];
        doneBlock(result);
    }
}

- (IBAction)closePop:(id)sender{
    [vcView removeFromSuperview];
}

- (void)showAlertInViewController:(UIViewController *)vc
                        withTitle:(NSString *)title
                          message:(NSString *)message
                cancelButtonTitle:(NSString *)cancelTitle
                  doneButtonTitle:(NSString *)doneTitle{
    
    UIView *bgView = [[UIView alloc] initWithFrame:vc.view.frame];
    bgView.backgroundColor = [[UIColor blackColor] colorWithAlphaComponent:0.68];
    bgView.tag = 99;
    [vc.view addSubview:bgView];
    
    UIButton *dismissBtn = [[UIButton alloc] initWithFrame:bgView.frame];
    dismissBtn.tag = 99;
    [dismissBtn addTarget:self
                action:@selector(closePop:)
      forControlEvents:UIControlEventTouchUpInside];
    [bgView addSubview:dismissBtn];
    
    vcView = bgView;
    
    int w = vc.view.frame.size.width * 0.8;
    int h = w;
    UIView *alertView = [[UIView alloc] initWithFrame:CGRectMake((CGRectGetWidth(bgView.frame)/2)-(w/2), (CGRectGetHeight(bgView.frame)/2)-(h/2), w, h)];
    alertView.backgroundColor = [UIColor whiteColor];
    alertView.layer.cornerRadius = 8;
    alertView.layer.shadowColor = [UIColor blackColor].CGColor;
    alertView.layer.shadowOffset = CGSizeMake(0, 5);
    alertView.layer.shadowOpacity = 0.3;
    alertView.layer.shadowRadius = 8.0;
    alertView.clipsToBounds = true;
    [bgView addSubview:alertView];
    
    UILabel *titleLbl = [[UILabel alloc] initWithFrame:CGRectMake(0, 20, w, h*0.1)];
    titleLbl.text = title;
    titleLbl.font = [[Fonts sharedFonts] headerFontLight];
    titleLbl.textAlignment = NSTextAlignmentCenter;
    [alertView addSubview:titleLbl];
    
    float msgH = h * 0.6;
    if ([doneTitle length]>0) {
        msgH = h * 0.4;
    }
    
    UITextView *messageTxtView = [[UITextView alloc] initWithFrame:CGRectMake(20, CGRectGetMaxY(titleLbl.frame)+10, w-30, msgH)];
    messageTxtView.text = message;
    messageTxtView.editable = FALSE;
    messageTxtView.scrollEnabled = FALSE;
    messageTxtView.font = [[Fonts sharedFonts] normalFont];
    [alertView addSubview:messageTxtView];
    
    UIButton *cancelBtn = [[UIButton alloc] initWithFrame:CGRectMake(0, CGRectGetMaxY(messageTxtView.frame), w, h*0.2)];
    cancelBtn.tag = 99;
    cancelBtn.titleLabel.font = [[Fonts sharedFonts] normalFontBold];
    cancelBtn.backgroundColor = [[Colors sharedColors] blueColor];
    [cancelBtn setTitleColor:[UIColor whiteColor] forState:UIControlStateNormal];
    [cancelBtn setTitle:cancelTitle forState:UIControlStateNormal];
    [cancelBtn addTarget:self
                  action:@selector(tapCancel:)
       forControlEvents:UIControlEventTouchUpInside];
    [alertView addSubview:cancelBtn];
    
    UIButton *doneBtn = [[UIButton alloc] initWithFrame:CGRectMake(0, CGRectGetMaxY(cancelBtn.frame), w, h*0.2)];
    doneBtn.tag = 99;
    doneBtn.titleLabel.font = [[Fonts sharedFonts] normalFont];
    doneBtn.backgroundColor = [UIColor clearColor];
    [doneBtn setTitleColor:[UIColor blackColor] forState:UIControlStateNormal];
    [doneBtn setTitle:doneTitle forState:UIControlStateNormal];
    [doneBtn addTarget:self
                  action:@selector(tapDone:)
        forControlEvents:UIControlEventTouchUpInside];
    [alertView addSubview:doneBtn];
    
    [[Animations sharedAnimations] zoomSpringAnimationForView:alertView];
}

- (void)showTimerAlertInViewController:(UIViewController *)vc
                        withTitle:(NSString *)title{
    
    UIView *bgView = [[UIView alloc] initWithFrame:vc.view.frame];
    bgView.backgroundColor = [[UIColor blackColor] colorWithAlphaComponent:0.68];
    bgView.tag = 99;
    [vc.view addSubview:bgView];
    
    vcView = bgView;
    
    int w = vc.view.frame.size.width * 0.4;
    int h = w;
    UIView *alertView = [[UIView alloc] initWithFrame:CGRectMake((CGRectGetWidth(bgView.frame)/2)-(w/2), (CGRectGetHeight(bgView.frame)/2)-(h/2), w, h)];
    alertView.backgroundColor = [UIColor whiteColor];
    alertView.layer.cornerRadius = 8;
    alertView.layer.shadowColor = [UIColor blackColor].CGColor;
    alertView.layer.shadowOffset = CGSizeMake(0, 5);
    alertView.layer.shadowOpacity = 0.3;
    alertView.layer.shadowRadius = 8.0;
    alertView.clipsToBounds = true;
    [bgView addSubview:alertView];
    
    UILabel *titleLbl = [[UILabel alloc] initWithFrame:CGRectMake(0, 30, w, h*0.2)];
    titleLbl.text = title;
    titleLbl.font = [[Fonts sharedFonts] normalFont];
    titleLbl.textAlignment = NSTextAlignmentCenter;
    [alertView addSubview:titleLbl];
    
    duration = 5;
    
    timerLbl = [[UILabel alloc] initWithFrame:CGRectMake(0, CGRectGetMaxY(titleLbl.frame) + 20, w, h*0.2)];
    timerLbl.text = [NSString stringWithFormat:@"%d ...", duration];
    timerLbl.font = [[Fonts sharedFonts] normalFont];
    timerLbl.textAlignment = NSTextAlignmentCenter;
    [alertView addSubview:timerLbl];
    
    [self startTimer];
    
    [[Animations sharedAnimations] zoomSpringAnimationForView:alertView];
}

- (void)startTimer{
    [NSTimer scheduledTimerWithTimeInterval:1 repeats:YES block:^(NSTimer * _Nonnull timer) {
        if(self->duration > 0){
            self->duration -= 1;
            
            if(self->duration == 3){
                [[Helper sharedHelper] playSoundName:@"countdown_end" extension:@"wav"];
            }
            
            self->timerLbl.text = [NSString stringWithFormat:@"%d ...", self->duration];
        }else{
            [timer invalidate];
            [self tapCancel:nil];
        }
    }];
    
}

@end
