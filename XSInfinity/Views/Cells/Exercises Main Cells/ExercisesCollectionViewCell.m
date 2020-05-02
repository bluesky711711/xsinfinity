//
//  ExercisesCollectionViewCell.m
//  XSInfinity
//
//  Created by Joseph Marvin Magdadaro on 6/5/18.
//  Copyright © 2018 Joseph Marvin Magdadaro. All rights reserved.
//

#import "ExercisesCollectionViewCell.h"
#import "Colors.h"
#import "Fonts.h"
#import "TranslationsModel.h"

@implementation ExercisesCollectionViewCell

- (void)awakeFromNib {
    [super awakeFromNib];
    self.pointsView.backgroundColor = [[Colors sharedColors] purpleColor];
    
    self.statesBtn.layer.cornerRadius = CGRectGetWidth(self.statesBtn.frame)/2;
    [self.statesBtn.layer setBorderColor:[[UIColor whiteColor] CGColor]];
    [self.statesBtn.layer setBorderWidth:2.5];
    self.statesBtn.clipsToBounds = YES;
    
    self.exerciseNameLbl.font = [[Fonts sharedFonts] normalFont];
    self.pointsLbl.font = [[Fonts sharedFonts] normalFont];
    self.pointsValueLbl.font = [[Fonts sharedFonts] headerFont];
    self.repsOrTimesLbl.font = [[Fonts sharedFonts] normalFont];
    self.repsOrTimesValueLbl.font = [[Fonts sharedFonts] normalFont];
    self.setsLbl.font = [[Fonts sharedFonts] normalFont];
    self.setsValueLbl.font = [[Fonts sharedFonts] normalFont];
}

@end
