//
//  FaqServices.m
//  XSInfinity
//
//  Created by Joseph Marvin Magdadaro on 8/9/18.
//  Copyright © 2018 Jerk Magz. All rights reserved.
//

#import "FaqServices.h"
#import <AFNetworking/AFHTTPSessionManager.h>
#import "NetworkManager.h"
#import "FaqModel.h"
#import "Helper.h"
#import "UserModel.h"

static NSString * const FaqCategoriesWithFaqsGetURL = @"api/v1/faqcategories";

@implementation FaqServices

+ (instancetype)sharedInstance
{
    static dispatch_once_t onceToken;
    static FaqServices *sharedInstance;
    
    dispatch_once(&onceToken, ^{
        sharedInstance = [[self alloc] init];
    });
    
    return sharedInstance;
}

- (void) getFaqCategoriesWithFaqsWithCompletion: (void(^)(NSError *error, int statusCode))completion{
    if([[NetworkManager sharedInstance] isConnectionOffline]){
        if(completion){
            completion([[Helper sharedHelper] noInternetError], (int)[[Helper sharedHelper] noInternetError].code);
        }
        return;
    }
    
    NSString *urlString = [NSString stringWithFormat:@"%@%@",MainURL, FaqCategoriesWithFaqsGetURL];
    
    AFHTTPSessionManager *manager = [[AFHTTPSessionManager manager] initWithSessionConfiguration:[[Helper sharedHelper] sessionConfiguration]];
    [manager.requestSerializer setValue:[[UserModel sharedInstance] accessToken] forHTTPHeaderField:@"jwt"];
    
    [manager GET:urlString parameters:nil progress:nil success:^(NSURLSessionDataTask * _Nonnull task, id  _Nullable responseObject) {
        NSHTTPURLResponse *response = (NSHTTPURLResponse *) [task response];
        NSInteger statusCode = [response statusCode];
        NSLog(@"RESPONSE CODE: %li", (long)statusCode);
        
        if( completion ){
            [[FaqModel sharedInstance] saveFaqCategories:responseObject];
            completion(nil, (int)statusCode);
        }
    } failure:^(NSURLSessionDataTask * _Nullable task, NSError * _Nonnull error) {
        NSHTTPURLResponse *response = (NSHTTPURLResponse *) [task response];
        NSInteger statusCode = [response statusCode];
        NSLog(@"RESPONSE CODE: %li", (long)statusCode);
        
        if( completion ){
            completion(error, (int)statusCode);
        }
    }];
    
}

@end
