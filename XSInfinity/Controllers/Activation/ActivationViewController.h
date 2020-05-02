//
//  ActivationViewController.h
//  XSInfinity
//
//  Created by Joseph Marvin Magdadaro on 6/11/18.
//  Copyright © 2018 Joseph Marvin Magdadaro. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface ActivationViewController : UIViewController
@property BOOL isFromDeepLink, isForResendActivation;
@property (nonatomic, retain) NSString *code;
@property (nonatomic, retain) NSString *userName;
@property (nonatomic, retain) NSString *userPassword;

@end
