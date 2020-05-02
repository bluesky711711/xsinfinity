//
//  NetworkManager.m
//  XSInfinity
//
//  Created by Jerk Nino Magdadaro on 31/10/2018.
//  Copyright © 2018 Jerk Magz. All rights reserved.
//

#import "NetworkManager.h"
#import <AFNetworking/AFNetworking.h>
#import "AppDelegate.h"
#import "CustomAlertView.h"
#import "TranslationsModel.h"
#import "ToastView.h"
#import "Fonts.h"

@implementation NetworkManager

+ (instancetype)sharedInstance
{
    static dispatch_once_t onceToken;
    static NetworkManager *sharedInstance;
    
    dispatch_once(&onceToken, ^{
        sharedInstance = [[self alloc] init];
    });
    
    return sharedInstance;
}

-(void) connectivityMonitoring{
    [[AFNetworkReachabilityManager sharedManager] setReachabilityStatusChangeBlock:^(AFNetworkReachabilityStatus status) {
        if([self.delegate respondsToSelector:@selector(finishedConnectivityMonitoring:)]){
            [self.delegate finishedConnectivityMonitoring:status];
        }
    }];
    
    [[AFNetworkReachabilityManager sharedManager] startMonitoring];
}

-(void) stopMonitoring{
    [[AFNetworkReachabilityManager sharedManager] stopMonitoring];
}

-(BOOL) isConnectionOffline{
    if(![AFNetworkReachabilityManager sharedManager].reachable){
        return YES;
    }
    return NO;
}

-(void) showConnectionErrorInViewController:(UIViewController *)vc{
    [[ToastView sharedInstance] showInViewController:vc
                                             message:[[TranslationsModel sharedInstance] getTranslationForKey:@"info.nointernet"]
                                        includeError:nil
                                   enableAutoDismiss:false
                                           showRetry:true];
}
-(void) showConnectionErrorInViewController:(UIViewController *)vc statusCode:(int)statusCode{
    NSString *message = [[TranslationsModel sharedInstance] getTranslationForKey:@"info.nointernet"];
    if(statusCode == SlowInternetErrorStatusCode){
        message = [[TranslationsModel sharedInstance] getTranslationForKey:@"info.slowinternet"];
    }
    
    AppDelegate *delegate = (AppDelegate *)[[UIApplication sharedApplication] delegate];
    UIViewController *vc2 = ((UINavigationController*)delegate.window.rootViewController).visibleViewController.presentedViewController;
    
    if(vc2 == nil){
        vc2 = ((UINavigationController*)delegate.window.rootViewController).visibleViewController;
    }
    
    [[ToastView sharedInstance] showInViewController:vc2
                                             message:message
                                        includeError:nil
                                   enableAutoDismiss:false
                                           showRetry:true];
}

-(void) showApiErrorInViewController:(UIViewController *)vc error:(NSError *)error{
    NSString *message = [[TranslationsModel sharedInstance] getTranslationForKey:@"info.somethingwentwrong"];
    NSString *errorCode = [NSString stringWithFormat:@"Error code: %li", (long)error.code];
    NSString *errorDescription = error.localizedDescription;
    
    if(error){
        message = [message stringByAppendingFormat:@"\n\n%@\n%@", errorCode, errorDescription];
    }
    
    [[ToastView sharedInstance] showInViewController:vc
                                             message:message
                                        includeError:error
                                   enableAutoDismiss:false
                                           showRetry:true];
}

/*
 Todo:
 √ received error and extract localizedString and the error code
 √ create new view to show to end user about the error
 √ add retry button - which will retry calling the api
 √ add contact us button
    √ which shows the email composer and prefilled the body with error info. Including:
 √ app's version number
 √ api endpoint
 √ error code
 √ error message returned from the server
 - **apply to all apis
 - **remove custom alertview
 */
@end
