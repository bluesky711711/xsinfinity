//
//  HabitsCollectionViewCell.m
//  Habits
//
//  Created by Joseph Marvin Magdadaro on 2/25/18.
//  Copyright © 2018 Joseph Marvin Magdadaro. All rights reserved.
//

#import "HabitsCollectionViewCell.h"
#import "Fonts.h"
#import "TranslationsModel.h"

@implementation HabitsCollectionViewCell

- (void)awakeFromNib {
    [super awakeFromNib];
    // Initialization code
    
    self.habitNum.font = [[Fonts sharedFonts] normalFont];
    self.title.font = [[Fonts sharedFonts] titleFontBold];
    self.statusLbl.font = [[Fonts sharedFonts] normalFont];
    self.remarks.font = [[Fonts sharedFonts] normalFont];
    
    [self.lockBtn setImage:[UIImage imageNamed:@"modulelocked"] forState:UIControlStateNormal];
    [self.lockBtn setTintColor:[UIColor whiteColor]];
}

@end
