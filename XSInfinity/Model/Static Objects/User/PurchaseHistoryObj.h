//
//  PurchaseHistoryObj.h
//  XSInfinity
//
//  Created by Joseph Marvin Magdadaro on 7/31/18.
//  Copyright © 2018 Jerk Magz. All rights reserved.
//

#import <Foundation/Foundation.h>

@interface PurchaseHistoryObj : NSObject
@property (nonatomic,strong) NSString *moduleName;
@property (nonatomic,strong) NSString *purchaseDate;
@property float price;

@end
