//
//  DownloadServices.m
//  XSInfinity
//
//  Created by Joseph Marvin Magdadaro on 6/19/18.
//  Copyright © 2018 Joseph Marvin Magdadaro. All rights reserved.
//

#import "DownloadServices.h"
#import <AFNetworking/AFHTTPSessionManager.h>
#import "NetworkManager.h"

@implementation DownloadServices

+ (instancetype)sharedInstance
{
    static dispatch_once_t onceToken;
    static DownloadServices *sharedInstance;
    
    dispatch_once(&onceToken, ^{
        sharedInstance = [[self alloc] init];
    });
    
    return sharedInstance;
}

- (void) downloadVideoFromURL:(NSString *)url setFileName:(NSString *)fileName withCompletion:(void(^)(NSError *error,  BOOL downloaded))completion{
    if([[NetworkManager sharedInstance] isConnectionOffline]){
        return;
    }
    
    NSURLSessionConfiguration *configuration = [NSURLSessionConfiguration defaultSessionConfiguration];
    AFURLSessionManager *manager = [[AFURLSessionManager alloc] initWithSessionConfiguration:configuration];
    
    NSURL *URL = [NSURL URLWithString:url];
    NSURLRequest *request = [NSURLRequest requestWithURL:URL];
    
    NSURLSessionDownloadTask *downloadTask = [manager downloadTaskWithRequest:request progress:nil destination:^NSURL *(NSURL *targetPath, NSURLResponse *response) {
        NSURL *documentsDirectoryURL = [[NSFileManager defaultManager] URLForDirectory:NSDocumentDirectory inDomain:NSUserDomainMask appropriateForURL:nil create:NO error:nil];
        return [documentsDirectoryURL URLByAppendingPathComponent:fileName];
    } completionHandler:^(NSURLResponse *response, NSURL *filePath, NSError *error) {
        NSLog(@"File downloaded to: %@", filePath);
        if( completion ){
            if (error == nil) {
                completion(nil, YES);
            }else{
                completion(error, NO);
            }
        }
    }];
    [downloadTask resume];
}
@end
