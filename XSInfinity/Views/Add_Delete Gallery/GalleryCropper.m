//
//  GalleryCropper.m
//  XSInfinity
//
//  Created by Joseph Marvin Magdadaro on 7/27/13.
//  Copyright © 2013 Jerk Magz. All rights reserved.
//

#import "GalleryCropper.h"
#import "TranslationsModel.h"
#import "Fonts.h"
#import "Animations.h"
#import "Colors.h"
#import "CustomAlertView.h"

@interface GalleryCropper ()<UIScrollViewDelegate>{
    TranslationsModel *translationsModel;
    Fonts *fonts;
    Colors *colors;
    BOOL didLayoutReloaded;
    int isPrivate;
    
    // For image cropping
    UIView *cropView;
    UIView *contentView;
    UIImageView *imgView;
    CAShapeLayer *fillLayer;
    CGRect cropFrame;
    
    UIButton *privateBtn;
    UIButton *publicBtn;
}

@property (nonatomic, retain) UIScrollView *scrollView;

@end

@implementation GalleryCropper

- (void)viewDidLoad {
    [super viewDidLoad];
    // Do any additional setup after loading the view.
    
    translationsModel = [TranslationsModel sharedInstance];
    fonts = [Fonts sharedFonts];
    colors = [Colors sharedColors];
}

-(void)viewDidLayoutSubviews{
    [super viewDidLayoutSubviews];
    
    if( !didLayoutReloaded ){
        if (self.gallery == nil) {
            [self setupCropView];
        }else{
            [self setupEditView];
        }
        
        didLayoutReloaded = YES;
    }
}

- (void)setupEditView{
    
    UIView *bgView = [[UIView alloc] initWithFrame:self.view.frame];
    bgView.backgroundColor = [[UIColor blackColor] colorWithAlphaComponent:0.68];
    bgView.tag = 99;
    [self.view addSubview:bgView];
    
    int w = self.view.frame.size.width * 0.9;
    int h = 530;
    UIView *alertView = [[UIView alloc] initWithFrame:CGRectMake((CGRectGetWidth(bgView.frame)/2)-(w/2), (CGRectGetHeight(bgView.frame)/2)-(h/2), w, h)];
    alertView.backgroundColor = [UIColor whiteColor];
    alertView.layer.cornerRadius = 8;
    alertView.layer.shadowColor = [UIColor blackColor].CGColor;
    alertView.layer.shadowOffset = CGSizeMake(0, 5);
    alertView.layer.shadowOpacity = 0.3;
    alertView.layer.shadowRadius = 8.0;
    alertView.clipsToBounds = true;
    [bgView addSubview:alertView];
    
    UILabel *titleLbl = [[UILabel alloc] initWithFrame:CGRectMake(0, 0, w, 70)];
    titleLbl.text = [translationsModel getTranslationForKey:@"upload.imgtitle"];
    titleLbl.font = [[Fonts sharedFonts] titleFont];
    titleLbl.textAlignment = NSTextAlignmentCenter;
    titleLbl.backgroundColor = [[UIColor whiteColor] colorWithAlphaComponent:0.8];
    [alertView addSubview:titleLbl];
    
    UIButton *xBtn = [UIButton buttonWithType:UIButtonTypeSystem];
    xBtn.frame = CGRectMake(w-55, 18, 35, 35);
    xBtn.tintColor = [UIColor blackColor];
    [xBtn setImage:[UIImage imageNamed:@"x"] forState:UIControlStateNormal];
    [xBtn addTarget:self
                  action:@selector(tapCancel:)
        forControlEvents:UIControlEventTouchUpInside];
    [alertView addSubview:xBtn];
    
    UIImageView *imgView = [[UIImageView alloc] initWithFrame:CGRectMake(0, 0, w, 290)];
    imgView.image = self.image;
    imgView.clipsToBounds = TRUE;
    imgView.backgroundColor = [UIColor blackColor];
    imgView.contentMode = UIViewContentModeScaleAspectFill;
    [alertView insertSubview:imgView belowSubview:titleLbl];
    
    float statusTopMargin = CGRectGetMaxY(imgView.frame)+30;
    int statusBtnSize = 20;
    int statusLblWidth = 90;
    
    publicBtn = [[UIButton alloc] initWithFrame:CGRectMake(w/4.5, statusTopMargin, statusBtnSize, statusBtnSize)];
    publicBtn.backgroundColor = [colors orangeColor];
    publicBtn.layer.cornerRadius = 5.0;
    publicBtn.clipsToBounds = YES;
    publicBtn.tag = 0;
    [publicBtn addTarget:self
                  action:@selector(changePrivacy:)
        forControlEvents:UIControlEventTouchUpInside];
    [alertView addSubview:publicBtn];
    
    UILabel *publicLbl = [[UILabel alloc] initWithFrame:CGRectMake(CGRectGetMaxX(publicBtn.frame)+15, statusTopMargin, statusLblWidth, statusBtnSize)];
    publicLbl.text = [translationsModel getTranslationForKey:@"upload.public"];
    publicLbl.font = [fonts normalFont];
    [alertView addSubview:publicLbl];
    
    privateBtn = [[UIButton alloc] initWithFrame:CGRectMake(w/1.7, statusTopMargin, statusBtnSize, statusBtnSize)];
    privateBtn.layer.borderWidth = 1.0;
    privateBtn.layer.borderColor = [UIColor blackColor].CGColor;
    privateBtn.backgroundColor = [UIColor clearColor];
    privateBtn.layer.cornerRadius = 5.0;
    privateBtn.clipsToBounds = YES;
    privateBtn.tag = 1;
    [privateBtn addTarget:self
                  action:@selector(changePrivacy:)
        forControlEvents:UIControlEventTouchUpInside];
    [alertView addSubview:privateBtn];
    
    //select gallery privacy status
    if (self.gallery.isPrivate) {
        [self changePrivacy:privateBtn];
    }else{
        [self changePrivacy:publicBtn];
    }
    
    UILabel *privateLbl = [[UILabel alloc] initWithFrame:CGRectMake(CGRectGetMaxX(privateBtn.frame)+15, statusTopMargin, statusLblWidth, statusBtnSize)];
    privateLbl.text = [translationsModel getTranslationForKey:@"upload.private"];
    privateLbl.font = [fonts normalFont];
    [alertView addSubview:privateLbl];
    
    UILabel *pictureLbl = [[UILabel alloc] initWithFrame:CGRectMake(0, CGRectGetMaxY(privateLbl.frame)+40, w, statusBtnSize)];
    pictureLbl.text = [translationsModel getTranslationForKey:@"upload.dateofpic"];
    pictureLbl.font = [fonts normalFont];
    pictureLbl.textAlignment = NSTextAlignmentCenter;
    [alertView addSubview:pictureLbl];
    
    UILabel *dateLbl = [[UILabel alloc] initWithFrame:CGRectMake(0, CGRectGetMaxY(pictureLbl.frame)+8, w, statusBtnSize)];
    dateLbl.text = [self setFormatForDate:self.dateStr];
    dateLbl.font = [fonts titleFontBold];
    dateLbl.textAlignment = NSTextAlignmentCenter;
    [alertView addSubview:dateLbl];
    
    float btnTopMargin = CGRectGetMaxY(dateLbl.frame)+20;
    float btnW = w/2;
    float btnH = 70;
    
    UIButton *cancelBtn = [[UIButton alloc] initWithFrame:CGRectMake(0, btnTopMargin, btnW, btnH)];
    cancelBtn.tag = 99;
    cancelBtn.titleLabel.font = [[Fonts sharedFonts] titleFont];
    cancelBtn.backgroundColor = [UIColor whiteColor];
    [cancelBtn setTitleColor:[UIColor blackColor] forState:UIControlStateNormal];
    [cancelBtn setTitle:[translationsModel getTranslationForKey:@"global.delete"] forState:UIControlStateNormal];
    [cancelBtn addTarget:self
                  action:@selector(deleteImage:)
        forControlEvents:UIControlEventTouchUpInside];
    [alertView addSubview:cancelBtn];
    
    UIButton *doneBtn = [[UIButton alloc] initWithFrame:CGRectMake(btnW, btnTopMargin, btnW, btnH)];
    doneBtn.tag = 99;
    doneBtn.titleLabel.font = [[Fonts sharedFonts] titleFontBold];
    doneBtn.backgroundColor = [UIColor whiteColor];
    [doneBtn setTitleColor:[UIColor blackColor] forState:UIControlStateNormal];
    [doneBtn setTitle:[translationsModel getTranslationForKey:@"global.savebutton"] forState:UIControlStateNormal];
    [doneBtn addTarget:self
                action:@selector(updateImage:)
      forControlEvents:UIControlEventTouchUpInside];
    [alertView addSubview:doneBtn];
    
    [[Animations sharedAnimations] zoomSpringAnimationForView:alertView];
    [self drawCropMask];
    
}

- (void)setupCropView{
    
    UIView *bgView = [[UIView alloc] initWithFrame:self.view.frame];
    bgView.backgroundColor = [[UIColor blackColor] colorWithAlphaComponent:0.68];
    bgView.tag = 99;
    [self.view addSubview:bgView];
    
    int w = self.view.frame.size.width * 0.9;
    int h = 530;
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
    titleLbl.text = [translationsModel getTranslationForKey:@"upload.croptitle"];
    titleLbl.font = [[Fonts sharedFonts] titleFont];
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
    imgView.clipsToBounds = YES;
    imgView.backgroundColor = [UIColor blueColor];
    imgView.frame = [self frameForImage:self.image inImageViewAspectFit:imgView];// Reset frame base on image size
    [contentView addSubview:imgView];
    
    float contentW = 0;
    float contentH = 0;
    if (CGRectGetWidth(imgView.frame) > CGRectGetHeight(imgView.frame)) {
        contentW = CGRectGetWidth(cropView.frame) + (CGRectGetWidth(imgView.frame) - CGRectGetHeight(cropView.frame));
        contentH = cropViewViewH;
    }else{
        contentW = cropViewViewW;
        contentH = CGRectGetHeight(imgView.frame);
    }
    
    _scrollView.contentSize = CGSizeMake(contentW, contentH);
    
    // Reset content view size base on image view frame
    contentView.frame = CGRectMake(0, 0, contentW, contentH);
    
    float statusTopMargin = CGRectGetMaxY(cropView.frame)+30;
    int statusBtnSize = 20;
    int statusLblWidth = 90;
    
    publicBtn = [[UIButton alloc] initWithFrame:CGRectMake(w/4.5, statusTopMargin, statusBtnSize, statusBtnSize)];
    publicBtn.backgroundColor = [colors orangeColor];
    publicBtn.layer.cornerRadius = 5.0;
    publicBtn.clipsToBounds = YES;
    publicBtn.tag = 0;
    [publicBtn addTarget:self
                  action:@selector(changePrivacy:)
        forControlEvents:UIControlEventTouchUpInside];
    [alertView addSubview:publicBtn];
    
    UILabel *publicLbl = [[UILabel alloc] initWithFrame:CGRectMake(CGRectGetMaxX(publicBtn.frame)+15, statusTopMargin, statusLblWidth, statusBtnSize)];
    publicLbl.text = [translationsModel getTranslationForKey:@"upload.public"];
    publicLbl.font = [fonts normalFont];
    [alertView addSubview:publicLbl];
    
    privateBtn = [[UIButton alloc] initWithFrame:CGRectMake(w/1.7, statusTopMargin, statusBtnSize, statusBtnSize)];
    privateBtn.layer.borderWidth = 1.0;
    privateBtn.layer.borderColor = [UIColor blackColor].CGColor;
    privateBtn.backgroundColor = [UIColor clearColor];
    privateBtn.layer.cornerRadius = 5.0;
    privateBtn.clipsToBounds = YES;
    privateBtn.tag = 1;
    [privateBtn addTarget:self
                  action:@selector(changePrivacy:)
        forControlEvents:UIControlEventTouchUpInside];
    [alertView addSubview:privateBtn];
    
    UILabel *privateLbl = [[UILabel alloc] initWithFrame:CGRectMake(CGRectGetMaxX(privateBtn.frame)+15, statusTopMargin, statusLblWidth, statusBtnSize)];
    privateLbl.text = [translationsModel getTranslationForKey:@"upload.private"];
    privateLbl.font = [fonts normalFont];
    [alertView addSubview:privateLbl];
    
    UILabel *pictureLbl = [[UILabel alloc] initWithFrame:CGRectMake(0, CGRectGetMaxY(privateLbl.frame)+40, w, statusBtnSize)];
    pictureLbl.text = [translationsModel getTranslationForKey:@"upload.dateofpic"];
    pictureLbl.font = [fonts normalFont];
    pictureLbl.textAlignment = NSTextAlignmentCenter;
    [alertView addSubview:pictureLbl];
    
    UILabel *dateLbl = [[UILabel alloc] initWithFrame:CGRectMake(0, CGRectGetMaxY(pictureLbl.frame)+8, w, statusBtnSize)];
    dateLbl.text = [self setFormatForDate:self.dateStr];
    dateLbl.font = [fonts titleFontBold];
    dateLbl.textAlignment = NSTextAlignmentCenter;
    [alertView addSubview:dateLbl];
    
    float btnTopMargin = CGRectGetMaxY(dateLbl.frame)+30;
    float btnW = w/2;
    float btnH = 70;
    
    UIButton *cancelBtn = [[UIButton alloc] initWithFrame:CGRectMake(0, btnTopMargin, btnW, btnH)];
    cancelBtn.tag = 99;
    cancelBtn.titleLabel.font = [[Fonts sharedFonts] titleFont];
    cancelBtn.backgroundColor = [UIColor whiteColor];
    [cancelBtn setTitleColor:[UIColor blackColor] forState:UIControlStateNormal];
    [cancelBtn setTitle:[translationsModel getTranslationForKey:@"global.cancelbutton"] forState:UIControlStateNormal];
    [cancelBtn addTarget:self
                  action:@selector(tapCancel:)
        forControlEvents:UIControlEventTouchUpInside];
    [alertView addSubview:cancelBtn];
    
    UIButton *doneBtn = [[UIButton alloc] initWithFrame:CGRectMake(btnW, btnTopMargin, btnW, btnH)];
    doneBtn.tag = 99;
    doneBtn.titleLabel.font = [[Fonts sharedFonts] titleFontBold];
    doneBtn.backgroundColor = [UIColor whiteColor];
    [doneBtn setTitleColor:[UIColor blackColor] forState:UIControlStateNormal];
    [doneBtn setTitle:[translationsModel getTranslationForKey:@"global.savebutton"] forState:UIControlStateNormal];
    [doneBtn addTarget:self
                action:@selector(saveImage:)
      forControlEvents:UIControlEventTouchUpInside];
    [alertView addSubview:doneBtn];
    
    [[Animations sharedAnimations] zoomSpringAnimationForView:alertView];
    [self drawCropMask];
    
}

- (UIView *)viewForZoomingInScrollView:(UIScrollView *)scrollView{
    NSLog(@"1");
    
    return contentView;
}

-(CGRect)frameForImage:(UIImage*)image inImageViewAspectFit:(UIImageView*)imageView{
    
    float scale1 = image.size.width / image.size.height;
    float scale2 = image.size.height / image.size.width;
    
    int cropSize = cropView.frame.size.height;
    
    if(scale1 < scale2)
    {
        float scale = cropSize / image.size.width;
        float height = scale * image.size.height;
        float xMargin = (cropView.bounds.size.width/2)-(cropSize/2);
        
        return CGRectMake(xMargin, 0, cropSize, height);
    }
    else
    {
        float scale = cropSize / image.size.height;
        float width = scale * image.size.width;
        
        float contentW = CGRectGetWidth(cropView.frame) + (width - cropSize);
        float xMargin = (contentW/2) - (width/2);
        
        return CGRectMake(xMargin, 0, width, cropSize);
    }
}

- (void)drawCropMask{
    
    int cropSize = cropView.frame.size.height;
    UIBezierPath *path = [UIBezierPath bezierPathWithRoundedRect:CGRectMake(0, 0, cropView.bounds.size.width, cropView.bounds.size.height) cornerRadius:0];
    
    cropFrame = CGRectMake((cropView.bounds.size.width/2)-(cropSize/2), (cropView.bounds.size.height/2)-(cropSize/2), cropSize, cropSize);
    UIBezierPath *cropPath = [UIBezierPath bezierPathWithRect:cropFrame];
    [path appendPath:cropPath];
    [path setUsesEvenOddFillRule:YES];
    
    fillLayer = [CAShapeLayer layer];
    fillLayer.path = path.CGPath;
    fillLayer.fillRule = kCAFillRuleEvenOdd;
    fillLayer.fillColor = [UIColor blackColor].CGColor;
    fillLayer.opacity = 0.5;
    [cropView.layer addSublayer:fillLayer];
}

- (IBAction)saveImage:(id)sender{
    
    UIImage *img = [self rasterizedImageInView:cropView
                                        atRect:CGRectMake(cropFrame.origin.x,
                                                          cropFrame.origin.y,
                                                          cropFrame.size.width,
                                                          cropFrame.size.width)];
    
    if (self.dismissDelegate) {
        [self.dismissDelegate saveImage:img withPrivacy:isPrivate];
    }
    [self dismissViewControllerAnimated:NO completion:nil];
}

- (IBAction)tapCancel:(id)sender{
    [self dismissViewControllerAnimated:NO completion:nil];
}

- (IBAction)deleteImage:(id)sender{
    if (self.dismissDelegate) {
        [self.dismissDelegate deleteImage:self.gallery.identifier];
    }
    [self dismissViewControllerAnimated:NO completion:nil];
}

- (IBAction)updateImage:(id)sender{
    if (self.dismissDelegate) {
        [self.dismissDelegate updateImagePrivacy:isPrivate forImage:self.gallery.identifier];
    }
    [self dismissViewControllerAnimated:NO completion:nil];
}

- (IBAction)changePrivacy:(id)sender{
    
    switch ([sender tag]){
        case 0:{
            publicBtn.backgroundColor = [colors orangeColor];
            publicBtn.layer.borderWidth = 0;
            publicBtn.layer.cornerRadius = 5.0;
            publicBtn.clipsToBounds = YES;
            
            privateBtn.layer.borderWidth = 1.0;
            privateBtn.layer.borderColor = [UIColor blackColor].CGColor;
            privateBtn.backgroundColor = [UIColor clearColor];
            privateBtn.layer.cornerRadius = 5.0;
            privateBtn.clipsToBounds = YES;
            
            isPrivate = 0;
        }
            break;
            
        case 1:{
            publicBtn.layer.borderWidth = 1.0;
            publicBtn.layer.borderColor = [UIColor blackColor].CGColor;
            publicBtn.backgroundColor = [UIColor clearColor];
            publicBtn.layer.cornerRadius = 5.0;
            publicBtn.clipsToBounds = YES;
            
            privateBtn.backgroundColor = [colors orangeColor];
            privateBtn.layer.cornerRadius = 5.0;
            privateBtn.clipsToBounds = YES;
            privateBtn.layer.borderWidth = 0;
            
            isPrivate = 1;
        }
            break;
            
        default:
            break;
    }
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

- (NSString *)setFormatForDate:(NSString *)dateString{
    
    NSDateFormatter *dateFormatter = [[NSDateFormatter alloc]init];
    [dateFormatter setDateFormat:@"yyyy-MM-dd'T'HH:mm:ssZ"];
    NSDate *date = [dateFormatter dateFromString:dateString];
    
    [dateFormatter setDateFormat:@"dd.MM.yyyy"];
    NSString *formattedDate = [dateFormatter stringFromDate:date];
    
    return formattedDate;
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
