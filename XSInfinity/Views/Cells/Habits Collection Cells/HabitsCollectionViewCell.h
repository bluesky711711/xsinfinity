//
//  HabitsCollectionViewCell.h
//  Habits
//
//  Created by Joseph Marvin Magdadaro on 2/25/18.
//  Copyright © 2018 Joseph Marvin Magdadaro. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface HabitsCollectionViewCell : UICollectionViewCell

@property (strong, nonatomic) IBOutlet UIView *habitView;
@property (nonatomic, strong) IBOutlet UIButton *iconBtn;
@property (nonatomic, strong) IBOutlet UIButton *lockBtn;
@property (nonatomic, strong) IBOutlet UIImageView *imgView;
@property (nonatomic, strong) IBOutlet UILabel *habitNum;
@property (nonatomic, strong) IBOutlet UILabel *title;
@property (nonatomic, strong) IBOutlet UILabel *remarks;
@property (nonatomic, strong) IBOutlet UIView *statusView;
@property (nonatomic, strong) IBOutlet UILabel *statusLbl;
@property (nonatomic, strong) IBOutlet UIButton *finishedBtn;
@end
