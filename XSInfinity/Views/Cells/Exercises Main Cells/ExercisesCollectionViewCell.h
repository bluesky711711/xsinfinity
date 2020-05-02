//
//  ExercisesCollectionViewCell.h
//  XSInfinity
//
//  Created by Joseph Marvin Magdadaro on 6/5/18.
//  Copyright © 2018 Joseph Marvin Magdadaro. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface ExercisesCollectionViewCell : UICollectionViewCell
@property (weak, nonatomic) IBOutlet UIView *shadowView;
@property (weak, nonatomic) IBOutlet UIImageView *imgView;
@property (weak, nonatomic) IBOutlet UIView *screenView;
@property (weak, nonatomic) IBOutlet UIView *pointsView;
@property (weak, nonatomic) IBOutlet UILabel *exerciseNameLbl;
@property (weak, nonatomic) IBOutlet UILabel *pointsLbl;
@property (weak, nonatomic) IBOutlet UILabel *pointsValueLbl;
@property (weak, nonatomic) IBOutlet UILabel *repsOrTimesLbl;
@property (weak, nonatomic) IBOutlet UILabel *repsOrTimesValueLbl;
@property (weak, nonatomic) IBOutlet UILabel *setsLbl;
@property (weak, nonatomic) IBOutlet UILabel *setsValueLbl;
@property (weak, nonatomic) IBOutlet UIButton *statesBtn;

@end
