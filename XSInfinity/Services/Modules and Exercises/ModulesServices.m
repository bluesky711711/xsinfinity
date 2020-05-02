//
//  ModulesServices.m
//  XSInfinity
//
//  Created by Joseph Marvin Magdadaro on 6/14/18.
//  Copyright © 2018 Joseph Marvin Magdadaro. All rights reserved.
//

#import "ModulesServices.h"
#import <AFNetworking/AFHTTPSessionManager.h>
#import "NetworkManager.h"
#import "ModulesModel.h"
#import "ExerciseSummaryObj.h"
#import "Helper.h"
#import "UserModel.h"

static NSString * const ExercisesSummaryGetURL = @"api/v1/user/exercises/overview";
static NSString * const AllModulesWithExercisesGetURL = @"api/v1/user/modulesinformation/withExercises";
static NSString * const UnlockedExercisesGetURL = @"api/v1/user/exercises";
static NSString * const RandomExerciseGetURL = @"api/v1/user/exercises/random";
static NSString * const ExercisesListGetURL = @"api/v1/user/exercises/search";
static NSString * const AllAvailableExercisesGetURL = @"api/v1/user/exercises";
static NSString * const AddExerciseRatingPostURL = @"api/v1/user/exercises";
static NSString * const BookmarkedExercisesURL = @"api/v1/user/bookmarks";
static NSString * const ExercisesHistoryGetURL = @"api/v1/user/history/exercises";
static NSString * const FocusAreaGetURL = @"api/v1/focusAreas";
static NSString * const TagsGetURL = @"api/v1/tags";
static NSString * const PaymentURL = @"api/v1/payment/kiwifast";

@implementation ModulesServices

+ (instancetype)sharedInstance
{
    static dispatch_once_t onceToken;
    static ModulesServices *sharedInstance;
    
    dispatch_once(&onceToken, ^{
        sharedInstance = [[self alloc] init];
    });
    
    return sharedInstance;
}

- (void) getExercisesSummaryWithCompletion: (void(^)(NSError *error, int statusCode))completion{
    if([[NetworkManager sharedInstance] isConnectionOffline]){
        if(completion){
            completion([[Helper sharedHelper] noInternetError], (int)[[Helper sharedHelper] noInternetError].code);
        }
        return;
    }
    
    NSString *urlString = [NSString stringWithFormat:@"%@%@",MainURL, ExercisesSummaryGetURL];
    
    AFHTTPSessionManager *manager = [[AFHTTPSessionManager manager] initWithSessionConfiguration:[[Helper sharedHelper] sessionConfiguration]];
    //[manager.requestSerializer setValue:[[Helper sharedHelper] authenticationToken] forHTTPHeaderField:@"Authorization"];
    [manager.requestSerializer setValue:[[UserModel sharedInstance] accessToken] forHTTPHeaderField:@"jwt"];
    
    [manager GET:urlString parameters:nil progress:nil success:^(NSURLSessionDataTask * _Nonnull task, id  _Nullable responseObject) {
        NSHTTPURLResponse *response = (NSHTTPURLResponse *) [task response];
        NSInteger statusCode = [response statusCode];
        NSLog(@"RESPONSE CODE: %li", (long)statusCode);
        
        if( completion ){
            [[ModulesModel sharedInstance] saveExercisesSummary:responseObject];
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

- (void) getAllModulesWithExercisesWithCompletion: (void(^)(NSError *error, int statusCode))completion{
    if([[NetworkManager sharedInstance] isConnectionOffline]){
        if(completion){
            completion([[Helper sharedHelper] noInternetError], (int)[[Helper sharedHelper] noInternetError].code);
        }
        return;
    }
    
    NSString *urlString = [NSString stringWithFormat:@"%@%@",MainURL, AllModulesWithExercisesGetURL];
    
    AFHTTPSessionManager *manager = [[AFHTTPSessionManager manager] initWithSessionConfiguration:[[Helper sharedHelper] sessionConfiguration]];
    [manager.requestSerializer setValue:[[UserModel sharedInstance] accessToken] forHTTPHeaderField:@"jwt"];

    [manager GET:urlString parameters:nil progress:nil success:^(NSURLSessionDataTask * _Nonnull task, id  _Nullable responseObject) {
        NSHTTPURLResponse *response = (NSHTTPURLResponse *) [task response];
        NSInteger statusCode = [response statusCode];
        NSLog(@"RESPONSE CODE: %li", (long)statusCode);
        
        if( completion ){
            [[ModulesModel sharedInstance] saveModules:responseObject];
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

- (void) getUnlockedExercisesWithCompletion: (void(^)(NSError *error, int statusCode, NSArray *exercises))completion {
    if([[NetworkManager sharedInstance] isConnectionOffline]){
        if(completion){
            completion([[Helper sharedHelper] noInternetError], (int)[[Helper sharedHelper] noInternetError].code, nil);
        }
        return;
    }
    
    NSString *urlString = [NSString stringWithFormat:@"%@%@",MainURL, UnlockedExercisesGetURL];
    
    AFHTTPSessionManager *manager = [[AFHTTPSessionManager manager] initWithSessionConfiguration:[[Helper sharedHelper] sessionConfiguration]];
    [manager.requestSerializer setValue:[[UserModel sharedInstance] accessToken] forHTTPHeaderField:@"jwt"];
    
    [manager GET:urlString parameters:nil progress:nil success:^(NSURLSessionDataTask * _Nonnull task, id  _Nullable responseObject) {
        NSHTTPURLResponse *response = (NSHTTPURLResponse *) [task response];
        NSInteger statusCode = [response statusCode];
        NSLog(@"RESPONSE CODE: %li", (long)statusCode);
        
        if( completion ){
            //[[ModulesModel sharedInstance] saveModules:responseObject];
            completion(nil, (int)statusCode, responseObject);
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

- (void) getSurpriseWorkoutWithParameters:(NSDictionary *)params withCompletion: (void(^)(NSError *error, int statusCode, ExercisesObj *exercise))completion{
    
    if([[NetworkManager sharedInstance] isConnectionOffline]){
        if(completion){
            completion([[Helper sharedHelper] noInternetError], (int)[[Helper sharedHelper] noInternetError].code, nil);
        }
        return;
    }
    
    NSString *urlString = [NSString stringWithFormat:@"%@%@",MainURL, RandomExerciseGetURL];
    
    AFHTTPSessionManager *manager = [[AFHTTPSessionManager manager] initWithSessionConfiguration:[[Helper sharedHelper] sessionConfiguration]];
    [manager.requestSerializer setValue:[[UserModel sharedInstance] accessToken] forHTTPHeaderField:@"jwt"];
    
    [manager GET:urlString parameters:params progress:nil success:^(NSURLSessionDataTask * _Nonnull task, id  _Nullable responseObject) {
        NSHTTPURLResponse *response = (NSHTTPURLResponse *) [task response];
        NSInteger statusCode = [response statusCode];
        NSLog(@"RESPONSE CODE: %li", (long)statusCode);
        
        if( completion ){
            ExercisesObj *exercise = [[ModulesModel sharedInstance] getSurpriseExerciseFromJson:responseObject[0]];
            completion(nil, (int)statusCode, exercise);
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

- (void) getExercisesWithParameters:(NSDictionary *)params withCompletion: (void(^)(NSError *error, int statusCode, NSArray *exercises))completion{
    if([[NetworkManager sharedInstance] isConnectionOffline]){
        if(completion){
            completion([[Helper sharedHelper] noInternetError], (int)[[Helper sharedHelper] noInternetError].code, nil);
        }
        return;
    }
    
    NSString *urlString = [NSString stringWithFormat:@"%@%@",MainURL, ExercisesListGetURL];
    
    AFHTTPSessionManager *manager = [[AFHTTPSessionManager manager] initWithSessionConfiguration:[[Helper sharedHelper] sessionConfiguration]];
    [manager.requestSerializer setValue:[[UserModel sharedInstance] accessToken] forHTTPHeaderField:@"jwt"];
    
    [manager GET:urlString parameters:params progress:nil success:^(NSURLSessionDataTask * _Nonnull task, id  _Nullable responseObject) {
        NSHTTPURLResponse *response = (NSHTTPURLResponse *) [task response];
        NSInteger statusCode = [response statusCode];
        NSLog(@"RESPONSE CODE: %li", (long)statusCode);
        
        if( completion ){
            NSArray *exercises = [[ModulesModel sharedInstance] getExercisesFromJson:responseObject[@"exercises"]];
            completion(nil, (int) statusCode, exercises);
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

- (void) getAvailableExercisesWithCompletion: (void(^)(NSError *error, int statusCode, NSArray *exercises))completion{
    if([[NetworkManager sharedInstance] isConnectionOffline]){
        if(completion){
            completion([[Helper sharedHelper] noInternetError], (int)[[Helper sharedHelper] noInternetError].code, nil);
        }
        return;
    }
    
    NSString *urlString = [NSString stringWithFormat:@"%@%@",MainURL, AllAvailableExercisesGetURL];
    
    AFHTTPSessionManager *manager = [[AFHTTPSessionManager manager] initWithSessionConfiguration:[[Helper sharedHelper] sessionConfiguration]];
    [manager.requestSerializer setValue:[[UserModel sharedInstance] accessToken] forHTTPHeaderField:@"jwt"];
    
    [manager GET:urlString parameters:nil progress:nil success:^(NSURLSessionDataTask * _Nonnull task, id  _Nullable responseObject) {
        NSHTTPURLResponse *response = (NSHTTPURLResponse *) [task response];
        NSInteger statusCode = [response statusCode];
        NSLog(@"RESPONSE CODE: %li", (long)statusCode);
        
        if( completion ){
            NSArray *exercises = [[ModulesModel sharedInstance] getExercisesFromJson:responseObject[@"exercises"]];
            completion(nil, (int) statusCode, exercises);
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

- (void) addRating:(int)rating forExercise:(NSString *)exerciseId withCompletion: (void(^)(NSError *error,  int statusCode))completion{
    if([[NetworkManager sharedInstance] isConnectionOffline]){
        if( completion ){
            completion([[Helper sharedHelper] noInternetError], (int)[[Helper sharedHelper] noInternetError].code);
        }
        return;
    }
    
    NSString *urlString = [NSString stringWithFormat:@"%@%@/%@/pass/%d",MainURL, AddExerciseRatingPostURL, exerciseId, rating];
    
    AFHTTPSessionManager *manager = [[AFHTTPSessionManager manager] initWithSessionConfiguration:[[Helper sharedHelper] sessionConfiguration]];
    manager.requestSerializer = [AFJSONRequestSerializer serializer];
    manager.responseSerializer = [AFHTTPResponseSerializer serializer];
    [manager.requestSerializer setValue:[[UserModel sharedInstance] accessToken] forHTTPHeaderField:@"jwt"];
    
    [manager POST:urlString parameters:nil progress:nil success:^(NSURLSessionDataTask * _Nonnull task, id  _Nullable responseObject) {
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

- (void) getBookmarkedExercisesWithCompletion: (void(^)(NSError *error,  BOOL successful))completion{
    /*if([[NetworkManager sharedInstance] isConnectionOffline]){
        return;
    }*/
    
    NSString *urlString = [NSString stringWithFormat:@"%@%@",MainURL, BookmarkedExercisesURL];
    
    AFHTTPSessionManager *manager = [[AFHTTPSessionManager manager] initWithSessionConfiguration:[[Helper sharedHelper] sessionConfiguration]];
    [manager.requestSerializer setValue:[[UserModel sharedInstance] accessToken] forHTTPHeaderField:@"jwt"];
    
    [manager GET:urlString parameters:nil progress:nil success:^(NSURLSessionDataTask * _Nonnull task, id  _Nullable responseObject) {
        [[ModulesModel sharedInstance] saveBookmarkedExercises:responseObject];
        
        if( completion ){
            completion(nil, YES);
        }
    } failure:^(NSURLSessionDataTask * _Nullable task, NSError * _Nonnull error) {
        
        if( completion ){
            completion(error, NO);
        }
    }];
}

- (void) createBookMarkForExercise:(NSString *)exerciseId withCompletion: (void(^)(NSError *error,  int statusCode))completion{
    if([[NetworkManager sharedInstance] isConnectionOffline]){
        if( completion ){
            completion([[Helper sharedHelper] noInternetError], (int)[[Helper sharedHelper] noInternetError].code);
        }
        return;
    }
    
    NSString *urlString = [NSString stringWithFormat:@"%@%@",MainURL, BookmarkedExercisesURL];
    NSDictionary *param = @{ @"exercise": exerciseId };
    
    AFHTTPSessionManager *manager = [[AFHTTPSessionManager manager] initWithSessionConfiguration:[[Helper sharedHelper] sessionConfiguration]];
    manager.requestSerializer = [AFJSONRequestSerializer serializer];
    manager.responseSerializer = [AFHTTPResponseSerializer serializer];
    [manager.requestSerializer setValue:[[UserModel sharedInstance] accessToken] forHTTPHeaderField:@"jwt"];
    
    [manager POST:urlString parameters:param progress:nil success:^(NSURLSessionDataTask * _Nonnull task, id  _Nullable responseObject) {
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

- (void) removeBookMark:(NSString *)bookmarkId withCompletion: (void(^)(NSError *error,  int statusCode))completion{
    if([[NetworkManager sharedInstance] isConnectionOffline]){
        if( completion ){
            completion([[Helper sharedHelper] noInternetError], (int)[[Helper sharedHelper] noInternetError].code);
        }
        return;
    }
    
    NSString *urlString = [NSString stringWithFormat:@"%@%@/%@",MainURL, BookmarkedExercisesURL, bookmarkId];
    
    AFHTTPSessionManager *manager = [[AFHTTPSessionManager manager] initWithSessionConfiguration:[[Helper sharedHelper] sessionConfiguration]];
    manager.requestSerializer = [AFJSONRequestSerializer serializer];
    manager.responseSerializer = [AFHTTPResponseSerializer serializer];
    [manager.requestSerializer setValue:[[UserModel sharedInstance] accessToken] forHTTPHeaderField:@"jwt"];
    
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

- (void) getExercisesHistoryWithCompletion: (void(^)(NSError *error, int statusCode,  NSArray *exercises))completion{
    if([[NetworkManager sharedInstance] isConnectionOffline]){
        if(completion){
            completion([[Helper sharedHelper] noInternetError], (int)[[Helper sharedHelper] noInternetError].code, nil);
        }
        return;
    }
    
    NSString *urlString = [NSString stringWithFormat:@"%@%@",MainURL, ExercisesHistoryGetURL];
    
    AFHTTPSessionManager *manager = [[AFHTTPSessionManager manager] initWithSessionConfiguration:[[Helper sharedHelper] sessionConfiguration]];
    [manager.requestSerializer setValue:[[UserModel sharedInstance] accessToken] forHTTPHeaderField:@"jwt"];
    
    [manager GET:urlString parameters:nil progress:nil success:^(NSURLSessionDataTask * _Nonnull task, id  _Nullable responseObject) {
        NSHTTPURLResponse *response = (NSHTTPURLResponse *) [task response];
        NSInteger statusCode = [response statusCode];
        NSLog(@"RESPONSE CODE: %li", (long)statusCode);
        
        if( completion ){
            NSArray *exercises = [[ModulesModel sharedInstance] getExercisesHistoryFromJson:responseObject[@"historyExercises"]];
            completion(nil, (int)statusCode, exercises);
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

- (void) getFocusAreaWithCompletion: (void(^)(NSError *error, int statusCode))completion{
    /*if([[NetworkManager sharedInstance] isConnectionOffline]){
        return;
    }*/
    
    NSString *urlString = [NSString stringWithFormat:@"%@%@",MainURL, FocusAreaGetURL];
    
    AFHTTPSessionManager *manager = [[AFHTTPSessionManager manager] initWithSessionConfiguration:[[Helper sharedHelper] sessionConfiguration]];
    [manager.requestSerializer setValue:[[UserModel sharedInstance] accessToken] forHTTPHeaderField:@"jwt"];
    
    [manager GET:urlString parameters:nil progress:nil success:^(NSURLSessionDataTask * _Nonnull task, id  _Nullable responseObject) {
        NSHTTPURLResponse *response = (NSHTTPURLResponse *) [task response];
        NSInteger statusCode = [response statusCode];
        NSLog(@"RESPONSE CODE: %li", (long)statusCode);
        [[ModulesModel sharedInstance] saveFocusArea:responseObject];
        
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

- (void) getTagsWithCompletion: (void(^)(NSError *error, int statusCode))completion{
    NSString *urlString = [NSString stringWithFormat:@"%@%@",MainURL, TagsGetURL];
    
    AFHTTPSessionManager *manager = [[AFHTTPSessionManager manager] initWithSessionConfiguration:[[Helper sharedHelper] sessionConfiguration]];
    [manager.requestSerializer setValue:[[UserModel sharedInstance] accessToken] forHTTPHeaderField:@"jwt"];
    
    [manager GET:urlString parameters:nil progress:nil success:^(NSURLSessionDataTask * _Nonnull task, id  _Nullable responseObject) {
        NSHTTPURLResponse *response = (NSHTTPURLResponse *) [task response];
        NSInteger statusCode = [response statusCode];
        NSLog(@"RESPONSE CODE: %li", (long)statusCode);
        [[ModulesModel sharedInstance] saveTags:responseObject];
        
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

- (void) initiatePaymentWithParam: (NSDictionary *)param completion: (void(^)(NSError *error, NSDictionary *result))completion{
    NSString *urlString = [NSString stringWithFormat:@"%@%@",CoachMainURL, PaymentURL];
    
    AFHTTPSessionManager *manager = [[AFHTTPSessionManager manager] initWithSessionConfiguration:[[Helper sharedHelper] sessionConfiguration]];
    manager.requestSerializer = [AFJSONRequestSerializer serializer];
    [manager.requestSerializer setValue:@"application/json" forHTTPHeaderField:@"Content-Type"];
    [manager.requestSerializer setValue:@"application/json" forHTTPHeaderField:@"Accept"];
    [manager.requestSerializer setValue:[[UserModel sharedInstance] accessToken] forHTTPHeaderField:@"Authorization"];
    
    manager.responseSerializer = [AFJSONResponseSerializer serializer];
    
    [manager POST:urlString parameters:param progress:nil success:^(NSURLSessionDataTask * _Nonnull task, id  _Nullable responseObject) {
        
        if( completion ){
            completion(nil, responseObject);
        }
    } failure:^(NSURLSessionDataTask * _Nullable task, NSError * _Nonnull error) {
        NSHTTPURLResponse *response = (NSHTTPURLResponse *) [task response];
        NSInteger statusCode = [response statusCode];
        NSLog(@"RESPONSE CODE: %li", (long)statusCode);
        
        if( completion ){
            completion(error, nil);
        }
    }];
}
@end
