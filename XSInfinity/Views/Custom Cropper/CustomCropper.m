//
//  CustomCropper.m
//  XSInfinity
//
//  Created by Joseph Marvin Magdadaro on 7/2/18.
//  Copyright © 2018 Joseph Marvin Magdadaro. All rights reserved.
//

#import "CustomCropper.h"
#import "TranslationsModel.h"
#import "Fonts.h"
#import "Animations.h"

@interface CustomCropper ()<UIScrollViewDelegate>{
    TranslationsModel *translationsModel;
    Fonts *fonts;
    BOOL didLayoutReloaded;
    
    // For image cropping
    UIView *cropView;
    UIView *contentView;
    UIImageView *imgView;
    CAShapeLayer *fillLayer;
    CGRect circleFrame;
}

@property (nonatomic, retain) UIScrollView *scrollView;

@end

@implementation CustomCropper

- (void)viewDidLoad {
    [super viewDidLoad];
    // Do any additional setup after loading the view.
    
    translationsModel = [TranslationsModel sharedInstance];
    fonts = [Fonts sharedFonts];
}

-(void)viewDidLayoutSubviews{
    [super viewDidLayoutSubviews];
    
    if( !didLayoutReloaded ){
        [self setupUserInterface];
        
        didLayoutReloaded = YES;
    }
}

- (void)setupUserInterface{
    
    UIView *bgView = [[UIView alloc] initWithFrame:self.view.frame];
    bgView.backgroundColor = [[UIColor blackColor] colorWithAlphaComponent:0.68];
    bgView.tag = 99;
    [self.view addSubview:bgView];
    
    int w = self.view.frame.size.width * 0.9;
    int h = 360;
    UIView *alertView = [[UIView alloc] initWithFrame:CGRectMake((CGRectGetWidth(bgView.frame)/2)-(w/2), (CGRectGetHeight(bgView.frame)/2)-(h/2), w, h)];
    alertView.backgroundColor = [UIColor whiteColor];
    alertView.layer.cornerRadius = 8;
    alertView.layer.shadowColor = [UIColor blackColor].CGColor;
    alertView.layer.shadowOffset = CGSizeMake(0, 5);
    alertView.layer.shadowOpacity = 0.3;
    alertView.layer.shadowRadius = 8.0;
    alertView.clipsToBounds = true;
    [bgView addSubview:alertView];
    
    UILabel *titleLbl = [[UILabel alloc] initWithFrame:CGRectMake(0, 30, w, 40)];
    titleLbl.text = [translationsModel getTranslationForKey:@"regstep1b.description"];
    titleLbl.font = [[Fonts sharedFonts] normalFont];
    titleLbl.textAlignment = NSTextAlignmentCenter;
    [alertView addSubview:titleLbl];
    
    int cropViewViewW = w;
    int cropViewViewH = 200;
    
    cropView = [[UIView alloc] initWithFrame:CGRectMake(0, 90, cropViewViewW, cropViewViewH)];
    cropView.backgroundColor = [UIColor blackColor];
    [alertView addSubview:cropView];
    
    _scrollView = [[UIScrollView alloc] initWithFrame:CGRectMake(0, 0, cropViewViewW, cropViewViewH)];
    _scrollView.scrollEnabled = TRUE;
    _scrollView.showsHorizontalScrollIndicator = FALSE;
    _scrollView.showsVerticalScrollIndicator = FALSE;
    _scrollView.maximumZoomScale = 3.0;
    _scrollView.delegate = self;
    [cropView addSubview:_scrollView];
    
    contentView = [[UIScrollView alloc] initWithFrame:CGRectMake(0, 0, cropViewViewW, cropViewViewH)];
    contentView.backgroundColor = [UIColor clearColor];
    [_scrollView addSubview:contentView];
    
    imgView = [[UIImageView alloc] init];
    imgView.image = self.image;
    imgView.backgroundColor = [UIColor blueColor];
    imgView.frame = [self frameForImage:self.image inImageViewAspectFit:imgView];// Reset frame base on image size
    [contentView addSubview:imgView];
    
    float contentW = 0;
    float contentH = 0;
    if (CGRectGetWidth(imgView.frame) > CGRectGetHeight(imgView.frame)) {
        contentW = CGRectGetWidth(cropView.frame) + (CGRectGetWidth(imgView.frame) - (CGRectGetWidth(cropView.frame)/2));
        contentH = cropViewViewH;
    }else{
        contentW = cropViewViewW;
        if (CGRectGetHeight(imgView.frame) < cropViewViewH) {
            contentH = CGRectGetHeight(cropView.frame) + (CGRectGetHeight(imgView.frame) - (CGRectGetWidth(cropView.frame)/2));
        }else{
            contentH = CGRectGetHeight(imgView.frame) + (CGRectGetHeight(cropView.frame) - (CGRectGetWidth(cropView.frame)/2));
        }
    }
    
    _scrollView.contentSize = CGSizeMake(contentW, contentH);
    
    // Reset content view size base on image view frame
    contentView.frame = CGRectMake(0, 0, contentW, contentH);
    
    UIView *lineView = [[UIView alloc] initWithFrame:CGRectMake(0, 289, w, 1)];
    lineView.backgroundColor = [UIColor grayColor];
    [alertView addSubview:lineView];
    
    float btnW = w/2;
    float btnH = 70;
    
    UIButton *cancelBtn = [[UIButton alloc] initWithFrame:CGRectMake(0, 290, btnW, btnH)];
    cancelBtn.tag = 99;
    cancelBtn.titleLabel.font = [[Fonts sharedFonts] normalFont];
    cancelBtn.backgroundColor = [UIColor whiteColor];
    [cancelBtn setTitleColor:[UIColor blackColor] forState:UIControlStateNormal];
    [cancelBtn setTitle:[translationsModel getTranslationForKey:@"global.cancelbutton"] forState:UIControlStateNormal];
    [cancelBtn addTarget:self
                  action:@selector(tapCancel:)
        forControlEvents:UIControlEventTouchUpInside];
    [alertView addSubview:cancelBtn];
    
    UIButton *doneBtn = [[UIButton alloc] initWithFrame:CGRectMake(btnW, 290, btnW, btnH)];
    doneBtn.tag = 99;
    doneBtn.titleLabel.font = [[Fonts sharedFonts] normalFont];
    doneBtn.backgroundColor = [UIColor whiteColor];
    [doneBtn setTitleColor:[UIColor blackColor] forState:UIControlStateNormal];
    [doneBtn setTitle:[translationsModel getTranslationForKey:@"global.savebutton"] forState:UIControlStateNormal];
    [doneBtn addTarget:self
                action:@selector(doneCropping:)
      forControlEvents:UIControlEventTouchUpInside];
    [alertView addSubview:doneBtn];
    
    [[Animations sharedAnimations] zoomSpringAnimationForView:alertView];
    [self drawCircleMask];
    
}

- (UIView *)viewForZoomingInScrollView:(UIScrollView *)scrollView{
    NSLog(@"1");
    
    return contentView;
}

-(CGRect)frameForImage:(UIImage*)image inImageViewAspectFit:(UIImageView*)imageView{
    
    float scale1 = image.size.width / image.size.height;
    float scale2 = image.size.height / image.size.width;
    
    if(scale1 < scale2)
    {
        float scale = (cropView.frame.size.width/2) / image.size.width;
        float height = scale * image.size.height;
        float xMargin = cropView.bounds.size.width/4;
        float contentH = 0;
        float yMargin = 0;
        
        if (height < CGRectGetHeight(cropView.frame)) {
            contentH = CGRectGetHeight(cropView.frame) + (CGRectGetHeight(imgView.frame) - (CGRectGetWidth(cropView.frame)/2));
        }else{
            contentH = height + (CGRectGetHeight(cropView.frame) - (CGRectGetWidth(cropView.frame)/2));
        }
        
        yMargin = (contentH/2) - (height/2);
        
        return CGRectMake(xMargin, yMargin, (cropView.frame.size.width/2), height);
    }
    else
    {
        float scale = (cropView.frame.size.width/2) / image.size.height;
        float width = scale * image.size.width;
        float yMargin = (cropView.bounds.size.height/2)-(cropView.bounds.size.width/4);
        
        float contentW = CGRectGetWidth(cropView.frame) + (width - (CGRectGetWidth(cropView.frame)/2));
        float xMargin = (contentW/2) - (width/2);
        
        return CGRectMake(xMargin, yMargin, width, (cropView.frame.size.width/2));
    }
}

- (void)drawCircleMask{
    
    int radius = cropView.frame.size.width/2;
    UIBezierPath *path = [UIBezierPath bezierPathWithRoundedRect:CGRectMake(0, 0, cropView.bounds.size.width, cropView.bounds.size.height) cornerRadius:0];
    
    circleFrame = CGRectMake((cropView.bounds.size.width/2)-(radius/2), (cropView.bounds.size.height/2)-(radius/2), radius, radius);
    UIBezierPath *circlePath = [UIBezierPath bezierPathWithRoundedRect:circleFrame cornerRadius:radius];
    [path appendPath:circlePath];
    [path setUsesEvenOddFillRule:YES];
    
    fillLayer = [CAShapeLayer layer];
    fillLayer.path = path.CGPath;
    fillLayer.fillRule = kCAFillRuleEvenOdd;
    fillLayer.fillColor = [UIColor blackColor].CGColor;
    fillLayer.opacity = 0.5;
    [cropView.layer addSublayer:fillLayer];
}

- (IBAction)doneCropping:(id)sender{
    [fillLayer removeFromSuperlayer];
    UIImage *img = [self rasterizedImageInView:cropView
                                                 atRect:CGRectMake(circleFrame.origin.x,
                                                                   circleFrame.origin.y,
                                                                   circleFrame.size.width,
                                                                   circleFrame.size.width)];
    
    if (self.dismissDelegate) {
        [self.dismissDelegate croppingImageDone:img];
    }
    [self dismissViewControllerAnimated:NO completion:nil];
}

- (IBAction)tapCancel:(id)sender{
    [self dismissViewControllerAnimated:NO completion:nil];
}

- (UIImage *)rasterizedImageInView:(UIView *)view atRect:(CGRect)rect {
    
    UIGraphicsBeginImageContextWithOptions(rect.size, view.opaque, 0.0);
    
    CGContextRef context = UIGraphicsGetCurrentContext();
    
    CGContextTranslateCTM(context, -rect.origin.x, -rect.origin.y);
    
    [view.layer renderInContext:context];
    
    UIImage *image = UIGraphicsGetImageFromCurrentImageContext();
    
    UIGraphicsEndImageContext();
    
    return image;
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

/*
#pragma mark - Navigation

// In a storyboard-based application, you will often want to do a little preparation before navigation
- (void)prepareForSegue:(UIStoryboardSegue *)segue sender:(id)sender {
    // Get the new view controller using [segue destinationViewController].
    // Pass the selected object to the new view controller.
}
*/

@end
