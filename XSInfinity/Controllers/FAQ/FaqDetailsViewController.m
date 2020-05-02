//
//  FaqDetailsViewController.m
//  XSInfinity
//
//  Created by Joseph Marvin Magdadaro on 8/9/18.
//  Copyright © 2018 Jerk Magz. All rights reserved.
//

#import "FaqDetailsViewController.h"
#import <MessageUI/MessageUI.h>
#import "Helper.h"
#import "Fonts.h"
#import "Colors.h"
#import "TranslationsModel.h"
#import "CustomNavigation.h"
#import "ToastView.h"
#import "NetworkManager.h"
#import "AppDelegate.h"

@interface FaqDetailsViewController ()<MFMailComposeViewControllerDelegate, NetworkManagerDelegate, ToastViewDelegate>{
    Helper *helper;
    Fonts *fonts;
    Colors *colors;
    TranslationsModel *translationsModel;
    AppDelegate *delegate;
    BOOL didLayoutReloaded;
    NSString *faqDetail;
}
@property (weak, nonatomic) IBOutlet UIView *scrollContentView;
@property (weak, nonatomic) IBOutlet NSLayoutConstraint *scrollContentViewHeightConstraint;

@property (weak, nonatomic) IBOutlet UIView *contentView;
@property (weak, nonatomic) IBOutlet UILabel *titleLbl;
@property (weak, nonatomic) IBOutlet UITextView *txtView;
@property (weak, nonatomic) IBOutlet UIButton *okayBtn;
@property (weak, nonatomic) IBOutlet UIButton *helpBtn;

@end

@implementation FaqDetailsViewController

- (void)viewWillAppear:(BOOL)animated{
    [super viewWillAppear:YES];
    self.navigationController.navigationBar.hidden = NO;
    [[CustomNavigation sharedInstance] addOrRemoveBlurEffectAndLineForNavigationInViewController:self];
}

- (void)viewDidLoad {
    [super viewDidLoad];
    self.navigationController.navigationBar.hidden = NO;
    self.navigationItem.title = [[TranslationsModel sharedInstance] getTranslationForKey:@"faq.title"];
    self.navigationItem.largeTitleDisplayMode = UINavigationItemLargeTitleDisplayModeNever;
    
    fonts = [Fonts sharedFonts];
    colors = [Colors sharedColors];
    helper = [Helper sharedHelper];
    translationsModel = [TranslationsModel sharedInstance];
    delegate = (AppDelegate *)[[UIApplication sharedApplication] delegate];
    
    NSString *faqCatTitle = [translationsModel getTranslationForKey:[NSString stringWithFormat:@"%@%@.title", Cf_domain_model_FaqCategory, self.faq.categoryIdentifier]];
    NSString *faqTitle = [translationsModel getTranslationForKey:[NSString stringWithFormat:@"%@%@.title", Cf_domain_model_Faq, self.faq.identifier]];
    NSString *faqAnswer = [translationsModel getTranslationForKey:[NSString stringWithFormat:@"%@%@.answer", Cf_domain_model_Faq, self.faq.identifier]];
    
    _titleLbl.text = faqCatTitle;
    faqDetail = [NSString stringWithFormat:@"<b>%@</b><p>%@</p>",faqTitle, faqAnswer];
}

- (void)viewDidAppear:(BOOL)animated{
    [super viewDidAppear:YES];
    
    [[ToastView sharedInstance] setDelegate:self];
    [[NetworkManager sharedInstance] setDelegate:self];
    [[NetworkManager sharedInstance] connectivityMonitoring];
}

- (void)viewDidDisappear:(BOOL)animated{
    [super viewDidDisappear:YES];
    [[NetworkManager sharedInstance] stopMonitoring];
}

#pragma mark - NetworkManagerDelegate
-(void) finishedConnectivityMonitoring:(AFNetworkReachabilityStatus)status{
    //0 - Offline
    if((long)status == 0){
        [[NetworkManager sharedInstance] showConnectionErrorInViewController:delegate.tabBarController];
    }
}

#pragma mark - ToastViewDelegate
-(void)retryConnection{
    if([[NetworkManager sharedInstance] isConnectionOffline]){
        [[NetworkManager sharedInstance] showConnectionErrorInViewController:delegate.tabBarController];
    }
}

-(void)viewDidLayoutSubviews{
    [super viewDidLayoutSubviews];
    
    if( !didLayoutReloaded ){
        [self setupUserInterface];
        
        didLayoutReloaded = YES;
    }
}

- (void)setupUserInterface{
    [[CustomNavigation sharedInstance] removeBlurEffectIn:self];
    [[CustomNavigation sharedInstance] addNavBarCustomBottomLineIn:self];
    
    [_contentView layoutIfNeeded];
    [helper addDropShadowIn:_contentView withColor:[UIColor darkGrayColor] andSetCornerRadiusTo:5.0];
    
    _titleLbl.font = [fonts headerFont];
    _okayBtn.titleLabel.font = [fonts normalFontBold];
    
    [_okayBtn setTitle:[translationsModel getTranslationForKey:@"faq.gotit_button"] forState:UIControlStateNormal];
    
    NSMutableParagraphStyle *style = [[NSParagraphStyle defaultParagraphStyle] mutableCopy];
    [style setAlignment:NSTextAlignmentCenter];
    [style setLineBreakMode:NSLineBreakByWordWrapping];
    
    NSDictionary *dict1 = @{NSUnderlineStyleAttributeName:@(NSUnderlineStyleSingle),
                            NSFontAttributeName:[fonts normalFont],
                            NSParagraphStyleAttributeName:style};
    
    NSMutableAttributedString *helpString = [[NSMutableAttributedString alloc] init];
    [helpString appendAttributedString:[[NSAttributedString alloc] initWithString:[translationsModel getTranslationForKey:@"faq.needhelplink"] attributes:dict1]];
    [_helpBtn setAttributedTitle:helpString forState:UIControlStateNormal];
    
    _okayBtn.backgroundColor = [colors blueColor];
    
    [_txtView setTextContainerInset:UIEdgeInsetsMake(16, 20, 0, 20)];
    
    _txtView.attributedText = [helper formatText:faqDetail];
    
    [self.view layoutIfNeeded];
    _scrollContentViewHeightConstraint.constant = CGRectGetHeight(_scrollContentView.frame) + (CGRectGetHeight(_txtView.frame) - 250);
    
}

- (IBAction)gotIt:(id)sender{
    [self.navigationController popViewControllerAnimated:YES];
}

- (IBAction)needHelp:(id)sender{
    MFMailComposeViewController *mc = [[MFMailComposeViewController alloc] init];
    
    if ([MFMailComposeViewController canSendMail]) {
        mc.mailComposeDelegate = self;
        [mc setSubject:[translationsModel getTranslationForKey:@"faq.needhelplink"]];
        [mc setToRecipients:@[@"oliver@chinafitter.com"]];
        [mc setMessageBody:@"" isHTML:NO];
        
        mc.navigationBar.barTintColor = [UIColor blackColor];
        mc.navigationBar.tintColor = [UIColor blackColor];
        [[mc navigationBar] setTitleTextAttributes:[NSDictionary dictionaryWithObject:[UIColor blackColor] forKey:NSForegroundColorAttributeName]];
        
        [self presentViewController:mc animated:YES completion:NULL];
        
    }
}

- (void) mailComposeController:(MFMailComposeViewController *)controller didFinishWithResult:(MFMailComposeResult)result error:(NSError *)error
{
    switch (result)
    {
        case MFMailComposeResultCancelled:
            NSLog(@"Mail cancelled");
            break;
        case MFMailComposeResultSaved:
            NSLog(@"Mail saved");
            break;
        case MFMailComposeResultSent:
        {
            NSLog(@"Mail sent");
        }
            break;
        case MFMailComposeResultFailed:
        {
            NSLog(@"Mail sent failure: %@", [error localizedDescription]);
        }
            break;
        default:
            break;
    }
    
    [self dismissViewControllerAnimated:YES completion:NULL];

}

#pragma mark - UIScrollView Delegate
- (void)scrollViewDidScroll:(UIScrollView *)scrollView{
    [self.view layoutIfNeeded];
    [[CustomNavigation sharedInstance] addOrRemoveBlurEffectAndLineForNavigationInViewController:self];
}

- (IBAction)back:(id)sender {
    [self.navigationController popViewControllerAnimated:YES];
}

@end
