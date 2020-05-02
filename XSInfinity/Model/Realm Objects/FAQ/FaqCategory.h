//
//  FaqCategory.h
//  XSInfinity
//
//  Created by Jerk Nino Magdadaro on 26/08/2018.
//  Copyright © 2018 Jerk Magz. All rights reserved.
//

#import "RLMObject.h"

@interface FaqCategory : RLMObject
@property (nonatomic,strong) NSString *identifier;
@property (nonatomic,strong) NSString *title;
//@property (nonatomic,strong) NSArray *faqs;

@end
