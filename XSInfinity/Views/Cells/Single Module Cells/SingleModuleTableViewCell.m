//
//  SingleModuleTableViewCell.m
//  XSInfinity
//
//  Created by Joseph Marvin Magdadaro on 6/4/18.
//  Copyright © 2018 Joseph Marvin Magdadaro. All rights reserved.
//

#import "SingleModuleTableViewCell.h"
#import "Fonts.h"
#import "TranslationsModel.h"

@implementation SingleModuleTableViewCell

- (void)awakeFromNib {
    [super awakeFromNib];
    
    self.lockBtn.layer.cornerRadius = CGRectGetWidth(self.lockBtn.frame)/2;
    [self.lockBtn.layer setBorderColor:[[UIColor whiteColor] CGColor]];
    [self.lockBtn.layer setBorderWidth:2.5];
    self.lockBtn.clipsToBounds = YES;
    
    self.heartBtn.backgroundColor = [UIColor clearColor];
  
    self.exerciseNameLbl.font = [[Fonts sharedFonts] normalFont];
    
    self.setsLbl.font = [[Fonts sharedFonts] normalFont];
    self.setsLbl.text = [[TranslationsModel sharedInstance] getTranslationForKey:@"global.sets"];
    
    self.setsValueLbl.font = [[Fonts sharedFonts] normalFont];
    
    self.repsOrTimesLbl.font = [[Fonts sharedFonts] normalFont];
    self.repsOrTimesLbl.text = [[TranslationsModel sharedInstance] getTranslationForKey:@"global.reps"];
    
    self.repsOrTimesValueLbl.font = [[Fonts sharedFonts] normalFont];
    
    self.timesLbl.font = [[Fonts sharedFonts] normalFont];
    self.timesLbl.text = [[TranslationsModel sharedInstance] getTranslationForKey:@"exmodule.timesfinished"];
    
    self.timesValueLbl.font = [[Fonts sharedFonts] normalFont];
    
    self.subContentView.layer.cornerRadius = 5.0;
    self.subContentView.clipsToBounds = YES;
}

- (void)setSelected:(BOOL)selected animated:(BOOL)animated {
    [super setSelected:selected animated:animated];

    // Configure the view for the selected state
}

@end
