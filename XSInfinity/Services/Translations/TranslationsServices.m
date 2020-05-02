//
//  TranslationsServices.m
//  XSInfinity
//
//  Created by Joseph Marvin Magdadaro on 5/26/18.
//  Copyright © 2018 Joseph Marvin Magdadaro. All rights reserved.
//

#import "TranslationsServices.h"
#import <AFNetworking/AFHTTPSessionManager.h>
#import "NetworkManager.h"
#import "TranslationsModel.h"
#import "Translations.h"
#import "Helper.h"

static NSString * const DefaultLastModified = @"2015-05-10T14:17:33+0200";
static NSString * const TranslationsGetURL = @"api/v1/translation/updatessince/";

@implementation TranslationsServices

+ (instancetype)sharedInstance
{
    static dispatch_once_t onceToken;
    static TranslationsServices *sharedInstance;
    
    dispatch_once(&onceToken, ^{
        sharedInstance = [[self alloc] init];
    });
    
    return sharedInstance;
}

- (void) getTranslationsWithCompletion: (void(^)(NSError *error,  BOOL successful))completion{
    NSString *lastModified = DefaultLastModified;
    
    Translations *translation = [[TranslationsModel sharedInstance] getLatestTranslation];
    if (translation) {
        lastModified = translation.lastModified;
    }
    
    NSString *urlString = [NSString stringWithFormat:@"%@%@%@",MainURL, TranslationsGetURL, lastModified];
    
    AFHTTPSessionManager *manager = [AFHTTPSessionManager manager];
    //[manager.requestSerializer setValue:authValue forHTTPHeaderField:@"Authorization"];
    [manager GET:urlString parameters:nil progress:nil success:^(NSURLSessionDataTask * _Nonnull task, id  _Nullable responseObject) {
        
        if( completion ){
            [[TranslationsModel sharedInstance] saveTranslations:responseObject];
            completion(nil, YES);
        }
    } failure:^(NSURLSessionDataTask * _Nullable task, NSError * _Nonnull error) {
        
        if( completion ){
            completion(error, NO);
        }
    }];
}

@end
