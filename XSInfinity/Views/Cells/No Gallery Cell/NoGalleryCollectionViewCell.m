//
//  NoGalleryCollectionViewCell.m
//  XSInfinity
//
//  Created by Joseph Marvin Magdadaro on 28/11/2018.
//  Copyright © 2018 Jerk Magz. All rights reserved.
//

#import "NoGalleryCollectionViewCell.h"
#import "Fonts.h"
#import "TranslationsModel.h"

@implementation NoGalleryCollectionViewCell

- (void)awakeFromNib {
    [super awakeFromNib];
    
    self.addImageLbl.font = [[Fonts sharedFonts] normalFont];
    self.addImageLbl.text = [[TranslationsModel sharedInstance] getTranslationForKey:@"user.addfirstimage"];
}

@end
