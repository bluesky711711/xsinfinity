//
//  SingleExerciseSetTableViewCell.h
//  XSInfinity
//
//  Created by Jerk Nino Magdadaro on 26/09/2018.
//  Copyright © 2018 Jerk Magz. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface SingleExerciseSetTableViewCell : UITableViewCell
@property (weak, nonatomic) IBOutlet UIView *shadowView;
@property (weak, nonatomic) IBOutlet UIView *setView;
@property (weak, nonatomic) IBOutlet UILabel *setLbl;
@property (weak, nonatomic) IBOutlet UILabel *setValueLbl;
@property (weak, nonatomic) IBOutlet UILabel *setRepsOrTimesLbl;
@property (weak, nonatomic) IBOutlet UILabel *setRepsOrTimesValueLbl;
@property (weak, nonatomic) IBOutlet UIButton *setBtn;

@end
