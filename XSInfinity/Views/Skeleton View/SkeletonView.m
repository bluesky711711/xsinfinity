//
//  SkeletonView.m
//  XSInfinity
//
//  Created by Jerk Nino Magdadaro on 28/08/2018.
//  Copyright © 2018 Jerk Magz. All rights reserved.
//

#import "SkeletonView.h"
#import "Colors.h"

@implementation SkeletonView

- (id)initWithFrame:(CGRect)frame
{
    self = [super initWithFrame:frame];
    if (self) {
        // Initialization code
    }
    return self;
}

- (void)addSkeletonFor:(UIView *)view isText:(BOOL)isText{
    UIView *v = [[UIView alloc] init];
    
    if (isText){
        UIView *bgView = [[UIView alloc] initWithFrame:CGRectMake(view.frame.origin.x, view.frame.origin.y + ((view.frame.size.height/2)-10), view.frame.size.width, (view.frame.size.height/1.5))];
        bgView.backgroundColor = [UIColor whiteColor];
        bgView.layer.cornerRadius = view.layer.cornerRadius;
        [self addSubview:bgView];
        
        v.frame = bgView.frame;
    }else {
        
        UIView *bgView = [[UIView alloc] initWithFrame:view.frame];
        bgView.backgroundColor = [UIColor whiteColor];
        bgView.layer.cornerRadius = view.layer.cornerRadius;
        [self addSubview:bgView];
        
        v.frame = view.frame;
    }
    
    v.layer.cornerRadius = view.layer.cornerRadius;
    v.backgroundColor = [[UIColor lightGrayColor] colorWithAlphaComponent:0.5];
    [self addSubview:v];
    [self animateSkeletonForView:v];
}

- (void)addSkeletonOn:(UIView *)subView for:(UIView *)view isText:(BOOL)isText{
    UIView *v = [[UIView alloc] init];
    
    UIView *contentView = [[UIView alloc] initWithFrame:subView.frame];
    contentView.backgroundColor = [UIColor clearColor];
    [self addSubview:contentView];
    
    UIView *bgView = [[UIView alloc] initWithFrame:view.frame];
    bgView.backgroundColor = [UIColor whiteColor];
    bgView.layer.cornerRadius = view.layer.cornerRadius;
    [contentView addSubview:bgView];
    
    if (isText){
        v.frame = CGRectMake(view.frame.origin.x, view.frame.origin.y + ((view.frame.size.height/2)-8), view.frame.size.width, 16);
    }else {
        v.frame = view.frame;
    }
    
    v.layer.cornerRadius = view.layer.cornerRadius;
    v.backgroundColor = [[UIColor lightGrayColor] colorWithAlphaComponent:0.5];
    [contentView addSubview:v];
    
    [self animateSkeletonForView:v];
}

- (void)addSkeletonOnExercisesModulesCollectionViewWithBounds:(CGRect)bounds withCellSize:(CGSize)cellSize{
    UIView *v = [[UIView alloc] initWithFrame:bounds];
    
    int numOfCells = 2;
    
    float leftMargin = 23;
    
    for (int i=0; i<numOfCells; i++) {
        
        int cellW = cellSize.width-16;
        int cellH = cellSize.height-16;
        
        UIView *cellView = [[UIView alloc] initWithFrame:CGRectMake(leftMargin, 8, cellW, cellH)];
        cellView.layer.cornerRadius = 5.0;
        cellView.backgroundColor = [UIColor whiteColor];
        [v addSubview:cellView];
        
        int lblH = 30;
        UILabel *nameLbl = [[UILabel alloc] initWithFrame:CGRectMake(10, 10, cellW/1.5, lblH)];
        UILabel *descLbl = [[UILabel alloc] initWithFrame:CGRectMake(10, CGRectGetMaxY(nameLbl.frame), cellW/2.5, lblH)];
        
        float btnSize = (cellW-60) /3;
        UIButton *easyBtn = [[UIButton alloc] initWithFrame:CGRectMake(16, cellH-(btnSize+16), btnSize, btnSize)];
        easyBtn.layer.cornerRadius = 5.0;
        UIButton *medBtn = [[UIButton alloc] initWithFrame:CGRectMake(CGRectGetMaxX(easyBtn.frame)+14, cellH-(btnSize+16), btnSize, btnSize)];
        medBtn.layer.cornerRadius = 5.0;
        UIButton *hardBtn = [[UIButton alloc] initWithFrame:CGRectMake(CGRectGetMaxX(medBtn.frame)+14, cellH-(btnSize+16), btnSize, btnSize)];
        hardBtn.layer.cornerRadius = 5.0;
        
        [cellView addSubview:nameLbl];
        [cellView addSubview:descLbl];
        [cellView addSubview:easyBtn];
        [cellView addSubview:medBtn];
        [cellView addSubview:hardBtn];
        [self addSkeletonOnSubView:cellView for:nameLbl isText:YES];
        [self addSkeletonOnSubView:cellView for:descLbl isText:YES];
        [self addSkeletonOnSubView:cellView for:easyBtn isText:NO];
        [self addSkeletonOnSubView:cellView for:medBtn isText:NO];
        [self addSkeletonOnSubView:cellView for:hardBtn isText:NO];
        
        leftMargin = CGRectGetMaxX(cellView.frame) + 18;
    }
    
    [self addSubview:v];
}

- (void)addSkeletonOnExercisesCollectionViewWithBounds:(CGRect)bounds withCellSize:(CGSize)cellSize{
    UIView *v = [[UIView alloc] initWithFrame:bounds];
    
    int numOfCells = 2;
    
    float leftMargin = 15;
    
    for (int i=0; i<numOfCells; i++) {
        
        UIView *cellView = [[UIView alloc] initWithFrame:CGRectMake(leftMargin, 0, cellSize.width, cellSize.height)];
        cellView.backgroundColor = [UIColor clearColor];
        [v addSubview:cellView];
        
        int v1Size = cellSize.width - 20;
        UIView *view1 = [[UIView alloc] initWithFrame:CGRectMake((cellSize.width/2)-(v1Size/2), 10, v1Size, v1Size)];
        view1.layer.cornerRadius = 5.0;
        view1.backgroundColor = [UIColor whiteColor];
        [cellView addSubview:view1];
        
        int lblH = 30;
        UILabel *nameLbl = [[UILabel alloc] initWithFrame:CGRectMake(10, 10, cellSize.width/1.5, lblH)];
        [view1 addSubview:nameLbl];
        [self addSkeletonOnSubView:view1 for:nameLbl isText:YES];
        
        float v2h = 80;
        float v2w = cellSize.width-40;
        UIView *view2 = [[UIView alloc] initWithFrame:CGRectMake((cellSize.width/2)-(v2w/2), cellSize.height-(v2h+10), v2w, v2h)];
        view2.layer.cornerRadius = 5.0;
        view2.backgroundColor = [UIColor whiteColor];
        [cellView addSubview:view2];
        
        UIView *animateView = [[UIView alloc] initWithFrame:CGRectMake(0, 0, v2w, v2h)];
        animateView.layer.cornerRadius = 5.0;
        [view2 addSubview:animateView];
        
        float v2LblH = 16;
        UILabel *descLbl = [[UILabel alloc] initWithFrame:CGRectMake(10, 16, CGRectGetWidth(view2.frame)/1.5, v2LblH)];
        descLbl.backgroundColor = [UIColor whiteColor];
        [view2 addSubview:descLbl];
        
        UILabel *desc2Lbl = [[UILabel alloc] initWithFrame:CGRectMake(10, v2LblH+32, CGRectGetWidth(view2.frame)/2, v2LblH)];
        desc2Lbl.backgroundColor = [UIColor whiteColor];
        [view2 addSubview:desc2Lbl];
        
        [self addSkeletonOnSubView:view2 for:animateView isText:NO];
        
        leftMargin = CGRectGetMaxX(cellView.frame) + 10;
    }
    
    [self addSubview:v];
}

- (void)addSkeletonOnHabitsCollectionViewWithBounds:(CGRect)bounds withCellSize:(CGSize)cellSize{
    UIView *v = [[UIView alloc] initWithFrame:bounds];
    
    int numOfCells = 2;
    
    float leftMargin = 0;
    
    for (int i=0; i<numOfCells; i++) {
        
        UIView *cellView = [[UIView alloc] initWithFrame:CGRectMake(leftMargin, 0, cellSize.width, cellSize.height)];
        cellView.backgroundColor = [UIColor clearColor];
        [v addSubview:cellView];
        
        int v1h = 190;
        int v1w = cellSize.width - 60;
        UIView *view1 = [[UIView alloc] initWithFrame:CGRectMake(40, (cellSize.height/2)-(v1h/2), v1w, v1h)];
        view1.layer.cornerRadius = 5.0;
        view1.backgroundColor = [UIColor whiteColor];
        [cellView addSubview:view1];
        
        int lblH = 30;
        UILabel *nameLbl = [[UILabel alloc] initWithFrame:CGRectMake(110, 40, v1w/2, lblH)];
        [view1 addSubview:nameLbl];
        [self addSkeletonOnSubView:view1 for:nameLbl isText:YES];
        
        UILabel *descLbl = [[UILabel alloc] initWithFrame:CGRectMake(110, CGRectGetMaxY(nameLbl.frame), v1w/2, lblH)];
        [view1 addSubview:descLbl];
        [self addSkeletonOnSubView:view1 for:descLbl isText:YES];
        
        UILabel *statusLbl = [[UILabel alloc] initWithFrame:CGRectMake(110, CGRectGetMaxY(descLbl.frame)+20, v1w/3, lblH)];
        [view1 addSubview:statusLbl];
        [self addSkeletonOnSubView:view1 for:statusLbl isText:YES];
        
        float v2h = 100;
        float v2w = 110;
        UIView *view2 = [[UIView alloc] initWithFrame:CGRectMake(20, CGRectGetMinY(view1.frame)+16, v2w, v2h)];
        view2.layer.cornerRadius = 5.0;
        view2.backgroundColor = [UIColor whiteColor];
        [cellView addSubview:view2];
        
        UIView *animateView = [[UIView alloc] initWithFrame:CGRectMake(0, 0, v2w, v2h)];
        animateView.layer.cornerRadius = 5.0;
        [view2 addSubview:animateView];
        
        [self addSkeletonOnSubView:view2 for:animateView isText:NO];
        
        leftMargin = CGRectGetMaxX(cellView.frame);
    }
    
    [self addSubview:v];
}

- (void)addSkeletonOnExerciseListCollectionView:(UICollectionView *)view withCellSize:(CGSize)cellSize{
    UIView *v = [[UIView alloc] initWithFrame:view.frame];
    
    int numOfCells = CGRectGetHeight(view.frame) / cellSize.height;
    
    float viewInset = 20;
    int lineSpace = 16;
    
    for (int i=0; i<numOfCells; i++) {
        
        int h = 40;
        UILabel *nameLbl = [[UILabel alloc] initWithFrame:CGRectMake(10, cellSize.height-h, cellSize.width/2.5, h)];
        UIButton *heartBtn = [[UIButton alloc] initWithFrame:CGRectMake(cellSize.width-(26), cellSize.height-h, 16, h)];
        
        UIView *leftView = [[UIView alloc] initWithFrame:CGRectMake(viewInset, lineSpace, cellSize.width, cellSize.height)];
        leftView.layer.cornerRadius = 5.0;
        leftView.backgroundColor = [UIColor whiteColor];
        [v addSubview:leftView];
        
        [leftView addSubview:nameLbl];
        [leftView addSubview:heartBtn];
        [self addSkeletonOnSubView:leftView for:nameLbl isText:YES];
        [self addSkeletonOnSubView:leftView for:heartBtn isText:YES];
        
        UIView *rightView = [[UIView alloc] initWithFrame:CGRectMake(CGRectGetWidth(view.frame)-(cellSize.width+viewInset), lineSpace, cellSize.width, cellSize.height)];
        rightView.layer.cornerRadius = 5.0;
        rightView.backgroundColor = [UIColor whiteColor];
        [v addSubview:rightView];
        
        [rightView addSubview:nameLbl];
        [rightView addSubview:heartBtn];
        [self addSkeletonOnSubView:rightView for:nameLbl isText:YES];
        [self addSkeletonOnSubView:rightView for:heartBtn isText:YES];
        
        lineSpace = CGRectGetMaxY(leftView.frame) + 10;
    }
    
    [self addSubview:v];
}

- (void)addSkeletonOnChartViewWithBounds:(CGRect)bounds{
    UIView *v = [[UIView alloc] initWithFrame:bounds];
    v.backgroundColor = [UIColor whiteColor];
    v.layer.cornerRadius = 5.0;
    
    int lblH = 36;
    
    UILabel *nameLbl = [[UILabel alloc] initWithFrame:CGRectMake(16, 10, bounds.size.width/2, lblH)];
    [v addSubview:nameLbl];
    [self addSkeletonOnSubView:v for:nameLbl isText:YES];
    
    UILabel *addLbl = [[UILabel alloc] initWithFrame:CGRectMake(bounds.size.width-lblH, 10, 20, lblH)];
    [v addSubview:addLbl];
    [self addSkeletonOnSubView:v for:addLbl isText:YES];
    
    int leftMargin = 16;
    for (int i=0; i<5; i++) {
        int h = arc4random() % (int)(bounds.size.height-80);
        
        UILabel *lbl = [[UILabel alloc] initWithFrame:CGRectMake(leftMargin, (bounds.size.height-(h+10)), 20, h)];
        [v addSubview:lbl];
        [self addSkeletonOnSubView:v for:lbl isText:NO];
        
        leftMargin = CGRectGetMaxX(lbl.frame) + ((bounds.size.width-132)/4);
    }
    
    [self addSubview:v];
}

- (void)addSkeletonOnCalendarCollectionViewWithBounds:(CGRect)bounds withCellSize:(CGSize)cellSize{
    UIView *v = [[UIView alloc] initWithFrame:bounds];
    
    int numOfCells = 2;
    
    float leftMargin = 0;
    
    for (int i=0; i<numOfCells; i++) {
        
        UIView *cellView = [[UIView alloc] initWithFrame:CGRectMake(leftMargin, 0, cellSize.width, cellSize.height)];
        cellView.layer.cornerRadius = 5.0;
        cellView.backgroundColor = [UIColor whiteColor];
        [v addSubview:cellView];
        
        int lblH = 36;
        
        UILabel *nameLbl = [[UILabel alloc] initWithFrame:CGRectMake(10, 10, cellSize.width/1.5, lblH)];
        [cellView addSubview:nameLbl];
        [self addSkeletonOnSubView:cellView for:nameLbl isText:YES];
        
        UILabel *descLbl = [[UILabel alloc] initWithFrame:CGRectMake(10, CGRectGetMaxY(nameLbl.frame), cellSize.width/2.5, lblH)];
        [cellView addSubview:descLbl];
        [self addSkeletonOnSubView:cellView for:descLbl isText:YES];
        
        int topMargin = CGRectGetMaxY(descLbl.frame)+20;
        for (int i=0; i<5; i++) {
            
            UILabel *lbl = [[UILabel alloc] initWithFrame:CGRectMake(10, topMargin, cellSize.width-20, lblH)];
            [cellView addSubview:lbl];
            [self addSkeletonOnSubView:cellView for:lbl isText:YES];
            
            topMargin = CGRectGetMaxY(lbl.frame);
        }
        
        leftMargin = CGRectGetMaxX(cellView.frame) + 10;
    }
    
    [self addSubview:v];
}

- (void)addSkeletonOnRankingTableViewWithBounds:(CGRect)bounds withCellHeight:(float)height{
    UIView *v = [[UIView alloc] initWithFrame:bounds];
    
    int numOfCells = bounds.size.height / height;
    
    int lineSpace = 0;
    
    for (int i=0; i<numOfCells; i++) {
        UIView *contentView = [[UIView alloc] initWithFrame:CGRectMake(0, lineSpace, bounds.size.width, height)];
        contentView.backgroundColor = [UIColor clearColor];
        [v addSubview:contentView];
        
        int infoW = bounds.size.width-48;
        int infoH = height-28;
        UIView *infoView = [[UIView alloc] initWithFrame:CGRectMake(36, 14, infoW, infoH)];
        infoView.layer.cornerRadius = 5.0;
        infoView.backgroundColor = [UIColor whiteColor];
        [contentView addSubview:infoView];
        
        float w = infoW/2;
        int h = 30;
        UILabel *nameLbl = [[UILabel alloc] initWithFrame:CGRectMake((infoW/2)-(w/2), (infoH/2)-(h/2), w, h)];
        [infoView addSubview:nameLbl];
        [self addSkeletonOnSubView:infoView for:nameLbl isText:YES];
        
        float imgSize = height-12;
        UIView *imgView = [[UIView alloc] initWithFrame:CGRectMake(16, 6, imgSize, imgSize)];
        imgView.layer.cornerRadius = imgSize/2;
        imgView.backgroundColor = [UIColor whiteColor];
        [contentView addSubview:imgView];
        
        UIView *animateView1 = [[UIView alloc] initWithFrame:CGRectMake(0, 0, imgSize, imgSize)];
        animateView1.layer.cornerRadius = imgSize/2;
        [imgView addSubview:animateView1];
        [self addSkeletonOnSubView:imgView for:animateView1 isText:NO];
        
        float rankH = height-12;
        float rankW = rankH*0.7;
        UIView *rankView = [[UIView alloc] initWithFrame:CGRectMake(bounds.size.width-(rankW+24), 6, rankW, rankH)];
        rankView.layer.cornerRadius = 5.0;
        rankView.backgroundColor = [UIColor whiteColor];
        [contentView addSubview:rankView];
        
        UIView *animateView2 = [[UIView alloc] initWithFrame:CGRectMake(0, 0, rankW, rankH)];
        animateView2.layer.cornerRadius = 5.0;
        [imgView addSubview:animateView2];
        [self addSkeletonOnSubView:rankView for:animateView2 isText:NO];
        
        lineSpace += height;
    }
    
    [self addSubview:v];
}

- (void)addSkeletonOnProfileGalleryCollectionView:(UICollectionView *)view withCellSize:(CGSize)cellSize{
    UIView *v = [[UIView alloc] initWithFrame:view.frame];
    
    int numOfCells = 3;
    
    float leftMargin = 20;
    
    for (int i=0; i<numOfCells; i++) {
        
        int h = 40;
        
        UIView *contentView = [[UIView alloc] initWithFrame:CGRectMake(leftMargin, 10, cellSize.width, cellSize.height)];
        contentView.layer.cornerRadius = 5.0;
        contentView.backgroundColor = [UIColor whiteColor];
        [v addSubview:contentView];
        
        UILabel *nameLbl = [[UILabel alloc] initWithFrame:CGRectMake(10, cellSize.height-h, cellSize.width/2.5, h)];
        [contentView addSubview:nameLbl];
        [self addSkeletonOnSubView:contentView for:nameLbl isText:YES];
        
        UIButton *heartBtn = [[UIButton alloc] initWithFrame:CGRectMake(cellSize.width-(26), cellSize.height-h, 16, h)];
        [contentView addSubview:heartBtn];
        [self addSkeletonOnSubView:contentView for:heartBtn isText:YES];
        
        leftMargin = CGRectGetMaxX(contentView.frame) + 15;
    }
    
    [self addSubview:v];
}

- (void)addSkeletonOnFaqCollectionViewWithBounds:(CGRect)bounds withCellSize:(CGSize)cellSize{
    UIView *v = [[UIView alloc] initWithFrame:bounds];
    
    int numOfCells = 2;
    
    float leftMargin = 30;
    
    for (int i=0; i<numOfCells; i++) {
        
        UIView *cellView = [[UIView alloc] initWithFrame:CGRectMake(leftMargin, 20, cellSize.width, cellSize.height)];
        cellView.layer.cornerRadius = 5.0;
        cellView.backgroundColor = [UIColor whiteColor];
        [v addSubview:cellView];
        
        UIView *bgView = [[UIView alloc] initWithFrame:CGRectMake(0, 0, cellSize.width, 66)];
        bgView.backgroundColor = [[Colors sharedColors] orangeColor];
        [cellView addSubview:bgView];
        
        int lblH = 30;
        UILabel *nameLbl = [[UILabel alloc] initWithFrame:CGRectMake(10, 20, cellSize.width/1.5, lblH)];
        [bgView addSubview:nameLbl];
        [self addSkeletonOnSubView:bgView for:nameLbl isText:YES];
        
        UIView *contentView = [[UIView alloc] initWithFrame:CGRectMake(10, 66, cellSize.width-20, cellSize.height-66)];
        [cellView addSubview:contentView];
        
        int topMargin = 20;
        for (int i=0; i<2; i++) {
            
            UILabel *lbl1 = [[UILabel alloc] initWithFrame:CGRectMake(10, topMargin, cellSize.width/1.3, lblH)];
            [contentView addSubview:lbl1];
            [self addSkeletonOnSubView:contentView for:lbl1 isText:YES];
            
            UILabel *lbl2 = [[UILabel alloc] initWithFrame:CGRectMake(10, CGRectGetMaxY(lbl1.frame), cellSize.width/1.3, lblH)];
            [contentView addSubview:lbl2];
            [self addSkeletonOnSubView:contentView for:lbl2 isText:YES];
            
            UILabel *lbl3 = [[UILabel alloc] initWithFrame:CGRectMake(10, CGRectGetMaxY(lbl2.frame), cellSize.width/1.3, lblH)];
            [contentView addSubview:lbl3];
            [self addSkeletonOnSubView:contentView for:lbl3 isText:YES];
            
            UILabel *lbl4 = [[UILabel alloc] initWithFrame:CGRectMake(10, CGRectGetMaxY(lbl3.frame), cellSize.width/2.5, lblH)];
            [contentView addSubview:lbl4];
            [self addSkeletonOnSubView:contentView for:lbl4 isText:YES];
            
            topMargin = CGRectGetMaxY(lbl4.frame) + 10;
        }
        
        leftMargin = CGRectGetMaxX(cellView.frame) + 20;
    }
    
    [self addSubview:v];
}

- (void)addSkeletonHeadsUpTableViewWithBounds:(CGRect)bounds{
    UIView *v = [[UIView alloc] initWithFrame:bounds];
    
    UIView *contentView = [[UIView alloc] initWithFrame:CGRectMake(0, 0, bounds.size.width, bounds.size.height)];
    contentView.backgroundColor = [UIColor whiteColor];
    [v addSubview:contentView];
    
    float h = bounds.size.height/3;
    float w = bounds.size.width/1.4;
    float leftM = (bounds.size.width/2)-(w/2);
    
    UILabel *lbl1 = [[UILabel alloc] initWithFrame:CGRectMake(leftM, 10, w, h)];
    [contentView addSubview:lbl1];
    [self addSkeletonOnSubView:contentView for:lbl1 isText:YES];
    
    UILabel *lbl2 = [[UILabel alloc] initWithFrame:CGRectMake(leftM, CGRectGetMaxY(lbl1.frame), w, h)];
    [contentView addSubview:lbl2];
    [self addSkeletonOnSubView:contentView for:lbl2 isText:YES];
    
    [self addSubview:v];
}

- (void)addSkeletonOnOverlayViewWithBounds:(CGRect)bounds{
    UIView *v = [[UIView alloc] initWithFrame:bounds];
    v.backgroundColor = [UIColor whiteColor];
    v.layer.cornerRadius = 5.0;
    [self addSubview:v];
    
    int lblH = 26;
    UILabel *nameLbl = [[UILabel alloc] initWithFrame:CGRectMake((bounds.size.width/2)-((bounds.size.width/1.8)/2), 30, bounds.size.width/1.8, lblH)];
    [v addSubview:nameLbl];
    [self addSkeletonFor:nameLbl isText:YES];
    
    UILabel *descLbl = [[UILabel alloc] initWithFrame:CGRectMake((bounds.size.width/2)-((bounds.size.width/2.5)/2), CGRectGetMaxY(nameLbl.frame)+10, bounds.size.width/2.5, lblH)];
    [v addSubview:descLbl];
    [self addSkeletonFor:descLbl isText:YES];
    
    int topMargin = CGRectGetMaxY(descLbl.frame) + 40;
    for (int i=0; i<3; i++) {
        
        UILabel *lbl1 = [[UILabel alloc] initWithFrame:CGRectMake(20, topMargin, bounds.size.width/1.1, lblH)];
        [v addSubview:lbl1];
        [self addSkeletonFor:lbl1 isText:YES];
        
        UILabel *lbl2 = [[UILabel alloc] initWithFrame:CGRectMake(20, CGRectGetMaxY(lbl1.frame)+10, bounds.size.width/1.1, lblH)];
        [v addSubview:lbl2];
        [self addSkeletonFor:lbl2 isText:YES];
        
        UILabel *lbl3 = [[UILabel alloc] initWithFrame:CGRectMake(20, CGRectGetMaxY(lbl2.frame)+10, bounds.size.width/1.1, lblH)];
        [v addSubview:lbl3];
        [self addSkeletonFor:lbl3 isText:YES];
        
        UILabel *lbl4 = [[UILabel alloc] initWithFrame:CGRectMake(20, CGRectGetMaxY(lbl3.frame)+10, bounds.size.width/2.5, lblH)];
        [v addSubview:lbl4];
        [self addSkeletonFor:lbl4 isText:YES];
        
        topMargin = CGRectGetMaxY(lbl4.frame) + 20;
    }
    
}

- (void)addSkeletonOnSubView:(UIView *)subView for:(UIView *)view isText:(BOOL)isText{
    UIView *v = [[UIView alloc] init];
    
    if (isText){
        v.frame = CGRectMake(view.frame.origin.x, view.frame.origin.y + ((view.frame.size.height/2)-8), view.frame.size.width, 16);
    }else {
        v.frame = view.frame;
    }
    
    v.layer.cornerRadius = view.layer.cornerRadius;
    v.backgroundColor = [[UIColor lightGrayColor] colorWithAlphaComponent:0.5];
    [subView insertSubview:v atIndex:0];
    [self animateSkeletonForView:v];
}

- (void)remove{
    [self removeFromSuperview];
}

- (void)animateSkeletonForView:(UIView *)v{
    v.backgroundColor = [[UIColor lightGrayColor] colorWithAlphaComponent:0.1f];
    v.clipsToBounds = YES;
    
    UIView *gradientView = [[UIView alloc] initWithFrame:CGRectMake(0-v.frame.size.width, 0, v.frame.size.width, v.frame.size.height)];
    [v addSubview:gradientView];
    
    CAGradientLayer *gradient = [CAGradientLayer layer];
    gradient.frame = gradientView.bounds;
    gradient.colors = @[(id)[[UIColor lightGrayColor] colorWithAlphaComponent:0.0f].CGColor,
                        (id)[[UIColor lightGrayColor] colorWithAlphaComponent:0.05f].CGColor,
                        (id)[[UIColor lightGrayColor] colorWithAlphaComponent:0.1f].CGColor,
                        (id)[[UIColor lightGrayColor] colorWithAlphaComponent:0.15f].CGColor,
                        (id)[[UIColor lightGrayColor] colorWithAlphaComponent:0.15f].CGColor,
                        (id)[[UIColor lightGrayColor] colorWithAlphaComponent:0.1f].CGColor,
                        (id)[[UIColor lightGrayColor] colorWithAlphaComponent:0.05f].CGColor,
                        (id)[[UIColor lightGrayColor] colorWithAlphaComponent:0.0f].CGColor];
    gradient.startPoint = CGPointMake(0.9, 0.0);
    gradient.endPoint = CGPointMake(0.1, 0.0);
    [gradientView.layer insertSublayer:gradient atIndex:0];
    
//    CABasicAnimation *anim = [CABasicAnimation animationWithKeyPath:@"colors"];
//    anim.fromValue = [gradient valueForKey:@"colors"];
//    anim.toValue = @[(id)[[UIColor lightGrayColor] colorWithAlphaComponent:0.1f].CGColor, (id)[[UIColor lightGrayColor] colorWithAlphaComponent:0.2f].CGColor, (id)[[UIColor lightGrayColor] colorWithAlphaComponent:0.3f].CGColor, (id)[[UIColor lightGrayColor] colorWithAlphaComponent:0.4f].CGColor];
//    anim.timingFunction = [CAMediaTimingFunction functionWithName:kCAMediaTimingFunctionEaseInEaseOut];
//    anim.duration = 1.2;
//    anim.repeatCount = INFINITY;
//    anim.autoreverses = YES;
    
//    [gradient addAnimation:anim forKey:@"colors"];

    [UIView animateWithDuration:1.3f
                          delay:0
                        options:UIViewAnimationOptionRepeat | UIViewAnimationCurveEaseIn
                     animations:^{
                         gradientView.frame = CGRectMake(v.frame.size.width, 0, v.frame.size.width, v.frame.size.height);
                     } completion:nil];
    
//    [UIView animateWithDuration:1.3f
//                          delay:0
//                        options:UIViewAnimationOptionAutoreverse | UIViewAnimationOptionRepeat | UIViewAnimationCurveEaseIn
//                     animations:^{
//                         v.alpha = 0.5;
//                     } completion:nil];
}

/*
// Only override drawRect: if you perform custom drawing.
// An empty implementation adversely affects performance during animation.
- (void)drawRect:(CGRect)rect {
    // Drawing code
}
*/

@end
