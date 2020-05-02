//
//  UserMediaServices.m
//  XSInfinity
//
//  Created by Joseph Marvin Magdadaro on 7/28/18.
//  Copyright © 2018 Jerk Magz. All rights reserved.
//

#import "UserMediaServices.h"
#import <AFNetworking/AFHTTPSessionManager.h>
#import "NetworkManager.h"
#import "Helper.h"
#import "UserModel.h"

static NSString * const ProfileImageGetURL = @"api/v1/user/media/profilepicture";
static NSString * const ProfileHeaderImageGetURL = @"api/v1/user/media/profileheader";
static NSString * const SaveProfileImagePostURL = @"api/v1/user/media/profilepicture";
static NSString * const SaveImageInGalleryPostURL = @"api/v1/user/media/galleryimage";
static NSString * const UpdateImageFromGalleryPatchURL = @"api/v1/user/media/image";
static NSString * const DeleteImageFromGalleryDeleteURL = @"api/v1/user/media/galleryimage";

@implementation UserMediaServices

+ (instancetype)sharedInstance
{
    static dispatch_once_t onceToken;
    static UserMediaServices *sharedInstance;
    
    dispatch_once(&onceToken, ^{
        sharedInstance = [[self alloc] init];
    });
    
    return sharedInstance;
}

- (void) getProfileImageWithCompletion: (void(^)(NSError *error, int statusCode))completion{
    if([[NetworkManager sharedInstance] isConnectionOffline]){
        if(completion){
            completion([[Helper sharedHelper] noInternetError], (int)[[Helper sharedHelper] noInternetError].code);
        }
        return;
    }
    
    NSString *urlString = [NSString stringWithFormat:@"%@%@",MainURL, ProfileImageGetURL];
    
    AFHTTPSessionManager *manager = [[AFHTTPSessionManager manager] initWithSessionConfiguration:[[Helper sharedHelper] sessionConfiguration]];
    [manager.requestSerializer setValue:[[UserModel sharedInstance] accessToken] forHTTPHeaderField:@"jwt"];
    
    [manager GET:urlString parameters:nil progress:nil success:^(NSURLSessionDataTask * _Nonnull task, id  _Nullable responseObject) {
        NSHTTPURLResponse *response = (NSHTTPURLResponse *) [task response];
        NSInteger statusCode = [response statusCode];
        NSLog(@"RESPONSE CODE: %li", (long)statusCode);
        
        if( completion ){
            [[UserModel sharedInstance] saveImageUrl:responseObject[@"url"] ofMedia:@"profileImage"];
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

- (void) getProfileHeaderImageWithCompletion: (void(^)(NSError *error, int statusCode))completion{
    if([[NetworkManager sharedInstance] isConnectionOffline]){
        if(completion){
            completion([[Helper sharedHelper] noInternetError], (int)[[Helper sharedHelper] noInternetError].code);
        }
        return;
    }
    
    NSString *urlString = [NSString stringWithFormat:@"%@%@",MainURL, ProfileHeaderImageGetURL];
    
    AFHTTPSessionManager *manager = [[AFHTTPSessionManager manager] initWithSessionConfiguration:[[Helper sharedHelper] sessionConfiguration]];
    [manager.requestSerializer setValue:[[UserModel sharedInstance] accessToken] forHTTPHeaderField:@"jwt"];
    
    [manager GET:urlString parameters:nil progress:nil success:^(NSURLSessionDataTask * _Nonnull task, id  _Nullable responseObject) {
        NSHTTPURLResponse *response = (NSHTTPURLResponse *) [task response];
        NSInteger statusCode = [response statusCode];
        NSLog(@"RESPONSE CODE: %li", (long)statusCode);
        
        if( completion ){
            [[UserModel sharedInstance] saveImageUrl:responseObject[@"url"] ofMedia:@"headerImage"];
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

- (void) saveProfileImage:(UIImage *)img withCompletion: (void(^)(NSError *error, int statusCode))completion{
    if([[NetworkManager sharedInstance] isConnectionOffline]){
        if(completion){
            completion([[Helper sharedHelper] noInternetError], (int)[[Helper sharedHelper] noInternetError].code);
        }
        return;
    }
    
    //Save the image to device temp location and get the path.
    NSData *imageData =  UIImageJPEGRepresentation(img, 1.0);
    NSString * timeStampValue = [NSString stringWithFormat:@"%ld", (long)[[NSDate date] timeIntervalSince1970]];
    NSString *filename = [NSString stringWithFormat:@"image%@.jpg", timeStampValue];
    NSArray *paths = NSSearchPathForDirectoriesInDomains(NSDocumentDirectory, NSUserDomainMask, YES);
    NSString *filePath = [[paths objectAtIndex:0] stringByAppendingPathComponent:filename];
    [imageData writeToFile:filePath atomically:YES];
    NSURL *fileURL = [[NSURL alloc] initFileURLWithPath:filePath];
    
    NSString *urlString = [NSString stringWithFormat:@"%@%@",MainURL, SaveProfileImagePostURL];
    
    AFHTTPRequestSerializer *requestSerializer = [AFHTTPRequestSerializer serializer];
    
    [requestSerializer setValue:@"multipart/form-data" forHTTPHeaderField:@"content-type"];
    [requestSerializer setValue:[[UserModel sharedInstance] accessToken] forHTTPHeaderField:@"jwt"];
    
    NSURLSessionConfiguration *configuration = [NSURLSessionConfiguration defaultSessionConfiguration];
    
    AFURLSessionManager *manager = [[AFURLSessionManager alloc] initWithSessionConfiguration:configuration];
    
    manager.responseSerializer = [AFHTTPResponseSerializer serializer];
    
    manager.securityPolicy.validatesDomainName = NO;
    
    NSMutableURLRequest *request = [requestSerializer multipartFormRequestWithMethod:@"POST" URLString:urlString parameters:nil constructingBodyWithBlock:^(id<AFMultipartFormData> formData) {
        
        [formData appendPartWithFileURL:fileURL name:@"image" fileName:filename mimeType:@"image/jpeg" error:nil];
        
    } error:nil];
    
    [request setTimeoutInterval:10000];
    
    NSURLSessionUploadTask *uploadTask;
    
    
    uploadTask = [manager
                  uploadTaskWithStreamedRequest:request
                  progress:^(NSProgress * _Nonnull uploadProgress) {
                      
                      dispatch_async(dispatch_get_main_queue(), ^{
                          //Update the progress view
                          NSLog(@"show progress here...");
                      });
                  }
                  completionHandler:^(NSURLResponse * _Nonnull response, id  _Nullable responseObject, NSError * _Nullable error) {
                      if (!error) {
                          NSHTTPURLResponse *responseCode = (NSHTTPURLResponse *)response;
                          NSInteger statusCode = [responseCode statusCode];
                          NSLog(@"RESPONSE CODE: %li", (long)statusCode);
                          
                          if( completion ){
                              completion(nil, (int)statusCode);
                          }
                      } else {
                          NSHTTPURLResponse *responseCode = (NSHTTPURLResponse *)response;
                          NSInteger statusCode = [responseCode statusCode];
                          NSLog(@"RESPONSE CODE: %li", (long)statusCode);
                          
                          if( completion ){
                              if(response){
                                  completion(error, (int)statusCode);
                              }else{
                                  completion(error, (int)error.code);
                              }
                          }
                      }

                  }];
    
    [uploadTask resume];
    
}

- (void) saveImage:(UIImage *)img withPrivacy:(int)isPrivate withCompletion: (void(^)(NSError *error,  int statusCode))completion{
    if([[NetworkManager sharedInstance] isConnectionOffline]){
        if(completion){
            completion([[Helper sharedHelper] noInternetError], (int)[[Helper sharedHelper] noInternetError].code);
        }
        return;
    }
    
    //Save the image to device temp location and get the path.
    NSData *imageData =  UIImageJPEGRepresentation(img, 1.0);
    NSString * timeStampValue = [NSString stringWithFormat:@"%ld", (long)[[NSDate date] timeIntervalSince1970]];
    NSString *filename = [NSString stringWithFormat:@"image%@.jpg", timeStampValue];
    NSArray *paths = NSSearchPathForDirectoriesInDomains(NSDocumentDirectory, NSUserDomainMask, YES);
    NSString *filePath = [[paths objectAtIndex:0] stringByAppendingPathComponent:filename];
    [imageData writeToFile:filePath atomically:YES];
    NSURL *fileURL = [[NSURL alloc] initFileURLWithPath:filePath];
    
    NSString *urlString = [NSString stringWithFormat:@"%@%@",MainURL, SaveImageInGalleryPostURL];
    
    AFHTTPRequestSerializer *requestSerializer = [AFHTTPRequestSerializer serializer];
    
    [requestSerializer setValue:@"multipart/form-data" forHTTPHeaderField:@"content-type"];
    [requestSerializer setValue:[[UserModel sharedInstance] accessToken] forHTTPHeaderField:@"jwt"];
    
    NSURLSessionConfiguration *configuration = [NSURLSessionConfiguration defaultSessionConfiguration];
    
    AFURLSessionManager *manager = [[AFURLSessionManager alloc] initWithSessionConfiguration:configuration];
    
    manager.responseSerializer = [AFHTTPResponseSerializer serializer];
    
    manager.securityPolicy.validatesDomainName = NO;
    
    NSMutableURLRequest *request = [requestSerializer multipartFormRequestWithMethod:@"POST" URLString:urlString parameters:nil constructingBodyWithBlock:^(id<AFMultipartFormData> formData) {
        
        [formData appendPartWithFileURL:fileURL name:@"image" fileName:filename mimeType:@"image/jpeg" error:nil];
        [formData appendPartWithFormData:[@(isPrivate).stringValue dataUsingEncoding:NSUTF8StringEncoding] name:@"privacyStatus"];
        
    } error:nil];
    
    [request setTimeoutInterval:10000];
    
    NSURLSessionUploadTask *uploadTask;
    
    uploadTask = [manager
                  uploadTaskWithStreamedRequest:request
                  progress:^(NSProgress * _Nonnull uploadProgress) {
                      
                      dispatch_async(dispatch_get_main_queue(), ^{
                          //Update the progress view
                          NSLog(@"show progress here...");
                      });
                  }
                  completionHandler:^(NSURLResponse * _Nonnull response, id  _Nullable responseObject, NSError * _Nullable error) {
                      if (!error) {
                          NSHTTPURLResponse *responseCode = (NSHTTPURLResponse *)response;
                          NSInteger statusCode = [responseCode statusCode];
                          NSLog(@"RESPONSE CODE: %li", (long)statusCode);
                          
                          if( completion ){
                              completion(nil, (int)statusCode);
                          }
                      } else {
                          NSHTTPURLResponse *responseCode = (NSHTTPURLResponse *)response;
                          NSInteger statusCode = [responseCode statusCode];
                          NSLog(@"RESPONSE CODE: %li", (long)statusCode);
                          
                          if( completion ){
                              if(response){
                                  completion(error, (int)statusCode);
                              }else{
                                  completion(error, (int)error.code);
                              }
                          }
                      }
                      
                  }];
    
    [uploadTask resume];
    
}

- (void) updateImagePrivacy:(int)isPrivate forImage:(NSString *)identifier withCompletion: (void(^)(NSError *error,  int statusCode))completion{
    
    if([[NetworkManager sharedInstance] isConnectionOffline]){
        if(completion){
            completion([[Helper sharedHelper] noInternetError], (int)[[Helper sharedHelper] noInternetError].code);
        }
        return;
    }
    
    NSString *urlString = [NSString stringWithFormat:@"%@%@/%@/privacyStatus/%d",MainURL, UpdateImageFromGalleryPatchURL, identifier, isPrivate];
    
    AFHTTPSessionManager *manager = [[AFHTTPSessionManager manager] initWithSessionConfiguration:[[Helper sharedHelper] sessionConfiguration]];
    [manager.requestSerializer setValue:[[UserModel sharedInstance] accessToken] forHTTPHeaderField:@"jwt"];
    
    [manager PATCH:urlString parameters:nil success:^(NSURLSessionDataTask * _Nonnull task, id  _Nullable responseObject) {
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

- (void) deleteImage:(NSString *)identifier withCompletion: (void(^)(NSError *error,  int statusCode))completion{
    if([[NetworkManager sharedInstance] isConnectionOffline]){
        if(completion){
            completion([[Helper sharedHelper] noInternetError], (int)[[Helper sharedHelper] noInternetError].code);
        }
        return;
    }
    
    NSString *urlString = [NSString stringWithFormat:@"%@%@/%@",MainURL, DeleteImageFromGalleryDeleteURL, identifier];
    
    AFHTTPSessionManager *manager = [[AFHTTPSessionManager manager] initWithSessionConfiguration:[[Helper sharedHelper] sessionConfiguration]];
    [manager.requestSerializer setValue:[[Helper sharedHelper] authenticationToken] forHTTPHeaderField:@"Authorization"];
    
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
