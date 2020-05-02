//
//  SingleModuleHeaderTableViewCell.h
//  XSInfinity
//
//  Created by Joseph Marvin Magdadaro on 6/4/18.
//  Copyright © 2018 Joseph Marvin Magdadaro. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface SingleModuleHeaderTableViewCell : UITableViewCell
@property (weak, nonatomic) IBOutlet UIView *shadowView;
@property (weak, nonatomic) IBOutlet UIView *subContentView;
@property (weak, nonatomic) IBOutlet UIImageView *imgView;
@property (weak, nonatomic) IBOutlet UILabel *moduleNameLbl;
@property (weak, nonatomic) IBOutlet UIButton *howToBtn;
@property (weak, nonatomic) IBOutlet UILabel *easyLbl;
@property (weak, nonatomic) IBOutlet UILabel *easyValueLbl;
@property (weak, nonatomic) IBOutlet UILabel *medLbl;
@property (weak, nonatomic) IBOutlet UILabel *medValueLbl;
@property (weak, nonatomic) IBOutlet UILabel *hardLbl;
@property (weak, nonatomic) IBOutlet UILabel *hardValueLbl;
@property (weak, nonatomic) IBOutlet UIView *easyValueView;
@property (weak, nonatomic) IBOutlet UIView *medValueView;
@property (weak, nonatomic) IBOutlet UIView *hardValueView;
@property (weak, nonatomic) IBOutlet NSLayoutConstraint *easyValueViewWidthConstraint;
@property (weak, nonatomic) IBOutlet NSLayoutConstraint *medValueViewWidthConstraint;
@property (weak, nonatomic) IBOutlet NSLayoutConstraint *hardValueViewWidthConstraint;

@end
