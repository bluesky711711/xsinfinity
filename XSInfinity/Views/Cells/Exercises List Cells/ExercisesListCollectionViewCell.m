//
//  ExercisesListCollectionViewCell.m
//  XSInfinity
//
//  Created by Joseph Marvin Magdadaro on 6/30/18.
//  Copyright © 2018 Joseph Marvin Magdadaro. All rights reserved.
//

#import "ExercisesListCollectionViewCell.h"
#import "Fonts.h"

@implementation ExercisesListCollectionViewCell

- (void)awakeFromNib {
    [super awakeFromNib];
    // Initialization code
    
    self.exerciseNameLbl.font = [[Fonts sharedFonts] normalFont];
}

@end
