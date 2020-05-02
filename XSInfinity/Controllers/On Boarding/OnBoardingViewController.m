//
//  OnBoardingViewController.m
//  XSInfinity
//
//  Created by Joseph Marvin Magdadaro on 16/12/2018.
//  Copyright © 2018 Jerk Magz. All rights reserved.
//

#import "OnBoardingViewController.h"
#import "OnBoardingContentViewController.h"
#import "SignInViewController.h"
#import "Colors.h"

static int const NumberOfPages = 4;

@interface OnBoardingViewController ()<UIPageViewControllerDataSource, OnBoardingContentViewControllerDelegate>
@property (nonatomic, strong) UIPageViewController *pageController;
@property (strong, nonatomic) UIPageControl *pageControl;

//used for page control positioning
@property (weak, nonatomic) IBOutlet UIView *invisibleView;
@property (weak, nonatomic) IBOutlet NSLayoutConstraint *invisibleViewConstraintHeight;
@end

@implementation OnBoardingViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    
    self.pageController = [[UIPageViewController alloc] initWithTransitionStyle:UIPageViewControllerTransitionStyleScroll navigationOrientation:UIPageViewControllerNavigationOrientationHorizontal options:nil];
    
    self.pageController.dataSource = self;
    [[self.pageController view] setFrame:[[self view] bounds]];
    
    OnBoardingContentViewController *initialViewController = [self viewControllerAtIndex:0];
    
    NSArray *viewControllers = [NSArray arrayWithObject:initialViewController];
    
    [self.pageController setViewControllers:viewControllers direction:UIPageViewControllerNavigationDirectionForward animated:NO completion:nil];
    
    [self addChildViewController:self.pageController];
    [[self view] addSubview:[self.pageController view]];
    [self.pageController didMoveToParentViewController:self];
    
    self.pageControl = [[UIPageControl alloc] initWithFrame:CGRectMake(0, CGRectGetMaxY(_invisibleView.frame) - 50, self.view.frame.size.width, 50)]; // your position
    self.pageControl.userInteractionEnabled = false;
    self.pageControl.backgroundColor = [UIColor clearColor];
    self.pageControl.numberOfPages = NumberOfPages;
    self.pageControl.pageIndicatorTintColor = [[UIColor whiteColor] colorWithAlphaComponent:0.75];
    self.pageControl.currentPageIndicatorTintColor = [[Colors sharedColors] orangeColor];
    [self.view addSubview: self.pageControl];
}

- (void)setConstraints{
    _invisibleViewConstraintHeight.constant = 400;
    if(IS_IPHONE_5){
        _invisibleViewConstraintHeight.constant = 300;
    }
    else if(IS_STANDARD_IPHONE_6_PLUS || IS_STANDARD_IPHONE_6){
        _invisibleViewConstraintHeight.constant = 350;
    }
}

- (void)viewDidLayoutSubviews{
    [super viewDidLayoutSubviews];
    [_invisibleView layoutIfNeeded];
    
    [self setConstraints];
    self.pageControl.frame = CGRectMake(0, _invisibleViewConstraintHeight.constant - 50, self.view.frame.size.width, 50); // your position
    
    CGAffineTransform transform = CGAffineTransformIdentity;
    transform = CGAffineTransformScale(transform, 1.7, 1.7);
    
    for (UIView *v in self.pageControl.subviews) {
        v.transform = transform;
    }
}

#pragma mark - UIPageViewControllerDataSource

- (UIViewController *)pageViewController:(UIPageViewController *)pageViewController viewControllerBeforeViewController:(UIViewController *)viewController {
    
    NSUInteger index = [(OnBoardingContentViewController *)viewController index];
    self.pageControl.currentPage = index;
    
    if (index == 0) {
        index = NumberOfPages;
    }
    
    index--;
    
    return [self viewControllerAtIndex:(int)index];
}

- (UIViewController *)pageViewController:(UIPageViewController *)pageViewController viewControllerAfterViewController:(UIViewController *)viewController {
    
    NSUInteger index = [(OnBoardingContentViewController *)viewController index];
    self.pageControl.currentPage = index;
    
    index++;
    
    if (index == NumberOfPages) {
        index = 0;
    }
    
    return [self viewControllerAtIndex:(int)index];
}

/*- (NSInteger)presentationCountForPageViewController:(UIPageViewController *)pageViewController {
    // The number of items reflected in the page indicator.
    return 5;
}

- (NSInteger)presentationIndexForPageViewController:(UIPageViewController *)pageViewController {
    // The selected item reflected in the page indicator.
    return 0;
}*/

-(OnBoardingContentViewController *)viewControllerAtIndex:(int)index{
    OnBoardingContentViewController *vc = [[OnBoardingContentViewController alloc] initWithNibName:@"OnBoardingContentViewController" bundle:nil];
    vc.delegate = self;
    vc.index = index;
    return vc;
}

#pragma mark - OnBoardingContentViewControllerDelegate

-(void)navigateToNextSlideWithCurrentIndex:(NSInteger)index{
    int nextIndex = (int)(index+1);
    
    OnBoardingContentViewController *initialViewController = [self viewControllerAtIndex:nextIndex];
    NSArray *viewControllers = [NSArray arrayWithObject:initialViewController];
    [self.pageController setViewControllers:viewControllers
                                  direction:UIPageViewControllerNavigationDirectionForward
                                   animated:YES
                                 completion:nil];
    self.pageControl.currentPage = nextIndex;
}

-(void)finishedOnBoarding{
    SignInViewController *vc = [[SignInViewController alloc] initWithNibName:@"SignInViewController" bundle:nil];
    [self.navigationController pushViewController:vc animated:NO];
}
@end
