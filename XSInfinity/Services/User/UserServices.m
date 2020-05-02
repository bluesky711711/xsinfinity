//
//  UserServices.m
//  XSInfinity
//
//  Created by Joseph Marvin Magdadaro on 6/6/18.
//  Copyright © 2018 Joseph Marvin Magdadaro. All rights reserved.
//

#import "UserServices.h"
#import <AFNetworking/AFHTTPSessionManager.h>
#import <OneSignal/OneSignal.h>
#import "NetworkManager.h"
#import "UserModel.h"
#import "Helper.h"

static NSString * const LoginPostURL = @"api/v1/auth/login/";
static NSString * const CreateUserPreferencesPostURL = @"api/v1/user/preferences";
static NSString * const UserOverviewDetailURL = @"api/v1/user/";
static NSString * const CreateUserPostURL = @"api/v1/user/";
static NSString * const ActivationPutURL = @"api/v1/user/";
static NSString * const ForgotPasswordPutURL = @"api/v1/user/";
static NSString * const UpdateUserTimeZonePostURL = @"api/v1/user/preferences";
static NSString * const UpdatePasswordPatchURL = @"api/v1/user/updatepassword";
static NSString * const UpdateEmailPatchURL = @"api/v1/user/updateemailaddress";
static NSString * const TodaysHeadUpGetURL = @"api/v1/user/todayheadsup";
static NSString * const GalleryGetURL = @"api/v1/user/media";
static NSString * const UserInfoGetURL = @"api/v1/user/preferences";
static NSString * const UserPerformanceGetURL = @"api/v1/user/performance/summary";
static NSString * const UserCommunitySummaryGetURL = @"api/v1/user/community/summary";
static NSString * const RemoveUserDeleteURL = @"api/v1/user/";
static NSString * const UserPurchaseHistoryGetURL = @"api/v1/user/purchasedmodules";

static NSString * const CoachCreateUserPostURL = @"/api/v1/auth/register";
static NSString * const CoachForgotPasswordPostURL = @"/api/v1/auth/forgot-password";
static NSString * const CoachResetPasswordPostURL = @"/api/v1/auth/reset-password";

@implementation UserServices

+ (instancetype)sharedInstance
{
    static dispatch_once_t onceToken;
    static UserServices *sharedInstance;
    
    dispatch_once(&onceToken, ^{
        sharedInstance = [[self alloc] init];
    });
    
    return sharedInstance;
}

- (void) createUserPreferences:(NSDictionary *)params withCompletion: (void(^)(NSError *error,  int statusCode))completion{
    if([[NetworkManager sharedInstance] isConnectionOffline]){
        if( completion ){
            completion([[Helper sharedHelper] noInternetError], (int)[[Helper sharedHelper] noInternetError].code);
        }
        return;
    }
    
    NSString *urlString = [NSString stringWithFormat:@"%@%@",MainURL, CreateUserPreferencesPostURL];
    
    AFHTTPSessionManager *manager = [[AFHTTPSessionManager manager] initWithSessionConfiguration:[[Helper sharedHelper] sessionConfiguration]];
    manager.requestSerializer = [AFJSONRequestSerializer serializer];
    manager.responseSerializer = [AFHTTPResponseSerializer serializer];
    [manager.requestSerializer setValue:[[Helper sharedHelper] authenticationToken] forHTTPHeaderField:@"Authorization"];
    
    [manager POST:urlString parameters:params progress:nil success:^(NSURLSessionDataTask * _Nonnull task, id  _Nullable responseObject) {
        NSHTTPURLResponse *response = (NSHTTPURLResponse *) [task response];
        NSInteger statusCode = [response statusCode];
        NSLog(@"RESPONSE CODE: %li", (long)statusCode);
        
        if( completion ){
            completion(nil, (int)statusCode);
        }
    } failure:^(NSURLSessionDataTask * _Nullable task, NSError * _Nonnull error) {
        NSHTTPURLResponse *response = (NSHTTPURLResponse *) [task response];
        NSInteger statusCode = [response statusCode];
        NSLog(@"RESPONSE CODE: %li", (long)statusCode);
        
        if( completion ){
            if(response){
                completion(error, (int)statusCode);
            }else{
                completion(error, (int)error.code);
            }
        }
    }];
}

- (void) createUser:(NSDictionary *)param withCompletion: (void(^)(NSError *error,  int statusCode))completion{
    if([[NetworkManager sharedInstance] isConnectionOffline]){
        if( completion ){
            completion([[Helper sharedHelper] noInternetError], (int)[[Helper sharedHelper] noInternetError].code);
        }
        return;
    }
    
    NSString *urlString = [NSString stringWithFormat:@"%@%@",CoachMainURL, CoachCreateUserPostURL];
    
    AFHTTPSessionManager *manager = [[AFHTTPSessionManager manager] initWithSessionConfiguration:[[Helper sharedHelper] sessionConfiguration]];
    [manager.requestSerializer setValue:@"application/json" forHTTPHeaderField:@"Content-Type"];
    [manager.requestSerializer setValue:@"application/json" forHTTPHeaderField:@"Accept"];
    manager.requestSerializer = [AFJSONRequestSerializer serializer];
    manager.responseSerializer = [AFJSONResponseSerializer serializer];
    
    [manager POST:urlString parameters:param progress:nil success:^(NSURLSessionDataTask * _Nonnull task, id  _Nullable responseObject) {
        NSHTTPURLResponse *response = (NSHTTPURLResponse *) [task response];
        NSInteger statusCode = [response statusCode];
        NSLog(@"RESPONSE CODE: %li", (long)statusCode);
        
        //save token
        [[UserModel sharedInstance] saveUserToken:responseObject[@"access_token"]];
        
        if( completion ){
            completion(nil, (int)statusCode);
        }
    } failure:^(NSURLSessionDataTask * _Nullable task, NSError * _Nonnull error) {
        NSHTTPURLResponse *response = (NSHTTPURLResponse *) [task response];
        NSInteger statusCode = [response statusCode];
        NSLog(@"RESPONSE CODE: %li", (long)statusCode);
        
        if( completion ){
            if(response){
                completion(error, (int)statusCode);
            }else{
                completion(error, (int)error.code);
            }
        }
    }];
}

- (void) updateUserTimeZone:(NSString *)timezone withCompletion: (void(^)(NSError *error,  int statusCode))completion{
    if([[NetworkManager sharedInstance] isConnectionOffline]){
        if( completion ){
            completion([[Helper sharedHelper] noInternetError], (int)[[Helper sharedHelper] noInternetError].code);
        }
        return;
    }
    
    NSString *urlString = [NSString stringWithFormat:@"%@%@",MainURL, UpdateUserTimeZonePostURL];
    NSDictionary *params = @{@"newPreferences": @[@{@"name":@"user.timeZone", @"value":timezone}]};
    
    AFHTTPSessionManager *manager = [[AFHTTPSessionManager manager] initWithSessionConfiguration:[[Helper sharedHelper] sessionConfiguration]];
    manager.requestSerializer = [AFJSONRequestSerializer serializer];
    manager.responseSerializer = [AFHTTPResponseSerializer serializer];
    [manager.requestSerializer setValue:[[UserModel sharedInstance] accessToken] forHTTPHeaderField:@"jwt"];
    
    [manager POST:urlString parameters:params progress:nil success:^(NSURLSessionDataTask * _Nonnull task, id  _Nullable responseObject) {
        NSHTTPURLResponse *response = (NSHTTPURLResponse *) [task response];
        NSInteger statusCode = [response statusCode];
        NSLog(@"RESPONSE CODE: %li", (long)statusCode);
        
        if( completion ){
            completion(nil, (int)statusCode);
        }
    } failure:^(NSURLSessionDataTask * _Nullable task, NSError * _Nonnull error) {
        NSHTTPURLResponse *response = (NSHTTPURLResponse *) [task response];
        NSInteger statusCode = [response statusCode];
        NSLog(@"RESPONSE CODE: %li", (long)statusCode);
        
        if( completion ){
            if(response){
                completion(error, (int)statusCode);
            }else{
                completion(error, (int)error.code);
            }
        }
    }];
}

- (void) signInWithUsername:(NSString *)username andPassword:(NSString *)password withCompletion: (void(^)(NSError *error,  int statusCode, NSDictionary *overview))completion{
    if([[NetworkManager sharedInstance] isConnectionOffline]){
        if( completion ){
            completion([[Helper sharedHelper] noInternetError], (int)[[Helper sharedHelper] noInternetError].code, nil);
        }
        return;
    }
    
    NSString *urlString = [NSString stringWithFormat:@"%@%@",CoachMainURL, LoginPostURL];
    NSDictionary *params = @{@"email":username, @"password": password};
    
    AFHTTPSessionManager *manager = [[AFHTTPSessionManager manager] initWithSessionConfiguration:[[Helper sharedHelper] sessionConfiguration]];
    [manager.requestSerializer setValue:@"application/json" forHTTPHeaderField:@"Content-Type"];//
    [manager.requestSerializer setValue:@"application/json" forHTTPHeaderField:@"Accept"];//
    manager.requestSerializer = [AFJSONRequestSerializer serializer];
    manager.responseSerializer = [AFJSONResponseSerializer serializer];
    
    [manager POST:urlString parameters:params progress:nil success:^(NSURLSessionDataTask * _Nonnull task, id  _Nullable responseObject) {
        NSHTTPURLResponse *response = (NSHTTPURLResponse *) [task response];
        NSInteger statusCode = [response statusCode];
        NSLog(@"RESPONSE CODE: %li", (long)statusCode);
        
        NSDictionary *userOverview = nil;
        if([responseObject isKindOfClass:[NSArray class]]){
            userOverview = [[responseObject mutableCopy] firstObject];
        }else{
            userOverview = responseObject;
        }
        
        //save token
        [[UserModel sharedInstance] saveUserToken:userOverview[@"access_token"]];
        
        FINISH_ONBOARDING(true);
        //SET_USER_ID(userOverview[@"identifier"])
        SET_USER_ID(userOverview[@"id"])
        SET_DATE_USER_REGISTERED(userOverview[@"creationDate"])
        HABITS_ACTIVATED([userOverview[@"habitStatus"] boolValue])
        [OneSignal sendTag:@"user_id" value:USER_ID];
        
        //update user time zone
        dispatch_async(dispatch_get_global_queue(DISPATCH_QUEUE_PRIORITY_DEFAULT, 0), ^{
            [self updateUserTimeZone:[[Helper sharedHelper] userTimeZone] withCompletion:nil];
        });
        
        if( completion ){
            completion(nil, (int)statusCode, userOverview);
        }
    } failure:^(NSURLSessionDataTask * _Nullable task, NSError * _Nonnull error) {
        NSHTTPURLResponse *response = (NSHTTPURLResponse *) [task response];
        NSInteger statusCode = [response statusCode];
        NSLog(@"RESPONSE CODE: %li", (long)statusCode);
        
        if( completion ){
            if(response){
                completion(error, (int)statusCode, nil);
            }else{
                completion(error, (int)error.code, nil);
            }
        }
    }];
}

- (void) sendActivationMailToUser:(NSString *)username withCompletion: (void(^)(NSError *error,  int statusCode))completion{
    if([[NetworkManager sharedInstance] isConnectionOffline]){
        if( completion ){
            completion([[Helper sharedHelper] noInternetError], (int)[[Helper sharedHelper] noInternetError].code);
        }
        return;
    }
    
    NSString *urlString = [NSString stringWithFormat:@"%@%@%@/sendActivationMail",MainURL, ActivationPutURL, username];
    
    AFHTTPSessionManager *manager = [[AFHTTPSessionManager manager] initWithSessionConfiguration:[[Helper sharedHelper] sessionConfiguration]];
    manager.requestSerializer = [AFJSONRequestSerializer serializer];
    manager.responseSerializer = [AFHTTPResponseSerializer serializer];
    [manager PUT:urlString parameters:nil success:^(NSURLSessionDataTask * _Nonnull task, id  _Nullable responseObject) {
        NSHTTPURLResponse *response = (NSHTTPURLResponse *) [task response];
        NSInteger statusCode = [response statusCode];
        NSLog(@"RESPONSE CODE: %li", (long)statusCode);
        
        if( completion ){
            completion(nil, (int)statusCode);
        }
    } failure:^(NSURLSessionDataTask * _Nullable task, NSError * _Nonnull error) {
        NSHTTPURLResponse *response = (NSHTTPURLResponse *) [task response];
        NSInteger statusCode = [response statusCode];
        NSLog(@"RESPONSE CODE: %li", (long)statusCode);
        
        if( completion ){
            if(response){
                completion(error, (int)statusCode);
            }else{
                completion(error, (int)error.code);
            }
        }
    }];

}

- (void) activateUser:(NSString *)username withCode:(NSString *)code withCompletion: (void(^)(NSError *error,  int statusCode))completion{
    if([[NetworkManager sharedInstance] isConnectionOffline]){
        if( completion ){
            completion([[Helper sharedHelper] noInternetError], (int)[[Helper sharedHelper] noInternetError].code);
        }
        return;
    }
    
    NSString *urlString = [NSString stringWithFormat:@"%@%@%@/activate/%@",MainURL, ActivationPutURL, username, code];
    
    AFHTTPSessionManager *manager = [[AFHTTPSessionManager manager] initWithSessionConfiguration:[[Helper sharedHelper] sessionConfiguration]];
    manager.requestSerializer = [AFJSONRequestSerializer serializer];
    manager.responseSerializer = [AFHTTPResponseSerializer serializer];
    [manager PUT:urlString parameters:nil success:^(NSURLSessionDataTask * _Nonnull task, id  _Nullable responseObject) {
        NSHTTPURLResponse *response = (NSHTTPURLResponse *) [task response];
        NSInteger statusCode = [response statusCode];
        NSLog(@"RESPONSE CODE: %li", (long)statusCode);
        
        if( completion ){
            completion(nil, (int)statusCode);
        }
    } failure:^(NSURLSessionDataTask * _Nullable task, NSError * _Nonnull error) {
        NSHTTPURLResponse *response = (NSHTTPURLResponse *) [task response];
        NSInteger statusCode = [response statusCode];
        NSLog(@"RESPONSE CODE: %li", (long)statusCode);
        
        if( completion ){
            if(response){
                completion(error, (int)statusCode);
            }else{
                completion(error, (int)error.code);
            }
        }
    }];
    
}

- (void) sendForgotMailToUser:(NSString *)email withCompletion: (void(^)(NSError *error,  int statusCode))completion{
    if([[NetworkManager sharedInstance] isConnectionOffline]){
        if( completion ){
            completion([[Helper sharedHelper] noInternetError], (int)[[Helper sharedHelper] noInternetError].code);
        }
        return;
    }
    
    //NSString *urlString = [NSString stringWithFormat:@"%@%@%@/sendPasswordForgotMail",MainURL, ForgotPasswordPutURL, username];
    NSString *urlString = [NSString stringWithFormat:@"%@%@",CoachMainURL, CoachForgotPasswordPostURL];
    
    AFHTTPSessionManager *manager = [[AFHTTPSessionManager manager] initWithSessionConfiguration:[[Helper sharedHelper] sessionConfiguration]];
    [manager.requestSerializer setValue:@"application/json" forHTTPHeaderField:@"Content-Type"];//
    [manager.requestSerializer setValue:@"application/json" forHTTPHeaderField:@"Accept"];//
    manager.requestSerializer = [AFJSONRequestSerializer serializer];
    manager.responseSerializer = [AFJSONResponseSerializer serializer];//
    
    [manager PUT:urlString parameters:@{@"email": email} success:^(NSURLSessionDataTask * _Nonnull task, id  _Nullable responseObject) {
        NSHTTPURLResponse *response = (NSHTTPURLResponse *) [task response];
        NSInteger statusCode = [response statusCode];
        NSLog(@"RESPONSE CODE: %li", (long)statusCode);
        
        if( completion ){
            completion(nil, (int)statusCode);
        }
    } failure:^(NSURLSessionDataTask * _Nullable task, NSError * _Nonnull error) {
        NSHTTPURLResponse *response = (NSHTTPURLResponse *) [task response];
        NSInteger statusCode = [response statusCode];
        NSLog(@"RESPONSE CODE: %li", (long)statusCode);
        
        if( completion ){
            if(response){
                completion(error, (int)statusCode);
            }else{
                completion(error, (int)error.code);
            }
        }
    }];
}

//reset password
- (void) setNewPassword:(NSString *)newPassword forUser:(NSString *)username withCode:(NSString *)code withCompletion: (void(^)(NSError *error,  int statusCode))completion{
    if([[NetworkManager sharedInstance] isConnectionOffline]){
        if( completion ){
            completion([[Helper sharedHelper] noInternetError], (int)[[Helper sharedHelper] noInternetError].code);
        }
        return;
    }
    
    NSString *urlString = [NSString stringWithFormat:@"%@%@%@/setNewPassword/%@",MainURL, ForgotPasswordPutURL, username, code];
    
    NSDictionary *param = @{@"newPassword": newPassword};
    
    AFHTTPSessionManager *manager = [[AFHTTPSessionManager manager] initWithSessionConfiguration:[[Helper sharedHelper] sessionConfiguration]];
    manager.requestSerializer = [AFJSONRequestSerializer serializer];
    manager.responseSerializer = [AFHTTPResponseSerializer serializer];
    [manager PUT:urlString parameters:param success:^(NSURLSessionDataTask * _Nonnull task, id  _Nullable responseObject) {
        NSHTTPURLResponse *response = (NSHTTPURLResponse *) [task response];
        NSInteger statusCode = [response statusCode];
        NSLog(@"RESPONSE CODE: %li", (long)statusCode);
        
        if( completion ){
            completion(nil, (int)statusCode);
        }
    } failure:^(NSURLSessionDataTask * _Nullable task, NSError * _Nonnull error) {
        NSHTTPURLResponse *response = (NSHTTPURLResponse *) [task response];
        NSInteger statusCode = [response statusCode];
        NSLog(@"RESPONSE CODE: %li", (long)statusCode);
        
        if( completion ){
            if(response){
                completion(error, (int)statusCode);
            }else{
                completion(error, (int)error.code);
            }
        }
    }];
}

- (void) updatePassword:(NSString *)newPassword withCompletion: (void(^)(NSError *error,  int statusCode))completion{
    if([[NetworkManager sharedInstance] isConnectionOffline]){
        if(completion){
            completion([[Helper sharedHelper] noInternetError], (int)[[Helper sharedHelper] noInternetError].code);
        }
        return;
    }
    
    NSString *urlString = [NSString stringWithFormat:@"%@%@",MainURL, UpdatePasswordPatchURL];
    NSDictionary *param = @{@"newPassword": newPassword};
    
    AFHTTPSessionManager *manager = [[AFHTTPSessionManager manager] initWithSessionConfiguration:[[Helper sharedHelper] sessionConfiguration]];
    [manager.requestSerializer setValue:[[Helper sharedHelper] authenticationToken] forHTTPHeaderField:@"Authorization"];
    
    [manager PATCH:urlString parameters:param success:^(NSURLSessionDataTask * _Nonnull task, id  _Nullable responseObject) {
        NSHTTPURLResponse *response = (NSHTTPURLResponse *) [task response];
        NSInteger statusCode = [response statusCode];
        NSLog(@"RESPONSE CODE: %li", (long)statusCode);
        
        if(statusCode == 201){
            Helper *helper = [Helper sharedHelper];
            [helper saveToKeychainUsername:[helper getSavedUsername] andPassword:newPassword];
        }
        
        if( completion ){
            completion(nil, (int)statusCode);
        }
    } failure:^(NSURLSessionDataTask * _Nullable task, NSError * _Nonnull error) {
        NSHTTPURLResponse *response = (NSHTTPURLResponse *) [task response];
        NSInteger statusCode = [response statusCode];
        NSLog(@"RESPONSE CODE: %li", (long)statusCode);
        
        //for some reason success code went here
        if(statusCode == 201){
            Helper *helper = [Helper sharedHelper];
            [helper saveToKeychainUsername:[helper getSavedUsername] andPassword:newPassword];
        }
        
        if( completion ){
            if(response){
                completion(error, (int)statusCode);
            }else{
                completion(error, (int)error.code);
            }
        }
    }];
}

- (void) updateEmail:(NSString *)newEmail withCompletion: (void(^)(NSError *error,  int statusCode))completion{
    if([[NetworkManager sharedInstance] isConnectionOffline]){
        if(completion){
            completion([[Helper sharedHelper] noInternetError], (int)[[Helper sharedHelper] noInternetError].code);
        }
        return;
    }
    
    NSString *urlString = [NSString stringWithFormat:@"%@%@",MainURL, UpdateEmailPatchURL];
    NSDictionary *param = @{@"newEmailAddress": newEmail};
    
    AFHTTPSessionManager *manager = [[AFHTTPSessionManager manager] initWithSessionConfiguration:[[Helper sharedHelper] sessionConfiguration]];
    [manager.requestSerializer setValue:[[Helper sharedHelper] authenticationToken] forHTTPHeaderField:@"Authorization"];
    
    [manager PATCH:urlString parameters:param success:^(NSURLSessionDataTask * _Nonnull task, id  _Nullable responseObject) {
        NSHTTPURLResponse *response = (NSHTTPURLResponse *) [task response];
        NSInteger statusCode = [response statusCode];
        NSLog(@"RESPONSE CODE: %li", (long)statusCode);
        
        if(statusCode == 201){
            Helper *helper = [Helper sharedHelper];
            [helper saveToKeychainUsername:newEmail andPassword:[helper getSavedUserPassword]];
        }
        
        if( completion ){
            completion(nil, (int)statusCode);
        }
    } failure:^(NSURLSessionDataTask * _Nullable task, NSError * _Nonnull error) {
        NSHTTPURLResponse *response = (NSHTTPURLResponse *) [task response];
        NSInteger statusCode = [response statusCode];
        NSLog(@"RESPONSE CODE: %li", (long)statusCode);
        
        if(statusCode == 201){
            Helper *helper = [Helper sharedHelper];
            [helper saveToKeychainUsername:newEmail andPassword:[helper getSavedUserPassword]];
        }
        
        if( completion ){
            if(response){
                completion(error, (int)statusCode);
            }else{
                completion(error, (int)error.code);
            }
        }
    }];
}

- (void) getTodaysHeadUpWithCompletion: (void(^)(NSError *error, int statusCode, HeadUpObj *headUp))completion{
    if([[NetworkManager sharedInstance] isConnectionOffline]){
        if(completion){
            completion([[Helper sharedHelper] noInternetError], (int)[[Helper sharedHelper] noInternetError].code, nil);
        }
        return;
    }
    
    NSString *urlString = [NSString stringWithFormat:@"%@%@",MainURL, TodaysHeadUpGetURL];
    
    AFHTTPSessionManager *manager = [[AFHTTPSessionManager manager] initWithSessionConfiguration:[[Helper sharedHelper] sessionConfiguration]];
    [manager.requestSerializer setValue:[[UserModel sharedInstance] accessToken] forHTTPHeaderField:@"jwt"];
    [manager GET:urlString parameters:nil progress:nil success:^(NSURLSessionDataTask * _Nonnull task, id  _Nullable responseObject) {
        
        NSHTTPURLResponse *response = (NSHTTPURLResponse *) [task response];
        NSInteger statusCode = [response statusCode];
        NSLog(@"RESPONSE CODE: %li", (long)statusCode);
        
        if( completion ){
            HeadUpObj *headUp = [[UserModel sharedInstance] getTodaysHeadUpFromJson:responseObject];
            completion(nil, (int)statusCode, headUp);
        }
    } failure:^(NSURLSessionDataTask * _Nullable task, NSError * _Nonnull error) {
        
        NSHTTPURLResponse *response = (NSHTTPURLResponse *) [task response];
        NSInteger statusCode = [response statusCode];
        NSLog(@"RESPONSE CODE: %li", (long)statusCode);
        
        if( completion ){
            if(response){
                completion(error, (int)statusCode, nil);
            }else{
                completion(error, (int)error.code, nil);
            }
        }
    }];
    
}

- (void) getUsersGalleryWithCompletion: (void(^)(NSError *error,  int statusCode))completion{
    if([[NetworkManager sharedInstance] isConnectionOffline]){
        if(completion){
            completion([[Helper sharedHelper] noInternetError], (int)[[Helper sharedHelper] noInternetError].code);
        }
        return;
    }
    
    NSString *urlString = [NSString stringWithFormat:@"%@%@",MainURL, GalleryGetURL];
    
    AFHTTPSessionManager *manager = [[AFHTTPSessionManager manager] initWithSessionConfiguration:[[Helper sharedHelper] sessionConfiguration]];
    [manager.requestSerializer setValue:[[UserModel sharedInstance] accessToken] forHTTPHeaderField:@"jwt"];
    
    [manager GET:urlString parameters:nil progress:nil success:^(NSURLSessionDataTask * _Nonnull task, id  _Nullable responseObject) {
        NSHTTPURLResponse *response = (NSHTTPURLResponse *) [task response];
        NSInteger statusCode = [response statusCode];
        NSLog(@"RESPONSE CODE: %li", (long)statusCode);
        
        if( completion ){
            [[UserModel sharedInstance] saveGallery:responseObject];
            completion(nil, (int)statusCode);
        }
    } failure:^(NSURLSessionDataTask * _Nullable task, NSError * _Nonnull error) {
        NSHTTPURLResponse *response = (NSHTTPURLResponse *) [task response];
        NSInteger statusCode = [response statusCode];
        NSLog(@"RESPONSE CODE: %li", (long)statusCode);
        
        if( completion ){
            if(response){
                completion(error, (int)statusCode);
            }else{
                completion(error, (int)error.code);
            }
        }
    }];
    
}

- (void) getUserOverviewWithCompletion: (void(^)(NSError *error,  NSDictionary *overview))completion{
    if([[NetworkManager sharedInstance] isConnectionOffline]){
        if(completion){
            completion([[Helper sharedHelper] noInternetError], nil);
        }
        return;
    }
    
    NSString *urlString = [NSString stringWithFormat:@"%@%@",MainURL, UserOverviewDetailURL];
    
    AFHTTPSessionManager *manager = [AFHTTPSessionManager manager];
    [manager.requestSerializer setValue:[[UserModel sharedInstance] accessToken] forHTTPHeaderField:@"jwt"];
    
    [manager GET:urlString parameters:nil progress:nil success:^(NSURLSessionDataTask * _Nonnull task, id  _Nullable responseObject) {
        NSHTTPURLResponse *response = (NSHTTPURLResponse *) [task response];
        NSInteger statusCode = [response statusCode];
        NSLog(@"RESPONSE CODE: %li", (long)statusCode);
        
        NSDictionary *userOverview = nil;
        if([responseObject isKindOfClass:[NSArray class]]){
            userOverview = [[responseObject mutableCopy] firstObject];
        }else{
            userOverview = responseObject;
        }
        
        if( completion ){
            completion(nil, userOverview);
        }
    } failure:^(NSURLSessionDataTask * _Nullable task, NSError * _Nonnull error) {
        NSHTTPURLResponse *response = (NSHTTPURLResponse *) [task response];
        NSInteger statusCode = [response statusCode];
        NSLog(@"RESPONSE CODE: %li", (long)statusCode);
        
        if( completion ){
            if(response){
                completion(error, nil);
            }else{
                completion(error, nil);
            }
        }
    }];
}

- (void) getUserInfoWithCompletion: (void(^)(NSError *error,  int statusCode))completion{
    if([[NetworkManager sharedInstance] isConnectionOffline]){
        if(completion){
            completion([[Helper sharedHelper] noInternetError], (int)[[Helper sharedHelper] noInternetError].code);
        }
        return;
    }
    
    NSString *urlString = [NSString stringWithFormat:@"%@%@",MainURL, UserInfoGetURL];
    
    AFHTTPSessionManager *manager = [[AFHTTPSessionManager manager] initWithSessionConfiguration:[[Helper sharedHelper] sessionConfiguration]];
    [manager.requestSerializer setValue:[[UserModel sharedInstance] accessToken] forHTTPHeaderField:@"jwt"];
    
    [manager GET:urlString parameters:nil progress:nil success:^(NSURLSessionDataTask * _Nonnull task, id  _Nullable responseObject) {
        NSHTTPURLResponse *response = (NSHTTPURLResponse *) [task response];
        NSInteger statusCode = [response statusCode];
        NSLog(@"RESPONSE CODE: %li", (long)statusCode);
        
        [[UserModel sharedInstance] saveUserInfo:responseObject];
        
        if( completion ){
            completion(nil, (int)statusCode);
        }
    } failure:^(NSURLSessionDataTask * _Nullable task, NSError * _Nonnull error) {
        NSHTTPURLResponse *response = (NSHTTPURLResponse *) [task response];
        NSInteger statusCode = [response statusCode];
        NSLog(@"RESPONSE CODE: %li", (long)statusCode);
        
        if( completion ){
            if(response){
                completion(error, (int)statusCode);
            }else{
                completion(error, (int)error.code);
            }
        }
    }];
}

- (void) getUserCommunitySummaryWithCompletion: (void(^)(NSError *error,  int statusCode))completion{
    if([[NetworkManager sharedInstance] isConnectionOffline]){
        if(completion){
            completion([[Helper sharedHelper] noInternetError], (int)[[Helper sharedHelper] noInternetError].code);
        }
        return;
    }
    
    NSString *urlString = [NSString stringWithFormat:@"%@%@",MainURL, UserCommunitySummaryGetURL];
    
    AFHTTPSessionManager *manager = [[AFHTTPSessionManager manager] initWithSessionConfiguration:[[Helper sharedHelper] sessionConfiguration]];
    [manager.requestSerializer setValue:[[UserModel sharedInstance] accessToken] forHTTPHeaderField:@"jwt"];
    
    [manager GET:urlString parameters:nil progress:nil success:^(NSURLSessionDataTask * _Nonnull task, id  _Nullable responseObject) {
        NSHTTPURLResponse *response = (NSHTTPURLResponse *) [task response];
        NSInteger statusCode = [response statusCode];
        NSLog(@"RESPONSE CODE: %li", (long)statusCode);
        
        if( completion ){
            [[UserModel sharedInstance] saveUserCommunitySummary:responseObject];
            completion(nil, (int)statusCode);
        }
    } failure:^(NSURLSessionDataTask * _Nullable task, NSError * _Nonnull error) {
        NSHTTPURLResponse *response = (NSHTTPURLResponse *) [task response];
        NSInteger statusCode = [response statusCode];
        NSLog(@"RESPONSE CODE: %li", (long)statusCode);
        
        if( completion ){
            if(response){
                completion(error, (int)statusCode);
            }else{
                completion(error, (int)error.code);
            }
        }
    }];
}

- (void) getUserPerformanceWithStartDate:(NSDate *)sDate endDate:(NSDate *)eDate completion: (void(^)(NSError *error,  int statusCode))completion{
    if([[NetworkManager sharedInstance] isConnectionOffline]){
        if(completion){
            completion([[Helper sharedHelper] noInternetError], (int)[[Helper sharedHelper] noInternetError].code);
        }
        return;
    }
    
    NSDateFormatter *dateFormat = [[NSDateFormatter alloc] init];
    [dateFormat setDateFormat:@"yyyy-MM-dd"];
    NSString *startDate = [dateFormat stringFromDate:sDate];
    NSString *endDate = [dateFormat stringFromDate:eDate];
    
    NSString *urlString = [NSString stringWithFormat:@"%@%@?startDate=%@&endDate=%@",MainURL, UserPerformanceGetURL, startDate, endDate];
    
    AFHTTPSessionManager *manager = [[AFHTTPSessionManager manager] initWithSessionConfiguration:[[Helper sharedHelper] sessionConfiguration]];
    [manager.requestSerializer setValue:[[UserModel sharedInstance] accessToken] forHTTPHeaderField:@"jwt"];
    
    [manager GET:urlString parameters:nil progress:nil success:^(NSURLSessionDataTask * _Nonnull task, id  _Nullable responseObject) {
        NSHTTPURLResponse *response = (NSHTTPURLResponse *) [task response];
        NSInteger statusCode = [response statusCode];
        NSLog(@"RESPONSE CODE: %li", (long)statusCode);
        
        if( completion ){
            [[UserModel sharedInstance] saveUserPerformance:responseObject];
            completion(nil, (int)statusCode);
        }
    } failure:^(NSURLSessionDataTask * _Nullable task, NSError * _Nonnull error) {
        NSHTTPURLResponse *response = (NSHTTPURLResponse *) [task response];
        NSInteger statusCode = [response statusCode];
        NSLog(@"RESPONSE CODE: %li", (long)statusCode);
        
        if( completion ){
            if(response){
                completion(error, (int)statusCode);
            }else{
                completion(error, (int)error.code);
            }
        }
    }];
    
}

- (void) deleteAccountWithCompletion: (void(^)(NSError *error,  int statusCode))completion{
    if([[NetworkManager sharedInstance] isConnectionOffline]){
        if( completion ){
            completion([[Helper sharedHelper] noInternetError], (int)[[Helper sharedHelper] noInternetError].code);
        }
        return;
    }
    
    NSString *urlString = [NSString stringWithFormat:@"%@%@",MainURL, RemoveUserDeleteURL];
    
    AFHTTPSessionManager *manager = [[AFHTTPSessionManager manager] initWithSessionConfiguration:[[Helper sharedHelper] sessionConfiguration]];
    [manager.requestSerializer setValue:[[UserModel sharedInstance] accessToken] forHTTPHeaderField:@"jwt"];
    //manager.requestSerializer = [AFJSONRequestSerializer serializer];
    //manager.responseSerializer = [AFHTTPResponseSerializer serializer];
    [manager DELETE:urlString parameters:nil success:^(NSURLSessionDataTask * _Nonnull task, id  _Nullable responseObject) {
        NSHTTPURLResponse *response = (NSHTTPURLResponse *) [task response];
        NSInteger statusCode = [response statusCode];
        NSLog(@"RESPONSE CODE: %li", (long)statusCode);
        
        if( completion ){
            completion(nil, (int)statusCode);
        }
    } failure:^(NSURLSessionDataTask * _Nullable task, NSError * _Nonnull error) {
        NSHTTPURLResponse *response = (NSHTTPURLResponse *) [task response];
        NSInteger statusCode = [response statusCode];
        NSLog(@"RESPONSE CODE: %li", (long)statusCode);
        
        if( completion ){
            if(response){
                completion(error, (int)statusCode);
            }else{
                completion(error, (int)error.code);
            }
        }
    }];
}

- (void) getpurchasedModuleHistoryWithCompletion: (void(^)(NSError *error, int statusCode, NSArray *purchasedModules))completion{
    if([[NetworkManager sharedInstance] isConnectionOffline]){
        if(completion){
            completion([[Helper sharedHelper] noInternetError], (int)[[Helper sharedHelper] noInternetError].code, nil);
        }
        return;
    }
    
    NSString *urlString = [NSString stringWithFormat:@"%@%@",MainURL, UserPurchaseHistoryGetURL];
    
    AFHTTPSessionManager *manager = [[AFHTTPSessionManager manager] initWithSessionConfiguration:[[Helper sharedHelper] sessionConfiguration]];
    [manager.requestSerializer setValue:[[UserModel sharedInstance] accessToken] forHTTPHeaderField:@"jwt"];
    
    [manager GET:urlString parameters:nil progress:nil success:^(NSURLSessionDataTask * _Nonnull task, id  _Nullable responseObject) {
        NSHTTPURLResponse *response = (NSHTTPURLResponse *) [task response];
        NSInteger statusCode = [response statusCode];
        NSLog(@"RESPONSE CODE: %li", (long)statusCode);
        
        if( completion ){
            NSArray *purchasedModules = [[UserModel sharedInstance] getUserPurchaseHistoryFromJson:responseObject];
            completion(nil, (int)statusCode, purchasedModules);
        }
    } failure:^(NSURLSessionDataTask * _Nullable task, NSError * _Nonnull error) {
        NSHTTPURLResponse *response = (NSHTTPURLResponse *) [task response];
        NSInteger statusCode = [response statusCode];
        NSLog(@"RESPONSE CODE: %li", (long)statusCode);
        
        if( completion ){
            if(response){
                completion(error, (int)statusCode, nil);
            }else{
                completion(error, (int)error.code, nil);
            }
        }
    }];
}

@end
