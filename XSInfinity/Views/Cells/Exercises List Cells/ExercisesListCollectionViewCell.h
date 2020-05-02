//
//  ExercisesListCollectionViewCell.h
//  XSInfinity
//
//  Created by Joseph Marvin Magdadaro on 6/30/18.
//  Copyright © 2018 Joseph Marvin Magdadaro. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface ExercisesListCollectionViewCell : UICollectionViewCell
@property (weak, nonatomic) IBOutlet UIImageView *imgView;
@property (weak, nonatomic) IBOutlet UIView *screenView;
@property (weak, nonatomic) IBOutlet UIButton *heartBtn;
@property (weak, nonatomic) IBOutlet UIView *difficultyColorView;
@property (weak, nonatomic) IBOutlet UILabel *exerciseNameLbl;

@end
