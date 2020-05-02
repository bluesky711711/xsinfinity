//
//  CommunityRankingTableViewCell.h
//  XSInfinity
//
//  Created by Joseph Marvin Magdadaro on 7/5/18.
//  Copyright © 2018 Jerk Magz. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface CommunityRankingTableViewCell : UITableViewCell
@property (weak, nonatomic) IBOutlet UIView *infoView;
@property (weak, nonatomic) IBOutlet UILabel *nameLbl;
@property (weak, nonatomic) IBOutlet UILabel *countryLbl;
@property (weak, nonatomic) IBOutlet UIView *rankView;
@property (weak, nonatomic) IBOutlet UILabel *rankLbl;
@property (weak, nonatomic) IBOutlet UIImageView *imgView;

@end
