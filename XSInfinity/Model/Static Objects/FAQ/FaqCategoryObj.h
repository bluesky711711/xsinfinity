//
//  FaqCategoryObj.h
//  XSInfinity
//
//  Created by Jerk Nino Magdadaro on 27/08/2018.
//  Copyright © 2018 Jerk Magz. All rights reserved.
//

#import <Foundation/Foundation.h>

@interface FaqCategoryObj : NSObject
@property (nonatomic,strong) NSString *identifier;
@property (nonatomic,strong) NSString *title;
@property (nonatomic,strong) NSArray *faqs;

@end
