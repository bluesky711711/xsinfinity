//
//  ForgotPasswordViewController.h
//  XSInfinity
//
//  Created by Joseph Marvin Magdadaro on 6/11/18.
//  Copyright © 2018 Joseph Marvin Magdadaro. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface ForgotPasswordViewController : UIViewController
@property BOOL isFromDeepLink;
@property (nonatomic, retain) NSString *code;
@property (nonatomic, retain) NSString *userName;
@end
