//
//  NetworkManager.h
//  XSInfinity
//
//  Created by Jerk Nino Magdadaro on 31/10/2018.
//  Copyright © 2018 Jerk Magz. All rights reserved.
//

#import <Foundation/Foundation.h>
#import <AFNetworking/AFNetworkReachabilityManager.h>

@protocol NetworkManagerDelegate;

@interface NetworkManager : NSObject
+ (NetworkManager *)sharedInstance;
@property (weak) id <NetworkManagerDelegate> delegate;
-(void) connectivityMonitoring;
-(BOOL) isConnectionOffline;
-(void) showConnectionErrorInViewController:(UIViewController *)vc;
-(void) showConnectionErrorInViewController:(UIViewController *)vc statusCode:(int)statusCode;
-(void) showApiErrorInViewController:(UIViewController *)vc error:(NSError *)error;
-(void) stopMonitoring;
@end

@protocol NetworkManagerDelegate <NSObject>
@optional
-(void)finishedConnectivityMonitoring: (AFNetworkReachabilityStatus)status;
@end
