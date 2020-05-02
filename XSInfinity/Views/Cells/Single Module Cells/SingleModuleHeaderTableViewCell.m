//
//  SingleModuleHeaderTableViewCell.m
//  XSInfinity
//
//  Created by Joseph Marvin Magdadaro on 6/4/18.
//  Copyright © 2018 Joseph Marvin Magdadaro. All rights reserved.
//

#import "SingleModuleHeaderTableViewCell.h"
#import "Fonts.h"
#import "Colors.h"
#import "TranslationsModel.h"

@implementation SingleModuleHeaderTableViewCell

- (void)awakeFromNib {
    [super awakeFromNib];
    
    self.moduleNameLbl.font = [[Fonts sharedFonts] titleFont];
    
    self.howToBtn.titleLabel.font = [[Fonts sharedFonts] titleFont];
    [self.howToBtn setTitle:[[TranslationsModel sharedInstance] getTranslationForKey:@"exmodule.howtouseit"] forState:UIControlStateNormal];
    
    self.easyLbl.font = [[Fonts sharedFonts] normalFont];
    self.easyLbl.text = [[TranslationsModel sharedInstance] getTranslationForKey:@"global.difficultyeasy"];
    
    self.easyValueLbl.font = [[Fonts sharedFonts] normalFont];
    
    self.medLbl.font = [[Fonts sharedFonts] normalFont];
    self.medLbl.text = [[TranslationsModel sharedInstance] getTranslationForKey:@"global.difficultymedium"];
    
    self.medValueLbl.font = [[Fonts sharedFonts] normalFont];
    
    self.hardLbl.font = [[Fonts sharedFonts] normalFont];
    self.hardLbl.text = [[TranslationsModel sharedInstance] getTranslationForKey:@"global.difficultyhard"];
    
    self.hardValueLbl.font = [[Fonts sharedFonts] normalFont];
    
    self.easyValueView.backgroundColor = [[Colors sharedColors] easyColor];
    self.medValueView.backgroundColor = [[Colors sharedColors] mediumColor];
    self.hardValueView.backgroundColor = [[Colors sharedColors] hardColor];
}

- (void)setSelected:(BOOL)selected animated:(BOOL)animated {
    [super setSelected:selected animated:animated];

    // Configure the view for the selected state
}

@end
