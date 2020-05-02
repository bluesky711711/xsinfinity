//
//  ToastView.m
//  XSInfinity
//
//  Created by Joseph Marvin Magdadaro on 30/11/2018.
//  Copyright © 2018 Joseph Marvin Magdadaro. All rights reserved.
//

#import "ToastView.h"
#import "Colors.h"
#import "Fonts.h"
#import "Animations.h"
#import "Helper.h"
#import "AppDelegate.h"
#import "TranslationsModel.h"

#define MESSAGE_VIEW_HEIGHT 115
#define BTN_HEIGHT 50
#define BTN_WIDTH 120
#define BTN_MARGIN 10
#define DISMISS_DELAY 5

@implementation ToastView {
    UIViewController *controller;
    NSError *apiError;
    UIView *overlayView;
    UIView *messageView;
    UILabel *messageLbl;
    UIButton *retryBtn;
    UIButton *contactUsBtn;
    UIButton *cancelBtn;
    NSTimer *timer;
    int timeCounter;
    AppDelegate *appDelegate;
}

+ (instancetype)sharedInstance
{
    static dispatch_once_t onceToken;
    static ToastView *sharedInstance;
    
    dispatch_once(&onceToken, ^{
        sharedInstance = [[self alloc] init];
    });
    
    return sharedInstance;
}

- (void)showInViewController:(UIViewController *)vc
                     message:(NSString *)message
                includeError:(NSError *)error
           enableAutoDismiss:(BOOL)enableAutoDismiss
                   showRetry:(BOOL)showRetry{
    appDelegate = (AppDelegate *)[[UIApplication sharedApplication] delegate];
    controller = vc;
    apiError = error;
    self.enableAutoDismiss = enableAutoDismiss;
    self.enableRetry = showRetry;
    
    if(overlayView.superview){
        messageLbl.text = message;
        return;
    }
    
    overlayView = [[UIView alloc] initWithFrame:vc.view.frame];
    overlayView.backgroundColor = [UIColor blackColor];
    overlayView.alpha = 0;
    [vc.view addSubview:overlayView];
    
    int height = MESSAGE_VIEW_HEIGHT;
    if(error){
        height += 40;
    }
    
    int top = (height + 20) * -1; //20 is extra space to make sure the message view wont show before sliding
    messageView = [[UIView alloc] initWithFrame:CGRectMake(0, top, CGRectGetWidth(vc.view.frame), height)];
    messageView.backgroundColor = [[Colors sharedColors] warning];
    [vc.view addSubview:messageView];
    
    int messageLblTop = (height/2)-(MESSAGE_VIEW_HEIGHT/2);
    if(appDelegate.window.safeAreaInsets.top > 0){
        int reduceHeight = height - appDelegate.window.safeAreaInsets.top;
        messageLblTop = (reduceHeight/2)-(MESSAGE_VIEW_HEIGHT/2);
        messageLblTop += appDelegate.window.safeAreaInsets.top;
    }
    
    messageLbl = [[UILabel alloc] initWithFrame:CGRectMake(0, messageLblTop, CGRectGetWidth(vc.view.frame), MESSAGE_VIEW_HEIGHT)];
    messageLbl.text = message;
    messageLbl.font = [[Fonts sharedFonts] normalFont];
    messageLbl.textColor = [UIColor whiteColor];
    messageLbl.backgroundColor = [UIColor clearColor];
    messageLbl.numberOfLines = 0;
    messageLbl.alpha = 0;
    messageLbl.textAlignment = NSTextAlignmentCenter;
    [messageView addSubview:messageLbl];
    
    if(error){
        NSLog(@"EndPoint = %@", error.userInfo);
        NSString *errorCode = [NSString stringWithFormat:@"Error code: %li", (long)error.code];
        NSString *errorDescription = error.localizedDescription;
        NSDictionary *smallFontAttrs = @{ NSFontAttributeName:[[Fonts sharedFonts] smallFont] };
        NSDictionary *boldFontAttrs = @{ NSFontAttributeName:[[Fonts sharedFonts] smallFontBold] };
        
        NSRange errorCodeRange = [message rangeOfString:errorCode];
        NSRange errorDescRange = [message rangeOfString:errorDescription];
        
        NSMutableAttributedString *attributedString = [[NSMutableAttributedString alloc] initWithString:message];
        
        [attributedString setAttributes:smallFontAttrs range:errorCodeRange];
        [attributedString setAttributes:smallFontAttrs range:errorDescRange];
        [messageLbl setAttributedText:attributedString];
    }
    
    retryBtn = [UIButton buttonWithType:UIButtonTypeCustom];
    retryBtn.frame = CGRectMake((CGRectGetWidth(vc.view.frame)/2)-(BTN_WIDTH/2), (CGRectGetHeight(vc.view.frame)/2)-(BTN_HEIGHT/2), BTN_WIDTH, BTN_HEIGHT);
    retryBtn.backgroundColor = [[Colors sharedColors] blueColor];
    retryBtn.alpha = 0;
    retryBtn.layer.cornerRadius = 5;
    retryBtn.clipsToBounds = YES;
    retryBtn.hidden = YES;
    retryBtn.titleLabel.font = [[Fonts sharedFonts] normalFont];
    [retryBtn setTitle:[[TranslationsModel sharedInstance] getTranslationForKey:@"info.retry"] forState:UIControlStateNormal];
    [retryBtn addTarget:self action:@selector(retry) forControlEvents:UIControlEventTouchUpInside];
    [vc.view addSubview:retryBtn];
    
    if(error){
        contactUsBtn = [UIButton buttonWithType:UIButtonTypeCustom];
        contactUsBtn.frame = CGRectMake((CGRectGetWidth(vc.view.frame)/2)-(BTN_WIDTH/2), CGRectGetMaxY(retryBtn.frame)+BTN_MARGIN, BTN_WIDTH, BTN_HEIGHT);
        contactUsBtn.backgroundColor = [[Colors sharedColors] blueColor];
        contactUsBtn.alpha = 0;
        contactUsBtn.layer.cornerRadius = 5;
        contactUsBtn.clipsToBounds = YES;
        contactUsBtn.hidden = YES;
        contactUsBtn.titleLabel.font = [[Fonts sharedFonts] normalFont];
        [contactUsBtn setTitle:[[TranslationsModel sharedInstance] getTranslationForKey:@"info.contactus"] forState:UIControlStateNormal];
        [contactUsBtn addTarget:self action:@selector(contactUs) forControlEvents:UIControlEventTouchUpInside];
        [vc.view addSubview:contactUsBtn];
        
        cancelBtn = [UIButton buttonWithType:UIButtonTypeCustom];
        cancelBtn.frame = CGRectMake((CGRectGetWidth(vc.view.frame)/2)-(BTN_WIDTH/2), CGRectGetMaxY(contactUsBtn.frame)+BTN_MARGIN, BTN_WIDTH, BTN_HEIGHT);
        cancelBtn.backgroundColor = [[Colors sharedColors] lightGray];
        cancelBtn.alpha = 0;
        cancelBtn.layer.cornerRadius = 5;
        cancelBtn.clipsToBounds = YES;
        cancelBtn.hidden = YES;
        cancelBtn.titleLabel.font = [[Fonts sharedFonts] normalFont];
        [cancelBtn setTitleColor:[[Colors sharedColors] darkColor] forState:UIControlStateNormal];
        [cancelBtn setTitle:[[TranslationsModel sharedInstance] getTranslationForKey:@"info.cancel"] forState:UIControlStateNormal];
        [cancelBtn addTarget:self action:@selector(cancel) forControlEvents:UIControlEventTouchUpInside];
        [vc.view addSubview:cancelBtn];
    }
    
    //start animation
    [UIView animateWithDuration:0.3 animations:^{
        if(!self.enableAutoDismiss){
            self->overlayView.alpha = 0.68;
        }
        
        CGRect newMessageFrame = self->messageView.frame;
        newMessageFrame.origin.y = 0;
        self->messageView.frame = newMessageFrame;
        
    } completion:^(BOOL finished) {
        if(self.enableRetry){
            self->retryBtn.hidden = false;
            self->contactUsBtn.hidden = false;
            self->cancelBtn.hidden = false;
        }
        
        [UIView animateWithDuration:0.2 animations:^{
            self->messageLbl.alpha = 1;
            self->retryBtn.alpha = 1;
            self->contactUsBtn.alpha = 1;
            self->cancelBtn.alpha = 1;
        }];
    }];
    
    //auto dismiss
    if(self.enableAutoDismiss){
        timeCounter = 0;
        timer = [NSTimer scheduledTimerWithTimeInterval:1 target:self selector:@selector(autoDismiss) userInfo:nil repeats:YES];
    }
}

#pragma mark - Retry

- (void)retry{
    [self dismiss];
    if([self.delegate respondsToSelector:@selector(retryConnection)]){
        [self.delegate retryConnection];
    }
}


#pragma mark - cancel

- (void)cancel{
    [self dismiss];
    if([self.delegate respondsToSelector:@selector(cancelToast)]){
        [self.delegate cancelToast];
    }
}

#pragma mark - Contact Us

- (void)contactUs{
    MFMailComposeViewController *mc = [[MFMailComposeViewController alloc] init];
    
    if ([MFMailComposeViewController canSendMail]) {
        mc.mailComposeDelegate = self;
        [mc setSubject:@"Error"];
        [mc setToRecipients:@[@"oliver@chinafitter.com "]];
        
        NSDictionary *infoDict = [[NSBundle mainBundle] infoDictionary];
        NSString *appVersion = [infoDict objectForKey:@"CFBundleShortVersionString"];
        NSString *buildNumber = [infoDict objectForKey:@"CFBundleVersion"];
        
        NSString *body = [NSString stringWithFormat:@"<br><br><br><br>================================<br><b>Error Code:</b><br>%ld<br><br><b>Error:</b><br>%@<br><br><b>URL:</b><br>%@<br><br><b>Version:</b><br>%@(%@)<br>================================",(long)apiError.code, apiError.localizedDescription, apiError.userInfo[@"NSErrorFailingURLKey"],appVersion,buildNumber];
        
        [mc setMessageBody:body isHTML:YES];
        
        mc.navigationBar.barTintColor = [UIColor blackColor];
        mc.navigationBar.tintColor = [UIColor blackColor];
        [[mc navigationBar] setTitleTextAttributes:[NSDictionary dictionaryWithObject:[UIColor blackColor] forKey:NSForegroundColorAttributeName]];
        
        [controller presentViewController:mc animated:YES completion:NULL];
        
    }
}

#pragma mark - MessageUI Delegate

- (void) mailComposeController:(MFMailComposeViewController *)controller didFinishWithResult:(MFMailComposeResult)result error:(NSError *)error
{
    switch (result)
    {
        case MFMailComposeResultCancelled:
            NSLog(@"Mail cancelled");
            break;
        case MFMailComposeResultSaved:
            NSLog(@"Mail saved");
            break;
        case MFMailComposeResultSent:
        {
            NSLog(@"Mail sent");
        }
            break;
        case MFMailComposeResultFailed:
        {
            NSLog(@"Mail sent failure: %@", [error localizedDescription]);
        }
            break;
        default:
            break;
    }
    
    [controller dismissViewControllerAnimated:YES completion:NULL];
}

#pragma mark - Dismiss

- (void)dismiss{
    if(messageView){
        [overlayView removeFromSuperview];
        [messageLbl removeFromSuperview];
        [messageView removeFromSuperview];
        [retryBtn removeFromSuperview];
        [cancelBtn removeFromSuperview];
        [contactUsBtn removeFromSuperview];
        
        self->timeCounter = 0;
        [self->timer invalidate];
    }
}

- (void)autoDismiss{
    if(timeCounter < DISMISS_DELAY){
        timeCounter++;
        return;
    }
    
    [UIView animateWithDuration:0.3 animations:^{
        self->overlayView.alpha = 0;
        self->retryBtn.alpha = 0;
        self->cancelBtn.alpha = 0;
        self->contactUsBtn.alpha = 0;
        
        int height = MESSAGE_VIEW_HEIGHT;
        CGRect newFrame = self->messageView.frame;
        newFrame.origin.y = (height + 20) * -1; //20 is extra space to make sure the message view wont show before sliding
        self->messageView.frame = newFrame;
        self->messageLbl.frame = newFrame;
    } completion:^(BOOL finished) {
        [self->overlayView removeFromSuperview];
        [self->messageLbl removeFromSuperview];
        [self->messageView removeFromSuperview];
        [self->retryBtn removeFromSuperview];
        [self->cancelBtn removeFromSuperview];
        [self->contactUsBtn removeFromSuperview];
        
        self->timeCounter = 0;
        [self->timer invalidate];
        
        if([self.delegate respondsToSelector:@selector(toastViewDismissed)]){
            [self.delegate toastViewDismissed];
        }
    }];
}
@end
