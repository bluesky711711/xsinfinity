//
//  HabitsServices.m
//  XSInfinity
//
//  Created by Joseph Marvin Magdadaro on 6/29/18.
//  Copyright © 2018 Joseph Marvin Magdadaro. All rights reserved.
//

#import "HabitsServices.h"
#import <AFNetworking/AFHTTPSessionManager.h>
#import "NetworkManager.h"
#import "HabitsObj.h"
#import "HabitsModel.h"
#import "Helper.h"
#import "UserModel.h"

static NSString * const HabitsOverviewGetURL = @"api/v1/user/habitinformation";
static NSString * const HabitsListGetURL = @"api/v1/habits";
static NSString * const AllHabitsListGetURL = @"api/v1/habits";
static NSString * const UnlockedHabitsListGetURL = @"api/v1/user/habits/unlockedhabits";
static NSString * const AvailableHabitsListGetURL = @"api/v1/user/habits/availablehabits";
static NSString * const StartHabitsPutURL = @"api/v1/user/starthabits";
static NSString * const StopHabitsPutURL = @"api/v1/user/stophabits";
static NSString * const FinishSpecificHabitPostURL = @"api/v1/user/habits";
static NSString * const FinishAllHabitsPostURL = @"api/v1/user/habits/passall";
static NSString * const UndoHabitPostURL = @"api/v1/user/habits";

@implementation HabitsServices

+ (instancetype)sharedInstance
{
    static dispatch_once_t onceToken;
    static HabitsServices *sharedInstance;
    
    dispatch_once(&onceToken, ^{
        sharedInstance = [[self alloc] init];
    });
    
    return sharedInstance;
}

- (void) getHabitsOverviewWithCompletion: (void(^)(NSError *error, int statusCode, NSArray *notPassedHabits, NSArray *unlockedHabits))completion{
    if([[NetworkManager sharedInstance] isConnectionOffline]){
        if(completion){
            completion([[Helper sharedHelper] noInternetError], (int)[[Helper sharedHelper] noInternetError].code, nil, nil);
        }
        return;
    }
    
    NSString *urlString = [NSString stringWithFormat:@"%@%@",MainURL, HabitsOverviewGetURL];
    
    AFHTTPSessionManager *manager = [[AFHTTPSessionManager manager] initWithSessionConfiguration:[[Helper sharedHelper] sessionConfiguration]];
    [manager.requestSerializer setValue:[[UserModel sharedInstance] accessToken] forHTTPHeaderField:@"jwt"];
    
    [manager GET:urlString parameters:nil progress:nil success:^(NSURLSessionDataTask * _Nonnull task, id  _Nullable responseObject) {
        NSHTTPURLResponse *response = (NSHTTPURLResponse *) [task response];
        NSInteger statusCode = [response statusCode];
        NSLog(@"RESPONSE CODE: %li", (long)statusCode);
        
        NSArray *notPassedHabits = [responseObject[@"todayNotPassedHabits"] mutableCopy];
        NSArray *unlockedHabits = [responseObject[@"unlockedHabits"] mutableCopy];
        
        if( completion ){
            [[HabitsModel sharedInstance] saveHabitsOverview:responseObject];
            completion(nil, (int)statusCode, notPassedHabits, unlockedHabits);
        }
    } failure:^(NSURLSessionDataTask * _Nullable task, NSError * _Nonnull error) {
        NSHTTPURLResponse *response = (NSHTTPURLResponse *) [task response];
        NSInteger statusCode = [response statusCode];
        NSLog(@"RESPONSE CODE: %li", (long)statusCode);
        
        if( completion ){
            if(response){
                completion(error, (int)statusCode, nil, nil);
            }else{
                completion(error, (int)error.code, nil, nil);
            }
        }
    }];
}

- (void) getAllHabitsWithCompletion: (void(^)(NSError *error, int statusCode))completion{
    if([[NetworkManager sharedInstance] isConnectionOffline]){
        if(completion){
            completion([[Helper sharedHelper] noInternetError], (int)[[Helper sharedHelper] noInternetError].code);
        }
        return;
    }
    
    NSString *urlString = [NSString stringWithFormat:@"%@%@",MainURL, AllHabitsListGetURL];
    
    AFHTTPSessionManager *manager = [[AFHTTPSessionManager manager] initWithSessionConfiguration:[[Helper sharedHelper] sessionConfiguration]];
    [manager.requestSerializer setValue:[[UserModel sharedInstance] accessToken] forHTTPHeaderField:@"jwt"];
    
    [manager GET:urlString parameters:nil progress:nil success:^(NSURLSessionDataTask * _Nonnull task, id  _Nullable responseObject) {
        NSHTTPURLResponse *response = (NSHTTPURLResponse *) [task response];
        NSInteger statusCode = [response statusCode];
        NSLog(@"RESPONSE CODE: %li", (long)statusCode);
        
        if( completion ){
            [[HabitsModel sharedInstance] saveHabits:responseObject];
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

//unlocked habits and returns passed or not passed habits
- (void) getUnlockedHabitsWithCompletion: (void(^)(NSError *error, int statusCode, NSArray *habits))completion{
    if([[NetworkManager sharedInstance] isConnectionOffline]){
        if(completion){
            completion([[Helper sharedHelper] noInternetError], (int)[[Helper sharedHelper] noInternetError].code, nil);
        }
        return;
    }
    
    NSString *urlString = [NSString stringWithFormat:@"%@%@",MainURL, UnlockedHabitsListGetURL];
    
    AFHTTPSessionManager *manager = [[AFHTTPSessionManager manager] initWithSessionConfiguration:[[Helper sharedHelper] sessionConfiguration]];
    [manager.requestSerializer setValue:[[UserModel sharedInstance] accessToken] forHTTPHeaderField:@"jwt"];
    
    [manager GET:urlString parameters:nil progress:nil success:^(NSURLSessionDataTask * _Nonnull task, id  _Nullable responseObject) {
        NSHTTPURLResponse *response = (NSHTTPURLResponse *) [task response];
        NSInteger statusCode = [response statusCode];
        NSLog(@"RESPONSE CODE: %li", (long)statusCode);
        
        if( completion ){
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

//unlocked habits but return only Not Passed habits
- (void) getAvailableHabitsWithCompletion: (void(^)(NSError *error, int statusCode, NSArray *habits))completion{
    if([[NetworkManager sharedInstance] isConnectionOffline]){
        if(completion){
            completion([[Helper sharedHelper] noInternetError], (int)[[Helper sharedHelper] noInternetError].code, nil);
        }
        return;
    }
    
    NSString *urlString = [NSString stringWithFormat:@"%@%@",MainURL, AvailableHabitsListGetURL];
    
    AFHTTPSessionManager *manager = [[AFHTTPSessionManager manager] initWithSessionConfiguration:[[Helper sharedHelper] sessionConfiguration]];
    [manager.requestSerializer setValue:[[UserModel sharedInstance] accessToken] forHTTPHeaderField:@"jwt"];
    
    [manager GET:urlString parameters:nil progress:nil success:^(NSURLSessionDataTask * _Nonnull task, id  _Nullable responseObject) {
        NSHTTPURLResponse *response = (NSHTTPURLResponse *) [task response];
        NSInteger statusCode = [response statusCode];
        NSLog(@"RESPONSE CODE: %li", (long)statusCode);
        
        if( completion ){
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

- (void) startHabitsWithCompletion: (void(^)(NSError *error, int statusCode))completion{
    if([[NetworkManager sharedInstance] isConnectionOffline]){
        if( completion ){
            completion([[Helper sharedHelper] noInternetError], (int)[[Helper sharedHelper] noInternetError].code);
        }
        return;
    }
    
    NSString *urlString = [NSString stringWithFormat:@"%@%@",MainURL, StartHabitsPutURL];
    
    AFHTTPSessionManager *manager = [[AFHTTPSessionManager manager] initWithSessionConfiguration:[[Helper sharedHelper] sessionConfiguration]];
    [manager.requestSerializer setValue:[[UserModel sharedInstance] accessToken] forHTTPHeaderField:@"jwt"];
    
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

- (void) stopHabitsWithCompletion: (void(^)(NSError *error, int statusCode))completion{
    if([[NetworkManager sharedInstance] isConnectionOffline]){
        if( completion ){
            completion([[Helper sharedHelper] noInternetError], (int)[[Helper sharedHelper] noInternetError].code);
        }
        return;
    }
    
    NSString *urlString = [NSString stringWithFormat:@"%@%@",MainURL, StopHabitsPutURL];
    
    AFHTTPSessionManager *manager = [[AFHTTPSessionManager manager] initWithSessionConfiguration:[[Helper sharedHelper] sessionConfiguration]];
    [manager.requestSerializer setValue:[[UserModel sharedInstance] accessToken] forHTTPHeaderField:@"jwt"];
    
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

- (void) finishHabitWithId:(NSString *)habitId withCompletion: (void(^)(NSError *error,  int statusCode))completion{
    if([[NetworkManager sharedInstance] isConnectionOffline]){
        if( completion ){
            completion([[Helper sharedHelper] noInternetError], (int)[[Helper sharedHelper] noInternetError].code);
        }
        return;
    }
    
    NSString *urlString = [NSString stringWithFormat:@"%@%@/%@/pass",MainURL, FinishSpecificHabitPostURL, habitId];
    
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

- (void) finishAllHabitsWithCompletion: (void(^)(NSError *error,  int statusCode))completion{
    if([[NetworkManager sharedInstance] isConnectionOffline]){
        if( completion ){
            completion([[Helper sharedHelper] noInternetError], (int)[[Helper sharedHelper] noInternetError].code);
        }
        return;
    }
    
    NSString *urlString = [NSString stringWithFormat:@"%@%@",MainURL, FinishAllHabitsPostURL];
    
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

- (void) undoHabitWithId:(NSString *)habitId withCompletion: (void(^)(NSError *error,  int statusCode))completion{
    if([[NetworkManager sharedInstance] isConnectionOffline]){
        if( completion ){
            completion([[Helper sharedHelper] noInternetError], (int)[[Helper sharedHelper] noInternetError].code);
        }
        return;
    }
    
    NSString *urlString = [NSString stringWithFormat:@"%@%@/%@/undopass",MainURL, UndoHabitPostURL, habitId];
    
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

@end
