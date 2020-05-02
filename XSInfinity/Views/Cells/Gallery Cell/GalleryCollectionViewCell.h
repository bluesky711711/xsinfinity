//
//  GalleryCollectionViewCell.h
//  XSInfinity
//
//  Created by Joseph Marvin Magdadaro on 7/11/18.
//  Copyright © 2018 Jerk Magz. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface GalleryCollectionViewCell : UICollectionViewCell
@property (weak, nonatomic) IBOutlet UIImageView *imgView;
@property (weak, nonatomic) IBOutlet UILabel *dateLbl;
@property (weak, nonatomic) IBOutlet UIButton *optionBtn;

@end
