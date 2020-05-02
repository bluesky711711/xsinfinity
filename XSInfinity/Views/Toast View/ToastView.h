//
//  ToastView.h
//  XSInfinity
//
//  Created by Joseph Marvin Magdadaro on 30/11/2018.
//  Copyright © 2018 Jerk Magz. All rights reserved.
//

#import <Foundation/Foundation.h>
#import <MessageUI/MessageUI.h>

@protocol ToastViewDelegate <NSObject>
@optional
-(void)toastViewDismissed;
-(void)retryConnection;
-(void)cancelToast;
@end

@interface ToastView : NSObject <MFMailComposeViewControllerDelegate>
+ (ToastView *)sharedInstance;
@property (weak) id <ToastViewDelegate> delegate;
@property(nonatomic, assign) BOOL enableAutoDismiss;
@property(nonatomic, assign) BOOL enableRetry;

- (void)showInViewController:(UIViewController *)vc
                     message:(NSString *)message
                includeError:(NSError *)error
           enableAutoDismiss:(BOOL)enableAutoDismiss
                   showRetry:(BOOL)showRetry;
- (void)dismiss;
@end
