//
//  GalleryCollectionViewCell.m
//  XSInfinity
//
//  Created by Joseph Marvin Magdadaro on 7/11/18.
//  Copyright © 2018 Jerk Magz. All rights reserved.
//

#import "GalleryCollectionViewCell.h"
#import "Fonts.h"

@implementation GalleryCollectionViewCell

- (void)awakeFromNib {
    [super awakeFromNib];
    
    self.dateLbl.font = [[Fonts sharedFonts] normalFont];
}

@end
