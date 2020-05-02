//
//  SingleModuleTableViewCell.h
//  XSInfinity
//
//  Created by Joseph Marvin Magdadaro on 6/4/18.
//  Copyright © 2018 Joseph Marvin Magdadaro. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface SingleModuleTableViewCell : UITableViewCell
@property (weak, nonatomic) IBOutlet UIView *imgShadowView;
@property (weak, nonatomic) IBOutlet UIImageView *imgView;
@property (weak, nonatomic) IBOutlet UIButton *heartBtn;
@property (weak, nonatomic) IBOutlet UILabel *exerciseNameLbl;
@property (weak, nonatomic) IBOutlet UIButton *lockBtn;
@property (weak, nonatomic) IBOutlet UIView *difficultyColorView;
@property (weak, nonatomic) IBOutlet UILabel *setsLbl;
@property (weak, nonatomic) IBOutlet UILabel *setsValueLbl;
@property (weak, nonatomic) IBOutlet UILabel *repsOrTimesLbl;
@property (weak, nonatomic) IBOutlet UILabel *repsOrTimesValueLbl;
@property (weak, nonatomic) IBOutlet UILabel *timesLbl;
@property (weak, nonatomic) IBOutlet UILabel *timesValueLbl;
@property (weak, nonatomic) IBOutlet UIView *subContentView;

@end
