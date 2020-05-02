//
//  ModulesCollectionViewCell.h
//  XSInfinity
//
//  Created by Joseph Marvin Magdadaro on 6/5/18.
//  Copyright © 2018 Joseph Marvin Magdadaro. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface ModulesCollectionViewCell : UICollectionViewCell
@property (weak, nonatomic) IBOutlet UIView *shadowView;
@property (weak, nonatomic) IBOutlet UILabel *nameLbl;
@property (weak, nonatomic) IBOutlet UILabel *definitionLbl;
@property (weak, nonatomic) IBOutlet UIButton *moduleBtn;
@property (weak, nonatomic) IBOutlet UIView *easyView;
@property (weak, nonatomic) IBOutlet UILabel *easyLbl;
@property (weak, nonatomic) IBOutlet UILabel *easyValueLbl;
@property (weak, nonatomic) IBOutlet UIButton *easyBtn;
@property (weak, nonatomic) IBOutlet UIView *mediumView;
@property (weak, nonatomic) IBOutlet UILabel *mediumLbl;
@property (weak, nonatomic) IBOutlet UILabel *mediumValueLbl;
@property (weak, nonatomic) IBOutlet UIButton *mediumBtn;
@property (weak, nonatomic) IBOutlet UIView *hardView;
@property (weak, nonatomic) IBOutlet UILabel *hardLbl;
@property (weak, nonatomic) IBOutlet UILabel *hardValueLbl;
@property (weak, nonatomic) IBOutlet UIButton *hardBtn;
@property (weak, nonatomic) IBOutlet UILabel *completedLbl;
@property (weak, nonatomic) IBOutlet UIView *lockedView;
@property (weak, nonatomic) IBOutlet UIImageView *imgView;
@property (weak, nonatomic) IBOutlet UILabel *lockedNameLbl;
@property (weak, nonatomic) IBOutlet UILabel *activateLbl;
@property (weak, nonatomic) IBOutlet UIButton *lockedBtn;

@end
