//
//  CommunityRankingTableViewCell.m
//  XSInfinity
//
//  Created by Joseph Marvin Magdadaro on 7/5/18.
//  Copyright © 2018 Jerk Magz. All rights reserved.
//

#import "CommunityRankingTableViewCell.h"
#import "Helper.h"
#import "Fonts.h"
#import "Colors.h"

@implementation CommunityRankingTableViewCell

- (void)awakeFromNib {
    [super awakeFromNib];
    
    [self.imgView.layer setBorderColor: [[UIColor whiteColor] CGColor]];
    [self.imgView.layer setBorderWidth: 3.0];
    
    self.rankView.backgroundColor = [[Colors sharedColors] purpleColor];
    
    self.nameLbl.font = [[Fonts sharedFonts] normalFontBold];
    self.countryLbl.font = [[Fonts sharedFonts] smallFont];
    self.rankLbl.font = [[Fonts sharedFonts] titleFontBold];
    
}

- (void)setSelected:(BOOL)selected animated:(BOOL)animated {
    [super setSelected:selected animated:animated];

    // Configure the view for the selected state
}

@end
