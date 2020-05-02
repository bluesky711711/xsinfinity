//
//  OnBoardingContentViewController.m
//  XSInfinity
//
//  Created by Joseph Marvin Magdadaro on 16/12/2018.
//  Copyright © 2018 Jerk Magz. All rights reserved.
//

#import "OnBoardingContentViewController.h"
#import "Fonts.h"
#import "Colors.h"
#import "Helper.h"
#import "TranslationsModel.h"
#import "TextViewOverlayViewController.h"

static int const NumberOfPages = 4;

@interface OnBoardingContent : NSObject
@property (nonatomic,strong) NSString *imagename;
@property (nonatomic,strong) NSString *instruction;
@property (nonatomic,strong) NSString *btnText;
@end
@implementation OnBoardingContent
@end

@interface OnBoardingContentViewController ()<UITextViewDelegate>
@property (strong, nonatomic) NSArray *contents;
@property (weak, nonatomic) IBOutlet UIImageView *imageView;
@property (weak, nonatomic) IBOutlet UILabel *instructionLbl;
@property (weak, nonatomic) IBOutlet UIButton *btn;
@property (weak, nonatomic) IBOutlet UILabel *linksLbl;
@property (weak, nonatomic) IBOutlet UITextView *linksTxtView;
@property (weak, nonatomic) IBOutlet NSLayoutConstraint *imageViewConstraintHeight;
@property (weak, nonatomic) IBOutlet NSLayoutConstraint *instructionConstraintHeight;
@end

@implementation OnBoardingContentViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    
    OnBoardingContent *content1 = [[OnBoardingContent alloc] init];
    content1.imagename = @"onboardingImg";
    content1.instruction = [[TranslationsModel sharedInstance] getTranslationForKey:@"onboard.text1"];
    content1.btnText = [[TranslationsModel sharedInstance] getTranslationForKey:@"onboard.button1"];
    
    OnBoardingContent *content2 = [[OnBoardingContent alloc] init];
    content2.imagename = @"placeholder-background-profile-user";
    content2.instruction = [[TranslationsModel sharedInstance] getTranslationForKey:@"onboard.text2"];
    content2.btnText = [[TranslationsModel sharedInstance] getTranslationForKey:@"onboard.button2"];
    
    OnBoardingContent *content3 = [[OnBoardingContent alloc] init];
    content3.imagename = @"onboardingImg";
    content3.instruction = [[TranslationsModel sharedInstance] getTranslationForKey:@"onboard.text3"];
    content3.btnText = [[TranslationsModel sharedInstance] getTranslationForKey:@"onboard.button3"];
    
    OnBoardingContent *content4 = [[OnBoardingContent alloc] init];
    content4.imagename = @"onboardingImg";
    content4.instruction = [[TranslationsModel sharedInstance] getTranslationForKey:@"onboard.text4"];
    content4.btnText = [[TranslationsModel sharedInstance] getTranslationForKey:@"onboard.button4"];
    self.contents = @[content1, content2, content3, content4];
    
    OnBoardingContent *content = self.contents[self.index];
    _imageView.image = [UIImage imageNamed:content.imagename];
    [_btn setTitle:content.btnText forState:UIControlStateNormal];
    
    [[Helper sharedHelper] addDropShadowIn:_imageView withColor:[UIColor darkGrayColor] andSetCornerRadiusTo:5.0];
    
    _btn.backgroundColor = [[Colors sharedColors] blueColor];
    _btn.titleLabel.font = [[Fonts sharedFonts] normalFontBold];
    
    NSMutableParagraphStyle *style = [[NSParagraphStyle defaultParagraphStyle] mutableCopy];
    [style setAlignment:NSTextAlignmentCenter];
    [style setLineBreakMode:NSLineBreakByWordWrapping];
    [style setLineHeightMultiple:1.4];
    
    NSDictionary *instructionAttributes = @{NSUnderlineStyleAttributeName:@(NSUnderlineStyleNone),
                            NSFontAttributeName:[[Fonts sharedFonts] titleFontBold],
                            NSParagraphStyleAttributeName:style};
    NSMutableAttributedString *insAttributedString = [[NSMutableAttributedString alloc] initWithString:content.instruction attributes:instructionAttributes];
    _instructionLbl.attributedText = insAttributedString;
    
    _linksTxtView.delegate = self;
    _linksTxtView.dataDetectorTypes = UIDataDetectorTypeLink;
    _linksTxtView.text = @"By clicking the button, you agree with our  Privacy Policy and our Terms of Service.";
    
    NSMutableParagraphStyle *style2 = [[NSParagraphStyle defaultParagraphStyle] mutableCopy];
    [style2 setAlignment:NSTextAlignmentCenter];
    [style2 setLineBreakMode:NSLineBreakByWordWrapping];
    NSDictionary *linksAttributes = @{NSUnderlineStyleAttributeName:@(NSUnderlineStyleNone),
                                      NSFontAttributeName:[[Fonts sharedFonts] normalFont],
                                      NSParagraphStyleAttributeName:style2,
                                      NSForegroundColorAttributeName:[UIColor whiteColor]
                                      };
    NSMutableAttributedString *linksAttributedString = [[NSMutableAttributedString alloc] initWithString:_linksTxtView.text attributes:linksAttributes];
    NSRange range1 = [_linksTxtView.text rangeOfString:@"Privacy Policy"];
    [linksAttributedString addAttribute:NSUnderlineStyleAttributeName
                            value:[NSNumber numberWithInt:1]
                            range:range1];
    [linksAttributedString addAttribute:NSLinkAttributeName
                                  value:@"PRIVACY_POLICY"
                                  range:range1];
    
    NSRange range2 = [_linksTxtView.text rangeOfString:@"Terms of Service"];
    [linksAttributedString addAttribute:NSUnderlineStyleAttributeName
                                  value:[NSNumber numberWithInt:1]
                                  range:range2];
    [linksAttributedString addAttribute:NSLinkAttributeName
                                  value:@"TERMS_OF_SERVICE"
                                  range:range2];
    _linksTxtView.attributedText = linksAttributedString;
    _linksTxtView.linkTextAttributes = @{NSForegroundColorAttributeName:[UIColor whiteColor]};
    
    
    if((self.index+1) != NumberOfPages){
        _linksTxtView.hidden = YES;
    }else{
        _linksTxtView.hidden = NO;
    }
    
    [self setConstraints];
}

- (void)setConstraints{
    _imageViewConstraintHeight.constant = 400;
    _instructionConstraintHeight.constant = 180;
    
    if(IS_IPHONE_5){
        _imageViewConstraintHeight.constant = 300;
        _instructionConstraintHeight.constant = 100;
    }
    else if(IS_STANDARD_IPHONE_6_PLUS || IS_STANDARD_IPHONE_6){
        _imageViewConstraintHeight.constant = 350;
        _instructionConstraintHeight.constant = 136;
    }
}

- (void)viewDidLayoutSubviews{
    [super viewDidLayoutSubviews];
}

#pragma mark - UITextViewDelegate
- (BOOL)textView:(UITextView *)textView shouldInteractWithURL:(NSURL *)URL inRange:(NSRange)characterRange interaction:(UITextItemInteraction)interaction{
    
    if([URL.absoluteString isEqualToString:@"PRIVACY_POLICY"]){
        [self openPrivacyPolicy];
    }else if([URL.absoluteString isEqualToString:@"TERMS_OF_SERVICE"]){
        [self openTermsOfService];
    }
    
    return false;
}

- (void)openPrivacyPolicy{
    [self openOverlayViewWithTitle:[[TranslationsModel sharedInstance] getTranslationForKey:@"privacypolicy.title"]
                              desc:[[TranslationsModel sharedInstance] getTranslationForKey:@"privacypolicy.text"]];
}

- (void)openTermsOfService{
    [self openOverlayViewWithTitle:[[TranslationsModel sharedInstance] getTranslationForKey:@"termsofservice.title"]
                              desc:[[TranslationsModel sharedInstance] getTranslationForKey:@"termsofservice.text"]];
}

- (void)openOverlayViewWithTitle:(NSString *)titleStr desc:(NSString *)desc{
    TextViewOverlayViewController *vc = [[TextViewOverlayViewController alloc] initWithNibName:@"TextViewOverlayViewController" bundle:nil];
    
    vc.titleStr = titleStr;
    vc.desc = desc;
    
    vc.view.backgroundColor = [UIColor clearColor];
    vc.modalPresentationStyle = UIModalPresentationOverCurrentContext;
    
    //UIViewController *pvc = delegate.tabBarController.presentedViewController;
    [self presentViewController:vc animated:NO completion:nil];
}

- (IBAction)goToNext:(id)sender {
    
    //go to next slide
    if((self.index+1) != NumberOfPages){
        if([self.delegate respondsToSelector:@selector(navigateToNextSlideWithCurrentIndex:)]){
            [self.delegate navigateToNextSlideWithCurrentIndex:self.index];
        }
        return;
    }
    
    //finish show onBoarding
    if([self.delegate respondsToSelector:@selector(finishedOnBoarding)]){
        [self.delegate finishedOnBoarding];
    }
}

@end
