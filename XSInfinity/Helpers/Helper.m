//
//  Helper.m
//  XSInfinity
//
//  Created by Joseph Marvin Magdadaro on 5/31/18.
//  Copyright © 2018 Joseph Marvin Magdadaro. All rights reserved.
//

#import "Helper.h"
#import <AVFoundation/AVFoundation.h>
#import <Realm/Realm.h>
#import "ExercisesMainViewController.h"
#import "HabitsActivationViewController.h"
#import "HabitsViewController.h"
#import "ExercisesListViewController.h"
#import "PerformanceViewController.h"
#import "RegistrationViewController.h"
#import "ProfileViewController.h"
#import "AppDelegate.h"
#import "Colors.h"
#import "Fonts.h"
#import "KeychainItemWrapper.h"
#import "UserInfo.h"
#import "UserSummary.h"
#import "Modules.h"
#import "Exercises.h"
#import "ExercisesSummary.h"
#import "BookmarkedExercises.h"
#import "Habits.h"
#import "HabitsOverview.h"
#import "Gallery.h"
#import "FaqCategory.h"
#import "Faq.h"

@implementation Helper {
    AVAudioPlayer *audioPlayer;
}

+ (Helper *)sharedHelper {
    __strong static Helper *sharedHelper = nil;
    static dispatch_once_t onceToken;
    dispatch_once(&onceToken, ^{
        sharedHelper = [[Helper alloc] init];
    });
    return sharedHelper;
}

- (id)init {
    self = [super init];
    return self;
}

#pragma mark: Clean Value

- (NSString *) cleanValue: (NSString *) value{
    return ((value != NULL && ![value isEqual:[NSNull null]] )?value:@"");
}

#pragma mark: Search Icon

- (UIImageView *) searchIcon{
    UIImageView *searchIcon = [[UIImageView alloc] initWithFrame:CGRectMake(0,0, 20.0, 7.0)];
    searchIcon.image = [UIImage imageNamed:@"search_icon"];
    searchIcon.contentMode = UIViewContentModeScaleAspectFit;
    
    return searchIcon;
}


#pragma mark: Add Shadow and Set Corner Radius

- (void)addDropShadowIn:(id)obj withColor:(UIColor *)shadowColor andSetCornerRadiusTo:(float)cornerRadius{
    UIEdgeInsets shadowInsets = UIEdgeInsetsMake(-1.0f, -1.0f, -5.0f, -1.0f);
    
    if ([obj isKindOfClass:[UIView class]]) {
        UIView *view = (UIView *)obj;
        
        [self addShadowInView:view withColor:shadowColor cornerRadiusTo:cornerRadius andShadowInsets:shadowInsets];
    }else if ([obj isKindOfClass:[UIButton class]]){
        UIButton *btn = (UIButton *)obj;
        
        [self addShadowInButton:btn withColor:shadowColor cornerRadiusTo:cornerRadius andShadowInsets:shadowInsets];
    }else if ([obj isKindOfClass:[UITextField class]]){
        UITextField *txt = (UITextField *)obj;
        
        [self addShadowInTextField:txt withColor:shadowColor cornerRadiusTo:cornerRadius andShadowInsets:shadowInsets];
    }
}

- (void)addShadowIn:(id)obj withColor:(UIColor *)shadowColor andSetCornerRadiusTo:(float)cornerRadius{
    UIEdgeInsets shadowInsets = UIEdgeInsetsMake(-5.0f, -5.0f, -6.0f, -5.0f);
    
    if ([obj isKindOfClass:[UIView class]]) {
        UIView *view = (UIView *)obj;
        
        [self addShadowInView:view withColor:shadowColor cornerRadiusTo:cornerRadius andShadowInsets:shadowInsets];
    }else if ([obj isKindOfClass:[UIButton class]]){
        UIButton *btn = (UIButton *)obj;
        
        [self addShadowInButton:btn withColor:shadowColor cornerRadiusTo:cornerRadius andShadowInsets:shadowInsets];
    }else if ([obj isKindOfClass:[UITextField class]]){
        UITextField *txt = (UITextField *)obj;
        
        [self addShadowInTextField:txt withColor:shadowColor cornerRadiusTo:cornerRadius andShadowInsets:shadowInsets];
    }
}

- (void)addShadowInView:(UIView *)view withColor:(UIColor *)shadowColor cornerRadiusTo:(float)cornerRadius andShadowInsets:(UIEdgeInsets)insets{
//    [view layoutIfNeeded];
    
    view.layer.cornerRadius = cornerRadius;
    view.clipsToBounds = YES;
    
    view.layer.shadowColor   = shadowColor.CGColor;
    view.layer.shadowOffset  = CGSizeMake(0.0f, 0.0f);
    view.layer.shadowOpacity = 0.3f;
    view.layer.shadowRadius  = cornerRadius;
    view.layer.masksToBounds = NO;
    
    UIBezierPath *shadowPath = [UIBezierPath bezierPathWithRect:UIEdgeInsetsInsetRect(view.bounds, insets)];
    
    view.layer.shadowPath = shadowPath.CGPath;
    
}

- (void)addShadowInButton:(UIButton *)btn withColor:(UIColor *)shadowColor cornerRadiusTo:(float)cornerRadius andShadowInsets:(UIEdgeInsets)insets{
    [btn layoutIfNeeded];
    
    btn.layer.cornerRadius = cornerRadius;
    btn.clipsToBounds = YES;
    
    btn.layer.shadowColor   = shadowColor.CGColor;
    btn.layer.shadowOffset  = CGSizeMake(0.0f, 0.0f);
    btn.layer.shadowOpacity = 0.5f;
    btn.layer.shadowRadius  = cornerRadius;
    btn.layer.masksToBounds = NO;
    
    UIBezierPath *shadowPath = [UIBezierPath bezierPathWithRect:UIEdgeInsetsInsetRect(btn.bounds, insets)];
    
    btn.layer.shadowPath = shadowPath.CGPath;
    
}

- (void)addShadowInTextField:(UITextField *)txt withColor:(UIColor *)shadowColor cornerRadiusTo:(float)cornerRadius andShadowInsets:(UIEdgeInsets)insets{
    [txt layoutIfNeeded];
    
    txt.layer.cornerRadius = cornerRadius;
    txt.clipsToBounds = YES;
    
    txt.layer.shadowColor   = shadowColor.CGColor;
    txt.layer.shadowOffset  = CGSizeMake(0.0f, 0.0f);
    txt.layer.shadowOpacity = 0.5f;
    txt.layer.shadowRadius  = cornerRadius;
    txt.layer.masksToBounds = NO;
    
    UIEdgeInsets shadowInsets = insets;
    UIBezierPath *shadowPath = [UIBezierPath bezierPathWithRect:UIEdgeInsetsInsetRect(txt.bounds, shadowInsets)];
    
    txt.layer.shadowPath = shadowPath.CGPath;
    
}

#pragma mark: Add Borders and Set Corner Radius

- (void)setFlexibleBorderIn:(id)obj withColor:(UIColor *)borderColor topBorderWidth:(float)topBorderWidth leftBorderWidth:(float)leftBorderWidth rightBorderWidth:(float)rightBorderWidth bottomBorderWidth:(float)bottomBorderWidth{
    
    float w = 0;
    float h = 0;
    
    if ([obj isKindOfClass:[UIView class]]) {
        UIView *view = (UIView *)obj;
        [view layoutIfNeeded];
        w = CGRectGetWidth(view.frame);
        h = CGRectGetHeight(view.frame);
    }else if ([obj isKindOfClass:[UIButton class]]){
        UIButton *btn = (UIButton *)obj;
        [btn layoutIfNeeded];
        w = CGRectGetWidth(btn.frame);
        h = CGRectGetHeight(btn.frame);
    }else if ([obj isKindOfClass:[UITextField class]]){
        UITextField *txt = (UITextField *)obj;
        [txt layoutIfNeeded];
        w = CGRectGetWidth(txt.frame);
        h = CGRectGetHeight(txt.frame);
    }
    
    CALayer *topBorder = [CALayer layer];
    topBorder.borderColor = borderColor.CGColor;
    topBorder.borderWidth = topBorderWidth;
    topBorder.frame = CGRectMake(0, 0, w, topBorderWidth);
    
    CALayer *rightBorder = [CALayer layer];
    rightBorder.borderColor = borderColor.CGColor;
    rightBorder.borderWidth = rightBorderWidth;
    rightBorder.frame = CGRectMake( w - rightBorderWidth, 0, rightBorderWidth, h);
    
    CALayer *bottomBorder = [CALayer layer];
    bottomBorder.borderColor = borderColor.CGColor;
    bottomBorder.borderWidth = bottomBorderWidth;
    bottomBorder.frame = CGRectMake(0, h - bottomBorderWidth, w, bottomBorderWidth);
    
    CALayer *leftBorder = [CALayer layer];
    leftBorder.borderColor = borderColor.CGColor;
    leftBorder.borderWidth = leftBorderWidth;
    leftBorder.frame = CGRectMake(0, 0, leftBorderWidth, h);
    
    if ([obj isKindOfClass:[UIView class]]) {
        UIView *view = (UIView *)obj;
        
        [view.layer addSublayer:topBorder];
        [view.layer addSublayer:rightBorder];
        [view.layer addSublayer:bottomBorder];
        [view.layer addSublayer:leftBorder];
    }else if ([obj isKindOfClass:[UIButton class]]){
        UIButton *btn = (UIButton *)obj;
        
        [btn.layer addSublayer:topBorder];
        [btn.layer addSublayer:rightBorder];
        [btn.layer addSublayer:bottomBorder];
        [btn.layer addSublayer:leftBorder];
    }else if ([obj isKindOfClass:[UITextField class]]){
        UITextField *txt = (UITextField *)obj;
        
        [txt.layer addSublayer:topBorder];
        [txt.layer addSublayer:rightBorder];
        [txt.layer addSublayer:bottomBorder];
        [txt.layer addSublayer:leftBorder];
    }
}

- (UIImage *)imageWithColor:(UIColor *)color andBounds:(CGRect)imgBounds {
    UIGraphicsBeginImageContextWithOptions(imgBounds.size, NO, 0);
    [color setFill];
    UIRectFill(imgBounds);
    UIImage *img = UIGraphicsGetImageFromCurrentImageContext();
    UIGraphicsEndImageContext();
    
    return img;
}

- (void)withnotactivehabit{
    AppDelegate *delegate = (AppDelegate *)[[UIApplication sharedApplication] delegate];
    UIViewController *viewController1 = [[ExercisesMainViewController alloc] initWithNibName:@"ExercisesMainViewController" bundle:nil];
    UINavigationController *navigationcontroller1 = [[UINavigationController alloc] initWithRootViewController:viewController1];
    
    UIViewController *viewController2 = [[HabitsActivationViewController alloc] initWithNibName:@"HabitsActivationViewController" bundle:nil];
    if (IS_HABITS_ACTIVATED) {
        viewController2 = [[HabitsViewController alloc] initWithNibName:@"HabitsViewController" bundle:nil];
    }
    UINavigationController *navigationcontroller2 = [[UINavigationController alloc] initWithRootViewController:viewController2];
    
    UIViewController *viewController3 = [[ExercisesListViewController alloc] initWithNibName:@"ExercisesListViewController" bundle:nil];
    UINavigationController *navigationcontroller3 = [[UINavigationController alloc] initWithRootViewController:viewController3];
    
    UIViewController *viewController4 = [[PerformanceViewController alloc] initWithNibName:@"PerformanceViewController" bundle:nil];
    UINavigationController *navigationcontroller4 = [[UINavigationController alloc] initWithRootViewController:viewController4];
    
    UIViewController *viewController5 = [[ProfileViewController alloc] initWithNibName:@"ProfileViewController" bundle:nil];
    UINavigationController *navigationcontroller5 = [[UINavigationController alloc] initWithRootViewController:viewController5];
    
    //delegate.tabBarController.viewControllers = [NSArray arrayWithObjects:navigationcontroller1, navigationcontroller2, navigationcontroller3, navigationcontroller4, navigationcontroller5, nil];
    [delegate.tabBarController setViewControllers:[NSArray arrayWithObjects:navigationcontroller1, navigationcontroller2, navigationcontroller3, navigationcontroller4, navigationcontroller5, nil] animated:NO];
}

- (void)setUpTabBarControllerFrom:(UIViewController *)vc initialIndex:(int)initialIndex{
    
    AppDelegate *delegate = (AppDelegate *)[[UIApplication sharedApplication] delegate];
    UIViewController *viewController1 = [[ExercisesMainViewController alloc] initWithNibName:@"ExercisesMainViewController" bundle:nil];
    UINavigationController *navigationcontroller1 = [[UINavigationController alloc] initWithRootViewController:viewController1];
    
    UIViewController *viewController2 = [[HabitsActivationViewController alloc] initWithNibName:@"HabitsActivationViewController" bundle:nil];
    if (IS_HABITS_ACTIVATED) {
        viewController2 = [[HabitsViewController alloc] initWithNibName:@"HabitsViewController" bundle:nil];
    }
    UINavigationController *navigationcontroller2 = [[UINavigationController alloc] initWithRootViewController:viewController2];
    
    UIViewController *viewController3 = [[ExercisesListViewController alloc] initWithNibName:@"ExercisesListViewController" bundle:nil];
    UINavigationController *navigationcontroller3 = [[UINavigationController alloc] initWithRootViewController:viewController3];
    
    UIViewController *viewController4 = [[PerformanceViewController alloc] initWithNibName:@"PerformanceViewController" bundle:nil];
    UINavigationController *navigationcontroller4 = [[UINavigationController alloc] initWithRootViewController:viewController4];
    
    UIViewController *viewController5 = [[ProfileViewController alloc] initWithNibName:@"ProfileViewController" bundle:nil];
    UINavigationController *navigationcontroller5 = [[UINavigationController alloc] initWithRootViewController:viewController5];
    
    delegate.tabBarController.viewControllers = [NSArray arrayWithObjects:navigationcontroller1, navigationcontroller2, navigationcontroller3, navigationcontroller4, navigationcontroller5, nil];
    delegate.tabBarController.modalTransitionStyle = UIModalTransitionStyleCoverVertical;
    delegate.tabBarController.selectedIndex = initialIndex;
    
    UITabBar *tabBar = delegate.tabBarController.tabBar;
    [tabBar.subviews makeObjectsPerformSelector: @selector(removeFromSuperview)];// To insure that no background color for previous selected tab
    tabBar.tintColor = [[Colors sharedColors] lightBlueColor];
    tabBar.unselectedItemTintColor = [UIColor blackColor];
    
    UITabBarItem *tabBarItem1 = [tabBar.items objectAtIndex:0];
    UITabBarItem *tabBarItem2 = [tabBar.items objectAtIndex:1];
    UITabBarItem *tabBarItem3 = [tabBar.items objectAtIndex:2];
    UITabBarItem *tabBarItem4 = [tabBar.items objectAtIndex:3];
    UITabBarItem *tabBarItem5 = [tabBar.items objectAtIndex:4];
    
    UIImage *exerciseImg = [[UIImage imageNamed:@"exercise"] imageWithRenderingMode:UIImageRenderingModeAlwaysTemplate];
    UIImage *infinityImg = [[UIImage imageNamed:@"infinity"] imageWithRenderingMode:UIImageRenderingModeAlwaysTemplate];
    UIImage *listImg = [[UIImage imageNamed:@"list"] imageWithRenderingMode:UIImageRenderingModeAlwaysTemplate];
    UIImage *performanceImg = [[UIImage imageNamed:@"performance"] imageWithRenderingMode:UIImageRenderingModeAlwaysTemplate];
    UIImage *profileImg = [[UIImage imageNamed:@"profile"] imageWithRenderingMode:UIImageRenderingModeAlwaysTemplate];
    
    [tabBarItem1 setImage:exerciseImg];
    [tabBarItem1 setSelectedImage:exerciseImg];
    tabBarItem1.imageInsets = UIEdgeInsetsMake(6, 0, -6, 0);
    
    [tabBarItem2 setImage:infinityImg];
    [tabBarItem2 setSelectedImage:infinityImg];
    tabBarItem2.imageInsets = UIEdgeInsetsMake(6, 0, -6, 0);
    
    [tabBarItem3 setImage:listImg];
    [tabBarItem3 setSelectedImage:listImg];
    tabBarItem3.imageInsets = UIEdgeInsetsMake(6, 0, -6, 0);
    
    [tabBarItem4 setImage:performanceImg];
    [tabBarItem4 setSelectedImage:performanceImg];
    tabBarItem4.imageInsets = UIEdgeInsetsMake(6, 0, -6, 0);
    
    [tabBarItem5 setImage:profileImg];
    [tabBarItem5 setSelectedImage:profileImg];
    tabBarItem5.imageInsets = UIEdgeInsetsMake(6, 0, -6, 0);
    
    /*delegate.tabBarAnimationView = [[UIView alloc] initWithFrame:tabBar.bounds];
    [tabBar insertSubview:delegate.tabBarAnimationView atIndex:0];
    
    float tabBarItemWidth = CGRectGetWidth(tabBar.frame)/[tabBar.items count];
    delegate.selectedTabBarItemBackgroundView = [[UIView alloc] initWithFrame:CGRectMake(tabBarItemWidth * initialIndex, -3, tabBarItemWidth, 52)];
    delegate.selectedTabBarItemBackgroundView.backgroundColor = [[Colors sharedColors] blueColor];
    [delegate.tabBarAnimationView addSubview:delegate.selectedTabBarItemBackgroundView];*/
    
    [vc.navigationController pushViewController:delegate.tabBarController animated:YES];
}

- (void)saveToKeychainUsername:(NSString *)username andPassword:(NSString *)password{
    KeychainItemWrapper *keychainItem = [[KeychainItemWrapper alloc] initWithIdentifier:@"AppLogin" accessGroup:nil];
    
    [keychainItem setObject:password forKey:(__bridge id)kSecValueData];
    [keychainItem setObject:username forKey:(__bridge id)kSecAttrAccount];
}

- (NSString *)getSavedUsername{
    KeychainItemWrapper *keychainItem = [[KeychainItemWrapper alloc] initWithIdentifier:@"AppLogin" accessGroup:nil];
    NSString *username = [keychainItem objectForKey:(__bridge id)kSecAttrAccount];
    
    return username;
}

- (NSString *)getSavedUserPassword{
    KeychainItemWrapper *keychainItem = [[KeychainItemWrapper alloc] initWithIdentifier:@"AppLogin" accessGroup:nil];
    NSString *password = [keychainItem objectForKey:(__bridge id)kSecValueData];
    
    return password;
}

- (NSString *)authenticationToken{
    NSString *username = [self getSavedUsername];
    NSString *password = [self getSavedUserPassword];
    NSString *loginString = [NSString stringWithFormat:@"%@:%@", username, password];
    NSData *authData = [loginString dataUsingEncoding:NSUTF8StringEncoding];
    
    return [NSString stringWithFormat:@"Basic %@", [authData base64EncodedStringWithOptions:0]];
}

- (void)removeSavedUser{
    KeychainItemWrapper *keychainItem = [[KeychainItemWrapper alloc] initWithIdentifier:@"AppLogin" accessGroup:nil];
    [keychainItem resetKeychainItem];
}

- (void)emptySavedData{
    RLMRealm *realm = [RLMRealm defaultRealm];
    
    [realm beginWriteTransaction];
    [realm deleteObjects:[UserInfo allObjects]];
    [realm deleteObjects:[UserSummary allObjects]];
    [realm deleteObjects:[Modules allObjects]];
    [realm deleteObjects:[Exercises allObjects]];
    [realm deleteObjects:[ExercisesSummary allObjects]];
    [realm deleteObjects:[BookmarkedExercises allObjects]];
    [realm deleteObjects:[Habits allObjects]];
    [realm deleteObjects:[HabitsOverview allObjects]];
    [realm deleteObjects:[Gallery allObjects]];
    [realm deleteObjects:[FaqCategory allObjects]];
    [realm deleteObjects:[Faq allObjects]];
    [realm commitWriteTransaction];
    
    HABITS_ACTIVATED(FALSE)
    
}

- (int)currentYear{
    
    NSDate *date = [NSDate date];
    
    NSDateFormatter *dateFormatter = [[NSDateFormatter alloc] init];
    [dateFormatter setDateFormat:@"yyyy"];
    int currentYear = [[dateFormatter stringFromDate:date] intValue];
    
    return currentYear;
}

- (int)currentMonthIndex{
    
    NSDate *date = [NSDate date];
    
    NSDateFormatter *dateFormatter = [[NSDateFormatter alloc] init];
    [dateFormatter setDateFormat:@"MM"];
    int currentMonth = [[dateFormatter stringFromDate:date] intValue];
    
    return currentMonth;
}

- (BOOL) isHeadsUpHidden{
    NSLog(@"Heads up hidden? = %i", IS_HEADS_UP_HIDDEN_PERMANENTLY);
    //check if heads up is hidden permanently
    if(IS_HEADS_UP_HIDDEN_PERMANENTLY){
        return true;
    }
    
    NSDateFormatter *formatter = [[NSDateFormatter alloc] init];
    [formatter setDateFormat:@"yyyy-MM-dd"];
    
    NSString *currDate = [formatter stringFromDate:[NSDate date]];
    NSString *dateHidden = [formatter stringFromDate:DATE_HEADS_UP_HIDDEN];
    
    NSLog(@"Current Date = %@", currDate);
    NSLog(@"Date hidden = %@", dateHidden);
    NSLog(@"NSOrderedSame = %i", [currDate isEqualToString:dateHidden]);

    return [currDate isEqualToString:dateHidden];
}

-(BOOL)isForceRefresh{
    if(LAST_TIME_IN_BACKGROUND == NULL || LAST_TIME_IN_BACKGROUND == [NSNull null]){
        return false;
    }
    
    NSDate *currDate = [NSDate date];
    NSTimeInterval intervalInMins = [currDate timeIntervalSinceDate:LAST_TIME_IN_BACKGROUND] / 60;
    NSLog(@"=Curr Date = %@", [NSDate date]);
    NSLog(@"=Last time in Background = %@", LAST_TIME_IN_BACKGROUND);
    NSLog(@"Interval = %f", fabs(intervalInMins));
    
    return fabs(intervalInMins) >= 5 ? true : false;
}

- (NSString *)userTimeZone{
    double tz = [[NSTimeZone localTimeZone] secondsFromGMT] / 3600.0;
    return [NSString stringWithFormat:@"%g", tz];
}

-(void)playSoundName:(NSString *)soundName extension:(NSString *)extension{
    NSURL *soundFileURL = [[NSBundle mainBundle] URLForResource:soundName
                                                  withExtension:extension];
    audioPlayer = [[AVAudioPlayer alloc] initWithContentsOfURL:soundFileURL error:nil];
    [audioPlayer play];
}

-(NSAttributedString *)formatText:(NSString *)text{
    NSString *fontName = [[Fonts sharedFonts] normalFontName];
    int fontSize = [[Fonts sharedFonts] normalFontSize];
    
    NSString *htmlStr = [NSString stringWithFormat:@"<html>"
                         "<head>"
                            "<style>"
                                "body { font-family: %@; font-size: %ipx; line-height: %ipx }"
                            "</style>"
                        "</head>"
                         "<body>%@</body>"
                         "</html>",
                         fontName, fontSize, (fontSize+4), text];
    
    NSMutableAttributedString *attributedString = [[NSMutableAttributedString alloc] initWithData:[htmlStr dataUsingEncoding:NSUnicodeStringEncoding]
                                            options:@{ NSDocumentTypeDocumentAttribute: NSHTMLTextDocumentType }
                                 documentAttributes:nil
                                              error:nil];
    return attributedString;
}

- (NSURLSessionConfiguration *)sessionConfiguration{
    NSURLSessionConfiguration *sessionConfig = [NSURLSessionConfiguration defaultSessionConfiguration];
    sessionConfig.timeoutIntervalForRequest = 25.0;
    return sessionConfig;
}

- (NSError *)noInternetError{
    NSMutableDictionary* details = [NSMutableDictionary dictionary];
    [details setValue:@"No Internet Connection" forKey:NSLocalizedDescriptionKey];
    NSError *error = [NSError errorWithDomain:MainURL code:NoInternetErrorStatusCode userInfo:details];
    return error;
}
@end
