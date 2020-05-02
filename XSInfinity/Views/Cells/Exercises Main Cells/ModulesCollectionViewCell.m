//
//  ModulesCollectionViewCell.m
//  XSInfinity
//
//  Created by Joseph Marvin Magdadaro on 6/5/18.
//  Copyright © 2018 Joseph Marvin Magdadaro. All rights reserved.
//

#import "ModulesCollectionViewCell.h"
#import "Colors.h"
#import "Fonts.h"
#import "TranslationsModel.h"

@implementation ModulesCollectionViewCell

- (void)awakeFromNib {
    [super awakeFromNib];
    
    self.easyView.layer.cornerRadius = 5.0;
    self.easyView.layer.borderWidth = 1.0;
    self.easyView.layer.borderColor = [[[Colors sharedColors] easyColor] CGColor];
    self.easyView.clipsToBounds = YES;
    
    self.mediumView.layer.cornerRadius = 5.0;
    self.mediumView.layer.borderWidth = 1.0;
    self.mediumView.layer.borderColor = [[[Colors sharedColors] mediumColor] CGColor];
    self.mediumView.clipsToBounds = YES;
    
    self.hardView.layer.cornerRadius = 5.0;
    self.hardView.layer.borderWidth = 1.0;
    self.hardView.layer.borderColor = [[[Colors sharedColors] hardColor] CGColor];
    self.hardView.clipsToBounds = YES;
    
    self.nameLbl.font = [[Fonts sharedFonts] titleFontBold];
    self.definitionLbl.font = [[Fonts sharedFonts] normalFont];
    self.easyLbl.font = [[Fonts sharedFonts] smallFontBold];
    self.easyValueLbl.font = [[Fonts sharedFonts] normalFont];
    self.mediumLbl.font = [[Fonts sharedFonts] smallFontBold];
    self.mediumValueLbl.font = [[Fonts sharedFonts] normalFont];
    self.hardLbl.font = [[Fonts sharedFonts] smallFontBold];
    self.hardValueLbl.font = [[Fonts sharedFonts] normalFont];
    self.completedLbl.font = [[Fonts sharedFonts] normalFont];
    self.lockedNameLbl.font = [[Fonts sharedFonts] titleFont];
    self.activateLbl.font = [[Fonts sharedFonts] titleFontBold];
}

@end
