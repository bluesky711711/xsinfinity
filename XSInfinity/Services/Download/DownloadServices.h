//
//  DownloadServices.h
//  XSInfinity
//
//  Created by Joseph Marvin Magdadaro on 6/19/18.
//  Copyright © 2018 Joseph Marvin Magdadaro. All rights reserved.
//

#import <Foundation/Foundation.h>

@interface DownloadServices : NSObject

+ (DownloadServices *) sharedInstance;

/**
 * Download video from URL
 *
 * Completion: Bool - downloaded or not downloaded
 */
- (void) downloadVideoFromURL:(NSString *)url setFileName:(NSString *)fileName withCompletion:(void(^)(NSError *error,  BOOL downloaded))completion;

@end


