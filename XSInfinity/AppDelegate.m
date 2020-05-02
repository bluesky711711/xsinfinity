//
//  AppDelegate.m
//  XSInfinity
//
//  Created by Joseph Marvin Magdadaro on 5/24/18.
//  Copyright © 2018 Joseph Marvin Magdadaro. All rights reserved.
//

#import "AppDelegate.h"
#import <OneSignal/OneSignal.h>
#import <Fabric/Fabric.h>
#import <Crashlytics/Crashlytics.h>
#import "Fonts.h"
#import "Colors.h"
#import "HeadsUpViewController.h"
#import "Helper.h"
#import "ForgotPasswordViewController.h"
#import "ActivationViewController.h"
#import "UserServices.h"
#import "NetworkManager.h"
#import "WXApi.h"
#import "WXApiManager.h"

@interface AppDelegate ()<UITabBarControllerDelegate, WXApiDelegate>
@property float tabBarItemWidth;

@end

@implementation AppDelegate


- (BOOL)application:(UIApplication *)application didFinishLaunchingWithOptions:(NSDictionary *)launchOptions {
    [Fabric with:@[[Crashlytics class]]];
    
    if (![[NSUserDefaults standardUserDefaults] objectForKey:@"FirstRun"]) {
        [[Helper sharedHelper] removeSavedUser];
        [[NSUserDefaults standardUserDefaults] setValue:@"1strun" forKey:@"FirstRun"];
        [[NSUserDefaults standardUserDefaults] synchronize];
    }
    
    [OneSignal initWithLaunchOptions:launchOptions
                               appId:@"70898356-136a-46b6-ad3b-c239266091dc"
            handleNotificationAction:nil
                            settings:@{kOSSettingsKeyAutoPrompt: @false}];
    OneSignal.inFocusDisplayType = OSNotificationDisplayTypeNotification;
    
    // Recommend moving the below line to prompt for push after informing the user about
    //   how your app will use them.
    [OneSignal promptForPushNotificationsWithUserResponse:^(BOOL accepted) {
        NSLog(@"User accepted notifications: %d", accepted);
    }];
    
    [WXApi startLogByLevel:WXLogLevelNormal logBlock:^(NSString *log) {
        NSLog(@"log : %@", log);
    }];
    
    //WeChat
    [WXApi registerApp:@"wxd574d8b3352b2535"];
    
    self.tabBarController = [[UITabBarController alloc] init];
    self.tabBarController.delegate = self;
    
    [[UINavigationBar appearance] setTintColor:[UIColor whiteColor]];
    
    [[UINavigationBar appearance] setTitleTextAttributes: [NSDictionary dictionaryWithObjectsAndKeys:
                                                           [UIColor whiteColor], NSForegroundColorAttributeName,
                                                           [[Fonts sharedFonts] normalFontBold], NSFontAttributeName, nil]];
    
    [[UINavigationBar appearance] setLargeTitleTextAttributes:[NSDictionary dictionaryWithObjectsAndKeys:
                                                               [UIColor whiteColor], NSForegroundColorAttributeName,
                                                               [[Fonts sharedFonts] headerFont], NSFontAttributeName, nil]];
    
    //hack to hide back title
    [[UIBarButtonItem appearance] setBackButtonTitlePositionAdjustment:UIOffsetMake(-200, 0.0) forBarMetrics:UIBarMetricsDefault];
    
    UIImageView *bg = [[UIImageView alloc] initWithFrame:self.window.bounds];
    bg.image = [UIImage imageNamed:@"bg"];
    [self.window addSubview:bg];
    
    SET_LANGUAGE_KEY(@"en");
    
    self.viewController = [[SplashViewController alloc] initWithNibName:@"SplashViewController" bundle:nil];
    self.viewController.isFromAppDelegate = YES;
    self.navController = [[UINavigationController alloc] initWithRootViewController:self.viewController];
    
    self.window.rootViewController = self.navController;
    [self.window makeKeyAndVisible];
    return YES;
}

- (BOOL)application:(UIApplication *)app
            openURL:(NSURL *)url
            options:(NSDictionary<UIApplicationOpenURLOptionsKey, id> *)options{
    return [WXApi handleOpenURL:url delegate:[WXApiManager sharedManager]];
}

- (BOOL)application:(UIApplication *)application
            openURL:(NSURL *)url
  sourceApplication:(NSString *)sourceApplication
         annotation:(id)annotation{
    return [WXApi handleOpenURL:url delegate:[WXApiManager sharedManager]];
}

- (BOOL)tabBarController:(UITabBarController *)tabBarController shouldSelectViewController:(UIViewController *)viewController{
    return YES;
}

- (void)tabBarController:(UITabBarController *)tabBarController
 didSelectViewController:(UIViewController *)viewController{
    
    _tabBarItemWidth = CGRectGetWidth(tabBarController.tabBar.frame)/[tabBarController.tabBar.items count];
    [self setBackgroundForTabItem:tabBarController.tabBar.items[tabBarController.selectedIndex] animated:YES];
}

- (void)setBackgroundForTabItem:(UITabBarItem *)item animated:(BOOL)animated{
    
    CGFloat x = 0;
    for (int i=0; i<[self.tabBarController.tabBar.items count]; i++) {
        if (self.tabBarController.tabBar.items[i] == item) {
            x = _tabBarItemWidth * i;
            break;
        }
    }
    
    CGFloat duration = animated ? 0.2f : 0;
    [UIView animateWithDuration:duration delay:0 options:UIViewAnimationOptionCurveEaseOut animations:^{
        self.selectedTabBarItemBackgroundView.frame = CGRectMake(x, -3, self.tabBarItemWidth, 52);
    } completion:^(BOOL finished) {
    }];
    
}

- (BOOL)application:(UIApplication *)application continueUserActivity:(NSUserActivity *)userActivity restorationHandler:(void (^)(NSArray * _Nullable))restorationHandler{

    NSURL *url = userActivity.webpageURL;
    NSLog(@"URL:%@", url);
    
    NSURLComponents *urlComponents = [NSURLComponents componentsWithURL:url resolvingAgainstBaseURL:NO];
    NSArray *queryItems = urlComponents.queryItems;
    
    NSString *code = [self valueForKey:@"code" fromQueryItems:queryItems];
    NSString *userName = [self valueForKey:@"user" fromQueryItems:queryItems];
    
    NSLog(@"%@", urlComponents);
    NSLog(@"%@", code);
    
    NSArray *paths = [urlComponents.path componentsSeparatedByString:@"/"];
    
    if ([[paths lastObject] isEqualToString:@"forgotPassword"]){
        ForgotPasswordViewController *vc = [[ForgotPasswordViewController alloc] initWithNibName:@"ForgotPasswordViewController" bundle:nil];
        vc.isFromDeepLink = YES;
        vc.code = code;
        vc.userName = userName;
        [self.navController pushViewController:vc animated:NO];
    }else if ([[paths lastObject] isEqualToString:@"activate"]){
        ActivationViewController *vc = [[ActivationViewController alloc] initWithNibName:@"ActivationViewController" bundle:nil];
        vc.isFromDeepLink = YES;
        vc.isForResendActivation = true;
        vc.code = code;
        vc.userName = userName;
        [self.navController pushViewController:vc animated:NO];
    }
    
    return YES;
}

- (NSString *)valueForKey:(NSString *)key fromQueryItems:(NSArray *)queryItems{
    NSPredicate *predicate = [NSPredicate predicateWithFormat:@"name=%@", key];
    NSURLQueryItem *queryItem = [[queryItems
                                  filteredArrayUsingPredicate:predicate]
                                 firstObject];
    return queryItem.value;
}

- (void)applicationWillResignActive:(UIApplication *)application {
    // Sent when the application is about to move from active to inactive state. This can occur for certain types of temporary interruptions (such as an incoming phone call or SMS message) or when the user quits the application and it begins the transition to the background state.
    // Use this method to pause ongoing tasks, disable timers, and invalidate graphics rendering callbacks. Games should use this method to pause the game.
}


- (void)applicationDidEnterBackground:(UIApplication *)application {
    // Use this method to release shared resources, save user data, invalidate timers, and store enough application state information to restore your application to its current state in case it is terminated later.
    // If your application supports background execution, this method is called instead of applicationWillTerminate: when the user quits.
    
    //save when the last time the app is sent to background.
    SET_LAST_TIME_IN_BACKGROUND([NSDate date]);
}


- (void)applicationWillEnterForeground:(UIApplication *)application {
    // Called as part of the transition from the background to the active state; here you can undo many of the changes made on entering the background.
    
    if([[Helper sharedHelper] isForceRefresh]){
        self.viewController = [[SplashViewController alloc] initWithNibName:@"SplashViewController" bundle:nil];
        self.viewController.isFromAppDelegate = YES;
        self.navController = [[UINavigationController alloc] initWithRootViewController:self.viewController];
        self.window.rootViewController = self.navController;
    }
    
    UIApplicationState state = [[UIApplication sharedApplication] applicationState];
    //NSLog(@"from applicationWillEnterForeground: UIApplicationState state = %li", (long)state);
    if (state == UIApplicationStateBackground || state == UIApplicationStateInactive)
    {
        Helper *helper = [Helper sharedHelper];
        NSString *username = [helper getSavedUsername];
        
        if (username.length > 0 && ![helper isHeadsUpHidden] && ![[NetworkManager sharedInstance] isConnectionOffline]) {
            HeadsUpViewController *vc = [[HeadsUpViewController alloc] initWithNibName:@"HeadsUpViewController" bundle:nil];
            vc.view.backgroundColor = [UIColor clearColor];
            vc.modalPresentationStyle = UIModalPresentationOverCurrentContext;
            
            [self.tabBarController presentViewController:vc animated:NO completion:nil];
        }
    }
}

- (void)applicationDidBecomeActive:(UIApplication *)application {
    // Restart any tasks that were paused (or not yet started) while the application was inactive. If the application was previously in the background, optionally refresh the user interface.
    
    Helper *helper = [Helper sharedHelper];
    NSString *username = [helper getSavedUsername];
    
    //update time zone for user
    if(username.length > 0){
        dispatch_async(dispatch_get_global_queue(DISPATCH_QUEUE_PRIORITY_DEFAULT, 0), ^{
            [[UserServices sharedInstance] updateUserTimeZone:[helper userTimeZone] withCompletion:nil];
        });
    }
}


- (void)applicationWillTerminate:(UIApplication *)application {
    // Called when the application is about to terminate. Save data if appropriate. See also applicationDidEnterBackground:.
}


@end
