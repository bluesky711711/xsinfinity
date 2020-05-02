//
//  CommunityServices.m
//  XSInfinity
//
//  Created by Joseph Marvin Magdadaro on 7/17/18.
//  Copyright © 2018 Jerk Magz. All rights reserved.
//

#import "CommunityServices.h"
#import <AFNetworking/AFHTTPSessionManager.h>
#import "NetworkManager.h"
#import "CommunityModel.h"
#import "RankingListObj.h"
#import "Helper.h"
#import "UserModel.h"

static NSString * const RankingListGetURL = @"api/v1/user/community/ranking";
static NSString * const OtherUserProfileGetURL = @"api/v1/user/community/user";
static NSString * const UserActivitiesGetURL = @"api/v1/user/history";

@implementation CommunityServices

+ (instancetype)sharedInstance
{
    static dispatch_once_t onceToken;
    static CommunityServices *sharedInstance;
    
    dispatch_once(&onceToken, ^{
        sharedInstance = [[self alloc] init];
    });
    
    return sharedInstance;
}

- (void) getRankingListWithCompletion: (void(^)(NSError *error, int statusCode, NSArray *rankingList))completion{
    if([[NetworkManager sharedInstance] isConnectionOffline]){
        if(completion){
            completion([[Helper sharedHelper] noInternetError], (int)[[Helper sharedHelper] noInternetError].code, nil);
        }
        return;
    }
    
    NSString *urlString = [NSString stringWithFormat:@"%@%@",MainURL, RankingListGetURL];
    
    AFHTTPSessionManager *manager = [[AFHTTPSessionManager manager] initWithSessionConfiguration:[[Helper sharedHelper] sessionConfiguration]];
    [manager.requestSerializer setValue:[[UserModel sharedInstance] accessToken] forHTTPHeaderField:@"jwt"];
    
    [manager GET:urlString parameters:nil progress:nil success:^(NSURLSessionDataTask * _Nonnull task, id  _Nullable responseObject) {
        NSHTTPURLResponse *response = (NSHTTPURLResponse *) [task response];
        NSInteger statusCode = [response statusCode];
        NSLog(@"RESPONSE CODE: %li", (long)statusCode);
        
        if( completion ){
            NSArray *rankingList = [[CommunityModel sharedInstance] getRankingListFromJson:responseObject];
            completion(nil, (int)statusCode, rankingList);
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

- (void) getOtherUserProfile:(NSString *)identifier withCompletion: (void(^)(NSError *error, int statusCode, OtherProfileObj *otherProfile))completion{
    if([[NetworkManager sharedInstance] isConnectionOffline]){
        if(completion){
            completion([[Helper sharedHelper] noInternetError], (int)[[Helper sharedHelper] noInternetError].code, nil);
        }
        return;
    }
    
    NSString *urlString = [NSString stringWithFormat:@"%@%@/%@",MainURL, OtherUserProfileGetURL, identifier];
    
    AFHTTPSessionManager *manager = [[AFHTTPSessionManager manager] initWithSessionConfiguration:[[Helper sharedHelper] sessionConfiguration]];
    [manager.requestSerializer setValue:[[UserModel sharedInstance] accessToken] forHTTPHeaderField:@"jwt"];
    
    [manager GET:urlString parameters:nil progress:nil success:^(NSURLSessionDataTask * _Nonnull task, id  _Nullable responseObject) {
        NSHTTPURLResponse *response = (NSHTTPURLResponse *) [task response];
        NSInteger statusCode = [response statusCode];
        NSLog(@"RESPONSE CODE: %li", (long)statusCode);
        
        if( completion ){
            OtherProfileObj *otherProfile = [[CommunityModel sharedInstance] getOtherProfileInfoFromJson:responseObject];
            completion(nil, (int)statusCode, otherProfile);
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

- (void) getActivitiesForUserWithCompletion: (void(^)(NSError *error, int statusCode, NSDictionary *userActivities))completion{
    if([[NetworkManager sharedInstance] isConnectionOffline]){
        if(completion){
            completion([[Helper sharedHelper] noInternetError], (int)[[Helper sharedHelper] noInternetError].code, nil);
        }
        return;
    }
    
    NSString *urlString = [NSString stringWithFormat:@"%@%@",MainURL, UserActivitiesGetURL];
    
    AFHTTPSessionManager *manager = [[AFHTTPSessionManager manager] initWithSessionConfiguration:[[Helper sharedHelper] sessionConfiguration]];
    [manager.requestSerializer setValue:[[UserModel sharedInstance] accessToken] forHTTPHeaderField:@"jwt"];
    
    [manager GET:urlString parameters:nil progress:nil success:^(NSURLSessionDataTask * _Nonnull task, id  _Nullable responseObject) {
        NSHTTPURLResponse *response = (NSHTTPURLResponse *) [task response];
        NSInteger statusCode = [response statusCode];
        NSLog(@"RESPONSE CODE: %li", (long)statusCode);
        
        if( completion ){
            NSDictionary *activities = [[CommunityModel sharedInstance] getUserActivitiesFromJson:responseObject];
            completion(nil, (int)statusCode, activities);
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
