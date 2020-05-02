//
//  SkeletonView.h
//  XSInfinity
//
//  Created by Jerk Nino Magdadaro on 28/08/2018.
//  Copyright © 2018 Jerk Magz. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface SkeletonView : UIView

- (void)addSkeletonFor:(UIView *)view isText:(BOOL)isText;

- (void)addSkeletonOn:(UIView *)subView for:(UIView *)view isText:(BOOL)isText;

- (void)addSkeletonOnExercisesModulesCollectionViewWithBounds:(CGRect)bounds withCellSize:(CGSize)cellSize;
- (void)addSkeletonOnExercisesCollectionViewWithBounds:(CGRect)bounds withCellSize:(CGSize)cellSize;

- (void)addSkeletonOnHabitsCollectionViewWithBounds:(CGRect)bounds withCellSize:(CGSize)cellSize;

- (void)addSkeletonOnExerciseListCollectionView:(UICollectionView *)view withCellSize:(CGSize)cellSize;

- (void)addSkeletonOnChartViewWithBounds:(CGRect)bounds;
- (void)addSkeletonOnCalendarCollectionViewWithBounds:(CGRect)bounds withCellSize:(CGSize)cellSize;
- (void)addSkeletonOnRankingTableViewWithBounds:(CGRect)bounds withCellHeight:(float)height;

- (void)addSkeletonOnProfileGalleryCollectionView:(UICollectionView *)view withCellSize:(CGSize)cellSize;

- (void)addSkeletonOnFaqCollectionViewWithBounds:(CGRect)bounds withCellSize:(CGSize)cellSize;

- (void)addSkeletonHeadsUpTableViewWithBounds:(CGRect)bounds;

- (void)addSkeletonOnOverlayViewWithBounds:(CGRect)bounds;

- (void)remove;
@end
